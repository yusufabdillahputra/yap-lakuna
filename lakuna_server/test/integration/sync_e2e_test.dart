/// End-to-end F2-01: dua perangkat (SQLite) + server (Postgres) lewat
/// endpoint sungguhan.
library;

import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart' as c;
import 'package:lakuna_data/lakuna_data.dart' as d;
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_server/src/generated/protocol.dart' as s;
import 'package:lakuna_server/src/sync/activation.dart';
import 'package:serverpod/serverpod.dart' show UuidValue, ValueEncoder;
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

const ownerId = '01900000-0000-7000-8000-00000000ff01';

/// Encoder nilai query Serverpod adalah satu objek global per isolate, dan
/// setiap sesi server memasang encoder Postgres. Perangkat (SQLite) dan
/// server di tes ini berbagi isolate, jadi encoder SQLite dipasang lagi
/// setelah setiap panggilan server. Hanya untuk tes; server sungguhan tidak
/// pernah membuka SQLite.
late ValueEncoder sqliteEncoder;
late ValueEncoder postgresEncoder;

/// Menjalankan [call] ke server lalu memasang lagi encoder SQLite.
Future<T> onServer<T>(Future<T> Function() call) async {
  ValueEncoder.set(postgresEncoder);
  try {
    return await call();
  } finally {
    ValueEncoder.set(sqliteEncoder);
  }
}

/// Transport yang memanggil endpoint `sync` langsung.
class EndpointTransport implements d.SyncTransport {
  EndpointTransport(this.endpoints, this.session, this.token);

  final TestEndpoints endpoints;
  final TestSessionBuilder session;
  final String token;

  @override
  Future<c.SyncPushReply> push(List<c.SyncPushEntry> entries) async {
    final r = await onServer(
      () => endpoints.sync.push(session, token, [
        for (final e in entries) s.SyncPushEntry.fromJson(e.toJson()),
      ]),
    );
    return c.SyncPushReply.fromJson(r.toJson());
  }

  @override
  Future<c.SyncPullPage> pull(int afterSeq) async => c.SyncPullPage.fromJson(
    (await onServer(
      () => endpoints.sync.pull(session, token, afterSeq),
    )).toJson(),
  );

  @override
  Future<c.SyncServerStatus> status() async => c.SyncServerStatus.fromJson(
    (await onServer(() => endpoints.sync.status(session, token))).toJson(),
  );

  @override
  Future<c.TenantStatus> tenantStatus() async => c.TenantStatus.fromJson(
    (await onServer(
      () => endpoints.sync.tenantStatus(session, token),
    )).toJson(),
  );
}

void main() {
  withServerpod('Sync dua perangkat (F2-01)', (sessionBuilder, endpoints) {
    final owner = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(ownerId, {}),
    );
    late Directory dir;
    late d.LakunaStore a;
    late d.LakunaStore b;
    late d.StoreContext ctxA;
    late d.StoreContext ctxB;
    late d.SyncEngine engineA;
    late d.SyncEngine engineB;
    late UuidValue variantId;

    Future<void> converge() async {
      for (var i = 0; i < 4; i++) {
        await engineA.runCycle();
        await engineB.runCycle();
      }
    }

    Future<Map<String, Map<String, Object?>>> snapshot(d.LakunaStore store) =>
        store.session.db.transaction((tx) async {
          final out = <String, Map<String, Object?>>{};
          for (final t in syncTables) {
            final type = d.syncRowType(t.name)!;
            for (final row in await type.after(store.session, tx)) {
              out['${t.name}/${row.id}'] = row.toJson() as Map<String, Object?>;
            }
          }
          for (final l in await c.StockLevel.db.find(
            store.session,
            transaction: tx,
          )) {
            out['stock_levels/${l.variantId}/${l.stockLocationId}'] = {
              'q': l.quantityMilli,
              'avg': l.avgCost,
            };
          }
          return out;
        });

    Future<d.CheckoutResult> sell(d.LakunaStore store, d.StoreContext ctx) =>
        d.checkoutSale(
          store,
          d.CatalogScope.of(ctx),
          staffId: ctx.owner.id,
          lines: [
            d.SaleLineRequest(variantId: variantId, quantity: Qty.units(2)),
          ],
          payments: const [d.SalePaymentRequest.cash(Money(100000))],
        );

    setUp(() async {
      sessionBuilder.build();
      postgresEncoder = ValueEncoder.instance;
      dir = await Directory.systemTemp.createTemp('lakuna_e2e_');
      await Directory('${dir.path}/a').create();
      a = await d.LakunaStore.open('${dir.path}/a/lakuna.sqlite');
      sqliteEncoder = ValueEncoder.instance;
      ctxA = await d.setupStore(
        a,
        SetupInput(
          businessType: BusinessKind.retail,
          businessName: 'Warung Contoh',
          outletName: 'Cabang Pusat',
          outletCode: 'PST',
          deviceCode: 'K01',
          timezone: 'Asia/Jakarta',
          ownerName: 'Yusuf',
          email: 'pemilik@contoh.id',
          password: 'rahasia123',
          passwordConfirm: 'rahasia123',
          pin: '123456',
          pinConfirm: '123456',
        ),
        platform: c.DevicePlatform.linux,
        credentials: const d.SetupCredentials(
          pinHash: r'$argon2id$pin',
          passwordHash: r'$argon2id$password',
        ),
      );
      final productId = await d.saveProduct(
        a,
        d.CatalogScope.of(ctxA),
        staffId: ctxA.owner.id,
        draft: const ProductDraft(
          name: 'Teh',
          baseUnit: 'pcs',
          variants: [
            VariantDraft(
              costPrice: Money(1000),
              sellPrice: Money(5000),
              openingStock: Qty(50000),
            ),
          ],
        ),
      );
      variantId = (await d.loadProduct(
        a,
        d.CatalogScope.of(ctxA),
        productId,
      ))!.variants.single.id;
      await d.openCashSession(
        a,
        d.CashScope.of(ctxA),
        staffId: ctxA.owner.id,
        openingCash: const Money(100000),
      );

      // Aktivasi perangkat A lalu unggah data awal.
      final act = await onServer(() async {
        final code = await createActivationCode(
          sessionBuilder.build(),
          note: 'Warung Contoh',
        );
        return endpoints.activation.activateFirstDevice(
          owner,
          code,
          ctxA.tenant.id,
          a.deviceId,
          'Warung Contoh',
          'K01',
        );
      });
      await d.markTenantHosted(a, staffId: ctxA.owner.id);
      engineA = d.SyncEngine(
        a,
        EndpointTransport(endpoints, sessionBuilder, act.deviceToken),
      );
      await engineA.runCycle();

      // Perangkat B bergabung dengan kode pasang dan mulai dari data server.
      final join = await onServer(() async {
        final pairing = await endpoints.activation.createPairingCode(
          sessionBuilder,
          act.deviceToken,
        );
        return endpoints.activation.joinWithPairingCode(
          sessionBuilder,
          pairing,
          ctxA.outlet.id,
          'K02',
          'Kasir 2',
          s.DevicePlatform.android,
        );
      });
      b = await d.openJoinedStore(
        '${dir.path}/b/lakuna.sqlite',
        deviceId: join.deviceId,
      );
      engineB = d.SyncEngine(
        b,
        EndpointTransport(endpoints, sessionBuilder, join.deviceToken),
      );
      await engineB.runCycle();
      ctxB = (await d.loadStoreContext(b))!;
      await d.openCashSession(
        b,
        d.CashScope.of(ctxB),
        staffId: ctxB.owner.id,
        openingCash: const Money(50000),
      );
    });

    tearDown(() async {
      await a.close();
      await b.close();
      await dir.delete(recursive: true);
    });

    test(
      'perangkat B mendapat ID dan kode dari server, tenant hosted',
      () async {
        expect(ctxB.device.code, 'K02');
        expect(ctxB.device.id, b.deviceId);
        expect(b.deviceId, isNot(a.deviceId));
        expect(ctxB.tenant.plan, c.TenantPlan.hosted);
      },
    );

    test('jual offline di kedua perangkat → isi tabel sama', () async {
      await sell(a, ctxA);
      final saleB = await sell(b, ctxB);
      await sell(a, ctxA);
      await d.returnSale(
        b,
        d.CatalogScope.of(ctxB),
        staffId: ctxB.owner.id,
        saleId: saleB.sale.id,
        lines: [
          d.ReturnLine(saleItemId: saleB.items.single.id, quantity: Qty.one),
        ],
        reason: c.SaleReturnReason.damaged,
        refundMethod: c.RefundMethod.cash,
        restock: true,
      );
      await converge();
      final snapA = await snapshot(a);
      final snapB = await snapshot(b);
      expect(snapB.keys.toSet(), snapA.keys.toSet());
      for (final key in snapA.keys) {
        expect(snapB[key], snapA[key], reason: key);
      }
      final sales = await c.Sale.db.find(b.session);
      expect(sales.map((x) => x.number).toSet(), hasLength(3));
      final level = await c.StockLevel.db.findFirstRow(
        a.session,
        where: (l) => l.variantId.equals(variantId),
      );
      expect(level!.quantityMilli, 50000 - 6000 + 1000);
    });

    for (final bFirst in [true, false]) {
      test('void di B vs retur sebagian di A (${bFirst ? 'B' : 'A'} dulu) '
          '→ voided di kedua perangkat', () async {
        final sale = await sell(b, ctxB);
        await converge();
        await d.returnSale(
          a,
          d.CatalogScope.of(ctxA),
          staffId: ctxA.owner.id,
          saleId: sale.sale.id,
          lines: [
            d.ReturnLine(saleItemId: sale.items.single.id, quantity: Qty.one),
          ],
          reason: c.SaleReturnReason.damaged,
          refundMethod: c.RefundMethod.cash,
          restock: true,
        );
        await d.voidSale(
          b,
          d.CatalogScope.of(ctxB),
          staffId: ctxB.owner.id,
          approverId: ctxB.owner.id,
          saleId: sale.sale.id,
          reason: 'Salah input',
        );
        if (bFirst) {
          await engineB.runCycle();
          await engineA.runCycle();
        } else {
          await engineA.runCycle();
          await engineB.runCycle();
        }
        await converge();
        for (final store in [a, b]) {
          final row = await c.Sale.db.findById(store.session, sale.sale.id);
          expect(row!.status, c.SaleStatus.voided);
          expect(row.voidReason, 'Salah input');
        }
        final server = await onServer(
          () => s.Sale.db.findById(sessionBuilder.build(), sale.sale.id),
        );
        expect(server!.status, s.SaleStatus.voided);
        expect(await snapshot(b), await snapshot(a));
      });
    }
  });
}
