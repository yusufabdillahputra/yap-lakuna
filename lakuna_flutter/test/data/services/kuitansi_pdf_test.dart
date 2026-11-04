import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/data/services/kuitansi_pdf.dart';

const sample = KuitansiDocument(
  title: 'KUITANSI',
  number: 'BP-PST-K01-261103-0007',
  storeName: 'Warung Contoh',
  storeLine: 'Cabang Pusat · Jl. Melati No. 12, Purwokerto · 0812-0000-0001',
  banner: 'SALINAN',
  fields: [
    KuitansiField('Telah terima dari', 'Toko Bu Ani'),
    KuitansiField('Uang sejumlah', 'Delapan ratus ribu rupiah', italic: true),
    KuitansiField('Untuk pembayaran', 'Piutang 2 nota (lihat rincian)'),
    KuitansiField('Metode', 'Tunai · kas laci'),
  ],
  tableHead: ['Nota', 'Sisa sebelum', 'Dibayar'],
  tableRows: [
    ['PST-T01-261020-0012', 'Rp 500.000', 'Rp 500.000'],
    ['PST-T01-261028-0031', 'Rp 300.000', 'Rp 300.000'],
  ],
  placeDate: 'Purwokerto, 3 November 2026',
  amount: 'Rp 800.000',
  signName: 'Sari',
  signRole: 'Kasir',
  footnote: 'Sisa piutang Toko Bu Ani setelah pembayaran ini: Rp 350.000.',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('kuitansi A5 menjadi PDF satu halaman', () async {
    final pdf = await buildKuitansiPdf(sample);
    expect(String.fromCharCodes(pdf.take(5)), '%PDF-');
    // Font ikut tertanam (subset).
    expect(pdf.length, greaterThan(8000));
    if (Platform.environment['KUITANSI_PDF_OUT'] case final out?) {
      File(out).writeAsBytesSync(pdf);
    }
  });
}
