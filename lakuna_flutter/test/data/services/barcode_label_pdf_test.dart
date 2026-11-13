import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/barcode_label_pdf.dart';

const _kopi = BarcodeLabel(
  title: 'Kopi Sachet Susu Gula Aren Ekstra Panjang Sekali Namanya',
  price: 'Rp 2.000',
  code: '8990001000012',
  symbology: BarcodeSymbology.ean13,
);
const _gula = BarcodeLabel(
  title: 'Gula Pasir · dus',
  code: 'GUL-1KG',
  symbology: BarcodeSymbology.code128,
);

Future<int> _pages(BarcodeLabelSheet sheet) async {
  final doc = await barcodeLabelPdfDocument(sheet);
  await doc.save();
  return doc.document.pdfPageList.pages.length;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('A4 24 label per halaman; 25 label → 2 halaman', () async {
    final sheet = BarcodeLabelSheet(
      paper: BarcodeLabelPaper.a4Sheet,
      labels: [for (var i = 0; i < 25; i++) i.isEven ? _kopi : _gula],
    );
    expect(await _pages(sheet), 2);
    final pdf = await buildBarcodeLabelPdf(sheet);
    expect(String.fromCharCodes(pdf.take(5)), '%PDF-');
    if (Platform.environment['LABEL_PDF_OUT'] case final out?) {
      File(out).writeAsBytesSync(pdf);
    }
  });

  test('A4 melewati label yang sudah terpakai', () async {
    expect(
      await _pages(
        const BarcodeLabelSheet(
          paper: BarcodeLabelPaper.a4Sheet,
          labels: [_kopi],
          skip: 23,
        ),
      ),
      1,
    );
    expect(
      await _pages(
        const BarcodeLabelSheet(
          paper: BarcodeLabelPaper.a4Sheet,
          labels: [_kopi, _gula],
          skip: 23,
        ),
      ),
      2,
    );
  });

  test('printer label: satu label per halaman, semua ukuran', () async {
    for (final paper in [
      BarcodeLabelPaper.roll50x30,
      BarcodeLabelPaper.roll38x25,
    ]) {
      expect(
        await _pages(
          BarcodeLabelSheet(
            paper: paper,
            labels: const [_kopi, _gula, _kopi],
            skip: 5,
          ),
        ),
        3,
        reason: paper.name,
      );
    }
  });

  test('EAN-8 dan UPC-A ikut tercetak', () async {
    expect(
      await _pages(
        const BarcodeLabelSheet(
          paper: BarcodeLabelPaper.roll50x30,
          labels: [
            BarcodeLabel(
              title: 'Permen',
              code: '96385074',
              symbology: BarcodeSymbology.ean8,
            ),
            BarcodeLabel(
              title: 'Impor',
              code: '036000291452',
              symbology: BarcodeSymbology.upcA,
            ),
          ],
        ),
      ),
      2,
    );
  });
}
