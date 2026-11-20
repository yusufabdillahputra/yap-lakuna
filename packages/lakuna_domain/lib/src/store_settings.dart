/// Aturan pengaturan toko, cabang, dan penjualan (F1-18, layar 1.26).
library;

import 'package:characters/characters.dart';

import 'money.dart';
import 'rounding.dart';
import 'setup.dart' show setupNameMaxLength;

/// Pembulatan total nota.
enum TotalRounding {
  none(1),
  nearest100(100),
  nearest500(500);

  const TotalRounding(this.step);

  /// Kelipatan rupiah.
  final int step;

  /// Pembulatan dengan kelipatan [step] (kolom `sales.rounding_step`,
  /// F1-10h); `null` untuk 0 atau nilai yang tidak dikenal.
  static TotalRounding? byStep(int step) {
    for (final r in values) {
      if (r.step == step) return r;
    }
    return null;
  }

  static TotalRounding? byNameOrNull(Object? name) {
    for (final r in values) {
      if (r.name == name) return r;
    }
    return null;
  }
}

/// [total] dibulatkan ke kelipatan [rounding] terdekat; tepat setengah ke
/// atas (Rp 50 → Rp 100, Rp 250 → Rp 500). Nol dan negatif tidak diubah.
Money roundTotal(Money total, TotalRounding rounding) {
  final step = rounding.step;
  if (step <= 1 || total.value <= 0) return total;
  final rest = total.value % step;
  final down = total.value - rest;
  return Money(rest * 2 >= step ? down + step : down);
}

/// Aturan *Penjualan & stok* per cabang (kunci `sales.rules`).
class SalesRules {
  const SalesRules({
    this.allowNegativeStock = true,
    this.rounding = TotalRounding.none,
    this.discountNeedsPin = true,
    this.transferAccount = '',
    this.targetMarginBp,
  });

  /// JSON tersimpan; kolom yang rusak memakai nilai bawaan.
  factory SalesRules.fromJson(Object? json) {
    if (json is! Map) return const SalesRules();
    final negative = json['allowNegativeStock'];
    final pin = json['discountNeedsPin'];
    final account = json['transferAccount'];
    final target = json['targetMarginBp'];
    return SalesRules(
      allowNegativeStock: negative is bool ? negative : true,
      rounding:
          TotalRounding.byNameOrNull(json['rounding']) ?? TotalRounding.none,
      discountNeedsPin: pin is bool ? pin : true,
      // Nilai tersimpan dipangkas dan dibatasi agar simpan ulang aturan
      // lain tidak gagal karena data lama/rusak.
      transferAccount: account is String
          ? _storedTransferAccounts(account)
          : '',
      targetMarginBp: target is int && validTargetMarginBp(target)
          ? target
          : null,
    );
  }

  /// Bila `false`, nota yang membuat stok produk minus ditolak.
  final bool allowNegativeStock;
  final TotalRounding rounding;

  /// Staf tanpa `sales:discount` boleh memberi diskon manual dengan
  /// persetujuan PIN manajer (F1-04b). Bila `false`, menu diskon hanya
  /// untuk staf berizin.
  final bool discountNeedsPin;

  /// Rekening transfer toko (F1-05c), mis. `BCA 123-456-7890 a.n.
  /// Warung Contoh`; satu rekening per baris, maks
  /// [ProfileLimits.transferAccountLines] (F1-05f). Kosong = belum diatur.
  final String transferAccount;

  /// Target margin kotor cabang dalam basis poin (F1-16d), kelipatan 100
  /// dari 1% sampai 99%; `null` = tanpa target.
  final int? targetMarginBp;

  /// Rekening transfer per baris, tanpa baris kosong (F1-05f).
  List<String> get transferAccounts => _accountLines(transferAccount);

  Map<String, Object> toJson() => {
    'allowNegativeStock': allowNegativeStock,
    'rounding': rounding.name,
    'discountNeedsPin': discountNeedsPin,
    'transferAccount': transferAccount,
    'targetMarginBp': ?targetMarginBp,
  };

  SalesRules copyWith({
    bool? allowNegativeStock,
    TotalRounding? rounding,
    bool? discountNeedsPin,
    String? transferAccount,
    int? Function()? targetMarginBp,
  }) => SalesRules(
    allowNegativeStock: allowNegativeStock ?? this.allowNegativeStock,
    rounding: rounding ?? this.rounding,
    discountNeedsPin: discountNeedsPin ?? this.discountNeedsPin,
    transferAccount: transferAccount ?? this.transferAccount,
    targetMarginBp: targetMarginBp == null
        ? this.targetMarginBp
        : targetMarginBp(),
  );

  @override
  bool operator ==(Object other) =>
      other is SalesRules &&
      other.allowNegativeStock == allowNegativeStock &&
      other.rounding == rounding &&
      other.discountNeedsPin == discountNeedsPin &&
      other.transferAccount == transferAccount &&
      other.targetMarginBp == targetMarginBp;

  @override
  int get hashCode => Object.hash(
    allowNegativeStock,
    rounding,
    discountNeedsPin,
    transferAccount,
    targetMarginBp,
  );

  @override
  String toString() =>
      'SalesRules(allowNegativeStock: $allowNegativeStock, '
      'rounding: ${rounding.name}, discountNeedsPin: $discountNeedsPin, '
      'transferAccount: $transferAccount, targetMarginBp: $targetMarginBp)';
}

/// Target margin sah (F1-16d): 1%–99%, persen bulat.
bool validTargetMarginBp(int bp) => bp >= 100 && bp <= 9900 && bp % 100 == 0;

/// Galat isian target margin (F1-16d).
enum TargetMarginIssue { outOfRange }

final _wholeNumber = RegExp(r'^[0-9]+$');

/// Target margin dari isian persen bulat [text]; `null` bila kosong atau
/// tidak sah.
int? targetMarginBpOf(String text) {
  final t = text.trim();
  if (!_wholeNumber.hasMatch(t) || t.length > 3) return null;
  final bp = int.parse(t) * 100;
  return validTargetMarginBp(bp) ? bp : null;
}

/// Galat isian target margin: kosong (tanpa target) atau 1–99 sah.
TargetMarginIssue? targetMarginIssue(String text) =>
    text.trim().isEmpty || targetMarginBpOf(text) != null
    ? null
    : TargetMarginIssue.outOfRange;

/// Teks isian untuk target tersimpan [bp] (`2500` → `25`).
String targetMarginText(int? bp) => bp == null ? '' : '${bp ~/ 100}';

/// Selisih poin (bp) margin [marginBp] di bawah target [targetBp]; 0 bila
/// target tercapai. Margin dibulatkan dulu ke 0,1 poin seperti tampilannya
/// (`formatPercentBp`), agar *69,0%* tidak ditulis *kurang 0,0 poin*.
int marginGapBp(int marginBp, int targetBp) {
  final shown = divRoundHalfAway(BigInt.from(marginBp), BigInt.from(10)) * 10;
  return shown >= targetBp ? 0 : targetBp - shown;
}

/// Batas isian profil toko & cabang.
abstract final class ProfileLimits {
  static const name = setupNameMaxLength;
  static const address = 160;
  static const phone = 20;

  /// Rekening transfer di *Penjualan & stok* (F1-05c), per baris.
  static const transferAccount = 100;

  /// Jumlah rekening transfer, satu per baris (F1-05f).
  static const transferAccountLines = 3;
}

/// Pemisah baris: `\r\n`, `\r`, `\n`, atau U+2028 dari teks yang ditempel.
final _lineBreak = RegExp('\r\n?|\n|\u2028');

List<String> _accountLines(String text) => [
  for (final line in text.split(_lineBreak))
    if (line.trim() case final t when t.isNotEmpty) t,
];

/// Rekening transfer dirapikan (F1-05f): tiap baris dipangkas, baris
/// kosong dibuang, digabung dengan `\n`.
String normalizeTransferAccounts(String text) => _accountLines(text).join('\n');

/// Data tersimpan dibatasi agar simpan ulang aturan lain tidak gagal
/// karena data lama/rusak.
String _storedTransferAccounts(String text) => [
  for (final line in _accountLines(
    text,
  ).take(ProfileLimits.transferAccountLines))
    line.characters.take(ProfileLimits.transferAccount).toString().trim(),
].join('\n');

/// Galat isian rekening transfer (F1-05f).
enum TransferAccountIssue { tooMany, tooLong }

/// Galat isian rekening [text] setelah dirapikan, atau `null`.
TransferAccountIssue? transferAccountIssue(String text) {
  final lines = _accountLines(text);
  if (lines.length > ProfileLimits.transferAccountLines) {
    return TransferAccountIssue.tooMany;
  }
  if (lines.any((l) => l.characters.length > ProfileLimits.transferAccount)) {
    return TransferAccountIssue.tooLong;
  }
  return null;
}

enum ProfileIssue { required, tooLong, invalidPhone }

enum OutletProfileField { name, address, phone }

final _phone = RegExp(r'^[0-9+\- ]+$');

/// Nama usaha: wajib, maks 60 karakter.
ProfileIssue? storeNameIssue(String name) {
  final t = name.trim();
  if (t.isEmpty) return ProfileIssue.required;
  if (t.characters.length > ProfileLimits.name) return ProfileIssue.tooLong;
  return null;
}

/// Galat isian *Cabang ini*; kosong bila sah.
Map<OutletProfileField, ProfileIssue> outletProfileIssues({
  required String name,
  required String address,
  required String phone,
}) {
  final a = address.trim();
  final p = phone.trim();
  return {
    OutletProfileField.name: ?storeNameIssue(name),
    if (a.characters.length > ProfileLimits.address)
      OutletProfileField.address: ProfileIssue.tooLong,
    if (p.isNotEmpty && !_phone.hasMatch(p))
      OutletProfileField.phone: ProfileIssue.invalidPhone
    else if (p.length > ProfileLimits.phone)
      OutletProfileField.phone: ProfileIssue.tooLong,
  };
}
