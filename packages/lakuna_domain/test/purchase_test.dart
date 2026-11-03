import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

PurchaseLineInput _line(int qtyMilli, int price, {int factor = 1000}) =>
    PurchaseLineInput(
      quantity: Qty(qtyMilli),
      unitPrice: Money(price),
      factorMilli: factor,
    );

void main() {
  group('purchaseTotals', () {
    test('subtotal, total, dan landed cost per satuan dasar', () {
      // Desain 1.19: 10 karung × 66.000, 4 dus (6) × 195.000, 20 renceng (10)
      // × 15.000, diskon 40.000, ongkir 25.000.
      final t = purchaseTotals(
        [
          _line(10000, 66000),
          _line(4000, 195000, factor: 6000),
          _line(20000, 15000, factor: 10000),
        ],
        discount: const Money(40000),
        shipping: const Money(25000),
      );
      expect(t.subtotal, const Money(1740000));
      expect(t.total, const Money(1725000));
      expect(t.lineTotals, const [Money(660000), Money(780000), Money(300000)]);
      // Nilai mendarat dijumlah sama dengan total.
      expect(Money.sum(t.landedTotals), t.total);
      // Baris 1: 660.000 − 15.172 + 9.483 = 654.311 → per karung 65.431.
      expect(t.landedTotals[0], const Money(654311));
      expect(t.landedUnitCosts[0], const Money(65431));
      // Baris 2: 24 botol.
      expect(t.baseQuantities[1], const Qty(24000));
      expect(
        t.landedUnitCosts[1].value,
        (t.landedTotals[1].value / 24).round(),
      );
    });

    test('tanpa diskon/ongkir, qty pecahan dibulatkan ke rupiah', () {
      final t = purchaseTotals([_line(1500, 10001)]);
      expect(t.lineTotals.single, const Money(15002));
      expect(t.landedUnitCosts.single, const Money(10001));
    });

    test('baris bernilai nol tetap ikut ongkir secara rata', () {
      final t = purchaseTotals([
        _line(1000, 0),
        _line(1000, 0),
      ], shipping: const Money(1001));
      expect(t.landedTotals, const [Money(501), Money(500)]);
    });
  });

  group('validatePurchase', () {
    final today = DateTime.utc(2026, 11, 3);
    List<PurchaseIssue> check({
      List<PurchaseLineInput>? lines,
      int discount = 0,
      int shipping = 0,
      int paid = 0,
      FundingKind? funding,
      bool supplier = true,
      DateTime? dueOn,
      bool receiving = true,
      String? note,
    }) => validatePurchase(
      lines: lines ?? [_line(1000, 10000)],
      discount: Money(discount),
      shipping: Money(shipping),
      paid: Money(paid),
      funding: funding,
      hasSupplier: supplier,
      purchasedOn: today,
      dueOn: dueOn,
      receiving: receiving,
      note: note,
    );

    test('lunas tanpa supplier dan jatuh tempo: sah', () {
      expect(
        check(paid: 10000, funding: FundingKind.storeCash, supplier: false),
        isEmpty,
      );
    });

    test('hutang wajib supplier dan jatuh tempo, tidak sebelum tanggal', () {
      expect(check(supplier: false).map((i) => i.field), [
        PurchaseField.supplier,
        PurchaseField.dueOn,
      ]);
      expect(
        check(dueOn: today.subtract(const Duration(days: 1))).single.field,
        PurchaseField.dueOn,
      );
      expect(check(dueOn: today), isEmpty);
    });

    test('baris, diskon, bayar, sumber dana', () {
      expect(check(lines: []).single.field, PurchaseField.lines);
      final bad = check(lines: [_line(0, 1000), _line(1000, -1)], dueOn: today);
      expect(bad.map((i) => (i.field, i.index)), [
        (PurchaseField.quantity, 0),
        (PurchaseField.price, 1),
      ]);
      expect(
        check(discount: 10001, dueOn: today).single.field,
        PurchaseField.discount,
      );
      expect(
        check(shipping: -1, dueOn: today).single.field,
        PurchaseField.shipping,
      );
      expect(
        check(paid: 10001, funding: FundingKind.bank).single.field,
        PurchaseField.paid,
      );
      expect(
        check(paid: 5000, dueOn: today).single.field,
        PurchaseField.funding,
      );
    });

    test('draf boleh belum lengkap, tapi batas angka dan teks tetap', () {
      expect(check(lines: [], supplier: false, receiving: false), isEmpty);
      expect(
        check(
          receiving: false,
          note: 'x' * (PurchaseLimits.note + 1),
        ).single.field,
        PurchaseField.note,
      );
      expect(
        check(receiving: false, lines: [_line(-1000, 0)]).single.field,
        PurchaseField.quantity,
      );
    });
  });

  test('sisa hutang tidak pernah minus', () {
    expect(
      purchaseDebt(
        total: const Money(1725000),
        paid: const Money(1000000),
        debtReduction: const Money(25000),
      ),
      const Money(700000),
    );
    expect(
      purchaseDebt(total: const Money(100), paid: const Money(100)),
      Money.zero,
    );
  });

  test('saran harga jual menjaga margin, dibulatkan ke atas Rp 100', () {
    // 72.500 × 65.600 / 65.000 = 73.169,2 → 73.200.
    expect(
      suggestedSellPrice(
        sellPrice: const Money(72500),
        oldCost: const Money(65000),
        newCost: const Money(65600),
      ),
      const Money(73200),
    );
    expect(
      suggestedSellPrice(
        sellPrice: const Money(17500),
        oldCost: const Money(14800),
        newCost: const Money(14650),
      ),
      const Money(17400),
    );
    // HPP lama nol atau tidak berubah: harga sekarang.
    expect(
      suggestedSellPrice(
        sellPrice: const Money(5000),
        oldCost: Money.zero,
        newCost: const Money(3000),
      ),
      const Money(5000),
    );
  });

  test('nilai retur beli mengurangi hutang dulu, sisanya uang kembali', () {
    expect(
      purchaseReturnSplit(
        amount: const Money(132000),
        debt: const Money(100000),
      ),
      (debtReduction: const Money(100000), refund: const Money(32000)),
    );
    expect(
      purchaseReturnSplit(amount: const Money(5000), debt: const Money(9000)),
      (debtReduction: const Money(5000), refund: Money.zero),
    );
    expect(purchaseReturnSplit(amount: const Money(5000), debt: Money.zero), (
      debtReduction: Money.zero,
      refund: const Money(5000),
    ));
  });

  test('nomor PB dan RB memuat outlet dan perangkat', () {
    final d = DateTime(2026, 11, 2);
    expect(purchaseNumber('pst', 'd01', d, 3), 'PB-PST-D01-261102-0003');
    expect(purchaseReturnNumber('PST', 'D01', d, 1), 'RB-PST-D01-261102-0001');
  });

  test('retur beli mengeluarkan nilai pada HPP mendarat, rata-rata dihitung ulang',
      () {
    // 10 @ 1.000 + 10 @ 2.000 → 20 @ 1.500. Retur 10 @ 2.000 → 10 @ 1.000.
    expect(
      averageCostAfterReturn(
        onHand: Qty.units(20),
        avgCost: const Money(1500),
        returned: Qty.units(10),
        unitCost: const Money(2000),
      ),
      const Money(1000),
    );
    // Habis atau minus: rata-rata lama dipertahankan.
    expect(
      averageCostAfterReturn(
        onHand: Qty.units(10),
        avgCost: const Money(1500),
        returned: Qty.units(10),
        unitCost: const Money(2000),
      ),
      const Money(1500),
    );
    // Nilai sisa tidak pernah minus.
    expect(
      averageCostAfterReturn(
        onHand: Qty.units(2),
        avgCost: const Money(100),
        returned: Qty.units(1),
        unitCost: const Money(5000),
      ),
      Money.zero,
    );
  });
}
