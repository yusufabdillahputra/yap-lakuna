import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/config/app_platform.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../testing/app_harness.dart';
import '../testing/fake_backup_repository.dart';

Finder _inSidebar(String label) => find.descendant(
  of: find.byKey(const ValueKey('sidebar')),
  matching: find.text(label),
);

void main() {
  const web = AppPlatform(isWeb: true);

  testWidgets('web: menu tanpa Kasir, Meja, Sesi kasir (F2-02 aturan 3)', (
    tester,
  ) async {
    await pumpLakuna(tester, platform: web);
    expect(_inSidebar('Beranda'), findsOneWidget);
    expect(_inSidebar('Riwayat'), findsOneWidget);
    for (final label in ['Kasir', 'Meja', 'Sesi kasir']) {
      expect(_inSidebar(label), findsNothing, reason: label);
    }
  });

  testWidgets('web mobile: navigasi bawah tanpa Kasir', (tester) async {
    await pumpLakuna(tester, platform: web, size: const Size(390, 844));
    expect(find.byKey(const ValueKey('nav-cashier')), findsNothing);
    expect(find.byKey(const ValueKey('nav-products')), findsOneWidget);
  });

  for (final path in [
    Routes.cashier,
    Routes.tables,
    Routes.tablesFloor(),
    Routes.cashSession,
    Routes.login,
  ]) {
    testWidgets('web: $path dialihkan ke Beranda', (tester) async {
      await pumpLakuna(tester, platform: web, initialLocation: path);
      expect(find.byKey(const ValueKey('home-greeting')), findsOneWidget);
    });
  }

  testWidgets('web: Pengaturan tanpa Data & backup', (tester) async {
    await pumpLakuna(
      tester,
      platform: web,
      initialLocation: Routes.settings,
      backup: FakeBackupRepository(last: DateTime.now().toUtc()),
    );
    expect(find.text('Data & backup'), findsNothing);
  });

  testWidgets('native: Kasir dan Data & backup tetap ada', (tester) async {
    await pumpLakuna(tester, initialLocation: Routes.settings);
    expect(find.text('Data & backup'), findsWidgets);
    expect(_inSidebar('Kasir'), findsOneWidget);
  });
}
