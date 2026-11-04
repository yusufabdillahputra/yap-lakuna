import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_session_repository.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key).last);
  await tester.pumpAndSettle();
  await tester.tap(_key(key).last);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    // ignore: invalid_use_of_visible_for_testing_member
    LicenseRegistry.reset();
    LicenseRegistry.addLicense(
      () => Stream.fromIterable(const [
        LicenseEntryWithLineBreaks(['forui'], 'MIT License\n\nForui.'),
        LicenseEntryWithLineBreaks(['Montserrat'], 'SIL OPEN FONT LICENSE'),
      ]),
    );
  });

  for (final size in [const Size(1440, 900), const Size(360, 740)]) {
    testWidgets('Tentang Lakuna untuk kasir di ${size.width.toInt()} px', (
      tester,
    ) async {
      await pumpLakuna(
        tester,
        size: size,
        initialLocation: Routes.settings,
        session: FakeSessionRepository(
          current: sampleStaff(name: 'Dimas', role: 'cashier'),
        ),
      );
      await _tap(tester, 'settings-section-about');
      expect(_key('about-section'), findsOneWidget);
      expect(find.text('Versi 0.1.0'), findsOneWidget);
      expect(find.text('Privasi data'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'about');

      await _tap(tester, 'about-licenses-show');
      expect(_key('about-license-forui'), findsOneWidget);
      expect(_key('about-license-Montserrat'), findsOneWidget);
      expect(find.text('Forui.'), findsNothing);
      await _tap(tester, 'about-license-forui');
      expect(find.textContaining('Forui.'), findsOneWidget);
      await _tap(tester, 'about-license-forui');
      expect(find.textContaining('Forui.'), findsNothing);
      expect(tester.takeException(), isNull, reason: 'licenses');

      await _tap(tester, 'about-guide');
      expect(_key('guide-screen'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('bagian dari rute: ?bagian=about', (tester) async {
    await pumpLakuna(
      tester,
      initialLocation: '${Routes.settings}?bagian=about',
    );
    expect(_key('about-section'), findsOneWidget);
  });
}
