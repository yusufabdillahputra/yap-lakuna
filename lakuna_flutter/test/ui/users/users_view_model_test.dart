import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/session_repository.dart';
import 'package:lakuna_flutter/data/repositories/users_repository.dart';
import 'package:lakuna_flutter/ui/users/users_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/fake_session_repository.dart';
import '../../testing/fake_users_repository.dart';

void main() {
  group('UsersViewModel', () {
    late FakeUsersRepository repo;

    setUp(() => repo = FakeUsersRepository());

    Future<UsersViewModel> loaded({StaffProfile? actor}) async {
      final vm = UsersViewModel(
        repository: repo,
        actor: actor ?? sampleStaff(),
      );
      await vm.load.execute();
      return vm;
    }

    test('memuat pengguna, role, dan status kunci', () async {
      repo.locked[repo.list[2].id] = const Duration(seconds: 42);
      final vm = await loaded();
      expect(vm.accounts.map((a) => a.name), [
        'Yusuf',
        'Rina',
        'Sari',
        'Dimas',
      ]);
      expect(vm.activeCount, 3);
      expect(vm.roles.first.isOwner, isTrue);
      expect(vm.lockedFor(vm.accounts[2]), const Duration(seconds: 42));
      await vm.unlock.execute(vm.accounts[2].id);
      expect(vm.lockedFor(vm.accounts[2]), isNull);
    });

    test(
      'matriks: centang, kembali ke awal, simpan hanya yang berubah',
      () async {
        final vm = await loaded();
        final owner = vm.role('owner')!;
        expect(vm.canEdit(owner), isFalse);
        vm.toggle('owner', Permission.salesCreate);
        expect(vm.dirty, isFalse);

        vm.toggle('cashier', Permission.reportsView);
        expect(vm.permissionsOf('cashier'), contains(Permission.reportsView));
        expect(vm.dirty, isTrue);
        vm.toggle('cashier', Permission.reportsView);
        expect(vm.dirty, isFalse);

        vm.toggle('waiter', Permission.salesCreate);
        await vm.saveMatrix.execute();
        expect(vm.saveMatrix.completed, isTrue);
        expect(repo.calls, contains('matrix:waiter'));
        expect(vm.dirty, isFalse);
        expect(vm.role('waiter')!.permissions, {
          Permission.openBillsManage,
          Permission.salesCreate,
        });
      },
    );

    test('batalkan perubahan matriks', () async {
      final vm = await loaded();
      vm.toggle('cashier', Permission.reportsView);
      vm.discard();
      expect(vm.dirty, isFalse);
      expect(
        vm.permissionsOf('cashier'),
        DefaultRole.cashier.permissions,
      );
    });

    test('aktor bukan pemilik: tidak bisa mengubah role sendiri atau izin '
        'di luar miliknya', () async {
      final manager = StaffProfile(
        id: repo.list[1].id,
        name: 'Rina',
        roleKey: 'manager',
        isOwner: false,
        hasPin: true,
        permissions: {
          ...DefaultRole.manager.permissions,
          Permission.usersManage,
        },
      );
      final vm = await loaded(actor: manager);
      expect(vm.canEdit(vm.role('manager')!), isFalse);
      expect(vm.canEdit(vm.role('cashier')!), isTrue);
      expect(
        vm.canToggle(vm.role('cashier')!, Permission.backupManage),
        isFalse,
      );
      vm.toggle('cashier', Permission.backupManage);
      expect(vm.dirty, isFalse);
    });

    test('role custom: buat, ganti nama, hapus yang dipakai gagal', () async {
      final vm = await loaded();
      await vm.createRole.execute('Barista');
      expect(vm.roles.last.name, 'Barista');
      final key = vm.roles.last.key;
      await vm.renameRole.execute((key, 'Barista Pagi'));
      expect(vm.role(key)!.name, 'Barista Pagi');

      repo.list = [...repo.list, sampleAccount('Tono', role: key)];
      await vm.deleteRole.execute(key);
      expect(vm.deleteFailedKey, key);
      expect((vm.deleteRole.result! as Error).error, isA<RoleInUse>());

      repo.list = repo.list.where((a) => a.name != 'Tono').toList();
      await vm.deleteRole.execute(key);
      expect(vm.role(key), isNull);
    });

    test('galat memuat', () async {
      repo.failNext = const NotPermitted(Permission.usersManage);
      final vm = UsersViewModel(repository: repo, actor: sampleStaff());
      await vm.load.execute();
      expect(vm.load.error, isTrue);
    });
  });

  group('StaffFormViewModel', () {
    late FakeUsersRepository repo;
    late List<RoleSummary> roles;

    setUp(() async {
      repo = FakeUsersRepository();
      roles = ((await repo.roles()) as Ok<List<RoleSummary>>).value;
    });

    test('tambah: role pemilik tidak bisa dipilih, bawaan kasir', () {
      final vm = StaffFormViewModel(repository: repo, roles: roles);
      expect(vm.isNew, isTrue);
      expect(vm.roleKey, 'cashier');
      expect(vm.roles.map((r) => r.key), isNot(contains('owner')));
    });

    test('tambah: galat baru muncul setelah simpan; PIN tidak sama', () async {
      final vm = StaffFormViewModel(repository: repo, roles: roles);
      expect(vm.issues, isEmpty);
      await vm.save.execute();
      expect(vm.issues, {
        StaffFormField.name: StaffIssue.required,
        StaffFormField.pin: StaffIssue.invalidPin,
        StaffFormField.pinRetype: StaffIssue.required,
      });
      vm
        ..setName('Budi')
        ..setPin('112233')
        ..setPinRetype('112234');
      expect(vm.issues, {StaffFormField.pinRetype: StaffIssue.pinMismatch});
      vm.setPinRetype('112233');
      vm.setRole('stock_keeper');
      await vm.save.execute();
      expect(vm.save.completed, isTrue);
      expect(repo.calls.last, 'create:Budi:stock_keeper:112233:true');
    });

    test('tambah: nama sudah dipakai', () async {
      final vm = StaffFormViewModel(repository: repo, roles: roles)
        ..setName('sari')
        ..setPin('112233')
        ..setPinRetype('112233');
      await vm.save.execute();
      expect(vm.nameTaken, isTrue);
    });

    test('ubah: tanpa PIN, simpan nama/role/status', () async {
      final sari = repo.list[2];
      final vm = StaffFormViewModel(
        repository: repo,
        roles: roles,
        account: sari,
      );
      expect(vm.isNew, isFalse);
      expect(vm.name, 'Sari');
      vm
        ..setRole('manager')
        ..setActive(false);
      await vm.save.execute();
      expect(vm.save.completed, isTrue);
      expect(repo.calls.last, 'update:Sari:manager:false');
    });

    test(
      'reset PIN dengan ulangi; kolom dikosongkan setelah berhasil',
      () async {
        final sari = repo.list[2];
        repo.locked[sari.id] = const Duration(seconds: 30);
        final vm = StaffFormViewModel(
          repository: repo,
          roles: roles,
          account: sari,
        );
        vm
          ..setResetPin('654321')
          ..setResetRetype('654320');
        await vm.resetPin.execute();
        expect(vm.issues, {
          StaffFormField.resetRetype: StaffIssue.pinMismatch,
        });
        vm.setResetRetype('654321');
        await vm.resetPin.execute();
        expect(vm.resetPin.completed, isTrue);
        expect(vm.resetGeneration, 1);
        expect(vm.issues, isEmpty);
        expect(repo.locked, isEmpty);
      },
    );
  });

  group('MyAccountViewModel', () {
    late FakeUsersRepository repo;
    late MyAccountViewModel vm;

    setUp(() async {
      repo = FakeUsersRepository();
      vm = MyAccountViewModel(repository: repo);
      await vm.load.execute();
    });

    test('memuat akun sendiri', () {
      expect(vm.account!.name, 'Yusuf');
      expect(vm.account!.hasPassword, isTrue);
    });

    test('ganti PIN: wajib PIN saat ini, ulangi sama', () async {
      await vm.changePin.execute();
      expect(vm.issues, {
        MyAccountField.pinCurrent: StaffIssue.required,
        MyAccountField.pin: StaffIssue.invalidPin,
        MyAccountField.pinRetype: StaffIssue.required,
      });
      vm
        ..set(MyAccountField.pinCurrent, '000000')
        ..set(MyAccountField.pin, '246810')
        ..set(MyAccountField.pinRetype, '246810');
      await vm.changePin.execute();
      expect(
        (vm.changePin.result! as Error).error,
        isA<WrongCurrentSecret>(),
      );
      vm.set(MyAccountField.pinCurrent, '123456');
      await vm.changePin.execute();
      expect(vm.changePin.completed, isTrue);
      expect(vm.pinGeneration, 1);
      expect(vm.value(MyAccountField.pin), '');
    });

    test('ganti kata sandi: minimal 8 dan ulangi sama', () async {
      vm
        ..set(MyAccountField.passwordCurrent, 'rahasia123')
        ..set(MyAccountField.password, 'pendek')
        ..set(MyAccountField.passwordRetype, 'pendek');
      await vm.changePassword.execute();
      expect(vm.issues, {
        MyAccountField.password: StaffIssue.passwordTooShort,
      });
      vm
        ..set(MyAccountField.password, 'rahasiabaru')
        ..set(MyAccountField.passwordRetype, 'rahasiabaru!');
      await vm.changePassword.execute();
      expect(vm.issues, {
        MyAccountField.passwordRetype: StaffIssue.passwordMismatch,
      });
      vm.set(MyAccountField.passwordRetype, 'rahasiabaru');
      await vm.changePassword.execute();
      expect(vm.changePassword.completed, isTrue);
      expect(repo.calls.last, 'my-password:rahasiabaru');
    });
  });
}
