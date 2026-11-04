import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart' show Permission;
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_customers_repository.dart';
import '../../testing/fake_session_repository.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

Finder _input(String key) =>
    find.descendant(of: _key(key), matching: find.byType(EditableText));

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key));
  await tester.pumpAndSettle();
  await tester.tap(_key(key));
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String key, String text) async {
  await tester.enterText(_input(key), text);
  await tester.pumpAndSettle();
}

void main() {
  for (final size in const [Size(1280, 800), Size(360, 740)]) {
    testWidgets('${size.width.toInt()} px: tambah, ubah, hapus grup', (
      tester,
    ) async {
      final repo = FakeCustomersRepository();
      await pumpLakuna(
        tester,
        size: size,
        initialLocation: Routes.master,
        customers: repo,
      );
      await _tap(
        tester,
        size.width < 600
            ? 'master-pill-customerGroups'
            : 'master-tab-customerGroups',
      );
      final grosir = repo.groupList.firstWhere((g) => g.name == 'Grosir');
      expect(_key('customer-group-${grosir.id.uuid}'), findsOneWidget);

      // Nama ganda ditolak.
      await _tap(tester, 'customer-groups-new');
      await _type(tester, 'customer-group-name', 'grosir');
      await _type(tester, 'customer-group-term', '30');
      await _tap(tester, 'customer-group-save');
      expect(_key('customer-group-error'), findsOneWidget);
      await _type(tester, 'customer-group-name', 'Reseller');
      await _tap(tester, 'customer-group-save');
      expect(_key('customer-group-form'), findsNothing);
      final reseller = repo.groupList.firstWhere((g) => g.name == 'Reseller');
      expect(reseller.termDays, 30);

      await _tap(tester, 'customer-group-edit-${reseller.id.uuid}');
      await _type(tester, 'customer-group-term', '21');
      await _tap(tester, 'customer-group-save');
      expect(
        repo.groupList.firstWhere((g) => g.name == 'Reseller').termDays,
        21,
      );

      // Grup terpakai tidak bisa dihapus; grup kosong bisa.
      await _tap(tester, 'customer-group-delete-${grosir.id.uuid}');
      expect(_key('customer-group-delete-error'), findsOneWidget);
      await _tap(tester, 'customer-group-delete-${reseller.id.uuid}');
      expect(repo.groupList.any((g) => g.name == 'Reseller'), isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tanpa customers:manage tab grup tidak tampil', (tester) async {
    await pumpLakuna(
      tester,
      initialLocation: Routes.master,
      customers: FakeCustomersRepository(canManage: false),
      session: FakeSessionRepository()
        ..current = staffWithPermissions({Permission.productsManage}),
    );
    expect(_key('master-tab-units'), findsOneWidget);
    expect(_key('master-tab-customerGroups'), findsNothing);
  });
}
