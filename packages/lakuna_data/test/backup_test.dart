import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late LakunaStore store;
  late Directory dir;
  late Directory out;
  late StoreContext ctx;
  late DateTime now;

  final versions = lakunaSchemaVersions;

  setUp(() async {
    now = DateTime.utc(2026, 11, 4, 9, 30);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    out = await Directory.systemTemp.createTemp('lakuna_backup_out_');
    await saveProduct(
      store,
      CatalogScope.of(ctx),
      staffId: ctx.owner.id,
      draft: const ProductDraft(
        name: 'Kopi Sachet',
        baseUnit: 'sachet',
        variants: [
          VariantDraft(
            costPrice: Money(1500),
            sellPrice: Money(2000),
            openingStock: Qty(10000),
          ),
        ],
      ),
    );
    final media = Directory(store.mediaDirectory);
    await media.create(recursive: true);
    await File('${media.path}/abc.png').writeAsBytes(pngBytes(4, 4));
  });

  /// Menyalin zip [path] ke [name] dengan isi diubah [edit] dan entri
  /// tambahan [extra].
  Future<String> rezip(
    String path,
    String name, {
    List<int> Function(String name, List<int> bytes)? edit,
    Map<String, List<int>> extra = const {},
  }) async {
    final input = InputFileStream(path);
    final archive = ZipDecoder().decodeStream(input);
    final target = '${out.path}/$name';
    final enc = ZipFileEncoder()..create(target);
    for (final f in archive.files) {
      final bytes = f.content.toList();
      enc.addArchiveFile(
        ArchiveFile.bytes(f.name, edit?.call(f.name, bytes) ?? bytes),
      );
    }
    for (final MapEntry(:key, :value) in extra.entries) {
      enc.addArchiveFile(ArchiveFile.bytes(key, value));
    }
    await enc.close();
    await archive.clear();
    await input.close();
    return target;
  }

  tearDown(() async {
    await store.close();
    if (dir.existsSync()) await dir.delete(recursive: true);
    if (out.existsSync()) await out.delete(recursive: true);
  });

  Future<(String, BackupManifest)> backup() async {
    final path = '${out.path}/${backupFileName(ctx, now)}';
    final manifest = await createBackup(
      store,
      ctx,
      outPath: path,
      appVersion: '0.25.0',
      now: now,
    );
    return (path, manifest);
  }

  test('statistik: nota, produk, ukuran database + gambar', () async {
    final stats = await backupStats(store, ctx);
    expect(stats.sales, 0);
    expect(stats.products, 1);
    expect(
      stats.sizeBytes,
      File(store.path).lengthSync() + pngBytes(4, 4).length,
    );
  });

  test('nama berkas memuat kode cabang dan waktu lokal', () {
    expect(backupFileName(ctx, now), 'lakuna-backup-PST-261104-1630.zip');
  });

  test('backup: manifest, database konsisten, dan gambar', () async {
    final (path, manifest) = await backup();
    expect(manifest.app, 'lakuna');
    expect(manifest.format, 1);
    expect(manifest.appVersion, '0.25.0');
    expect(manifest.schemaVersion, versions.last);
    expect(manifest.tenantName, 'Warung Contoh');
    expect(manifest.outletCode, 'PST');
    expect(manifest.deviceCode, 'K01');
    expect(manifest.deviceId, store.deviceId.uuid);
    expect(manifest.createdAt, now);
    expect(manifest.products, 1);
    expect(manifest.media, ['abc.png']);

    final archive = ZipDecoder().decodeStream(InputFileStream(path));
    expect(
      archive.files.map((f) => f.name),
      containsAll(['manifest.json', 'lakuna.sqlite', 'media/abc.png']),
    );
    final json = jsonDecode(
      utf8.decode(archive.findFile('manifest.json')!.content),
    );
    expect(BackupManifest.fromJson(json as Map<String, Object?>), manifest);

    // Pemeriksaan ulang berkas yang sama lolos.
    expect(await inspectBackup(path, knownVersions: versions), manifest);
  });

  group('pemeriksaan berkas', () {
    test('bukan zip ditolak', () async {
      final bad = File('${out.path}/bad.zip')..writeAsStringSync('halo');
      await expectLater(
        inspectBackup(bad.path, knownVersions: versions),
        throwsA(isA<BackupInvalid>()),
      );
    });

    test('zip tanpa manifest Lakuna ditolak', () async {
      final path = '${out.path}/other.zip';
      final enc = ZipFileEncoder()..create(path);
      enc.addArchiveFile(ArchiveFile.string('readme.txt', 'x'));
      await enc.close();
      await expectLater(
        inspectBackup(path, knownVersions: versions),
        throwsA(isA<BackupInvalid>()),
      );
    });

    test('checksum database tidak cocok ditolak saat disiapkan', () async {
      final (path, _) = await backup();
      final tampered = await rezip(
        path,
        'tampered.zip',
        edit: (name, bytes) {
          if (name == 'lakuna.sqlite') bytes[200] ^= 0xFF;
          return bytes;
        },
      );
      final target = await Directory.systemTemp.createTemp('lakuna_t_');
      addTearDown(() => target.delete(recursive: true));
      await expectLater(
        stageRestore(tampered, dataDir: target.path, knownVersions: versions),
        throwsA(isA<BackupInvalid>()),
      );
      expect(hasPendingRestore(target.path), isFalse);
      expect(Directory('${target.path}/restore').existsSync(), isFalse);
    });

    test('versi skema kosong = berkas tidak sah', () async {
      final (path, _) = await backup();
      final blank = await rezip(
        path,
        'blank.zip',
        edit: (name, bytes) {
          if (name != 'manifest.json') return bytes;
          final json = jsonDecode(utf8.decode(bytes)) as Map<String, Object?>;
          json['schemaVersion'] = '';
          return utf8.encode(jsonEncode(json));
        },
      );
      await expectLater(
        inspectBackup(blank, knownVersions: versions),
        throwsA(isA<BackupInvalid>()),
      );
    });

    test('entri zip berbahaya tidak diekstrak (zip-slip)', () async {
      final (path, _) = await backup();
      final evil = await rezip(
        path,
        'evil.zip',
        extra: {
          '../luar.txt': utf8.encode('x'),
          'media/../../luar2.txt': utf8.encode('x'),
          r'media/..\luar3.txt': utf8.encode('x'),
          'media/sub/dalam.png': utf8.encode('x'),
          '/abs.txt': utf8.encode('x'),
        },
      );
      final parent = await Directory.systemTemp.createTemp('lakuna_slip_');
      addTearDown(() => parent.delete(recursive: true));
      final target = Directory('${parent.path}/data')..createSync();
      await stageRestore(evil, dataDir: target.path, knownVersions: versions);
      final staged = Directory('${target.path}/restore')
          .listSync(recursive: true)
          .map((e) => e.path.substring(target.path.length + 9))
          .toSet();
      expect(staged, {
        'lakuna.sqlite',
        'media',
        'media${Platform.pathSeparator}abc.png',
        'ready',
      });
      expect(parent.listSync().length, 1);
    });

    test('backup dari versi skema lebih baru ditolak', () async {
      final (path, _) = await backup();
      await expectLater(
        inspectBackup(path, knownVersions: versions.take(3).toList()),
        throwsA(isA<BackupTooNew>()),
      );
    });
  });

  test('pulihkan: data lama dipindah, data backup dipasang', () async {
    final (path, manifest) = await backup();

    // Perangkat pengganti: folder data lain dengan toko berbeda.
    final (other, otherDir) = await openTempStore();
    try {
      await setupTestStore(other, outletCode: 'BRU', email: 'lain@contoh.id');
      await stageRestore(path, dataDir: otherDir.path, knownVersions: versions);
      expect(hasPendingRestore(otherDir.path), isTrue);
      await other.close();

      final moved = await applyPendingRestore(
        otherDir.path,
        now: DateTime.utc(2026, 11, 5, 1, 2),
      );
      expect(moved, endsWith('sebelum-pulihkan-261105-0102'));
      expect(File('$moved/lakuna.sqlite').existsSync(), isTrue);
      expect(hasPendingRestore(otherDir.path), isFalse);
      expect(File('${otherDir.path}/media/abc.png').existsSync(), isTrue);

      final restored = await LakunaStore.open('${otherDir.path}/lakuna.sqlite');
      try {
        await finishRestore(restored);
        expect(
          await LocalPreferences(restored.session).get(backupLastAtKey),
          manifest.createdAt.toIso8601String(),
        );
        expect(File('${otherDir.path}/pulihkan-selesai').existsSync(), isFalse);
        expect(restored.deviceId.uuid, manifest.deviceId);
        final outlets = await Outlet.db.find(restored.session);
        expect(outlets.single.code, 'PST');
        expect(await Product.db.count(restored.session), 1);
      } finally {
        await restored.close();
      }
    } finally {
      await otherDir.delete(recursive: true);
    }
  });

  group('pemasangan tahan crash', () {
    late Directory target;
    late String path;

    setUp(() async {
      (path, _) = await backup();
      target = await Directory.systemTemp.createTemp('lakuna_crash_');
      // Data "lama" perangkat ini.
      File('${target.path}/lakuna.sqlite').writeAsStringSync('lama');
      Directory('${target.path}/media').createSync();
      File('${target.path}/media/lama.png').writeAsStringSync('lama');
      await stageRestore(path, dataDir: target.path, knownVersions: versions);
    });

    tearDown(() => target.delete(recursive: true));

    String db() =>
        File('${target.path}/lakuna.sqlite').readAsStringSync(encoding: latin1);

    test('mati setelah database backup dipasang: lanjut tanpa '
        'memindah data backup', () async {
      // Simulasikan langkah pertama selesai lalu aplikasi mati.
      final keep = '${target.path}/sebelum-pulihkan-261105-0102';
      File('${target.path}/restore/applying').writeAsStringSync(keep);
      Directory(keep).createSync();
      File('${target.path}/lakuna.sqlite').renameSync('$keep/lakuna.sqlite');
      Directory('${target.path}/media').renameSync('$keep/media');
      File('${target.path}/restore/lakuna.sqlite')
          .renameSync('${target.path}/lakuna.sqlite');

      final moved = await applyPendingRestore(target.path);
      expect(moved, keep);
      expect(db(), startsWith('SQLite format 3'));
      expect(File('$keep/lakuna.sqlite').readAsStringSync(), 'lama');
      expect(File('${target.path}/media/abc.png').existsSync(), isTrue);
      expect(Directory('${target.path}/restore').existsSync(), isFalse);
      // Dipanggil lagi: tidak ada apa-apa.
      expect(await applyPendingRestore(target.path), isNull);
      expect(db(), startsWith('SQLite format 3'));
    });

    test('mati setelah data lama dipindah sebagian: lanjut ke folder '
        'yang sama', () async {
      final keep = '${target.path}/sebelum-pulihkan-261105-0102';
      File('${target.path}/restore/applying').writeAsStringSync(keep);
      Directory(keep).createSync();
      File('${target.path}/lakuna.sqlite').renameSync('$keep/lakuna.sqlite');

      expect(await applyPendingRestore(target.path), keep);
      expect(db(), startsWith('SQLite format 3'));
      expect(File('$keep/media/lama.png').existsSync(), isTrue);
      expect(File('${target.path}/media/abc.png').existsSync(), isTrue);
    });

    test('batalkan pemasangan: data lama kembali', () async {
      final keep = await applyPendingRestore(
        target.path,
        now: DateTime.utc(2026, 11, 5, 1, 2),
      );
      final failed = await undoRestore(
        target.path,
        keep!,
        now: DateTime.utc(2026, 11, 5, 1, 3),
      );
      expect(failed, endsWith('pulihkan-gagal-261105-0103'));
      expect(db(), 'lama');
      expect(File('${target.path}/media/lama.png').existsSync(), isTrue);
      expect(File('$failed/lakuna.sqlite').existsSync(), isTrue);
      expect(Directory(keep).existsSync(), isFalse);
    });
  });

  test('tanpa restore tertunda tidak ada yang dipindah', () async {
    expect(await applyPendingRestore(dir.path), isNull);
    expect(File(store.path).existsSync(), isTrue);
  });
}
