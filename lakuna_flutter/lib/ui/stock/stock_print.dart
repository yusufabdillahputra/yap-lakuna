import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/services/report_document.dart';
import '../../data/services/spreadsheet_exporter.dart' show XlsxNumber;
import '../../l10n/gen/app_localizations.dart';
import '../core/format.dart' show formatClock;
import '../customers/customer_labels.dart' show formatLongDate;
import '../reports/report_labels.dart' show qtyLabel;

/// Isi cetakan *Cetak stok* (F1-08b): semua [rows] lokasi [location]
/// dengan kolom *Fisik* kosong untuk hitung tangan. Kata pencarian layar
/// sengaja tidak dipakai agar daftar opname lengkap.
ReportTable stockPrintTable(
  AppLocalizations l10n, {
  required List<StockRow> rows,
  required String location,
  required String outlet,
  required String staff,
  required DateTime printedAt,
  String? timezone,
}) {
  final local = outletLocalTime(printedAt, timezone);
  XlsxNumber money(Money m) => XlsxNumber(m.value);
  return ReportTable(
    title: l10n.stockPrintTitle(location),
    subtitle: l10n.stockPrintSubtitle(
      outlet,
      '${formatLongDate(l10n, local)} ${formatClock(printedAt, timezone)}',
      staff,
    ),
    headers: [
      l10n.stockColProduct,
      l10n.stockPrintColCode,
      l10n.stockColStock,
      l10n.stockColMinimum,
      l10n.stockColValue,
      l10n.stockPrintColCounted,
    ],
    widths: [36, 16, 14, 12, 16, 12],
    // Stok memuat satuan (mis. `12,5 bungkus`): jangan sampai terlipat.
    flex: [5, 3, 3, 2, 3, 2],
    rows: [
      for (final r in rows)
        ReportRow([
          r.displayName,
          r.sku ?? r.barcode ?? '',
          '${qtyLabel(l10n, r.stock)} ${r.baseUnit}',
          r.minStock.isPositive ? qtyLabel(l10n, r.minStock) : '',
          money(r.value),
          '',
        ]),
      ReportRow([
        l10n.reportsTotal,
        '',
        '',
        '',
        money(rows.fold(Money.zero, (sum, r) => sum + r.value)),
        '',
      ], strong: true),
    ],
    notes: [
      l10n.stockPrintCounts(
        rows.length,
        rows.where((r) => r.belowMinimum).length,
        rows.where((r) => r.stock.milli < 0).length,
      ),
      l10n.stockPrintNote,
    ],
  );
}

/// `stok-<lokasi>-<yymmdd>.pdf`: lokasi huruf kecil, selain huruf/angka
/// menjadi `-`; lokasi tanpa huruf/angka menjadi `lokasi`.
String stockPrintFileName(String location, DateTime at, String? timezone) {
  final slug = location
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  final d = outletLocalTime(at, timezone);
  String two(int n) => n.toString().padLeft(2, '0');
  final date = '${two(d.year % 100)}${two(d.month)}${two(d.day)}';
  return 'stok-${slug.isEmpty ? 'lokasi' : slug}-$date.pdf';
}
