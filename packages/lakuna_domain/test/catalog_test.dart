import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

ProductDraft _draft({
  String name = 'Minyak Goreng',
  String baseUnit = 'botol',
  ProductKind kind = ProductKind.goods,
  List<VariantDraft>? variants,
  String category = '',
  String sku = '',
  String brand = '',
}) => ProductDraft(
  name: name,
  baseUnit: baseUnit,
  kind: kind,
  category: category,
  sku: sku,
  brand: brand,
  variants:
      variants ??
      const [VariantDraft(costPrice: Money(32500), sellPrice: Money(36000))],
);

void main() {
  group('unitPriceFor', () {
    const tiers = [
      PriceTier(minQty: Qty(24000), price: Money(34000)),
      PriceTier(minQty: Qty(6000), price: Money(35000)),
    ];

    test('tanpa tingkat memakai harga jual', () {
      expect(
        unitPriceFor(const Money(36000), const [], Qty.units(100)),
        const Money(36000),
      );
    });

    test('di bawah tingkat pertama memakai harga jual', () {
      expect(
        unitPriceFor(const Money(36000), tiers, Qty.units(5)),
        const Money(36000),
      );
    });

    test('tepat di tingkat memakai harga tingkat', () {
      expect(
        unitPriceFor(const Money(36000), tiers, Qty.units(6)),
        const Money(35000),
      );
    });

    test('tingkat terbesar yang tercapai menang, urutan tidak penting', () {
      expect(
        unitPriceFor(const Money(36000), tiers, Qty.units(23)),
        const Money(35000),
      );
      expect(
        unitPriceFor(const Money(36000), tiers, Qty.units(30)),
        const Money(34000),
      );
    });

    test('tierFor mengembalikan tingkat yang dipakai', () {
      expect(tierFor(tiers, Qty.units(7))?.minQty, const Qty(6000));
      expect(tierFor(tiers, Qty.units(1)), isNull);
    });
  });

  group('conversionSellPrice', () {
    test('harga satuan diisi dipakai apa adanya', () {
      expect(
        conversionSellPrice(
          variantPrice: const Money(36000),
          factor: Qty.units(6),
          unitPrice: const Money(210000),
        ),
        const Money(210000),
      );
    });

    test('kosong = harga varian × isi, dibulatkan', () {
      expect(
        conversionSellPrice(
          variantPrice: const Money(36000),
          factor: Qty.units(6),
        ),
        const Money(216000),
      );
      expect(
        conversionSellPrice(
          variantPrice: const Money(28000),
          factor: const Qty(250),
        ),
        const Money(7000),
      );
    });
  });

  group('Qty format dan parse', () {
    test('format dengan koma desimal dan titik ribuan', () {
      expect(const Qty(12500).format(), '12,5');
      expect(const Qty(250).format(), '0,25');
      expect(Qty.units(3).format(), '3');
      expect(Qty.units(1250).format(), '1.250');
      expect(const Qty(-1500).format(), '-1,5');
      expect(const Qty(12500).format(decimal: '.', group: ','), '12.5');
    });

    test('tryParse bahasa Indonesia', () {
      expect(Qty.tryParse('12,5'), const Qty(12500));
      expect(Qty.tryParse(' 0,25 '), const Qty(250));
      expect(Qty.tryParse('3'), Qty.units(3));
      expect(Qty.tryParse('1.250'), Qty.units(1250));
      expect(Qty.tryParse('1.250,125'), const Qty(1250125));
      expect(Qty.tryParse(''), isNull);
      expect(Qty.tryParse('1,2345'), isNull);
      expect(Qty.tryParse('-2'), isNull);
      expect(Qty.tryParse('abc'), isNull);
    });

    test('tryParse menerima ketikan setengah jadi dari pemformat input', () {
      expect(Qty.tryParse('12,'), Qty.units(12));
      expect(Qty.tryParse(',5'), const Qty(500));
      expect(Qty.tryParse('1.250,'), Qty.units(1250));
      expect(Qty.tryParse(','), isNull);
      expect(Qty.tryParse('1.25'), isNull);
    });

    test('tryParse bahasa Inggris', () {
      expect(Qty.tryParse('12.5', decimal: '.', group: ','), const Qty(12500));
      expect(Qty.tryParse('1,250', decimal: '.', group: ','), Qty.units(1250));
    });

    test('tryParse menolak angka melampaui batas', () {
      expect(Qty.tryParse('9' * 20), isNull);
    });
  });

  group('normalizeCode', () {
    test('trim dan huruf besar', () {
      expect(normalizeCode('  myk-2l '), 'MYK-2L');
    });
  });

  group('ProductKind', () {
    test('hanya barang yang melacak stok', () {
      expect(ProductKind.goods.tracksStock, isTrue);
      expect(ProductKind.service.tracksStock, isFalse);
      expect(ProductKind.menu.tracksStock, isFalse);
    });
  });

  group('validateProductDraft', () {
    test('draf sah tidak punya masalah', () {
      expect(validateProductDraft(_draft()), isEmpty);
    });

    test('nama dan satuan dasar wajib', () {
      final issues = validateProductDraft(_draft(name: ' ', baseUnit: ''));
      expect(issues, [
        const ProductIssue(ProductField.name, ProductError.required),
        const ProductIssue(ProductField.baseUnit, ProductError.required),
      ]);
    });

    test('batas panjang dihitung per grapheme', () {
      expect(validateProductDraft(_draft(name: '😀' * 120)), isEmpty);
      expect(validateProductDraft(_draft(name: 'a' * 121)), [
        const ProductIssue(ProductField.name, ProductError.tooLong),
      ]);
      expect(
        validateProductDraft(
          _draft(category: 'k' * 61, brand: 'm' * 61, sku: 's' * 41),
        ),
        [
          const ProductIssue(ProductField.category, ProductError.tooLong),
          const ProductIssue(ProductField.sku, ProductError.tooLong),
          const ProductIssue(ProductField.brand, ProductError.tooLong),
        ],
      );
      expect(validateProductDraft(_draft(baseUnit: 'u' * 31)), [
        const ProductIssue(ProductField.baseUnit, ProductError.tooLong),
      ]);
    });

    test('minimal satu varian', () {
      expect(validateProductDraft(_draft(variants: const [])), [
        const ProductIssue(ProductField.variants, ProductError.required),
      ]);
    });

    test('lebih dari satu varian: nama wajib dan unik tanpa beda huruf', () {
      final issues = validateProductDraft(
        _draft(
          variants: const [
            VariantDraft(name: '1 L'),
            VariantDraft(name: ''),
            VariantDraft(name: '1 l'),
          ],
        ),
      );
      expect(issues, [
        const ProductIssue(
          ProductField.variantName,
          ProductError.required,
          variant: 1,
        ),
        const ProductIssue(
          ProductField.variantName,
          ProductError.duplicate,
          variant: 2,
        ),
      ]);
    });

    test('harga, stok min, dan stok awal tidak negatif', () {
      final issues = validateProductDraft(
        _draft(
          variants: const [
            VariantDraft(
              costPrice: Money(-1),
              sellPrice: Money(-2),
              minStock: Qty(-1),
              openingStock: Qty(-1),
            ),
          ],
        ),
      );
      expect(issues.map((i) => (i.field, i.error)), [
        (ProductField.costPrice, ProductError.negative),
        (ProductField.sellPrice, ProductError.negative),
        (ProductField.minStock, ProductError.negative),
        (ProductField.openingStock, ProductError.negative),
      ]);
      expect(issues.every((i) => i.variant == 0), isTrue);
    });

    test('stok awal diabaikan untuk jasa', () {
      expect(
        validateProductDraft(
          _draft(
            kind: ProductKind.service,
            variants: const [VariantDraft(openingStock: Qty(-1))],
          ),
        ),
        isEmpty,
      );
    });

    test('kode di varian dan satuan dibatasi panjangnya', () {
      final issues = validateProductDraft(
        _draft(
          variants: [
            VariantDraft(
              name: 'v' * 61,
              sku: 's' * 41,
              barcode: 'b' * 65,
              units: [
                UnitDraft(name: 'dus', factor: Qty.units(6), barcode: 'c' * 65),
              ],
            ),
          ],
        ),
      );
      expect(issues.map((i) => (i.field, i.error)), [
        (ProductField.variantName, ProductError.tooLong),
        (ProductField.variantSku, ProductError.tooLong),
        (ProductField.variantBarcode, ProductError.tooLong),
        (ProductField.unitBarcode, ProductError.tooLong),
      ]);
    });

    test('satuan konversi: nama wajib, bukan satuan dasar, unik; isi > 1', () {
      final issues = validateProductDraft(
        _draft(
          variants: [
            VariantDraft(
              units: [
                UnitDraft(name: 'Dus', factor: Qty.units(6)),
                UnitDraft(name: '', factor: Qty.units(12)),
                UnitDraft(name: 'Botol', factor: Qty.units(2)),
                UnitDraft(name: 'dus', factor: Qty.units(12)),
                const UnitDraft(name: 'pak', factor: Qty.one),
                const UnitDraft(
                  name: 'krat',
                  factor: Qty(24000),
                  costPrice: Money(-1),
                  sellPrice: Money(-1),
                ),
              ],
            ),
          ],
        ),
      );
      expect(issues.map((i) => (i.field, i.error, i.unit)), [
        (ProductField.unitName, ProductError.required, 1),
        (ProductField.unitName, ProductError.sameAsBase, 2),
        (ProductField.unitName, ProductError.duplicate, 3),
        (ProductField.unitFactor, ProductError.factorTooSmall, 4),
        (ProductField.unitCostPrice, ProductError.negative, 5),
        (ProductField.unitSellPrice, ProductError.negative, 5),
      ]);
    });

    test('tingkat grosir: jumlah > 1, unik, harga > 0', () {
      final issues = validateProductDraft(
        _draft(
          variants: [
            VariantDraft(
              tiers: [
                PriceTier(minQty: Qty.units(6), price: const Money(35000)),
                const PriceTier(minQty: Qty.one, price: Money(35500)),
                PriceTier(minQty: Qty.units(6), price: const Money(34000)),
                PriceTier(minQty: Qty.units(24), price: Money.zero),
              ],
            ),
          ],
        ),
      );
      expect(issues.map((i) => (i.field, i.error, i.tier)), [
        (ProductField.tierMinQty, ProductError.minQtyTooSmall, 1),
        (ProductField.tierMinQty, ProductError.duplicate, 2),
        (ProductField.tierPrice, ProductError.notPositive, 3),
      ]);
    });

    test('SKU dan barcode kembar di dalam produk ditandai', () {
      final issues = validateProductDraft(
        _draft(
          variants: [
            const VariantDraft(name: '1 L', sku: 'MYK-1L', barcode: '899001'),
            VariantDraft(
              name: '2 L',
              sku: 'myk-1l ',
              barcode: '899002',
              units: [
                UnitDraft(name: 'dus', factor: Qty.units(6), barcode: '899001'),
              ],
            ),
          ],
        ),
      );
      expect(issues.map((i) => (i.field, i.error, i.variant, i.unit)), [
        (ProductField.variantSku, ProductError.duplicate, 1, null),
        (ProductField.unitBarcode, ProductError.duplicate, 1, 0),
      ]);
    });

    test('ProductDraft.codes mendaftar SKU dan barcode yang terisi', () {
      final draft = _draft(
        variants: [
          VariantDraft(
            sku: ' myk ',
            barcode: '111',
            units: [
              UnitDraft(name: 'dus', factor: Qty.units(6), barcode: '222'),
            ],
          ),
          const VariantDraft(name: 'b'),
        ],
      );
      expect(draft.skus, ['MYK']);
      expect(draft.barcodes, ['111', '222']);
    });
  });

  group('movingAverageCost', () {
    test('stok kosong atau minus memakai biaya masuk', () {
      expect(
        movingAverageCost(
          onHand: Qty.zero,
          avgCost: const Money(1000),
          incoming: Qty.units(5),
          unitCost: const Money(1500),
        ),
        const Money(1500),
      );
      expect(
        movingAverageCost(
          onHand: Qty.units(-2),
          avgCost: const Money(1000),
          incoming: Qty.units(5),
          unitCost: const Money(1500),
        ),
        const Money(1500),
      );
    });

    test('rata-rata tertimbang, dibulatkan', () {
      expect(
        movingAverageCost(
          onHand: Qty.units(10),
          avgCost: const Money(1000),
          incoming: Qty.units(5),
          unitCost: const Money(1600),
        ),
        const Money(1200),
      );
      expect(
        movingAverageCost(
          onHand: Qty.units(2),
          avgCost: const Money(1000),
          incoming: Qty.units(1),
          unitCost: const Money(1001),
        ),
        const Money(1000),
      );
    });

    test('barang keluar tidak mengubah rata-rata', () {
      expect(
        movingAverageCost(
          onHand: Qty.units(10),
          avgCost: const Money(1000),
          incoming: Qty.units(-3),
          unitCost: const Money(5000),
        ),
        const Money(1000),
      );
    });
  });
}
