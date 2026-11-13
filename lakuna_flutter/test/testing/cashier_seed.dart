import 'package:lakuna_domain/lakuna_domain.dart';

/// Produk contoh kasir: minyak (satuan Dus + grosir), beras dua varian,
/// kopi stok 1, dan satu produk nonaktif. [resellerGroupId] menambah harga
/// grup minyak Rp35.500 mulai 1 botol (F1-07c).
List<ProductDraft> cashierProducts({String? resellerGroupId}) => [
  ProductDraft(
    name: 'Minyak Goreng',
    category: 'Sembako',
    baseUnit: 'botol',
    variants: [
      VariantDraft(
        name: '2 L',
        sku: 'MYK-2L',
        barcode: '8991234500024',
        costPrice: const Money(32500),
        sellPrice: const Money(36000),
        openingStock: Qty.units(24),
        units: [
          UnitDraft(
            name: 'Dus',
            factor: Qty.units(6),
            barcode: '8991234500031',
            sellPrice: const Money(210000),
          ),
        ],
        tiers: [
          PriceTier(minQty: Qty.units(6), price: const Money(35000)),
          if (resellerGroupId != null)
            PriceTier(
              minQty: Qty.one,
              price: const Money(35500),
              groupId: resellerGroupId,
            ),
        ],
      ),
    ],
  ),
  ProductDraft(
    name: 'Beras Premium',
    category: 'Sembako',
    baseUnit: 'karung',
    variants: [
      VariantDraft(
        name: '5 kg',
        barcode: '8990001',
        sellPrice: const Money(72500),
        openingStock: Qty.units(10),
      ),
      VariantDraft(
        name: '10 kg',
        barcode: '8990002',
        sellPrice: const Money(140000),
        openingStock: Qty.units(4),
      ),
    ],
  ),
  ProductDraft(
    name: 'Kopi Sachet',
    category: 'Minuman',
    baseUnit: 'sachet',
    variants: [
      VariantDraft(
        sku: 'KOP',
        sellPrice: const Money(2000),
        openingStock: Qty.units(1),
      ),
    ],
  ),
  ProductDraft(
    name: 'Arsip Lama',
    baseUnit: 'pcs',
    isActive: false,
    variants: const [VariantDraft(sellPrice: Money(1000))],
  ),
];
