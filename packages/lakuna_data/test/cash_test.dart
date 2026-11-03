import 'dart:convert';
import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

const _credentials = SetupCredentials(
  pinHash: r'$argon2id$pin',
  passwordHash: r'$argon2id$password',
);

void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late DateTime now;

  setUp(() async {
    now = DateTime.utc(2026, 11, 3, 0, 58);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupStore(
      store,
      SetupInput(
        businessType: BusinessKind.retail,
        businessName: 'Warung Contoh',
        outletName: 'Cabang Pusat',
        outletCode: 'PST',
        deviceCode: 'K01',
        timezone: 'Asia/Jakarta',
        ownerName: 'Yusuf',
        email: 'yusuf@contoh.id',
        password: 'rahasia123',
        passwordConfirm: 'rahasia123',
        pin: '123456',
        pinConfirm: '123456',
      ),
      platform: DevicePlatform.linux,
      credentials: _credentials,
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  CashScope scope() => CashScope(
    tenantId: ctx.tenant.id,
    outletId: ctx.outlet.id,
    deviceId: store.deviceId,
  );

  Future<CashSession> open({int cash = 200000, String note = ''}) =>
      openCashSession(
        store,
        scope(),
        staffId: ctx.owner.id,
        openingCash: Money(cash),
        note: note,
      );

  Future<int> outboxCount(String table) async {
    final rows = await SyncOutboxEntry.db.find(store.session);
    return rows.where((r) => r.entity == table).length;
  }

  group('buka sesi', () {
    test('menulis satu baris terbuka dan satu entri outbox', () async {
      final session = await open(note: '  Laci pagi ');
      expect(session.status, CashSessionStatus.opened);
      expect(session.openingCash, 200000);
      expect(session.openingNote, 'Laci pagi');
      expect(session.openedBy, ctx.owner.id);
      expect(session.openedAt, now);
      expect(session.deviceId, store.deviceId);
      expect(session.createdBy, ctx.owner.id);
      expect(await outboxCount('cash_sessions'), 1);

      final found = await findOpenCashSession(store, scope());
      expect(found?.id, session.id);
    });

    test('catatan kosong disimpan sebagai null', () async {
      final session = await open();
      expect(session.openingNote, isNull);
    });

    test('sesi kedua di perangkat yang sama ditolak', () async {
      await open();
      await expectLater(open(), throwsA(isA<CashSessionAlreadyOpen>()));
      expect(await CashSession.db.count(store.session), 1);
    });

    test('saldo awal negatif ditolak tanpa menulis', () async {
      await expectLater(
        open(cash: -1),
        throwsA(
          isA<CashInputInvalid>().having(
            (e) => e.error,
            'error',
            CashError.negative,
          ),
        ),
      );
      expect(await CashSession.db.count(store.session), 0);
    });

    test('belum ada sesi → null', () async {
      expect(await findOpenCashSession(store, scope()), isNull);
    });

    test('sesi perangkat lain tidak terbaca', () async {
      final other = await store.write(actor: ctx.owner.id, (w) async {
        final s = await w.stamp();
        return w.insert(
          Device(
            tenantId: ctx.tenant.id,
            outletId: ctx.outlet.id,
            code: 'K02',
            name: 'Perangkat K02',
            platform: DevicePlatform.android,
            createdBy: ctx.owner.id,
            updatedBy: ctx.owner.id,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
      });
      await openCashSession(
        store,
        CashScope(
          tenantId: ctx.tenant.id,
          outletId: ctx.outlet.id,
          deviceId: other.id,
        ),
        staffId: ctx.owner.id,
        openingCash: const Money(50000),
      );
      expect(await findOpenCashSession(store, scope()), isNull);
      // Perangkat ini tetap boleh membuka sesinya sendiri.
      await open();
    });
  });

  group('uang masuk/keluar', () {
    test('tercatat dengan outbox dan masuk ke rekap', () async {
      final session = await open();
      now = now.add(const Duration(hours: 1));
      final out = await recordCashMovement(
        store,
        scope(),
        sessionId: session.id,
        staffId: ctx.owner.id,
        direction: CashDirection.outflow,
        amount: const Money(15000),
        note: ' Beli es batu ',
      );
      expect(out.note, 'Beli es batu');
      expect(out.source, 'manual');
      expect(out.outletId, ctx.outlet.id);
      await recordCashMovement(
        store,
        scope(),
        sessionId: session.id,
        staffId: ctx.owner.id,
        direction: CashDirection.inflow,
        amount: const Money(50000),
        note: 'Tambah modal kembalian',
      );
      expect(await outboxCount('cash_movements'), 2);

      final movements = await listCashMovements(store, scope(), session.id);
      expect(movements.map((m) => m.amount), [15000, 50000]);

      final drawer = await cashDrawerFor(store, scope(), session);
      expect(drawer.inflow, const Money(50000));
      expect(drawer.outflow, const Money(15000));
      expect(drawer.expectedCash, const Money(235000));
    });

    test('jumlah nol atau keterangan kosong ditolak', () async {
      final session = await open();
      await expectLater(
        recordCashMovement(
          store,
          scope(),
          sessionId: session.id,
          staffId: ctx.owner.id,
          direction: CashDirection.inflow,
          amount: Money.zero,
          note: 'x',
        ),
        throwsA(
          isA<CashInputInvalid>()
              .having((e) => e.field, 'field', CashField.amount)
              .having((e) => e.error, 'error', CashError.notPositive),
        ),
      );
      await expectLater(
        recordCashMovement(
          store,
          scope(),
          sessionId: session.id,
          staffId: ctx.owner.id,
          direction: CashDirection.inflow,
          amount: const Money(1000),
          note: ' ',
        ),
        throwsA(
          isA<CashInputInvalid>().having(
            (e) => e.field,
            'field',
            CashField.note,
          ),
        ),
      );
      expect(await CashMovement.db.count(store.session), 0);
    });

    test('sesi yang sudah ditutup ditolak', () async {
      final session = await open();
      await closeCashSession(
        store,
        scope(),
        sessionId: session.id,
        staffId: ctx.owner.id,
        count: const CashCount(sheets: {100000: 2}),
      );
      await expectLater(
        recordCashMovement(
          store,
          scope(),
          sessionId: session.id,
          staffId: ctx.owner.id,
          direction: CashDirection.inflow,
          amount: const Money(1000),
          note: 'Telat',
        ),
        throwsA(isA<CashSessionNotOpen>()),
      );
    });
  });

  group('tutup sesi', () {
    test(
      'menyimpan seharusnya, dihitung, selisih, rincian, dan catatan',
      () async {
        final session = await open();
        await recordCashMovement(
          store,
          scope(),
          sessionId: session.id,
          staffId: ctx.owner.id,
          direction: CashDirection.outflow,
          amount: const Money(15000),
          note: 'Beli es batu',
        );
        now = now.add(const Duration(hours: 8));
        final closed = await closeCashSession(
          store,
          scope(),
          sessionId: session.id,
          staffId: ctx.owner.id,
          count: const CashCount(
            sheets: {100000: 1, 50000: 1, 20000: 1, 10000: 1},
            coins: Money(3000),
          ),
          note: ' Kembalian kurang ',
        );
        expect(closed.status, CashSessionStatus.closed);
        expect(closed.closedBy, ctx.owner.id);
        expect(closed.closedAt, now);
        expect(closed.expectedCash, 185000);
        expect(closed.countedCash, 183000);
        expect(closed.difference, -2000);
        expect(closed.closingNote, 'Kembalian kurang');
        expect(closed.version, 2);
        expect(
          CashCount.fromJson(
            jsonDecode(closed.countedBreakdown!) as Map<String, Object?>,
          ).total,
          const Money(183000),
        );
        expect(await outboxCount('cash_sessions'), 2);
        expect(await findOpenCashSession(store, scope()), isNull);
      },
    );

    test('selisih tanpa catatan ditolak tanpa menulis', () async {
      final session = await open();
      await expectLater(
        closeCashSession(
          store,
          scope(),
          sessionId: session.id,
          staffId: ctx.owner.id,
          count: const CashCount(sheets: {100000: 1}),
        ),
        throwsA(
          isA<CashInputInvalid>()
              .having((e) => e.field, 'field', CashField.note)
              .having((e) => e.error, 'error', CashError.required),
        ),
      );
      expect(await findOpenCashSession(store, scope()), isNotNull);
      expect(await outboxCount('cash_sessions'), 1);
    });

    test('hitungan tidak sah ditolak', () async {
      final session = await open();
      await expectLater(
        closeCashSession(
          store,
          scope(),
          sessionId: session.id,
          staffId: ctx.owner.id,
          count: const CashCount(sheets: {100000: -1}),
          note: 'x',
        ),
        throwsA(
          isA<CashInputInvalid>().having(
            (e) => e.field,
            'field',
            CashField.count,
          ),
        ),
      );
    });

    test('selisih pas tidak butuh catatan; tutup dua kali ditolak', () async {
      final session = await open();
      final closed = await closeCashSession(
        store,
        scope(),
        sessionId: session.id,
        staffId: ctx.owner.id,
        count: const CashCount(sheets: {100000: 2}),
      );
      expect(closed.difference, 0);
      expect(closed.closingNote, isNull);
      await expectLater(
        closeCashSession(
          store,
          scope(),
          sessionId: session.id,
          staffId: ctx.owner.id,
          count: const CashCount(sheets: {100000: 5}),
          note: 'Timpa',
        ),
        throwsA(isA<CashSessionNotOpen>()),
      );
      final stored = await CashSession.db.findById(store.session, session.id);
      expect(stored!.countedCash, 200000);
      // Setelah ditutup, sesi baru boleh dibuka.
      await open(cash: 100000);
    });

    test('sesi cabang lain tidak bisa ditutup', () async {
      final session = await open();
      final otherScope = CashScope(
        tenantId: ctx.tenant.id,
        outletId: UuidValue.fromString(newId()),
        deviceId: store.deviceId,
      );
      await expectLater(
        closeCashSession(
          store,
          otherScope,
          sessionId: session.id,
          staffId: ctx.owner.id,
          count: const CashCount(sheets: {100000: 2}),
        ),
        throwsA(isA<CashSessionNotOpen>()),
      );
    });
  });
}
