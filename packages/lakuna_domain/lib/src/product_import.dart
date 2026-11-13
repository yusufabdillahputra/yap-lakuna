import 'catalog.dart';
import 'customer_import.dart' show parseImportMoney;
import 'money.dart';
import 'qty.dart';
import 'setup.dart' show normalizeCode;

// Import produk dari CSV/XLSX (F1-07b). Pembacaan berkas ada di aplikasi;
// di sini hanya tabel sel → draf produk satu varian.

/// Alasan baris import produk dilewati.
enum ProductImportRejectReason {
  name,
  price,
  cost,
  stock,
  kind,

  /// Teks terlalu panjang atau isian lain yang ditolak validasi produk.
  text,

  /// SKU atau barcode sudah dipakai baris sebelumnya di berkas.
  duplicateCode,

  /// Nama sudah dipakai baris sebelumnya di berkas.
  duplicateName,
}

class ProductImportRejected {
  const ProductImportRejected(this.line, this.reason);

  final int line;
  final ProductImportRejectReason reason;
}

/// Baris sah: draf produk baru satu varian, siap disimpan.
class ProductImportRow {
  const ProductImportRow({required this.line, required this.draft});

  /// Nomor baris di berkas (1 = baris judul).
  final int line;
  final ProductDraft draft;
}

class ProductImportResult {
  const ProductImportResult({
    this.rows = const [],
    this.rejected = const [],
    this.missingColumns = false,
  });

  final List<ProductImportRow> rows;
  final List<ProductImportRejected> rejected;

  /// Baris judul tidak punya kolom nama atau harga jual: berkas ditolak.
  final bool missingColumns;
}

/// Satuan bawaan bila kolom satuan kosong.
const productImportDefaultUnit = 'pcs';

const _columns = {
  'nama': 'name',
  'nama produk': 'name',
  'name': 'name',
  'product': 'name',
  'product name': 'name',
  'kategori': 'category',
  'category': 'category',
  'jenis': 'kind',
  'type': 'kind',
  'kind': 'kind',
  'satuan': 'unit',
  'unit': 'unit',
  'sku': 'sku',
  'kode': 'sku',
  'code': 'sku',
  'barcode': 'barcode',
  'harga beli': 'cost',
  'cost': 'cost',
  'cost price': 'cost',
  'hpp': 'cost',
  'harga pokok': 'cost',
  'harga modal': 'cost',
  'modal': 'cost',
  'harga jual': 'price',
  'harga': 'price',
  'price': 'price',
  'sell price': 'price',
  'stok awal': 'stock',
  'stok': 'stock',
  'stock': 'stock',
  'opening stock': 'stock',
  'stok minimum': 'min',
  'stok min': 'min',
  'min stok': 'min',
  'min stock': 'min',
  'minimum stock': 'min',
};

const _kinds = {
  'barang': ProductKind.goods,
  'goods': ProductKind.goods,
  'produk': ProductKind.goods,
  'jasa': ProductKind.service,
  'layanan': ProductKind.service,
  'service': ProductKind.service,
  'menu': ProductKind.menu,
};

/// Jumlah dari sel import: format Indonesia (`1.500`, `1,5`) lebih dulu,
/// lalu format ekspor Excel / Inggris (`1.5`, `1,500.25`). `null` bila
/// tidak sah atau negatif.
///
/// `1,500` ditolak karena ambigu: ribuan gaya Inggris (seperti harga
/// `1,500` = Rp1.500) atau 1,5 gaya Indonesia. Tulis `1500` atau `1,5`.
/// Sel angka XLSX sudah diubah ke koma desimal oleh pembaca berkas.
Qty? parseImportQty(String text) {
  final t = text.trim().replaceAll(' ', '');
  if (RegExp(r'^\d{1,3},\d{3}$').hasMatch(t)) return null;
  return Qty.tryParse(t) ?? Qty.tryParse(t, decimal: '.', group: ',');
}

String _nameKey(String name) =>
    name.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

/// Kunci nama produk untuk mencocokkan produk yang sudah ada (tanpa beda
/// huruf dan spasi berlebih).
String productImportNameKey(String name) => _nameKey(name);

/// Baris tabel (baris pertama = judul) → draf produk sah + baris ditolak.
ProductImportResult productImportRows(List<List<String>> table) {
  if (table.isEmpty) return const ProductImportResult(missingColumns: true);
  final index = <String, int>{};
  for (var i = 0; i < table.first.length; i++) {
    final header = table.first[i].trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    final key = _columns[header];
    if (key != null) index.putIfAbsent(key, () => i);
  }
  if (!index.containsKey('name') || !index.containsKey('price')) {
    return const ProductImportResult(missingColumns: true);
  }
  final rows = <ProductImportRow>[];
  final rejected = <ProductImportRejected>[];
  final names = <String>{};
  final skus = <String>{};
  final barcodes = <String>{};
  for (var r = 1; r < table.length; r++) {
    final cells = table[r];
    final line = r + 1;
    if (cells.every((c) => c.trim().isEmpty)) continue;
    String? cell(String key) {
      final i = index[key];
      if (i == null || i >= cells.length) return null;
      final v = cells[i].trim();
      return v.isEmpty ? null : v;
    }

    void reject(ProductImportRejectReason reason) =>
        rejected.add(ProductImportRejected(line, reason));

    final name = cell('name');
    if (name == null) {
      reject(ProductImportRejectReason.name);
      continue;
    }
    final priceRaw = cell('price');
    final price = priceRaw == null ? null : parseImportMoney(priceRaw);
    if (price == null) {
      reject(ProductImportRejectReason.price);
      continue;
    }
    var cost = 0;
    if (cell('cost') case final raw?) {
      final parsed = parseImportMoney(raw);
      if (parsed == null) {
        reject(ProductImportRejectReason.cost);
        continue;
      }
      cost = parsed;
    }
    var kind = ProductKind.goods;
    if (cell('kind') case final raw?) {
      final parsed = _kinds[raw.toLowerCase()];
      if (parsed == null) {
        reject(ProductImportRejectReason.kind);
        continue;
      }
      kind = parsed;
    }
    Qty? qty(String key) {
      final raw = cell(key);
      return raw == null ? Qty.zero : parseImportQty(raw);
    }

    final stock = qty('stock');
    final min = qty('min');
    if (stock == null || min == null) {
      reject(ProductImportRejectReason.stock);
      continue;
    }
    final sku = cell('sku') ?? '';
    final barcode = cell('barcode') ?? '';
    final tracks = kind.tracksStock;
    final draft = ProductDraft(
      name: name,
      category: cell('category') ?? '',
      kind: kind,
      baseUnit: cell('unit') ?? productImportDefaultUnit,
      variants: [
        VariantDraft(
          sku: sku,
          barcode: barcode,
          costPrice: Money(cost),
          sellPrice: Money(price),
          openingStock: tracks ? stock : Qty.zero,
          minStock: tracks ? min : Qty.zero,
        ),
      ],
    );
    if (validateProductDraft(draft).isNotEmpty) {
      reject(ProductImportRejectReason.text);
      continue;
    }
    final skuKey = sku.isEmpty ? null : normalizeCode(sku);
    final barcodeKey = barcode.isEmpty ? null : normalizeCode(barcode);
    if ((skuKey != null && skus.contains(skuKey)) ||
        (barcodeKey != null && barcodes.contains(barcodeKey))) {
      reject(ProductImportRejectReason.duplicateCode);
      continue;
    }
    if (!names.add(_nameKey(name))) {
      reject(ProductImportRejectReason.duplicateName);
      continue;
    }
    if (skuKey != null) skus.add(skuKey);
    if (barcodeKey != null) barcodes.add(barcodeKey);
    rows.add(ProductImportRow(line: line, draft: draft));
  }
  return ProductImportResult(rows: rows, rejected: rejected);
}

/// Judul kolom [header] dikenali pembaca import produk.
bool productImportKnownHeader(String header) => _columns.containsKey(
  header.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' '),
);

/// Templat berkas import produk (F1-07g): judul + dua baris contoh yang
/// lolos [productImportRows].
const productImportTemplate = [
  [
    'Nama',
    'Kategori',
    'Jenis',
    'Satuan',
    'SKU',
    'Barcode',
    'Harga beli',
    'Harga jual',
    'Stok awal',
    'Stok minimum',
  ],
  [
    'Contoh Gula Pasir 1 kg',
    'Sembako',
    'barang',
    'pcs',
    'CTH-GULA-1KG',
    '8991234567890',
    '14000',
    '17500',
    '24',
    '5',
  ],
  [
    'Contoh Kopi Susu',
    'Minuman',
    'menu',
    'gelas',
    'CTH-KOPI-SUSU',
    '',
    '6000',
    '15000',
    '',
    '',
  ],
];
