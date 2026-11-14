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
