import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart' show BusinessType, UuidValue;
import 'package:lakuna_data/lakuna_data.dart' show StockRow;
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/ui/home/home_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/fake_backup_repository.dart';
import '../../testing/fake_dining_repository.dart';
import '../../testing/fake_reports_repository.dart';
import '../../testing/fake_session_repository.dart';
import '../../testing/fake_stock_repository.dart';
import '../../testing/fake_store_repository.dart';

void main() {
  late FakeStoreRepository store;
  late FakeSessionRepository session;
  late FakeReportsRepository reports;
  late FakeStockRepository stock;
  late FakeDiningRepository dining;
  late FakeBackupRepository backup;
  // 09.30 WIB.
  var now = DateTime.utc(2026, 11, 4, 2, 30);

  HomeViewModel vm() => HomeViewModel(
    store: store,
    session: session,
    reports: reports,
    stock: stock,
    dining: dining,
    backup: backup,
    clock: () => now,
  );

  setUp(() {
    now = DateTime.utc(2026, 11, 4, 2, 30);
    store = FakeStoreRepository(
      current: sampleStoreContext(timezone: 'Asia/Jakarta'),
    );
    session = FakeSessionRepository()..current = sampleStaff();
    reports = FakeReportsRepository();
    stock = FakeStockRepository();
    dining = FakeDiningRepository();
    backup = FakeBackupRepository(last: DateTime.utc(2026, 11, 3, 14, 4));
  });

  test('sapaan menurut jam cabang', () {
    expect(DayPart.at(4), DayPart.morning);
    expect(DayPart.at(10), DayPart.morning);
    expect(DayPart.at(11), DayPart.midday);
    expect(DayPart.at(15), DayPart.afternoon);
    expect(DayPart.at(18), DayPart.night);
    expect(DayPart.at(3), DayPart.night);
    expect(vm().dayPart, DayPart.morning);
    now = DateTime.utc(2026, 11, 4, 12); // 19.00 WIB
    expect(vm().dayPart, DayPart.night);
  });

  test('pemilik: penjualan, stok minimum, QRIS menunggu, backup', () async {
    final report = switch (await reports.load(ReportPeriod.today)) {
      Ok(:final value) => value,
      Error(:final error) => throw error,
    };
    final low = switch (await stock.belowMinimum()) {
      Ok(:final value) => value,
      Error(:final error) => throw error,
    };
    final home = vm();
    await home.load.execute();
    expect(home.sales, (
      total: report.netSales,
      count: report.saleCount,
      average: report.averagePerSale,
    ));
    expect(home.belowMinimum, low.length);
    expect(home.pendingQris, isNull); // retail
    expect(home.showBackup, isTrue);
    // Backup 21.04 WIB kemarin.
    expect(home.backupDaysAgo, 1);
    expect(home.backupOverdue, isFalse);
    // Retail: tanpa Meja.
    expect(
      home.modules.map((e) => e.key),
      homeModuleKeys.where((k) => k != 'tables'),
    );
    expect(home.staffName, 'Yusuf');
  });

  test('F&B: Meja dan QRIS menunggu', () async {
    store = FakeStoreRepository(
      current: sampleStoreContext(
        timezone: 'Asia/Jakarta',
        businessType: BusinessType.fnb,
      ),
    );
    final home = vm();
    await home.load.execute();
    expect(home.modules.map((e) => e.key), homeModuleKeys);
    expect(home.pendingQris, 0);
  });

  test('retail: QRIS menunggu tidak dimuat', () async {
    final home = vm();
    await home.load.execute();
    expect(home.pendingQris, isNull);
  });

  test('galat non-Exception tidak menggagalkan Beranda', () async {
    final home = HomeViewModel(
      store: store,
      session: session,
      reports: reports,
      stock: _ThrowingStock(),
      backup: backup,
      clock: () => now,
    );
    await home.load.execute();
    expect(home.load.error, isFalse);
    expect(home.belowMinimum, isNull);
    expect(home.sales, isNotNull);
    expect(home.showBackup, isTrue);
  });

  test('batas jam sapaan dan hari backup', () async {
    expect(DayPart.at(14), DayPart.midday);
    expect(DayPart.at(17), DayPart.afternoon);
    // Backup 8 hari lalu: lewat batas pengingat.
    backup.last = DateTime.utc(2026, 10, 27, 2);
    final home = vm();
    await home.load.execute();
    expect(home.backupDaysAgo, 8);
    expect(home.backupOverdue, isTrue);
    // Jam perangkat mundur: tidak negatif.
    backup.last = DateTime.utc(2026, 11, 6);
    final skew = vm();
    await skew.load.execute();
    expect(skew.backupDaysAgo, 0);
  });

  test('kasir: tanpa laporan, stok, backup', () async {
    session.current = sampleStaff(name: 'Dimas', role: 'cashier');
    final home = vm();
    await home.load.execute();
    expect(home.sales, isNull);
    expect(home.belowMinimum, isNull);
    expect(home.showBackup, isFalse);
    expect(home.modules.map((e) => e.key), isNot(contains('reports')));
    expect(home.modules.map((e) => e.key), contains('cashier'));
  });

  test('galat sumber hanya menyembunyikan barisnya', () async {
    stock.nextError = Exception('rusak');
    dining.nextError = Exception('rusak');
    backup.last = null;
    final home = vm();
    await home.load.execute();
    expect(home.belowMinimum, isNull);
    expect(home.pendingQris, isNull);
    expect(home.sales, isNotNull);
    expect(home.backupDaysAgo, isNull);
    expect(home.backupOverdue, isTrue);
  });
}

class _ThrowingStock extends FakeStockRepository {
  @override
  Future<Result<List<StockRow>>> belowMinimum({UuidValue? locationId}) =>
      throw StateError('rusak');
}
