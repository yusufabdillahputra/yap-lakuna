import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_flutter/data/repositories/app_settings_repository.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../testing/app_harness.dart';
import '../testing/fake_app_settings_repository.dart';

void main() {
  testWidgets('mengganti bahasa ke English menyimpan dan menerjemahkan UI', (
    tester,
  ) async {
    final repo = FakeAppSettingsRepository();
    await pumpLakuna(
      tester,
      repository: repo,
      initialLocation: Routes.settings,
    );
    await tester.tap(find.byKey(const ValueKey('settings-section-appearance')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('locale-en')));
    await tester.pumpAndSettle();
    expect(repo.storedLocale, const Locale('en'));
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Offline · data on this device'), findsOneWidget);
  });

  testWidgets('memilih tema gelap mengubah tema Forui dan tersimpan', (
    tester,
  ) async {
    final repo = FakeAppSettingsRepository(storedTheme: AppThemeMode.light);
    await pumpLakuna(
      tester,
      repository: repo,
      initialLocation: Routes.settings,
    );
    await tester.tap(find.byKey(const ValueKey('settings-section-appearance')));
    await tester.pumpAndSettle();
    BuildContext ctx() =>
        tester.element(find.byKey(const ValueKey('theme-dark')));
    expect(ctx().theme.colors.brightness, Brightness.light);
    await tester.tap(find.byKey(const ValueKey('theme-dark')));
    await tester.pumpAndSettle();
    expect(repo.storedTheme, AppThemeMode.dark);
    expect(ctx().theme.colors.brightness, Brightness.dark);
  });

  testWidgets('gagal menyimpan menampilkan pesan dan mengembalikan pilihan', (
    tester,
  ) async {
    final repo = FakeAppSettingsRepository(
      storedTheme: AppThemeMode.light,
      failWrites: true,
    );
    await pumpLakuna(
      tester,
      repository: repo,
      initialLocation: Routes.settings,
    );
    await tester.tap(find.byKey(const ValueKey('settings-section-appearance')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('theme-dark')));
    await tester.pumpAndSettle();
    expect(find.text('Pengaturan gagal disimpan. Coba lagi.'), findsOneWidget);
    final ctx = tester.element(find.byKey(const ValueKey('theme-dark')));
    expect(ctx.theme.colors.brightness, Brightness.light);
  });
}
