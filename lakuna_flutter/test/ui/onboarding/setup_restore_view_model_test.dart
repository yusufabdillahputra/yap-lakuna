import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/data/repositories/backup_repository.dart';
import 'package:lakuna_flutter/ui/onboarding/setup_restore_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/fake_backup_repository.dart';

void main() {
  late FakeBackupRepository repo;
  late FakeBackupFiles files;
  late SetupRestoreViewModel vm;
  late int restarts;

  setUp(() {
    repo = FakeBackupRepository();
    files = FakeBackupFiles();
    restarts = 0;
    vm = SetupRestoreViewModel(
      repository: repo,
      files: files,
      restart: () async => restarts++,
    );
  });

  tearDown(() => vm.dispose());

  test('pilih → ringkasan → ketik nama toko → siapkan & muat ulang', () async {
    await vm.pick.execute();
    expect(vm.manifest?.tenantName, 'Warung Contoh');
    expect(vm.canConfirm, isFalse);
    vm.setConfirmText('warung');
    expect(vm.canConfirm, isFalse);
    vm.setConfirmText('  warung CONTOH ');
    expect(vm.canConfirm, isTrue);
    await vm.restore.execute();
    expect(vm.restore.result, isA<Ok<void>>());
    expect(repo.staged, [files.picked]);
    expect(restarts, 1);
  });

  test('batal memilih tidak mengubah pilihan; galat berkas tampil', () async {
    await vm.pick.execute();
    files.picked = null;
    await vm.pick.execute();
    expect(vm.manifest, isNotNull);

    files.picked = '/tmp/rusak.zip';
    repo.inspectError = const BackupInvalid('rusak');
    await vm.pick.execute();
    expect(vm.manifest, isNull);
    expect(
      (vm.pick.result! as Error<void>).error,
      isA<BackupInvalid>(),
    );
    await vm.restore.execute();
    expect(repo.staged, isEmpty);
    expect(restarts, 0);
  });

  test('toko sudah ada atau gagal disiapkan: tidak dimuat ulang', () async {
    await vm.pick.execute();
    vm.setConfirmText('Warung Contoh');
    repo.nextError = const BackupTooNew('99999999999999999-baru');
    await vm.restore.execute();
    expect((vm.restore.result! as Error<void>).error, isA<BackupTooNew>());
    expect(restarts, 0);

    repo.storeExists = true;
    await vm.pick.execute();
    expect(
      (vm.pick.result! as Error<void>).error,
      isA<StoreAlreadySetUp>(),
    );
  });

  test(
    'dilepas saat aplikasi dimuat ulang: perintah selesai tanpa galat',
    () async {
      late SetupRestoreViewModel disposing;
      disposing = SetupRestoreViewModel(
        repository: repo,
        files: files,
        // Memuat ulang aplikasi melepas dialog beserta view model-nya.
        restart: () async => disposing.dispose(),
      );
      await disposing.pick.execute();
      disposing.setConfirmText('Warung Contoh');
      await disposing.restore.execute();
      expect(disposing.restore.result, isA<Ok<void>>());
      expect(repo.staged, hasLength(1));
    },
  );

  test('tanpa restart: backup siap, tidak bisa dipulihkan dua kali', () async {
    final manual = SetupRestoreViewModel(repository: repo, files: files);
    addTearDown(manual.dispose);
    await manual.pick.execute();
    manual.setConfirmText('Warung Contoh');
    await manual.restore.execute();
    expect(manual.staged, isTrue);
    expect(manual.canConfirm, isFalse);
    expect(manual.busy, isTrue);
  });
}
