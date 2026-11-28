import 'money.dart';
import 'qty.dart';
import 'report.dart' show topProducts;
import 'setup.dart';

/// Penjualan satu cabang hari ini untuk dashboard semua cabang 2.3
/// (F2-02 tahap 3).
class OutletDay {
  const OutletDay({
    required this.outletId,
    required this.sales,
    required this.transactions,
    required this.hourly,
  });

  final String outletId;

  /// Penjualan bersih (setelah void dan retur), sama dengan Laporan.
  final Money sales;
  final int transactions;

  /// 24 nilai penjualan per jam dinding cabang (indeks 0 = 00.00–00.59).
  final List<Money> hourly;
}

/// Rata-rata per nota, dibulatkan ke bawah; 0 bila belum ada nota.
Money averagePerReceipt(Money sales, int transactions) =>
    transactions <= 0 ? Money.zero : Money(sales.value ~/ transactions);

/// Jam pertama dan terakhir yang bertransaksi di [hourly], diperluas agar
/// grafik minimal menampilkan 08–17.
({int from, int to}) hourAxis(List<Money> hourly) {
  var from = 8;
  var to = 17;
  for (var h = 0; h < hourly.length; h++) {
    if (hourly[h] == Money.zero) continue;
    if (h < from) from = h;
    if (h > to) to = h;
  }
  return (from: from, to: to);
}

enum DeviceLiveness { online, offline }

/// Perangkat dianggap online bila terakhir terlihat server ≤ 10 menit lalu.
DeviceLiveness deviceLiveness(DateTime? lastSeen, DateTime now) =>
    lastSeen != null && now.difference(lastSeen) <= const Duration(minutes: 10)
    ? DeviceLiveness.online
    : DeviceLiveness.offline;

/// Perangkat masuk *Perlu perhatian* bila belum sync > 1 jam atau belum
/// pernah sync.
bool deviceStale(DateTime? lastSeen, DateTime now) =>
    lastSeen == null || now.difference(lastSeen) > const Duration(hours: 1);

/// Produk terlaris dashboard (beda dengan [topProducts] Laporan yang per
/// varian): baris varian digabung per produk, urut jumlah turun lalu
/// nama, dipotong [limit].
List<({String productId, String name, Qty sold})> topSellingProducts(
  List<({String productId, String name, Qty qty})> lines, {
  int limit = 5,
}) {
  final sold = <String, ({String productId, String name, Qty sold})>{};
  for (final l in lines) {
    final prev = sold[l.productId];
    sold[l.productId] = (
      productId: l.productId,
      name: prev?.name ?? l.name,
      sold: (prev?.sold ?? Qty.zero) + l.qty,
    );
  }
  final list = sold.values.toList()
    ..sort((a, b) {
      final byQty = b.sold.milli.compareTo(a.sold.milli);
      return byQty != 0 ? byQty : a.name.compareTo(b.name);
    });
  return list.take(limit).toList();
}

/// Awal hari ini (00.00 jam dinding cabang di [timezone]) sebagai waktu
/// UTC; zona tak dikenal memakai zona perangkat, sama dengan Laporan.
DateTime outletDayStart(DateTime nowUtc, String? timezone) {
  final zone = setupTimezones.where((z) => z.id == timezone).firstOrNull;
  if (zone == null) {
    final l = nowUtc.toLocal();
    return DateTime(l.year, l.month, l.day).toUtc();
  }
  final l = outletLocalTime(nowUtc, timezone);
  return DateTime.utc(
    l.year,
    l.month,
    l.day,
  ).subtract(Duration(hours: zone.utcOffsetHours));
}
