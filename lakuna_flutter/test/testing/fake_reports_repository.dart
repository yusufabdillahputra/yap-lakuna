import 'dart:async';

import 'package:lakuna_client/lakuna_client.dart';
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

  /// Permintaan tab lanjutan, mis. `stock:ReportPeriod.today`.
  final extraRequests = <String>[];

  Future<Result<T>> _extra<T>(
    String tab,
    ReportPeriod? period,
    T Function() build,
  ) async {
    extraRequests.add('$tab:$period');
    if (holds[period] case final hold?) await hold.future;
    if (!canView) {
      return const Result.error(NotPermitted(Permission.reportsView));
    }
    return Result.ok(build());
  }

  static UuidValue _uuid(int n) =>
      UuidValue.fromString('00000000-0000-7000-8000-${'$n'.padLeft(12, '0')}');

  /// Stok: Kopi 20 + 1 − 4 = 17 gelas × 6.000; Roti 10 − 1 = 9 porsi ×
  /// 9.000; nilai 183.000.
  @override
  Future<Result<StockReport>> loadStock(ReportPeriod period) async =>
      _extra('stock', period, () {
        final empty = period.kind == ReportPeriodKind.month;
        StockMovementRow row(
          String key,
          String name,
          int opening,
          int inflow,
          int outflow,
          int cost,
        ) => StockMovementRow(
          key: key,
          name: name,
          opening: Qty.units(opening),
          inflow: Qty.units(inflow),
          outflow: Qty.units(outflow),
          value: canViewProfit
              ? Money(cost * (opening + inflow - outflow))
              : null,
        );
        return StockReport(
          rows: empty
              ? const []
              : [
                  row('kopi', 'Kopi Susu', 20, 1, 4, 6000),
                  row('roti', 'Roti Bakar', 10, 0, 1, 9000),
                ],
          unitOf: const {'kopi': 'gelas', 'roti': 'porsi'},
          variantCount: 3,
          lowCount: 1,
          outCount: 1,
          totalValue: canViewProfit ? const Money(183000) : null,
        );
      });

  /// Kas: sesi Sari masih buka (seharusnya 179.000), sesi Budi kemarin
  /// kurang 5.000; masuk manual 5.000, keluar pengeluaran 25.000 (2×) dan
  /// manual 15.000.
  @override
  Future<Result<CashReport>> loadCash(ReportPeriod period) async =>
      _extra('cash', period, () {
        if (period.kind == ReportPeriodKind.month) {
          return const CashReport(sessions: [], inflows: [], outflows: []);
        }
        return CashReport(
          sessions: [
            CashSessionLine(
              openedAt: DateTime.utc(2026, 11, 4, 8),
              staffName: 'Sari',
              opening: const Money(100000),
              expected: const Money(179000),
            ),
            CashSessionLine(
              openedAt: DateTime.utc(2026, 11, 3, 8),
              closedAt: DateTime.utc(2026, 11, 3, 21),
              staffName: 'Budi',
              opening: const Money(100000),
              expected: const Money(150000),
              counted: const Money(145000),
              difference: const Money(-5000),
            ),
          ],
          inflows: const [
            GroupTotal(CashSourceKind.manualIn, 1, Money(5000)),
          ],
          outflows: const [
            GroupTotal(CashSourceKind.expense, 2, Money(25000)),
            GroupTotal(CashSourceKind.manualOut, 1, Money(15000)),
          ],
        );
      });

  /// Piutang: Budi 150.000 (lewat tempo) dan Rina 50.000; hutang CV Sumber
  /// 120.000 jatuh tempo 10/11/2026.
  @override
  Future<Result<DebtReport>> loadDebts() async => _extra('debts', null, () {
    CustomerRow customer(int n, String name, int debt, int overdue) =>
        CustomerRow(
          customer: Customer(
            id: _uuid(n),
            tenantId: _uuid(99),
            name: name,
            creditLimit: 1000000,
            createdAt: DateTime.utc(2026, 11, 1),
            hlc: '',
          ),
          groupName: null,
          termDays: 14,
          outstanding: Money(debt),
          openCount: 1,
          overdueCount: overdue,
        );
    return DebtReport(
      today: today,
      customers: [
        customer(1, 'Budi', 150000, 1),
        customer(2, 'Rina', 50000, 0),
      ],
      suppliers: [
        SupplierRow(
          supplier: Supplier(
            id: _uuid(3),
            tenantId: _uuid(99),
            name: 'CV Sumber',
            termDays: 14,
            createdAt: DateTime.utc(2026, 3, 1),
            hlc: '',
          ),
          debt: const Money(120000),
          openCount: 2,
          overdueCount: 0,
          nearestDue: DateTime.utc(2026, 11, 10),
        ),
      ],
      overdue: const Money(150000),
      overdueCustomers: 1,
      overduePurchases: 0,
    );
  });

  /// Retur: 1 Kopi Susu salah barang (ke stok) 18.000.
  @override
  Future<Result<ReturnsReport>> loadReturns(ReportPeriod period) async =>
      _extra('returns', period, () {
        if (period.kind == ReportPeriodKind.month) {
          return const ReturnsReport([]);
        }
        return ReturnsReport([
          ReturnReportLine(
            returnedAt: DateTime.utc(2026, 11, 4, 11, 5),
            number: 'RT-PST-K01-261104-0001',
            saleNumber: 'PST-K01-261104-0001',
            staffName: 'Sari',
            reason: SaleReturnReason.wrongItem,
            restock: true,
            refundMethod: RefundMethod.cash,
            amount: const Money(18000),
          ),
        ]);
      });

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
