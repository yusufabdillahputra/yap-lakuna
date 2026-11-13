import 'package:characters/characters.dart';

import 'money.dart';
import 'qty.dart';
import 'rounding.dart';
import 'setup.dart' show normalizeCode;

/// Jenis produk (F1-07). Hanya barang yang melacak stok; menu F&B memakai
/// resep di F1-10.
enum ProductKind {
  goods,
  service,
  menu;

  bool get tracksStock => this == goods;
}

/// Satu tingkat harga grosir: mulai [minQty] (satuan dasar) harga per satuan
/// dasar menjadi [price]. [groupId] `null` = semua pelanggan; diisi = hanya
/// pelanggan grup itu (F1-07c).
class PriceTier {
  const PriceTier({
    required this.minQty,
    required this.price,
    this.id,
    this.groupId,
  });

  /// ID baris `price_tiers` bila tingkat sudah tersimpan.
  final String? id;
  final Qty minQty;
  final Money price;

  /// ID grup pelanggan (`customer_groups`), `null` = semua pelanggan.
  final String? groupId;
}

PriceTier? _highestReached(Iterable<PriceTier> tiers, Qty qty) {
  PriceTier? best;
  for (final t in tiers) {
    if (t.minQty.milli <= qty.milli &&
        (best == null || t.minQty.milli > best.minQty.milli)) {
      best = t;
    }
  }
  return best;
}

/// Tingkat grosir yang berlaku untuk [qty]: dari tingkat semua pelanggan,
/// [PriceTier.minQty] terbesar yang masih ≤ [qty]. Bila [groupId] diisi,
/// tingkat grup itu dihitung dengan cara yang sama dan yang **lebih murah**
/// dipakai (F1-07c). `null` bila belum mencapai tingkat mana pun.
PriceTier? tierFor(Iterable<PriceTier> tiers, Qty qty, {String? groupId}) {
  final general = _highestReached(tiers.where((t) => t.groupId == null), qty);
  if (groupId == null) return general;
  final group = _highestReached(tiers.where((t) => t.groupId == groupId), qty);
  if (general == null) return group;
  if (group == null) return general;
  return group.price < general.price ? group : general;
}

/// Harga per satuan dasar untuk [qty] setelah harga grosir.
Money unitPriceFor(
  Money base,
  Iterable<PriceTier> tiers,
  Qty qty, {
  String? groupId,
}) => tierFor(tiers, qty, groupId: groupId)?.price ?? base;

/// Harga jual satu satuan konversi berisi [factor] satuan dasar: harga yang
/// diisi sendiri ([unitPrice]) atau harga varian × isi.
Money conversionSellPrice({
  required Money variantPrice,
  required Qty factor,
  Money? unitPrice,
}) => unitPrice ?? variantPrice.timesMilli(factor.milli);

/// Rata-rata biaya per satuan dasar setelah [incoming] masuk dengan biaya
/// [unitCost]. Barang keluar ([incoming] ≤ 0) tidak mengubahnya; stok kosong
/// atau minus memakai biaya masuk.
Money movingAverageCost({
  required Qty onHand,
  required Money avgCost,
  required Qty incoming,
  required Money unitCost,
}) {
  if (incoming.milli <= 0) return avgCost;
  if (onHand.milli <= 0) return unitCost;
  final total =
      BigInt.from(avgCost.value) * BigInt.from(onHand.milli) +
      BigInt.from(unitCost.value) * BigInt.from(incoming.milli);
  return Money(
    divRoundHalfAway(total, BigInt.from(onHand.milli + incoming.milli)),
  );
}

/// Batas panjang (grapheme) field produk.
abstract final class ProductLimits {
  static const name = 120;
  static const category = 60;
  static const baseUnit = 30;
  static const sku = 40;
  static const brand = 60;
  static const variantName = 60;
  static const barcode = 64;
  static const unitName = 30;

  /// Ukuran maksimal berkas foto produk (F1-07f).
  static const photoMaxBytes = 2 * 1024 * 1024;

  /// Lebar maksimal foto dari kamera (F1-07f).
  static const cameraMaxWidth = 1600;
}

/// Satuan konversi sebuah varian, mis. dus berisi 6 botol.
class UnitDraft {
  const UnitDraft({
    required this.name,
    required this.factor,
    this.id,
    this.barcode = '',
    this.costPrice,
    this.sellPrice,
  });

  final String? id;
  final String name;

  /// Isi satu satuan ini dalam satuan dasar.
  final Qty factor;
  final String barcode;

  /// Harga yang diisi sendiri; `null` = ikut harga varian × isi.
  final Money? costPrice;
  final Money? sellPrice;
}

/// Varian produk di form 1.16.
class VariantDraft {
  const VariantDraft({
    this.id,
    this.name = '',
    this.sku = '',
    this.barcode = '',
    this.costPrice = Money.zero,
    this.sellPrice = Money.zero,
    this.minStock = Qty.zero,
    this.openingStock = Qty.zero,
    this.units = const [],
    this.tiers = const [],
  });

  /// ID baris `product_variants` bila varian sudah tersimpan.
  final String? id;
  final String name;
  final String sku;
  final String barcode;
  final Money costPrice;
  final Money sellPrice;
  final Qty minStock;

  /// Hanya untuk varian baru dari produk yang melacak stok.
  final Qty openingStock;
  final List<UnitDraft> units;
  final List<PriceTier> tiers;
}

/// Isi form produk 1.16. Kategori dan satuan berupa nama; penyimpanan
/// memakai ulang yang sudah ada atau membuat baru.
class ProductDraft {
  const ProductDraft({
    required this.name,
    required this.baseUnit,
    required this.variants,
    this.id,
    this.category = '',
    this.kind = ProductKind.goods,
    this.sku = '',
    this.brand = '',
    this.isActive = true,
    this.isTaxable = false,
    this.sendToKitchen = true,
    this.allowNote = true,
    this.modifierGroupIds = const [],
  });

  final String? id;
  final String name;
  final String category;
  final ProductKind kind;
  final String baseUnit;
  final String sku;
  final String brand;

  /// Sakelar *Dijual di kasir*.
  final bool isActive;
  final bool isTaxable;

  /// Sakelar *Kirim ke tiket dapur* (1.16b, F1-10g).
  final bool sendToKitchen;

  /// Sakelar *Bisa catatan bebas* (1.16b, F1-10g).
  final bool allowNote;
  final List<VariantDraft> variants;

  /// Grup modifier terpasang, berurutan (1.16b, F1-10b).
  final List<String> modifierGroupIds;

  /// SKU varian yang terisi, sudah dinormalkan ([normalizeCode]).
  List<String> get skus => [
    for (final v in variants)
      if (v.sku.trim().isNotEmpty) normalizeCode(v.sku),
  ];

  /// Barcode varian dan satuan konversi yang terisi, dinormalkan.
  List<String> get barcodes => [
    for (final v in variants) ...[
      if (v.barcode.trim().isNotEmpty) normalizeCode(v.barcode),
      for (final u in v.units)
        if (u.barcode.trim().isNotEmpty) normalizeCode(u.barcode),
    ],
  ];
}

/// Field form produk yang bisa ditolak.
enum ProductField {
  name,
  category,
  baseUnit,
  sku,
  brand,
  variants,
  variantName,
  variantSku,
  variantBarcode,
  costPrice,
  sellPrice,
  minStock,
  openingStock,
  unitName,
  unitFactor,
  unitBarcode,
  unitCostPrice,
  unitSellPrice,
  tierMinQty,
  tierPrice,

  /// Grup modifier terpasang (F1-10b).
  modifierGroups,
}

enum ProductError {
  required,
  tooLong,
  negative,
  notPositive,

  /// Kembar di dalam produk yang sama.
  duplicate,

  /// Satuan konversi bernama sama dengan satuan dasar.
  sameAsBase,

  /// Isi satuan konversi harus lebih dari 1 satuan dasar.
  factorTooSmall,

  /// Tingkat grosir harus mulai dari lebih dari 1 satuan dasar.
  minQtyTooSmall,

  /// Kode sudah dipakai produk lain di tenant ini.
  taken,

  /// Data yang dirujuk sudah dihapus (mis. grup modifier).
  missing,
}

/// Satu masalah di form produk. [variant], [unit], dan [tier] adalah indeks
/// baris bila masalahnya di tabel.
class ProductIssue {
  const ProductIssue(
    this.field,
    this.error, {
    this.variant,
    this.unit,
    this.tier,
  });

  final ProductField field;
  final ProductError error;
  final int? variant;
  final int? unit;
  final int? tier;

  @override
  bool operator ==(Object other) =>
      other is ProductIssue &&
      other.field == field &&
      other.error == error &&
      other.variant == variant &&
      other.unit == unit &&
      other.tier == tier;

  @override
  int get hashCode => Object.hash(field, error, variant, unit, tier);

  @override
  String toString() =>
      'ProductIssue($field, $error, variant: $variant, unit: $unit, '
      'tier: $tier)';
}

int _len(String s) => s.trim().characters.length;

/// Semua masalah draf produk, urut seperti field di form. Kosong = sah.
List<ProductIssue> validateProductDraft(ProductDraft d) {
  final issues = <ProductIssue>[];
  void add(
    ProductField f,
    ProductError e, {
    int? variant,
    int? unit,
    int? tier,
  }) =>
      issues.add(ProductIssue(f, e, variant: variant, unit: unit, tier: tier));

  if (d.name.trim().isEmpty) {
    add(ProductField.name, ProductError.required);
  } else if (_len(d.name) > ProductLimits.name) {
    add(ProductField.name, ProductError.tooLong);
  }
  if (_len(d.category) > ProductLimits.category) {
    add(ProductField.category, ProductError.tooLong);
  }
  if (d.baseUnit.trim().isEmpty) {
    add(ProductField.baseUnit, ProductError.required);
  } else if (_len(d.baseUnit) > ProductLimits.baseUnit) {
    add(ProductField.baseUnit, ProductError.tooLong);
  }
  if (_len(d.sku) > ProductLimits.sku) {
    add(ProductField.sku, ProductError.tooLong);
  }
  if (_len(d.brand) > ProductLimits.brand) {
    add(ProductField.brand, ProductError.tooLong);
  }
  if (d.variants.isEmpty) {
    add(ProductField.variants, ProductError.required);
    return issues;
  }

  final baseUnit = d.baseUnit.trim().toLowerCase();
  final variantNames = <String>{};
  final skus = <String>{};
  final barcodes = <String>{};
  bool seenCode(Set<String> seen, String code) =>
      code.trim().isNotEmpty && !seen.add(normalizeCode(code));

  for (var i = 0; i < d.variants.length; i++) {
    final v = d.variants[i];
    final name = v.name.trim();
    if (name.isEmpty) {
      if (d.variants.length > 1) {
        add(ProductField.variantName, ProductError.required, variant: i);
      }
    } else if (_len(name) > ProductLimits.variantName) {
      add(ProductField.variantName, ProductError.tooLong, variant: i);
    } else if (!variantNames.add(name.toLowerCase())) {
      add(ProductField.variantName, ProductError.duplicate, variant: i);
    }

    if (_len(v.sku) > ProductLimits.sku) {
      add(ProductField.variantSku, ProductError.tooLong, variant: i);
    } else if (seenCode(skus, v.sku)) {
      add(ProductField.variantSku, ProductError.duplicate, variant: i);
    }
    if (_len(v.barcode) > ProductLimits.barcode) {
      add(ProductField.variantBarcode, ProductError.tooLong, variant: i);
    } else if (seenCode(barcodes, v.barcode)) {
      add(ProductField.variantBarcode, ProductError.duplicate, variant: i);
    }
    if (v.costPrice.isNegative) {
      add(ProductField.costPrice, ProductError.negative, variant: i);
    }
    if (v.sellPrice.isNegative) {
      add(ProductField.sellPrice, ProductError.negative, variant: i);
    }
    if (v.minStock.milli < 0) {
      add(ProductField.minStock, ProductError.negative, variant: i);
    }
    if (d.kind.tracksStock && v.openingStock.milli < 0) {
      add(ProductField.openingStock, ProductError.negative, variant: i);
    }

    final unitNames = <String>{};
    for (var j = 0; j < v.units.length; j++) {
      final u = v.units[j];
      final uName = u.name.trim().toLowerCase();
      if (uName.isEmpty) {
        add(ProductField.unitName, ProductError.required, variant: i, unit: j);
      } else if (_len(uName) > ProductLimits.unitName) {
        add(ProductField.unitName, ProductError.tooLong, variant: i, unit: j);
      } else if (uName == baseUnit) {
        add(
          ProductField.unitName,
          ProductError.sameAsBase,
          variant: i,
          unit: j,
        );
      } else if (!unitNames.add(uName)) {
        add(ProductField.unitName, ProductError.duplicate, variant: i, unit: j);
      }
      if (u.factor.milli <= Qty.one.milli) {
        add(
          ProductField.unitFactor,
          ProductError.factorTooSmall,
          variant: i,
          unit: j,
        );
      }
      if (_len(u.barcode) > ProductLimits.barcode) {
        add(
          ProductField.unitBarcode,
          ProductError.tooLong,
          variant: i,
          unit: j,
        );
      } else if (seenCode(barcodes, u.barcode)) {
        add(
          ProductField.unitBarcode,
          ProductError.duplicate,
          variant: i,
          unit: j,
        );
      }
      if (u.costPrice?.isNegative ?? false) {
        add(
          ProductField.unitCostPrice,
          ProductError.negative,
          variant: i,
          unit: j,
        );
      }
      if (u.sellPrice?.isNegative ?? false) {
        add(
          ProductField.unitSellPrice,
          ProductError.negative,
          variant: i,
          unit: j,
        );
      }
    }

    // Jumlah unik per grup; semua pelanggan dihitung satu grup (F1-07c).
    final tierQtys = <(String?, int)>{};
    for (var k = 0; k < v.tiers.length; k++) {
      final t = v.tiers[k];
      if (t.groupId == null && t.minQty.milli <= Qty.one.milli) {
        add(
          ProductField.tierMinQty,
          ProductError.minQtyTooSmall,
          variant: i,
          tier: k,
        );
      } else if (t.groupId != null && !t.minQty.isPositive) {
        // Harga grup boleh berlaku sejak 1 satuan (harga reseller).
        add(
          ProductField.tierMinQty,
          ProductError.notPositive,
          variant: i,
          tier: k,
        );
      } else if (!tierQtys.add((t.groupId, t.minQty.milli))) {
        add(
          ProductField.tierMinQty,
          ProductError.duplicate,
          variant: i,
          tier: k,
        );
      }
      if (t.price.value <= 0) {
        add(
          ProductField.tierPrice,
          ProductError.notPositive,
          variant: i,
          tier: k,
        );
      }
    }
  }
  return issues;
}
