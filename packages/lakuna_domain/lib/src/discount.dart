/// Diskon manual Kasir per baris atau per nota (F1-04b, 1.4b).
library;

import 'money.dart';

enum DiscountKind { percent, amount }

enum DiscountIssue {
  /// Nol, negatif, atau persen > 100%.
  invalid,

  /// Potongan melebihi dasar (baris atau nota).
  tooLarge,
}

/// Diskon manual: persen (basis poin) atau rupiah.
class ManualDiscount {
  const ManualDiscount.percent(this._bp)
    : kind = DiscountKind.percent,
      _amount = Money.zero;

  const ManualDiscount.amount(this._amount)
    : kind = DiscountKind.amount,
      _bp = BasisPoints.zero;

  final DiscountKind kind;
  final BasisPoints _bp;
  final Money _amount;

  int get _value => kind == DiscountKind.percent ? _bp.value : _amount.value;

  /// Persen dalam basis poin; 0 untuk diskon rupiah.
  int get bp => _bp.value;

  /// Nilai rupiah; nol untuk diskon persen.
  Money get amount => _amount;

  /// Potongan dari [base]: persen dibulatkan setengah ke atas, rupiah apa
  /// adanya (dibatasi [base]).
  Money cut(Money base) => switch (kind) {
    DiscountKind.percent => base.applyBp(_bp),
    DiscountKind.amount => _amount > base ? base : _amount,
  };

  /// Galat untuk dasar [base]; `null` bila sah.
  DiscountIssue? issue(Money base) {
    if (_value <= 0) return DiscountIssue.invalid;
    if (kind == DiscountKind.percent && _value > BasisPoints.full.value) {
      return DiscountIssue.invalid;
    }
    if (kind == DiscountKind.amount && _value > base.value) {
      return DiscountIssue.tooLarge;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is ManualDiscount && other.kind == kind && other._value == _value;

  @override
  int get hashCode => Object.hash(kind, _value);

  @override
  String toString() => 'ManualDiscount(${kind.name}: $_value)';
}

/// Isian diskon → [ManualDiscount]; `null` bila kosong atau tidak sah.
/// Persen paling banyak dua desimal ("12,5"); rupiah bulat, titik/koma
/// ribuan diabaikan ("12.500").
ManualDiscount? parseDiscountValue(String text, DiscountKind kind) {
  final t = text.trim();
  if (t.isEmpty) return null;
  switch (kind) {
    case DiscountKind.percent:
      final m = RegExp(r'^(\d{1,3})(?:[.,](\d{1,2}))?$').firstMatch(t);
      if (m == null) return null;
      final frac = (m.group(2) ?? '').padRight(2, '0');
      return ManualDiscount.percent(
        BasisPoints(int.parse(m.group(1)!) * 100 + int.parse(frac)),
      );
    case DiscountKind.amount:
      final digits = t.replaceAll(RegExp(r'[.,\s]'), '');
      if (!RegExp(r'^\d{1,12}$').hasMatch(digits)) return null;
      return ManualDiscount.amount(Money(int.parse(digits)));
  }
}
