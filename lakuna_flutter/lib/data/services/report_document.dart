import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'spreadsheet_exporter.dart';

const _regular = 'assets/fonts/pdf/DMSans-Regular.ttf';
const _semiBold = 'assets/fonts/pdf/DMSans-SemiBold.ttf';
const _heading = 'assets/fonts/pdf/Montserrat-Bold.ttf';

/// Satu baris tabel laporan. Sel: `String`, `int`, [XlsxNumber] (rupiah),
/// atau `null`.
@immutable
class ReportRow {
  const ReportRow(this.cells, {this.strong = false, this.indent = false});

  final List<Object?> cells;

  /// Baris jumlah (tebal).
  final bool strong;

  /// Baris rincian (menjorok di PDF).
  final bool indent;
}

/// Isi satu tab laporan yang sudah diterjemahkan, untuk Excel dan PDF
/// (F1-16).
@immutable
class ReportTable {
  const ReportTable({
    required this.title,
    required this.subtitle,
    required this.headers,
    required this.rows,
    this.notes = const [],
    this.widths = const [],
    this.flex = const [],
  });

  /// Mis. `Laba rugi · Oktober 2026`.
  final String title;

  /// Mis. `Cabang Pusat · dibuat 4 November 2026`.
  final String subtitle;
  final List<String> headers;
  final List<ReportRow> rows;

  /// Catatan di bawah tabel (cara hitung, peringatan).
  final List<String> notes;

  /// Lebar kolom Excel (karakter).
  final List<int> widths;

  /// Lebar relatif kolom PDF; kosong = kolom pertama 3, lainnya 1.
  final List<int> flex;
}

/// Nama lembar Excel: maks 31 karakter, tanpa `[]:*?/\`. Judul
/// `<nama> · <periode>` yang terlalu panjang memakai `<nama>` saja (periode
/// tetap ada di baris judul lembar), bukan dipotong di tengah kata.
@visibleForTesting
String reportSheetName(String title) {
  final clean = title.replaceAll(RegExp(r'[\[\]:*?/\\]'), ' ').trim();
  if (clean.length <= 31) return clean;
  final name = clean.split(' · ').first.trim();
  return name.length <= 31 ? name : name.substring(0, 31).trim();
}

/// Kolom rata kanan di PDF: selain kolom pertama, kolom yang semua isinya
/// angka (rupiah, bilangan, qty `3 gelas`, persen `25,7%`).
@visibleForTesting
List<bool> reportRightAligned(ReportTable t) {
  final digit = RegExp(r'^[−+\-]?\d');
  bool numericCell(Object? cell) => switch (cell) {
    null => true,
    XlsxNumber() || int() => true,
    final String s => s.isEmpty || digit.hasMatch(s),
    _ => false,
  };
  bool hasValue(Object? cell) => cell != null && cell != '';
  return [
    for (var c = 0; c < t.headers.length; c++)
      c > 0 &&
          t.rows.any((r) => c < r.cells.length && hasValue(r.cells[c])) &&
          t.rows.every((r) => c >= r.cells.length || numericCell(r.cells[c])),
  ];
}

/// Berkas `.xlsx` satu lembar: judul kolom, baris, lalu judul, subjudul,
/// dan catatan di bawahnya.
Uint8List reportXlsx(ReportTable t) => buildXlsx(
  reportSheetName(t.title),
  [
    t.headers,
    for (final r in t.rows) r.cells,
    const [],
    [t.title],
    [t.subtitle],
    for (final n in t.notes) [n],
  ],
  widths: t.widths,
);

/// PDF A4 tegak: judul, subjudul, tabel, catatan. [money] memformat sel
/// [XlsxNumber] (mis. `Rp 12.500`). Kolom angka rata kanan.
Future<Uint8List> reportPdf(
  ReportTable t, {
  required String Function(int value) money,
}) async {
  final regular = pw.Font.ttf(await rootBundle.load(_regular));
  final semi = pw.Font.ttf(await rootBundle.load(_semiBold));
  final heading = pw.Font.ttf(await rootBundle.load(_heading));
  const ink = PdfColor.fromInt(0xFF18181B);
  const muted = PdfColor.fromInt(0xFF52525B);
  const rule = PdfColor.fromInt(0xFFE4E4E7);
  const band = PdfColor.fromInt(0xFFF4F4F5);
  pw.TextStyle body({pw.Font? font, double size = 9, PdfColor color = ink}) =>
      pw.TextStyle(font: font ?? regular, fontSize: size, color: color);

  String text(Object? cell) => switch (cell) {
    null => '',
    final XlsxNumber n => money(n.value),
    final int n => '$n',
    _ => '$cell',
  };
  final columns = t.headers.length;
  final align = [
    for (final right in reportRightAligned(t))
      right ? pw.TextAlign.right : pw.TextAlign.left,
  ];

  pw.Widget cell(
    String value,
    int column, {
    bool strong = false,
    bool indent = false,
    bool head = false,
  }) => pw.Padding(
    padding: pw.EdgeInsets.fromLTRB(
      column == 0 && indent ? 14 : 6,
      5,
      6,
      5,
    ),
    child: pw.Text(
      value,
      textAlign: align[column],
      style: body(
        font: strong || head ? semi : regular,
        size: head ? 8 : 9,
        color: head ? muted : ink,
      ),
    ),
  );

  final doc = pw.Document(title: t.title, creator: 'Lakuna');
  doc.addPage(
    pw.MultiPage(
      // Bawaan 20 halaman (≈ 700 baris) terlalu kecil untuk daftar stok
      // toko besar; batas ini hanya dicek di build debug.
      maxPages: 1000,
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      pageFormat: PdfPageFormat.a4.copyWith(
        marginLeft: 16 * PdfPageFormat.mm,
        marginRight: 16 * PdfPageFormat.mm,
        marginTop: 16 * PdfPageFormat.mm,
        marginBottom: 16 * PdfPageFormat.mm,
      ),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          '${context.pageNumber} / ${context.pagesCount}',
          style: body(size: 7, color: muted),
        ),
      ),
      build: (_) => [
        pw.Text(t.title, style: body(font: heading, size: 15)),
        pw.SizedBox(height: 3),
        pw.Text(t.subtitle, style: body(size: 9, color: muted)),
        pw.SizedBox(height: 12),
        pw.Table(
          columnWidths: {
            for (var c = 0; c < columns; c++)
              c: pw.FlexColumnWidth(
                c < t.flex.length ? t.flex[c].toDouble() : (c == 0 ? 3 : 1),
              ),
          },
          border: const pw.TableBorder(
            horizontalInside: pw.BorderSide(color: rule, width: 0.6),
            bottom: pw.BorderSide(color: rule, width: 0.6),
          ),
          children: [
            pw.TableRow(
              repeat: true,
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: ink)),
              ),
              children: [
                for (var c = 0; c < columns; c++)
                  cell(t.headers[c], c, head: true),
              ],
            ),
            for (final r in t.rows)
              pw.TableRow(
                decoration: r.strong
                    ? const pw.BoxDecoration(color: band)
                    : null,
                children: [
                  for (var c = 0; c < columns; c++)
                    cell(
                      text(c < r.cells.length ? r.cells[c] : null),
                      c,
                      strong: r.strong,
                      indent: r.indent,
                    ),
                ],
              ),
          ],
        ),
        if (t.notes.isNotEmpty) pw.SizedBox(height: 12),
        for (final n in t.notes)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 3),
            child: pw.Text(n, style: body(size: 8, color: muted)),
          ),
      ],
    ),
  );
  return doc.save();
}
