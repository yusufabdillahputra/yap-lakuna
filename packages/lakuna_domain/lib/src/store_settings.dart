/// Aturan pengaturan toko, cabang, dan penjualan (F1-18, layar 1.26).
library;

import 'package:characters/characters.dart';

import 'money.dart';
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
  });

  /// JSON tersimpan; kolom yang rusak memakai nilai bawaan.
  factory SalesRules.fromJson(Object? json) {
    if (json is! Map) return const SalesRules();
    final negative = json['allowNegativeStock'];
    final pin = json['discountNeedsPin'];
    final account = json['transferAccount'];
    return SalesRules(
      allowNegativeStock: negative is bool ? negative : true,
      rounding:
          TotalRounding.byNameOrNull(json['rounding']) ?? TotalRounding.none,
      discountNeedsPin: pin is bool ? pin : true,
      // Nilai tersimpan dipangkas dan dibatasi agar simpan ulang aturan
      // lain tidak gagal karena data lama/rusak.
      transferAccount: account is String
          ? account
                .trim()
                .characters
                .take(ProfileLimits.transferAccount)
                .toString()
                .trim()
          : '',
    );
  }

  /// Bila `false`, nota yang membuat stok produk minus ditolak.
  final bool allowNegativeStock;
  final TotalRounding rounding;

  /// Staf tanpa `sales:discount` boleh memberi diskon manual dengan
  /// persetujuan PIN manajer (F1-04b). Bila `false`, menu diskon hanya
  /// untuk staf berizin.
  final bool discountNeedsPin;

  /// Rekening transfer toko, teks bebas satu baris (F1-05c), mis.
  /// `BCA 123-456-7890 a.n. Warung Contoh`. Kosong = belum diatur.
  final String transferAccount;

  Map<String, Object> toJson() => {
    'allowNegativeStock': allowNegativeStock,
    'rounding': rounding.name,
    'discountNeedsPin': discountNeedsPin,
    'transferAccount': transferAccount,
  };

  SalesRules copyWith({
    bool? allowNegativeStock,
    TotalRounding? rounding,
    bool? discountNeedsPin,
    String? transferAccount,
  }) => SalesRules(
    allowNegativeStock: allowNegativeStock ?? this.allowNegativeStock,
    rounding: rounding ?? this.rounding,
    discountNeedsPin: discountNeedsPin ?? this.discountNeedsPin,
    transferAccount: transferAccount ?? this.transferAccount,
  );

  @override
  bool operator ==(Object other) =>
      other is SalesRules &&
      other.allowNegativeStock == allowNegativeStock &&
      other.rounding == rounding &&
      other.discountNeedsPin == discountNeedsPin &&
      other.transferAccount == transferAccount;

  @override
  int get hashCode => Object.hash(
    allowNegativeStock,
    rounding,
    discountNeedsPin,
    transferAccount,
  );

  @override
  String toString() =>
      'SalesRules(allowNegativeStock: $allowNegativeStock, '
      'rounding: ${rounding.name}, discountNeedsPin: $discountNeedsPin, '
      'transferAccount: $transferAccount)';
}

/// Batas isian profil toko & cabang.
abstract final class ProfileLimits {
  static const name = setupNameMaxLength;
  static const address = 160;
  static const phone = 20;

  /// Rekening transfer di *Penjualan & stok* (F1-05c).
  static const transferAccount = 100;
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
