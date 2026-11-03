import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../l10n/gen/app_localizations.dart';
import '../cashier/payment_view.dart' show paymentMethodLabel;

bool _english(AppLocalizations l10n) => l10n.localeName.startsWith('en');

/// Nominal struk tanpa "Rp": `200.000` (id) / `200,000` (en).
String receiptAmount(AppLocalizations l10n, int value) =>
    groupThousands(value, _english(l10n) ? ',' : '.');

String _qty(AppLocalizations l10n, int milli) => _english(l10n)
    ? Qty(milli).format(decimal: '.', group: ',')
    : Qty(milli).format(decimal: ',', group: '.');

/// `dd/MM/yy HH.mm`.
String receiptDate(DateTime local) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${two(local.year % 100)} '
      '${two(local.hour)}.${two(local.minute)}';
}

List<String> _footer(AppLocalizations l10n, ReceiptConfig config) =>
    config.footerLines ?? [l10n.receiptThanks];

/// Isi struk nota [result] (F1-06, 1.12).
ReceiptContent saleReceiptContent(
  AppLocalizations l10n, {
  required CheckoutResult result,
  required String businessName,
  required String outletName,
  required String staffName,
  required String? timezone,
  required ReceiptConfig config,
  String? banner,
}) {
  final sale = result.sale;
  return ReceiptContent(
    storeName: businessName.toUpperCase(),
    outletName: outletName,
    header: config.headerLines,
    banner: banner,
    meta: [
      ReceiptPair(l10n.receiptNo, sale.number),
      ReceiptPair(
        l10n.receiptDate,
        receiptDate(outletLocalTime(sale.soldAt, timezone)),
      ),
      ReceiptPair(l10n.receiptCashier, staffName),
    ],
    items: [
      for (final item in result.items)
        ReceiptItem(
          name: '${item.productName} ${item.variantName}'.trim(),
          detail:
              '${_qty(l10n, item.quantityMilli)}'
              '${item.productUnitId == null ? '' : ' ${item.unitName}'}'
              ' x ${receiptAmount(l10n, item.unitPrice)}',
          amount: receiptAmount(l10n, item.lineTotal),
        ),
    ],
    totals: [
      ReceiptPair(
        l10n.receiptTotal,
        receiptAmount(l10n, sale.total),
        bold: true,
      ),
      for (final payment in result.payments)
        ReceiptPair(
          paymentMethodLabel(l10n, payment.method),
          receiptAmount(l10n, payment.amount),
        ),
      if (result.payments.any((p) => p.method == PaymentMethod.cash))
        ReceiptPair(l10n.receiptChange, receiptAmount(l10n, sale.changeAmount)),
    ],
    footer: _footer(l10n, config),
  );
}

/// Struk contoh untuk pratinjau Pengaturan dan *Tes cetak*.
ReceiptContent sampleReceiptContent(
  AppLocalizations l10n, {
  required String businessName,
  required String outletName,
  required String staffName,
  required ReceiptConfig config,
  required DateTime now,
}) {
  ReceiptItem item(String name, int qty, int price) => ReceiptItem(
    name: name,
    detail: '$qty x ${receiptAmount(l10n, price)}',
    amount: receiptAmount(l10n, qty * price),
  );
  return ReceiptContent(
    storeName: businessName.toUpperCase(),
    outletName: outletName,
    header: config.headerLines,
    meta: [
      ReceiptPair(l10n.receiptNo, l10n.receiptSampleNumber),
      ReceiptPair(l10n.receiptDate, receiptDate(now)),
      ReceiptPair(l10n.receiptCashier, staffName),
    ],
    items: [
      item('Beras Premium 5 kg', 2, 70000),
      item('Minyak Goreng 2 L', 1, 36000),
      item('Kopi Sachet', 2, 2000),
    ],
    totals: [
      ReceiptPair(l10n.receiptTotal, receiptAmount(l10n, 180000), bold: true),
      ReceiptPair(l10n.paymentCash, receiptAmount(l10n, 200000)),
      ReceiptPair(l10n.receiptChange, receiptAmount(l10n, 20000)),
    ],
    footer: _footer(l10n, config),
  );
}
