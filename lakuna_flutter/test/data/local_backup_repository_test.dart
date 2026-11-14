import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/backup_repository.dart'
    show StoreAlreadySetUp;
import 'package:lakuna_flutter/data/repositories/local_backup_repository.dart';
import 'package:lakuna_flutter/data/repositories/local_store_repository.dart';
import 'package:lakuna_flutter/data/repositories/session_repository.dart';
import 'package:lakuna_flutter/data/repositories/suppliers_repository.dart'
    show NotPermitted;
import 'package:lakuna_flutter/utils/result.dart';

import '../testing/fake_session_repository.dart';

SetupInput _input() => SetupInput(
  businessType: BusinessKind.retail,
  businessName: 'Toko Bu Ani',
  outletName: 'Cabang Pusat',
  outletCode: 'PST',
  deviceCode: 'K01',
  timezone: 'Asia/Jakarta',
  ownerName: 'Ani',
  email: 'ani@contoh.id',
  password: 'rahasia123',
  passwordConfirm: 'rahasia123',
  pin: '123456',
  pinConfirm: '123456',
);

T _ok<T>(Result<T> result) => (result as Ok<T>).value;
Exception _err<T>(Result<T> result) => (result as Error<T>).error;

void main() {
  late Directory dir;
  late Directory exports;
  late LakunaStore store;
  late FakeSessionRepository session;
  late LocalBackupRepository repo;
  late StaffProfile owner;
  final now = DateTime.utc(2026, 11, 4, 9, 30);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('lakuna_backup_repo_');
    exports = Directory('${dir.path}/ekspor');
    Directory('${dir.path}/data').createSync();
    store = await LakunaStore.open('${dir.path}/data/lakuna.sqlite');
    final stores = LocalStoreRepository(
      store,
      hasher: const CredentialHasher.forTesting(),
      platform: DevicePlatform.linux,
    );
    final ctx = _ok(await stores.setup(_input()));
    owner = StaffProfile(
      id: ctx.owner.id,
      name: ctx.owner.name,
      roleKey: 'owner',
      isOwner: true,
      hasPin: true,
      permissions: Permission.values.toSet(),
    );
    session = FakeSessionRepository(staff: [owner])..current = owner;
    repo = LocalBackupRepository(
      store,
      stores: stores,
      session: session,
      preferences: LocalPreferences(store.session),
      appVersion: '0.25.0',
      clock: () => now,
      exportDirectory: exports,
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test('backup, catat waktu, periksa, lalu siapkan pulihkan', () async {
    expect(_ok(await repo.load()).lastBackupAt, isNull);
    final created = _ok(await repo.createBackup());
    expect(created.fileName, 'lakuna-backup-PST-261104-1630.zip');
    expect(File(created.path).existsSync(), isTrue);

    expect(_ok(await repo.recordBackup()), now);
    expect(await repo.lastBackupAt(), now);

    final manifest = _ok(await repo.inspect(created.path));
    expect(manifest.tenantName, 'Toko Bu Ani');
    _ok(await repo.stageRestore(created.path));
    expect(hasPendingRestore('${dir.path}/data'), isTrue);
  });

  test('backup terkunci kata sandi (F1-19c)', () async {
    final created = _ok(await repo.createBackup(password: 'rahasia-toko'));
    expect(created.locked, isTrue);
    expect(_err(await repo.inspect(created.path)), isA<BackupLocked>());
    expect(
      _err(await repo.inspect(created.path, password: 'salah-sandi')),
      isA<BackupWrongPassword>(),
    );
    expect(
      _ok(
        await repo.inspect(created.path, password: 'rahasia-toko'),
      ).tenantName,
      'Toko Bu Ani',
    );
    expect(_err(await repo.stageRestore(created.path)), isA<BackupLocked>());
    expect(hasPendingRestore('${dir.path}/data'), isFalse);
    _ok(await repo.stageRestore(created.path, password: 'rahasia-toko'));
    expect(hasPendingRestore('${dir.path}/data'), isTrue);
    expect(_ok(await repo.createBackup()).locked, isFalse);
  });

  test('backup baru menghapus salinan sementara sebelumnya', () async {
    final first = _ok(await repo.createBackup());
    File('${exports.path}/sisa.zip').writeAsStringSync('x');
    final second = _ok(await repo.createBackup());
    expect(exports.listSync().map((e) => e.path), [second.path]);
    expect(first.path, second.path);
  });

  test('tanpa backup:manage ditolak', () async {
    session.current = StaffProfile(
      id: owner.id,
      name: 'Rina',
      roleKey: 'manager',
      isOwner: false,
      hasPin: true,
      permissions: Permission.values.toSet()..remove(Permission.backupManage),
    );
    expect(_err(await repo.load()), isA<NotPermitted>());
    expect(_err(await repo.createBackup()), isA<NotPermitted>());
    expect(_err(await repo.recordBackup()), isA<NotPermitted>());
    expect(_err(await repo.stageRestore('/tmp/x.zip')), isA<NotPermitted>());
    expect(exports.existsSync(), isFalse);
  });

  group('backup otomatis (F1-19d)', () {
    late Directory auto;
    setUp(() => auto = Directory('${dir.path}/Otomatis'));

    test('bawaan menyala; jalan tanpa staf; catat waktu', () async {
      final state = await repo.autoBackup();
      expect(state.enabled, isTrue);
      expect(state.lastAt, isNull);
      expect(state.failed, isFalse);

      session.current = null;
      final path = _ok(await repo.runAutoBackup(auto));
      expect(path, '${auto.path}/lakuna-backup-PST-261104-1630.zip');
      expect(File(path).existsSync(), isTrue);
      session.current = owner;
      expect(_ok(await repo.inspect(path)).tenantName, 'Toko Bu Ani');
      expect((await repo.autoBackup()).lastAt, now);
      // Backup otomatis juga mengisi *Backup terakhir* (pengingat Beranda).
      expect(await repo.lastBackupAt(), now);
      // Salinan sementara backup manual tidak disentuh.
      expect(exports.existsSync(), isFalse);
    });

    test('pangkas ke 7 berkas terbaru, berkas lain tetap', () async {
      auto.createSync(recursive: true);
      for (var d = 1; d <= 8; d++) {
        final day = d.toString().padLeft(2, '0');
        File(
          '${auto.path}/lakuna-backup-PST-2611$day-0100.zip',
        ).writeAsStringSync('lama');
      }
      File('${auto.path}/catatan.txt').writeAsStringSync('punya pemilik');
      _ok(await repo.runAutoBackup(auto));
      final names = auto.listSync().map((e) => e.uri.pathSegments.last).toList()
        ..sort();
      expect(names, [
        'catatan.txt',
        'lakuna-backup-PST-261103-0100.zip',
        'lakuna-backup-PST-261104-0100.zip',
        'lakuna-backup-PST-261104-1630.zip',
        'lakuna-backup-PST-261105-0100.zip',
        'lakuna-backup-PST-261106-0100.zip',
        'lakuna-backup-PST-261107-0100.zip',
        'lakuna-backup-PST-261108-0100.zip',
      ]);
    });

    test('pangkas menurut waktu, bukan kode cabang', () async {
      auto.createSync(recursive: true);
      // Kode cabang lama "ZZZ" (diurutkan lebih dulu menurut nama) lebih
      // tua daripada berkas "AAA": yang dibuang tetap yang tertua.
      for (var d = 1; d <= 4; d++) {
        File(
          '${auto.path}/lakuna-backup-ZZZ-26100$d-0100.zip',
        ).writeAsStringSync('lama');
        File(
          '${auto.path}/lakuna-backup-AAA-26110$d-0100.zip',
        ).writeAsStringSync('baru');
      }
      _ok(await repo.runAutoBackup(auto));
      final names = auto.listSync().map((e) => e.uri.pathSegments.last).toSet();
      expect(names, hasLength(7));
      expect(names, contains('lakuna-backup-PST-261104-1630.zip'));
      for (var d = 1; d <= 4; d++) {
        expect(names, contains('lakuna-backup-AAA-26110$d-0100.zip'));
      }
      expect(names, isNot(contains('lakuna-backup-ZZZ-261001-0100.zip')));
      expect(names, isNot(contains('lakuna-backup-ZZZ-261002-0100.zip')));
    });

    test('salinan setengah jadi dibuang; tidak ada yang dipangkas', () async {
      auto.createSync(recursive: true);
      for (var d = 1; d <= 8; d++) {
        File(
          '${auto.path}/lakuna-backup-PST-26110$d-0100.zip',
        ).writeAsStringSync('lama');
      }
      // Nama tujuan sudah dipakai folder: ganti nama dari `.part` gagal.
      Directory('${auto.path}/lakuna-backup-PST-261104-1630.zip').createSync();
      expect(await repo.runAutoBackup(auto), isA<Error<String>>());
      expect(
        File('${auto.path}/lakuna-backup-PST-261104-1630.zip.part')
            .existsSync(),
        isFalse,
      );
      final zips = auto.listSync().whereType<File>().toList();
      expect(zips, hasLength(8));
      expect((await repo.autoBackup()).failed, isTrue);
      expect(Directory('${exports.path}-otomatis').existsSync(), isFalse);
    });

    test('gagal dicatat lalu bersih setelah berhasil', () async {
      // Folder tujuan berupa berkas: tidak bisa ditulis.
      final blocked = File('${dir.path}/bukan-folder')..writeAsStringSync('x');
      expect(
        await repo.runAutoBackup(Directory(blocked.path)),
        isA<Error<String>>(),
      );
      final failed = await repo.autoBackup();
      expect(failed.failed, isTrue);
      expect(failed.lastAt, isNull);
      expect(await repo.lastBackupAt(), isNull);
      _ok(await repo.runAutoBackup(auto));
      expect((await repo.autoBackup()).failed, isFalse);
    });

    test('sakelar butuh backup:manage', () async {
      _ok(await repo.setAutoBackup(false));
      expect((await repo.autoBackup()).enabled, isFalse);
      session.current = null;
      expect(_err(await repo.setAutoBackup(true)), isA<NotPermitted>());
      expect((await repo.autoBackup()).enabled, isFalse);
    });
  });

  test(
    'pulihkan dari onboarding: hanya sebelum toko dibuat (F1-19b)',
    () async {
      final created = _ok(await repo.createBackup());
      // Toko sudah ada di perangkat ini: ditolak walau tanpa staf login.
      session.current = null;
      expect(
        _err(await repo.inspectForSetup(created.path)),
        isA<StoreAlreadySetUp>(),
      );
      expect(
        _err(await repo.stageRestoreForSetup(created.path)),
        isA<StoreAlreadySetUp>(),
      );
      expect(hasPendingRestore('${dir.path}/data'), isFalse);

      // Perangkat baru yang belum punya toko.
      Directory('${dir.path}/baru').createSync();
      final fresh = await LakunaStore.open('${dir.path}/baru/lakuna.sqlite');
      addTearDown(fresh.close);
      final freshRepo = LocalBackupRepository(
        fresh,
        stores: LocalStoreRepository(
          fresh,
          hasher: const CredentialHasher.forTesting(),
          platform: DevicePlatform.linux,
        ),
        session: FakeSessionRepository(staff: const []),
        preferences: LocalPreferences(fresh.session),
        appVersion: '0.45.0',
        clock: () => now,
        exportDirectory: exports,
      );
      expect(
        _ok(await freshRepo.inspectForSetup(created.path)).tenantName,
        'Toko Bu Ani',
      );
      File('${dir.path}/bukan.zip').writeAsStringSync('bukan zip');
      expect(
        _err(await freshRepo.inspectForSetup('${dir.path}/bukan.zip')),
        isA<BackupInvalid>(),
      );
      _ok(await freshRepo.stageRestoreForSetup(created.path));
      expect(hasPendingRestore('${dir.path}/baru'), isTrue);
    },
  );
}
