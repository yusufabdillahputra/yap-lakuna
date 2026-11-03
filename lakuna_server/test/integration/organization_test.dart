import 'package:lakuna_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Tabel fondasi di Postgres', (sessionBuilder, endpoints) {
    test(
      'tenant, outlet, perangkat, dan staf tersimpan dengan relasinya',
      () async {
        final session = sessionBuilder.build();
        final tenant = await Tenant.db.insertRow(
          session,
          Tenant(name: 'Toko Maju', businessType: BusinessType.fnb, hlc: 'h1'),
        );
        final outlet = await Outlet.db.insertRow(
          session,
          Outlet(tenantId: tenant.id, code: 'PST', name: 'Pusat', hlc: 'h2'),
        );
        await Device.db.insertRow(
          session,
          Device(
            tenantId: tenant.id,
            outletId: outlet.id,
            code: 'K01',
            name: 'Kasir 1',
            platform: DevicePlatform.android,
            hlc: 'h3',
          ),
        );
        final staff = await StaffMember.db.insertRow(
          session,
          StaffMember(
            tenantId: tenant.id,
            name: 'Yusuf',
            isOwner: true,
            hlc: 'h4',
          ),
        );
        await OutletMember.db.insertRow(
          session,
          OutletMember(
            tenantId: tenant.id,
            outletId: outlet.id,
            staffMemberId: staff.id,
            roleName: 'owner',
            hlc: 'h5',
          ),
        );

        final stored = await Tenant.db.findById(session, tenant.id);
        expect(stored!.businessType, BusinessType.fnb);
        expect(stored.plan, TenantPlan.free);
        expect(stored.version, 1);
        expect(await Device.db.count(session), 1);
        expect(await OutletMember.db.count(session), 1);
      },
    );

    test('kode outlet unik per tenant', () async {
      final session = sessionBuilder.build();
      final tenant = await Tenant.db.insertRow(
        session,
        Tenant(name: 'A', hlc: 'h'),
      );
      await Outlet.db.insertRow(
        session,
        Outlet(tenantId: tenant.id, code: 'PST', name: 'Pusat', hlc: 'h'),
      );
      await expectLater(
        Outlet.db.insertRow(
          session,
          Outlet(tenantId: tenant.id, code: 'PST', name: 'Lain', hlc: 'h'),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('pengaturan tingkat tenant unik walau outlet_id kosong', () async {
      final session = sessionBuilder.build();
      final tenant = await Tenant.db.insertRow(
        session,
        Tenant(name: 'A', hlc: 'h'),
      );
      Setting setting() => Setting(
        tenantId: tenant.id,
        scopeKey: 'tenant',
        key: 'tax',
        hlc: 'h',
      );
      await Setting.db.insertRow(session, setting());
      await expectLater(
        Setting.db.insertRow(session, setting()),
        throwsA(isA<Exception>()),
      );
    });
  });
}
