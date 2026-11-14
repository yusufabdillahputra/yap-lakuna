import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../l10n/gen/app_localizations.dart';
import '../receipt/receipt_content.dart' show mergeSplitPortions, receiptDate;

String _qty(AppLocalizations l10n, int milli) =>
    l10n.localeName.startsWith('en')
    ? Qty(milli).format(decimal: '.', group: ',')
    : Qty(milli).format(decimal: ',', group: '.');

/// Baris tiket dapur 1.7e: judul, meja/take away, nomor `K-0012`, jam,
/// pelayan, lalu item baru (jumlah × nama) dengan modifier (`+ Besar`) dan
/// catatan berawalan `*`, tanpa harga. [heading] mengganti judul (mis.
/// *TIKET BAR*, F1-10j).
List<ReceiptLine> kitchenTicketLines(
  AppLocalizations l10n, {
  required KitchenSendResult result,
  required String? timezone,
  required ReceiptPaper paper,
  String? heading,
}) {
  final w = paper.columns;
  final bill = result.bill;
  final rule = ReceiptLine('-' * w);
  List<ReceiptLine> centered(String text, {bool bold = false}) => [
    for (final l in wrapText(text, w))
      ReceiptLine(l, align: ReceiptAlign.center, bold: bold),
  ];
  return [
    ...centered(heading ?? l10n.ticketHeading, bold: true),
    ...centered(
      bill.isTakeAway
          ? l10n.ticketTakeAway(bill.label)
          : l10n.ticketDineIn(bill.label),
      bold: true,
    ),
    if (bill.sale.customerName case final name? when name.trim().isNotEmpty)
      ...centered(name.trim()),
    rule,
    if (result.ticket case final ticket?) ...[
      ...layoutPair(l10n.ticketNo, kitchenTicketLabel(ticket.number), w),
      ...layoutPair(
        l10n.ticketTime,
        receiptDate(outletLocalTime(ticket.sentAt, timezone)),
        w,
      ),
    ],
    ...layoutPair(l10n.ticketStaff, result.staffName, w),
    rule,
    // Porsi split bill yang dikirim bersamaan digabung kembali.
    for (final item in mergeSplitPortions(result.items)) ...[
      for (final l in wrapText(
        '${_qty(l10n, item.quantityMilli)}'
        '${item.productUnitId == null ? '' : ' ${item.unitName}'}'
        ' x ${'${item.productName} ${item.variantName}'.trim()}',
        w,
      ))
        ReceiptLine(l, bold: true),
      for (final m in result.modifiersOf(item))
        for (final l in wrapText('+ ${m.name}', w - 2)) ReceiptLine('  $l'),
      if (item.note case final note? when note.trim().isNotEmpty)
        for (final l in wrapText('* ${note.trim()}', w - 2))
          ReceiptLine('  $l'),
    ],
    rule,
    ...centered(l10n.ticketFooter),
  ];
}

/// Tiket contoh untuk *Tes cetak tiket* di Pengaturan (F1-10e); [bar]
/// untuk *Tes cetak tiket bar* (F1-10j).
List<ReceiptLine> sampleKitchenTicketLines(
  AppLocalizations l10n, {
  required ReceiptPaper paper,
  required String staffName,
  required DateTime now,
  bool bar = false,
}) {
  final w = paper.columns;
  final rule = ReceiptLine('-' * w);
  List<ReceiptLine> centered(String text, {bool bold = false}) => [
    for (final l in wrapText(text, w))
      ReceiptLine(l, align: ReceiptAlign.center, bold: bold),
  ];
  List<ReceiptLine> item(String text, String extra) => [
    for (final l in wrapText(text, w)) ReceiptLine(l, bold: true),
    for (final l in wrapText(extra, w - 2)) ReceiptLine('  $l'),
  ];
  return [
    ...centered(bar ? l10n.barTicketHeading : l10n.ticketHeading, bold: true),
    ...centered(l10n.ticketDineIn('A1'), bold: true),
    rule,
    ...layoutPair(l10n.ticketNo, kitchenTicketLabel(1), w),
    ...layoutPair(l10n.ticketTime, receiptDate(now), w),
    ...layoutPair(l10n.ticketStaff, staffName, w),
    rule,
    if (!bar) ...item('1 x Nasi Goreng', '+ Pedas'),
    ...item('2 x Es Teh Manis', '* Tanpa es'),
    rule,
    ...centered(l10n.ticketFooter),
  ];
}
