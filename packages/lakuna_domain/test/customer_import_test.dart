import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('parseCsv', () {
    test('koma, titik koma, kutip, dan baris baru di dalam kutip', () {
      expect(parseCsv('nama,hp\nAni,0812\n'), [
        ['nama', 'hp'],
        ['Ani', '0812'],
      ]);
      expect(parseCsv('nama;hp\r\n"Toko ""Maju""";0813\r\n'), [
        ['nama', 'hp'],
        ['Toko "Maju"', '0813'],
      ]);
      expect(parseCsv('nama,alamat\nAni,"Jl. A,\nNo. 1"'), [
        ['nama', 'alamat'],
        ['Ani', 'Jl. A,\nNo. 1'],
      ]);
    });

    test('BOM UTF-8 dibuang, baris kosong dilewati', () {
      expect(parseCsv('﻿nama\n\nAni\n'), [
        ['nama'],
        ['Ani'],
      ]);
    });
  });

  group('customerImportRows', () {
    test('kolom Indonesia atau English, urutan bebas', () {
      final result = customerImportRows([
        ['HP', 'Nama', 'Grup', 'Limit', 'Alamat', 'Catatan'],
        ['0813-2222-1010', 'Toko Bu Ani', 'Grosir', '2.000.000', 'Jl. A', ''],
        ['', 'Pak Darto', '', '', '', 'langganan'],
      ]);
      expect(result.missingName, isFalse);
      expect(result.rejected, isEmpty);
      expect(result.rows, hasLength(2));
      final ani = result.rows.first;
      expect(ani.line, 2);
      expect(ani.name, 'Toko Bu Ani');
      expect(ani.phone, '081322221010');
      expect(ani.groupName, 'Grosir');
      expect(ani.creditLimit, const Money(2000000));
      expect(ani.address, 'Jl. A');
      expect(ani.note, isNull);
      final darto = result.rows.last;
      expect(darto.phone, isNull);
      expect(darto.creditLimit, isNull);
      expect(darto.note, 'langganan');

      final en = customerImportRows([
        ['name', 'phone', 'credit_limit', 'group', 'address', 'note'],
        ['Ani', '081322221010', '500000', '', '', ''],
      ]);
      expect(en.rows.single.creditLimit, const Money(500000));
    });

    test('tanpa kolom nama → ditolak seluruhnya', () {
      final result = customerImportRows([
        ['hp'],
        ['0812'],
      ]);
      expect(result.missingName, isTrue);
      expect(result.rows, isEmpty);
    });

    test('baris tidak valid dilaporkan dengan nomor baris', () {
      final result = customerImportRows([
        ['nama', 'hp', 'limit'],
        ['', '0812345678', ''],
        ['Budi', '12', ''],
        ['Cici', '', 'abc'],
        ['Dodi', '', '-5'],
        ['Eka', '081234567890', ''],
        ['Eka 2', '+6281234567890', ''],
      ]);
      expect(
        [for (final r in result.rejected) (r.line, r.reason)],
        [
          (2, ImportRejectReason.name),
          (3, ImportRejectReason.phone),
          (4, ImportRejectReason.creditLimit),
          (5, ImportRejectReason.creditLimit),
          (7, ImportRejectReason.duplicatePhone),
        ],
      );
      expect(result.rows.single.name, 'Eka');
    });

    test('baris kosong seluruhnya dilewati tanpa laporan', () {
      final result = customerImportRows([
        ['nama'],
        ['', ''],
        ['Ani'],
      ]);
      expect(result.rejected, isEmpty);
      expect(result.rows.single.line, 3);
    });
  });

  group('parseImportMoney', () {
    test('rupiah bulat, pemisah ribuan titik atau koma, Rp', () {
      expect(parseImportMoney('1500000'), 1500000);
      expect(parseImportMoney('1.500.000'), 1500000);
      expect(parseImportMoney('1,500,000'), 1500000);
      expect(parseImportMoney('Rp 1.500.000'), 1500000);
      expect(parseImportMoney('rp2.000'), 2000);
    });

    test('desimal nol dari ekspor akuntansi tidak dikali 100', () {
      expect(parseImportMoney('1500000.00'), 1500000);
      expect(parseImportMoney('1500000,00'), 1500000);
      expect(parseImportMoney('1.500.000,00'), 1500000);
      expect(parseImportMoney('1,500,000.00'), 1500000);
    });

    test('pecahan rupiah, negatif, atau teks ditolak', () {
      expect(parseImportMoney('1100000.0000000002'), isNull);
      expect(parseImportMoney('1,5'), isNull);
      expect(parseImportMoney('-5000'), isNull);
      expect(parseImportMoney('lima ribu'), isNull);
      expect(parseImportMoney('1.50.000'), isNull);
    });
  });
}
