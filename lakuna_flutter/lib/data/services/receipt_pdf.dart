import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const _regular = 'assets/fonts/DM_Mono/DMMono-Regular.ttf';
const _medium = 'assets/fonts/DM_Mono/DMMono-Medium.ttf';

/// Lebar area cetak (mm) per kertas: 58 mm → 48 mm, 80 mm → 72 mm.
double receiptPrintableMm(ReceiptPaper paper) => switch (paper) {
  ReceiptPaper.mm58 => 48,
  ReceiptPaper.mm80 => 72,
};

double _paperMm(ReceiptPaper paper) => switch (paper) {
  ReceiptPaper.mm58 => 58,
  ReceiptPaper.mm80 => 80,
};

/// Lebar satu karakter DM Mono = 0,6 em.
const receiptCharEm = 0.6;

/// Tinggi baris = 1,35 × ukuran font.
const receiptLineHeight = 1.35;

double _fontSize(ReceiptPaper paper) =>
    receiptPrintableMm(paper) *
    PdfPageFormat.mm /
    (paper.columns * receiptCharEm);

/// Tinggi satu baris struk di PDF (pt).
double receiptLineHeightPt(ReceiptPaper paper) =>
    _fontSize(paper) * receiptLineHeight;

double _margin(ReceiptPaper paper) =>
    (_paperMm(paper) - receiptPrintableMm(paper)) / 2 * PdfPageFormat.mm;

/// Kelonggaran tinggi halaman (pt). Tanpa ini, galat pembulatan bisa
/// membuat kolom sedikit lebih tinggi dari halaman dan paket `pdf`
/// membuang baris terakhir (footer).
const _heightSlackPt = 2.0;

/// Ukuran halaman gulungan setinggi [lineCount] baris.
PdfPageFormat receiptPageFormat(ReceiptPaper paper, int lineCount) {
  final margin = _margin(paper);
  return PdfPageFormat(
    _paperMm(paper) * PdfPageFormat.mm,
    lineCount * receiptLineHeightPt(paper) + margin * 2 + _heightSlackPt,
    marginAll: margin,
  );
}

/// PDF struk dari [lines] (baris yang sama dengan layar dan ESC/POS).
Future<Uint8List> buildReceiptPdf(
  List<ReceiptLine> lines,
  ReceiptPaper paper,
) async {
  final regular = pw.Font.ttf(await rootBundle.load(_regular));
  final medium = pw.Font.ttf(await rootBundle.load(_medium));
  final size = _fontSize(paper);
  final doc = pw.Document(title: 'Struk', creator: 'Lakuna');
  doc.addPage(
    pw.Page(
      pageFormat: receiptPageFormat(paper, lines.length),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          for (final line in lines)
            pw.SizedBox(
              height: receiptLineHeightPt(paper),
              child: pw.Text(
                line.text,
                textAlign: switch (line.align) {
                  ReceiptAlign.left => pw.TextAlign.left,
                  ReceiptAlign.center => pw.TextAlign.center,
                  ReceiptAlign.right => pw.TextAlign.right,
                },
                style: pw.TextStyle(
                  font: line.bold ? medium : regular,
                  fontSize: size,
                ),
              ),
            ),
        ],
      ),
    ),
  );
  return doc.save();
}
