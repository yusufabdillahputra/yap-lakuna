import 'package:characters/characters.dart';

import 'document_number.dart';
import 'money.dart';
import 'qty.dart';
import 'rounding.dart';
import 'split_bill.dart';

/// Batas teks pembelian (F1-12), dalam karakter.
abstract final class PurchaseLimits {
  static const note = 200;
  static const invoiceNo = 40;
  static const supplierName = 120;
  static const supplierPhone = 20;
}

/// Sumber dana bayar di muka atau uang kembali retur beli (salinan domain
/// dari enum server `FundingSource`).
enum FundingKind { storeCash, drawer, bank }

/// Satu baris pembelian: [quantity] dalam satuan baris, [unitPrice] per
/// satuan baris, [factorMilli] isi satuan baris dalam satuan dasar.
class PurchaseLineInput {
  const PurchaseLineInput({
    required this.quantity,
    required this.unitPrice,
    this.factorMilli = 1000,
  });

  final Qty quantity;
  final Money unitPrice;
  final int factorMilli;

  Money get lineTotal => unitPrice.timesMilli(quantity.milli);
  Qty get baseQuantity => quantity.toBaseUnit(factorMilli);
}

/// Hasil hitung pembelian: subtotal, total, dan nilai mendarat per baris.
class PurchaseTotals {
  const PurchaseTotals({
    required this.lineTotals,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.landedTotals,
    required this.baseQuantities,
    required this.landedUnitCosts,
  });

  final List<Money> lineTotals;
  final Money subtotal;
  final Money discount;
  final Money shipping;

  /// Subtotal baris − bagian diskon + bagian ongkir.
  final List<Money> landedTotals;
  final List<Qty> baseQuantities;

  /// Harga pokok mendarat per satuan dasar, dibulatkan ke rupiah terdekat.
  final List<Money> landedUnitCosts;

  Money get total => subtotal - discount + shipping;
}

/// Membagi diskon faktur dan ongkir ke baris secara proporsional subtotal
/// baris (sisa terbesar). Bila semua baris nol, dibagi rata.
PurchaseTotals purchaseTotals(
  List<PurchaseLineInput> lines, {
  Money discount = Money.zero,
  Money shipping = Money.zero,
}) {
  final lineTotals = [for (final l in lines) l.lineTotal];
  final weights = [for (final t in lineTotals) t.value < 0 ? 0 : t.value];
  final w = weights.every((x) => x == 0)
      ? [for (final _ in weights) 1]
      : weights;
  final discounts = discount.value <= 0
      ? [for (final _ in lines) Money.zero]
      : allocateByWeight(discount, w);
  final shippings = shipping.value <= 0
      ? [for (final _ in lines) Money.zero]
      : allocateByWeight(shipping, w);
  final landed = [
    for (var i = 0; i < lines.length; i++)
      lineTotals[i] - discounts[i] + shippings[i],
  ];
  final base = [for (final l in lines) l.baseQuantity];
  return PurchaseTotals(
    lineTotals: lineTotals,
    subtotal: Money.sum(lineTotals),
    discount: discount,
    shipping: shipping,
    landedTotals: landed,
    baseQuantities: base,
    landedUnitCosts: [
      for (var i = 0; i < lines.length; i++)
        base[i].milli <= 0
            ? Money.zero
            : Money(
                divRoundHalfAway(
                  BigInt.from(landed[i].value) * BigInt.from(1000),
                  BigInt.from(base[i].milli),
                ),
              ),
    ],
  );
}

enum PurchaseField {
  lines,
  quantity,
  price,
  discount,
  shipping,
  paid,
  funding,
  supplier,
  dueOn,
  invoiceNo,
  note,
}

/// Satu masalah isian pembelian; [index] = baris untuk qty/harga.
class PurchaseIssue {
  const PurchaseIssue(this.field, [this.index]);

  final PurchaseField field;
  final int? index;

  @override
  bool operator ==(Object other) =>
      other is PurchaseIssue && other.field == field && other.index == index;

  @override
  int get hashCode => Object.hash(field, index);

  @override
  String toString() => 'PurchaseIssue($field, $index)';
}

/// Memeriksa isian pembelian. Draf ([receiving] `false`) boleh tanpa baris,
/// supplier, atau jatuh tempo, tetapi angka dan panjang teks tetap diperiksa.
List<PurchaseIssue> validatePurchase({
  required List<PurchaseLineInput> lines,
  Money discount = Money.zero,
  Money shipping = Money.zero,
  Money paid = Money.zero,
  FundingKind? funding,
  required bool hasSupplier,
  required DateTime purchasedOn,
  DateTime? dueOn,
  String? invoiceNo,
  String? note,
  required bool receiving,
}) {
  final issues = <PurchaseIssue>[];
  if (receiving && lines.isEmpty) {
    issues.add(const PurchaseIssue(PurchaseField.lines));
  }
  for (final (i, l) in lines.indexed) {
    if (l.quantity.milli <= 0) {
      issues.add(PurchaseIssue(PurchaseField.quantity, i));
    } else if (l.unitPrice.isNegative) {
      issues.add(PurchaseIssue(PurchaseField.price, i));
    }
  }
  // Baris yang bermasalah tidak ikut dihitung agar galatnya tidak berantai.
  final totals = purchaseTotals([
    for (final l in lines)
      if (l.quantity.milli > 0 && !l.unitPrice.isNegative) l,
  ]);
  final badDiscount = discount.isNegative || discount > totals.subtotal;
  if (badDiscount) issues.add(const PurchaseIssue(PurchaseField.discount));
  if (shipping.isNegative) {
    issues.add(const PurchaseIssue(PurchaseField.shipping));
  }
  final total =
      totals.subtotal -
      (badDiscount ? Money.zero : discount) +
      (shipping.isNegative ? Money.zero : shipping);
  if (paid.isNegative || (receiving && paid > total)) {
    issues.add(const PurchaseIssue(PurchaseField.paid));
  }
  if (paid.value > 0 && funding == null) {
    issues.add(const PurchaseIssue(PurchaseField.funding));
  }
  if (receiving && total > paid) {
    if (!hasSupplier) issues.add(const PurchaseIssue(PurchaseField.supplier));
    if (dueOn == null || _day(dueOn).isBefore(_day(purchasedOn))) {
      issues.add(const PurchaseIssue(PurchaseField.dueOn));
    }
  }
  if (_len(invoiceNo) > PurchaseLimits.invoiceNo) {
    issues.add(const PurchaseIssue(PurchaseField.invoiceNo));
  }
  if (_len(note) > PurchaseLimits.note) {
    issues.add(const PurchaseIssue(PurchaseField.note));
  }
  return issues;
}

DateTime _day(DateTime d) => DateTime.utc(d.year, d.month, d.day);

int _len(String? s) => (s ?? '').trim().characters.length;

/// Sisa hutang pembelian: total − dibayar − pengurang hutang dari retur,
/// tidak pernah minus.
Money purchaseDebt({
  required Money total,
  required Money paid,
  Money debtReduction = Money.zero,
}) {
  final debt = total - paid - debtReduction;
  return debt.isNegative ? Money.zero : debt;
}

/// Saran harga jual yang menjaga margin lama: `sellPrice × newCost ÷
/// oldCost`, dibulatkan ke atas ke Rp 100. HPP lama nol atau tidak berubah →
/// harga sekarang.
Money suggestedSellPrice({
  required Money sellPrice,
  required Money oldCost,
  required Money newCost,
}) {
  if (oldCost.value <= 0 || newCost == oldCost || newCost.value <= 0) {
    return sellPrice;
  }
  final raw = BigInt.from(sellPrice.value) * BigInt.from(newCost.value);
  final step = BigInt.from(oldCost.value) * BigInt.from(100);
  final hundreds = (raw + step - BigInt.one) ~/ step;
  return Money((hundreds * BigInt.from(100)).toInt());
}

/// Nilai retur beli mengurangi hutang dulu; kelebihannya uang kembali.
({Money debtReduction, Money refund}) purchaseReturnSplit({
  required Money amount,
  required Money debt,
}) {
  final cap = debt.isNegative ? Money.zero : debt;
  final reduction = amount < cap ? amount : cap;
  return (debtReduction: reduction, refund: amount - reduction);
}

/// `PB-PST-D01-261102-0003`.
String purchaseNumber(
  String outletCode,
  String deviceCode,
  DateTime localDate,
  int counter,
) => documentNumber('PB', outletCode, deviceCode, localDate, counter);

/// `RB-PST-D01-261102-0001`.
String purchaseReturnNumber(
  String outletCode,
  String deviceCode,
  DateTime localDate,
  int counter,
) => documentNumber('RB', outletCode, deviceCode, localDate, counter);

/// HPP rata-rata setelah retur beli: barang keluar pada harga pokok mendarat
/// barisnya ([unitCost]), bukan rata-rata, sehingga nilai sisa =
/// `onHand × avg − returned × unitCost` dibagi qty sisa. Qty sisa ≤ 0 →
/// rata-rata lama; nilai sisa minus → 0.
Money averageCostAfterReturn({
  required Qty onHand,
  required Money avgCost,
  required Qty returned,
  required Money unitCost,
}) {
  final remaining = onHand.milli - returned.milli;
  if (returned.milli <= 0 || remaining <= 0) return avgCost;
  final value =
      BigInt.from(avgCost.value) * BigInt.from(onHand.milli) -
      BigInt.from(unitCost.value) * BigInt.from(returned.milli);
  if (value <= BigInt.zero) return Money.zero;
  return Money(divRoundHalfAway(value, BigInt.from(remaining)));
}
