import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/data/services/report_document.dart';
import 'package:lakuna_flutter/data/services/spreadsheet_exporter.dart';

import '../../testing/main_isolate_stall.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<String> mediaBox({required bool landscape}) async {
    final pdf = await reportPdf(
      ReportTable(
        title: 'Piutang & hutang',
        subtitle: 'Cabang Pusat',
        headers: const ['Keterangan', 'Sisa'],
        rows: const [
          ReportRow(['Budi', 'Rp 150.000']),
        ],
        landscape: landscape,
      ),
      money: (v) => 'Rp $v',
    );
    final text = String.fromCharCodes(pdf);
    return RegExp(r'/MediaBox\s*\[([^\]]*)\]').firstMatch(text)![1]!.trim();
  }

  test('tabel berkolom banyak dicetak mendatar (F1-16g)', () async {
    final portrait = (await mediaBox(landscape: false)).split(RegExp(r'\s+'));
    final wide = (await mediaBox(landscape: true)).split(RegExp(r'\s+'));
    double w(List<String> box) => double.parse(box[2]);
    double h(List<String> box) => double.parse(box[3]);
    expect(w(portrait), lessThan(h(portrait)));
    expect(w(wide), greaterThan(h(wide)));
  });

  test('PDF ribuan baris dibuat di isolate terpisah (F1-19f)', () async {
    final table = ReportTable(
      title: 'Stok',
      subtitle: 'Gudang',
      headers: const ['Barang', 'Stok', 'Nilai'],
      rows: [
        for (var i = 0; i < 3000; i++)
          ReportRow(['Barang nomor $i', '$i pcs', XlsxNumber(i * 1000)]),
      ],
    );
    final run = await measureMainIsolateStall(
      () => reportPdf(table, money: (v) => 'Rp $v'),
    );
    expect(String.fromCharCodes(run.result.take(4)), '%PDF');
    // Rupiah diformat di isolate utama lalu ikut ke PDF.
    expect(run.elapsed, greaterThan(const Duration(milliseconds: 200)));
    expect(
      run.longestStall,
      lessThan(run.elapsed * 0.5),
      reason: 'layar tidak boleh membeku selama PDF dibuat',
    );
  });
}
