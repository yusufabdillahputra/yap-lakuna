import 'catalog.dart';
import 'document_number.dart';
import 'money.dart';
import 'qty.dart';

/// Harga satu baris keranjang kasir (F1-04).
class PricedLine {
  const PricedLine({
    required this.quantity,
    required this.factor,
    required this.listPrice,
    required this.unitPrice,
    required this.lineTotal,
    required this.listTotal,
    this.tier,
  });

  /// Jumlah dalam satuan baris (mis. 2 dus).
  final Qty quantity;

  /// Isi satu satuan baris dalam satuan dasar ([Qty.one] untuk satuan dasar).
  final Qty factor;

  /// Harga per satuan baris tanpa grosir.
  final Money listPrice;

  /// Harga per satuan baris yang dipakai (setelah grosir).
  final Money unitPrice;

  /// [unitPrice] × [quantity], dibulatkan ke rupiah.
  final Money lineTotal;

  /// [listPrice] × [quantity], dibulatkan ke rupiah.
  final Money listTotal;

  /// Tingkat grosir yang berlaku, `null` bila tidak ada.
  final PriceTier? tier;

  /// Potongan grosir baris ini.
  Money get tierDiscount => listTotal - lineTotal;

  /// Jumlah dalam satuan dasar (untuk stok).
  Qty get baseQuantity => quantity.toBaseUnit(factor.milli);
}

/// Harga baris: satuan dasar ([factor] `null`) memakai harga grosir [tiers]
/// untuk [quantity] (termasuk tingkat grup [customerGroupId], F1-07c);
/// satuan konversi memakai [unitPrice] atau harga varian × isi, tanpa
/// grosir (tingkat grosir didefinisikan per satuan dasar).
PricedLine priceSaleLine({
  required Money sellPrice,
  required Qty quantity,
  List<PriceTier> tiers = const [],
  Qty? factor,
  Money? unitPrice,
  String? customerGroupId,
}) {
  if (!quantity.isPositive) {
    throw ArgumentError.value(quantity.milli, 'quantity', 'harus > 0');
  }
  if (factor == null) {
    final tier = tierFor(tiers, quantity, groupId: customerGroupId);
    final price = tier?.price ?? sellPrice;
    return PricedLine(
      quantity: quantity,
      factor: Qty.one,
      listPrice: sellPrice,
      unitPrice: price,
      lineTotal: price.timesMilli(quantity.milli),
      listTotal: sellPrice.timesMilli(quantity.milli),
      tier: tier,
    );
  }
  final price = conversionSellPrice(
    variantPrice: sellPrice,
    factor: factor,
    unitPrice: unitPrice,
  );
  final total = price.timesMilli(quantity.milli);
  return PricedLine(
    quantity: quantity,
    factor: factor,
    listPrice: price,
    unitPrice: price,
    lineTotal: total,
    listTotal: total,
  );
}

/// Ringkasan nota: subtotal (harga daftar), diskon grosir, dan total.
class SaleTotals {
  const SaleTotals({required this.subtotal, required this.total});

  factory SaleTotals.of(Iterable<PricedLine> lines) => SaleTotals(
    subtotal: Money.sum(lines.map((l) => l.listTotal)),
    total: Money.sum(lines.map((l) => l.lineTotal)),
  );

  final Money subtotal;
  final Money total;

  Money get tierDiscount => subtotal - total;
}

/// Awalan nota hari [localDate] di perangkat ini: `PST-K01-261103-`.
String receiptPrefix(String outletCode, String deviceCode, DateTime localDate) {
  final full = receiptNumber(outletCode, deviceCode, localDate, 0);
  return full.substring(0, full.length - 4);
}

/// Penghitung nota berikutnya: nomor tertinggi di [numbers] yang berawalan
/// [prefix] (hari dan perangkat yang sama) + 1.
int nextReceiptCounter(Iterable<String> numbers, String prefix) {
  var max = 0;
  for (final n in numbers) {
    if (!n.startsWith(prefix)) continue;
    final counter = int.tryParse(n.substring(prefix.length));
    if (counter != null && counter > max) max = counter;
  }
  return max + 1;
}
