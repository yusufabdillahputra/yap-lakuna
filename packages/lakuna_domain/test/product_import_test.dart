import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('parseImportQty', () {
    test('format Indonesia dan ekspor Excel', () {
      expect(parseImportQty('12'), Qty.units(12));
      expect(parseImportQty('1.500'), Qty.units(1500));
      expect(parseImportQty('1,5'), const Qty(1500));
      expect(parseImportQty('1.5'), const Qty(1500));
      expect(parseImportQty('2,25'), const Qty(2250));
      expect(parseImportQty('1,500.25'), const Qty(1500250));
      expect(parseImportQty('-3'), isNull);
      expect(parseImportQty('dua'), isNull);
    });
  });

  group('productImportRows', () {
    test('judul Indonesia, bawaan, dan angka', () {
      final r = productImportRows([
        [
          'Nama Produk',
          'Kategori',
          'Satuan',
          'SKU',
          'Barcode',
          'Harga Beli',
          'Harga Jual',
          'Stok Awal',
          'Stok Minimum',
        ],
        [
          'Beras Premium 5 kg',
          'Sembako',
          'sak',
          'BRS-5',
          '8991234567890',
          'Rp 60.000',
          '72.500',
          '1.500',
          '10',
        ],
        ['Air Mineral', '', '', '', '', '', '3500', '', ''],
      ]);
      expect(r.missingColumns, isFalse);
      expect(r.rejected, isEmpty);
      expect(r.rows, hasLength(2));
      final beras = r.rows.first;
      expect(beras.line, 2);
      expect(beras.draft.name, 'Beras Premium 5 kg');
      expect(beras.draft.category, 'Sembako');
      expect(beras.draft.baseUnit, 'sak');
      expect(beras.draft.kind, ProductKind.goods);
      final v = beras.draft.variants.single;
      expect(v.sku, 'BRS-5');
      expect(v.barcode, '8991234567890');
      expect(v.costPrice, const Money(60000));
      expect(v.sellPrice, const Money(72500));
      expect(v.openingStock, Qty.units(1500));
      expect(v.minStock, Qty.units(10));
      final air = r.rows.last.draft;
      expect(air.baseUnit, 'pcs');
      expect(air.category, '');
      expect(air.variants.single.costPrice, Money.zero);
      expect(air.variants.single.openingStock, Qty.zero);
    });

    test('judul Inggris dan jenis', () {
      final r = productImportRows([
        ['name', 'type', 'unit', 'price', 'stock'],
        ['Cuci Gudang', 'jasa', 'kali', '15000', '5'],
        ['Nasi Goreng', 'menu', 'porsi', '25000', ''],
        ['Sabun', 'Barang', 'pcs', '4500', '3'],
        ['Kopi', 'goods', '', '2000', ''],
        ['Aneh', 'mainan', '', '1000', ''],
      ]);
      expect(r.rows.map((e) => e.draft.kind), [
        ProductKind.service,
        ProductKind.menu,
        ProductKind.goods,
        ProductKind.goods,
      ]);
      // Jasa dan menu tidak melacak stok: stok diabaikan.
      expect(r.rows.first.draft.variants.single.openingStock, Qty.zero);
      expect(r.rows[2].draft.variants.single.openingStock, Qty.units(3));
      expect(r.rejected.single.line, 6);
      expect(r.rejected.single.reason, ProductImportRejectReason.kind);
    });

    test('kolom nama atau harga jual hilang menolak berkas', () {
      expect(productImportRows([]).missingColumns, isTrue);
      expect(
        productImportRows([
          ['nama', 'kategori'],
          ['Gula', 'Sembako'],
        ]).missingColumns,
        isTrue,
      );
      expect(
        productImportRows([
          ['kategori', 'harga jual'],
          ['Sembako', '1000'],
        ]).missingColumns,
        isTrue,
      );
    });

    test('baris tidak sah ditolak dengan alasan dan nomor baris asli', () {
      final long = 'x' * 130;
      final r = productImportRows([
        ['nama', 'harga jual', 'harga beli', 'stok', 'sku', 'barcode'],
        ['', '1000', '', '', '', ''],
        ['Gula', '', '', '', '', ''],
        ['Gula', '12.345,67', '', '', '', ''],
        ['Teh', '5000', 'mahal', '', '', ''],
        ['Kopi', '2000', '', '-1', '', ''],
        [long, '1000', '', '', '', ''],
        ['', '', '', '', '', ''],
        ['Susu', '9000', '', '', 'S-1', ''],
        ['Susu Coklat', '9500', '', '', 's-1', ''],
        ['Roti', '7000', '', '', '', '899'],
        ['Roti Tawar', '7500', '', '', '', '899'],
        ['susu  ', '9000', '', '', '', ''],
      ]);
      expect(r.rows.map((e) => e.draft.name), ['Susu', 'Roti']);
      expect(r.rejected.map((e) => (e.line, e.reason)), [
        (2, ProductImportRejectReason.name),
        (3, ProductImportRejectReason.price),
        (4, ProductImportRejectReason.price),
        (5, ProductImportRejectReason.cost),
        (6, ProductImportRejectReason.stock),
        (7, ProductImportRejectReason.text),
        (10, ProductImportRejectReason.duplicateCode),
        (12, ProductImportRejectReason.duplicateCode),
        (13, ProductImportRejectReason.duplicateName),
      ]);
    });
  });
}
