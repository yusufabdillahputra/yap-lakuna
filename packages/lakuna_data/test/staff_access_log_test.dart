import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;
  late DateTime now;

  Future<StaffMember> addStaff(String name) {
    final actor = ctx.owner.id;
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
          roleName: 'cashier',
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

  Future<StaffAccessLog> record(UuidValue staffId, StaffAccessKind kind) =>
      recordStaffAccess(store, scope, staffId: staffId, kind: kind);

  setUp(() async {
    now = DateTime.utc(2026, 11, 27, 1);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test('catat lalu baca: terbaru dulu, nama staf dan kode perangkat, '
      'tercatat di outbox', () async {
    final budi = await addStaff('Budi');
    final log = await record(ctx.owner.id, StaffAccessKind.signInSetup);
    expect(log.occurredAt, now);
    expect(log.outletId, ctx.outlet.id);
    expect(log.deviceId, ctx.device.id);
    expect(log.createdBy, ctx.owner.id);
    now = now.add(const Duration(minutes: 5));
    await record(ctx.owner.id, StaffAccessKind.signOut);
    now = now.add(const Duration(minutes: 1));
    await record(budi.id, StaffAccessKind.signInPin);

    final page = await listStaffAccess(store, scope);
    expect(
      [for (final r in page.rows) r.staffName],
      ['Budi', 'Yusuf', 'Yusuf'],
    );
    expect(
      [for (final r in page.rows) r.log.kind],
      [
        StaffAccessKind.signInPin,
        StaffAccessKind.signOut,
        StaffAccessKind.signInSetup,
      ],
    );
    expect(page.rows.first.deviceCode, 'K01');
    expect(page.hasMore, isFalse);

    final outbox = await SyncOutboxEntry.db.find(store.session);
    expect(outbox.where((e) => e.entity == 'staff_access_logs'), hasLength(3));
  });

  test('filter staf', () async {
    final budi = await addStaff('Budi');
    await record(ctx.owner.id, StaffAccessKind.signInPassword);
    await record(budi.id, StaffAccessKind.signInPin);
    await record(budi.id, StaffAccessKind.signOutRemoved);
    final page = await listStaffAccess(store, scope, staffId: budi.id);
    expect(page.rows, hasLength(2));
    expect(page.rows.every((r) => r.log.staffId == budi.id), isTrue);
  });

  test(
    'halaman dengan kursor: tanpa baris ganda walau waktunya sama',
    () async {
      // Lima kejadian di milidetik yang sama, tiga lagi sesudahnya.
      final written = <UuidValue>[];
      for (var i = 0; i < 5; i++) {
        written.add((await record(ctx.owner.id, StaffAccessKind.signInPin)).id);
      }
      for (var i = 0; i < 3; i++) {
        now = now.add(const Duration(seconds: 1));
        written.add((await record(ctx.owner.id, StaffAccessKind.signOut)).id);
      }
      final seen = <UuidValue>{};
      StaffAccessCursor? before;
      var pages = 0;
      do {
        final page = await listStaffAccess(
          store,
          scope,
          before: before,
          limit: 3,
        );
        pages++;
        for (final r in page.rows) {
          expect(seen.add(r.log.id), isTrue, reason: 'baris ganda');
        }
        before = page.hasMore ? page.next : null;
      } while (before != null);
      expect(seen, hasLength(8));
      // Urutan tulis terjaga walau waktunya sama (HLC, bukan UUID acak).
      expect(seen.toList(), written.reversed.toList());
      expect(pages, 3);
    },
  );

  test('staf yang sudah dihapus tetap bernama', () async {
    final budi = await addStaff('Budi');
    await record(budi.id, StaffAccessKind.signInPin);
    await store.write(actor: ctx.owner.id, (w) async {
      final s = await w.stamp();
      final row = (await StaffMember.db.findById(w.session, budi.id))!;
      await w.update(
        row.copyWith(
          deletedAt: s.now,
          isActive: false,
          version: row.version + 1,
          hlc: s.hlc.toString(),
        ),
        s,
      );
    });
    final page = await listStaffAccess(store, scope);
    expect(page.rows.single.staffName, 'Budi');
  });

  test('dibatasi tenant dan cabang', () async {
    await record(ctx.owner.id, StaffAccessKind.signInPin);
    final actor = ctx.owner.id;
    final other = await store.write(actor: actor, (w) async {
      final s = await w.stamp();
      return w.insert(
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
    });
    final otherScope = CatalogScope(
      tenantId: ctx.tenant.id,
      outletId: other.id,
      deviceId: ctx.device.id,
    );
    await recordStaffAccess(
      store,
      otherScope,
      staffId: actor,
      kind: StaffAccessKind.signOut,
    );
    expect(
      (await listStaffAccess(store, scope)).rows.single.log.kind,
      StaffAccessKind.signInPin,
    );
    expect(
      (await listStaffAccess(store, otherScope)).rows.single.log.kind,
      StaffAccessKind.signOut,
    );
    final otherTenant = CatalogScope(
      tenantId: UuidValue.fromString('00000000-0000-7000-8000-000000000001'),
      outletId: ctx.outlet.id,
      deviceId: ctx.device.id,
    );
    expect((await listStaffAccess(store, otherTenant)).rows, isEmpty);
  });
}
