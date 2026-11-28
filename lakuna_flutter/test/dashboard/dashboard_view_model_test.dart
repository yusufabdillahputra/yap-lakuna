import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart' show DashboardData;
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/spreadsheet_exporter.dart';
import 'package:lakuna_flutter/ui/dashboard/dashboard_view_model.dart';

import '../testing/fake_dashboard_repository.dart';

class _Exporter implements SpreadsheetExporter {
  final saved = <String>[];

  @override
  Future<String?> save(Uint8List bytes, {required String fileName}) async {
    saved.add(fileName);
    return '/tmp/$fileName';
  }
}

class _Ticker {
  void Function(Timer)? tick;
  Duration? every;
  var cancelled = false;

  Timer start(Duration d, void Function(Timer) cb) {
    every = d;
    tick = cb;
    return _FakeTimer(this);
  }
}

class _FakeTimer implements Timer {
  _FakeTimer(this.owner);
  final _Ticker owner;

  @override
  void cancel() => owner.cancelled = true;

  @override
  bool get isActive => !owner.cancelled;

  @override
  int get tick => 0;
}

void main() {
  final now = DateTime.utc(2026, 11, 28, 8);
  late FakeDashboardRepository repo;
  late _Ticker ticker;
  late _Exporter exporter;

  setUp(() {
    repo = FakeDashboardRepository(now: now)
      ..status = TenantStatus(
        devices: [
          device('K01', pusatId, now.subtract(const Duration(minutes: 2))),
          device('K02', pusatId, now.subtract(const Duration(hours: 3))),
          device('K03', timurId, now.subtract(const Duration(minutes: 5))),
        ],
        openConflicts: 2,
        serverTime: now,
      );
    ticker = _Ticker();
    exporter = _Exporter();
  });

  DashboardViewModel vm() => DashboardViewModel(
    repository: repo,
    exporter: exporter,
    clock: () => repo.now,
    periodic: ticker.start,
  );

  test('semua cabang: total = jumlah per cabang, rata-rata, perangkat '
      'online', () async {
    final m = vm();
    await m.start();
    expect(m.totalSales, const Money(36000));
    expect(m.transactions, 3);
    expect(m.average, const Money(12000));
    expect(m.outletCount, 2);
    expect(m.hourly[14], const Money(26000));
    expect(m.axis, (from: 8, to: 17));
    expect(m.rows.map((r) => r.code), ['PST', 'TMR']);
    final pusat = m.rows.first;
    expect(pusat.devices, 2);
    expect(pusat.offline, 1);
    expect(pusat.lastSync, now.subtract(const Duration(minutes: 2)));
    expect(m.devicesOnline, 2);
    expect(m.devicesTotal, 3);
    expect(m.conflicts, 2);
    expect(m.attention.whereType<AttentionDevice>().single.device.code, 'K02');
    expect(m.attention.whereType<AttentionConflicts>().single.count, 2);
    expect(m.allClear, isFalse);
    m.dispose();
  });

  test('pilih cabang memfilter angka, perangkat, dan terlaris', () async {
    final m = vm();
    await m.start();
    await m.selectOutlet(timurId);
    expect(repo.loads.last?.uuid, timurId);
    expect(m.totalSales, const Money(6000));
    expect(m.rows.map((r) => r.code), ['TMR']);
    expect(m.top.map((t) => t.name), ['Isi Pulsa']);
    expect(m.devicesTotal, 1);
    expect(m.devicesOnline, 1);
    await m.selectOutlet(null);
    expect(m.rows, hasLength(2));
    m.dispose();
  });

  test(
    'setiap 60 detik status perangkat dimuat ulang; dispose berhenti',
    () async {
      final m = vm();
      await m.start();
      expect(ticker.every, const Duration(seconds: 60));
      expect(repo.statusCalls, 1);
      ticker.tick!(_FakeTimer(ticker));
      await pumpEventQueue();
      expect(repo.statusCalls, 2);
      m.dispose();
      expect(ticker.cancelled, isTrue);
    },
  );

  test(
    'offline: angka penjualan tetap, status perangkat tidak tersedia',
    () async {
      repo.status = null;
      final m = vm();
      await m.start();
      expect(m.devicesUnavailable, isTrue);
      expect(m.totalSales, const Money(36000));
      expect(m.allClear, isFalse);
      m.dispose();
    },
  );

  test('tanpa perhatian: Semua beres', () async {
    repo.status = TenantStatus(
      devices: [device('K01', pusatId, now)],
      openConflicts: 0,
      serverTime: now,
    );
    final m = vm();
    await m.start();
    expect(m.attention, isEmpty);
    expect(m.allClear, isTrue);
    m.dispose();
  });

  test('stok minimum per cabang masuk Perlu perhatian', () async {
    repo
      ..status = TenantStatus(devices: [], openConflicts: 0, serverTime: now)
      ..data = (id) {
        final d = sampleDashboard(only: id);
        return DashboardData(
          outlets: d.outlets,
          outletInfo: d.outletInfo,
          top: d.top,
          belowMinimum: {pusatId: 3, timurId: 0},
        );
      };
    final m = vm();
    await m.start();
    final stock = m.attention.whereType<AttentionStock>().single;
    expect((stock.outletName, stock.count), ('Pusat', 3));
  });

  test('Unduh laporan: berkas Excel bernama cabang dan tanggal', () async {
    final m = vm();
    await m.start();
    await m.exportExcel.execute(Uint8List(4));
    expect(exporter.saved, ['dashboard-semua-cabang-261128.xlsx']);
    expect(m.exportPath, '/tmp/dashboard-semua-cabang-261128.xlsx');
    await m.selectOutlet(timurId);
    await m.exportExcel.execute(Uint8List(4));
    expect(exporter.saved.last, 'dashboard-TMR-261128.xlsx');
    m.dispose();
  });

  test('tanggal nama berkas mengikuti zona waktu cabang', () async {
    // 18.00Z tanggal 28 = 01.00 WIB tanggal 29.
    repo.now = DateTime.utc(2026, 11, 28, 18);
    final m = DashboardViewModel(
      repository: repo,
      exporter: exporter,
      clock: () => repo.now,
      periodic: ticker.start,
      timezone: 'Asia/Jakarta',
    );
    await m.start();
    expect(m.exportFileName(), 'dashboard-semua-cabang-261129.xlsx');
    m.dispose();
  });

  test('pilih cabang saat muat berkala berjalan: hasil cabang baru menang '
      '(review I1)', () async {
    final m = vm();
    await m.start();
    repo.loadGate = Completer<void>();
    ticker.tick!(_FakeTimer(ticker));
    await pumpEventQueue();
    expect(m.load.running, isTrue);
    final picked = m.selectOutlet(timurId);
    repo.loadGate!.complete();
    repo.loadGate = null;
    await picked;
    await pumpEventQueue();
    expect(repo.loads.last?.uuid, timurId);
    expect(m.rows.map((r) => r.code), ['TMR']);
    expect(m.totalSales, const Money(6000));
    m.dispose();
  });

  test(
    'angka penjualan tampil tanpa menunggu status perangkat (review I2)',
    () async {
      repo.statusGate = Completer<void>();
      final m = vm();
      await m.start();
      expect(m.totalSales, const Money(36000));
      expect(m.devicesUnavailable, isTrue);
      expect(m.load.running, isFalse);
      repo.statusGate!.complete();
      await pumpEventQueue();
      expect(m.devicesUnavailable, isFalse);
      expect(m.devicesTotal, 3);
      m.dispose();
    },
  );

  test('dispose sebelum muatan pertama selesai: timer tidak dibuat '
      '(review I3)', () async {
    repo.loadGate = Completer<void>();
    final m = vm();
    final started = m.start();
    m.dispose();
    repo.loadGate!.complete();
    await started;
    expect(ticker.tick, isNull);
  });
}
