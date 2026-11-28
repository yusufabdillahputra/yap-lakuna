import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/hosting_repository.dart';
import 'package:lakuna_flutter/data/repositories/local_hosting_repository.dart';
import 'package:lakuna_flutter/data/repositories/local_store_repository.dart';
import 'package:lakuna_flutter/data/repositories/repository_errors.dart';
import 'package:lakuna_flutter/data/repositories/session_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../testing/fake_hosting_connection.dart';
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
  late LakunaStore store;
  late FakeSessionRepository session;
  late LocalHostingRepository repo;
  late StaffProfile owner;
  final connections = <FakeHostingConnection>[];
  final now = DateTime.utc(2026, 11, 28, 8);

  setUp(() async {
    connections.clear();
    dir = await Directory.systemTemp.createTemp('lakuna_hosting_repo_');
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
    repo = LocalHostingRepository(
      store,
      stores: stores,
      session: session,
      appVersion: '0.166.0',
      lakunaServerUrl: '',
      clock: () => now,
      connect: (uri) {
        final c = FakeHostingConnection(uri);
        connections.add(c);
        return c;
      },
    );
  });

  tearDown(() async {
    await repo.stop();
    await store.close();
    await dir.delete(recursive: true);
  });

  StaffProfile cashier() => StaffProfile(
    id: owner.id,
    name: 'Rina',
    roleKey: 'cashier',
    isOwner: false,
    hasPin: true,
    permissions: Permission.values.toSet()..remove(Permission.syncManage),
  );

  test('tanpa LAKUNA_HOSTING_URL hanya server sendiri', () {
    expect(repo.lakunaServerUrl, isNull);
  });

  test(
    'alamat http bukan localhost ditolak sebelum menghubungi server',
    () async {
      expect(
        _err(await repo.checkServer('http://sync.contoh.id')),
        isA<InvalidServerUrl>(),
      );
      expect(connections, isEmpty);
    },
  );

  test(
    'aktivasi terputus setelah token tersimpan: ulang menyalakan sync',
    () async {
      // Token dan alamat sudah tersimpan, tetapi langkah sesudahnya gagal
      // (mis. disk penuh) sehingga sync belum menyala.
      await HostingVault.of(store).writeToken('token-aktivasi');
      await writeSyncState(
        store.session,
        SyncStateKey.serverUrl,
        'https://sync.contoh.id',
      );
      expect(store.afterWrite, isNull);
      _ok(
        await repo.activate('sync.contoh.id', activationCode: 'KODE2345'),
      );
      expect(store.afterWrite, isNotNull);
      expect(connections.last.transportToken, 'token-aktivasi');
    },
  );

  test(
    'aktivasi: token di brankas, sync menyala, sesi pemilik ditutup',
    () async {
      _ok(await repo.checkServer('sync.contoh.id'));
      _ok(
        await repo.login(
          'sync.contoh.id',
          email: 'ani@contoh.id',
          password: 'rahasia123',
        ),
      );
      // Satu koneksi per alamat selama aktivasi.
      expect(connections, hasLength(1));
      expect(connections.single.server.toString(), 'https://sync.contoh.id/');

      _ok(await repo.activate('sync.contoh.id', activationCode: 'KODE2345'));
      expect(connections.first.calls, contains('activate:KODE2345'));
      expect(connections.first.closed, isTrue);
      expect(await HostingVault.of(store).readToken(), 'token-aktivasi');

      final state = _ok(await repo.load());
      expect(state.active, isTrue);
      expect(state.serverUrl, 'https://sync.contoh.id/');
      // Koneksi sync baru memakai token perangkat.
      expect(connections.last.transportToken, 'token-aktivasi');
      expect(repo.status.kind, isNot(SyncChipKind.local));
      expect(store.afterWrite, isNotNull);
      // Gambar perangkat lain diunduh lewat koneksi sync (aturan 20).
      expect(store.fetchMedia, isNotNull);
      expect(connections.last.mediaToken, 'token-aktivasi');

      final share = _ok(await repo.createPairingCode());
      expect(share.code, 'ABCD2345');
      expect(share.shareText, 'https://sync.contoh.id#ABCD2345');
      expect(share.expiresAt, now.add(pairingCodeLifetime));
      expect(connections.last.calls, contains('pairing:token-aktivasi'));
    },
  );

  test('berhenti: unduhan gambar lewat server dilepas', () async {
    await HostingVault.of(store).writeToken('token-aktivasi');
    await writeSyncState(
      store.session,
      SyncStateKey.serverUrl,
      'https://sync.contoh.id',
    );
    await repo.start();
    expect(store.fetchMedia, isNotNull);
    await repo.stop();
    expect(store.fetchMedia, isNull);
  });

  test('jeda dan lanjutkan sync', () async {
    _ok(await repo.activate('sync.contoh.id', activationCode: 'KODE2345'));
    _ok(await repo.setPaused(true));
    expect(repo.status.kind, SyncChipKind.paused);
    expect(_ok(await repo.load()).paused, isTrue);
    _ok(await repo.setPaused(false));
    expect(_ok(await repo.load()).paused, isFalse);
    expect(repo.status.kind, isNot(SyncChipKind.paused));
  });

  test('kode pasang sebelum aktif ditolak', () async {
    expect(_err(await repo.createPairingCode()), isA<HostingNotActive>());
  });

  test('tanpa sync:manage ditolak', () async {
    session.current = cashier();
    expect(
      _err(await repo.activate('sync.contoh.id', activationCode: 'KODE2345')),
      isA<NotPermitted>(),
    );
    expect(_err(await repo.setPaused(true)), isA<NotPermitted>());
    expect(_err(await repo.createPairingCode()), isA<NotPermitted>());
    expect(
      _err(
        await repo.join(
          'sync.contoh.id',
          code: 'ABCD2345',
          outletId: UuidValue.fromString(newId()),
          deviceCode: 'K02',
          deviceName: 'Kasir 2',
        ),
      ),
      isA<NotPermitted>(),
    );
    expect(await HostingVault.of(store).readToken(), isNull);
  });

  test('gabung di perangkat yang sudah punya toko: backup dulu', () async {
    final result = await repo.join(
      'sync.contoh.id',
      code: 'ABCD2345',
      outletId: UuidValue.fromString(newId()),
      deviceCode: ' k02 ',
      deviceName: 'Kasir 2',
    );
    // Server palsu gagal setelah backup dibuat.
    expect(_err(result), isA<SyncOfflineException>());
    expect(connections.single.calls, containsAllInOrder(['status', 'join']));
    final backups = Directory('${dir.path}/data/backup-sebelum-gabung')
        .listSync()
        .map((e) => e.path.split('/').last)
        .toList();
    expect(backups, ['lakuna-backup-PST-261128-1500.zip']);
    // Database lama tetap dipakai.
    expect(await applyPendingJoin(store.path), isNull);
  });
}
