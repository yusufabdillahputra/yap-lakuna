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

  group('templat bahasa Inggris (F1-07p)', () {
    test('produk: judul dikenali, contoh dilewati, nama diganti sah', () {
      final t = productImportTemplateEn;
      expect(t.first, [
        'Name',
        'Category',
        'Type',
        'Unit',
        'SKU',
        'Barcode',
        'Cost price',
        'Sell price',
        'Opening stock',
        'Min stock',
      ]);
      expect(t.first.every(productImportKnownHeader), isTrue);
      final r = productImportRows(t);
      expect(r.rows, isEmpty);
      expect(r.rejected.map((e) => e.reason), [
        ProductImportRejectReason.sample,
        ProductImportRejectReason.sample,
      ]);
      final filled = productImportRows(_renamed(t));
      expect(filled.rejected, isEmpty);
      expect(filled.rows.map((e) => e.draft.kind), [
        ProductKind.goods,
        ProductKind.menu,
      ]);
      // Angka contoh sama dengan templat Indonesia.
      expect(
        [for (final row in t.skip(1)) row.skip(6)],
        [for (final row in productImportTemplate.skip(1)) row.skip(6)],
      );
    });

    test('pelanggan: judul dikenali, contoh dilewati, nama diganti sah', () {
      final t = customerImportTemplateEn;
      expect(t.first, [
        'Name',
        'Phone',
        'Address',
        'Group',
        'Credit limit',
        'Note',
      ]);
      expect(t.first.every(customerImportKnownHeader), isTrue);
      final r = customerImportRows(t);
      expect(r.rows, isEmpty);
      expect(r.rejected.map((e) => e.reason), [
        ImportRejectReason.sample,
        ImportRejectReason.sample,
      ]);
      final filled = customerImportRows(_renamed(t));
      expect(filled.rejected, isEmpty);
      expect(filled.rows, hasLength(2));
      expect(filled.rows.first.groupName, 'Wholesale');
    });

    test('supplier: judul dikenali, contoh dilewati, nama diganti sah', () {
      final t = supplierImportTemplateEn;
      expect(t.first, [
        'Name',
        'Contact',
        'Phone',
        'Category',
        'Term (days)',
        'Address',
        'Note',
      ]);
      expect(t.first.every(supplierImportKnownHeader), isTrue);
      final r = supplierImportRows(t);
      expect(r.rows, isEmpty);
      expect(r.rejected.map((e) => e.reason), [
        SupplierImportRejectReason.sample,
        SupplierImportRejectReason.sample,
      ]);
      final filled = supplierImportRows(_renamed(t));
      expect(filled.rejected, isEmpty);
      expect(filled.rows.first.termDays, 30);
    });

    test('contoh EN di bawah judul Indonesia tetap dilewati', () {
      final mixed = [customerImportTemplate.first, customerImportTemplateEn[1]];
      expect(
        customerImportRows(mixed).rejected.single.reason,
        ImportRejectReason.sample,
      );
      final products = [
        productImportTemplate.first,
        productImportTemplateEn[2],
      ];
      expect(
        productImportRows(products).rejected.single.reason,
        ProductImportRejectReason.sample,
      );
      final suppliers = [
        supplierImportTemplate.first,
        supplierImportTemplateEn[2],
      ];
      expect(
        supplierImportRows(suppliers).rejected.single.reason,
        SupplierImportRejectReason.sample,
      );
    });
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
    [
      row.first.replaceFirst('Contoh ', '').replaceFirst('Sample ', ''),
      ...row.skip(1),
    ],
];
