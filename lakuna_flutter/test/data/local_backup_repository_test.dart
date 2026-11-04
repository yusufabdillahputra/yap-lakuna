import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
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
}
