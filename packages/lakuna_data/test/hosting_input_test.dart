import 'package:lakuna_data/lakuna_data.dart';
import 'package:test/test.dart';

void main() {
  group('alamat server', () {
    test('https diterima, garis miring akhir ditambahkan', () {
      expect(
        parseServerUrl(' https://sync.contoh.id ').toString(),
        'https://sync.contoh.id/',
      );
      expect(
        parseServerUrl('https://sync.contoh.id/api').toString(),
        'https://sync.contoh.id/api/',
      );
    });

    test('tanpa skema dianggap https', () {
      expect(
        parseServerUrl('sync.contoh.id').toString(),
        'https://sync.contoh.id/',
      );
    });

    test('http hanya untuk localhost (uji)', () {
      expect(parseServerUrl('http://sync.contoh.id'), isNull);
      expect(
        parseServerUrl('http://localhost:8080').toString(),
        'http://localhost:8080/',
      );
      expect(
        parseServerUrl('http://127.0.0.1:8080').toString(),
        'http://127.0.0.1:8080/',
      );
    });

    test('isian kosong atau rusak ditolak', () {
      expect(parseServerUrl(''), isNull);
      expect(parseServerUrl('https://'), isNull);
      expect(parseServerUrl('ftp://sync.contoh.id'), isNull);
      expect(parseServerUrl('https://user:rahasia@sync.contoh.id'), isNull);
    });
  });

  group('kode pasang lengkap', () {
    test('<alamat>#<kode> dipisah', () {
      final p = parsePairingInput('https://sync.contoh.id#ABCD-2345');
      expect(p.serverUrl, 'https://sync.contoh.id');
      expect(p.code, 'ABCD2345');
    });

    test('kode saja', () {
      final p = parsePairingInput(' abcd 2345 ');
      expect(p.serverUrl, isNull);
      expect(p.code, 'ABCD2345');
    });

    test('alamat saja', () {
      final p = parsePairingInput('https://sync.contoh.id');
      expect(p.serverUrl, 'https://sync.contoh.id');
      expect(p.code, '');
    });

    test('teks kode pasang lengkap', () {
      expect(
        pairingShareText(Uri.parse('https://sync.contoh.id/'), 'ABCD2345'),
        'https://sync.contoh.id#ABCD2345',
      );
    });
  });
}
