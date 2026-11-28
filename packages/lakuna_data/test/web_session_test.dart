import 'dart:convert';
import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:test/test.dart';

import 'helpers.dart';
import 'testing/fake_sync_transport.dart';

/// Server palsu yang putus setelah [failAfter] halaman pull.
class _FlakyTransport extends FakeSyncTransport {
  _FlakyTransport({required super.serverTime});

  int? failAfter;
  final afterSeqs = <int>[];

  @override
  Future<SyncPullPage> pull(int afterSeq) async {
    afterSeqs.add(afterSeq);
    if (failAfter != null && afterSeqs.length > failAfter!) {
      throw const SocketException('putus');
    }
    final page = await super.pull(afterSeq);
    return page.copyWith(
      remaining: changes.where((c) => c.seq > page.nextSeq).length,
    );
  }
}

void main() {
  final now = DateTime.utc(2026, 11, 28, 8);
  late Directory dir;
  late _FlakyTransport transport;
  late UuidValue webDeviceId;

  setUp(() async {
    final (source, sourceDir) = await openTempStore();
    dir = sourceDir;
    final ctx = await setupTestStore(source);
    webDeviceId = UuidValue.fromString(newId());
    await source.write((w) async {
      final s = await w.stamp();
      await w.insert(
        Device(
          id: webDeviceId,
          tenantId: ctx.tenant.id,
          outletId: ctx.outlet.id,
          code: 'W01',
          name: 'Browser',
          platform: DevicePlatform.web,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    });
    await prepareInitialUpload(source, serverNow: now);
    transport = _FlakyTransport(serverTime: now)..pageSize = 2;
    for (final e in await SyncOutboxEntry.db.find(
      source.session,
      orderBy: (e) => e.id,
    )) {
      transport.addChange(
        e.entity,
        jsonDecode(e.payloadJson) as Map<String, dynamic>,
      );
    }
    await source.close();
  });

  tearDown(() => dir.delete(recursive: true));

  String path() => '${dir.path}/${webDatabaseName(webDeviceId)}';

  Future<void> join({List<(int, int?)>? progress}) => joinHostingWeb(
    databasePath: path(),
    deviceId: webDeviceId,
    deviceToken: 'token-web',
    serverUrl: 'https://toko.contoh.id/',
    transport: transport,
    onPull: progress == null ? null : (n, rest) => progress.add((n, rest)),
  );

  test('nama database per perangkat web (F2-02 aturan 6)', () {
    expect(webDatabaseName(webDeviceId), 'lakuna-${webDeviceId.uuid}.sqlite');
  });

  test(
    'gabung web: data ditarik, token di database, progres per halaman',
    () async {
      final total = transport.changes.length;
      expect(total, greaterThan(4));
      final progress = <(int, int?)>[];
      await join(progress: progress);
      expect(progress.first, (2, total - 2));
      expect(progress.last, (total, 0));
      final store = await LakunaStore.open(path(), media: MemoryMediaBlobs());
      addTearDown(store.close);
      expect(store.deviceId, webDeviceId);
      final ctx = (await loadStoreContext(store))!;
      expect(ctx.device.code, 'W01');
      expect(await StateTokenVault(store).readToken(), 'token-web');
      expect(
        await store.syncState(SyncStateKey.serverUrl),
        'https://toko.contoh.id/',
      );
      final outbox = await SyncOutboxEntry.db.count(store.session);
      expect(outbox, 0);
    },
  );

  test(
    'putus di tengah pull lalu dilanjutkan dari kursor (Fokus review 2)',
    () async {
      transport.failAfter = 1;
      await expectLater(join(), throwsA(isA<SyncOfflineException>()));
      transport.failAfter = null;
      transport.afterSeqs.clear();
      await join();
      expect(transport.afterSeqs.first, 2);
      final store = await LakunaStore.open(path(), media: MemoryMediaBlobs());
      addTearDown(store.close);
      expect(await loadStoreContext(store), isNotNull);
    },
  );

  test('sesi web disiapkan lalu dibaca lagi setelah tab ditutup '
      '(Fokus review 2)', () async {
    expect(await readWebSession(path()), isNull);
    await prepareWebSession(
      databasePath: path(),
      deviceId: webDeviceId,
      deviceToken: 'token-web',
      serverUrl: 'https://toko.contoh.id/',
    );
    final session = (await readWebSession(path()))!;
    expect(session.deviceId, webDeviceId);
    expect(session.deviceToken, 'token-web');
    expect(session.serverUrl, 'https://toko.contoh.id/');
    // Pull pertama memakai kredensial yang sama, tanpa perangkat baru.
    await join();
    expect((await readWebSession(path()))!.deviceToken, 'token-web');
  });

  test('deleteWebDatabase (native) menghapus berkas dan sufiksnya', () async {
    await join();
    for (final suffix in ['-wal', '-shm', '-journal']) {
      File('${path()}$suffix').writeAsStringSync('x');
    }
    await deleteWebDatabase(path());
    for (final suffix in ['', '-wal', '-shm', '-journal']) {
      expect(File('${path()}$suffix').existsSync(), isFalse, reason: suffix);
    }
  });
}
