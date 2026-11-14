import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/ui/onboarding/onboarding_view_model.dart';

import '../../testing/fake_session_repository.dart';
import '../../testing/fake_store_repository.dart';

void fillBusiness(OnboardingViewModel vm) {
  vm
    ..setBusinessType(BusinessKind.fnb)
    ..setField(SetupField.businessName, 'Warung Contoh')
    ..setField(SetupField.outletName, 'Cabang Pusat')
    ..setField(SetupField.outletCode, 'pst');
}

void fillOwner(OnboardingViewModel vm) {
  vm
    ..setField(SetupField.ownerName, 'Yusuf')
    ..setField(SetupField.email, 'yusuf@contoh.id')
    ..setField(SetupField.password, 'rahasia123')
    ..setField(SetupField.passwordConfirm, 'rahasia123')
    ..setField(SetupField.pin, '123456')
    ..setField(SetupField.pinConfirm, '123456');
}

void fillProduct(OnboardingViewModel vm) {
  vm
    ..setProductName('Kopi Susu')
    ..setProductSellPrice(const Money(15000));
}

void main() {
  late FakeStoreRepository repository;
  late FakeSessionRepository session;
  late OnboardingViewModel vm;

  setUp(() {
    repository = FakeStoreRepository();
    session = FakeSessionRepository();
    vm = OnboardingViewModel(
      repository: repository,
      session: session,
      now: () => DateTime.utc(2026, 11, 3, 3),
    );
  });

  test('mulai di langkah bahasa & tema dengan nilai bawaan', () {
    expect(vm.step, OnboardingStep.languageTheme);
    expect(vm.stepNumber, 1);
    expect(vm.value(SetupField.deviceCode), 'K01');
    expect(vm.value(SetupField.timezone), 'Asia/Jakarta');
    expect(vm.businessType, BusinessKind.retail);
  });

  test('langkah dengan galat tidak bisa dilewati dan galat ditampilkan', () {
    vm.next();
    expect(vm.step, OnboardingStep.business);
    expect(vm.errorFor(SetupField.businessName), isNull);

    vm.next();
    expect(vm.step, OnboardingStep.business);
    expect(vm.errorFor(SetupField.businessName), SetupError.required);
    expect(vm.errorFor(SetupField.outletCode), SetupError.invalidCode);
    // Galat langkah lain belum ditampilkan.
    expect(vm.errorFor(SetupField.email), isNull);
  });

  test('galat hilang saat field diperbaiki', () {
    vm
      ..next()
      ..next();
    vm.setField(SetupField.businessName, 'Warung Contoh');
    expect(vm.errorFor(SetupField.businessName), isNull);
  });

  test('pratinjau nomor nota mengikuti kode yang diketik', () {
    expect(vm.receiptPreview, 'PST-K01-261103-0001');
    vm.setField(SetupField.outletCode, 'bdg');
    vm.setField(SetupField.deviceCode, 't01');
    expect(vm.receiptPreview, 'BDG-T01-261103-0001');
  });

  test('tanggal pratinjau nota mengikuti zona waktu yang dipilih', () {
    final late = OnboardingViewModel(
      repository: repository,
      session: session,
      now: () => DateTime.utc(2026, 11, 3, 16, 30),
    );
    // 23.30 WIB masih tanggal 3; 01.30 WIT sudah tanggal 4.
    expect(late.receiptPreview, 'PST-K01-261103-0001');
    late.setField(SetupField.timezone, 'Asia/Jayapura');
    expect(late.receiptPreview, 'PST-K01-261104-0001');
  });

  test('kembali dari ringkasan menghapus galat setup sebelumnya', () async {
    repository.failSetup = true;
    vm.next();
    fillBusiness(vm);
    vm.next();
    fillOwner(vm);
    vm.next();
    fillProduct(vm);
    await vm.finish.execute();
    expect(vm.finish.error, isTrue);
    vm.back();
    expect(vm.finish.error, isFalse);
  });

  test('alur lengkap sampai ringkasan lalu setup sekali', () async {
    vm.next();
    fillBusiness(vm);
    vm.next();
    expect(vm.step, OnboardingStep.owner);
    fillOwner(vm);
    vm.next();
    expect(vm.step, OnboardingStep.summary);
    expect(vm.stepNumber, 4);
    fillProduct(vm);

    await vm.finish.execute();
    expect(vm.finish.completed, isTrue);
    expect(repository.setupCalls, hasLength(1));
    final input = repository.setupCalls.single;
    expect(input.businessType, BusinessKind.fnb);
    expect(input.outletCode, 'PST');
    expect(input.pin, '123456');
    expect(repository.current, isNotNull);
    // Pemilik langsung bertugas tanpa mengetik PIN.
    expect(session.current?.isOwner, isTrue);
  });

  test('kembali ke langkah sebelumnya tanpa kehilangan isian', () {
    vm.next();
    fillBusiness(vm);
    vm.next();
    vm.back();
    expect(vm.step, OnboardingStep.business);
    expect(vm.value(SetupField.businessName), 'Warung Contoh');
  });

  test('setup gagal: perintah berstatus galat dan bisa dicoba lagi', () async {
    repository.failSetup = true;
    vm.next();
    fillBusiness(vm);
    vm.next();
    fillOwner(vm);
    vm.next();
    fillProduct(vm);
    await vm.finish.execute();
    expect(vm.finish.error, isTrue);
    expect(session.current, isNull);
    repository.failSetup = false;
    await vm.finish.execute();
    expect(vm.finish.completed, isTrue);
  });

  group('produk pertama (F1-01b)', () {
    Future<void> toStep4({BusinessKind kind = BusinessKind.retail}) async {
      vm.next();
      fillBusiness(vm);
      vm
        ..setBusinessType(kind)
        ..next();
      fillOwner(vm);
      vm.next();
    }

    test('bawaan tambah produk; isian kosong memblokir setup', () async {
      await toStep4();
      expect(vm.firstProductChoice, FirstProductChoice.add);
      expect(vm.productError(ProductField.name), isNull);
      await vm.finish.execute();
      expect(vm.finish.error, isTrue);
      expect(repository.setupCalls, isEmpty);
      expect(vm.productError(ProductField.name), ProductError.required);
      expect(vm.productError(ProductField.sellPrice), ProductError.required);
      // Galat hilang setelah diperbaiki.
      fillProduct(vm);
      expect(vm.productError(ProductField.name), isNull);
      expect(vm.productError(ProductField.sellPrice), isNull);
      vm.setProductSellPrice(Money.zero);
      expect(vm.productError(ProductField.sellPrice), ProductError.notPositive);
    });

    test(
      'retail: barang dengan satuan, barcode, harga beli, stok awal',
      () async {
        await toStep4();
        expect(vm.productUnit, 'pcs');
        expect(vm.productTracksStock, isTrue);
        fillProduct(vm);
        vm
          ..setProductCostPrice(const Money(9000))
          ..setProductUnit('gelas')
          ..setProductBarcode(' 899100 ')
          ..setProductOpeningStock(Qty.units(24));
        await vm.finish.execute();
        expect(vm.finish.completed, isTrue);
        final draft = repository.setupProducts.single!;
        expect(draft.name, 'Kopi Susu');
        expect(draft.kind, ProductKind.goods);
        expect(draft.baseUnit, 'gelas');
        final v = draft.variants.single;
        expect(v.sellPrice, const Money(15000));
        expect(v.costPrice, const Money(9000));
        expect(v.barcode, '899100');
        expect(v.openingStock, Qty.units(24));
        expect(vm.opensImport, isFalse);
      },
    );

    test('F&B: menu satuan porsi tanpa stok awal', () async {
      await toStep4(kind: BusinessKind.fnb);
      expect(vm.productUnit, 'porsi');
      expect(vm.productTracksStock, isFalse);
      fillProduct(vm);
      vm.setProductOpeningStock(Qty.units(5));
      await vm.finish.execute();
      final draft = repository.setupProducts.single!;
      expect(draft.kind, ProductKind.menu);
      expect(draft.variants.single.openingStock, Qty.zero);
    });

    test('lewati dan import tidak mengirim produk; isian bertahan', () async {
      await toStep4();
      vm.setProductName('Kopi Susu');
      vm.setFirstProductChoice(FirstProductChoice.skip);
      expect(vm.opensImport, isFalse);
      vm.setFirstProductChoice(FirstProductChoice.import);
      expect(vm.opensImport, isTrue);
      vm.back();
      vm.next();
      expect(vm.firstProductChoice, FirstProductChoice.import);
      expect(vm.productName, 'Kopi Susu');
      await vm.finish.execute();
      expect(vm.finish.completed, isTrue);
      expect(repository.setupProducts.single, isNull);
    });
  });
}
