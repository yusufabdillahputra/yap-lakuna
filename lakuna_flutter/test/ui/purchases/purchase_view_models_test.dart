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
