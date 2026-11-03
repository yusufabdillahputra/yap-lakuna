import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/ui/dining/modifier_pick.dart';

import '../../testing/modifier_seed.dart';

void main() {
  final groups = seedModifierGroups();
  final ukuran = groups.first;
  final topping = groups.last;
  final reguler = ukuran.options.first;
  final besar = ukuran.options.last;
  final boba = topping.options.first;
  final keju = topping.options.last;

  test('bawaan tersedia terpilih; total = (harga + tambahan) × jumlah', () {
    final pick = ModifierPick(groups, basePrice: const Money(24000));
    expect(pick.isSelected(ukuran, reguler), isTrue);
    expect(pick.valid, isTrue);
    expect(pick.total, const Money(24000));

    pick.toggle(ukuran, besar);
    expect(pick.isSelected(ukuran, reguler), isFalse);
    expect(pick.isSelected(ukuran, besar), isTrue);
    pick.toggle(topping, boba);
    pick.setQuantity(2);
    expect(pick.unitDelta, const Money(9000));
    expect(pick.total, const Money(66000));
    expect(pick.ids, [besar.id, boba.id]);
  });

  test('pilihan tunggal wajib tidak bisa dikosongkan; opsional bisa', () {
    final pick = ModifierPick(groups, basePrice: const Money(24000));
    pick.toggle(ukuran, reguler);
    expect(pick.isSelected(ukuran, reguler), isTrue);
    pick.toggle(topping, boba);
    pick.toggle(topping, boba);
    expect(pick.isSelected(topping, boba), isFalse);
  });

  test('habis tidak bisa dipilih; batas maks menonaktifkan opsi lain', () {
    final pick = ModifierPick(groups, basePrice: const Money(24000));
    expect(pick.canSelect(topping, keju), isFalse);
    pick.toggle(topping, keju);
    expect(pick.isSelected(topping, keju), isFalse);

    final many = seedModifierGroups(extraToppings: true);
    final t = many.last;
    final [b, _, jelly, pudding] = t.options;
    final limited = ModifierPick(many, basePrice: const Money(10000));
    limited.toggle(t, b);
    limited.toggle(t, jelly);
    expect(limited.canSelect(t, pudding), isFalse);
    limited.toggle(t, pudding);
    expect(limited.isSelected(t, pudding), isFalse);
    expect(limited.canSelect(t, jelly), isTrue, reason: 'bisa dilepas');
  });

  test('wajib belum dipilih → tidak sah; jumlah 1–999', () {
    final noDefault = seedModifierGroups(noDefaults: true);
    final pick = ModifierPick(noDefault, basePrice: const Money(24000));
    expect(pick.valid, isFalse);
    pick.toggle(noDefault.first, noDefault.first.options.first);
    expect(pick.valid, isTrue);
    pick.setQuantity(0);
    expect(pick.quantity, 1);
    pick.setQuantity(1500);
    expect(pick.quantity, 999);
  });

  test('tambahan negatif melebihi harga → tidak sah', () {
    final pick = ModifierPick(groups, basePrice: const Money(3000));
    pick.toggle(ukuran, besar);
    expect(pick.valid, isTrue);
    final cheap = ModifierPick(
      seedModifierGroups(sizeDelta: -5000),
      basePrice: const Money(3000),
    );
    cheap.toggle(cheap.groups.first, cheap.groups.first.options.last);
    expect(cheap.priceInvalid, isTrue);
    expect(cheap.valid, isFalse);
  });
}
