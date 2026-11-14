import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/purchases_repository.dart';
import 'package:lakuna_flutter/ui/purchases/purchase_detail_view_model.dart';
import 'package:lakuna_flutter/ui/purchases/purchase_form_view_model.dart';
import 'package:lakuna_flutter/ui/purchases/purchases_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/cashier_seed.dart';
import '../../testing/fake_purchases_repository.dart';

void main() {
  late FakePurchasesRepository repo;
  late PurchaseFormViewModel form;

  setUp(() async {
    repo = FakePurchasesRepository();
    form = PurchaseFormViewModel(repository: repo);
    await form.load.execute();
  });

  group('PurchaseFormViewModel', () {
    test(
      'isi awal: nomor, tanggal hari ini, lokasi bawaan, jatuh tempo +14',
      () {
        expect(form.number, 'PB-PST-D01-261103-0001');
        expect(form.purchasedOn, DateTime(2026, 11, 3));
        expect(form.dueOn, DateTime(2026, 11, 17));
        expect(form.locationName, 'Toko');
        expect(form.funding, FundingKind.storeCash);
        expect(form.lines, isEmpty);
      },
    );

    test('scan barcode satuan konversi memilih satuannya, scan ulang +1', () {
      expect(form.addByCode('8991234500031'), PurchaseScanResult.added);
      final line = form.lines.single;
      expect(line.unit.name, 'Dus');
      expect(line.unit.factor, Qty.units(6));
      // HPP dasar 32.500 × 6.
      expect(line.unitPrice, const Money(195000));
      expect(form.addByCode('8991234500031'), PurchaseScanResult.increased);
      expect(form.lines.single.quantity, Qty.units(2));
      // Barcode varian → satuan dasar, baris terpisah.
      expect(form.addByCode('8991234500024'), PurchaseScanResult.added);
      expect(form.lines.last.unit.isBase, isTrue);
      expect(form.addByCode('tidak-ada'), PurchaseScanResult.notFound);
      // Nama yang cocok dengan dua varian tidak dipilih otomatis.
      expect(form.addByCode('beras'), PurchaseScanResult.notFound);
      expect(form.suggestions('beras'), hasLength(2));
    });

    test('UPC-A 13 digit (awalan 0) memilih produknya (F1-07h)', () async {
      final upc = PurchaseFormViewModel(
        repository: FakePurchasesRepository(
          products: [
            ...cashierProducts(),
            const ProductDraft(
              name: 'Sereal Impor',
              baseUnit: 'pcs',
              variants: [
                VariantDraft(barcode: '036000291452', sellPrice: Money(30000)),
              ],
            ),
          ],
        ),
      );
      await upc.load.execute();
      expect(upc.addByCode('0036000291452'), PurchaseScanResult.added);
      expect(upc.lines.single.product.productName, 'Sereal Impor');
    });

    test('ganti satuan mengisi ulang harga; satuan kembar digabung', () {
      form
        ..addByCode('8991234500031')
        ..addByCode('MYK-2L');
      final dus = form.lines.first;
      final botol = form.lines.last;
      form.setUnit(botol.key, dus.unit.productUnitId);
      expect(form.lines.single.quantity, Qty.units(2));
      form.setUnit(form.lines.single.key, null);
      expect(form.lines.single.unitPrice, const Money(32500));
      expect(form.lines.single.priceRev, 1);
    });

    test('total, sisa hutang, dan galat setelah mencoba terima', () async {
      form
        ..addByCode('8991234500031')
        ..setQuantity(form.lines.single.key, Qty.units(4))
        ..setDiscount(const Money(40000))
        ..setShipping(const Money(25000))
        ..setPaid(const Money(500000));
      expect(form.totals.total, const Money(765000));
      expect(form.debt, const Money(265000));
      expect(form.issues, isEmpty);
      await form.receive.execute();
      expect(form.receive.error, isTrue);
      expect(form.hasIssue(PurchaseField.supplier), isTrue);
      expect(repo.requests, isEmpty);
      // Supplier baru cukup diketik.
      form
        ..useNewSupplier()
        ..setNewSupplierName('UD Makmur');
      expect(form.issues, isEmpty);
      await form.receive.execute();
      expect(form.receive.completed, isTrue);
      final r = repo.requests.single;
      expect(r.newSupplierName, 'UD Makmur');
      expect(r.funding, FundingSource.storeCash);
      expect(r.dueOn, DateTime.utc(2026, 11, 17));
      expect(r.purchasedOn, DateTime.utc(2026, 11, 3));
    });

    test('lunas tidak mengirim jatuh tempo; laci tanpa sesi ditolak', () async {
      repo.hasOpenSession = false;
      form
        ..addByCode('KOP')
        ..setUnitPrice(form.lines.single.key, const Money(1500))
        ..payInFull()
        ..setFunding(FundingKind.drawer);
      expect(form.paid, const Money(1500));
      await form.receive.execute();
      expect(form.actionError, isA<CashSessionNotOpen>());
      expect(repo.requests.single.dueOn, isNull);
    });

    test('bayar dari laci melebihi perkiraan: peringatan (F1-03c)', () async {
      repo.drawerCash = const Money(1000);
      final f = PurchaseFormViewModel(repository: repo);
      addTearDown(f.dispose);
      await f.load.execute();
      f
        ..selectSupplier(repo.suppliers.single.id)
        ..addByCode('KOP')
        ..setUnitPrice(f.lines.single.key, const Money(1500))
        ..setPaid(const Money(1000))
        ..setFunding(FundingKind.drawer);
      expect(f.drawerShortfall, isNull);
      f.payInFull();
      expect(f.drawerShortfall, const Money(500));
      f.setFunding(FundingKind.storeCash);
      expect(f.drawerShortfall, isNull);
      f.setFunding(FundingKind.drawer);
      // Tanpa izin laci: terima ditolak, jadi tanpa peringatan.
      repo.canUseDrawer = false;
      await f.load.execute();
      f
        ..addByCode('KOP')
        ..setUnitPrice(f.lines.single.key, const Money(1500))
        ..payInFull()
        ..setFunding(FundingKind.drawer);
      expect(f.drawerShortfall, isNull);
      repo.canUseDrawer = true;
      await f.load.execute();
      f
        ..selectSupplier(repo.suppliers.single.id)
        ..addByCode('KOP')
        ..setUnitPrice(f.lines.single.key, const Money(1500))
        ..payInFull()
        ..setFunding(FundingKind.drawer);
      expect(f.drawerShortfall, const Money(500));
      await f.receive.execute();
      expect(f.receive.completed, isTrue);
      expect(repo.requests.single.funding, FundingSource.drawer);
    });

    test('draf disimpan lalu dibuka lagi dengan isi yang sama', () async {
      form
        ..selectSupplier(repo.suppliers.single.id)
        ..setInvoiceNo('SP/XI/0457')
        ..addByCode('8991234500031');
      await form.saveDraft.execute();
      expect(form.isDraft, isTrue);
      final id = form.draftId!;
      final again = PurchaseFormViewModel(repository: repo, draftId: id);
      await again.load.execute();
      expect(again.number, 'PB-PST-D01-261103-0001');
      expect(again.invoiceNo, 'SP/XI/0457');
      expect(again.supplierId, repo.suppliers.single.id);
      expect(again.lines.single.unit.name, 'Dus');
      await again.deleteDraft.execute();
      expect(again.deleteDraft.completed, isTrue);
      expect((await repo.list() as Ok<List<PurchaseRow>>).value, isEmpty);
    });

    test('tanggal mundur menggeser jatuh tempo bawaan', () {
      form.setPurchasedOn(DateTime(2026, 11, 1));
      expect(form.dueOn, DateTime(2026, 11, 15));
      form.setDueOn(DateTime(2026, 11, 30));
      form.setPurchasedOn(DateTime(2026, 11, 2));
      expect(form.dueOn, DateTime(2026, 11, 30));
    });

    test('jatuh tempo bawaan mengikuti tempo standar supplier', () async {
      repo.suppliers.add(
        Supplier(
          tenantId: repo.suppliers.first.tenantId,
          name: 'PT Segar Jaya',
          termDays: 7,
          hlc: '',
        ),
      );
      await form.load.execute();
      final segar = form.setup!.suppliers.firstWhere(
        (s) => s.name == 'PT Segar Jaya',
      );
      form.setPurchasedOn(DateTime(2026, 11, 3));
      form.selectSupplier(segar.id);
      expect(form.dueOn, DateTime(2026, 11, 10));
      form.setPurchasedOn(DateTime(2026, 11, 1));
      expect(form.dueOn, DateTime(2026, 11, 8));
      // Supplier baru (ketik nama) memakai 14 hari.
      form.useNewSupplier();
      expect(form.dueOn, DateTime(2026, 11, 15));
      // Jatuh tempo yang diubah staf tidak ditimpa.
      form.setDueOn(DateTime(2026, 12, 1));
      form.selectSupplier(segar.id);
      expect(form.dueOn, DateTime(2026, 12, 1));
    });
  });

  group('pembelian dari stok minimum (F1-08c)', () {
    test('baris terisi: jumlah saran, harga modal, lokasi; varian hilang '
        'dilewati; startNew kosong', () async {
      final variants = [
        for (final p in repo.products)
          for (final v in p.variants) v,
      ];
      final gudang = repo.locations.last;
      final restock = PurchaseRestock(
        locationId: gudang.id,
        locationName: 'Gudang',
        lines: [
          (variantId: variants[0].id, quantity: Qty.units(38)),
          (variantId: variants[1].id, quantity: Qty.units(18)),
          (variantId: UuidValue.fromString(newId()), quantity: Qty.units(5)),
        ],
      );
      final filled = PurchaseFormViewModel(repository: repo, restock: restock);
      await filled.load.execute();
      expect(filled.locationName, 'Gudang');
      expect(filled.lines, hasLength(2));
      expect(filled.lines.first.product.variantId, variants[0].id);
      expect(filled.lines.first.quantity, Qty.units(38));
      expect(filled.lines.first.unit.isBase, isTrue);
      expect(filled.lines.first.unitPrice, variants[0].costPrice);
      expect(filled.lines.last.quantity, Qty.units(18));
      expect(filled.restockApplied, 2);
      expect(filled.restockSkipped, 1);
      expect(filled.restockLocationName, 'Gudang');
      expect(filled.supplierId, isNull);

      await filled.startNew();
      expect(filled.lines, isEmpty);
      expect(filled.restockApplied, 0);
      expect(filled.locationName, 'Toko');
      filled.dispose();
    });
  });

  group('supplier terakhir untuk draf stok minimum (F1-08d)', () {
    PurchaseRestock restockOf(FakePurchasesRepository r) => PurchaseRestock(
      locationId: r.locations.first.id,
      locationName: 'Toko',
      lines: [
        for (final v in [
          for (final p in r.products) ...p.variants,
        ].take(3))
          (variantId: v.id, quantity: Qty.one),
      ],
    );

    test('supplier terbanyak dipilih, catatan menyebut jumlahnya', () async {
      final r = FakePurchasesRepository(
        suppliers: const ['CV Sumber Pangan', 'Toko Gula Jaya'],
      );
      final variants = [
        for (final p in r.products)
          for (final v in p.variants) v.id,
      ];
      final sumber = r.suppliers.first;
      final gula = r.suppliers.last;
      r.lastSupplierOf
        ..[variants[0]] = (supplierId: gula.id, at: DateTime.utc(2026, 11, 2))
        ..[variants[1]] = (
          supplierId: sumber.id,
          at: DateTime.utc(2026, 10, 1),
        );
      r.lastSupplierOf[variants[2]] = (
        supplierId: sumber.id,
        at: DateTime.utc(2026, 9, 1),
      );
      final vm = PurchaseFormViewModel(repository: r, restock: restockOf(r));
      await vm.load.execute();
      // Sumber Pangan untuk 2 barang, Gula Jaya 1 barang (walau lebih baru).
      expect(vm.restockApplied, 3);
      expect(vm.supplierId, sumber.id);
      expect(vm.restockSupplierName, 'CV Sumber Pangan');
      expect(vm.restockSupplierCount, 2);
      // Mengganti supplier menghapus catatan supplier terakhir.
      vm.selectSupplier(gula.id);
      expect(vm.restockSupplierName, isNull);
      await vm.startNew();
      expect(vm.supplierId, isNull);
      expect(vm.restockSupplierName, isNull);
      vm.dispose();
    });

    test(
      'galat baca supplier terakhir: form tetap terisi tanpa supplier',
      () async {
        final r = FakePurchasesRepository();
        r.lastSupplierOf[r.products.first.variants.first.id] = (
          supplierId: r.suppliers.single.id,
          at: DateTime.utc(2026, 11, 2),
        );
        final vm = _FailingLast(r);
        final form = PurchaseFormViewModel(
          repository: vm,
          restock: restockOf(r),
        );
        await form.load.execute();
        expect(form.restockApplied, greaterThan(0));
        expect(form.supplierId, isNull);
        expect(form.restockSupplierName, isNull);
        form.dispose();
      },
    );

    test('tanpa riwayat atau supplier sudah tidak ada: kosong', () async {
      final r = FakePurchasesRepository();
      final variant = r.products.first.variants.first.id;
      r.lastSupplierOf[variant] = (
        supplierId: UuidValue.fromString(newId()),
        at: DateTime.utc(2026, 11, 2),
      );
      final vm = PurchaseFormViewModel(repository: r, restock: restockOf(r));
      await vm.load.execute();
      expect(vm.supplierId, isNull);
      expect(vm.restockSupplierName, isNull);
      expect(vm.restockApplied, greaterThan(0));
      vm.dispose();
    });
  });

  group('harga beli terakhir untuk draf stok minimum (F1-08e)', () {
    PurchaseRestock restockOf(FakePurchasesRepository r) => PurchaseRestock(
      locationId: r.locations.first.id,
      locationName: 'Toko',
      lines: [
        for (final v in [
          for (final p in r.products) ...p.variants,
        ].take(2))
          (variantId: v.id, quantity: Qty.one),
      ],
    );

    test('baris dengan riwayat memakai harga terakhir, lainnya harga '
        'modal', () async {
      final r = FakePurchasesRepository();
      final variants = [for (final p in r.products) ...p.variants];
      r.lastPriceOf[variants[0].id] = const Money(31500);
      final vm = PurchaseFormViewModel(repository: r, restock: restockOf(r));
      await vm.load.execute();
      expect(vm.lines.first.unitPrice, const Money(31500));
      // Isian harga dibangun ulang (kunci memuat priceRev).
      expect(vm.lines.first.priceRev, 1);
      expect(vm.lines.last.unitPrice, variants[1].costPrice);
      expect(vm.lines.last.priceRev, 0);
      expect(vm.restockApplied, 2);
      expect(vm.restockPriceCount, 1);
      await vm.startNew();
      expect(vm.restockPriceCount, 0);
      vm.dispose();
    });

    test('galat baca harga terakhir: harga modal tetap dipakai', () async {
      final r = FakePurchasesRepository();
      final variants = [for (final p in r.products) ...p.variants];
      r.lastPriceOf[variants[0].id] = const Money(31500);
      final form = PurchaseFormViewModel(
        repository: _FailingPrices(r),
        restock: restockOf(r),
      );
      await form.load.execute();
      expect(form.lines.first.unitPrice, variants[0].costPrice);
      expect(form.restockPriceCount, 0);
      form.dispose();
    });
  });

  group('buka draf dari stok minimum (F1-08i)', () {
    Future<(FakePurchasesRepository, Purchase, List<UuidValue>)> seed() async {
      final r = FakePurchasesRepository(
        suppliers: const ['CV Sumber Pangan'],
      );
      final variants = [
        for (final p in r.products) ...p.variants.map((v) => v.id),
      ];
      final saved = await r.saveDraft(
        PurchaseRequest(
          purchasedOn: DateTime(2026, 11, 2),
          locationId: r.locations.first.id,
          lines: [
            PurchaseLineRequest(
              variantId: variants[0],
              quantity: Qty.units(5),
              unitPrice: const Money(30000),
            ),
          ],
        ),
      );
      // Riwayat yang tidak boleh mengubah baris draf atau suppliernya.
      r.lastPriceOf
        ..[variants[0]] = const Money(31500)
        ..[variants[1]] = const Money(12000);
      r.lastSupplierOf[variants[1]] = (
        supplierId: r.suppliers.single.id,
        at: DateTime.utc(2026, 11, 1),
      );
      return (r, (saved as Ok<Purchase>).value, variants);
    }

    PurchaseRestock restockOf(
      FakePurchasesRepository r,
      List<(UuidValue, int)> lines,
    ) => PurchaseRestock(
      locationId: r.locations.first.id,
      locationName: 'Toko',
      lines: [
        for (final (id, qty) in lines)
          (variantId: id, quantity: Qty.units(qty)),
      ],
    );

    test('barang yang belum ada ditambahkan; baris draf, lokasi, dan '
        'supplier tidak berubah', () async {
      final (r, draft, v) = await seed();
      final vm = PurchaseFormViewModel(
        repository: r,
        draftId: draft.id,
        restock: restockOf(r, [(v[0], 38), (v[1], 18), (v[2], 7)]),
      );
      await vm.load.execute();
      expect(vm.isDraft, isTrue);
      expect(vm.draftId, draft.id);
      expect(vm.number, draft.number);
      expect(vm.lines.map((l) => l.product.variantId), [v[0], v[1], v[2]]);
      // Baris lama tetap: jumlah dan harga draf.
      expect(vm.lines[0].quantity, Qty.units(5));
      expect(vm.lines[0].unitPrice, const Money(30000));
      expect(vm.lines[0].priceRev, 0);
      // Baris baru: jumlah saran, harga beli terakhir atau harga modal.
      expect(vm.lines[1].quantity, Qty.units(18));
      expect(vm.lines[1].unitPrice, const Money(12000));
      expect(vm.lines[2].quantity, Qty.units(7));
      expect(
        vm.lines[2].unitPrice,
        r.products
            .expand((p) => p.variants)
            .firstWhere((x) => x.id == v[2])
            .costPrice,
      );
      expect(vm.restockIntoDraft, isTrue);
      expect(vm.restockApplied, 2);
      expect(vm.restockInDraft, 1);
      expect(vm.restockPriceCount, 1);
      expect(vm.restockLocationName, 'Toko');
      expect(vm.supplierId, isNull);
      expect(vm.restockSupplierName, isNull);
      expect(r.lastPriceCalls, 1);
      vm.dispose();
    });

    test('semua barang sudah ada: tidak ada baris baru', () async {
      final (r, draft, v) = await seed();
      final vm = PurchaseFormViewModel(
        repository: r,
        draftId: draft.id,
        restock: restockOf(r, [(v[0], 38)]),
      );
      await vm.load.execute();
      expect(vm.lines, hasLength(1));
      expect(vm.lines.single.unitPrice, const Money(30000));
      expect(vm.restockApplied, 0);
      expect(vm.restockInDraft, 1);
      expect(vm.restockIntoDraft, isTrue);
      vm.dispose();
    });

    test('simpan draf menyimpan baris tambahan ke draf yang sama', () async {
      final (r, draft, v) = await seed();
      final vm = PurchaseFormViewModel(
        repository: r,
        draftId: draft.id,
        restock: restockOf(r, [(v[0], 38), (v[1], 18)]),
      );
      await vm.load.execute();
      await vm.saveDraft.execute();
      expect(vm.saveDraft.completed, isTrue);
      expect(r.purchases.where((p) => p.number == draft.number), hasLength(1));
      // Tambahan sudah tersimpan: catatan "simpan draf" hilang.
      expect(vm.restockIntoDraft, isFalse);
      expect(vm.restockLocationName, isNull);
      final detail = await r.detail(draft.id);
      expect(
        (detail as Ok<PurchaseDetail>).value.items.map((i) => i.variantId),
        [v[0], v[1]],
      );
      vm.dispose();
    });
  });

  group('jumlah saran ikut satuan (F1-08j)', () {
    Future<PurchaseFormViewModel> filled(int qty) async {
      final r = FakePurchasesRepository();
      final myk = r.products.first.variants.first;
      final vm = PurchaseFormViewModel(
        repository: r,
        restock: PurchaseRestock(
          locationId: r.locations.first.id,
          locationName: 'Toko',
          lines: [(variantId: myk.id, quantity: Qty.units(qty))],
        ),
      );
      await vm.load.execute();
      return vm;
    }

    UuidValue dus(PurchaseFormLine l) =>
        l.product.units.firstWhere((u) => !u.isBase).productUnitId!;

    test('saran 38 botol → 7 dus (dibulatkan ke atas), kembali 38 '
        'botol', () async {
      final vm = await filled(38);
      final line = vm.lines.single;
      expect(line.suggested, Qty.units(38));
      vm.setUnit(line.key, dus(line));
      expect(vm.lines.single.unit.name, 'Dus');
      expect(vm.lines.single.quantity, Qty.units(7));
      vm.setUnit(line.key, null);
      expect(vm.lines.single.unit.isBase, isTrue);
      expect(vm.lines.single.quantity, Qty.units(38));
      vm.dispose();
    });

    test('pas habis dibagi: 36 botol → 6 dus', () async {
      final vm = await filled(36);
      vm.setUnit(vm.lines.single.key, dus(vm.lines.single));
      expect(vm.lines.single.quantity, Qty.units(6));
      vm.dispose();
    });

    test('jumlah yang sudah diubah staf tidak dikonversi', () async {
      final vm = await filled(38);
      final key = vm.lines.single.key;
      vm.setQuantity(key, Qty.units(2));
      expect(vm.lines.single.suggested, isNull);
      vm.setUnit(key, dus(vm.lines.single));
      expect(vm.lines.single.quantity, Qty.units(2));
      vm.dispose();
    });

    test('scan ulang barang saran (+1) menghentikan konversi', () async {
      final vm = await filled(38);
      expect(vm.addByCode('MYK-2L'), PurchaseScanResult.increased);
      final line = vm.lines.single;
      expect(line.quantity, Qty.units(39));
      expect(line.suggested, isNull);
      vm.setUnit(line.key, dus(line));
      expect(vm.lines.single.quantity, Qty.units(39));
      vm.dispose();
    });

    test('isian jumlah yang tidak berubah tidak melupakan saran', () async {
      final vm = await filled(38);
      final key = vm.lines.single.key;
      vm.setQuantity(key, Qty.units(38));
      expect(vm.lines.single.suggested, Qty.units(38));
      vm.setUnit(key, dus(vm.lines.single));
      expect(vm.lines.single.quantity, Qty.units(7));
      vm.dispose();
    });

    test('digabung ke baris dus yang sudah ada: ditambah saran yang '
        'dikonversi', () async {
      final vm = await filled(38);
      final saran = vm.lines.single;
      final unitId = dus(saran);
      expect(vm.addByCode('8991234500031'), PurchaseScanResult.added);
      expect(vm.lines, hasLength(2));
      vm.setUnit(saran.key, unitId);
      final merged = vm.lines.single;
      expect(merged.unit.name, 'Dus');
      expect(merged.quantity, Qty.units(1 + 7));
      vm.dispose();
    });

    test('barang yang ditambah manual tetap seperti dulu', () async {
      expect(form.addByCode('MYK-2L'), PurchaseScanResult.added);
      final line = form.lines.single;
      expect(line.suggested, isNull);
      form.setQuantity(line.key, Qty.units(3));
      form.setUnit(line.key, dus(line));
      expect(form.lines.single.quantity, Qty.units(3));
    });
  });

  group('harga beli terakhir untuk barang yang ditambah manual (F1-12e)', () {
    UuidValue myk() => form.lines
        .firstWhere((l) => l.product.sku == 'MYK-2L')
        .product
        .variantId;

    test(
      'satuan dasar memakai harga terakhir; tanpa riwayat harga modal',
      () async {
        final variants = [for (final p in repo.products) ...p.variants];
        final myk2 = variants.firstWhere((v) => v.sku == 'MYK-2L');
        repo.lastPriceOf[myk2.id] = const Money(31000);
        expect(form.addByCode('MYK-2L'), PurchaseScanResult.added);
        // Harga modal tampil dulu, lalu diganti setelah riwayat terbaca.
        expect(form.lines.single.unitPrice, const Money(32500));
        await pumpEventQueue();
        expect(form.lines.single.unitPrice, const Money(31000));
        expect(form.lines.single.priceRev, 1);
        expect(myk(), myk2.id);
        // Barang lain tanpa riwayat tetap harga modal.
        final other = variants.firstWhere((v) => v.id != myk2.id);
        form.addProduct(other.id);
        await pumpEventQueue();
        expect(form.lines.last.unitPrice, other.costPrice);
        expect(form.lines.last.priceRev, 0);
      },
    );

    test('harga yang diubah staf selama menunggu tidak ditimpa', () async {
      final myk2 = [
        for (final p in repo.products) ...p.variants,
      ].firstWhere((v) => v.sku == 'MYK-2L');
      repo.lastPriceOf[myk2.id] = const Money(31000);
      form.addByCode('MYK-2L');
      form.setUnitPrice(form.lines.single.key, const Money(30000));
      await pumpEventQueue();
      expect(form.lines.single.unitPrice, const Money(30000));
    });

    test('satuan konversi memakai harga modal; kembali ke satuan dasar '
        'memakai harga terakhir lagi tanpa membaca ulang', () async {
      final myk2 = [
        for (final p in repo.products) ...p.variants,
      ].firstWhere((v) => v.sku == 'MYK-2L');
      repo.lastPriceOf[myk2.id] = const Money(31000);
      form.addByCode('8991234500031');
      await pumpEventQueue();
      // Dus: HPP dasar 32.500 × 6, tidak dari riwayat.
      expect(form.lines.single.unitPrice, const Money(195000));
      expect(repo.lastPriceCalls, 0);
      final key = form.lines.single.key;
      form.setUnit(key, null);
      await pumpEventQueue();
      expect(form.lines.single.unitPrice, const Money(31000));
      expect(repo.lastPriceCalls, 1);
      final dus = form.lines.single.product.units[1].productUnitId;
      form.setUnit(key, dus);
      expect(form.lines.single.unitPrice, const Money(195000));
      form.setUnit(key, null);
      await pumpEventQueue();
      expect(form.lines.single.unitPrice, const Money(31000));
      // Riwayat varian ini sudah tersimpan selama form terbuka.
      expect(repo.lastPriceCalls, 1);
    });

    UuidValue mykId() => [
      for (final p in repo.products) ...p.variants,
    ].firstWhere((v) => v.sku == 'MYK-2L').id;

    test('baris diganti ke dus selama menunggu: harga dus tetap', () async {
      repo.lastPriceOf[mykId()] = const Money(31000);
      form.addByCode('MYK-2L');
      final key = form.lines.single.key;
      form.setUnit(key, form.lines.single.product.units[1].productUnitId);
      await pumpEventQueue();
      expect(form.lines.single.unitPrice, const Money(195000));
    });

    test(
      'simpan sebelum riwayat terbaca: draf berisi harga terakhir',
      () async {
        repo.lastPriceOf[mykId()] = const Money(31000);
        form.addByCode('MYK-2L');
        await form.saveDraft.execute();
        expect(form.saveDraft.completed, isTrue);
        expect(form.lines.single.unitPrice, const Money(31000));
        expect(repo.requests.single.lines.single.unitPrice, const Money(31000));
      },
    );

    test('form baru membaca ulang riwayat', () async {
      repo.lastPriceOf[mykId()] = const Money(31000);
      form.addByCode('MYK-2L');
      await pumpEventQueue();
      expect(repo.lastPriceCalls, 1);
      repo.lastPriceOf[mykId()] = const Money(30500);
      await form.startNew();
      form.addByCode('MYK-2L');
      await pumpEventQueue();
      expect(form.lines.single.unitPrice, const Money(30500));
      expect(repo.lastPriceCalls, 2);
    });

    test(
      'riwayat dari draf stok minimum dipakai lagi tanpa membaca ulang',
      () async {
        final variants = [for (final p in repo.products) ...p.variants];
        repo.lastPriceOf[variants[0].id] = const Money(31500);
        final vm = PurchaseFormViewModel(
          repository: repo,
          restock: PurchaseRestock(
            locationId: repo.locations.first.id,
            locationName: 'Toko',
            lines: [(variantId: variants[0].id, quantity: Qty.one)],
          ),
        );
        await vm.load.execute();
        expect(repo.lastPriceCalls, 1);
        vm.removeLine(vm.lines.single.key);
        vm.addProduct(variants[0].id);
        await pumpEventQueue();
        expect(vm.lines.single.unitPrice, const Money(31500));
        expect(repo.lastPriceCalls, 1);
        vm.dispose();
      },
    );

    test('draf yang dibuka lagi tidak berubah harganya', () async {
      form.addByCode('MYK-2L');
      form.setUnitPrice(form.lines.single.key, const Money(33000));
      await form.saveDraft.execute();
      repo.lastPriceOf[mykId()] = const Money(31000);
      final again = PurchaseFormViewModel(
        repository: repo,
        draftId: form.draftId,
      );
      await again.load.execute();
      await pumpEventQueue();
      expect(again.lines.single.unitPrice, const Money(33000));
      again.dispose();
    });

    test(
      'galat baca: harga modal tetap, baris berikutnya mencoba lagi',
      () async {
        final myk2 = [
          for (final p in repo.products) ...p.variants,
        ].firstWhere((v) => v.sku == 'MYK-2L');
        repo.lastPriceOf[myk2.id] = const Money(31000);
        repo.nextError = Exception('baca gagal');
        form.addByCode('MYK-2L');
        await pumpEventQueue();
        expect(form.lines.single.unitPrice, const Money(32500));
        form.removeLine(form.lines.single.key);
        form.addByCode('MYK-2L');
        await pumpEventQueue();
        expect(form.lines.single.unitPrice, const Money(31000));
      },
    );
  });

  group('PurchaseDetailViewModel', () {
    Future<PurchaseDetailViewModel> received({int paid = 0}) async {
      form
        ..selectSupplier(repo.suppliers.single.id)
        ..addByCode('MYK-2L')
        ..setQuantity(form.lines.single.key, Qty.units(12))
        ..setUnitPrice(form.lines.single.key, const Money(34000))
        ..setPaid(Money(paid));
      await form.receive.execute();
      final vm = PurchaseDetailViewModel(
        repository: repo,
        purchaseId: form.draftId!,
      );
      await vm.load.execute();
      return vm;
    }

    test('saran harga jual dan terapkan', () async {
      final vm = await received();
      // HPP 32.500 (24 btl) → (780.000 + 408.000) / 36 = 33.000.
      final s = vm.suggestions.single;
      expect(s.item.avgCostBefore, 32500);
      expect(s.item.avgCostAfter, 33000);
      // 36.000 × 33.000 / 32.500 = 36.553,8 → 36.600.
      expect(s.suggested, const Money(36600));
      expect(s.below, isTrue);
      expect(vm.checked, {s.item.variantId});
      await vm.applyPrices.execute();
      expect(repo.applied.single, {s.item.variantId: const Money(36600)});
      expect(vm.suggestions.single.below, isFalse);
      expect(vm.checked, isEmpty);
    });

    test('satu saran per varian walau dibeli dalam dua satuan', () async {
      repo.canEditPrices = false;
      form
        ..selectSupplier(repo.suppliers.single.id)
        ..addByCode('8991234500031')
        ..addByCode('MYK-2L')
        ..payInFull();
      await form.receive.execute();
      final vm = PurchaseDetailViewModel(
        repository: repo,
        purchaseId: form.draftId!,
      );
      await vm.load.execute();
      expect(vm.detail!.items, hasLength(2));
      expect(vm.suggestions, hasLength(1));
      expect(vm.suggestionFor(vm.detail!.items.last), isNull);
      expect(vm.canEditPrices, isFalse);
    });

    test('jatuh tempo dalam hari', () async {
      final vm = await received();
      expect(vm.dueInDays, 14);
    });

    test(
      'retur: kurangi hutang dulu, sisa uang kembali wajib sumber',
      () async {
        final vm = await received(paid: 400000);
        final item = vm.detail!.items.single;
        expect(vm.detail!.debt, const Money(8000));
        vm
          ..openReturn()
          ..setReturnQty(item.id, Qty.units(13));
        expect(vm.exceeds(item), isTrue);
        vm.setReturnQty(item.id, Qty.units(2));
        expect(vm.returnTotal, const Money(68000));
        expect(vm.returnSplit.debtReduction, const Money(8000));
        expect(vm.returnSplit.refund, const Money(60000));
        await vm.submitReturn.execute();
        expect(vm.returnIssues, [PurchaseReturnIssue.refundSource]);
        vm.setRefundSource(FundingKind.bank);
        await vm.submitReturn.execute();
        expect(vm.submitReturn.completed, isTrue);
        expect(vm.returning, isFalse);
        expect(vm.detail!.returns.single.refundAmount, 60000);
        expect(vm.detail!.remainingMilli(item), 10000);
        expect(vm.dueInDays, isNull);
      },
    );
  });

  test('PurchasesViewModel: tab dan cari', () async {
    form
      ..selectSupplier(repo.suppliers.single.id)
      ..addByCode('KOP');
    await form.saveDraft.execute();
    final vm = PurchasesViewModel(repository: repo);
    await vm.load.execute();
    expect(vm.rows!.single.isDraft, isTrue);
    vm.setQuery('sumber');
    await Future<void>.delayed(Duration.zero);
    expect(vm.rows, hasLength(1));
    vm.setQuery('tidak ada');
    await Future<void>.delayed(Duration.zero);
    expect(vm.rows, isEmpty);
    vm.setTab(PurchaseTab.returns);
    expect(vm.tab, PurchaseTab.returns);
    expect(vm.returns, isEmpty);
  });
}

/// Repositori palsu yang gagal membaca supplier terakhir (F1-08d).
class _FailingLast extends FakePurchasesRepository {
  _FailingLast(this._inner);

  final FakePurchasesRepository _inner;

  @override
  Future<Result<PurchaseSetup>> load() => _inner.load();

  @override
  Future<Result<Map<UuidValue, ({UuidValue supplierId, DateTime at})>>>
  lastSuppliers(Iterable<UuidValue> variantIds) async =>
      Result.error(Exception('baca gagal'));
}

/// Repositori palsu yang gagal membaca harga beli terakhir (F1-08e).
class _FailingPrices extends FakePurchasesRepository {
  _FailingPrices(this._inner);

  final FakePurchasesRepository _inner;

  @override
  Future<Result<PurchaseSetup>> load() => _inner.load();

  @override
  Future<Result<Map<UuidValue, Money>>> lastPurchasePrices(
    Iterable<UuidValue> variantIds,
  ) async => Result.error(Exception('baca gagal'));
}
