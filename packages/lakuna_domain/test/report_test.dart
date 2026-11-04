import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

ReportSaleLine line(
  String key, {
  String variant = 'v1',
  String name = 'Kopi',
  int qty = 1000,
  int factor = 1000,
  int total = 10000,
  int cost = 6000,
}) => ReportSaleLine(
  key: key,
  variantKey: variant,
  name: name,
  quantityMilli: qty,
  factorMilli: factor,
  lineTotal: Money(total),
  unitCost: Money(cost),
);

ReportSale sale(
  List<ReportSaleLine> lines, {
  String staff = 'sari',
  int? subtotal,
  int discount = 0,
  int service = 0,
  int tax = 0,
  int? paid,
  bool credit = false,
  List<ReportPayment>? payments,
}) {
  final sub = subtotal ?? lines.fold<int>(0, (a, l) => a + l.lineTotal.value);
  final total = sub - discount + service + tax;
  return ReportSale(
    staffKey: staff,
    subtotal: Money(sub),
    tierDiscount: Money(discount),
    service: Money(service),
    tax: Money(tax),
    total: Money(total),
    credit: credit,
    paidAtSale: Money(paid ?? total),
    payments:
        payments ??
        [ReportPayment(ReportPaymentMethod.cash, Money(total), Money.zero)],
    lines: lines,
  );
}

void main() {
  group('ReportPeriod', () {
    final today = DateTime.utc(2026, 11, 4);

    test('rentang dan periode sebelumnya', () {
      expect(ReportPeriod.today.range(today), DateRange(today, today));
      expect(
        ReportPeriod.today.previousRange(today),
        DateRange(DateTime.utc(2026, 11, 3), DateTime.utc(2026, 11, 3)),
      );
      expect(
        ReportPeriod.last7Days.range(today),
        DateRange(DateTime.utc(2026, 10, 29), today),
      );
      expect(
        ReportPeriod.last7Days.previousRange(today),
        DateRange(DateTime.utc(2026, 10, 22), DateTime.utc(2026, 10, 28)),
      );
      expect(
        ReportPeriod.thisMonth.range(today),
        DateRange(DateTime.utc(2026, 11), DateTime.utc(2026, 11, 30)),
      );
      expect(
        ReportPeriod.thisMonth.previousRange(today),
        DateRange(DateTime.utc(2026, 10), DateTime.utc(2026, 10, 4)),
      );
      // Bulan ini dibandingkan dengan tanggal yang sama bulan lalu, dipotong
      // di akhir bulan lalu (31 Maret → 1–28 Februari).
      expect(
        ReportPeriod.thisMonth.previousRange(DateTime.utc(2026, 3, 31)),
        DateRange(DateTime.utc(2026, 2), DateTime.utc(2026, 2, 28)),
      );
      const jan = ReportPeriod.month(2026, 1);
      expect(
        jan.range(today),
        DateRange(DateTime.utc(2026, 1), DateTime.utc(2026, 1, 31)),
      );
      expect(
        jan.previousRange(today),
        DateRange(DateTime.utc(2025, 12), DateTime.utc(2025, 12, 31)),
      );
    });

    test('pilihan: hari ini, 7 hari, bulan ini, lalu 12 bulan sebelumnya', () {
      final choices = reportPeriodChoices(today);
      expect(choices, hasLength(15));
      expect(choices.take(3), [
        ReportPeriod.today,
        ReportPeriod.last7Days,
        ReportPeriod.thisMonth,
      ]);
      expect(choices[3], const ReportPeriod.month(2026, 10));
      expect(choices.last, const ReportPeriod.month(2025, 11));
    });

    test('kunci berkas', () {
      expect(ReportPeriod.today.fileKey(today), 'hari-ini');
      expect(ReportPeriod.last7Days.fileKey(today), '7-hari');
      expect(ReportPeriod.thisMonth.fileKey(today), '2026-11');
      expect(const ReportPeriod.month(2026, 3).fileKey(today), '2026-03');
    });
  });

  group('persen', () {
    test('ratioBp dan changeBp', () {
      expect(ratioBp(const Money(257), const Money(1000)), 2570);
      expect(ratioBp(const Money(1), const Money(3)), 3333);
      expect(ratioBp(const Money(5), Money.zero), isNull);
      expect(changeBp(const Money(108), const Money(100)), 800);
      expect(changeBp(const Money(90), const Money(100)), -1000);
      expect(changeBp(const Money(90), Money.zero), isNull);
      expect(changeBp(const Money(90), const Money(-10)), isNull);
    });

    test('formatPercentBp satu desimal', () {
      expect(formatPercentBp(2570), '25,7%');
      expect(formatPercentBp(2575), '25,8%');
      expect(formatPercentBp(-1000), '-10,0%');
      expect(formatPercentBp(800, decimal: '.'), '8.0%');
    });

    test('bagian PB1 retur', () {
      expect(
        returnTaxShare(
          amount: const Money(55000),
          saleTax: const Money(10000),
          saleTotal: const Money(110000),
        ),
        const Money(5000),
      );
      expect(
        returnTaxShare(
          amount: const Money(100),
          saleTax: Money.zero,
          saleTotal: const Money(100),
        ),
        Money.zero,
      );
      expect(
        returnTaxShare(
          amount: const Money(100),
          saleTax: const Money(10),
          saleTotal: Money.zero,
        ),
        Money.zero,
      );
    });
  });

  group('ProfitAndLoss', () {
    test('periode kosong = nol', () {
      final pl = ProfitAndLoss.compute(
        sales: const [],
        returns: const [],
        expenses: const [],
        stockAdjustment: Money.zero,
      );
      expect(pl.netSales, Money.zero);
      expect(pl.netProfit, Money.zero);
      expect(pl.grossMarginBp, isNull);
      expect(pl.expenseRatioBp, isNull);
      expect(pl.saleCount, 0);
    });

    test('diskon, service, PB1, retur, HPP, beban, penyesuaian', () {
      final kopi = line(
        'k',
        variant: 'kopi',
        qty: 2000,
        total: 36000,
        cost: 8000,
      );
      final teh = line(
        't',
        variant: 'teh',
        name: 'Teh',
        qty: 1000,
        total: 20000,
        cost: 0,
      );
      // Grosir: harga daftar 40.000 → 36.000.
      final s1 = sale([kopi], subtotal: 40000, discount: 4000);
      // F&B: service 2.000, PB1 2.200.
      final s2 = sale([teh], service: 2000, tax: 2200);
      final pl = ProfitAndLoss.compute(
        sales: [s1, s2],
        returns: [
          // Retur 1 kopi di-restock: 18.000, tanpa PB1.
          ReportReturn(
            saleStaffKey: 'sari',
            amount: const Money(18000),
            saleTax: Money.zero,
            saleTotal: const Money(36000),
            restock: true,
            lines: [ReportReturnLine(kopi, 1000)],
          ),
          // Retur teh rusak (tidak di-restock): 24.200 termasuk PB1 2.200.
          ReportReturn(
            saleStaffKey: 'sari',
            amount: const Money(24200),
            saleTax: const Money(2200),
            saleTotal: const Money(24200),
            restock: false,
            lines: [ReportReturnLine(teh, 1000)],
          ),
        ],
        expenses: const [
          ExpenseLine('Listrik & air', Money(5000)),
          ExpenseLine('Sewa tempat', Money(10000)),
          ExpenseLine('Listrik & air', Money(1000)),
        ],
        stockAdjustment: const Money(-1500),
      );
      expect(pl.grossSales, const Money(60000));
      expect(pl.discount, const Money(4000));
      expect(pl.service, const Money(2000));
      expect(pl.returns, const Money(40000));
      expect(pl.netSales, const Money(18000));
      // HPP: 2 × 8.000 + 0 − 1 × 8.000 (restock).
      expect(pl.cogs, const Money(8000));
      expect(pl.grossProfit, const Money(10000));
      expect(pl.grossMarginBp, 5556);
      expect(pl.expenses.map((e) => (e.name, e.amount)), [
        ('Sewa tempat', const Money(10000)),
        ('Listrik & air', const Money(6000)),
      ]);
      expect(pl.totalExpenses, const Money(16000));
      expect(pl.stockAdjustment, const Money(-1500));
      expect(pl.netProfit, const Money(-7500));
      expect(pl.taxCollected, Money.zero);
      expect(pl.missingCostCount, 1);
      expect(pl.saleCount, 2);
      expect(pl.expenseRatioBp, 8889);
    });

    test('HPP memakai qty satuan dasar', () {
      // 2 dus isi 12, biaya 1.000 per pcs.
      final dus = line('d', qty: 2000, factor: 12000, total: 30000, cost: 1000);
      final pl = ProfitAndLoss.compute(
        sales: [
          sale([dus]),
        ],
        returns: const [],
        expenses: const [],
        stockAdjustment: Money.zero,
      );
      expect(pl.cogs, const Money(24000));
      expect(pl.taxCollected, Money.zero);
    });

    test('PB1 dipungut tidak masuk penjualan bersih', () {
      final pl = ProfitAndLoss.compute(
        sales: [
          sale([line('a', total: 100000, cost: 0)], tax: 10000),
        ],
        returns: const [],
        expenses: const [],
        stockAdjustment: Money.zero,
      );
      expect(pl.netSales, const Money(100000));
      expect(pl.taxCollected, const Money(10000));
    });
  });

  group('SalesBreakdown', () {
    final kopi = line('k1', variant: 'kopi', qty: 3000, total: 30000);
    final kopi2 = line('k2', variant: 'kopi', qty: 1000, total: 10000);
    final teh = line('t1', variant: 'teh', name: 'Teh', total: 8000);
    final roti = line(
      'r1',
      variant: 'roti',
      name: 'Roti',
      qty: 1000,
      factor: 6000,
      total: 30000,
    );
    final sales = [
      sale([kopi, teh], staff: 'sari'),
      sale([kopi2, roti], staff: 'budi', tax: 4000),
    ];
    final returns = [
      ReportReturn(
        saleStaffKey: 'sari',
        amount: const Money(10000),
        saleTax: Money.zero,
        saleTotal: const Money(38000),
        restock: true,
        lines: [ReportReturnLine(kopi, 1000)],
      ),
    ];

    test('per produk: qty dasar bersih dan nilai tanpa PB1', () {
      final rows = salesByProduct(sales, returns);
      expect(rows.map((r) => (r.key, r.name, r.quantity, r.value)), [
        ('kopi', 'Kopi', Qty.units(3), const Money(30000)),
        ('roti', 'Roti', Qty.units(6), const Money(30000)),
        ('teh', 'Teh', Qty.units(1), const Money(8000)),
      ]);
    });

    test('per kategori', () {
      final rows = salesByCategory(salesByProduct(sales, returns), {
        'kopi': 'Minuman',
        'teh': 'Minuman',
      });
      expect(rows.map((r) => (r.key, r.name, r.value)), [
        ('Minuman', 'Minuman', const Money(38000)),
        ('', '', const Money(30000)),
      ]);
      expect(rows.first.quantity, Qty.units(4));
    });

    test('per kasir: jumlah nota dan penjualan bersih', () {
      final rows = salesByStaff(sales, returns);
      expect(rows.map((r) => (r.key, r.count, r.value)), [
        ('budi', 1, const Money(40000)),
        ('sari', 1, const Money(28000)),
      ]);
    });

    test('service makan di tempat: per kasir memuatnya, per produk tidak', () {
      final nasi = line('n1', variant: 'nasi', name: 'Nasi', total: 20000);
      final dineIn = [
        sale([nasi], service: 1000),
      ];
      final product = salesByProduct(dineIn, const []);
      final staff = salesByStaff(dineIn, const []);
      final pl = ProfitAndLoss.compute(
        sales: dineIn,
        returns: const [],
        expenses: const [],
        stockAdjustment: Money.zero,
      );
      expect(product.single.value, const Money(20000));
      expect(staff.single.value, const Money(21000));
      expect(pl.netSales, staff.single.value);
      // Selisihnya tepat service charge di laba rugi.
      expect(staff.single.value - product.single.value, pl.service);
    });

    test('terlaris: qty, lalu nilai, lalu nama; dibatasi', () {
      final rows = topProducts(salesByProduct(sales, returns), limit: 2);
      expect(rows.map((r) => r.key), ['roti', 'kopi']);
    });

    test('retur yang menghabiskan baris mengambil sisa nilai', () {
      final odd = line('o', variant: 'o', qty: 3000, total: 10000);
      final rows = salesByProduct(
        [
          sale([odd]),
        ],
        [
          ReportReturn(
            saleStaffKey: 'sari',
            amount: const Money(3333),
            saleTax: Money.zero,
            saleTotal: const Money(10000),
            restock: true,
            lines: [ReportReturnLine(odd, 1000)],
          ),
          ReportReturn(
            saleStaffKey: 'sari',
            amount: const Money(6667),
            saleTax: Money.zero,
            saleTotal: const Money(10000),
            restock: true,
            lines: [ReportReturnLine(odd, 2000)],
          ),
        ],
      );
      expect(rows.single.quantity, Qty.zero);
      expect(rows.single.value, Money.zero);
    });
  });

  group('paymentMix', () {
    test('tunai bersih kembalian, non tunai, kredit; urut dan persen', () {
      final rows = paymentMix([
        sale(
          [line('a', total: 50000)],
          payments: [
            ReportPayment(
              ReportPaymentMethod.cash,
              const Money(100000),
              const Money(50000),
            ),
          ],
        ),
        sale(
          [line('b', total: 30000)],
          payments: [
            ReportPayment(
              ReportPaymentMethod.qris,
              const Money(20000),
              Money.zero,
            ),
            ReportPayment(
              ReportPaymentMethod.cash,
              const Money(10000),
              Money.zero,
            ),
          ],
        ),
        sale(
          [line('c', total: 20000)],
          credit: true,
          paid: 5000,
          payments: [
            ReportPayment(
              ReportPaymentMethod.cash,
              const Money(5000),
              Money.zero,
            ),
          ],
        ),
      ]);
      expect(rows.map((r) => (r.method, r.amount, r.shareBp)), [
        (ReportPaymentMethod.cash, const Money(65000), 6500),
        (ReportPaymentMethod.qris, const Money(20000), 2000),
        (ReportPaymentMethod.credit, const Money(15000), 1500),
      ]);
      expect(paymentMix(const []), isEmpty);
    });
  });
}
