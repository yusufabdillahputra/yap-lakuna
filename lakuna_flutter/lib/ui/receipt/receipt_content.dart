import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../l10n/gen/app_localizations.dart';
import '../cashier/payment_view.dart' show paymentMethodLabel;

bool _english(AppLocalizations l10n) => l10n.localeName.startsWith('en');

/// Nominal struk tanpa "Rp": `200.000` (id) / `200,000` (en).
String receiptAmount(AppLocalizations l10n, int value) =>
    groupThousands(value, _english(l10n) ? ',' : '.');

/// Nominal bertanda untuk tambahan modifier: `-3.000`, `4.000`.
String _signed(AppLocalizations l10n, int value) =>
    '${value < 0 ? '-' : ''}${receiptAmount(l10n, value.abs())}';

String _qty(AppLocalizations l10n, int milli) => _english(l10n)
    ? Qty(milli).format(decimal: '.', group: ',')
    : Qty(milli).format(decimal: ',', group: '.');

/// Tarif basis poin sebagai persen: `5%`, `5,5%` (id) / `5.5%` (en).
String percentLabel(AppLocalizations l10n, int bp) {
  final whole = bp ~/ 100;
  final frac = bp % 100;
  if (frac == 0) return '$whole%';
  final digits = frac % 10 == 0
      ? '${frac ~/ 10}'
      : frac.toString().padLeft(2, '0');
  return '$whole${_english(l10n) ? '.' : ','}$digits%';
}

/// `dd/MM/yy HH.mm`.
String receiptDate(DateTime local) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${two(local.year % 100)} '
      '${two(local.hour)}.${two(local.minute)}';
}

List<String> _footer(AppLocalizations l10n, ReceiptConfig config) =>
    config.footerLines ?? [l10n.receiptThanks];

/// Isi struk nota [result] (F1-06, 1.12). Cetak ulang riwayat (F1-11)
/// memberi [banner] dan nilai [returned].
ReceiptContent saleReceiptContent(
  AppLocalizations l10n, {
  required CheckoutResult result,
  required String businessName,
  required String outletName,
  required String staffName,
  required String? timezone,
  required ReceiptConfig config,
  String? banner,
  String? orderLabel,
  int returned = 0,
}) {
  final sale = result.sale;
  // Rincian Subtotal muncul bila ada service, PB1, atau pembulatan (retail
  // pun) agar selisih ke TOTAL terlihat.
  final breakdown =
      sale.serviceAmount != 0 ||
      sale.taxAmount != 0 ||
      sale.roundingAmount != 0 ||
      sale.discountAmount != 0;
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
      if (orderLabel != null) ReceiptPair(l10n.receiptOrder, orderLabel),
      if (sale.customerId != null && sale.customerName != null)
        ReceiptPair(l10n.receiptCustomer, sale.customerName!),
    ],
    items: [
      for (final item in mergeSplitPortions(result.items))
        ReceiptItem(
          name: '${item.productName} ${item.variantName}'.trim(),
          extras: [
            for (final m in result.modifiersOf(item))
              m.priceDelta == 0
                  ? '+ ${m.name}'
                  : '+ ${m.name} ${_signed(l10n, m.priceDelta)}',
          ],
          // Harga satuan termasuk tambahan modifier agar jumlah × harga =
          // total baris.
          detail:
              '${_qty(l10n, item.quantityMilli)}'
              '${item.productUnitId == null ? '' : ' ${item.unitName}'}'
              ' x ${receiptAmount(l10n, item.unitPrice + item.modifierDelta)}',
          // Jumlah sebelum diskon baris; potongannya di baris sendiri.
          amount: receiptAmount(l10n, item.lineTotal + item.discountAmount),
          discount: item.discountAmount == 0
              ? null
              : ReceiptPair(
                  item.discountBp == 0
                      ? l10n.receiptDiscount
                      : l10n.receiptDiscountPct(
                          percentLabel(l10n, item.discountBp),
                        ),
                  '-${receiptAmount(l10n, item.discountAmount)}',
                ),
        ),
    ],
    totals: [
      if (breakdown) ...[
        ReceiptPair(
          l10n.receiptSubtotal,
          receiptAmount(
            l10n,
            result.items.fold(0, (sum, i) => sum + i.lineTotal),
          ),
        ),
        if (sale.discountAmount != 0)
          ReceiptPair(
            sale.discountBp == 0
                ? l10n.receiptDiscount
                : l10n.receiptDiscountPct(percentLabel(l10n, sale.discountBp)),
            '-${receiptAmount(l10n, sale.discountAmount)}',
          ),
        if (sale.serviceAmount != 0)
          ReceiptPair(
            l10n.receiptService(percentLabel(l10n, sale.serviceBp)),
            receiptAmount(l10n, sale.serviceAmount),
          ),
        if (sale.taxAmount != 0)
          ReceiptPair(
            sale.taxInclusive
                ? l10n.receiptTaxIncluded(percentLabel(l10n, sale.taxBp))
                : l10n.receiptTax(percentLabel(l10n, sale.taxBp)),
            receiptAmount(l10n, sale.taxAmount),
          ),
        if (sale.roundingAmount != 0)
          ReceiptPair(
            l10n.receiptRounding,
            sale.roundingAmount < 0
                ? '-${receiptAmount(l10n, -sale.roundingAmount)}'
                : receiptAmount(l10n, sale.roundingAmount),
          ),
      ],
      ReceiptPair(
        l10n.receiptTotal,
        receiptAmount(l10n, sale.total),
        bold: true,
      ),
      for (final payment in result.payments)
        ReceiptPair(
          switch (payment.guestLabel) {
            final label? => l10n.receiptGuestPayment(
              label,
              paymentMethodLabel(l10n, payment.method),
            ),
            null => paymentMethodLabel(l10n, payment.method),
          },
          receiptAmount(l10n, payment.amount),
        ),
      if (result.payments.any((p) => p.method == PaymentMethod.cash))
        ReceiptPair(l10n.receiptChange, receiptAmount(l10n, sale.changeAmount)),
      // Nota kredit (F1-13): sisa jadi piutang dan jatuh temponya.
      if (sale.customerId != null && sale.paidAmount < sale.total) ...[
        ReceiptPair(
          l10n.receiptDebt,
          receiptAmount(l10n, sale.total - sale.paidAmount),
          bold: true,
        ),
        if (sale.dueOn case final due?)
          ReceiptPair(
            l10n.receiptDueOn,
            '${due.day.toString().padLeft(2, '0')}/'
            '${due.month.toString().padLeft(2, '0')}/${due.year % 100}',
          ),
      ],
      // Cetak ulang nota yang diretur (F1-11): nilai retur dan bersih.
      if (returned != 0) ...[
        ReceiptPair(l10n.receiptReturned, '-${receiptAmount(l10n, returned)}'),
        ReceiptPair(
          l10n.receiptNet,
          receiptAmount(l10n, sale.total - returned),
          bold: true,
        ),
      ],
    ],
    footer: _footer(l10n, config),
  );
}

/// Porsi split bill (F1-10c) digabung kembali ke baris asalnya agar struk
/// sama dengan pesanan: jumlah, total baris, dan potongan diskon baris
/// dijumlahkan, urutan ikut kemunculan pertama. Porsi dengan diskon baris
/// berbeda (F1-04g) tetap baris sendiri.
List<SaleItem> mergeSplitPortions(List<SaleItem> items) {
  final merged = <(UuidValue, int, bool), SaleItem>{};
  for (final item in items) {
    final key = (
      item.splitFromItemId ?? item.id,
      item.discountBp,
      item.discountBp == 0 && item.discountAmount > 0,
    );
    final prev = merged[key];
    merged[key] = prev == null
        ? item
        : prev.copyWith(
            quantityMilli: prev.quantityMilli + item.quantityMilli,
            lineTotal: prev.lineTotal + item.lineTotal,
            discountAmount: prev.discountAmount + item.discountAmount,
          );
  }
  return merged.values.toList();
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
