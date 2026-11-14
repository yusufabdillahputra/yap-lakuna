import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:lakuna_client/lakuna_client.dart' show Product;
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

String _hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

void main() {
  group('pbkdf2Sha256 (vektor uji)', () {
    test('RFC 7914 §11', () {
      expect(
        _hex(pbkdf2Sha256(utf8.encode('passwd'), utf8.encode('salt'), 1, 64)),
        '55ac046e56e3089fec1691c22544b605f94185216dde0465e68b9d57c20dacbc'
        '49ca9cccf179b645991664b39d77ef317c71b845b1e30bd509112041d3a19783',
      );
      expect(
        _hex(
          pbkdf2Sha256(utf8.encode('Password'), utf8.encode('NaCl'), 80000, 64),
        ),
        '4ddcd8f60b98be21830cee5ef22701f9641a4418d04c0414aeff08876b34ab56'
        'a1d425a1225833549adb841b51c9b3176a272bdebba1d078478f62b397f33c8d',
      );
    });

    test('kata sandi UTF-8 (emoji)', () {
      expect(
        _hex(
          pbkdf2Sha256(
            utf8.encode('kunci🔒'),
            Uint8List.fromList(List.generate(16, (i) => i)),
            10000,
            32,
          ),
        ),
        '1bad1f275d62be2e10b67f509f1f294fe61de48d8d1af5b51dfd30547459f978',
      );
    });
  });

  group('BackupLock (komentar zip)', () {
    test('format dan baca ulang', () {
      final lock = BackupLock(
        salt: Uint8List.fromList(List.generate(16, (i) => 250 - i)),
        iterations: 310000,
      );
      final comment = lock.toComment();
      expect(comment, startsWith('lakuna-kunci:1:pbkdf2-sha256:310000:'));
      final back = BackupLock.parse(comment)!;
      expect(back.iterations, 310000);
      expect(back.salt, lock.salt);
    });

    test('bukan komentar Lakuna = tidak terkunci', () {
      expect(BackupLock.parse(''), isNull);
      expect(BackupLock.parse('dibuat 7-Zip'), isNull);
    });

    test('komentar Lakuna rusak atau iterasi di luar batas ditolak', () {
      for (final bad in [
        'lakuna-kunci:2:pbkdf2-sha256:310000:AAAAAAAAAAAAAAAAAAAAAA',
        'lakuna-kunci:1:scrypt:310000:AAAAAAAAAAAAAAAAAAAAAA',
        'lakuna-kunci:1:pbkdf2-sha256:abc:AAAAAAAAAAAAAAAAAAAAAA',
        'lakuna-kunci:1:pbkdf2-sha256:9999:AAAAAAAAAAAAAAAAAAAAAA',
        'lakuna-kunci:1:pbkdf2-sha256:2000001:AAAAAAAAAAAAAAAAAAAAAA',
        'lakuna-kunci:1:pbkdf2-sha256:310000:pendek',
        'lakuna-kunci:1:pbkdf2-sha256:310000:!!!',
      ]) {
        expect(
          () => BackupLock.parse(bad),
          throwsA(isA<BackupInvalid>()),
          reason: bad,
        );
      }
    });

    test('baca komentar dari ekor berkas zip', () async {
      final dir = await Directory.systemTemp.createTemp('lakuna_lock_');
      try {
        final path = '${dir.path}/a.zip';
        final out = OutputFileStream(path);
        ZipEncoder()
          ..startEncode(out)
          ..add(ArchiveFile.string('a.txt', 'isi'))
          ..endEncode(comment: 'halo komentar');
        await out.close();
        expect(await readZipComment(path), 'halo komentar');
        final plain = '${dir.path}/b.zip';
        final enc = ZipFileEncoder()..create(plain);
        enc.addArchiveFile(ArchiveFile.string('a.txt', 'isi'));
        await enc.close();
        expect(await readZipComment(plain), '');
        await File('${dir.path}/c.zip').writeAsString('bukan zip');
        expect(await readZipComment('${dir.path}/c.zip'), isNull);
      } finally {
        await dir.delete(recursive: true);
      }
    });
  });

  group('backup terkunci (F1-19c)', () {
    late LakunaStore store;
    late Directory dir;
    late Directory out;
    late StoreContext ctx;
    final now = DateTime.utc(2026, 11, 14, 3, 0);
    final versions = lakunaSchemaVersions;
    const password = 'rahasia-toko-1';

    setUp(() async {
      (store, dir) = await openTempStore(clock: () => now);
      ctx = await setupTestStore(store);
      out = await Directory.systemTemp.createTemp('lakuna_backup_lock_');
      await saveProduct(
        store,
        CatalogScope.of(ctx),
        staffId: ctx.owner.id,
        draft: const ProductDraft(
          name: 'Teh Botol',
          baseUnit: 'botol',
          variants: [VariantDraft(sellPrice: Money(5000))],
        ),
      );
      final media = Directory(store.mediaDirectory);
      await media.create(recursive: true);
      await File('${media.path}/foto.png').writeAsBytes(pngBytes(3, 3));
    });

    tearDown(() async {
      await store.close();
      if (dir.existsSync()) await dir.delete(recursive: true);
      if (out.existsSync()) await out.delete(recursive: true);
    });

    Future<String> lockedBackup({String name = 'kunci.zip'}) async {
      final path = '${out.path}/$name';
      await createBackup(
        store,
        ctx,
        outPath: path,
        appVersion: '0.60.0',
        now: now,
        password: password,
        iterations: 10000,
      );
      return path;
    }

    test('isi terenkripsi dan parameter di komentar zip', () async {
      final path = await lockedBackup();
      final lock = BackupLock.parse((await readZipComment(path))!)!;
      expect(lock.iterations, 10000);
      expect(lock.salt, hasLength(16));
      final input = InputFileStream(path);
      try {
        final archive = ZipDecoder().decodeStream(input);
        expect(
          archive.files.map((f) => f.name),
          containsAll(['manifest.json', 'lakuna.sqlite', 'media/foto.png']),
        );
        // Tanpa kunci turunan manifest tidak terbaca, termasuk dengan kata
        // sandi pengguna apa adanya (kata sandi zip = kunci turunan).
        expect(
          () => archive.findFile('manifest.json')!.content,
          throwsA(anything),
        );
        await archive.clear();
        final again = ZipDecoder().decodeStream(
          InputFileStream(path),
          password: password,
        );
        expect(
          () => again.findFile('manifest.json')!.content,
          throwsA(anything),
        );
      } finally {
        await input.close();
      }
      // Nama toko tidak muncul sebagai teks biasa di berkas.
      final raw = latin1.decode(File(path).readAsBytesSync());
      expect(raw.contains('Warung Contoh'), isFalse);
    });

    test('inspect: tanpa kata sandi, salah, lalu benar', () async {
      final path = await lockedBackup();
      await expectLater(
        inspectBackup(path, knownVersions: versions),
        throwsA(isA<BackupLocked>()),
      );
      await expectLater(
        inspectBackup(path, knownVersions: versions, password: 'salah-sandi'),
        throwsA(isA<BackupWrongPassword>()),
      );
      final manifest = await inspectBackup(
        path,
        knownVersions: versions,
        password: password,
      );
      expect(manifest.tenantName, 'Warung Contoh');
      expect(manifest.products, 1);
      expect(manifest.media, ['foto.png']);
    });

    test('pulihkan backup terkunci: database dan gambar sama', () async {
      final path = await lockedBackup();
      final target = await Directory.systemTemp.createTemp('lakuna_target_');
      try {
        await expectLater(
          stageRestore(path, dataDir: target.path, knownVersions: versions),
          throwsA(isA<BackupLocked>()),
        );
        await expectLater(
          stageRestore(
            path,
            dataDir: target.path,
            knownVersions: versions,
            password: 'salah-sandi',
          ),
          throwsA(isA<BackupWrongPassword>()),
        );
        expect(hasPendingRestore(target.path), isFalse);
        await stageRestore(
          path,
          dataDir: target.path,
          knownVersions: versions,
          password: password,
        );
        expect(hasPendingRestore(target.path), isTrue);
        expect(
          File('${target.path}/restore/media/foto.png').readAsBytesSync(),
          pngBytes(3, 3),
        );
        await applyPendingRestore(target.path);
        final restored = await LakunaStore.open('${target.path}/lakuna.sqlite');
        try {
          expect(await Product.db.count(restored.session), 1);
        } finally {
          await restored.close();
        }
      } finally {
        await target.delete(recursive: true);
      }
    });

    test('data terenkripsi diubah: ditolak, data tidak berubah', () async {
      final path = await lockedBackup();
      final bytes = File(path).readAsBytesSync();
      // Balik satu byte di tengah isi database terenkripsi.
      final input = InputFileStream(path);
      final archive = ZipDecoder().decodeStream(input);
      final db = archive.findFile('lakuna.sqlite')!;
      expect(db.size, greaterThan(1000));
      await archive.clear();
      await input.close();
      bytes[bytes.length ~/ 2] ^= 0xff;
      final broken = '${out.path}/rusak.zip';
      File(broken).writeAsBytesSync(bytes);
      final target = await Directory.systemTemp.createTemp('lakuna_target_');
      try {
        await expectLater(
          stageRestore(
            broken,
            dataDir: target.path,
            knownVersions: versions,
            password: password,
          ),
          throwsA(isA<BackupInvalid>()),
        );
        expect(hasPendingRestore(target.path), isFalse);
        expect(Directory('${target.path}/restore').existsSync(), isFalse);
      } finally {
        await target.delete(recursive: true);
      }
    });

    test('komentar dibuang: berkas terkunci tetap tidak terbaca', () async {
      final path = await lockedBackup();
      final bytes = File(path).readAsBytesSync();
      // Komentar = ekor berkas; potong lalu set panjang komentar 0.
      final comment = (await readZipComment(path))!;
      final cut = bytes.sublist(0, bytes.length - comment.length);
      cut[cut.length - 2] = 0;
      cut[cut.length - 1] = 0;
      final stripped = '${out.path}/tanpa-komentar.zip';
      File(stripped).writeAsBytesSync(cut);
      await expectLater(
        inspectBackup(stripped, knownVersions: versions),
        throwsA(isA<BackupInvalid>()),
      );
    });

    test(
      'manifest terkunci memuat nonce acak (CRC tidak bisa ditebak)',
      () async {
        final path = await lockedBackup();
        final lock = BackupLock.parse((await readZipComment(path))!)!;
        final input = InputFileStream(path);
        try {
          final archive = ZipDecoder().decodeStream(
            input,
            password: await lock.zipPassword(password),
          );
          final json = jsonDecode(
            utf8.decode(archive.findFile('manifest.json')!.content),
          ) as Map<String, Object?>;
          expect(json['nonce'], isA<String>());
          expect((json['nonce']! as String).length, greaterThanOrEqualTo(22));
          await archive.clear();
        } finally {
          await input.close();
        }
      },
    );

    test('manifest terenkripsi diubah: bukan "kata sandi salah"', () async {
      final path = await lockedBackup();
      final bytes = File(path).readAsBytesSync();
      // Entri pertama = manifest: header lokal + salt + pemeriksa, lalu data.
      bytes[110] ^= 0xff;
      final broken = '${out.path}/manifest-rusak.zip';
      File(broken).writeAsBytesSync(bytes);
      await expectLater(
        inspectBackup(broken, knownVersions: versions, password: password),
        throwsA(isA<BackupInvalid>()),
      );
    });

    test('komentar kunci palsu di zip tanpa enkripsi ditolak', () async {
      final plain = '${out.path}/biasa.zip';
      await createBackup(
        store,
        ctx,
        outPath: plain,
        appVersion: '0.60.0',
        now: now,
      );
      // Salin entri apa adanya (tidak terenkripsi) + komentar kunci palsu.
      final input = InputFileStream(plain);
      final archive = ZipDecoder().decodeStream(input);
      final forged = '${out.path}/palsu.zip';
      final output = OutputFileStream(forged);
      final encoder = ZipEncoder()..startEncode(output);
      for (final f in archive.files) {
        encoder.add(ArchiveFile.bytes(f.name, f.content));
      }
      encoder.endEncode(
        comment: BackupLock.create(iterations: 10000).toComment(),
      );
      await output.close();
      await archive.clear();
      await input.close();
      final target = await Directory.systemTemp.createTemp('lakuna_target_');
      try {
        await expectLater(
          stageRestore(
            forged,
            dataDir: target.path,
            knownVersions: versions,
            password: 'apa-saja-123',
          ),
          throwsA(isA<BackupInvalid>()),
        );
        expect(hasPendingRestore(target.path), isFalse);
      } finally {
        await target.delete(recursive: true);
      }
    });

    test('backup biasa: kata sandi diabaikan', () async {
      final path = '${out.path}/biasa.zip';
      await createBackup(
        store,
        ctx,
        outPath: path,
        appVersion: '0.60.0',
        now: now,
      );
      expect(await readZipComment(path), '');
      final manifest = await inspectBackup(
        path,
        knownVersions: versions,
        password: 'apa-saja-123',
      );
      expect(manifest.products, 1);
    });

    test('backup gagal: berkas setengah jadi dihapus', () async {
      final path = '${out.path}/gagal.zip';
      await expectLater(
        createBackup(
          store,
          ctx,
          outPath: path,
          appVersion: '0.60.0',
          password: password,
          iterations: 1,
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(File(path).existsSync(), isFalse);
    });
  });
}
