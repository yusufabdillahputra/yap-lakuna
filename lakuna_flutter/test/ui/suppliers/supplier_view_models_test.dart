import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/suppliers_repository.dart'
    show NotPermitted;
import 'package:lakuna_flutter/data/services/image_file_picker.dart';
import 'package:lakuna_flutter/ui/suppliers/supplier_form_view_model.dart';
import 'package:lakuna_flutter/ui/suppliers/supplier_panel_view_model.dart';
import 'package:lakuna_flutter/ui/suppliers/supplier_purchases_view_model.dart';
import 'package:lakuna_flutter/ui/suppliers/suppliers_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/fake_payment_settings_repository.dart'
    show FakeImagePicker;
import '../../testing/fake_suppliers_repository.dart';
import '../../testing/qris_seed.dart';

void main() {
  late FakeSuppliersRepository repo;

  setUp(() => repo = FakeSuppliersRepository());

  UuidValue idOf(String name) => repo.byName(name).id;

  group('SuppliersViewModel', () {
    test('memuat, menyaring nama/kategori/telepon, dan memilih', () async {
      final vm = SuppliersViewModel(repository: repo);
      await vm.load.execute();
      expect(vm.rows.map((r) => r.supplier.name), [
        'CV Sumber Pangan',
        'PT Segar Jaya',
        'UD Makmur',
      ]);
      expect(vm.overview!.totalDebt, const Money(1300000 + 725000 + 480000));
      expect(vm.overview!.nearestDue, DateTime.utc(2026, 11, 4));
      vm.setQuery('minuman');
      expect(vm.rows.single.supplier.name, 'UD Makmur');
      vm.setQuery('0813');
      expect(vm.rows.single.supplier.name, 'PT Segar Jaya');
      vm.setQuery('hendra');
      expect(vm.rows.single.supplier.name, 'CV Sumber Pangan');
      vm.select(idOf('UD Makmur'));
      expect(vm.selected, idOf('UD Makmur'));
    });

    test('tanpa izin → galat NotPermitted', () async {
      repo
        ..canManage = false
        ..canPay = false;
      final vm = SuppliersViewModel(repository: repo);
      await vm.load.execute();
      expect(vm.error, isA<NotPermitted>());
    });
  });

  group('SupplierPanelViewModel', () {
    late SupplierPanelViewModel vm;
    late FakeImagePicker picker;

    setUp(() async {
      picker = FakeImagePicker();
      vm = SupplierPanelViewModel(
        repository: repo,
        supplierId: idOf('CV Sumber Pangan'),
        picker: picker,
      );
      await vm.load.execute();
    });

    tearDown(() => vm.dispose());

    test('alokasi otomatis ke jatuh tempo terdekat, sisa setelah bayar', () {
      expect(vm.detail!.open.map((p) => p.purchase.number), [
        'PB-PST-D01-261028-0001',
        'PB-PST-D01-261102-0003',
      ]);
      vm.setAmount(const Money(1500000));
      final first = vm.detail!.open[0].purchase.id;
      final second = vm.detail!.open[1].purchase.id;
      expect(vm.allocations, {
        first: const Money(1300000),
        second: const Money(200000),
      });
      expect(vm.balanceAfter, const Money(525000));
      expect(vm.nextDueAfter, DateTime.utc(2026, 11, 16));
      expect(vm.canSubmit, isTrue);

      vm.payAll();
      expect(vm.amount, const Money(2025000));
      expect(vm.nextDueAfter, isNull);
    });

    test('melebihi hutang dan alokasi manual tidak cocok ditolak', () {
      vm.setAmount(const Money(3000000));
      expect(vm.issue, DebtPaymentIssue.overOutstanding);
      expect(vm.canSubmit, isFalse);
      vm.setAmount(const Money(100000));
      vm.setManual(true);
      final first = vm.detail!.open[0].purchase.id;
      vm.setAllocation(first, const Money(40000));
      expect(vm.issue, DebtPaymentIssue.allocationTotal);
      expect(vm.canSubmit, isFalse);
      vm.setAllocation(first, const Money(100000));
      expect(vm.issue, isNull);
      expect(vm.canSubmit, isTrue);
    });

    test('kas laci butuh izin, sesi terbuka, dan tanggal hari ini', () async {
      vm.setAmount(const Money(100000));
      vm.setFunding(FundingSource.drawer);
      expect(vm.drawerIssue, isNull);
      vm.setPaidOn(DateTime.utc(2026, 11, 3));
      expect(vm.drawerIssue, DrawerIssue.notToday);
      expect(vm.canSubmit, isFalse);
      vm.setPaidOn(DateTime.utc(2026, 11, 4));

      repo.hasOpenSession = false;
      final noSession = SupplierPanelViewModel(
        repository: repo,
        supplierId: idOf('CV Sumber Pangan'),
      );
      await noSession.load.execute();
      noSession.setFunding(FundingSource.drawer);
      expect(noSession.drawerIssue, DrawerIssue.noSession);
      noSession.dispose();

      repo
        ..hasOpenSession = true
        ..canUseDrawer = false;
      final noPermission = SupplierPanelViewModel(
        repository: repo,
        supplierId: idOf('CV Sumber Pangan'),
      );
      await noPermission.load.execute();
      noPermission.setFunding(FundingSource.drawer);
      expect(noPermission.drawerIssue, DrawerIssue.notPermitted);
      noPermission.dispose();
    });

    test('muat ulang menyegarkan status sesi kasir', () async {
      vm.setFunding(FundingSource.drawer);
      expect(vm.drawerIssue, isNull);
      repo.hasOpenSession = false;
      await vm.load.execute();
      expect(vm.drawerIssue, DrawerIssue.noSession);
    });

    test('simpan: kirim permintaan, kosongkan isian, muat ulang', () async {
      picker.next = PickedImage(
        name: 'bukti.png',
        size: tinyPortraitPng.length,
        bytes: tinyPortraitPng,
      );
      await vm.pickProof.execute(false);
      expect(vm.proof?.fileName, 'bukti.png');
      vm
        ..setAmount(const Money(1300000))
        ..setFunding(FundingSource.bank)
        ..setReference(' TRF-0211-883 ')
        ..setNote('Lunas faktur Oktober');
      final gen = vm.generation;
      await vm.pay.execute();
      expect(vm.pay.result, isA<Ok<DebtPayment>>());
      final r = repo.requests.single;
      expect(r.amount, const Money(1300000));
      expect(r.funding, FundingSource.bank);
      expect(r.reference, 'TRF-0211-883');
      expect(r.note, 'Lunas faktur Oktober');
      expect(r.allocations, isNull);
      expect(r.proof!.bytes, tinyPortraitPng);
      expect(vm.amount, Money.zero);
      expect(vm.proof, isNull);
      expect(vm.generation, greaterThan(gen));
      expect(vm.detail!.open, hasLength(1));
      expect(vm.detail!.payments.single.number, 'BH-PST-K01-261104-0001');
    });

    test(
      'batal pembayaran laci: hutang kembali, butuh sesi (F1-13c)',
      () async {
        vm
          ..setAmount(const Money(300000))
          ..setFunding(FundingSource.drawer);
        await vm.pay.execute();
        final paid = vm.detail!.payments.single;
        final before = vm.detail!.row.debt;
        expect(vm.canVoid(paid), isTrue);

        repo.hasOpenSession = false;
        await vm.voidPayment.execute((paid.id, 'Salah nominal'));
        expect(
          (vm.voidPayment.result! as Error<DebtPayment>).error,
          isA<CashSessionNotOpen>(),
        );

        repo.hasOpenSession = true;
        await vm.voidPayment.execute((paid.id, 'Salah nominal'));
        expect(vm.voidPayment.result, isA<Ok<DebtPayment>>());
        expect(vm.detail!.row.debt, before + const Money(300000));
        expect(vm.detail!.payments.single.voidReason, 'Salah nominal');
        expect(vm.canVoid(vm.detail!.payments.single), isFalse);
      },
    );

    test('foto bukti 12 MB diterima (dikecilkan saat disimpan)', () async {
      final big = Uint8List(12 * 1024 * 1024)..setAll(0, tinyPortraitPng);
      picker.next = PickedImage(
        name: 'bukti.jpg',
        size: big.length,
        bytes: big,
      );
      await vm.pickProof.execute(false);
      expect(vm.proofIssue, isNull);
      expect(vm.proof!.bytes.length, big.length);
    });

    test('foto bukti terlalu besar atau bukan gambar ditolak', () async {
      picker.next = PickedImage(
        name: 'besar.png',
        size: SupplierLimits.proofInputMaxBytes + 1,
        bytes: Uint8List(SupplierLimits.proofInputMaxBytes + 1),
      );
      await vm.pickProof.execute(false);
      expect(vm.proofIssue, ProofIssue.tooLarge);
      expect(vm.proof, isNull);
      picker.next = PickedImage(
        name: 'teks.png',
        size: 3,
        bytes: Uint8List.fromList([1, 2, 3]),
      );
      await vm.pickProof.execute(false);
      expect(vm.proofIssue, ProofIssue.invalid);
    });

    test('hapus ditolak selama berhutang', () async {
      await vm.delete.execute();
      expect(vm.delete.result, isA<Error<void>>());
      expect(
        (vm.delete.result! as Error<void>).error,
        isA<SupplierHasDebt>(),
      );
    });
  });

  group('SupplierFormViewModel', () {
    test('validasi lalu simpan', () async {
      final vm = SupplierFormViewModel(repository: repo);
      vm.setTermDays('');
      await vm.save.execute();
      expect(vm.issues, {SupplierIssue.name, SupplierIssue.termDays});
      vm
        ..setName('Toko Plastik Jaya')
        ..setContactName('Mas Budi')
        ..setCategory('Kemasan')
        ..setPhone('0812 9999 0000')
        ..setTermDays('30');
      await vm.save.execute();
      final saved = (vm.save.result! as Ok<Supplier>).value;
      expect(saved.phone, '081299990000');
      expect(saved.termDays, 30);
      expect(repo.byName('Toko Plastik Jaya').category, 'Kemasan');
    });

    test('nama sudah dipakai', () async {
      final vm = SupplierFormViewModel(repository: repo)..setName('ud makmur');
      await vm.save.execute();
      expect(
        (vm.save.result! as Error<Supplier>).error,
        isA<SupplierNameTaken>(),
      );
    });
  });

  test('SupplierPurchasesViewModel: terbaru dulu', () async {
    final vm = SupplierPurchasesViewModel(
      repository: repo,
      supplierId: idOf('CV Sumber Pangan'),
    );
    await vm.load.execute();
    expect(vm.rows!.map((r) => r.purchase.number), [
      'PB-PST-D01-261102-0003',
      'PB-PST-D01-261101-0002',
      'PB-PST-D01-261028-0001',
    ]);
  });
}
