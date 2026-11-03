/// Aturan meja F&B dan open bill (F1-10).
library;

import 'package:characters/characters.dart';

import 'money.dart';

/// Batas isian F&B.
abstract final class FnbLimits {
  static const areaName = 40;
  static const tableName = 20;
  static const seatsMax = 99;
  static const guestsMax = 99;
  static const customerName = 40;
  static const voidReason = 120;
  static const itemNote = 120;

  /// Tarif service maks 30%.
  static const serviceBp = BasisPoints(3000);

  /// Tarif PB1 maks 20%.
  static const taxBp = BasisPoints(2000);

  /// Langkah tarif 0,5%.
  static const rateStepBp = 50;

  /// Maks meja sekali *Tambah beberapa*.
  static const tableBatch = 50;
}

/// Rincian tagihan F&B: subtotal (setelah grosir), service, PB1, total.
class FnbCharges {
  const FnbCharges({
    required this.subtotal,
    required this.service,
    required this.tax,
  });

  final Money subtotal;
  final Money service;
  final Money tax;

  Money get total => subtotal + service + tax;
}

/// Service = [subtotal] × [serviceBp] (hanya [dineIn]); PB1 = (subtotal +
/// service) × [taxBp]. Masing-masing dibulatkan setengah ke atas.
FnbCharges fnbCharges(
  Money subtotal, {
  required bool dineIn,
  required BasisPoints serviceBp,
  required BasisPoints taxBp,
}) {
  final service = dineIn ? subtotal.applyBp(serviceBp) : Money.zero;
  final tax = (subtotal + service).applyBp(taxBp);
  return FnbCharges(subtotal: subtotal, service: service, tax: tax);
}

/// Tarif sah: 0..[max] dan kelipatan 0,5%.
bool validateFnbRate(BasisPoints bp, BasisPoints max) =>
    bp.value >= 0 &&
    bp.value <= max.value &&
    bp.value % FnbLimits.rateStepBp == 0;

enum DiningNameError { empty, tooLong, duplicate }

/// Nama meja/area: wajib, maks [max] karakter terlihat, unik di [existing]
/// tanpa membedakan huruf (isi [existing] tanpa nama baris yang diubah).
DiningNameError? validateDiningName(
  String name, {
  required int max,
  required Iterable<String> existing,
}) {
  final t = name.trim();
  if (t.isEmpty) return DiningNameError.empty;
  if (t.characters.length > max) return DiningNameError.tooLong;
  final key = t.toLowerCase();
  if (existing.any((e) => e.trim().toLowerCase() == key)) {
    return DiningNameError.duplicate;
  }
  return null;
}

/// Nama meja *Tambah beberapa*: `M1`…`M12`. Awalan yang diakhiri huruf
/// atau angka langsung disambung; spasi tepi dibuang kecuali pemisah
/// kata (`Meja 9`). `null` bila rentang tidak sah atau > 50 meja.
List<String>? tableRange(String prefix, int from, int to) {
  if (from < 1 || to < from || to - from + 1 > FnbLimits.tableBatch) {
    return null;
  }
  final p = prefix.trim();
  final sep = p.length > 1 && RegExp(r'[A-Za-z]{2}$').hasMatch(p) ? ' ' : '';
  return [for (var i = from; i <= to; i++) '$p$sep$i'];
}

/// Nomor take away harian: `TA-07`.
String takeAwayLabel(int n) => 'TA-${n.toString().padLeft(2, '0')}';

/// Nomor tiket dapur harian: `K-0012`.
String kitchenTicketLabel(int n) => 'K-${n.toString().padLeft(4, '0')}';

/// Nomor harian berikutnya dari nomor yang sudah dipakai hari ini.
int nextDailyNumber(Iterable<int> usedToday) =>
    usedToday.fold(0, (m, n) => n > m ? n : m) + 1;

/// Badge daftar take away (1.7e).
enum TakeAwayState { empty, pending, inKitchen, ready }

TakeAwayState takeAwayState({
  required int pending,
  required int sent,
  required int served,
}) {
  if (pending > 0) return TakeAwayState.pending;
  if (sent > 0) return TakeAwayState.inKitchen;
  if (served > 0) return TakeAwayState.ready;
  return TakeAwayState.empty;
}
