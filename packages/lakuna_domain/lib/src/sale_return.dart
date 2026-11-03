import 'document_number.dart';
import 'money.dart';
import 'split_bill.dart';

/// Batas retur penjualan (F1-11).
abstract final class ReturnLimits {
  /// Catatan retur / alasan void, karakter.
  static const note = 200;
}

/// Alasan retur (salinan domain dari enum server `SaleReturnReason`).
enum ReturnReasonKind { damaged, wrongItem, expired, other }

/// Status retur sebuah nota.
enum ReturnState { none, partial, full }

enum ReturnNoteError { missing, tooLong }

/// Bagian total nota (termasuk service, PB1, potongan grosir) untuk tiap
/// baris, proporsional terhadap `line_total`, sisa terbesar. Jumlahnya selalu
/// sama dengan [total]. Bila semua baris bernilai nol, total dibagi rata.
List<Money> lineShares(Money total, List<int> lineTotals) {
  final weights = [for (final t in lineTotals) t < 0 ? 0 : t];
  return allocateByWeight(
    total,
    weights.every((w) => w == 0) ? [for (final _ in weights) 1] : weights,
  );
}

/// Nilai retur [returningMilli] dari baris berbagian [share] yang terjual
/// [soldMilli] dan sudah diretur [returnedMilli]. Nilai kumulatif dibulatkan
/// ke bawah; retur yang menghabiskan baris mengambil sisanya, sehingga semua
/// retur baris berjumlah tepat [share].
Money returnAmount({
  required Money share,
  required int soldMilli,
  required int returnedMilli,
  required int returningMilli,
}) {
  if (returningMilli <= 0 ||
      returnedMilli < 0 ||
      returnedMilli + returningMilli > soldMilli) {
    throw ArgumentError.value(returningMilli, 'returningMilli');
  }
  int cumulative(int qty) => qty == soldMilli
      ? share.value
      : (BigInt.from(share.value) * BigInt.from(qty) ~/ BigInt.from(soldMilli))
            .toInt();
  return Money(
    cumulative(returnedMilli + returningMilli) - cumulative(returnedMilli),
  );
}

/// Status retur dari jumlah terjual dan sudah diretur per baris.
ReturnState returnState({
  required List<int> sold,
  required List<int> returned,
}) {
  var any = false;
  var all = true;
  for (var i = 0; i < sold.length; i++) {
    final r = i < returned.length ? returned[i] : 0;
    if (r > 0) any = true;
    if (r < sold[i]) all = false;
  }
  if (!any) return ReturnState.none;
  return all ? ReturnState.full : ReturnState.partial;
}

/// `RT-PST-K01-261103-0001`.
String saleReturnNumber(
  String outletCode,
  String deviceCode,
  DateTime localDate,
  int counter,
) => documentNumber('RT', outletCode, deviceCode, localDate, counter);

/// Catatan retur: wajib untuk alasan *Lainnya*, maks [ReturnLimits.note].
ReturnNoteError? validateReturnNote({required bool other, String? note}) {
  final text = note?.trim() ?? '';
  if (other && text.isEmpty) return ReturnNoteError.missing;
  if (text.length > ReturnLimits.note) return ReturnNoteError.tooLong;
  return null;
}

/// Barang rusak / kedaluwarsa bawaannya tidak kembali ke stok.
bool restockByDefault(ReturnReasonKind reason) =>
    reason != ReturnReasonKind.damaged && reason != ReturnReasonKind.expired;
