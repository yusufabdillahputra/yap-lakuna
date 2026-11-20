import 'dart:ui' show AppExitResponse;

import 'package:flutter/services.dart';
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

  testWidgets('dialog grup yang berubah bertanya sebelum ditutup (F1-09b)', (
    tester,
  ) async {
    final repo = FakeCustomersRepository();
    await pumpLakuna(
      tester,
      size: const Size(1280, 800),
      initialLocation: Routes.master,
      customers: repo,
    );
    await _tap(tester, 'master-tab-customerGroups');
    final grosir = repo.groupList.firstWhere((g) => g.name == 'Grosir');
    await _tap(tester, 'customer-group-edit-${grosir.id.uuid}');
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(_key('customer-group-form'), findsNothing);

    await _tap(tester, 'customer-group-edit-${grosir.id.uuid}');
    await _type(tester, 'customer-group-term', '45');
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(_key('customer-group-discard'), findsOneWidget);
    expect(
      find.text(
        'Grup pelanggan yang sedang diisi belum disimpan dan akan hilang.',
      ),
      findsOneWidget,
    );
    await _tap(tester, 'customer-group-discard-cancel');
    expect(_key('customer-group-form'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_key('customer-group-discard'), findsOneWidget);
    await _tap(tester, 'customer-group-discard-cancel');

    // Tempo dikembalikan: tidak berubah lagi, Esc langsung menutup.
    await _type(tester, 'customer-group-term', '${grosir.termDays}');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_key('customer-group-discard'), findsNothing);
    expect(_key('customer-group-form'), findsNothing);

    await _tap(tester, 'customer-group-edit-${grosir.id.uuid}');
    await _type(tester, 'customer-group-term', '45');
    await _tap(tester, 'customer-group-cancel');
    await _tap(tester, 'customer-group-discard-confirm');
    expect(_key('customer-group-form'), findsNothing);
    expect(
      repo.groupList.firstWhere((g) => g.id == grosir.id).termDays,
      grosir.termDays,
    );
    expect(tester.takeException(), isNull);
  });

  group('Simpan dari dialog Buang perubahan? (F1-09c)', () {
    Future<FakeCustomersRepository> open(WidgetTester tester) async {
      final repo = FakeCustomersRepository();
      await pumpLakuna(
        tester,
        size: const Size(1280, 800),
        initialLocation: Routes.master,
        customers: repo,
      );
      await _tap(tester, 'master-tab-customerGroups');
      return repo;
    }

    testWidgets('Esc lalu Simpan: tersimpan dan tampil', (tester) async {
      final repo = await open(tester);
      await _tap(tester, 'customer-groups-new');
      await _type(tester, 'customer-group-name', 'Reseller');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await _tap(tester, 'customer-group-discard-save');
      expect(_key('customer-group-discard'), findsNothing);
      expect(_key('customer-group-form'), findsNothing);
      final reseller = repo.groupList.singleWhere((g) => g.name == 'Reseller');
      expect(_key('customer-group-${reseller.id.uuid}'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('isian salah atau nama ganda: tetap terbuka, aplikasi tidak '
        'ditutup', (tester) async {
      final repo = await open(tester);
      final before = repo.groupList.length;

      await _tap(tester, 'customer-groups-new');
      await _type(tester, 'customer-group-term', '45');
      final exit = tester.binding.handleRequestAppExit();
      await tester.pumpAndSettle();
      await _tap(tester, 'customer-group-discard-save');
      expect(await exit, AppExitResponse.cancel);
      expect(_key('customer-group-form'), findsOneWidget);
      expect(find.textContaining('Nama grup wajib diisi'), findsOneWidget);

      // Nama ganda ditolak penyimpanan: tetap dengan pesan.
      await _type(tester, 'customer-group-name', 'grosir');
      final again = tester.binding.handleRequestAppExit();
      await tester.pumpAndSettle();
      await _tap(tester, 'customer-group-discard-save');
      expect(await again, AppExitResponse.cancel);
      expect(_key('customer-group-form'), findsOneWidget);
      expect(_key('customer-group-error'), findsOneWidget);
      expect(repo.groupList, hasLength(before));
      expect(tester.takeException(), isNull);
    });

    testWidgets('tutup jendela lalu Simpan: tersimpan lalu keluar', (
      tester,
    ) async {
      final repo = await open(tester);
      final grosir = repo.groupList.firstWhere((g) => g.name == 'Grosir');
      await _tap(tester, 'customer-group-edit-${grosir.id.uuid}');
      await _type(tester, 'customer-group-term', '45');
      final exit = tester.binding.handleRequestAppExit();
      await tester.pumpAndSettle();
      await _tap(tester, 'customer-group-discard-save');
      expect(await exit, AppExitResponse.exit);
      expect(repo.groupList.firstWhere((g) => g.id == grosir.id).termDays, 45);
      expect(_key('customer-group-form'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
