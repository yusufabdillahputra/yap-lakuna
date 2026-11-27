import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart' show Permission;
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_session_repository.dart';
import '../../testing/fake_shifts_repository.dart';

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

String _text(WidgetTester tester, String key) =>
    tester.widget<Text>(_key(key)).data!;

void main() {
  for (final size in const [Size(1280, 800), Size(360, 740)]) {
    testWidgets('${size.width.toInt()} px: tambah, ubah, hapus shift', (
      tester,
    ) async {
      final repo = FakeShiftsRepository();
      final pagi = repo.add('Pagi', 7 * 60, 15 * 60, used: 3);
      await pumpLakuna(
        tester,
        size: size,
        initialLocation: Routes.master,
        shifts: repo,
      );
      await _tap(
        tester,
        size.width < 600 ? 'master-pill-shifts' : 'master-tab-shifts',
      );
      expect(
        _text(tester, 'shift-sub-${pagi.id.uuid}'),
        '07.00–15.00 · dipakai 3 sesi',
      );

      // Isian salah ditandai di bawah field; jam sama ditolak.
      await _tap(tester, 'shifts-new');
      await _type(tester, 'shift-name', 'Malam');
      await _type(tester, 'shift-start', '25');
      await _type(tester, 'shift-end', '6');
      await _tap(tester, 'shift-save');
      expect(find.text('Isi jam 00.00–23.59, mis. 07.00.'), findsOneWidget);
      expect(repo.shifts, hasLength(1));
      await _type(tester, 'shift-start', '6');
      await _tap(tester, 'shift-save');
      expect(
        find.text('Jam selesai harus berbeda dengan jam mulai.'),
        findsOneWidget,
      );

      // Lewat tengah malam diberi keterangan.
      await _type(tester, 'shift-start', '22:00');
      expect(
        _text(tester, 'shift-overnight'),
        'Lewat tengah malam: 22.00–06.00.',
      );
      // Nama ganda ditolak repositori.
      await _type(tester, 'shift-name', 'pagi');
      await _tap(tester, 'shift-save');
      expect(
        _text(tester, 'shift-error'),
        'Nama shift sudah dipakai di cabang ini.',
      );
      await _type(tester, 'shift-name', 'Malam');
      await _tap(tester, 'shift-save');
      expect(_key('shift-form'), findsNothing);
      final malam = repo.shifts.firstWhere((s) => s.name == 'Malam');
      expect((malam.startMinute, malam.endMinute), (1320, 360));
      expect(
        _text(tester, 'shift-sub-${malam.id.uuid}'),
        '22.00–06.00 · belum dipakai',
      );

      // Ubah: isian awal memakai format 07.00.
      await _tap(tester, 'shift-edit-${malam.id.uuid}');
      expect(find.text('22.00'), findsOneWidget);
      await _type(tester, 'shift-end', '0530');
      await _tap(tester, 'shift-save');
      expect(repo.shifts.firstWhere((s) => s.id == malam.id).endMinute, 330);

      // Shift terpakai tidak bisa dihapus; yang kosong bisa.
      await _tap(tester, 'shift-delete-${pagi.id.uuid}');
      expect(
        _text(tester, 'shift-delete-error'),
        'Shift dipakai 3 sesi kasir, jadi tidak bisa dihapus.',
      );
      await _tap(tester, 'shift-delete-${malam.id.uuid}');
      expect(repo.shifts.map((s) => s.name), ['Pagi']);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tanpa settings:manage tab Shift tidak tampil', (tester) async {
    await pumpLakuna(
      tester,
      initialLocation: Routes.master,
      shifts: FakeShiftsRepository(),
      session: FakeSessionRepository()
        ..current = staffWithPermissions({Permission.productsManage}),
    );
    expect(_key('master-tab-units'), findsOneWidget);
    expect(_key('master-tab-shifts'), findsNothing);
  });

  testWidgets('dialog shift yang berubah bertanya, Simpan dari dialog', (
    tester,
  ) async {
    final repo = FakeShiftsRepository();
    final pagi = repo.add('Pagi', 7 * 60, 15 * 60);
    await pumpLakuna(
      tester,
      initialLocation: Routes.master,
      shifts: repo,
    );
    await _tap(tester, 'master-tab-shifts');
    // Belum berubah: Esc langsung menutup.
    await _tap(tester, 'shift-edit-${pagi.id.uuid}');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_key('shift-form'), findsNothing);

    await _tap(tester, 'shift-edit-${pagi.id.uuid}');
    await _type(tester, 'shift-end', '16.00');
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(
      find.text('Shift yang sedang diisi belum disimpan dan akan hilang.'),
      findsOneWidget,
    );
    await _tap(tester, 'shift-discard-save');
    expect(_key('shift-form'), findsNothing);
    expect(repo.shifts.single.endMinute, 16 * 60);

    // Isian salah: Simpan dari dialog tidak menutup form.
    await _tap(tester, 'shift-edit-${pagi.id.uuid}');
    await _type(tester, 'shift-end', '99');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    await _tap(tester, 'shift-discard-save');
    expect(_key('shift-form'), findsOneWidget);
    expect(find.text('Isi jam 00.00–23.59, mis. 07.00.'), findsOneWidget);
    await _tap(tester, 'shift-cancel');
    await _tap(tester, 'shift-discard-confirm');
    expect(_key('shift-form'), findsNothing);
    expect(repo.shifts.single.endMinute, 16 * 60);
    expect(tester.takeException(), isNull);
  });
}
