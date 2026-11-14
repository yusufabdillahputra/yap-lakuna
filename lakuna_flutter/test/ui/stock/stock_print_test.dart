import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/report_document.dart';
import 'package:lakuna_flutter/data/services/spreadsheet_exporter.dart';
import 'package:lakuna_flutter/l10n/gen/app_localizations.dart';
import 'package:lakuna_flutter/ui/stock/stock_print.dart';

import '../../testing/fake_stock_repository.dart';

void main() {
  final id = lookupAppLocalizations(const Locale('id'));
  final en = lookupAppLocalizations(const Locale('en'));
  // 02.30 UTC = 09.30 WIB.
  final at = DateTime.utc(2026, 11, 14, 2, 30);

  List<Object?> cells(ReportRow r) => r.cells;

  test('tabel cetak stok: kolom, minimum kosong, total, catatan (F1-08b)', () {
    final rows = [
      ...sampleStockRows(),
      sampleRow(4, 'Gas 3 kg', unit: 'tabung', stock: Qty.units(-2)),
    ];
    final t = stockPrintTable(
      id,
      rows: rows,
      location: 'Etalase',
      outlet: 'Cabang Pusat',
      staff: 'Yusuf',
      printedAt: at,
      timezone: 'Asia/Jakarta',
    );
    expect(t.title, 'Daftar stok · Etalase');
    expect(t.subtitle, 'Cabang Pusat · dicetak 14 November 2026 09.30 · Yusuf');
    expect(t.headers, [
      'Produk',
      'SKU / Barcode',
      'Stok',
      'Minimum',
      'Nilai (HPP)',
      'Fisik',
    ]);
    expect(t.rows, hasLength(5));
    expect(cells(t.rows[0]), [
      'Kopi Sachet',
      '8990001',
      '2 sachet',
      '20',
      const XlsxNumber(3000),
      '',
    ]);
    // Minimum tidak diisi → kosong; stok desimal memakai koma.
    expect(cells(t.rows[1])[3], '');
    expect(cells(t.rows[2])[2], '12,5 kg');
    // Stok minus tercetak minus, nilainya 0.
    expect(cells(t.rows[3])[2], '-2 tabung');
    expect(cells(t.rows[3])[4], const XlsxNumber(0));
    final total = t.rows.last;
    expect(total.strong, isTrue);
    expect(cells(total)[0], 'Total');
    expect(cells(total)[4], const XlsxNumber(3000 + 270000 + 318750));
    expect(t.notes, [
      '4 item · 2 di bawah minimum · 1 stok minus',
      'Tulis hasil hitung di kolom Fisik, lalu catat selisihnya di menu '
          'Stok, tab Penyesuaian.',
    ]);
  });

  test('bahasa Inggris dan nama berkas', () {
    final t = stockPrintTable(
      en,
      rows: sampleStockRows(),
      location: 'Gudang Belakang',
      outlet: 'Cabang Pusat',
      staff: 'Yusuf',
      printedAt: at,
      timezone: 'Asia/Jakarta',
    );
    expect(t.title, 'Stock list · Gudang Belakang');
    expect(t.notes.first, '3 items · 2 below minimum · 0 negative stock');
    final one = stockPrintTable(
      en,
      rows: sampleStockRows().take(1).toList(),
      location: 'Etalase',
      outlet: 'Cabang Pusat',
      staff: 'Yusuf',
      printedAt: at,
    );
    expect(one.notes.first, '1 item · 1 below minimum · 0 negative stock');
    expect(t.headers.last, 'Counted');
    expect(cells(t.rows[2])[2], '12.5 kg');
    expect(
      stockPrintFileName('Gudang Belakang #2', at, 'Asia/Jakarta'),
      'stok-gudang-belakang-2-261114-0930.pdf',
    );
    expect(
      stockPrintFileName('***', at, 'Asia/Jakarta'),
      'stok-lokasi-261114-0930.pdf',
    );
  });

  test('PDF lebih dari 20 halaman tetap dibuat (800 baris)', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final rows = [
      for (var i = 0; i < 800; i++)
        sampleRow(i, 'Barang $i', unit: 'pcs', stock: Qty.units(i)),
    ];
    final pdf = await reportPdf(
      stockPrintTable(
        id,
        rows: rows,
        location: 'Gudang',
        outlet: 'Cabang Pusat',
        staff: 'Yusuf',
        printedAt: at,
      ),
      money: (v) => 'Rp $v',
    );
    expect(String.fromCharCodes(pdf.take(4)), '%PDF');
  });
}
