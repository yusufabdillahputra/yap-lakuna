import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  test('nomor nota memuat outlet, perangkat, tanggal, urutan', () {
    expect(
      receiptNumber('jkt1', 'k02', DateTime(2026, 11, 2), 7),
      'JKT1-K02-261102-0007',
    );
  });

  test('nomor dokumen lain memakai prefix', () {
    expect(
      documentNumber('sa', 'pst', 'k01', DateTime(2026, 11, 2), 1),
      'SA-PST-K01-261102-0001',
    );
  });

  test('penghitung harian direset saat tanggal berganti', () {
    final c = DailyCounter(date: DateTime(2026, 11, 2), last: 41);
    expect(c.next(DateTime(2026, 11, 2, 23, 59)), 42);
    expect(c.next(DateTime(2026, 11, 3)), 1);
    expect(c.last, 1);
  });
}
