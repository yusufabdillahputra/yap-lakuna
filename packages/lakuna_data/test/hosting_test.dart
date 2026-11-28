import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' show sha256;

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:test/test.dart';

import 'helpers.dart';
import 'testing/fake_hosting_client.dart';
import 'testing/fake_media_transport.dart';
import 'testing/fake_sync_transport.dart';

void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;

  setUp(() async {
    (store, dir) = await openTempStore();
    ctx = await setupTestStore(store);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test('tandai tenant hosted lewat outbox (aturan 14)', () async {
    await markTenantHosted(store, staffId: ctx.owner.id);
    final tenant = (await Tenant.db.findById(store.session, ctx.tenant.id))!;
    expect(tenant.plan, TenantPlan.hosted);
    expect(tenant.version, ctx.tenant.version + 1);
    final entries = await SyncOutboxEntry.db.find(
      store.session,
      where: (e) => e.entity.equals('tenants'),
      orderBy: (e) => e.id,
    );
    expect(entries.last.hlc, tenant.hlc);
  });

  test('perangkat gabungan: ID dari server, tanpa unggah awal', () async {
    final id = UuidValue.fromString('01900000-0000-7000-8000-0000000000b9');
    final joined = await openJoinedStore(
      '${dir.path}/gabung/lakuna.sqlite',
      deviceId: id,
    );
    addTearDown(joined.close);
    expect(joined.deviceId, id);
    expect(await joined.syncState(SyncStateKey.initialUpload), 'done');
    expect(await SyncOutboxEntry.db.count(joined.session), 0);
    expect(await Tenant.db.count(joined.session), 0);
  });

  test('brankas token: folder 700 dan berkas 600 di Linux/macOS', () async {
    final vault = HostingVault('${dir.path}/brankas');
    await vault.writeToken('rahasia');
    expect(await vault.readToken(), 'rahasia');
    int mode(String path) => FileStat.statSync(path).mode & 0x1ff;
    expect(mode('${dir.path}/brankas/hosting'), 0x1c0);
    expect(mode('${dir.path}/brankas/hosting/device-token'), 0x180);
  }, skip: Platform.isLinux || Platform.isMacOS ? false : 'hanya POSIX');

  test('perangkat gabungan menolak berkas database yang sudah ada', () async {
    await expectLater(
      openJoinedStore(
        store.path,
        deviceId: UuidValue.fromString('01900000-0000-7000-8000-0000000000b9'),
      ),
      throwsStateError,
    );
  });

  group('versi hosting (tahap 3)', () {
    late FakeHostingClient client;
    final now = DateTime.utc(2026, 11, 28, 8);

    setUp(() {
      client = FakeHostingClient(serverTime: now);
    });

    Future<StaffMember> addCashier() {
      final actor = ctx.owner.id;
      return store.write(actor: actor, (w) async {
        final s = await w.stamp();
        final staff = await w.insert(
          StaffMember(
            tenantId: ctx.tenant.id,
            name: 'Sari',
            pinHash: r'$argon2id$x',
            isActive: true,
            createdBy: actor,
            updatedBy: actor,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
        await w.insert(
          OutletMember(
            tenantId: ctx.tenant.id,
            outletId: ctx.outlet.id,
            staffMemberId: staff.id,
            roleName: 'cashier',
            createdBy: actor,
            updatedBy: actor,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
        return staff;
      });
    }

    Future<void> activate({UuidValue? staffId}) => activateHosting(
      store,
      ctx,
      staffId: staffId ?? ctx.owner.id,
      serverUrl: 'https://sync.contoh.id',
      activationCode: 'KODE2345',
      client: client,
      appVersion: '0.166.0',
    );

    test('belum aktif: status kosong', () async {
      final state = await loadHostingState(store);
      expect(state.active, isFalse);
      expect(state.serverUrl, isNull);
      expect(state.pending, greaterThan(0));
    });

    test('server dengan protokol lebih lama ditolak', () async {
      client.protocolVersion = syncProtocolVersion - 1;
      await expectLater(
        checkHostingServer(client, appVersion: '0.166.0'),
        throwsA(isA<HostingServerTooOld>()),
      );
    });

    test('server meminta versi aplikasi lebih baru: ditolak', () async {
      client.minAppVersion = '0.170.0';
      await expectLater(
        checkHostingServer(client, appVersion: '0.166.0'),
        throwsA(isA<HostingAppTooOld>()),
      );
      // Build lokal tanpa nomor versi tidak ditolak.
      await checkHostingServer(client, appVersion: 'dev');
      client.minAppVersion = '0.166.0';
      final status = await checkHostingServer(client, appVersion: '0.166.0');
      expect(status.serverVersion, '0.166.0');
    });

    test('staf tanpa sync:manage tidak bisa mengaktifkan', () async {
      final kasir = await addCashier();
      await expectLater(
        activate(staffId: kasir.id),
        throwsA(isA<HostingNotPermitted>()),
      );
      expect(client.calls, isEmpty);
      expect((await loadHostingState(store)).active, isFalse);
    });

    test(
      'aktivasi: token di brankas, tenant hosted, outbox dipadatkan',
      () async {
        await activate();
        final a = client.activated!;
        expect(a.tenantId, ctx.tenant.id);
        expect(a.deviceId, store.deviceId);
        expect(a.tenantName, ctx.tenant.name);
        expect(a.deviceCode, ctx.device.code);
        expect(a.activationCode, 'KODE2345');
        expect(await HostingVault.of(store).readToken(), 'token-aktivasi');
        // Token tidak disimpan di database (ikut backup).
        final keys = [
          for (final e in await SyncStateEntry.db.find(store.session)) e.value,
        ];
        expect(keys, isNot(contains('token-aktivasi')));
        final tenant = (await Tenant.db.findById(
          store.session,
          ctx.tenant.id,
        ))!;
        expect(tenant.plan, TenantPlan.hosted);
        expect(await store.syncState(SyncStateKey.initialUpload), 'done');
        final tenants = await SyncOutboxEntry.db.find(
          store.session,
          where: (e) => e.entity.equals('tenants'),
        );
        expect(tenants.single.payloadJson, contains('"plan":"hosted"'));
        final state = await loadHostingState(store);
        expect(state.active, isTrue);
        expect(state.serverUrl, 'https://sync.contoh.id');
        expect(state.pending, greaterThan(0));
      },
    );

    test('aktivasi ditolak server: perangkat tetap belum aktif', () async {
      client.failWith = ActivationException(reason: ActivationFailure.codeUsed);
      await expectLater(activate(), throwsA(isA<ActivationException>()));
      expect(await HostingVault.of(store).readToken(), isNull);
      final tenant = (await Tenant.db.findById(store.session, ctx.tenant.id))!;
      expect(tenant.plan, TenantPlan.free);
      expect((await loadHostingState(store)).active, isFalse);
    });

    test('aktivasi kedua ditolak', () async {
      await activate();
      await expectLater(activate(), throwsA(isA<HostingAlreadyActive>()));
    });

    test('kode pasang memakai token perangkat dan butuh sync:manage', () async {
      final kasir = await addCashier();
      await expectLater(
        createHostingPairingCode(
          store,
          ctx,
          staffId: ctx.owner.id,
          client: client,
        ),
        throwsA(isA<HostingNotActive>()),
      );
      await activate();
      await expectLater(
        createHostingPairingCode(store, ctx, staffId: kasir.id, client: client),
        throwsA(isA<HostingNotPermitted>()),
      );
      final code = await createHostingPairingCode(
        store,
        ctx,
        staffId: ctx.owner.id,
        client: client,
      );
      expect(code, 'ABCD2345');
      expect(client.pairingToken, 'token-aktivasi');
    });

    test('jeda sync: siklus tidak memanggil server', () async {
      await activate();
      await setSyncPaused(store, ctx, staffId: ctx.owner.id, paused: true);
      expect((await loadHostingState(store)).paused, isTrue);
      final transport = FakeSyncTransport(serverTime: now);
      final r = await runHostingCycle(SyncEngine(store, transport));
      expect(r.outcome, SyncCycleOutcome.paused);
      expect(transport.pushed, isEmpty);
      await setSyncPaused(store, ctx, staffId: ctx.owner.id, paused: false);
      final again = await runHostingCycle(SyncEngine(store, transport));
      expect(again.outcome, SyncCycleOutcome.synced);
      expect(transport.pushed, isNotEmpty);
    });

    test(
      'progres unggah awal selesai: perubahan baru tidak memunculkannya lagi',
      () async {
        await activate();
        var progress = await initialUploadProgress(store);
        expect(progress.any((g) => g.acked < g.total), isTrue);
        final transport = FakeSyncTransport(serverTime: now);
        final r = await runHostingCycle(SyncEngine(store, transport));
        expect(r.outcome, SyncCycleOutcome.synced);
        expect(r.pending, 0);
        // Penjualan/perubahan setelah unggah awal: cukup *N perubahan
        // menunggu*, bukan daftar unggah awal per kelompok lagi.
        await addCashier();
        progress = await initialUploadProgress(store);
        expect(progress, isEmpty);
      },
    );

    test('perangkat gabungan tidak menampilkan progres unggah awal', () async {
      final joined = await openJoinedStore(
        '${dir.path}/gabung/lakuna.sqlite',
        deviceId: UuidValue.fromString('01900000-0000-7000-8000-0000000000b9'),
      );
      addTearDown(joined.close);
      expect(await initialUploadProgress(joined), isEmpty);
    });

    test('siklus mengunggah berkas media setelah barisnya di-push', () async {
      await activate();
      final bytes = Uint8List.fromList([1, 2, 3]);
      final key = '${sha256.convert(bytes)}.png';
      final file = await File('${store.mediaDirectory}/$key')
          .create(recursive: true);
      file.writeAsBytesSync(bytes);
      final media = await store.write(actor: ctx.owner.id, (w) async {
        final s = await w.stamp();
        return w.insert(
          MediaFile(
            tenantId: ctx.tenant.id,
            kind: MediaKind.qrisSticker,
            fileName: 'qris.png',
            mimeType: 'image/png',
            sizeBytes: 3,
            sha256: sha256.convert(bytes).toString(),
            width: 1,
            height: 1,
            storageKey: key,
            createdAt: s.now,
            updatedAt: s.now,
            createdBy: s.actor,
            updatedBy: s.actor,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
      });
      final transport = FakeSyncTransport(serverTime: now);
      final mediaServer = FakeMediaTransport(ctx.tenant.id)
        ..rows[media.id] = media;
      final r = await runHostingCycle(
        SyncEngine(store, transport),
        media: mediaServer,
      );
      expect(r.outcome, SyncCycleOutcome.synced);
      expect(mediaServer.uploads, ['${ctx.tenant.id.uuid}/$key']);
    });

    test('siklus melanjutkan pemadatan yang terputus', () async {
      await activate();
      // Seolah aplikasi ditutup sebelum pemadatan selesai.
      await writeSyncState(
        store.session,
        SyncStateKey.initialUpload,
        'pending',
      );
      await writeSyncState(
        store.session,
        SyncStateKey.initialUploadCursor,
        '0:',
      );
      final transport = FakeSyncTransport(serverTime: now);
      final r = await runHostingCycle(SyncEngine(store, transport));
      expect(r.outcome, SyncCycleOutcome.synced);
      expect(await store.syncState(SyncStateKey.initialUpload), 'done');
    });

    test('pulih backup mematikan sync dan menghapus token', () async {
      await activate();
      final zip = '${dir.path}/b.zip';
      await createBackup(store, ctx, outPath: zip, appVersion: '0.166.0');
      final dataDir = File(store.path).parent.path;
      await stageRestore(
        zip,
        dataDir: dataDir,
        knownVersions: lakunaSchemaVersions,
      );
      await store.close();
      await applyPendingRestore(dataDir);
      store = await LakunaStore.open('$dataDir/lakuna.sqlite');
      await finishRestore(store);
      expect((await loadHostingState(store)).active, isFalse);
      expect(await HostingVault.of(store).readToken(), isNull);
    });

    test(
      'mematikan versi hosting mengulang unggah awal di aktivasi berikutnya',
      () async {
        await activate();
        final transport = FakeSyncTransport(serverTime: now);
        await runHostingCycle(SyncEngine(store, transport));
        expect(await store.syncState(SyncStateKey.initialUpload), 'done');
        await disableHosting(store);
        for (final key in [
          SyncStateKey.initialUpload,
          SyncStateKey.initialUploadCursor,
          SyncStateKey.initialUploadAcked,
          SyncStateKey.restampHlc,
          SyncStateKey.pullCursor,
          SyncStateKey.pullParked,
          SyncStateKey.syncPaused,
          SyncStateKey.lastError,
          SyncStateKey.lastSyncAt,
        ]) {
          expect(await store.syncState(key), isNull, reason: key.key);
        }
        // Server baru: semua data diunggah lagi dari awal.
        client = FakeHostingClient(serverTime: now);
        await activate();
        final pending = await SyncOutboxEntry.db.count(
          store.session,
          where: (e) => e.status.equals(OutboxStatus.pending),
        );
        expect(pending, greaterThan(0));
      },
    );

    group('gabung', () {
      late LakunaStore source;
      late Directory sourceDir;
      late FakeSyncTransport transport;
      late String joinPath;

      setUp(() async {
        (source, sourceDir) = await openTempStore();
        final sctx = await setupTestStore(source);
        // Baris perangkat baru dibuat server saat pasang.
        await source.write((w) async {
          final s = await w.stamp();
          await w.insert(
            Device(
              id: client.joinedDeviceId,
              tenantId: sctx.tenant.id,
              outletId: sctx.outlet.id,
              code: 'K02',
              name: 'Kasir 2',
              platform: DevicePlatform.android,
              hlc: s.hlc.toString(),
              originDeviceId: s.deviceId,
            ),
            s,
          );
        });
        await prepareInitialUpload(source, serverNow: now);
        transport = FakeSyncTransport(serverTime: now);
        for (final e in await SyncOutboxEntry.db.find(
          source.session,
          orderBy: (e) => e.id,
        )) {
          transport.addChange(
            e.entity,
            jsonDecode(e.payloadJson) as Map<String, dynamic>,
          );
        }
        joinPath = '${dir.path}/gabung-uji/lakuna.sqlite';
      });

      tearDown(() async {
        await source.close();
        await sourceDir.delete(recursive: true);
      });

      Future<void> join({required Future<void> Function() backup}) =>
          joinHosting(
            databasePath: joinPath,
            serverUrl: 'https://sync.contoh.id',
            client: client,
            transport: (token) {
              expect(token, 'token-gabung');
              return transport;
            },
            appVersion: '0.166.0',
            pairingCode: 'ABCD2345',
            outletId: ctx.outlet.id,
            deviceCode: 'K02',
            deviceName: 'Kasir 2',
            platform: DevicePlatform.android,
            backupFirst: backup,
          );

      test('backup dibuat lebih dulu; gagal backup = tidak gabung', () async {
        await expectLater(
          join(backup: () async => throw const FileSystemException('penuh')),
          throwsA(isA<FileSystemException>()),
        );
        expect(client.calls, isNot(contains('join')));
        bool? joinedBeforeBackup;
        await join(
          backup: () async =>
              joinedBeforeBackup = client.calls.contains('join'),
        );
        expect(joinedBeforeBackup, isFalse);
        expect(client.calls, contains('join'));
      });

      test(
        'database baru: ID perangkat dari server, data dari server',
        () async {
          await File(joinPath).parent.create(recursive: true);
          final old = await LakunaStore.open(joinPath);
          final oldId = old.deviceId;
          await setupTestStore(old, outletCode: 'LMA', email: 'lama@contoh.id');
          await old.close();
          await join(backup: () async {});
          // Database lama belum diganti sampai aplikasi dimulai ulang.
          expect(File(joinPath).existsSync(), isTrue);
          final kept = await applyPendingJoin(joinPath);
          expect(kept, isNotNull);
          expect(File('$kept/lakuna.sqlite').existsSync(), isTrue);
          final joined = await LakunaStore.open(joinPath);
          addTearDown(joined.close);
          expect(joined.deviceId, client.joinedDeviceId);
          expect(joined.deviceId, isNot(oldId));
          final jctx = (await loadStoreContext(joined))!;
          expect(jctx.device.code, 'K02');
          expect(jctx.outlet.code, 'PST');
          expect(await HostingVault.of(joined).readToken(), 'token-gabung');
          final state = await loadHostingState(joined);
          expect(state.active, isTrue);
          expect(state.serverUrl, 'https://sync.contoh.id');
          expect(state.pending, 0);
          expect(await applyPendingJoin(joinPath), isNull);
        },
      );

      test('pull gagal: tidak ada gabung yang tertunda', () async {
        transport.offline = true;
        await expectLater(
          join(backup: () async {}),
          throwsA(isA<SyncOfflineException>()),
        );
        expect(await applyPendingJoin(joinPath), isNull);
        transport.offline = false;
        await join(backup: () async {});
        expect(await applyPendingJoin(joinPath), isNotNull);
      });

      test(
        'gabung putus di tengah pull dilanjutkan tanpa memakai kode lagi',
        () async {
          transport.offline = true;
          await expectLater(
            join(backup: () async {}),
            throwsA(isA<SyncOfflineException>()),
          );
          transport.offline = false;
          // Kode pasang sudah terpakai di server: ulang tidak boleh pasang
          // perangkat kedua (kode perangkat bentrok, perangkat hantu).
          await join(backup: () async {});
          expect(client.calls.where((c) => c == 'join'), hasLength(1));
          expect(await applyPendingJoin(joinPath), isNotNull);
        },
      );
    });
  });
}
