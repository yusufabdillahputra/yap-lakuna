import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/data/repositories/backup_repository.dart';
import 'package:lakuna_flutter/data/services/backup_files.dart';
import 'package:lakuna_flutter/ui/settings/backup_view_model.dart';

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
}
