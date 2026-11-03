import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/ui/onboarding/onboarding_view_model.dart';

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
    ..setField(SetupField.pin, '123456')
    ..setField(SetupField.pinConfirm, '123456');
}

void main() {
  late FakeStoreRepository repository;
  late OnboardingViewModel vm;

  setUp(() {
    repository = FakeStoreRepository();
    vm = OnboardingViewModel(
      repository: repository,
      today: () => DateTime(2026, 11, 3),
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

  test('alur lengkap sampai ringkasan lalu setup sekali', () async {
    vm.next();
    fillBusiness(vm);
    vm.next();
    expect(vm.step, OnboardingStep.owner);
    fillOwner(vm);
    vm.next();
    expect(vm.step, OnboardingStep.summary);
    expect(vm.stepNumber, 4);

    await vm.finish.execute();
    expect(vm.finish.completed, isTrue);
    expect(repository.setupCalls, hasLength(1));
    final input = repository.setupCalls.single;
    expect(input.businessType, BusinessKind.fnb);
    expect(input.outletCode, 'PST');
    expect(input.pin, '123456');
    expect(repository.current, isNotNull);
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
    await vm.finish.execute();
    expect(vm.finish.error, isTrue);
    repository.failSetup = false;
    await vm.finish.execute();
    expect(vm.finish.completed, isTrue);
  });
}
