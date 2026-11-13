import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  test('templat produk terbaca utuh oleh pembaca import', () {
    final t = productImportTemplate;
    expect(t.first.every(productImportKnownHeader), isTrue);
    final r = productImportRows(t);
    expect(r.missingColumns, isFalse);
    // Baris contoh dikenali dan dilewati agar tidak ikut tersimpan.
    expect(r.rows, isEmpty);
    expect(r.rejected.map((e) => e.reason), [
      ProductImportRejectReason.sample,
      ProductImportRejectReason.sample,
    ]);
    final filled = productImportRows(_renamed(t));
    expect(filled.rejected, isEmpty);
    expect(filled.rows, hasLength(2));
    expect(t.first, hasLength(10));
  });

  test('templat pelanggan terbaca utuh oleh pembaca import', () {
    final t = customerImportTemplate;
    expect(t.first.every(customerImportKnownHeader), isTrue);
    final r = customerImportRows(t);
    expect(r.missingName, isFalse);
    expect(r.rows, isEmpty);
    expect(r.rejected.map((e) => e.reason), [
      ImportRejectReason.sample,
      ImportRejectReason.sample,
    ]);
    final filled = customerImportRows(_renamed(t));
    expect(filled.rejected, isEmpty);
    expect(filled.rows, hasLength(2));
    expect(t.first, hasLength(6));
  });

  test('templat supplier terbaca utuh oleh pembaca import', () {
    final t = supplierImportTemplate;
    expect(t.first.every(supplierImportKnownHeader), isTrue);
    final r = supplierImportRows(t);
    expect(r.missingName, isFalse);
    expect(r.rows, isEmpty);
    expect(r.rejected.map((e) => e.reason), [
      SupplierImportRejectReason.sample,
      SupplierImportRejectReason.sample,
    ]);
    final filled = supplierImportRows(_renamed(t));
    expect(filled.rejected, isEmpty);
    expect(filled.rows, hasLength(2));
    expect(filled.rows.first.termDays, isNotNull);
    expect(t.first, hasLength(7));
  });

  test('contoh dikenali tanpa beda huruf/spasi, nama mirip tetap sah', () {
    expect(
      isImportTemplateSample(' contoh pak budi ', customerImportTemplate),
      isTrue,
    );
    expect(isImportTemplateSample('Pak Budi', customerImportTemplate), isFalse);
    expect(isImportTemplateSample('Nama', customerImportTemplate), isFalse);
  });

  test('judul tak dikenal', () {
    expect(productImportKnownHeader('Warna'), isFalse);
    expect(customerImportKnownHeader(' NO. HP '), isTrue);
    expect(supplierImportKnownHeader('Tempo (hari)'), isTrue);
  });
}

/// Templat dengan nama contoh diganti (pengguna mengisi data sendiri).
List<List<String>> _renamed(List<List<String>> t) => [
  t.first,
  for (final row in t.skip(1))
    [row.first.replaceFirst('Contoh ', ''), ...row.skip(1)],
];
