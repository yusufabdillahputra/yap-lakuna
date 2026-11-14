import 'package:characters/characters.dart';

import 'money.dart';
import 'qty.dart';

/// Batas panjang field stok (F1-08).
abstract final class StockLimits {
  /// Nama lokasi stok (Etalase, Gudang).
  static const locationName = 40;

  /// Alasan per baris penyesuaian.
  static const lineNote = 60;

  /// Catatan dokumen penyesuaian.
  static const note = 200;
}

/// Selisih penyesuaian: fisik − sistem (negatif = barang berkurang).
Qty stockDifference({required Qty system, required Qty physical}) =>
    physical - system;

/// HPP per satuan dasar untuk menilai selisih: rata-rata bila ada, harga
/// modal varian bila rata-rata masih 0.
Money adjustmentUnitCost({required Money avgCost, required Money costPrice}) =>
    avgCost == Money.zero ? costPrice : avgCost;

/// Nilai selisih (bertanda) = selisih × HPP per satuan dasar.
Money adjustmentValue(Qty difference, Money unitCost) =>
    unitCost.timesMilli(difference.milli);

enum StockLocationNameError { empty, tooLong, duplicate }

/// Validasi nama lokasi terhadap nama lokasi lain di cabang yang sama
/// ([existing], tanpa lokasi yang sedang diganti namanya).
StockLocationNameError? validateLocationName(
  String name, {
  required Iterable<String> existing,
}) {
  final t = name.trim();
  if (t.isEmpty) return StockLocationNameError.empty;
  if (t.characters.length > StockLimits.locationName) {
    return StockLocationNameError.tooLong;
  }
  final key = t.toLowerCase();
  if (existing.any((e) => e.trim().toLowerCase() == key)) {
    return StockLocationNameError.duplicate;
  }
  return null;
}

/// Panjang teks dalam karakter yang terlihat (emoji = 1), sama dengan
/// penghitung `maxLength` di field teks.
int textLength(String text) => text.characters.length;

/// Jumlah saran beli ulang dari daftar stok minimum (F1-08c):
/// `2 × minimum − stok` (stok minus dihitung 0), dibulatkan ke atas ke
/// satuan utuh, minimal satu satuan.
Qty restockQuantity(Qty stock, Qty minimum) {
  final have = stock.milli < 0 ? 0 : stock.milli;
  final need = minimum.milli * 2 - have;
  final units = need <= 0 ? 1 : (need + 999) ~/ 1000;
  return Qty.units(units < 1 ? 1 : units);
}

/// Supplier untuk draf pembelian dari stok minimum (F1-08d): dari supplier
/// terakhir tiap barang ([last], satu entri per barang yang punya riwayat),
/// yang memasok paling banyak barang; seri = pembelian paling baru.
/// `null` bila tidak ada riwayat.
({K supplier, int count})? chooseRestockSupplier<K>(
  Iterable<({K supplier, DateTime at})> last,
) {
  final counts = <K, int>{};
  final latest = <K, DateTime>{};
  for (final e in last) {
    counts[e.supplier] = (counts[e.supplier] ?? 0) + 1;
    final at = latest[e.supplier];
    if (at == null || e.at.isAfter(at)) latest[e.supplier] = e.at;
  }
  K? best;
  for (final k in counts.keys) {
    if (best == null) {
      best = k;
      continue;
    }
    final c = counts[k]!.compareTo(counts[best]!);
    if (c > 0 || (c == 0 && latest[k]!.isAfter(latest[best]!))) best = k;
  }
  return best == null ? null : (supplier: best, count: counts[best]!);
}

/// Harga beli per satuan dasar (F1-08e): harga satuan baris dibagi isi
/// satuan [factor], dibulatkan ke rupiah terdekat (setengah menjauhi nol). Isi
/// tidak sah (≤ 0) mengembalikan harga apa adanya.
Money perBaseUnitPrice(Money unitPrice, Qty factor) {
  if (factor.milli <= 0) return unitPrice;
  final scaled = unitPrice.value * 1000;
  final half = factor.milli ~/ 2;
  final q = scaled >= 0
      ? (scaled + half) ~/ factor.milli
      : -((-scaled + half) ~/ factor.milli);
  return Money(q);
}
