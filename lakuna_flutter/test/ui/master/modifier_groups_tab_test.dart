import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_master_data_repository.dart';
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

/// FSwitch/FCheckbox diketuk lewat labelnya.
Future<void> _toggle(WidgetTester tester, String key, String label) async {
  final target = find.descendant(of: _key(key), matching: find.text(label));
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String key, String text) async {
  await tester.ensureVisible(_input(key));
  await tester.enterText(_input(key), text);
  await tester.pumpAndSettle();
}

void main() {
  Future<FakeMasterDataRepository> pump(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
  }) async {
    final repo = FakeMasterDataRepository();
    await pumpLakuna(
      tester,
      size: size,
      initialLocation: Routes.master,
      masterData: repo,
      stock: FakeStockRepository(),
      session: FakeSessionRepository()..current = sampleStaff(),
    );
    await _tap(
      tester,
      size.width < 900 ? 'master-pill-modifiers' : 'master-tab-modifiers',
    );
    return repo;
  }

  testWidgets('daftar grup dengan aturan, opsi, dan jumlah menu', (
    tester,
  ) async {
    await pump(tester);
    expect(_key('modifier-group-Ukuran'), findsOneWidget);
    expect(
      find.text('Wajib · pilih 1 · 2 opsi · dipakai 1 menu'),
      findsOneWidget,
    );
    expect(
      find.text('Opsional · maks 2 · 2 opsi · belum dipakai menu'),
      findsOneWidget,
    );
    expect(find.text('Boba +Rp 5.000, Keju +Rp 6.000 (Habis)'), findsOneWidget);
  });

  testWidgets('buat grup: galat ditandai, potongan negatif, simpan', (
    tester,
  ) async {
    final repo = await pump(tester);
    await _tap(tester, 'modifier-add');
    await _type(tester, 'modifier-name', 'ukuran');
    await _tap(tester, 'modifier-save');
    expect(find.text('Nama grup sudah dipakai.'), findsOneWidget);
    expect(find.text('Nama opsi wajib diisi.'), findsOneWidget);
    expect(repo.modifierGroupsData, hasLength(2));

    await _type(tester, 'modifier-name', 'Nasi');
    await _toggle(tester, 'modifier-required', 'Wajib dipilih');
    await _type(tester, 'modifier-max', '2');
    await _type(tester, 'modifier-option-name-0', 'Tanpa nasi');
    await _type(tester, 'modifier-option-price-0', '-3000');
    expect(find.text('-3.000'), findsOneWidget);
    await _tap(tester, 'modifier-option-add');
    await _type(tester, 'modifier-option-name-1', 'Nasi merah');
    await _type(tester, 'modifier-option-price-1', '2000');
    await _toggle(tester, 'modifier-option-available-1', 'Tersedia');
    await _tap(tester, 'modifier-save');

    expect(_key('modifier-dialog'), findsNothing);
    final nasi = repo.modifierGroupsData.last;
    expect(nasi.name, 'Nasi');
    expect(nasi.group.minSelect, 0);
    expect(nasi.group.maxSelect, 2);
    expect(nasi.options.map((o) => (o.name, o.priceDelta, o.isAvailable)), [
      ('Tanpa nasi', -3000, true),
      ('Nasi merah', 2000, false),
    ]);
    expect(
      find.text('Opsional · maks 2 · 2 opsi · belum dipakai menu'),
      findsNWidgets(2),
    );
  });

  testWidgets('ubah, urut, hapus; grup dipakai menu ditolak', (tester) async {
    final repo = await pump(tester);
    await _tap(tester, 'modifier-edit-Topping');
    await _type(tester, 'modifier-name', 'Ekstra');
    await _tap(tester, 'modifier-option-remove-1');
    await _tap(tester, 'modifier-save');
    expect(repo.modifierGroupsData.last.name, 'Ekstra');
    expect(repo.modifierGroupsData.last.options.map((o) => o.name), ['Boba']);

    await _tap(tester, 'modifier-up-Ekstra');
    expect(repo.modifierGroupsData.map((g) => g.name), ['Ekstra', 'Ukuran']);

    await _tap(tester, 'modifier-delete-Ukuran');
    await _tap(tester, 'modifier-confirm-delete');
    expect(
      find.text('Grup masih dipasang di 1 menu. Lepas dulu dari form menu.'),
      findsOneWidget,
    );
    await _tap(tester, 'modifier-delete-Ekstra');
    await _tap(tester, 'modifier-confirm-delete');
    expect(repo.modifierGroupsData.map((g) => g.name), ['Ukuran']);
  });

  testWidgets('ponsel 360 px tanpa overflow', (tester) async {
    await pump(tester, size: const Size(360, 740));
    expect(_key('modifier-group-Topping'), findsOneWidget);
    await _tap(tester, 'modifier-edit-Ukuran');
    expect(_key('modifier-option-name-1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
