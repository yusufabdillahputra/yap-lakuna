import 'dart:async';

import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/reports_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

ReportSaleLine _line(
  String key,
  String variant,
  String name,
  int qty,
  int total,
  int cost,
) => ReportSaleLine(
  key: key,
  variantKey: variant,
  name: name,
  quantityMilli: qty,
  factorMilli: 1000,
  lineTotal: Money(total),
  unitCost: Money(cost),
);

/// [ReportsRepository] palsu dengan data hitungan tangan (hari ini
/// 2026-11-04, Cabang Pusat):
///
/// - Nota Sari: 3 Kopi Susu 54.000 + 1 Roti Bakar 25.000, tunai.
/// - Nota Budi: 2 Air Mineral 10.000, QRIS.
/// - Nota Sari: 1 Kopi Susu 18.000 diskon 2.000, kartu.
/// - Retur 1 Kopi Susu 18.000 (restock).
/// - Beban: Sewa tempat 20.000, Listrik & air 5.000; penyesuaian −3.000.
///
/// Penjualan bersih 87.000, HPP 27.000, laba kotor 60.000 (69,0%), laba
/// bersih 32.000; periode lalu laba bersih 16.000 (+100%). Periode bulan
/// tertentu kosong.
class FakeReportsRepository extends ReportsRepository {
  FakeReportsRepository({this.canView = true, this.canViewProfit = true});

  bool canView;
  bool canViewProfit;
  final today = DateTime.utc(2026, 11, 4);
  final requests = <ReportPeriod>[];

  /// Muatan periode ini ditahan sampai completer-nya selesai.
  final holds = <ReportPeriod, Completer<void>>{};

  static final kopi = _line('k1', 'kopi', 'Kopi Susu', 3000, 54000, 6000);

  @override
  Future<Result<ReportData>> load(ReportPeriod period) async {
    requests.add(period);
    if (holds[period] case final hold?) await hold.future;
    if (!canView) {
      return const Result.error(NotPermitted(Permission.reportsView));
    }
    final empty = period.kind == ReportPeriodKind.month;
    final sales = empty
        ? const <ReportSale>[]
        : [
            ReportSale(
              staffKey: 'sari',
              subtotal: const Money(79000),
              tierDiscount: Money.zero,
              service: Money.zero,
              tax: Money.zero,
              total: const Money(79000),
              credit: false,
              paidAtSale: const Money(79000),
              payments: const [
                ReportPayment(
                  ReportPaymentMethod.cash,
                  Money(100000),
                  Money(21000),
                ),
              ],
              lines: [
                kopi,
                _line('r1', 'roti', 'Roti Bakar', 1000, 25000, 9000),
              ],
            ),
            ReportSale(
              staffKey: 'budi',
              subtotal: const Money(10000),
              tierDiscount: Money.zero,
              service: Money.zero,
              tax: Money.zero,
              total: const Money(10000),
              credit: false,
              paidAtSale: const Money(10000),
              payments: const [
                ReportPayment(
                  ReportPaymentMethod.qris,
                  Money(10000),
                  Money.zero,
                ),
              ],
              lines: [_line('a1', 'air', 'Air Mineral', 2000, 10000, 0)],
            ),
            ReportSale(
              staffKey: 'sari',
              subtotal: const Money(18000),
              tierDiscount: const Money(2000),
              service: Money.zero,
              tax: Money.zero,
              total: const Money(16000),
              credit: false,
              paidAtSale: const Money(16000),
              payments: const [
                ReportPayment(
                  ReportPaymentMethod.card,
                  Money(16000),
                  Money.zero,
                ),
              ],
              lines: [_line('k2', 'kopi', 'Kopi Susu', 1000, 16000, 6000)],
            ),
          ];
    final returns = empty
        ? const <ReportReturn>[]
        : [
            ReportReturn(
              saleStaffKey: 'sari',
              amount: const Money(18000),
              saleTax: Money.zero,
              saleTotal: const Money(79000),
              restock: true,
              lines: [ReportReturnLine(kopi, 1000)],
            ),
          ];
    final profit = ProfitAndLoss.compute(
      sales: sales,
      returns: returns,
      expenses: empty
          ? const []
          : const [
              ExpenseLine('Sewa tempat', Money(20000)),
              ExpenseLine('Listrik & air', Money(5000)),
            ],
      stockAdjustment: empty ? Money.zero : const Money(-3000),
    );
    final previous = ProfitAndLoss.compute(
      sales: [
        ReportSale(
          staffKey: 'sari',
          subtotal: const Money(36000),
          tierDiscount: Money.zero,
          service: Money.zero,
          tax: Money.zero,
          total: const Money(36000),
          credit: false,
          paidAtSale: const Money(36000),
          payments: const [],
          lines: [_line('p1', 'kopi', 'Kopi Susu', 2000, 36000, 6000)],
        ),
      ],
      returns: const [],
      expenses: const [ExpenseLine('Sewa tempat', Money(8000))],
      stockAdjustment: Money.zero,
    );
    return Result.ok(
      ReportData(
        period: period,
        range: period.range(today),
        today: today,
        outletName: 'Cabang Pusat',
        sales: sales,
        returns: returns,
        staffNames: const {'sari': 'Sari', 'budi': 'Budi'},
        categoryOf: const {'kopi': 'Minuman', 'air': 'Minuman'},
        unitOf: const {'kopi': 'gelas', 'roti': 'porsi', 'air': 'botol'},
        overdue: empty ? Money.zero : const Money(150000),
        overdueCustomers: empty ? 0 : 2,
        profit: canViewProfit ? profit : null,
        previousProfit: canViewProfit ? previous : null,
      ),
    );
  }
}
