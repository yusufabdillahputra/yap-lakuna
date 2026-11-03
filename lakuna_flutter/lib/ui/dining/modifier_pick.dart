import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

/// Status sheet pilih modifier 1.8: opsi terpilih per grup, jumlah, dan
/// total. Aturan sama dengan `validateModifierSelection` di domain.
class ModifierPick extends ChangeNotifier {
  ModifierPick(this.groups, {required this.basePrice}) {
    for (final g in groups) {
      final defaults = [
        for (final o in g.options)
          if (o.isDefault && o.isAvailable) o.id,
      ];
      _selected[g.id] = defaults.take(g.group.maxSelect).toList();
    }
  }

  final List<ModifierGroupDetail> groups;

  /// Harga dasar satu satuan pilihan menu.
  final Money basePrice;

  static const maxQuantity = 999;

  final _selected = <UuidValue, List<UuidValue>>{};
  var _quantity = 1;

  int get quantity => _quantity;

  void setQuantity(int value) {
    final q = value.clamp(1, maxQuantity);
    if (q == _quantity) return;
    _quantity = q;
    notifyListeners();
  }

  bool isSelected(ModifierGroupDetail g, ModifierOption o) =>
      _selected[g.id]?.contains(o.id) ?? false;

  /// Opsi bisa diketuk: tersedia, dan untuk pilihan ganda belum mencapai
  /// batas (opsi terpilih selalu bisa dilepas).
  bool canSelect(ModifierGroupDetail g, ModifierOption o) {
    if (!o.isAvailable) return false;
    if (g.group.maxSelect == 1 || isSelected(g, o)) return true;
    return (_selected[g.id]?.length ?? 0) < g.group.maxSelect;
  }

  void toggle(ModifierGroupDetail g, ModifierOption o) {
    if (!canSelect(g, o)) return;
    final list = _selected[g.id] ??= [];
    if (g.group.maxSelect == 1) {
      if (list.contains(o.id)) {
        // Pilihan tunggal wajib tidak bisa dikosongkan.
        if (g.isRequired) return;
        list.clear();
      } else {
        list
          ..clear()
          ..add(o.id);
      }
    } else if (!list.remove(o.id)) {
      list.add(o.id);
    }
    notifyListeners();
  }

  /// Opsi terpilih urut grup lalu urut opsi.
  List<UuidValue> get ids => [
    for (final g in groups)
      for (final o in g.options)
        if (isSelected(g, o)) o.id,
  ];

  Money get unitDelta => Money.sum([
    for (final g in groups)
      for (final o in g.options)
        if (isSelected(g, o)) Money(o.priceDelta),
  ]);

  /// Σ tambahan membuat harga satuan di bawah nol.
  bool get priceInvalid => modifiedUnitPrice(basePrice, unitDelta) == null;

  /// Grup yang belum memenuhi minimal pilih.
  bool groupMissing(ModifierGroupDetail g) =>
      (_selected[g.id]?.length ?? 0) < g.group.minSelect;

  bool get valid =>
      !priceInvalid &&
      validateModifierSelection(
            [
              for (final g in groups) g.rule,
            ],
            [for (final id in ids) id.uuid],
          ) ==
          null;

  Money get total => priceInvalid
      ? Money.zero
      : Money((basePrice + unitDelta).value * _quantity);
}
