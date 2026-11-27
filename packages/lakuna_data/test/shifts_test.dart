import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;
  late CashScope cashScope;
  late DateTime now;

  UuidValue owner() => ctx.owner.id;

  Future<StaffMember> addStaff(String name, String role) {
    final actor = owner();
    return store.write(actor: actor, (w) async {
      final s = await w.stamp();
      final staff = await w.insert(
        StaffMember(
          tenantId: ctx.tenant.id,
          name: name,
          pinHash: r'$argon2id$x',
          isActive: true,
          createdBy: actor,
          updatedBy: actor,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
      await w.insert(
        OutletMember(
          tenantId: ctx.tenant.id,
          outletId: ctx.outlet.id,
          staffMemberId: staff.id,
          roleName: role,
          createdBy: actor,
          updatedBy: actor,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
      return staff;
    });
  }

  Future<Shift> save(
    String name,
    int start,
    int end, {
    UuidValue? id,
    UuidValue? staffId,
  }) => saveShift(
    store,
    scope,
    staffId: staffId ?? owner(),
    id: id,
    name: name,
    startMinute: start,
    endMinute: end,
  );

  setUp(() async {
    // 2026-11-04 03.00 UTC = 10.00 WIB.
    now = DateTime.utc(2026, 11, 4, 3);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    cashScope = CashScope.of(ctx);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  group('master shift', () {
    test('simpan, urut jam mulai, ubah, dan tercatat di outbox', () async {
      final malam = await save(' Malam ', 22 * 60, 6 * 60);
      final pagi = await save('Pagi', 7 * 60, 15 * 60);
      expect(malam.name, 'Malam');
      expect(malam.outletId, ctx.outlet.id);
      expect(malam.startMinute, 1320);
      expect(malam.endMinute, 360);
      var rows = await listShifts(store, scope);
      expect([for (final r in rows) r.shift.name], ['Pagi', 'Malam']);
      expect(rows.first.usage, 0);

      final ubah = await save('Pagi awal', 6 * 60, 14 * 60, id: pagi.id);
      expect(ubah.id, pagi.id);
      expect(ubah.version, 2);
      rows = await listShifts(store, scope);
      expect(rows.first.shift.name, 'Pagi awal');
      expect(rows.first.shift.startMinute, 360);

      final outbox = await SyncOutboxEntry.db.find(store.session);
      expect(outbox.where((e) => e.entity == 'shifts'), hasLength(3));
    });

    test('nama unik per cabang tanpa membedakan huruf', () async {
      final pagi = await save('Pagi', 420, 900);
      await expectLater(
        save('pagi ', 900, 1320),
        throwsA(isA<ShiftNameTaken>()),
      );
      // Mengubah shift sendiri dengan nama sama boleh.
      await save('PAGI', 420, 960, id: pagi.id);
    });

    test('isian tidak sah ditolak tanpa menulis apa pun', () async {
      await expectLater(
        save('', 420, 900),
        throwsA(
          isA<ShiftInvalid>().having((e) => e.issues, 'issues', {
            ShiftIssue.name,
          }),
        ),
      );
      await expectLater(
        save('Pagi', 420, 420),
        throwsA(
          isA<ShiftInvalid>().having((e) => e.issues, 'issues', {
            ShiftIssue.sameTime,
          }),
        ),
      );
      await expectLater(save('Pagi', 420, 1440), throwsA(isA<ShiftInvalid>()));
      expect(await listShifts(store, scope), isEmpty);
    });

    test('butuh settings:manage', () async {
      final kasir = await addStaff('Sari', 'cashier');
      await expectLater(
        save('Pagi', 420, 900, staffId: kasir.id),
        throwsA(
          isA<ShiftActorNotPermitted>().having(
            (e) => e.permission,
            'permission',
            Permission.settingsManage,
          ),
        ),
      );
      final pagi = await save('Pagi', 420, 900);
      await expectLater(
        deleteShift(store, scope, staffId: kasir.id, shiftId: pagi.id),
        throwsA(isA<ShiftActorNotPermitted>()),
      );
      // Daftar boleh dibaca kasir (pilihan buka sesi).
      expect(await listShifts(store, scope), hasLength(1));
    });

    test('ubah atau hapus shift yang tidak ada ditolak', () async {
      final ghost = UuidValue.fromString(newId());
      await expectLater(
        save('Pagi', 420, 900, id: ghost),
        throwsA(isA<ShiftNotFound>()),
      );
      await expectLater(
        deleteShift(store, scope, staffId: owner(), shiftId: ghost),
        throwsA(isA<ShiftNotFound>()),
      );
    });

    test('hapus lunak, ditolak bila dipakai sesi kasir', () async {
      final pagi = await save('Pagi', 420, 900);
      final siang = await save('Siang', 900, 1320);
      final session = await openCashSession(
        store,
        cashScope,
        staffId: owner(),
        openingCash: Money(100000),
        shiftId: pagi.id,
      );
      expect(session.shiftId, pagi.id);
      final rows = await listShifts(store, scope);
      expect(rows.first.usage, 1);
      await expectLater(
        deleteShift(store, scope, staffId: owner(), shiftId: pagi.id),
        throwsA(isA<ShiftInUse>().having((e) => e.sessions, 'sessions', 1)),
      );
      await deleteShift(store, scope, staffId: owner(), shiftId: siang.id);
      expect(
        [for (final r in await listShifts(store, scope)) r.shift.name],
        ['Pagi'],
      );
      final gone = await Shift.db.findById(store.session, siang.id);
      expect(gone!.deletedAt, now);
      // Nama shift yang dihapus boleh dipakai lagi.
      await save('siang', 900, 1320);
    });
  });

  group('buka sesi dengan shift', () {
    test('tanpa shift tetap bisa', () async {
      final session = await openCashSession(
        store,
        cashScope,
        staffId: owner(),
        openingCash: Money(0),
      );
      expect(session.shiftId, isNull);
    });

    test('shift terhapus atau cabang lain ditolak', () async {
      final pagi = await save('Pagi', 420, 900);
      await deleteShift(store, scope, staffId: owner(), shiftId: pagi.id);
      await expectLater(
        openCashSession(
          store,
          cashScope,
          staffId: owner(),
          openingCash: Money(0),
          shiftId: pagi.id,
        ),
        throwsA(isA<ShiftNotFound>()),
      );
      final actor = owner();
      final other = await store.write(actor: actor, (w) async {
        final s = await w.stamp();
        final outlet = await w.insert(
          Outlet(
            tenantId: ctx.tenant.id,
            code: 'CB2',
            name: 'Cabang Dua',
            timezone: 'Asia/Jakarta',
            createdBy: actor,
            updatedBy: actor,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
        return w.insert(
          Shift(
            tenantId: ctx.tenant.id,
            outletId: outlet.id,
            name: 'Pagi',
            startMinute: 420,
            endMinute: 900,
            createdBy: actor,
            updatedBy: actor,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
      });
      expect(await listShifts(store, scope), isEmpty);
      await expectLater(
        openCashSession(
          store,
          cashScope,
          staffId: owner(),
          openingCash: Money(0),
          shiftId: other.id,
        ),
        throwsA(isA<ShiftNotFound>()),
      );
      expect(await findOpenCashSession(store, cashScope), isNull);
    });
  });
}
