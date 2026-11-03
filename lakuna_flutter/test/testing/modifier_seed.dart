import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';

import 'fake_stock_repository.dart' show fakeId;

ModifierOption seedOption(
  int n,
  UuidValue group,
  String name,
  int delta, {
  bool isDefault = false,
  bool available = true,
  int order = 0,
}) => ModifierOption(
  id: fakeId(700 + n),
  tenantId: fakeId(1),
  modifierGroupId: group,
  name: name,
  priceDelta: delta,
  isDefault: isDefault,
  isAvailable: available,
  sortOrder: order,
  hlc: '',
);

ModifierGroup seedGroup(int n, String name, int min, int max, int order) =>
    ModifierGroup(
      id: fakeId(690 + n),
      tenantId: fakeId(1),
      name: name,
      minSelect: min,
      maxSelect: max,
      sortOrder: order,
      hlc: '',
    );

/// Ukuran (wajib pilih 1: Reguler bawaan, Besar +4.000) dan Topping
/// (opsional maks 2: Boba +5.000, Keju +6.000 habis), sesuai kriteria
/// selesai v0.12.0.
List<ModifierGroupDetail> seedModifierGroups({int sizeProducts = 1}) {
  final size = seedGroup(1, 'Ukuran', 1, 1, 0);
  final topping = seedGroup(2, 'Topping', 0, 2, 1);
  return [
    ModifierGroupDetail(
      group: size,
      options: [
        seedOption(1, size.id, 'Reguler', 0, isDefault: true),
        seedOption(2, size.id, 'Besar', 4000, order: 1),
      ],
      productCount: sizeProducts,
    ),
    ModifierGroupDetail(
      group: topping,
      options: [
        seedOption(3, topping.id, 'Boba', 5000),
        seedOption(4, topping.id, 'Keju', 6000, available: false, order: 1),
      ],
    ),
  ];
}
