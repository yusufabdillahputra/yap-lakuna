import 'dart:convert';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/cash_drawer_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../receipt/receipt_content.dart';

/// Data rekap sesi yang baru ditutup (F1-03b): isi sesi saat tombol tutup
/// ditekan, sesi tertutup (angka akhir), dan nama staf penutup.
@immutable
class SessionRecap {
  const SessionRecap({
    required this.active,
    required this.closed,
    required this.closerName,
  });

  final ActiveCashSession active;
  final CashSession closed;
  final String closerName;
}

/// Isi struk rekap sesi kasir (F1-03b), dicetak dengan mesin struk F1-06.
ReceiptContent sessionRecapContent(
  AppLocalizations l10n, {
  required SessionRecap recap,
  required String businessName,
  required String outletName,
  required String deviceCode,
  required String? timezone,
}) {
  String amount(int value) => receiptAmount(l10n, value);
  String signed(int value) =>
      '${value < 0 ? '-' : ''}${receiptAmount(l10n, value.abs())}';
  String date(DateTime t) => receiptDate(outletLocalTime(t, timezone));
  String clock(DateTime t) {
    final local = outletLocalTime(t, timezone);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.hour)}.${two(local.minute)}';
  }

  final active = recap.active;
  final closed = recap.closed;
  final sales = active.sales;
  final drawer = active.drawer;
  final difference = closed.difference ?? 0;
  final breakdown = closed.countedBreakdown;
  final count = breakdown == null
      ? null
      : CashCount.fromJson(jsonDecode(breakdown) as Map<String, Object?>);

  return ReceiptContent(
    storeName: businessName,
    outletName: outletName,
    banner: l10n.recapTitle,
    meta: [
      ReceiptPair(l10n.recapDevice, deviceCode),
      ReceiptPair(l10n.recapOpened, date(active.session.openedAt)),
      ReceiptPair(l10n.recapOpenedBy, active.openedByName),
      ReceiptPair(
        l10n.recapClosed,
        date(closed.closedAt ?? closed.updatedAt),
      ),
      ReceiptPair(l10n.recapClosedBy, recap.closerName),
    ],
    sections: [
      [
        ReceiptPair(l10n.cashStatTransactions, '${sales.count}'),
        ReceiptPair(l10n.cashStatSales, amount(sales.total.value)),
        ReceiptPair(l10n.recapCash, amount(sales.cash.value)),
        ReceiptPair(l10n.recapNonCash, amount(sales.nonCash.value)),
        if (sales.credit != Money.zero)
          ReceiptPair(l10n.recapCredit, amount(sales.credit.value)),
        ReceiptPair(
          l10n.cashStatVoids,
          '${sales.voidCount} / ${sales.returnCount}',
        ),
      ],
      [
        ReceiptPair(l10n.recapOpening, amount(drawer.openingCash.value)),
        ReceiptPair(l10n.cashRecapCashSales, amount(drawer.cashSales.value)),
        if (drawer.cashRefunds != Money.zero)
          ReceiptPair(
            l10n.cashRecapCashRefunds,
            signed(-drawer.cashRefunds.value),
          ),
        ReceiptPair(l10n.recapInflow, amount(drawer.inflow.value)),
        ReceiptPair(l10n.recapOutflow, signed(-drawer.outflow.value)),
      ],
      [
        for (final m in active.movements)
          ReceiptPair(
            '${clock(m.createdAt)} ${m.note}',
            signed(
              m.direction == CashDirection.inflow ? m.amount : -m.amount,
            ),
          ),
      ],
      if (count != null)
        [
          for (final d in cashDenominations)
            if (count.sheetsOf(d) > 0)
              ReceiptPair(
                '${amount(d)} x ${count.sheetsOf(d)}',
                amount(d * count.sheetsOf(d)),
              ),
          if (count.coins != Money.zero)
            ReceiptPair(l10n.cashCoins, amount(count.coins.value)),
        ],
    ],
    totals: [
      ReceiptPair(
        l10n.cashRecapExpected,
        amount(closed.expectedCash ?? 0),
        bold: true,
      ),
      ReceiptPair(l10n.cashCounted, amount(closed.countedCash ?? 0)),
      ReceiptPair(
        l10n.cashDifference,
        difference == 0
            ? l10n.cashDifferenceExact
            : '${difference > 0 ? '+' : ''}${signed(difference)}',
        bold: true,
      ),
    ],
    footer: [
      if (closed.closingNote case final note?) l10n.recapNote(note),
    ],
  );
}
