import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const _regular = 'assets/fonts/pdf/DMSans-Regular.ttf';
const _semiBold = 'assets/fonts/pdf/DMSans-SemiBold.ttf';
const _heading = 'assets/fonts/pdf/Montserrat-Bold.ttf';

/// Kertas label barcode (F1-07e).
enum BarcodeLabelPaper {
  /// Kertas stiker A4, grid penuh 3 × 8 (70 × 37,125 mm) tanpa margin.
  a4Sheet,

  /// Printer label, satu label 50 × 30 mm per halaman.
  roll50x30,

  /// Printer label, satu label 38 × 25 mm per halaman.
  roll38x25;

  /// Ukuran halaman PDF (dan kertas di dialog cetak).
  PdfPageFormat get pageFormat => switch (this) {
    a4Sheet => PdfPageFormat.a4,
    roll50x30 => const PdfPageFormat(
      50 * PdfPageFormat.mm,
      30 * PdfPageFormat.mm,
    ),
    roll38x25 => const PdfPageFormat(
      38 * PdfPageFormat.mm,
      25 * PdfPageFormat.mm,
    ),
  };

  /// Lebar satu label (mm).
  double get labelWidthMm => switch (this) {
    a4Sheet => 210 / sheetColumns,
    roll50x30 => 50,
    roll38x25 => 38,
  };

  /// Lebar area barcode di label: lebar label dikurangi padding dan zona
  /// tenang kiri-kanan (mm), dipakai peringatan kode terlalu panjang
  /// (F1-07i).
  double get barcodeWidthMm {
    final scale = _scale(this);
    return labelWidthMm - 2 * (scale.pad + scale.quiet);
  }

  /// Label per lembar A4.
  static const sheetColumns = 3;
  static const sheetRows = 8;
  static const perSheet = sheetColumns * sheetRows;
}

/// Satu label: nama, harga (opsional), dan kode.
@immutable
class BarcodeLabel {
  const BarcodeLabel({
    required this.title,
    required this.code,
    required this.symbology,
    this.price,
  });

  final String title;

  /// `Rp 36.000`; `null` = harga tidak dicetak.
  final String? price;
  final String code;
  final BarcodeSymbology symbology;
}

/// Isi satu cetakan: label sudah diulang sesuai jumlahnya.
@immutable
class BarcodeLabelSheet {
  const BarcodeLabelSheet({
    required this.paper,
    required this.labels,
    this.skip = 0,
  });

  final BarcodeLabelPaper paper;
  final List<BarcodeLabel> labels;

  /// Label pertama di lembar A4 yang dilewati (sudah terpakai); diabaikan
  /// untuk printer label.
  final int skip;
}

/// PDF label barcode.
Future<Uint8List> buildBarcodeLabelPdf(BarcodeLabelSheet sheet) async =>
    (await barcodeLabelPdfDocument(sheet)).save();

pw.Barcode _barcode(BarcodeSymbology s) => switch (s) {
  BarcodeSymbology.ean13 => pw.Barcode.ean13(),
  BarcodeSymbology.ean8 => pw.Barcode.ean8(),
  BarcodeSymbology.upcA => pw.Barcode.upcA(),
  BarcodeSymbology.code128 => pw.Barcode.code128(),
};

/// Jumlah modul (garis tersempit) [code] seperti yang digambar paket
/// barcode, tanpa zona tenang (F1-07i). Code 128 memakai set C untuk deret
/// angka, jadi dihitung dari hasil gambar, bukan dari panjang kode. Kode
/// yang tidak bisa digambar menghasilkan 0.
int barcodeModules(String code, BarcodeSymbology symbology) {
  const width = 1000.0;
  try {
    final bars = _barcode(symbology)
        .make(code, width: width, height: 10, drawText: false)
        .whereType<pw.BarcodeBar>();
    final narrowest = bars.map((b) => b.width).reduce(math.min);
    return (width / narrowest).round();
  } on pw.BarcodeException {
    return 0;
  } on StateError {
    // Tidak ada garis sama sekali.
    return 0;
  }
}

/// `true` bila garis barcode [code] lebih tipis dari batas aman di
/// [paper] (F1-07i).
bool barcodeTooDenseOn(
  BarcodeLabelPaper paper,
  String code,
  BarcodeSymbology symbology,
) => barcodeTooDense(barcodeModules(code, symbology), paper.barcodeWidthMm);

/// Ukuran huruf per kertas: nama, harga, teks barcode; padding label dan
/// zona tenang kiri-kanan barcode (mm).
typedef _Scale = ({
  double title,
  double price,
  double code,
  double pad,
  double quiet,
});

_Scale _scale(BarcodeLabelPaper paper) => switch (paper) {
  BarcodeLabelPaper.a4Sheet => (
    title: 8,
    price: 11,
    code: 7,
    pad: 3,
    quiet: 3,
  ),
  BarcodeLabelPaper.roll50x30 => (
    title: 7,
    price: 9.5,
    code: 6.5,
    pad: 2,
    quiet: 2,
  ),
  BarcodeLabelPaper.roll38x25 => (
    title: 6,
    price: 8,
    code: 5.5,
    pad: 1.5,
    quiet: 1.5,
  ),
};

/// Dokumen PDF label.
Future<pw.Document> barcodeLabelPdfDocument(BarcodeLabelSheet sheet) async {
  final regular = pw.Font.ttf(await rootBundle.load(_regular));
  final semi = pw.Font.ttf(await rootBundle.load(_semiBold));
  final heading = pw.Font.ttf(await rootBundle.load(_heading));
  const ink = PdfColor.fromInt(0xFF18181B);
  final scale = _scale(sheet.paper);

  pw.Widget label(BarcodeLabel l) => pw.Padding(
    padding: pw.EdgeInsets.all(scale.pad * PdfPageFormat.mm),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          l.title,
          maxLines: 2,
          style: pw.TextStyle(font: semi, fontSize: scale.title, color: ink),
        ),
        if (l.price case final price?)
          pw.Text(
            price,
            style: pw.TextStyle(
              font: heading,
              fontSize: scale.price,
              color: ink,
            ),
          ),
        pw.SizedBox(height: 1),
        pw.Expanded(
          child: pw.Padding(
            padding: pw.EdgeInsets.symmetric(
              horizontal: scale.quiet * PdfPageFormat.mm,
            ),
            child: pw.BarcodeWidget(
              barcode: _barcode(l.symbology),
              data: l.code,
              color: PdfColors.black,
              textPadding: 1,
              textStyle: pw.TextStyle(font: regular, fontSize: scale.code),
            ),
          ),
        ),
      ],
    ),
  );

  final doc = pw.Document(title: 'Label barcode', creator: 'Lakuna');
  switch (sheet.paper) {
    case BarcodeLabelPaper.a4Sheet:
      const perSheet = BarcodeLabelPaper.perSheet;
      final skip = sheet.skip.clamp(0, perSheet - 1);
      final slots = <BarcodeLabel?>[
        for (var i = 0; i < skip; i++) null,
        ...sheet.labels,
      ];
      const cellWidth = 210 / BarcodeLabelPaper.sheetColumns;
      const cellHeight = 297 / BarcodeLabelPaper.sheetRows;
      for (var start = 0; start < slots.length; start += perSheet) {
        final page = slots.skip(start).take(perSheet).toList();
        doc.addPage(
          pw.Page(
            pageFormat: sheet.paper.pageFormat.copyWith(
              marginLeft: 0,
              marginRight: 0,
              marginTop: 0,
              marginBottom: 0,
            ),
            build: (_) => pw.Column(
              children: [
                for (var r = 0; r < BarcodeLabelPaper.sheetRows; r++)
                  pw.Row(
                    children: [
                      for (var c = 0; c < BarcodeLabelPaper.sheetColumns; c++)
                        pw.SizedBox(
                          width: cellWidth * PdfPageFormat.mm,
                          height: cellHeight * PdfPageFormat.mm,
                          child: switch (page.elementAtOrNull(
                            r * BarcodeLabelPaper.sheetColumns + c,
                          )) {
                            final l? => label(l),
                            null => pw.SizedBox(),
                          },
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      }
    case BarcodeLabelPaper.roll50x30 || BarcodeLabelPaper.roll38x25:
      final format = sheet.paper.pageFormat;
      for (final l in sheet.labels) {
        doc.addPage(pw.Page(pageFormat: format, build: (_) => label(l)));
      }
  }
  return doc;
}
