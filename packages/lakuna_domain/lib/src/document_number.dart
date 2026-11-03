/// Nomor nota unik per perangkat: `OUTLET-DEVICE-YYMMDD-0001`. Karena kode
/// perangkat ikut di nomor, dua perangkat offline tidak pernah menghasilkan
/// nomor yang sama.
String receiptNumber(
  String outletCode,
  String deviceCode,
  DateTime localDate,
  int counter,
) =>
    '${outletCode.toUpperCase()}-${deviceCode.toUpperCase()}-'
    '${_yymmdd(localDate)}-${counter.toString().padLeft(4, '0')}';

/// Nomor dokumen selain nota: `PREFIX-OUTLET-DEVICE-YYMMDD-0001`, mis.
/// penyesuaian stok `SA-PST-K01-261102-0001`.
String documentNumber(
  String prefix,
  String outletCode,
  String deviceCode,
  DateTime localDate,
  int counter,
) =>
    '${prefix.toUpperCase()}-'
    '${receiptNumber(outletCode, deviceCode, localDate, counter)}';

String _yymmdd(DateTime d) =>
    '${(d.year % 100).toString().padLeft(2, '0')}'
    '${d.month.toString().padLeft(2, '0')}'
    '${d.day.toString().padLeft(2, '0')}';

/// Penghitung dokumen per perangkat, direset setiap hari (tanggal lokal
/// outlet).
class DailyCounter {
  DailyCounter({required DateTime date, this.last = 0})
      : date = DateTime(date.year, date.month, date.day);

  DateTime date;
  int last;

  /// Nomor berikutnya untuk [now]; mulai dari 1 lagi bila hari berganti.
  int next(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    if (today != date) {
      date = today;
      last = 0;
    }
    return ++last;
  }
}
