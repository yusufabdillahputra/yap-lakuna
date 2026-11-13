import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  test('templat produk terbaca utuh oleh pembaca import', () {
    final t = productImportTemplate;
    expect(t.first.every(productImportKnownHeader), isTrue);
    final r = productImportRows(t);
    expect(r.missingColumns, isFalse);
    expect(r.rejected, isEmpty);
    expect(r.rows, hasLength(2));
    expect(t.first, hasLength(10));
  });

  test('templat pelanggan terbaca utuh oleh pembaca import', () {
    final t = customerImportTemplate;
    expect(t.first.every(customerImportKnownHeader), isTrue);
    final r = customerImportRows(t);
    expect(r.missingName, isFalse);
    expect(r.rejected, isEmpty);
    expect(r.rows, hasLength(2));
    expect(t.first, hasLength(6));
  });

  test('templat supplier terbaca utuh oleh pembaca import', () {
    final t = supplierImportTemplate;
    expect(t.first.every(supplierImportKnownHeader), isTrue);
    final r = supplierImportRows(t);
    expect(r.missingName, isFalse);
    expect(r.rejected, isEmpty);
    expect(r.rows, hasLength(2));
    expect(r.rows.first.termDays, isNotNull);
    expect(t.first, hasLength(7));
  });

  test('judul tak dikenal', () {
    expect(productImportKnownHeader('Warna'), isFalse);
    expect(customerImportKnownHeader(' NO. HP '), isTrue);
    expect(supplierImportKnownHeader('Tempo (hari)'), isTrue);
  });
}
