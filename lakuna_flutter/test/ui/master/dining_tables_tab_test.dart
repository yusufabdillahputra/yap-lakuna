import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_dining_admin_repository.dart';
import '../../testing/fake_session_repository.dart';
import '../../testing/fake_stock_repository.dart';

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
  Future<FakeDiningAdminRepository> pump(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
    String role = 'owner',
  }) async {
    final repo = FakeDiningAdminRepository();
    await pumpLakuna(
      tester,
      size: size,
      initialLocation: Routes.master,
      diningAdmin: repo,
      stock: FakeStockRepository(),
      session: FakeSessionRepository()..current = sampleStaff(role: role),
    );
    return repo;
  }

  testWidgets('area: tambah, kembar ditolak, ubah, urut, hapus', (
    tester,
  ) async {
    final repo = await pump(tester);
    await _tap(tester, 'master-tab-tables');
    expect(_key('dining-setup-area-Indoor'), findsOneWidget);
    expect(find.text('2 meja'), findsOneWidget);

    await _tap(tester, 'dining-setup-area-add');
    await _type(tester, 'dining-setup-area-name', ' teras ');
    await _tap(tester, 'dining-setup-area-save');
    expect(find.text('Nama sudah dipakai.'), findsOneWidget);
    expect(repo.areas, hasLength(2));

    await _tap(tester, 'dining-setup-area-add');
    await _type(tester, 'dining-setup-area-name', 'Lantai 2');
    await _tap(tester, 'dining-setup-area-save');
    expect(repo.areas.map((a) => a.name), ['Indoor', 'Teras', 'Lantai 2']);
    expect(_key('dining-setup-error'), findsNothing);

    await _tap(tester, 'dining-setup-area-edit-Lantai 2');
    await _type(tester, 'dining-setup-area-name', 'Rooftop');
    await _tap(tester, 'dining-setup-area-save');
    await _tap(tester, 'dining-setup-area-up-Rooftop');
    expect(repo.areas.map((a) => a.name), ['Indoor', 'Rooftop', 'Teras']);

    // Area berisi meja tidak bisa dihapus.
    await _tap(tester, 'dining-setup-area-delete-Indoor');
    await _tap(tester, 'dining-setup-confirm-delete');
    expect(
      find.text(
        'Area masih punya 2 meja. Pindahkan atau hapus mejanya dulu.',
      ),
      findsOneWidget,
    );
    await _tap(tester, 'dining-setup-area-delete-Rooftop');
    await _tap(tester, 'dining-setup-confirm-delete');
    expect(repo.areas.map((a) => a.name), ['Indoor', 'Teras']);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('meja: tambah, rentang, sibuk ditolak, ubah kursi', (
    tester,
  ) async {
    final repo = await pump(tester);
    await _tap(tester, 'master-tab-tables');

    await _tap(tester, 'dining-setup-table-add');
    await _type(tester, 'dining-setup-table-name', 'M3');
    await _type(tester, 'dining-setup-table-seats', '0');
    await _tap(tester, 'dining-setup-table-save');
    expect(find.text('Kursi 1–99.'), findsOneWidget);
    await _type(tester, 'dining-setup-table-seats', '6');
    await _tap(tester, 'dining-setup-table-save');
    expect(repo.tables.last.name, 'M3');
    expect(repo.tables.last.seats, 6);
    expect(repo.tables.last.diningAreaId, isNull);
    expect(find.text('Tanpa area · 6 kursi'), findsOneWidget);

    await _tap(tester, 'dining-setup-table-range');
    await _type(tester, 'dining-setup-range-from', '5');
    await _type(tester, 'dining-setup-range-to', '2');
    expect(
      find.text('Rentang tidak sah (1–50 meja sekaligus).'),
      findsOneWidget,
    );
    await _type(tester, 'dining-setup-range-to', '7');
    expect(find.text('Akan dibuat: M5, M6, M7'), findsOneWidget);
    await _tap(tester, 'dining-setup-range-save');
    expect(repo.tables.map((t) => t.name), [
      'M1',
      'M2',
      'T1',
      'M3',
      'M5',
      'M6',
      'M7',
    ]);

    // Rentang yang bentrok dengan meja yang ada ditolak seluruhnya.
    await _tap(tester, 'dining-setup-table-range');
    await _type(tester, 'dining-setup-range-from', '7');
    await _type(tester, 'dining-setup-range-to', '8');
    await _tap(tester, 'dining-setup-range-save');
    expect(find.text('Nama M7 sudah dipakai.'), findsOneWidget);
    expect(repo.tables, hasLength(7));

    repo.busyTables.add(repo.tables.first.id);
    await _tap(tester, 'dining-setup-table-delete-M1');
    await _tap(tester, 'dining-setup-confirm-delete');
    expect(find.text('Meja masih punya bill terbuka.'), findsOneWidget);

    await _tap(tester, 'dining-setup-table-edit-M2');
    await _type(tester, 'dining-setup-table-seats', '2');
    await _tap(tester, 'dining-setup-table-save');
    expect(repo.tables[1].seats, 2);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('ponsel: tab Meja & area tanpa overflow', (tester) async {
    await pump(tester, size: const Size(360, 740));
    await _tap(tester, 'master-pill-tables');
    expect(_key('dining-setup-area-Teras'), findsOneWidget);
    await _tap(tester, 'dining-setup-table-range');
    expect(_key('dining-setup-range-preview'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
