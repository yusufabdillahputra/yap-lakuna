import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/app_settings_repository.dart';
import 'package:lakuna_flutter/routing/routes.dart';
import 'package:lakuna_flutter/ui/settings/store_settings_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_app_settings_repository.dart';
import '../../testing/fake_store_settings_repository.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

Finder _input(String prefix) => find.descendant(
  of: find.byWidgetPredicate(
    (w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('$prefix-'),
  ),
  matching: find.byType(EditableText),
);

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key).last);
  await tester.pumpAndSettle();
  await tester.tap(_key(key).last);
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String prefix, String text) async {
  await tester.ensureVisible(_input(prefix));
  await tester.enterText(_input(prefix), text);
  await tester.pumpAndSettle();
}

void main() {
  group('StoreSettingsViewModel', () {
    test('muat, galat isian, simpan', () async {
      final repo = FakeStoreSettingsRepository();
      final vm = StoreSettingsViewModel(repository: repo);
      await vm.load.execute();
      expect(vm.businessName, 'Warung Contoh');
      expect(vm.businessDirty, isFalse);

      vm.setBusinessName('  ');
      await vm.saveBusiness.execute();
      expect(vm.businessIssue, ProfileIssue.required);
      expect(repo.calls, isEmpty);
      vm.setBusinessName('Toko Bu Ani');
      await vm.saveBusiness.execute();
      expect(vm.saveBusiness.completed, isTrue);
      expect(vm.profile!.businessName, 'Toko Bu Ani');
      expect(vm.businessDirty, isFalse);

      vm.setPhone('telp');
      await vm.saveOutlet.execute();
      expect(
        vm.outletIssues[OutletProfileField.phone],
        ProfileIssue.invalidPhone,
      );
      vm.setPhone('021 555');
      await vm.saveOutlet.execute();
      expect(repo.calls.last, 'outlet:Cabang Pusat:Jl. Melati 1:021 555');

      expect(vm.rulesDirty, isFalse);
      vm.setRounding(TotalRounding.nearest500);
      vm.setAllowNegativeStock(false);
      expect(vm.rulesDirty, isTrue);
      await vm.saveRules.execute();
      expect(repo.calls.last, 'rules:false:nearest500');
      expect(vm.rulesDirty, isFalse);
    });

    test('simpan satu bagian tidak menimpa isian bagian lain', () async {
      final repo = FakeStoreSettingsRepository();
      final vm = StoreSettingsViewModel(repository: repo);
      await vm.load.execute();
      vm.setAddress('Jl. Kenanga 2');
      vm.setBusinessName('Toko Bu Ani');
      await vm.saveBusiness.execute();
      expect(vm.address, 'Jl. Kenanga 2');
      expect(vm.outletDirty, isTrue);
      vm.setBusinessName('Toko Bu Ani Baru');
      await vm.saveOutlet.execute();
      expect(vm.businessName, 'Toko Bu Ani Baru');
      expect(vm.businessDirty, isTrue);
      expect(vm.outletDirty, isFalse);
    });

    test('gagal simpan tetap kotor', () async {
      final repo = FakeStoreSettingsRepository(failSave: true);
      final vm = StoreSettingsViewModel(repository: repo);
      await vm.load.execute();
      vm.setRounding(TotalRounding.nearest100);
      await vm.saveRules.execute();
      expect(vm.saveRules.result, isA<Error<SalesRules>>());
      expect(vm.rulesDirty, isTrue);
    });
  });

  testWidgets('1440: profil toko, cabang, penjualan & stok', (tester) async {
    final repo = FakeStoreSettingsRepository();
    await pumpLakuna(
      tester,
      size: const Size(1440, 900),
      initialLocation: Routes.settings,
      storeSettings: repo,
    );
    // Bagian pertama untuk pemilik: Profil toko.
    expect(_key('store-business-save'), findsOneWidget);
    expect(find.textContaining('WIB'), findsOneWidget);
    await _type(tester, 'store-business-name', 'Toko Bu Ani');
    await _tap(tester, 'store-business-save');
    expect(_key('store-business-saved'), findsOneWidget);
    expect(repo.calls, ['business:Toko Bu Ani']);

    await _tap(tester, 'settings-section-outlet');
    expect(find.text('PST'), findsOneWidget);
    expect(find.text('K01'), findsOneWidget);
    await _type(tester, 'store-outlet-phone', '0812 99');
    await _tap(tester, 'store-outlet-save');
    expect(_key('store-outlet-saved'), findsOneWidget);
    expect(repo.calls.last, 'outlet:Cabang Pusat:Jl. Melati 1:0812 99');

    await _tap(tester, 'settings-section-rules');
    expect(_key('store-rules-session'), findsOneWidget);
    final negative = find.descendant(
      of: _key('store-rules-negative'),
      matching: find.text('Izinkan stok minus'),
    );
    await tester.ensureVisible(negative);
    await tester.tap(negative);
    await tester.pumpAndSettle();
    final pin = find.descendant(
      of: _key('store-rules-discount-pin'),
      matching: find.text('Diskon manual butuh PIN manajer'),
    );
    await tester.ensureVisible(pin);
    await tester.tap(pin);
    await tester.pumpAndSettle();
    await _tap(tester, 'store-rules-rounding-nearest100');
    await _tap(tester, 'store-rules-save');
    expect(_key('store-rules-saved'), findsOneWidget);
    expect(repo.calls.last, 'rules:false:nearest100');
    expect(repo.rules.discountNeedsPin, isFalse);
  });

  testWidgets('360: pil bagian dan ukuran tampilan Besar', (tester) async {
    final settings = FakeAppSettingsRepository();
    final vm = await pumpLakuna(
      tester,
      size: const Size(360, 780),
      initialLocation: Routes.settings,
      repository: settings,
    );
    expect(_key('store-business-save'), findsOneWidget);
    await _tap(tester, 'settings-section-appearance');
    await _tap(tester, 'text-size-large');
    expect(settings.storedTextSize, AppTextSize.large);
    expect(vm.textSize, AppTextSize.large);
    final context = tester.element(_key('text-size-large'));
    expect(MediaQuery.textScalerOf(context).scale(10), closeTo(11.5, 0.01));
    expect(tester.takeException(), isNull);
  });
}
