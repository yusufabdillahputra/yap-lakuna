import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:test/test.dart';

UuidValue _id(int n) => UuidValue.fromString(
  '01a1a4fb-0000-7000-8000-${n.toRadixString(16).padLeft(12, '0')}',
);

SaleItem _item(String name, UuidValue variantId) => SaleItem(
  tenantId: _id(1),
  saleId: _id(2),
  variantId: variantId,
  productName: name,
  variantName: '',
  unitName: 'pcs',
  factorMilli: 1000,
  quantityMilli: 1000,
  listPrice: 0,
  unitPrice: 0,
  lineTotal: 0,
  unitCost: 0,
  tracksStock: false,
  sortOrder: 0,
  hlc: '',
);

void main() {
  // Kategori: Minuman (induk) > Kopi (anak); Makanan.
  final minuman = _id(10);
  final kopi = _id(11);
  final makanan = _id(12);
  final esTeh = _item('Es Teh', _id(100));
  final latte = _item('Latte', _id(101));
  final nasi = _item('Nasi Goreng', _id(102));
  final kerupuk = _item('Kerupuk', _id(103)); // tanpa kategori
  final hilang = _item('Produk lama', _id(104)); // tidak dikenal
  final variantCategories = <UuidValue, UuidValue?>{
    _id(100): minuman,
    _id(101): kopi,
    _id(102): makanan,
    _id(103): null,
  };
  final parents = {kopi: minuman};
  final items = [nasi, esTeh, latte, kerupuk, hilang];

  test('item kategori bar (dan sub-kategorinya) ke bar, sisanya dapur', () {
    final split = splitBarItems(
      items,
      variantCategories: variantCategories,
      categoryParents: parents,
      barCategories: {minuman},
    );
    expect(split.bar, [esTeh, latte]);
    expect(split.kitchen, [nasi, kerupuk, hilang]);
  });

  test('sub-kategori saja: induknya tetap ke dapur', () {
    final split = splitBarItems(
      items,
      variantCategories: variantCategories,
      categoryParents: parents,
      barCategories: {kopi},
    );
    expect(split.bar, [latte]);
    expect(split.kitchen, [nasi, esTeh, kerupuk, hilang]);
  });

  test('tanpa kategori bar: semua ke dapur', () {
    final split = splitBarItems(
      items,
      variantCategories: variantCategories,
      categoryParents: parents,
      barCategories: const {},
    );
    expect(split.bar, isEmpty);
    expect(split.kitchen, items);
  });

  test('printer bar aktif hanya dengan printer dan kategori', () {
    const printer = PrinterSelection(
      kind: PrinterKind.network,
      name: 'a',
      address: 'a:9100',
    );
    expect(const KitchenPrinter(printer: printer).routesBar, isFalse);
    expect(
      KitchenPrinter(printer: printer, categoryIds: {minuman}).routesBar,
      isTrue,
    );
  });
}
