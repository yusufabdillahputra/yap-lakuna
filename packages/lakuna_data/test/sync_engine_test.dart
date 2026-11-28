import 'dart:async';
import 'dart:io';

import 'package:fake_async/fake_async.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart' show TableRow;
import 'package:test/test.dart';

import 'helpers.dart';
import 'testing/fake_sync_transport.dart';

final deviceB = UuidValue.fromString('01900000-0000-7000-8000-0000000000b1');

void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;
  late DateTime now;
  late FakeSyncTransport server;
  late SyncEngine engine;
  late UuidValue productId;
  var tick = 0;

  /// HLC perangkat B sedikit setelah [now].
  String hlcB() =>
      Hlc(now.millisecondsSinceEpoch + 1000, tick++, deviceB.uuid).toString();

  Map<String, dynamic> fromB(
    TableRow<UuidValue?> row,
    Map<String, dynamic> changes,
  ) => {
    ...(row.toJson() as Map<String, dynamic>),
    'id': newId(),
    'hlc': hlcB(),
    'originDeviceId': deviceB.uuid,
    ...changes,
  };

  Future<List<SyncOutboxEntry>> outbox() =>
      SyncOutboxEntry.db.find(store.session, orderBy: (e) => e.id);

  setUp(() async {
    now = DateTime.utc(2026, 11, 28, 5);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    productId = await saveProduct(
      store,
      scope,
      staffId: ctx.owner.id,
      draft: const ProductDraft(
        name: 'Teh',
        baseUnit: 'pcs',
        variants: [
          VariantDraft(
            costPrice: Money(1000),
            sellPrice: Money(1500),
            openingStock: Qty(5000),
          ),
        ],
      ),
    );
    server = FakeSyncTransport(serverTime: now);
    engine = SyncEngine(store, server, batchSize: 7);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test('push urut id outbox, per batch, applied → acked', () async {
    final r = await engine.runCycle();
    expect(r.outcome, SyncCycleOutcome.synced);
    expect(r.pending, 0);
    final entries = await outbox();
    expect(server.pushed.every((b) => b.length <= 7), isTrue);
    expect(server.pushed.length, greaterThan(1));
    expect(
      [for (final b in server.pushed) ...b.map((e) => (e.rowId, e.hlc))],
      [for (final e in entries) (e.rowId, e.hlc)],
    );
    expect(entries.every((e) => e.status == OutboxStatus.acked), isTrue);
  });

  test('rejected → conflict; dependency dicoba ulang, final tidak', () async {
    server.onPush = (e) =>
        _reject(e, {
          'products': SyncRejectReason.dependency,
          'product_variants': SyncRejectReason.finalDocument,
        }) ??
        SyncPushResult(
          rowId: e.rowId,
          hlc: e.hlc,
          kind: SyncResultKind.applied,
        );
    final first = await engine.runCycle();
    expect(first.outcome, SyncCycleOutcome.attention);
    expect(first.conflicts, 2);
    final conflict = (await outbox()).where(
      (e) => e.status == OutboxStatus.conflict,
    );
    expect(
      {for (final e in conflict) e.lastError},
      {'dependency', 'finalDocument'},
    );

    server.onPush = null;
    server.pushed.clear();
    final second = await engine.runCycle();
    expect(
      [for (final b in server.pushed) ...b.map((e) => e.tableName)],
      ['products'],
    );
    expect(second.conflicts, 1);
  });

  test('balasan stale menimpa baris lokal tanpa outbox baru', () async {
    await engine.runCycle();
    now = now.add(const Duration(seconds: 5));
    await archiveProduct(
      store,
      scope,
      staffId: ctx.owner.id,
      productId: productId,
    );
    final local = (await Product.db.findById(store.session, productId))!;
    final serverRow = {
      ...local.toJson(),
      'name': 'Teh Server',
      'deletedAt': null,
      'hlc': Hlc(now.millisecondsSinceEpoch + 9000, 0, 'server').toString(),
    }..remove('deletedAt');
    server.onPush = (e) => e.tableName == 'products'
        ? SyncPushResult(
            rowId: e.rowId,
            hlc: e.hlc,
            kind: SyncResultKind.stale,
            serverPayloadJson: jsonEncodeRow(serverRow),
          )
        : SyncPushResult(
            rowId: e.rowId,
            hlc: e.hlc,
            kind: SyncResultKind.applied,
          );
    final before = (await outbox()).length;
    await engine.runCycle();
    final after = await Product.db.findById(store.session, productId);
    expect(after!.name, 'Teh Server');
    expect(after.deletedAt, isNull);
    expect((await outbox()).length, before);
    expect(
      (await outbox()).every((e) => e.status == OutboxStatus.acked),
      isTrue,
    );
  });

  test('pull menerapkan baris tanpa outbox dan menyimpan kursor', () async {
    await engine.runCycle();
    final unit = (await MeasureUnit.db.find(store.session)).first;
    final row = fromB(unit, {'name': 'karung'});
    server.addChange('units', row);
    final before = (await outbox()).length;
    await engine.runCycle();
    final pulled = await MeasureUnit.db.findById(
      store.session,
      UuidValue.fromString(row['id'] as String),
    );
    expect(pulled!.name, 'karung');
    expect((await outbox()).length, before);
    expect(await store.syncState(SyncStateKey.pullCursor), '1');
  });

  test('baris lokal lebih baru tidak ditimpa pull yang lebih lama', () async {
    await engine.runCycle();
    final p = (await Product.db.findById(store.session, productId))!;
    server.addChange('products', {
      ...p.toJson(),
      'name': 'Teh Lama',
      'hlc': Hlc(1, 0, deviceB.uuid).toString(),
    });
    await engine.runCycle();
    expect((await Product.db.findById(store.session, productId))!.name, 'Teh');
  });

  test('FK belum ada: diparkir, lalu berhasil setelah induk datang', () async {
    await engine.runCycle();
    final category = await createCategory(
      store,
      scope,
      staffId: ctx.owner.id,
      draft: const CategoryDraft(name: 'Minuman'),
    );
    await engine.runCycle();
    final p = (await Product.db.findById(store.session, productId))!;
    final newCategory = fromB(category, {'name': 'Snack'});
    final child = fromB(p, {
      'categoryId': newCategory['id'],
      'name': 'Keripik',
    });
    server.addChange('products', child);
    final first = await engine.runCycle();
    expect(first.outcome, SyncCycleOutcome.attention);
    expect(first.conflicts, 1);
    expect(await store.syncState(SyncStateKey.pullCursor), '1');

    server.addChange('categories', newCategory);
    final second = await engine.runCycle();
    expect(second.outcome, SyncCycleOutcome.synced);
    expect(second.conflicts, 0);
    expect(
      await Product.db.findById(
        store.session,
        UuidValue.fromString(child['id'] as String),
      ),
      isNotNull,
    );
    expect(await store.syncState(SyncStateKey.pullCursor), '2');
  });

  test('stock_levels sama dengan bangun ulang penuh setelah pull', () async {
    await engine.runCycle();
    final m = (await StockMovement.db.find(store.session)).single;
    server.addChange(
      'stock_movements',
      fromB(m, {
        'quantityMilli': -2000,
        'sourceType': 'sale',
        'occurredAt': m.occurredAt
            .subtract(const Duration(minutes: 1))
            .toIso8601String(),
      }),
    );
    await engine.runCycle();
    List<(String, int, int)> levels(List<StockLevel> l) => [
      for (final x in l)
        ('${x.variantId}${x.stockLocationId}', x.quantityMilli, x.avgCost),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    final incremental = levels(await StockLevel.db.find(store.session));
    expect(incremental.single.$2, 3000);
    await rebuildStockLevels(store);
    expect(levels(await StockLevel.db.find(store.session)), incremental);
  });

  test('galat jaringan → offline tanpa melempar', () async {
    server.offline = true;
    final r = await engine.runCycle();
    expect(r.outcome, SyncCycleOutcome.offline);
    expect(r.error, 'network');
    expect(await store.syncState(SyncStateKey.lastError), 'network');
  });

  test('HLC lokal maju ke waktu server', () async {
    server.serverTime = now.add(const Duration(hours: 1));
    await engine.runCycle();
    final last = Hlc.parse((await store.syncState(SyncStateKey.lastHlc))!);
    expect(
      last.millis,
      greaterThanOrEqualTo(server.serverTime.millisecondsSinceEpoch),
    );
    expect(last.node, store.deviceId.uuid);
  });

  test('dua runCycle bersamaan = satu siklus', () async {
    final a = engine.runCycle();
    final b = engine.runCycle();
    expect(identical(await a, await b), isTrue);
    expect(server.pulls, 1);
  });

  test(
    'pull banyak halaman: perubahan parkir dari halaman awal tetap disimpan',
    () async {
      await engine.runCycle();
      final p = (await Product.db.findById(store.session, productId))!;
      final orphan = fromB(p, {'categoryId': newId(), 'name': 'Yatim'});
      server.addChange('products', orphan);
      final unit = (await MeasureUnit.db.find(store.session)).first;
      server.addChange('units', fromB(unit, {'name': 'karung'}));
      server.pageSize = 1;
      final r = await engine.runCycle();
      expect(r.conflicts, 1);
      expect(await store.syncState(SyncStateKey.pullCursor), '2');
      expect(
        await store.syncState(SyncStateKey.pullParked),
        contains(orphan['id']),
      );
    },
  );

  test(
    'galat lokal (bukan jaringan) → perlu perhatian, bukan offline',
    () async {
      server.onPush = (e) => throw const FormatException('rusak');
      final r = await engine.runCycle();
      expect(r.outcome, SyncCycleOutcome.attention);
      expect(r.error, 'local');
    },
  );

  test(
    'balasan push kurang dari entri → perlu perhatian tanpa melempar',
    () async {
      final short = _ShortReplyTransport(server);
      final r = await SyncEngine(store, short).runCycle();
      expect(r.outcome, SyncCycleOutcome.attention);
      expect(r.error, 'local');
    },
  );

  test(
    'balasan stale memajukan HLC perangkat melewati HLC baris server',
    () async {
      await engine.runCycle();
      now = now.add(const Duration(seconds: 5));
      await archiveProduct(
        store,
        scope,
        staffId: ctx.owner.id,
        productId: productId,
      );
      final local = (await Product.db.findById(store.session, productId))!;
      final ahead = Hlc(
        now.add(const Duration(minutes: 4)).millisecondsSinceEpoch,
        0,
        deviceB.uuid,
      );
      server.onPush = (e) => e.tableName == 'products'
          ? SyncPushResult(
              rowId: e.rowId,
              hlc: e.hlc,
              kind: SyncResultKind.stale,
              serverPayloadJson: jsonEncodeRow({
                ...local.toJson(),
                'hlc': ahead.toString(),
              }),
            )
          : SyncPushResult(
              rowId: e.rowId,
              hlc: e.hlc,
              kind: SyncResultKind.applied,
            );
      server.offline = false;
      await engine.runCycle();
      final last = Hlc.parse((await store.syncState(SyncStateKey.lastHlc))!);
      expect(last > ahead, isTrue);
    },
  );

  test('entri ditolak clock dicoba ulang dan galat clock bertahan', () async {
    server.onPush = (e) =>
        _reject(e, {'products': SyncRejectReason.clock}) ??
        SyncPushResult(
          rowId: e.rowId,
          hlc: e.hlc,
          kind: SyncResultKind.applied,
        );
    final first = await engine.runCycle();
    expect(first.error, 'clock');
    server.pushed.clear();
    final second = await engine.runCycle();
    expect(
      [for (final b in server.pushed) ...b.map((e) => e.tableName)],
      ['products'],
    );
    expect(second.error, 'clock');
    server.onPush = null;
    final third = await engine.runCycle();
    expect(third.error, isNull);
    expect(third.conflicts, 0);
  });

  group('SyncScheduler', () {
    SyncCycleResult result(SyncCycleOutcome o) =>
        SyncCycleResult(outcome: o, pending: 0, conflicts: 0);

    test('tidak pernah menjalankan dua siklus bersamaan', () {
      fakeAsync((async) {
        var active = 0;
        var maxActive = 0;
        var runs = 0;
        final s = SyncScheduler(() async {
          active++;
          runs++;
          maxActive = active > maxActive ? active : maxActive;
          await Future<void>.delayed(const Duration(seconds: 3));
          active--;
          return result(SyncCycleOutcome.synced);
        });
        s.start();
        for (var i = 0; i < 10; i++) {
          async.elapse(const Duration(milliseconds: 700));
          s.notifyWrite();
          s.syncNow();
        }
        async.elapse(const Duration(seconds: 20));
        expect(maxActive, 1);
        expect(runs, greaterThan(1));
        s.stop();
      });
    });

    test('debounce 2 detik setelah tulis, lalu tiap 30 detik', () {
      fakeAsync((async) {
        var runs = 0;
        final s = SyncScheduler(() async {
          runs++;
          return result(SyncCycleOutcome.synced);
        });
        s.start();
        async.elapse(Duration.zero);
        expect(runs, 1);
        s.notifyWrite();
        async.elapse(const Duration(milliseconds: 1900));
        expect(runs, 1);
        async.elapse(const Duration(milliseconds: 200));
        expect(runs, 2);
        async.elapse(const Duration(seconds: 30));
        expect(runs, 3);
        s.stop();
      });
    });

    test('offline lama: jeda tetap 5 detik sampai 5 menit (tanpa luapan)', () {
      fakeAsync((async) {
        final times = <Duration>[];
        final s = SyncScheduler(() async {
          times.add(async.elapsed);
          return result(SyncCycleOutcome.offline);
        });
        s.start();
        async.elapse(const Duration(hours: 10));
        final gaps = [
          for (var i = 1; i < times.length; i++)
            (times[i] - times[i - 1]).inSeconds,
        ];
        expect(gaps.every((g) => g >= 5 && g <= 300), isTrue);
        expect(times.length, lessThan(200));
        s.stop();
      });
    });

    test('run melempar: penjadwal tetap berjalan', () {
      fakeAsync((async) {
        var runs = 0;
        final s = SyncScheduler(() async {
          runs++;
          if (runs == 1) throw StateError('bug');
          return result(SyncCycleOutcome.synced);
        });
        s.start();
        async.elapse(const Duration(minutes: 2));
        expect(runs, greaterThan(1));
        s.stop();
      });
    });

    test('offline: backoff eksponensial sampai 5 menit', () {
      fakeAsync((async) {
        final times = <Duration>[];
        final s = SyncScheduler(() async {
          times.add(async.elapsed);
          return result(SyncCycleOutcome.offline);
        });
        s.start();
        async.elapse(const Duration(minutes: 20));
        final gaps = [
          for (var i = 1; i < times.length; i++)
            (times[i] - times[i - 1]).inSeconds,
        ];
        expect(gaps.take(4), [5, 10, 20, 40]);
        expect(gaps.reduce((a, b) => a > b ? a : b), 300);
        s.stop();
      });
    });
  });
}

SyncPushResult? _reject(SyncPushEntry e, Map<String, SyncRejectReason> map) {
  final reason = map[e.tableName];
  if (reason == null) return null;
  return SyncPushResult(
    rowId: e.rowId,
    hlc: e.hlc,
    kind: SyncResultKind.rejected,
    reason: reason,
  );
}

/// Transport yang membalas push dengan hasil lebih sedikit dari entri.
class _ShortReplyTransport implements SyncTransport {
  _ShortReplyTransport(this.inner);
  final FakeSyncTransport inner;

  @override
  Future<SyncPushReply> push(List<SyncPushEntry> entries) async {
    final r = await inner.push(entries);
    return r.copyWith(results: r.results.take(1).toList());
  }

  @override
  Future<SyncPullPage> pull(int afterSeq) => inner.pull(afterSeq);

  @override
  Future<SyncServerStatus> status() => inner.status();
}
