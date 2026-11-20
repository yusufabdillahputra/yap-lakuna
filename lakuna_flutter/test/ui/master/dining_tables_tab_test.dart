import 'dart:async';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart' show DiningNameError;
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

Future<void> _esc(WidgetTester tester) async {
  await tester.sendKeyEvent(LogicalKeyboardKey.escape);
  await tester.pumpAndSettle();
}

/// Apakah isian [key] sedang berkursor (F1-10q).
bool _focused(WidgetTester tester, String key) =>
    tester.widget<EditableText>(_input(key)).focusNode.hasFocus;

Future<void> _choose(WidgetTester tester, String key, String label) async {
  await _tap(tester, key);
  await tester.tap(find.text(label).last);
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
    // Ditolak: dialog tetap terbuka (F1-10o), pesan di bawah Nama (F1-10p).
    expect(
      find.descendant(
        of: _key('dining-setup-area-name'),
        matching: find.text('Nama sudah dipakai.'),
      ),
      findsOneWidget,
    );
    expect(_key('dining-setup-dialog-error'), findsNothing);
    expect(_key('dining-setup-error'), findsNothing);
    expect(repo.areas, hasLength(2));

    await _type(tester, 'dining-setup-area-name', 'Lantai 2');
    expect(find.text('Nama sudah dipakai.'), findsNothing);
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

    // Rentang yang bentrok dengan meja yang ada ditolak seluruhnya; dialog
    // tetap terbuka dengan isian utuh (F1-10o).
    await _tap(tester, 'dining-setup-table-range');
    await _type(tester, 'dining-setup-range-from', '7');
    await _type(tester, 'dining-setup-range-to', '8');
    await _tap(tester, 'dining-setup-range-save');
    // Galat nama rentang menggantikan pratinjau (F1-10p).
    expect(
      find.descendant(
        of: _key('dining-setup-range-preview'),
        matchRoot: true,
        matching: find.text('Nama M7 sudah dipakai.'),
      ),
      findsOneWidget,
    );
    expect(_key('dining-setup-dialog-error'), findsNothing);
    expect(_key('dining-setup-error'), findsNothing);
    expect(repo.tables, hasLength(7));
    for (final (key, text) in [
      ('dining-setup-range-from', '7'),
      ('dining-setup-range-to', '8'),
    ]) {
      expect(
        find.descendant(of: _key(key), matching: find.text(text)),
        findsOneWidget,
      );
    }
    // Isian berubah: Esc tetap bertanya.
    await _esc(tester);
    expect(_key('dining-range-discard'), findsOneWidget);
    await _tap(tester, 'dining-range-discard-confirm');
    expect(_key('dining-setup-range-dialog'), findsNothing);
    expect(_key('dining-setup-error'), findsNothing);

    repo.busyTables.add(repo.tables.first.id);
    await _tap(tester, 'dining-setup-table-delete-M1');
    await _tap(tester, 'dining-setup-confirm-delete');
    expect(find.text('Meja masih punya bill terbuka.'), findsOneWidget);

    await _tap(tester, 'dining-setup-table-edit-M2');
    await _type(tester, 'dining-setup-table-seats', '2');
    // *Boleh digabung* (F1-10d) juga bisa diatur tanpa denah.
    expect(repo.tables[1].canMerge, isFalse);
    await _tap(tester, 'dining-setup-table-merge');
    await _tap(tester, 'dining-setup-table-save');
    expect(repo.tables[1].seats, 2);
    expect(repo.tables[1].canMerge, isTrue);
    expect(find.text('Indoor · 2 kursi · Boleh digabung'), findsOneWidget);
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

  testWidgets('dialog area yang berubah bertanya sebelum ditutup (F1-10n)', (
    tester,
  ) async {
    final repo = await pump(tester);
    await _tap(tester, 'master-tab-tables');
    // Tanpa perubahan: ketuk di luar menutup.
    await _tap(tester, 'dining-setup-area-add');
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(_key('dining-setup-area-dialog'), findsNothing);

    await _tap(tester, 'dining-setup-area-add');
    await _type(tester, 'dining-setup-area-name', 'Lantai 2');
    await _esc(tester);
    expect(_key('dining-area-discard'), findsOneWidget);
    expect(
      find.text('Area yang sedang diisi belum disimpan dan akan hilang.'),
      findsOneWidget,
    );
    await _tap(tester, 'dining-area-discard-cancel');
    expect(_key('dining-setup-area-dialog'), findsOneWidget);

    // Menu samping tertutup dialog: ketukannya ikut bertanya.
    await tester.tap(_key('nav-stock'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(_key('dining-area-discard'), findsOneWidget);
    await _tap(tester, 'dining-area-discard-confirm');
    expect(_key('dining-setup-area-dialog'), findsNothing);
    expect(repo.areas, hasLength(2));

    // Nama dikembalikan (spasi diabaikan): Batal langsung menutup.
    await _tap(tester, 'dining-setup-area-edit-Teras');
    await _type(tester, 'dining-setup-area-name', 'Teras ');
    await _tap(tester, 'dining-setup-area-cancel');
    expect(_key('dining-area-discard'), findsNothing);
    expect(_key('dining-setup-area-dialog'), findsNothing);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  // Setiap isian meja yang ikut disimpan membuat dialog bertanya (F1-10n).
  final tableChanges = <String, Future<void> Function(WidgetTester)>{
    'nama': (t) => _type(t, 'dining-setup-table-name', 'M9'),
    'kursi': (t) => _type(t, 'dining-setup-table-seats', '6'),
    'area': (t) => _choose(t, 'dining-setup-table-area', 'Teras'),
    'boleh digabung': (t) => _tap(t, 'dining-setup-table-merge'),
  };
  for (final MapEntry(key: what, value: change) in tableChanges.entries) {
    testWidgets('meja: ubah $what lalu Esc bertanya dulu (F1-10n)', (
      tester,
    ) async {
      final repo = await pump(tester);
      await _tap(tester, 'master-tab-tables');
      final before = [...repo.tables];
      await _tap(tester, 'dining-setup-table-edit-M1');
      await change(tester);
      await _esc(tester);
      expect(_key('dining-table-discard'), findsOneWidget);
      expect(
        find.text('Meja yang sedang diisi belum disimpan dan akan hilang.'),
        findsOneWidget,
      );
      await _tap(tester, 'dining-table-discard-confirm');
      expect(_key('dining-setup-table-dialog'), findsNothing);
      expect(repo.tables, orderedEquals(before));
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
  }

  testWidgets('meja: kursi dengan nol di depan bukan perubahan (F1-10n)', (
    tester,
  ) async {
    await pump(tester);
    await _tap(tester, 'master-tab-tables');
    await _tap(tester, 'dining-setup-table-add');
    await _type(tester, 'dining-setup-table-seats', '04');
    await _esc(tester);
    expect(_key('dining-table-discard'), findsNothing);
    expect(_key('dining-setup-table-dialog'), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('rentang meja yang berubah bertanya sebelum ditutup (F1-10n)', (
    tester,
  ) async {
    final repo = await pump(tester);
    await _tap(tester, 'master-tab-tables');
    // Nilai bawaan bukan perubahan.
    await _tap(tester, 'dining-setup-table-range');
    await _esc(tester);
    expect(_key('dining-setup-range-dialog'), findsNothing);

    await _tap(tester, 'dining-setup-table-range');
    await _type(tester, 'dining-setup-range-to', '30');
    await _tap(tester, 'dining-setup-range-cancel');
    expect(_key('dining-range-discard'), findsOneWidget);
    expect(
      find.text(
        'Rentang meja yang sedang diisi belum disimpan dan akan hilang.',
      ),
      findsOneWidget,
    );
    await _tap(tester, 'dining-range-discard-cancel');
    expect(_key('dining-setup-range-dialog'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(_key('dining-range-discard'), findsOneWidget);
    await _tap(tester, 'dining-range-discard-confirm');
    expect(_key('dining-setup-range-dialog'), findsNothing);
    expect(repo.tables, hasLength(3));

    // Area rentang juga dihitung.
    await _tap(tester, 'dining-setup-table-range');
    await _choose(tester, 'dining-setup-range-area', 'Teras');
    await _esc(tester);
    expect(_key('dining-range-discard'), findsOneWidget);
    await _tap(tester, 'dining-range-discard-confirm');
    expect(repo.tables, hasLength(3));
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  // Setiap isian rentang ikut dihitung; nilai bawaan M, 1–12, 4 kursi.
  final rangeChanges = <String, (String, String)>{
    'awalan': ('dining-setup-range-prefix', 'T'),
    'dari': ('dining-setup-range-from', '2'),
    'sampai': ('dining-setup-range-to', '30'),
    'kursi': ('dining-setup-range-seats', '6'),
  };
  for (final MapEntry(key: what, value: (field, text))
      in rangeChanges.entries) {
    testWidgets('rentang: ubah $what lalu Esc bertanya dulu (F1-10n)', (
      tester,
    ) async {
      final repo = await pump(tester);
      await _tap(tester, 'master-tab-tables');
      await _tap(tester, 'dining-setup-table-range');
      await _type(tester, field, text);
      await _esc(tester);
      expect(_key('dining-range-discard'), findsOneWidget);
      await _tap(tester, 'dining-range-discard-confirm');
      expect(_key('dining-setup-range-dialog'), findsNothing);
      expect(repo.tables, hasLength(3));
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
  }

  testWidgets('rentang: awalan dengan spasi tepi dan "01" bukan perubahan '
      '(F1-10n)', (tester) async {
    await pump(tester);
    await _tap(tester, 'master-tab-tables');
    await _tap(tester, 'dining-setup-table-range');
    await _type(tester, 'dining-setup-range-prefix', ' M ');
    await _type(tester, 'dining-setup-range-from', '01');
    await _esc(tester);
    expect(_key('dining-range-discard'), findsNothing);
    expect(_key('dining-setup-range-dialog'), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('tombol kembali sistem ikut bertanya (F1-10n)', (tester) async {
    await pump(tester);
    await _tap(tester, 'master-tab-tables');
    await _tap(tester, 'dining-setup-table-edit-M1');
    await _type(tester, 'dining-setup-table-seats', '8');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(_key('dining-table-discard'), findsOneWidget);
    expect(_key('dining-setup-table-dialog'), findsOneWidget);
    await _tap(tester, 'dining-table-discard-cancel');
    expect(_key('dining-setup-table-dialog'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('konfirmasi hapus: ketuk di luar sama dengan Batal (F1-10n)', (
    tester,
  ) async {
    final repo = await pump(tester);
    await _tap(tester, 'master-tab-tables');
    await _tap(tester, 'dining-setup-table-delete-T1');
    expect(_key('dining-setup-confirm'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(_key('dining-setup-confirm'), findsNothing);
    expect(repo.tables, hasLength(3));
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('meja kembar: dialog tetap terbuka dengan isian utuh (F1-10o)', (
    tester,
  ) async {
    final repo = await pump(tester);
    await _tap(tester, 'master-tab-tables');
    await _tap(tester, 'dining-setup-table-add');
    await _type(tester, 'dining-setup-table-name', 'm1');
    await _type(tester, 'dining-setup-table-seats', '6');
    await _tap(tester, 'dining-setup-table-save');
    expect(_key('dining-setup-table-dialog'), findsOneWidget);
    expect(
      find.descendant(
        of: _key('dining-setup-table-name'),
        matching: find.text('Nama sudah dipakai.'),
      ),
      findsOneWidget,
    );
    expect(_key('dining-setup-dialog-error'), findsNothing);
    expect(
      find.descendant(
        of: _key('dining-setup-table-seats'),
        matching: find.text('6'),
      ),
      findsOneWidget,
    );
    expect(repo.tables, hasLength(3));
    await _type(tester, 'dining-setup-table-name', 'M9');
    await _tap(tester, 'dining-setup-table-save');
    expect(_key('dining-setup-table-dialog'), findsNothing);
    expect(repo.tables.last.name, 'M9');
    expect(repo.tables.last.seats, 6);
    expect(_key('dining-setup-error'), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('simpan yang berjalan menahan dialog (F1-10o)', (tester) async {
    final repo = await pump(tester);
    await _tap(tester, 'master-tab-tables');
    await _tap(tester, 'dining-setup-area-add');
    await _type(tester, 'dining-setup-area-name', 'Lantai 2');
    final gate = repo.gate = Completer<void>();
    await tester.tap(_key('dining-setup-area-save'));
    await tester.pump();
    await _esc(tester);
    await tester.tapAt(const Offset(10, 10));
    await tester.pump(const Duration(milliseconds: 300));
    expect(_key('dining-setup-area-dialog'), findsOneWidget);
    expect(_key('dining-area-discard'), findsNothing);
    repo.gate = null;
    gate.complete();
    await tester.pumpAndSettle();
    expect(_key('dining-setup-area-dialog'), findsNothing);
    expect(repo.areas.map((a) => a.name), contains('Lantai 2'));
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('ubah nama area yang kembar: dialog tetap terbuka (F1-10o)', (
    tester,
  ) async {
    final repo = await pump(tester);
    await _tap(tester, 'master-tab-tables');
    await _tap(tester, 'dining-setup-area-edit-Teras');
    await _type(tester, 'dining-setup-area-name', 'indoor');
    await _tap(tester, 'dining-setup-area-save');
    expect(_key('dining-setup-area-dialog'), findsOneWidget);
    expect(
      find.descendant(
        of: _key('dining-setup-area-name'),
        matching: find.text('Nama sudah dipakai.'),
      ),
      findsOneWidget,
    );
    expect(_key('dining-setup-error'), findsNothing);
    expect(repo.areas.map((a) => a.name), ['Indoor', 'Teras']);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('Enter dan ketuk Simpan lagi saat simpan berjalan diabaikan '
      '(F1-10o)', (tester) async {
    final repo = await pump(tester);
    await _tap(tester, 'master-tab-tables');
    await _tap(tester, 'dining-setup-area-add');
    await _type(tester, 'dining-setup-area-name', 'Lantai 2');
    final gate = repo.gate = Completer<void>();
    final before = repo.calls;
    await tester.tap(_key('dining-setup-area-save'));
    await tester.pump();
    await tester.tap(_key('dining-setup-area-save'), warnIfMissed: false);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.tap(_key('dining-setup-area-cancel'), warnIfMissed: false);
    await tester.pump();
    expect(_key('dining-area-discard'), findsNothing);
    repo.gate = null;
    gate.complete();
    await tester.pumpAndSettle();
    expect(_key('dining-setup-area-dialog'), findsNothing);
    // Satu simpan (buat area) + satu muat ulang daftar.
    expect(repo.calls - before, 2);
    expect(repo.areas.where((a) => a.name == 'Lantai 2'), hasLength(1));
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('galat tak terduga tidak mengunci dialog (F1-10o)', (
    tester,
  ) async {
    final repo = await pump(tester);
    await _tap(tester, 'master-tab-tables');
    await _tap(tester, 'dining-setup-table-add');
    await _type(tester, 'dining-setup-table-name', 'M9');
    repo.throwNext = true;
    await _tap(tester, 'dining-setup-table-save');
    expect(tester.takeException(), isNull);
    expect(
      find.descendant(
        of: _key('dining-setup-dialog-error'),
        matching: find.text('Aksi gagal. Coba lagi.'),
      ),
      findsOneWidget,
    );
    await _esc(tester);
    expect(_key('dining-table-discard'), findsOneWidget);
    await _tap(tester, 'dining-table-discard-confirm');
    expect(_key('dining-setup-table-dialog'), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('tab dibangun ulang (lebar melewati 900 px) saat dialog terbuka '
      '(F1-10o)', (tester) async {
    final repo = await pump(tester);
    await _tap(tester, 'master-tab-tables');
    await _tap(tester, 'dining-setup-table-range');
    await _type(tester, 'dining-setup-range-from', '1');
    await _type(tester, 'dining-setup-range-to', '2');
    tester.view.physicalSize = const Size(800, 800);
    await tester.pumpAndSettle();
    await _tap(tester, 'dining-setup-range-save');
    expect(_key('dining-setup-range-dialog'), findsOneWidget);
    expect(
      find.descendant(
        of: _key('dining-setup-range-preview'),
        matchRoot: true,
        matching: find.text('Nama M1 sudah dipakai.'),
      ),
      findsOneWidget,
    );
    expect(repo.tables, hasLength(3));
    // Mengubah isian rentang menghapus pesan dan pratinjau kembali.
    await _type(tester, 'dining-setup-range-from', '5');
    expect(find.text('Nama M1 sudah dipakai.'), findsNothing);
    await _type(tester, 'dining-setup-range-to', '6');
    expect(find.textContaining('M5, M6'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  group('galat simpan di isiannya (F1-10p)', () {
    testWidgets('kursi dari penyimpanan di bawah Kursi; galat lain di kotak', (
      tester,
    ) async {
      final repo = await pump(tester);
      await _tap(tester, 'master-tab-tables');
      await _tap(tester, 'dining-setup-table-add');
      await _type(tester, 'dining-setup-table-name', 'M9');
      repo.nextError = DiningSeatsInvalid();
      await _tap(tester, 'dining-setup-table-save');
      expect(
        find.descendant(
          of: _key('dining-setup-table-seats'),
          matching: find.text('Kursi 1–99.'),
        ),
        findsOneWidget,
      );
      expect(_key('dining-setup-dialog-error'), findsNothing);
      expect(
        find.descendant(
          of: _key('dining-setup-table-name'),
          matching: find.text('Kursi 1–99.'),
        ),
        findsNothing,
      );

      repo.nextError = DiningNotFound();
      await _tap(tester, 'dining-setup-table-save');
      expect(_key('dining-setup-dialog-error'), findsOneWidget);
      expect(find.text('Kursi 1–99.'), findsNothing);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

    testWidgets('nama area terlalu panjang dari penyimpanan di bawah Nama', (
      tester,
    ) async {
      final repo = await pump(tester);
      await _tap(tester, 'master-tab-tables');
      await _tap(tester, 'dining-setup-area-add');
      await _type(tester, 'dining-setup-area-name', 'Lantai 3');
      repo.nextError = const DiningNameInvalid(DiningNameError.tooLong);
      await _tap(tester, 'dining-setup-area-save');
      expect(_key('dining-setup-dialog-error'), findsNothing);
      expect(
        find.descendant(
          of: _key('dining-setup-area-name'),
          matching: find.textContaining('Nama maks'),
        ),
        findsOneWidget,
      );
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

    testWidgets('nama kosong lalu kembar: pesan kembar yang tampil', (
      tester,
    ) async {
      await pump(tester);
      await _tap(tester, 'master-tab-tables');
      await _tap(tester, 'dining-setup-area-add');
      await _tap(tester, 'dining-setup-area-save');
      expect(find.text('Nama wajib diisi.'), findsOneWidget);
      await _type(tester, 'dining-setup-area-name', 'indoor');
      await _tap(tester, 'dining-setup-area-save');
      expect(find.text('Nama wajib diisi.'), findsNothing);
      expect(
        find.descendant(
          of: _key('dining-setup-area-name'),
          matching: find.text('Nama sudah dipakai.'),
        ),
        findsOneWidget,
      );
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

    testWidgets('kursi rentang dari penyimpanan di bawah Kursi', (
      tester,
    ) async {
      final repo = await pump(tester);
      await _tap(tester, 'master-tab-tables');
      await _tap(tester, 'dining-setup-table-range');
      await _type(tester, 'dining-setup-range-from', '20');
      await _type(tester, 'dining-setup-range-to', '21');
      repo.nextError = DiningSeatsInvalid();
      await _tap(tester, 'dining-setup-range-save');
      expect(
        find.descendant(
          of: _key('dining-setup-range-seats'),
          matching: find.text('Kursi 1–99.'),
        ),
        findsOneWidget,
      );
      expect(_key('dining-setup-dialog-error'), findsNothing);
      // Mengubah isian menghapus galat kursi.
      await _type(tester, 'dining-setup-range-seats', '6');
      expect(find.text('Kursi 1–99.'), findsNothing);

      // Galat lain tetap di kotak merah; pratinjau tidak berubah.
      repo.nextError = DiningRangeInvalid();
      await _tap(tester, 'dining-setup-range-save');
      expect(_key('dining-setup-dialog-error'), findsOneWidget);
      expect(find.textContaining('M20, M21'), findsOneWidget);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
  });

  group('kursor pindah ke isian yang salah (F1-10q)', () {
    testWidgets('area: nama kosong dan nama kembar ke Nama', (tester) async {
      await pump(tester);
      await _tap(tester, 'master-tab-tables');
      await _tap(tester, 'dining-setup-area-add');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      await _tap(tester, 'dining-setup-area-save');
      expect(find.text('Nama wajib diisi.'), findsOneWidget);
      expect(_focused(tester, 'dining-setup-area-name'), isTrue);

      await _type(tester, 'dining-setup-area-name', 'indoor');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      await _tap(tester, 'dining-setup-area-save');
      expect(find.text('Nama sudah dipakai.'), findsOneWidget);
      expect(_focused(tester, 'dining-setup-area-name'), isTrue);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

    testWidgets('meja: nama kembar saat kursor di Kursi ke Nama', (
      tester,
    ) async {
      await pump(tester);
      await _tap(tester, 'master-tab-tables');
      await _tap(tester, 'dining-setup-table-add');
      await _type(tester, 'dining-setup-table-name', 'm1');
      await _type(tester, 'dining-setup-table-seats', '6');
      expect(_focused(tester, 'dining-setup-table-seats'), isTrue);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Nama sudah dipakai.'), findsOneWidget);
      expect(_focused(tester, 'dining-setup-table-name'), isTrue);
      expect(_focused(tester, 'dining-setup-table-seats'), isFalse);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

    testWidgets('meja: kursi 0 dan galat kursi penyimpanan ke Kursi', (
      tester,
    ) async {
      final repo = await pump(tester);
      await _tap(tester, 'master-tab-tables');
      await _tap(tester, 'dining-setup-table-add');
      await _type(tester, 'dining-setup-table-seats', '0');
      await _type(tester, 'dining-setup-table-name', 'M9');
      await _tap(tester, 'dining-setup-table-save');
      expect(find.text('Kursi 1–99.'), findsOneWidget);
      expect(_focused(tester, 'dining-setup-table-seats'), isTrue);

      await _type(tester, 'dining-setup-table-seats', '6');
      await _type(tester, 'dining-setup-table-name', 'M10');
      repo.nextError = DiningSeatsInvalid();
      await _tap(tester, 'dining-setup-table-save');
      expect(find.text('Kursi 1–99.'), findsOneWidget);
      expect(_focused(tester, 'dining-setup-table-seats'), isTrue);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

    testWidgets('meja: nama kosong dan kursi 0 ke Nama (isian teratas)', (
      tester,
    ) async {
      await pump(tester);
      await _tap(tester, 'master-tab-tables');
      await _tap(tester, 'dining-setup-table-add');
      await _type(tester, 'dining-setup-table-seats', '0');
      await _tap(tester, 'dining-setup-table-save');
      expect(find.text('Nama wajib diisi.'), findsOneWidget);
      expect(find.text('Kursi 1–99.'), findsOneWidget);
      expect(_focused(tester, 'dining-setup-table-name'), isTrue);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

    testWidgets('galat di kotak merah tidak memindahkan kursor', (
      tester,
    ) async {
      final repo = await pump(tester);
      await _tap(tester, 'master-tab-tables');
      await _tap(tester, 'dining-setup-table-add');
      await _type(tester, 'dining-setup-table-name', 'M9');
      await _type(tester, 'dining-setup-table-seats', '6');
      repo.nextError = DiningNotFound();
      await _tap(tester, 'dining-setup-table-save');
      expect(_key('dining-setup-dialog-error'), findsOneWidget);
      // Kursor tetap di tombol Simpan yang diketuk.
      expect(_focused(tester, 'dining-setup-table-seats'), isFalse);
      expect(_focused(tester, 'dining-setup-table-name'), isFalse);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

    testWidgets('rentang: Dari, Sampai, nama kembar, lalu Kursi', (
      tester,
    ) async {
      await pump(tester);
      await _tap(tester, 'master-tab-tables');
      await _tap(tester, 'dining-setup-table-range');
      // Nomor awal 0 → Dari.
      await _type(tester, 'dining-setup-range-from', '0');
      await _type(tester, 'dining-setup-range-prefix', 'B');
      await _tap(tester, 'dining-setup-range-save');
      expect(_focused(tester, 'dining-setup-range-from'), isTrue);

      // Sampai lebih kecil dari Dari → Sampai.
      await _type(tester, 'dining-setup-range-from', '5');
      await _type(tester, 'dining-setup-range-to', '3');
      await _type(tester, 'dining-setup-range-prefix', 'B');
      await _tap(tester, 'dining-setup-range-save');
      expect(_focused(tester, 'dining-setup-range-to'), isTrue);

      // Rentang benar, kursi 0 → Kursi.
      await _type(tester, 'dining-setup-range-to', '6');
      await _type(tester, 'dining-setup-range-seats', '0');
      await _type(tester, 'dining-setup-range-prefix', 'B');
      await _tap(tester, 'dining-setup-range-save');
      expect(find.text('Kursi 1–99.'), findsOneWidget);
      expect(_focused(tester, 'dining-setup-range-seats'), isTrue);

      // Nama kembar dari penyimpanan → Dari.
      await _type(tester, 'dining-setup-range-seats', '4');
      await _type(tester, 'dining-setup-range-prefix', 'M');
      await _type(tester, 'dining-setup-range-from', '1');
      await _type(tester, 'dining-setup-range-to', '2');
      await _tap(tester, 'dining-setup-range-save');
      expect(find.text('Nama M1 sudah dipakai.'), findsOneWidget);
      expect(_focused(tester, 'dining-setup-range-from'), isTrue);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

    testWidgets('rentang: galat kursi penyimpanan ke Kursi', (tester) async {
      final repo = await pump(tester);
      await _tap(tester, 'master-tab-tables');
      await _tap(tester, 'dining-setup-table-range');
      await _type(tester, 'dining-setup-range-from', '20');
      await _type(tester, 'dining-setup-range-to', '21');
      repo.nextError = DiningSeatsInvalid();
      await _tap(tester, 'dining-setup-range-save');
      expect(find.text('Kursi 1–99.'), findsOneWidget);
      expect(_focused(tester, 'dining-setup-range-seats'), isTrue);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

    testWidgets('area: Enter pada nama kembar tetap di Nama', (tester) async {
      await pump(tester);
      await _tap(tester, 'master-tab-tables');
      await _tap(tester, 'dining-setup-area-add');
      await _type(tester, 'dining-setup-area-name', 'indoor');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Nama sudah dipakai.'), findsOneWidget);
      expect(_focused(tester, 'dining-setup-area-name'), isTrue);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

    testWidgets('galat tak terduga tidak memindahkan kursor (Enter)', (
      tester,
    ) async {
      final repo = await pump(tester);
      await _tap(tester, 'master-tab-tables');
      await _tap(tester, 'dining-setup-table-add');
      await _type(tester, 'dining-setup-table-name', 'M9');
      await _type(tester, 'dining-setup-table-seats', '6');
      repo.throwNext = true;
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Aksi gagal. Coba lagi.'), findsOneWidget);
      expect(_focused(tester, 'dining-setup-table-name'), isFalse);
      expect(_focused(tester, 'dining-setup-table-seats'), isFalse);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

    testWidgets('rentang: lebih dari batas ke Sampai; galat rentang '
        'penyimpanan tidak memindahkan kursor', (tester) async {
      final repo = await pump(tester);
      await _tap(tester, 'master-tab-tables');
      await _tap(tester, 'dining-setup-table-range');
      await _type(tester, 'dining-setup-range-from', '1');
      await _type(tester, 'dining-setup-range-to', '99');
      await _type(tester, 'dining-setup-range-prefix', 'B');
      await _tap(tester, 'dining-setup-range-save');
      expect(_focused(tester, 'dining-setup-range-to'), isTrue);

      await _type(tester, 'dining-setup-range-to', '3');
      await _type(tester, 'dining-setup-range-prefix', 'C');
      repo.nextError = DiningRangeInvalid();
      await _tap(tester, 'dining-setup-range-save');
      expect(_key('dining-setup-dialog-error'), findsOneWidget);
      for (final k in ['from', 'to', 'seats']) {
        expect(_focused(tester, 'dining-setup-range-$k'), isFalse);
      }
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

    testWidgets('rentang: isian diubah selama simpan, kursor ikut galat '
        'penyimpanan', (tester) async {
      final repo = await pump(tester);
      await _tap(tester, 'master-tab-tables');
      await _tap(tester, 'dining-setup-table-range');
      await _type(tester, 'dining-setup-range-from', '20');
      await _type(tester, 'dining-setup-range-to', '21');
      final gate = repo.gate = Completer<void>();
      repo.nextError = DiningSeatsInvalid();
      await tester.tap(_key('dining-setup-range-save'));
      await tester.pump();
      await tester.enterText(_input('dining-setup-range-from'), '0');
      await tester.pump();
      repo.gate = null;
      gate.complete();
      await tester.pumpAndSettle();
      expect(_focused(tester, 'dining-setup-range-seats'), isTrue);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

    testWidgets('rentang: pratinjau tepat di bawah Dari–Sampai', (
      tester,
    ) async {
      await pump(tester);
      await _tap(tester, 'master-tab-tables');
      await _tap(tester, 'dining-setup-table-range');
      final preview = tester.getRect(_key('dining-setup-range-preview'));
      expect(
        preview.top,
        greaterThanOrEqualTo(
          tester.getRect(_key('dining-setup-range-to')).bottom,
        ),
      );
      expect(
        preview.bottom,
        lessThanOrEqualTo(
          tester.getRect(_key('dining-setup-range-seats')).top,
        ),
      );
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
  });

  group('Simpan dari dialog Buang perubahan? (F1-09c)', () {
    testWidgets('area: Esc lalu Simpan tersimpan; nama kembar tetap '
        'terbuka', (tester) async {
      final repo = await pump(tester);
      await _tap(tester, 'master-tab-tables');
      await _tap(tester, 'dining-setup-area-add');
      await _type(tester, 'dining-setup-area-name', 'teras');
      await _esc(tester);
      await _tap(tester, 'dining-area-discard-save');
      expect(_key('dining-setup-area-dialog'), findsOneWidget);
      expect(
        find.descendant(
          of: _key('dining-setup-area-name'),
          matching: find.text('Nama sudah dipakai.'),
        ),
        findsOneWidget,
      );
      // Kursor kembali ke isian yang salah (F1-10q).
      expect(_focused(tester, 'dining-setup-area-name'), isTrue);
      expect(repo.areas, hasLength(2));

      // Ditolak saat tutup jendela: aplikasi tidak ditutup.
      final exit = tester.binding.handleRequestAppExit();
      await tester.pumpAndSettle();
      await _tap(tester, 'dining-area-discard-save');
      expect(await exit, AppExitResponse.cancel);
      expect(_key('dining-setup-area-dialog'), findsOneWidget);
      expect(repo.areas, hasLength(2));

      await _type(tester, 'dining-setup-area-name', 'Balkon');
      await _esc(tester);
      await _tap(tester, 'dining-area-discard-save');
      expect(_key('dining-area-discard'), findsNothing);
      expect(_key('dining-setup-area-dialog'), findsNothing);
      expect(repo.areas.last.name, 'Balkon');
      expect(_key('dining-setup-area-Balkon'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('meja: isian salah tidak menutup aplikasi; tutup jendela '
        'lalu Simpan tersimpan lalu keluar', (tester) async {
      final repo = await pump(tester);
      await _tap(tester, 'master-tab-tables');
      await _tap(tester, 'dining-setup-table-add');
      await _type(tester, 'dining-setup-table-name', 'M3');
      await _type(tester, 'dining-setup-table-seats', '0');
      var exit = tester.binding.handleRequestAppExit();
      await tester.pumpAndSettle();
      await _tap(tester, 'dining-table-discard-save');
      expect(await exit, AppExitResponse.cancel);
      expect(_key('dining-setup-table-dialog'), findsOneWidget);
      expect(find.text('Kursi 1–99.'), findsOneWidget);
      expect(repo.tables, hasLength(3));

      await _type(tester, 'dining-setup-table-seats', '6');
      exit = tester.binding.handleRequestAppExit();
      await tester.pumpAndSettle();
      await _tap(tester, 'dining-table-discard-save');
      expect(await exit, AppExitResponse.exit);
      expect(repo.tables.last.name, 'M3');
      expect(repo.tables.last.seats, 6);
      expect(_key('dining-setup-table-dialog'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('rentang: Batal lalu Simpan; bentrok tetap terbuka', (
      tester,
    ) async {
      final repo = await pump(tester);
      await _tap(tester, 'master-tab-tables');
      await _tap(tester, 'dining-setup-table-range');
      await _type(tester, 'dining-setup-range-from', '2');
      await _type(tester, 'dining-setup-range-to', '3');
      await _tap(tester, 'dining-setup-range-cancel');
      await _tap(tester, 'dining-range-discard-save');
      expect(_key('dining-setup-range-dialog'), findsOneWidget);
      expect(find.text('Nama M2 sudah dipakai.'), findsOneWidget);
      expect(repo.tables, hasLength(3));

      await _type(tester, 'dining-setup-range-from', '5');
      await _type(tester, 'dining-setup-range-to', '6');
      await _tap(tester, 'dining-setup-range-cancel');
      await _tap(tester, 'dining-range-discard-save');
      expect(_key('dining-setup-range-dialog'), findsNothing);
      expect(repo.tables.map((t) => t.name), ['M1', 'M2', 'T1', 'M5', 'M6']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('simpan dari pertanyaan yang berjalan menahan dialog dan '
        'jendela', (tester) async {
      final repo = await pump(tester);
      await _tap(tester, 'master-tab-tables');
      await _tap(tester, 'dining-setup-area-add');
      await _type(tester, 'dining-setup-area-name', 'Lantai 2');
      await _esc(tester);
      final gate = repo.gate = Completer<void>();
      await tester.tap(_key('dining-area-discard-save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(_key('dining-area-discard'), findsNothing);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(_key('dining-area-discard'), findsNothing);
      expect(_key('dining-setup-area-dialog'), findsOneWidget);
      final exit = tester.binding.handleRequestAppExit();
      await tester.pump();
      expect(_key('dining-area-discard'), findsNothing);
      expect(await exit, AppExitResponse.cancel);

      repo.gate = null;
      gate.complete();
      await tester.pumpAndSettle();
      expect(_key('dining-setup-area-dialog'), findsNothing);
      expect(repo.areas.map((a) => a.name), contains('Lantai 2'));
      expect(tester.takeException(), isNull);
    });
  });
}
