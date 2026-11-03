import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_dining_admin_repository.dart';
import '../../testing/fake_session_repository.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

/// Kolom tarif memakai kunci `<nama>-<revisi>`.
Finder _rateInput(String name) => find.descendant(
  of: find.byWidgetPredicate(
    (w) => switch (w.key) {
      ValueKey<String>(:final value) => value.startsWith('fnb-rates-$name-'),
      _ => false,
    },
  ),
  matching: find.byType(EditableText),
);

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key));
  await tester.pumpAndSettle();
  await tester.tap(_key(key));
  await tester.pumpAndSettle();
}

Finder _previewText(String text) =>
    find.descendant(of: _key('fnb-rates-preview'), matching: find.text(text));

void main() {
  Future<FakeDiningAdminRepository> pump(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
  }) async {
    final repo = FakeDiningAdminRepository();
    await pumpLakuna(
      tester,
      size: size,
      initialLocation: Routes.settings,
      diningAdmin: repo,
    );
    await _tap(tester, 'settings-section-taxes');
    return repo;
  }

  testWidgets('pajak & service: pratinjau, galat, simpan', (tester) async {
    final repo = await pump(tester);
    expect(find.text('Pajak & service'), findsWidgets);
    expect(_previewText('Rp 100.000'), findsWidgets);
    final save = tester.widget<FButton>(_key('fnb-rates-save'));
    expect(save.onPress, isNull);

    await tester.enterText(_rateInput('service'), '5');
    await tester.enterText(_rateInput('tax'), '10');
    await tester.pumpAndSettle();
    expect(_previewText('Service 5% (dine in)'), findsOneWidget);
    expect(_previewText('Rp 5.000'), findsOneWidget);
    expect(_previewText('PB1 10%'), findsOneWidget);
    expect(_previewText('Rp 10.500'), findsOneWidget);
    expect(_previewText('Rp 115.500'), findsOneWidget);

    await tester.enterText(_rateInput('service'), '35');
    await tester.pumpAndSettle();
    expect(find.text('Isi 0–30 dengan kelipatan 0,5.'), findsOneWidget);
    expect(tester.widget<FButton>(_key('fnb-rates-save')).onPress, isNull);

    await tester.enterText(_rateInput('service'), '7,5');
    await tester.pumpAndSettle();
    await _tap(tester, 'fnb-rates-save');
    expect(repo.savedRates.service.value, 750);
    expect(repo.savedRates.tax.value, 1000);
    expect(_key('fnb-rates-saved'), findsOneWidget);
    expect(_previewText('Service 7,5% (dine in)'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('pajak & service di ponsel tanpa overflow', (tester) async {
    await pump(tester, size: const Size(360, 740));
    expect(_key('fnb-rates-preview'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('kasir tidak melihat bagian pajak & service', (tester) async {
    await pumpLakuna(
      tester,
      initialLocation: Routes.settings,
      session: FakeSessionRepository()..current = sampleStaff(role: 'cashier'),
    );
    expect(_key('settings-section-taxes'), findsNothing);
  });
}
