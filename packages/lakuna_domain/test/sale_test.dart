import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  const tiers = [
    PriceTier(minQty: Qty(2000), price: Money(70000)),
    PriceTier(minQty: Qty(10000), price: Money(68000)),
  ];

  group('priceSaleLine', () {
    test('satuan dasar tanpa grosir', () {
      final l = priceSaleLine(
        sellPrice: const Money(72500),
        tiers: tiers,
        quantity: Qty.one,
      );
      expect(l.unitPrice, const Money(72500));
      expect(l.listPrice, const Money(72500));
      expect(l.lineTotal, const Money(72500));
      expect(l.tier, isNull);
      expect(l.tierDiscount, Money.zero);
    });

    test('satuan dasar memakai tingkat grosir tertinggi yang dicapai', () {
      final two = priceSaleLine(
        sellPrice: const Money(72500),
        tiers: tiers,
        quantity: Qty.units(2),
      );
      expect(two.unitPrice, const Money(70000));
      expect(two.lineTotal, const Money(140000));
      expect(two.tier?.minQty, Qty.units(2));
      expect(two.tierDiscount, const Money(5000));

      final ten = priceSaleLine(
        sellPrice: const Money(72500),
        tiers: tiers,
        quantity: Qty.units(12),
      );
      expect(ten.unitPrice, const Money(68000));
      expect(ten.lineTotal, const Money(816000));
    });

    test('satuan konversi memakai harga satuan, tanpa grosir', () {
      final dus = priceSaleLine(
        sellPrice: const Money(36000),
        tiers: tiers,
        factor: Qty.units(6),
        unitPrice: const Money(210000),
        quantity: Qty.units(2),
      );
      expect(dus.unitPrice, const Money(210000));
      expect(dus.listPrice, const Money(210000));
      expect(dus.lineTotal, const Money(420000));
      expect(dus.tier, isNull);
      expect(dus.baseQuantity, Qty.units(12));
    });

    test('satuan konversi tanpa harga = harga varian × isi', () {
      final dus = priceSaleLine(
        sellPrice: const Money(36000),
        factor: Qty.units(6),
        quantity: Qty.one,
      );
      expect(dus.unitPrice, const Money(216000));
    });

    test('jumlah pecahan dibulatkan ke rupiah', () {
      final kg = priceSaleLine(
        sellPrice: const Money(28001),
        quantity: const Qty(500),
      );
      expect(kg.lineTotal, const Money(14001)); // 14000,5 → 14001
      expect(kg.baseQuantity, const Qty(500));
    });

    test('jumlah harus positif', () {
      expect(
        () => priceSaleLine(sellPrice: const Money(1000), quantity: Qty.zero),
        throwsArgumentError,
      );
    });
  });

  test('SaleTotals menjumlah subtotal, diskon grosir, dan total', () {
    final lines = [
      priceSaleLine(
        sellPrice: const Money(72500),
        tiers: tiers,
        quantity: Qty.units(2),
      ),
      priceSaleLine(sellPrice: const Money(36000), quantity: Qty.one),
    ];
    final t = SaleTotals.of(lines);
    expect(t.subtotal, const Money(181000));
    expect(t.tierDiscount, const Money(5000));
    expect(t.total, const Money(176000));
    expect(SaleTotals.of(const []).total, Money.zero);
  });

  group('nextReceiptCounter', () {
    test('mulai dari 1 dan mengambil nomor tertinggi + 1', () {
      const prefix = 'PST-K01-261103-';
      expect(nextReceiptCounter(const [], prefix), 1);
      expect(
        nextReceiptCounter(const [
          'PST-K01-261103-0002',
          'PST-K01-261103-0010',
          'PST-K01-261102-0099', // hari lain
          'PST-K02-261103-0050', // perangkat lain
          'PST-K01-261103-ABCD', // rusak
        ], prefix),
        11,
      );
    });

    test('awalan nota sesuai receiptNumber', () {
      expect(
        receiptPrefix('pst', 'k01', DateTime(2026, 11, 3)),
        'PST-K01-261103-',
      );
      expect(
        receiptNumber('PST', 'K01', DateTime(2026, 11, 3), 7),
        startsWith(receiptPrefix('PST', 'K01', DateTime(2026, 11, 3))),
      );
    });
  });

  group('pembayaran', () {
    test('kembalian tunai, null bila uang kurang', () {
      expect(
        cashChange(total: const Money(180000), received: const Money(200000)),
        const Money(20000),
      );
      expect(
        cashChange(total: const Money(180000), received: const Money(180000)),
        Money.zero,
      );
      expect(
        cashChange(total: const Money(180000), received: const Money(179999)),
        isNull,
      );
    });

    test('nominal cepat: uang pas lalu pecahan di atas total, unik', () {
      expect(quickCashAmounts(const Money(214000)), const [
        Money(214000),
        Money(220000),
        Money(250000),
        Money(300000),
      ]);
      expect(quickCashAmounts(const Money(50000)), const [
        Money(50000),
        Money(100000),
      ]);
      expect(quickCashAmounts(const Money(1500)), const [
        Money(1500),
        Money(10000),
        Money(50000),
        Money(100000),
      ]);
      expect(quickCashAmounts(Money.zero), isEmpty);
    });

    test('referensi pembayaran maksimal 40 karakter', () {
      expect(validatePaymentReference(''), isNull);
      expect(validatePaymentReference('004512'), isNull);
      expect(validatePaymentReference('x' * 41), PaymentReferenceError.tooLong);
    });
  });

  test('outletLocalTime memakai zona cabang', () {
    final t = DateTime.utc(2026, 11, 3, 17);
    expect(outletLocalTime(t, 'Asia/Jakarta').day, 4);
    expect(outletLocalTime(t, 'Asia/Jakarta').hour, 0);
    expect(outletLocalTime(t, 'Asia/Jayapura').hour, 2);
  });
}
