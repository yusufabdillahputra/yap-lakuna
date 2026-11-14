import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/data/repositories/backup_repository.dart';
import 'package:lakuna_flutter/data/services/backup_files.dart';
import 'package:lakuna_domain/lakuna_domain.dart' show BackupPasswordProblem;
import 'package:lakuna_flutter/ui/settings/backup_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/fake_backup_repository.dart';

void main() {
  late FakeBackupRepository repo;
  late FakeBackupFiles files;
  late BackupViewModel vm;
  var restarts = 0;

  setUp(() async {
    repo = FakeBackupRepository(last: DateTime.utc(2026, 10, 26));
    files = FakeBackupFiles();
    restarts = 0;
    vm = BackupViewModel(
      repository: repo,
      files: files,
      restart: () async => restarts++,
      clock: () => DateTime.utc(2026, 11, 4, 9),
    );
    await vm.load.execute();
  });

  test('ringkasan dan pengingat', () {
    expect(vm.stats!.sales, 1240);
    expect(vm.lastBackupAt, DateTime.utc(2026, 10, 26));
    expect(vm.daysSinceBackup, 9);
    expect(vm.overdue, isTrue);
  });

  group('backup otomatis (F1-19d)', () {
    BackupViewModel make({required bool supported}) => BackupViewModel(
      repository: repo,
      files: files,
      clock: () => DateTime.utc(2026, 11, 4, 9),
      autoSupported: supported,
      autoFolder: () async => Directory('/docs/Lakuna/Backup/Otomatis'),
    );

    test('desktop: status, folder, sakelar', () async {
      repo
        ..autoLast = DateTime.utc(2026, 11, 2, 8)
        ..autoFailed = true;
      final desk = make(supported: true);
      await desk.load.execute();
      expect(desk.autoBackup!.enabled, isTrue);
      expect(desk.autoBackup!.failed, isTrue);
      expect(desk.daysSinceAutoBackup, 2);
      // Lokasi folder dimuat terpisah (layar tidak menunggu).
      await Future<void>.delayed(Duration.zero);
      expect(desk.autoFolderPath, '/docs/Lakuna/Backup/Otomatis');
      await desk.setAuto.execute(false);
      expect(repo.autoEnabled, isFalse);
      expect(desk.autoBackup!.enabled, isFalse);
    });

    test('waktu terakhir di masa depan: 0 hari, bukan negatif', () async {
      repo.autoLast = DateTime.utc(2026, 11, 7);
      final desk = make(supported: true);
      await desk.load.execute();
      expect(desk.daysSinceAutoBackup, 0);
    });

    test('ponsel: tidak dimuat', () async {
      final phone = make(supported: false);
      await phone.load.execute();
      expect(phone.autoBackup, isNull);
      expect(phone.autoFolderPath, isNull);
    });

    test('gagal mengubah sakelar: status tetap', () async {
      final desk = make(supported: true);
      await desk.load.execute();
      repo.nextError = const NotPermittedStub();
      await desk.setAuto.execute(false);
      expect(desk.setAuto.result, isA<Error<void>>());
      expect(desk.autoBackup!.enabled, isTrue);
    });
  });

  test('backup sekarang: simpan lalu catat waktu', () async {
    await vm.backupNow.execute();
    expect(files.delivered, ['lakuna-backup-PST-261104-1600.zip']);
    expect(vm.lastBackupAt, repo.now);
    expect(vm.overdue, isFalse);
    expect(vm.lastDelivery, isA<BackupSaved>());
  });

  test('share sheet ditutup: waktu backup tidak dicatat', () async {
    files.delivery = const BackupDismissed();
    await vm.backupNow.execute();
    expect(vm.lastBackupAt, DateTime.utc(2026, 10, 26));
    expect(vm.lastDelivery, isA<BackupDismissed>());
  });

  test('pulihkan: periksa, konfirmasi nama toko, lalu muat ulang', () async {
    await vm.pickRestore.execute();
    expect(vm.pendingRestore, sampleManifest());
    expect(vm.canConfirmRestore, isFalse);
    vm.setConfirmText('warung contoh ');
    expect(vm.canConfirmRestore, isTrue);
    await vm.restore.execute();
    expect(repo.staged, [files.picked]);
    expect(restarts, 1);
  });

  test('batal pilih berkas: tidak ada perubahan', () async {
    files.picked = null;
    await vm.pickRestore.execute();
    expect(vm.pendingRestore, isNull);
    expect(vm.pickRestore.error, isFalse);
  });

  test('berkas tidak sah: galat, tidak ada yang disiapkan', () async {
    repo.inspectError = const BackupInvalid('zip');
    await vm.pickRestore.execute();
    expect(vm.pendingRestore, isNull);
    expect(vm.pickRestore.error, isTrue);
    vm.setConfirmText('Warung Contoh');
    await vm.restore.execute();
    expect(repo.staged, isEmpty);
  });

  test('batal pulihkan mengosongkan pilihan', () async {
    await vm.pickRestore.execute();
    vm.setConfirmText('Warung Contoh');
    vm.cancelRestore();
    expect(vm.pendingRestore, isNull);
    expect(vm.confirmText, isEmpty);
  });

  group('kunci kata sandi (F1-19c)', () {
    test('sakelar mati: backup tanpa kata sandi', () async {
      expect(vm.lockEnabled, isFalse);
      expect(vm.passwordProblem, isNull);
      expect(vm.canBackup, isTrue);
      await vm.backupNow.execute();
      expect(repo.createdPasswords, [null]);
      expect(vm.lastBackupLocked, isFalse);
    });

    test('sakelar nyala: tombol menunggu kata sandi + ulangi', () async {
      vm.setLock(true);
      expect(vm.passwordProblem, BackupPasswordProblem.tooShort);
      expect(vm.canBackup, isFalse);
      await vm.backupNow.execute();
      expect(repo.createdPasswords, isEmpty);

      vm.setPassword('rahasia-toko');
      expect(vm.passwordProblem, BackupPasswordProblem.mismatch);
      vm.setPasswordRetype('rahasia-toko');
      expect(vm.passwordProblem, isNull);
      expect(vm.canBackup, isTrue);
      final revision = vm.passwordRevision;
      await vm.backupNow.execute();
      expect(repo.createdPasswords, ['rahasia-toko']);
      expect(vm.lastBackupLocked, isTrue);
      // Isian dikosongkan; kata sandi tidak disimpan di view model.
      expect(vm.password, isEmpty);
      expect(vm.passwordRetype, isEmpty);
      expect(vm.passwordRevision, greaterThan(revision));
      expect(vm.lockEnabled, isTrue);
      expect(vm.canBackup, isFalse);
    });

    test('share sheet ditutup: isian tetap untuk dicoba lagi', () async {
      files.delivery = const BackupDismissed();
      vm
        ..setLock(true)
        ..setPassword('rahasia-toko')
        ..setPasswordRetype('rahasia-toko');
      await vm.backupNow.execute();
      expect(vm.password, 'rahasia-toko');
      expect(vm.canBackup, isTrue);
    });

    test('sakelar dimatikan: isian dikosongkan', () {
      vm
        ..setLock(true)
        ..setPassword('rahasia-toko')
        ..setLock(false);
      expect(vm.password, isEmpty);
      expect(vm.canBackup, isTrue);
    });

    test('pulihkan backup terkunci: kata sandi salah lalu benar', () async {
      repo.lockPassword = 'rahasia-toko';
      await vm.pickRestore.execute();
      expect(vm.pickRestore.error, isFalse);
      expect(vm.needsPassword, isTrue);
      expect(vm.pendingRestore, isNull);
      expect(vm.canUnlock, isFalse);

      vm.setUnlockPassword('salah-sandi');
      expect(vm.canUnlock, isTrue);
      await vm.unlock.execute();
      expect(
        (vm.unlock.result! as Error<void>).error,
        isA<BackupWrongPassword>(),
      );
      expect(vm.needsPassword, isTrue);

      vm.setUnlockPassword('rahasia-toko');
      await vm.unlock.execute();
      expect(vm.needsPassword, isFalse);
      expect(vm.pendingRestore, sampleManifest());
      vm.setConfirmText('Warung Contoh');
      await vm.restore.execute();
      expect(repo.stagedPasswords, ['rahasia-toko']);
      expect(restarts, 1);
    });

    test('batal saat membuka kunci: hasil lama tidak dipakai', () async {
      repo.lockPassword = 'rahasia-toko';
      await vm.pickRestore.execute();
      vm.setUnlockPassword('rahasia-toko');
      final gate = Completer<void>();
      repo.inspectGate = gate.future;
      final pending = vm.unlock.execute();
      // Selama kunci dibuka, Pulihkan dan Backup tidak bisa ditekan.
      expect(vm.canBackup, isFalse);
      vm.cancelRestore();
      gate.complete();
      await pending;
      expect(vm.pendingRestore, isNull);
      expect(vm.needsPassword, isFalse);
      vm.setConfirmText('Warung Contoh');
      await vm.restore.execute();
      expect(repo.staged, isEmpty);
    });

    test('isian buka kunci dibuat ulang tiap berkas dipilih', () async {
      repo.lockPassword = 'rahasia-toko';
      await vm.pickRestore.execute();
      final first = vm.unlockRevision;
      vm.setUnlockPassword('salah');
      await vm.pickRestore.execute();
      expect(vm.unlockRevision, greaterThan(first));
      expect(vm.unlockPassword, isEmpty);
    });

    test('batal pulihkan mengosongkan kata sandi', () async {
      repo.lockPassword = 'rahasia-toko';
      await vm.pickRestore.execute();
      vm.setUnlockPassword('rahasia-toko');
      vm.cancelRestore();
      expect(vm.needsPassword, isFalse);
      expect(vm.unlockPassword, isEmpty);
    });
  });
}

class NotPermittedStub implements Exception {
  const NotPermittedStub();
}
