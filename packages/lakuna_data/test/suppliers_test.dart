import 'dart:io';
import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// PNG 1×1 terkecil yang sah.
final _png = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;
  late CashScope cashScope;
  late DateTime now;
  late CatalogProduct gula;
  late StockLocation gudang;

  UuidValue owner() => ctx.owner.id;

  Future<StaffMember> addStaff(String name, String role) {
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

  setUp(() async {
    // 2026-11-04 03.00 UTC = 10.00 WIB.
    now = DateTime.utc(2026, 11, 4, 3);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    cashScope = CashScope.of(ctx);
    final id = await saveProduct(
      store,
      scope,
      staffId: owner(),
      draft: const ProductDraft(
        name: 'Gula Pasir 1 kg',
        baseUnit: 'kg',
        variants: [
          VariantDraft(costPrice: Money(14000), sellPrice: Money(17500)),
        ],
      ),
    );
    gula = (await loadProduct(store, scope, id))!;
    gudang = await defaultStockLocation(store, scope);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<Supplier> supplier(
    String name, {
    int termDays = 14,
    String? phone,
    UuidValue? staffId,
  }) => saveSupplier(
    store,
    scope,
    staffId: staffId ?? owner(),
    input: SupplierInput(
      name: name,
      phone: phone,
      contactName: 'Pak Hendra',
      category: 'Sembako',
      termDays: termDays,
    ),
  );

  /// Pembelian diterima: [kg] kg gula × 15.000, bayar [paid] di muka.
  Future<Purchase> buy(
    Supplier s, {
    required int kg,
    int paid = 0,
    DateTime? purchasedOn,
    DateTime? dueOn,
  }) => receivePurchase(
    store,
    scope,
    staffId: owner(),
    request: PurchaseRequest(
      supplierId: s.id,
      purchasedOn: purchasedOn ?? DateTime(2026, 11, 4),
      locationId: gudang.id,
      lines: [
        PurchaseLineRequest(
          variantId: gula.variants.single.id,
          quantity: Qty.units(kg),
          unitPrice: const Money(15000),
        ),
      ],
      paid: Money(paid),
      funding: paid > 0 ? FundingSource.storeCash : null,
      dueOn: dueOn,
    ),
  );

  Future<DebtPayment> pay(
    Supplier s,
    int amount, {
    FundingSource funding = FundingSource.bank,
    DateTime? paidOn,
    Map<UuidValue, Money>? allocations,
    String? reference,
    SupplierPaymentProof? proof,
    UuidValue? staffId,
  }) => paySupplierDebt(
    store,
    scope,
    staffId: staffId ?? owner(),
    request: SupplierPaymentRequest(
      supplierId: s.id,
      amount: Money(amount),
      funding: funding,
      paidOn: paidOn ?? DateTime.utc(2026, 11, 4),
      allocations: allocations,
      reference: reference,
      proof: proof,
    ),
  );

  group('master supplier', () {
    test('simpan, normalisasi, nama unik, ubah', () async {
      final s = await supplier('CV Sumber Pangan', phone: '+62 21-555-0101');
      expect(s.phone, '0215550101');
      expect(s.termDays, 14);
      expect(s.contactName, 'Pak Hendra');
      expect(s.category, 'Sembako');

      await expectLater(
        () => supplier('cv sumber pangan'),
        throwsA(isA<SupplierNameTaken>()),
      );
      await expectLater(
        () => supplier('', termDays: 400),
        throwsA(
          isA<SupplierInvalid>().having((e) => e.issues, 'issues', {
            SupplierIssue.name,
            SupplierIssue.termDays,
          }),
        ),
      );

      final edited = await saveSupplier(
        store,
        scope,
        staffId: owner(),
        input: SupplierInput(
          id: s.id,
          name: 'CV Sumber Pangan Jaya',
          termDays: 30,
          address: 'Jl. Raya 1',
        ),
      );
      expect(edited.id, s.id);
      expect(edited.termDays, 30);
      expect(edited.address, 'Jl. Raya 1');
      expect(edited.contactName, isNull);

      // Ganti nama ke nama supplier lain (beda huruf besar) ditolak.
      final other = await supplier('UD Makmur');
      await expectLater(
        saveSupplier(
          store,
          scope,
          staffId: owner(),
          input: SupplierInput(
            id: other.id,
            name: 'cv sumber pangan JAYA',
            termDays: 14,
          ),
        ),
        throwsA(isA<SupplierNameTaken>()),
      );
    });

    test('hapus ditolak selama masih berhutang', () async {
      final s = await supplier('UD Makmur');
      final p = await buy(s, kg: 10, dueOn: DateTime(2026, 11, 18));
      await expectLater(
        () => deleteSupplier(store, scope, staffId: owner(), supplierId: s.id),
        throwsA(isA<SupplierHasDebt>()),
      );
      await pay(s, p.total);
      await deleteSupplier(store, scope, staffId: owner(), supplierId: s.id);
      final overview = await loadSuppliersOverview(store, scope, now: now);
      expect(overview.rows, isEmpty);
      // Pembelian lama tetap menampilkan nama supplier.
      expect((await listPurchases(store, scope)).single.supplierName, s.name);
    });
  });

  group('hutang', () {
    test('ringkasan: total, jatuh tempo terdekat, terlambat', () async {
      final a = await supplier('CV Sumber Pangan');
      final b = await supplier('PT Segar Jaya');
      await supplier('UD Makmur');
      await buy(
        a,
        kg: 220,
        paid: 2000000,
        purchasedOn: DateTime(2026, 10, 28),
        dueOn: DateTime(2026, 11, 3),
      );
      await buy(a, kg: 50, dueOn: DateTime(2026, 11, 16));
      await buy(b, kg: 32, dueOn: DateTime(2026, 11, 5));
      // Lunas: tidak dihitung.
      await buy(b, kg: 1, paid: 15000);

      final o = await loadSuppliersOverview(store, scope, now: now);
      expect(o.rows.map((r) => r.supplier.name), [
        'CV Sumber Pangan',
        'PT Segar Jaya',
        'UD Makmur',
      ]);
      expect(o.rows[0].debt, const Money(1300000 + 750000));
      expect(o.rows[0].overdueCount, 1);
      expect(o.rows[0].nearestDue, DateTime.utc(2026, 11, 3));
      expect(o.rows[1].debt, const Money(480000));
      expect(o.rows[2].debt, Money.zero);
      expect(o.totalDebt, const Money(2530000));
      expect(o.nearestDue, DateTime.utc(2026, 11, 3));
      expect(o.overdueCount, 1);
      expect(o.creditorCount, 2);
    });

    test('bayar otomatis ke jatuh tempo terdekat dulu', () async {
      final s = await supplier('CV Sumber Pangan');
      final late = await buy(
        s,
        kg: 100,
        purchasedOn: DateTime(2026, 11, 1),
        dueOn: DateTime(2026, 11, 20),
      );
      final soon = await buy(s, kg: 40, dueOn: DateTime(2026, 11, 10));
      // Sisa: soon 600.000, late 1.500.000.
      final p = await pay(s, 1000000, reference: 'TRF-0211-883');
      expect(p.number, 'BH-PST-K01-261104-0001');
      expect(p.party, DebtParty.supplier);
      expect(p.supplierId, s.id);
      expect(p.fundingSource, FundingSource.bank);
      expect(p.reference, 'TRF-0211-883');
      expect(p.balanceAfter, 1100000);
      expect(p.cashSessionId, isNull);

      final allocations = await DebtPaymentAllocation.db.find(
        store.session,
        where: (a) => a.debtPaymentId.equals(p.id),
      );
      final byPurchase = {
        for (final a in allocations) a.purchaseId: (a.amount, a.balanceBefore),
      };
      expect(byPurchase[soon.id], (600000, 600000));
      expect(byPurchase[late.id], (400000, 1500000));
      expect(
        allocations.every((a) => a.documentType == DebtDocumentType.purchase),
        isTrue,
      );

      final detail = await loadSupplierDetail(store, scope, s.id, now: now);
      expect(detail.open.single.purchase.id, late.id);
      expect(detail.open.single.outstanding, const Money(1100000));
      expect(detail.payments.single.id, p.id);

      // Daftar dan rincian pembelian ikut berkurang.
      final rows = {
        for (final r in await listPurchases(store, scope)) r.purchase.id: r,
      };
      expect(rows[soon.id]!.debt, Money.zero);
      expect(rows[late.id]!.debt, const Money(1100000));
      final d = await loadPurchaseDetail(store, scope, late.id);
      expect(d.debt, const Money(1100000));
      expect(d.debtPaid, const Money(400000));
      expect(d.debtPayments.single.number, p.number);
      expect(d.debtPayments.single.funding, FundingSource.bank);
    });

    test('alokasi manual dan validasi', () async {
      final s = await supplier('CV Sumber Pangan');
      final a = await buy(s, kg: 10, dueOn: DateTime(2026, 11, 10));
      final b = await buy(s, kg: 20, dueOn: DateTime(2026, 11, 12));
      await expectLater(
        pay(s, 500000),
        throwsA(
          isA<SupplierPaymentInvalid>().having(
            (e) => e.issue,
            'issue',
            DebtPaymentIssue.overOutstanding,
          ),
        ),
      );
      await expectLater(
        pay(s, 100000, allocations: {a.id: const Money(50000)}),
        throwsA(isA<SupplierPaymentInvalid>()),
      );
      await expectLater(
        pay(s, 1000, paidOn: DateTime.utc(2026, 11, 5)),
        throwsA(isA<SupplierPaymentDateInvalid>()),
      );
      // Alokasi ke pembelian supplier lain ditolak.
      final lain = await supplier('UD Makmur');
      final c = await buy(lain, kg: 5, dueOn: DateTime(2026, 11, 10));
      await expectLater(
        pay(s, 10000, allocations: {c.id: const Money(10000)}),
        throwsA(
          isA<SupplierPaymentInvalid>().having(
            (e) => e.issue,
            'issue',
            DebtPaymentIssue.allocationUnknown,
          ),
        ),
      );
      await pay(
        s,
        100000,
        allocations: {a.id: const Money(20000), b.id: const Money(80000)},
      );
      final d = await loadSupplierDetail(store, scope, s.id, now: now);
      final rest = {for (final o in d.open) o.purchase.id: o.outstanding};
      expect(rest[a.id], const Money(130000));
      expect(rest[b.id], const Money(220000));
    });

    test(
      'kas laci: butuh sesi, tanggal hari ini, menulis kas keluar',
      () async {
        final s = await supplier('CV Sumber Pangan');
        await buy(s, kg: 10, dueOn: DateTime(2026, 11, 10));
        await expectLater(
          pay(s, 50000, funding: FundingSource.drawer),
          throwsA(isA<CashSessionNotOpen>()),
        );
        final session = await openCashSession(
          store,
          cashScope,
          staffId: owner(),
          openingCash: const Money(500000),
        );
        await expectLater(
          pay(
            s,
            50000,
            funding: FundingSource.drawer,
            paidOn: DateTime.utc(2026, 11, 3),
          ),
          throwsA(isA<SupplierPaymentDrawerDate>()),
        );
        final p = await pay(s, 50000, funding: FundingSource.drawer);
        expect(p.cashSessionId, session.id);
        final moves = await CashMovement.db.find(
          store.session,
          where: (m) => m.cashSessionId.equals(session.id),
        );
        final out = moves.singleWhere(
          (m) => m.source == supplierPaymentCashSource,
        );
        expect(out.direction, CashDirection.outflow);
        expect(out.amount, 50000);
        expect(out.note, contains(p.number));
      },
    );

    test('foto bukti tersimpan dan bisa dibaca', () async {
      final s = await supplier('CV Sumber Pangan');
      await buy(s, kg: 10, dueOn: DateTime(2026, 11, 10));
      await expectLater(
        pay(
          s,
          1000,
          proof: SupplierPaymentProof(
            bytes: Uint8List.fromList([1, 2, 3]),
            fileName: 'x.png',
          ),
        ),
        throwsA(isA<SupplierPaymentProofInvalid>()),
      );
      final p = await pay(
        s,
        1000,
        proof: SupplierPaymentProof(bytes: _png, fileName: 'bukti.png'),
      );
      expect(p.proofMediaId, isNotNull);
      final media = await MediaFile.db.findById(store.session, p.proofMediaId!);
      expect(media!.kind, MediaKind.paymentProof);
      expect(await loadSupplierPaymentProof(store, scope, p.id), _png);
    });

    test('retur beli setelah bayar memotong sisa hutang saja', () async {
      final s = await supplier('CV Sumber Pangan');
      final p = await buy(s, kg: 10, dueOn: DateTime(2026, 11, 10));
      await pay(s, 100000);
      final item = (await loadPurchaseDetail(store, scope, p.id)).items.single;
      final r = await returnPurchase(
        store,
        scope,
        staffId: owner(),
        purchaseId: p.id,
        lines: [
          PurchaseReturnLine(purchaseItemId: item.id, quantity: Qty.units(5)),
        ],
        refundSource: FundingSource.storeCash,
      );
      expect(r.amount, 75000);
      expect(r.debtReduction, 50000);
      expect(r.refundAmount, 25000);
      final d = await loadSupplierDetail(store, scope, s.id, now: now);
      expect(d.open, isEmpty);
    });

    test('riwayat pembelian supplier', () async {
      final s = await supplier('CV Sumber Pangan');
      final other = await supplier('UD Makmur');
      await buy(s, kg: 1, paid: 15000, purchasedOn: DateTime(2026, 11, 1));
      await buy(s, kg: 2, dueOn: DateTime(2026, 11, 10));
      await buy(other, kg: 3, dueOn: DateTime(2026, 11, 10));
      final rows = await listSupplierPurchases(store, scope, s.id);
      expect(rows.map((r) => r.purchase.total), [30000, 15000]);
      expect(rows.first.debt, const Money(30000));
    });
  });

  group('import', () {
    Future<SupplierImportSummary> run(
      List<List<String>> table, {
      UuidValue? staffId,
    }) => importSuppliers(
      store,
      scope,
      staffId: staffId ?? owner(),
      rows: supplierImportRows(table).rows,
    );

    test('buat baru, perbarui per nama tanpa beda huruf', () async {
      final old = await supplier('CV Sumber Pangan', phone: '0215550101');
      final summary = await run([
        ['Nama', 'Kontak', 'Telepon', 'Tempo', 'Alamat'],
        ['cv sumber pangan', '', '', '30', 'Jl. Pasar 1'],
        ['UD Makmur', 'Bu Rina', '0813-1111-2222', '', ''],
      ]);
      expect(summary.created, 1);
      expect(summary.updated, 1);
      final rows = (await loadSuppliersOverview(store, scope, now: now)).rows;
      expect(rows, hasLength(2));
      final a = rows.firstWhere((r) => r.supplier.id == old.id).supplier;
      // Nama lama tetap (kunci), kolom kosong mempertahankan data lama.
      expect(a.name, 'CV Sumber Pangan');
      expect(a.termDays, 30);
      expect(a.address, 'Jl. Pasar 1');
      expect(a.phone, '0215550101');
      expect(a.contactName, 'Pak Hendra');
      expect(a.category, 'Sembako');
      expect(a.version, old.version + 1);
      final b = rows.firstWhere((r) => r.supplier.name == 'UD Makmur').supplier;
      expect(b.termDays, SupplierLimits.defaultTermDays);
      expect(b.phone, '081311112222');
      expect(b.contactName, 'Bu Rina');
    });

    test('supplier terhapus tidak diperbarui; nama dipakai lagi', () async {
      final old = await supplier('UD Makmur');
      await deleteSupplier(store, scope, staffId: owner(), supplierId: old.id);
      final summary = await run([
        ['Nama'],
        ['UD Makmur'],
      ]);
      expect(summary.created, 1);
      expect(summary.updated, 0);
    });

    test('baris dari luar parser diperiksa ulang', () async {
      await expectLater(
        importSuppliers(
          store,
          scope,
          staffId: owner(),
          rows: const [SupplierImportRow(line: 2, name: 'A', termDays: 400)],
        ),
        throwsA(isA<SupplierInvalid>()),
      );
      await expectLater(
        importSuppliers(
          store,
          scope,
          staffId: owner(),
          rows: const [
            SupplierImportRow(line: 2, name: 'A'),
            SupplierImportRow(line: 3, name: 'B', phone: '12'),
          ],
        ),
        throwsA(isA<SupplierInvalid>()),
      );
      // Satu baris salah membatalkan seluruh import.
      expect(
        (await loadSuppliersOverview(store, scope, now: now)).rows,
        isEmpty,
      );
    });

    test('nama ganda di daftar baris digabung ke satu supplier', () async {
      final summary = await importSuppliers(
        store,
        scope,
        staffId: owner(),
        rows: const [
          SupplierImportRow(line: 2, name: 'Toko D', termDays: 7),
          SupplierImportRow(line: 3, name: ' toko d ', address: 'Jl. 2'),
        ],
      );
      expect(summary.created, 1);
      expect(summary.updated, 1);
      final d = (await loadSuppliersOverview(
        store,
        scope,
        now: now,
      )).rows.single.supplier;
      expect(d.name, 'Toko D');
      expect(d.termDays, 7);
      expect(d.address, 'Jl. 2');
    });

    test('izin dan outbox', () async {
      final kasir = await addStaff('Sari', 'cashier');
      await expectLater(
        run([
          ['Nama'],
          ['CV A'],
        ], staffId: kasir.id),
        throwsA(isA<SupplierActorNotPermitted>()),
      );
      final before = (await SyncOutboxEntry.db.find(store.session))
          .where((r) => r.entity == 'suppliers')
          .length;
      await run([
        ['Nama'],
        ['CV A'],
        ['CV B'],
      ]);
      final after = (await SyncOutboxEntry.db.find(store.session))
          .where((r) => r.entity == 'suppliers')
          .length;
      expect(after, before + 2);
    });
  });

  test('izin: kasir bayar, staf gudang kelola supplier', () async {
    final kasir = await addStaff('Sari', 'cashier');
    final gudangStaff = await addStaff('Andi', 'stock_keeper');
    await expectLater(
      supplier('CV A', staffId: kasir.id),
      throwsA(isA<SupplierActorNotPermitted>()),
    );
    final s = await supplier('CV A', staffId: gudangStaff.id);
    await buy(s, kg: 10, dueOn: DateTime(2026, 11, 10));
    await expectLater(
      pay(s, 1000, staffId: gudangStaff.id),
      throwsA(isA<SupplierActorNotPermitted>()),
    );
    final p = await pay(s, 1000, staffId: kasir.id);
    expect(p.staffId, kasir.id);
  });
}
