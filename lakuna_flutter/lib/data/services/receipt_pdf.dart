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

/// Ukuran halaman gulungan setinggi [lineCount] baris, ditambah
/// [extraPt] (mis. logo).
PdfPageFormat receiptPageFormat(
  ReceiptPaper paper,
  int lineCount, {
  double extraPt = 0,
}) {
  final margin = _margin(paper);
  return PdfPageFormat(
    _paperMm(paper) * PdfPageFormat.mm,
    lineCount * receiptLineHeightPt(paper) +
        extraPt +
        margin * 2 +
        _heightSlackPt,
    marginAll: margin,
  );
}

/// Jarak logo ke baris pertama (pt).
const _logoGapPt = 2 * PdfPageFormat.mm;

/// Ukuran logo di PDF (pt): lebar maks 60 % area cetak, tinggi maks 20 mm,
/// rasio asli; `null` bila [logo] bukan gambar yang dikenali.
({double width, double height})? receiptPdfLogoSize(
  Uint8List? logo,
  ReceiptPaper paper,
) {
  if (logo == null) return null;
  final header = readImageHeader(logo);
  if (header == null || header.width <= 0 || header.height <= 0) return null;
  final maxWidth = receiptPrintableMm(paper) * PdfPageFormat.mm * 0.6;
  const maxHeight = 20 * PdfPageFormat.mm;
  var width = maxWidth;
  var height = width * header.height / header.width;
  if (height > maxHeight) {
    height = maxHeight;
    width = height * header.width / header.height;
  }
  return (width: width, height: height);
}

/// Tinggi tambahan halaman untuk logo (pt), 0 tanpa logo.
double receiptPdfLogoExtra(Uint8List? logo, ReceiptPaper paper) {
  final size = receiptPdfLogoSize(logo, paper);
  return size == null ? 0 : size.height + _logoGapPt;
}

/// PDF struk dari [lines] (baris yang sama dengan layar dan ESC/POS), dengan
/// [logo] di tengah atas bila ada (F1-06b). Logo yang gagal didekode
/// (header sah tetapi isi rusak) dilewati: struk tetap jadi tanpa logo.
Future<Uint8List> buildReceiptPdf(
  List<ReceiptLine> lines,
  ReceiptPaper paper, {
  Uint8List? logo,
}) async {
  if (logo != null) {
    try {
      return await _buildReceiptPdf(lines, paper, logo);
    } on Object {
      // Dekode gambar terjadi saat `save`; ulangi tanpa logo.
    }
  }
  return _buildReceiptPdf(lines, paper, null);
}

Future<Uint8List> _buildReceiptPdf(
  List<ReceiptLine> lines,
  ReceiptPaper paper,
  Uint8List? logo,
) async {
  final regular = pw.Font.ttf(await rootBundle.load(_regular));
  final medium = pw.Font.ttf(await rootBundle.load(_medium));
  final size = _fontSize(paper);
  var logoSize = receiptPdfLogoSize(logo, paper);
  pw.MemoryImage? image;
  if (logoSize != null) {
    try {
      image = pw.MemoryImage(logo!);
    } on Object {
      // Gambar rusak: struk tetap dicetak tanpa logo.
      logoSize = null;
    }
  }
  final doc = pw.Document(title: 'Struk', creator: 'Lakuna');
  doc.addPage(
    pw.Page(
      pageFormat: receiptPageFormat(
        paper,
        lines.length,
        extraPt: logoSize == null ? 0 : logoSize.height + _logoGapPt,
      ),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          if (logoSize != null && image != null)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: _logoGapPt),
              child: pw.Center(
                child: pw.Image(
                  image,
                  width: logoSize.width,
                  height: logoSize.height,
                ),
              ),
            ),
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
  return await doc.save();
}
