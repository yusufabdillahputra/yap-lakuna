import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/data/services/report_document.dart';

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
}
