import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('parseImportTermDays', () {
    test('angka, "hari", dan batas', () {
      expect(parseImportTermDays('14'), 14);
      expect(parseImportTermDays(' 30 hari '), 30);
      expect(parseImportTermDays('7 days'), 7);
      expect(parseImportTermDays('0'), 0);
      expect(parseImportTermDays('365'), 365);
      expect(parseImportTermDays('14.0'), 14);
      expect(parseImportTermDays('366'), isNull);
      expect(parseImportTermDays('-1'), isNull);
      expect(parseImportTermDays('dua minggu'), isNull);
      expect(parseImportTermDays('1.5'), isNull);
    });
  });

  group('supplierImportRows', () {
    test('judul ID, kolom kosong = null, telepon dinormalisasi', () {
      final r = supplierImportRows([
        [
          'Nama',
          'Kontak',
          'Telepon',
          'Kategori',
          'Tempo (hari)',
          'Alamat',
          'Catatan',
          'Lain',
        ],
        [
          'CV Sumber Pangan',
          'Pak Hendra',
          '+62 21-555-0101',
          'Sembako',
          '30',
          'Jl. Pasar 1',
          'Kirim Senin',
          'x',
        ],
        ['  PT Segar Jaya ', '', '', '', '', '', '', ''],
        ['', '', '', '', '', '', '', ''],
      ]);
      expect(r.missingName, isFalse);
      expect(r.rejected, isEmpty);
      expect(r.rows, hasLength(2));
      final a = r.rows.first;
      expect(a.line, 2);
      expect(a.name, 'CV Sumber Pangan');
      expect(a.contactName, 'Pak Hendra');
      expect(a.phone, '0215550101');
      expect(a.category, 'Sembako');
      expect(a.termDays, 30);
      expect(a.address, 'Jl. Pasar 1');
      expect(a.note, 'Kirim Senin');
      final b = r.rows.last;
      expect(b.line, 3);
      expect(b.name, 'PT Segar Jaya');
      expect(b.phone, isNull);
      expect(b.termDays, isNull);
      expect(b.contactName, isNull);
    });

    test('judul EN dan tanpa kolom nama', () {
      final r = supplierImportRows([
        ['Name', 'Contact', 'Phone', 'Category', 'Term days'],
        ['UD Makmur', 'Bu Rina', '081311112222', 'Minuman', '7'],
      ]);
      expect(r.rows.single.termDays, 7);
      expect(r.rows.single.contactName, 'Bu Rina');
      expect(
        supplierImportRows([
          ['Kontak', 'Telepon'],
          ['A', '0812'],
        ]).missingName,
        isTrue,
      );
      expect(supplierImportRows(const []).missingName, isTrue);
    });

    test('alias judul telepon; telepon tanpa angka ditolak', () {
      final r = supplierImportRows([
        ['Nama Supplier', 'No. Telp', 'Tempo'],
        ['CV A', '0812-3456-789', '7 hari'],
        ['CV B', '-', ''],
      ]);
      expect(r.rows.single.phone, '08123456789');
      expect(r.rows.single.termDays, 7);
      expect(
        [for (final x in r.rejected) (x.line, x.reason)],
        [(3, SupplierImportRejectReason.phone)],
      );
      expect(
        supplierImportRows([
          ['nama', 'WhatsApp'],
          ['CV C', '081234567890'],
        ]).rows.single.phone,
        '081234567890',
      );
    });

    test('baris salah ditolak dengan alasan; nama ganda tanpa beda huruf', () {
      final r = supplierImportRows([
        ['Nama', 'Telepon', 'Tempo', 'Kategori'],
        ['', '0812345678', '', ''],
        ['Toko A', '123', '', ''],
        ['Toko B', '', '400', ''],
        ['Toko C', '', '', 'x' * 61],
        ['Toko D', '', '14', ''],
        ['toko d', '', '', ''],
      ]);
      expect(r.rows.map((x) => x.name), ['Toko D']);
      expect(
        [for (final x in r.rejected) (x.line, x.reason)],
        [
          (2, SupplierImportRejectReason.name),
          (3, SupplierImportRejectReason.phone),
          (4, SupplierImportRejectReason.termDays),
          (5, SupplierImportRejectReason.text),
          (7, SupplierImportRejectReason.duplicateName),
        ],
      );
    });
  });
}
