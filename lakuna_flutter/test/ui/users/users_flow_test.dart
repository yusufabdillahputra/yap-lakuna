import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/routing/routes.dart';
import 'package:lakuna_flutter/ui/core/menu.dart';

import 'package:lakuna_flutter/data/repositories/session_repository.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_session_repository.dart';
import '../../testing/fake_users_repository.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

Finder _input(Finder field) =>
    find.descendant(of: field, matching: find.byType(EditableText));

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, Finder field, String text) async {
  await tester.ensureVisible(field);
  await tester.enterText(_input(field), text);
  await tester.pumpAndSettle();
}

Future<void> _choose(WidgetTester tester, Finder field, String label) async {
  await _tap(tester, field);
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  late FakeUsersRepository repo;

  Future<void> pump(
    WidgetTester tester,
    Size size, {
    String location = Routes.users,
    FakeSessionRepository? session,
  }) async {
    repo = FakeUsersRepository();
    await pumpLakuna(
      tester,
      size: size,
      users: repo,
      session: session,
      initialLocation: location,
    );
  }

  testWidgets('1440: tambah staf dengan PIN + ulangi, lalu reset PIN', (
    tester,
  ) async {
    await pump(tester, const Size(1440, 900));
    expect(find.text('Cabang Pusat · 3 pengguna aktif'), findsOneWidget);
    expect(find.text('yusuf@contoh.id'), findsOneWidget);
    expect(find.text('PIN saja'), findsNWidgets(3));
    expect(find.text('Nonaktif'), findsOneWidget);

    await _tap(tester, _key('users-add'));
    expect(_key('users-form'), findsOneWidget);
    await _tap(tester, _key('users-form-save'));
    expect(find.text('Wajib diisi'), findsWidgets);
    expect(find.text('PIN harus 6 angka'), findsOneWidget);

    await _type(tester, _key('users-form-name'), 'Budi');
    await _choose(tester, _key('users-form-role'), 'Staf gudang');
    await _type(tester, _key('users-form-pin'), '112233');
    await _type(tester, _key('users-form-pin-retype'), '112299');
    await _tap(tester, _key('users-form-save'));
    expect(find.text('PIN tidak sama'), findsOneWidget);
    expect(repo.calls.where((c) => c.startsWith('create')), isEmpty);

    await _type(tester, _key('users-form-pin-retype'), '112233');
    await _tap(tester, _key('users-form-save'));
    expect(_key('users-form'), findsNothing);
    expect(repo.calls, contains('create:Budi:stock_keeper:112233:true'));
    expect(find.text('Budi'), findsOneWidget);
    expect(find.text('Cabang Pusat · 4 pengguna aktif'), findsOneWidget);

    // Reset PIN Sari tanpa PIN lama; kunci ikut dibuka.
    final sari = repo.list[2];
    await _tap(tester, _key('users-row-${sari.id.uuid}'));
    expect(find.text('Ubah pengguna'), findsOneWidget);
    expect(_key('users-form-pin'), findsNothing);
    await _type(tester, _key('users-reset-pin'), '445566');
    await _type(tester, _key('users-reset-retype'), '445566');
    await _tap(tester, _key('users-reset-submit'));
    expect(_key('users-reset-done'), findsOneWidget);
    expect(repo.calls, contains('reset:445566'));
  });

  testWidgets('1440: PIN dikunci tampil dan bisa dibuka', (tester) async {
    await pump(tester, const Size(1440, 900));
    final sari = repo.list[2];
    repo.locked[sari.id] = const Duration(seconds: 45);
    // Ganti tab membangun ulang daftar, jadi status kunci terbaca.
    await _tap(tester, _key('users-tab-roles'));
    await _tap(tester, _key('users-tab-users'));
    expect(find.text('PIN dikunci 45 dtk'), findsOneWidget);
    await _tap(tester, _key('users-unlock-${sari.id.uuid}'));
    expect(find.text('PIN dikunci 45 dtk'), findsNothing);
    expect(repo.locked, isEmpty);
  });

  testWidgets('1440: matriks izin, role custom, hapus role yang dipakai', (
    tester,
  ) async {
    await pump(tester, const Size(1440, 900));
    await _tap(tester, _key('users-tab-roles'));
    expect(find.text('sales:create'), findsOneWidget);
    expect(find.text('Lihat laba rugi'), findsOneWidget);

    // Pemilik terkunci; kasir bisa diubah.
    await _tap(tester, _key('users-perm-owner-sales:create'));
    expect(repo.calls.where((c) => c.startsWith('matrix')), isEmpty);
    await _tap(tester, _key('users-perm-cashier-reports:view'));
    await _tap(tester, _key('users-matrix-save'));
    expect(repo.calls, contains('matrix:cashier'));
    expect(_key('users-matrix-saved'), findsOneWidget);
    expect(repo.stored['cashier']!.$2, contains(Permission.reportsView));

    await _tap(tester, _key('users-role-new'));
    await _type(tester, _key('users-role-name'), 'Barista');
    // Enter di kolom nama langsung membuat role.
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(_key('users-role-barista'), findsOneWidget);

    repo.list = [...repo.list, sampleAccount('Tono', role: 'barista')];
    await _tap(tester, _key('users-role-delete-barista'));
    expect(_key('users-role-delete-dialog'), findsOneWidget);
    await _tap(tester, _key('users-role-delete-confirm'));
    expect(_key('users-role-delete-error'), findsOneWidget);
  });

  testWidgets('manajer: pemilik dan dirinya tidak bisa dibuka atau diubah', (
    tester,
  ) async {
    repo = FakeUsersRepository();
    final rina = repo.list[1];
    final manager = StaffProfile(
      id: rina.id,
      name: 'Rina',
      roleKey: 'manager',
      isOwner: false,
      hasPin: true,
      permissions: {...DefaultRole.manager.permissions, Permission.usersManage},
    );
    final owner = repo.list.first;
    repo.locked[owner.id] = const Duration(seconds: 30);
    await pumpLakuna(
      tester,
      size: const Size(1440, 900),
      users: repo,
      session: FakeSessionRepository(staff: [manager], current: manager),
      initialLocation: Routes.users,
    );
    expect(find.text('PIN dikunci 30 dtk'), findsOneWidget);
    expect(_key('users-unlock-${owner.id.uuid}'), findsNothing);
    await _tap(tester, _key('users-row-${rina.id.uuid}'));
    expect(_key('users-form'), findsNothing);
    await _tap(tester, _key('users-row-${repo.list[2].id.uuid}'));
    expect(_key('users-form'), findsOneWidget);
  });

  testWidgets('1440: staf tanpa PIN ditandai "Belum punya PIN"', (
    tester,
  ) async {
    repo = FakeUsersRepository();
    repo.list = [...repo.list, sampleAccount('Andi', pin: false)];
    await pumpLakuna(
      tester,
      size: const Size(1440, 900),
      users: repo,
      initialLocation: Routes.users,
    );
    expect(find.text('Belum punya PIN'), findsOneWidget);
    expect(find.text('PIN saja'), findsNWidgets(3));
  });

  testWidgets('800: daftar dan matriks bisa digulir', (tester) async {
    await pump(tester, const Size(800, 900));
    expect(find.text('Sari'), findsOneWidget);
    await _tap(tester, _key('users-tab-roles'));
    await tester.drag(_key('users-matrix-scroll'), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('360: kartu pengguna dan dialog tambah', (tester) async {
    await pump(tester, const Size(360, 780));
    expect(find.text('Rina'), findsOneWidget);
    await _tap(tester, _key('users-add'));
    expect(_key('users-form'), findsOneWidget);
    await _tap(tester, find.text('Batal'));
    await _tap(tester, _key('users-tab-roles'));
    expect(_key('users-matrix-save'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('Akun saya', () {
    testWidgets('1440: ganti PIN dan kata sandi dengan kolom ulangi', (
      tester,
    ) async {
      await pump(tester, const Size(1440, 900), location: Routes.account);
      expect(
        find.text('Yusuf · Pemilik · terbuka untuk setiap pengguna'),
        findsOneWidget,
      );

      await _type(tester, _key('account-pinCurrent'), '123456');
      await _type(tester, _key('account-pin'), '246810');
      await _type(tester, _key('account-pinRetype'), '246811');
      await _tap(tester, _key('account-pin-submit'));
      expect(find.text('PIN tidak sama'), findsOneWidget);
      await _type(tester, _key('account-pinRetype'), '246810');
      await _tap(tester, _key('account-pin-submit'));
      expect(_key('account-pin-done'), findsOneWidget);
      expect(repo.calls, contains('my-pin:246810'));

      await _type(tester, _key('account-passwordCurrent'), 'salah123');
      await _type(tester, _key('account-password'), 'rahasiabaru');
      await _type(tester, _key('account-passwordRetype'), 'rahasiabaru');
      await _tap(tester, _key('account-password-submit'));
      expect(find.text('Kata sandi saat ini salah.'), findsOneWidget);
      await _type(tester, _key('account-passwordCurrent'), 'rahasia123');
      await _tap(tester, _key('account-password-submit'));
      expect(_key('account-password-done'), findsOneWidget);
    });

    testWidgets('360: kasir PIN saja, tanpa izin users:manage', (
      tester,
    ) async {
      final kasir = sampleStaff(name: 'Sari', role: 'cashier');
      repo = FakeUsersRepository();
      repo.list = [
        sampleAccount('Sari', id: kasir.id),
        ...repo.list,
      ];
      await pumpLakuna(
        tester,
        size: const Size(360, 780),
        users: repo,
        session: FakeSessionRepository(staff: [kasir], current: kasir),
        initialLocation: Routes.account,
      );
      expect(_key('account-password-none'), findsOneWidget);
      expect(_key('account-pin-submit'), findsOneWidget);
      // Kasir tidak bisa membuka Pengguna & role.
      expect(menuEntryByPath(Routes.users)!.allows(kasir.permissions), isFalse);
      expect(
        menuEntryByPath(Routes.account)!.allows(kasir.permissions),
        isTrue,
      );
    });
  });
}
