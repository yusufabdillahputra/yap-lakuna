/// Modifier menu F&B (F1-10b, layar 1.8 / 1.16b / 1.17b).
library;

import 'package:characters/characters.dart';

import 'money.dart';

/// Batas isian modifier.
abstract final class ModifierLimits {
  static const groupName = 40;
  static const optionName = 40;
  static const selectMax = 20;
  static const optionsMax = 30;

  /// Tambahan harga per opsi: −Rp 1.000.000 s.d. Rp 1.000.000.
  static const priceDelta = Money(1000000);
}

/// Isian satu opsi di form grup (1.17b).
class ModifierOptionDraft {
  const ModifierOptionDraft({
    required this.name,
    this.priceDelta = Money.zero,
    this.isDefault = false,
    this.isAvailable = true,
    this.id,
  });

  /// `null` = opsi baru.
  final String? id;
  final String name;
  final Money priceDelta;
  final bool isDefault;
  final bool isAvailable;
}

/// Isian form grup modifier (1.17b).
class ModifierGroupDraft {
  const ModifierGroupDraft({
    required this.name,
    required this.minSelect,
    required this.maxSelect,
    required this.options,
  });

  final String name;
  final int minSelect;
  final int maxSelect;
  final List<ModifierOptionDraft> options;

  /// *Wajib dipilih* = minimal ≥ 1.
  bool get required => minSelect > 0;
}

enum ModifierGroupError {
  nameEmpty,
  nameTooLong,
  nameDuplicate,

  /// Maks < 1, min > maks, atau di luar 0..20.
  selectRange,

  /// Minimal pilih lebih dari jumlah opsi.
  minAboveOptions,

  /// Tidak ada opsi atau lebih dari 30.
  optionCount,
  optionNameEmpty,
  optionNameTooLong,
  optionNameDuplicate,
  optionPrice,

  /// Opsi bawaan lebih banyak dari maksimal pilih.
  defaultsAboveMax,
}

int _len(String s) => s.trim().characters.length;

/// Galat per opsi (indeks → galat pertama) untuk ditandai di baris form.
Map<int, ModifierGroupError> modifierOptionErrors(ModifierGroupDraft d) {
  final errors = <int, ModifierGroupError>{};
  final seen = <String>{};
  for (final (i, o) in d.options.indexed) {
    final key = o.name.trim().toLowerCase();
    if (key.isEmpty) {
      errors[i] = ModifierGroupError.optionNameEmpty;
    } else if (_len(o.name) > ModifierLimits.optionName) {
      errors[i] = ModifierGroupError.optionNameTooLong;
    } else if (!seen.add(key)) {
      errors[i] = ModifierGroupError.optionNameDuplicate;
    } else if (o.priceDelta > ModifierLimits.priceDelta ||
        o.priceDelta < -ModifierLimits.priceDelta) {
      errors[i] = ModifierGroupError.optionPrice;
    }
  }
  return errors;
}

/// Validasi grup [d]; [existingNames] = nama grup lain di tenant (tanpa
/// grup yang sedang diubah).
List<ModifierGroupError> validateModifierGroup(
  ModifierGroupDraft d, {
  required Iterable<String> existingNames,
}) {
  final errors = <ModifierGroupError>[];
  final name = d.name.trim();
  if (name.isEmpty) {
    errors.add(ModifierGroupError.nameEmpty);
  } else if (_len(name) > ModifierLimits.groupName) {
    errors.add(ModifierGroupError.nameTooLong);
  } else if (existingNames.any(
    (e) => e.trim().toLowerCase() == name.toLowerCase(),
  )) {
    errors.add(ModifierGroupError.nameDuplicate);
  }
  if (d.minSelect < 0 ||
      d.maxSelect < 1 ||
      d.minSelect > d.maxSelect ||
      d.maxSelect > ModifierLimits.selectMax) {
    errors.add(ModifierGroupError.selectRange);
  } else if (d.minSelect > d.options.length) {
    errors.add(ModifierGroupError.minAboveOptions);
  }
  if (d.options.isEmpty || d.options.length > ModifierLimits.optionsMax) {
    errors.add(ModifierGroupError.optionCount);
  }
  for (final e in modifierOptionErrors(d).values.toSet()) {
    errors.add(e);
  }
  if (d.options.where((o) => o.isDefault).length > d.maxSelect) {
    errors.add(ModifierGroupError.defaultsAboveMax);
  }
  return errors;
}

/// Opsi yang bisa dipilih kasir (untuk validasi pilihan).
class ModifierOptionRule {
  const ModifierOptionRule({
    required this.id,
    required this.priceDelta,
    this.available = true,
  });

  final String id;
  final Money priceDelta;
  final bool available;
}

/// Grup terpasang di produk (untuk validasi pilihan).
class ModifierGroupRule {
  const ModifierGroupRule({
    required this.id,
    required this.name,
    required this.minSelect,
    required this.maxSelect,
    required this.options,
  });

  final String id;
  final String name;
  final int minSelect;
  final int maxSelect;
  final List<ModifierOptionRule> options;
}

enum ModifierSelectionError {
  /// Opsi bukan milik grup yang terpasang di produk.
  unknown,
  duplicate,
  unavailable,
  belowMin,
  aboveMax,
}

/// Pilihan [selected] (id opsi) untuk produk dengan grup [groups].
ModifierSelectionError? validateModifierSelection(
  List<ModifierGroupRule> groups,
  List<String> selected,
) {
  if (selected.toSet().length != selected.length) {
    return ModifierSelectionError.duplicate;
  }
  final byId = {
    for (final g in groups)
      for (final o in g.options) o.id: (g, o),
  };
  for (final id in selected) {
    final hit = byId[id];
    if (hit == null) return ModifierSelectionError.unknown;
    if (!hit.$2.available) return ModifierSelectionError.unavailable;
  }
  for (final g in groups) {
    final n = g.options.where((o) => selected.contains(o.id)).length;
    if (n < g.minSelect) return ModifierSelectionError.belowMin;
    if (n > g.maxSelect) return ModifierSelectionError.aboveMax;
  }
  return null;
}

/// Σ tambahan harga opsi [selected] per satuan.
Money modifierDelta(List<ModifierGroupRule> groups, List<String> selected) =>
    Money.sum([
      for (final g in groups)
        for (final o in g.options)
          if (selected.contains(o.id)) o.priceDelta,
    ]);

/// Kunci gabung baris: id opsi terurut, `null` bila tanpa modifier.
String? modifierKey(Iterable<String> ids) {
  if (ids.isEmpty) return null;
  return (ids.toList()..sort()).join(',');
}

/// Harga satuan + tambahan; `null` bila hasilnya negatif.
Money? modifiedUnitPrice(Money unitPrice, Money delta) {
  final p = unitPrice + delta;
  return p.isNegative ? null : p;
}
