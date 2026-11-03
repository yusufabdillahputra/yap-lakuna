import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/master_data_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

import 'fake_stock_repository.dart' show fakeId;
import 'modifier_seed.dart';

/// Master data di memori dengan aturan `lakuna_domain` yang sama dengan
/// `lakuna_data`. Contoh: Sembako (2 produk), Minuman (1) dengan subkategori
/// Kopi (1, warna sky), Rokok nonaktif (0); satuan pcs (2), botol (1),
/// dus (0); lokasi Etalase (bawaan) dan Gudang.
class FakeMasterDataRepository extends MasterDataRepository {
  FakeMasterDataRepository({this.permitted = true}) {
    final tenant = fakeId(1);
    ProductCategory cat(
      int n,
      String name,
      int order, {
      UuidValue? parent,
      String? color,
      bool active = true,
    }) => ProductCategory(
      id: fakeId(300 + n),
      tenantId: tenant,
      name: name,
      sortOrder: order,
      parentId: parent,
      color: color,
      isActive: active,
      hlc: '',
    );
    categoriesData.addAll([
      cat(1, 'Sembako', 0),
      cat(2, 'Minuman', 1),
      cat(3, 'Kopi', 2, parent: fakeId(302), color: categoryColors.first),
      cat(4, 'Rokok', 3, active: false),
    ]);
    productCounts.addAll({fakeId(301): 2, fakeId(302): 1, fakeId(303): 1});
    MeasureUnit unit(int n, String name) =>
        MeasureUnit(id: fakeId(400 + n), tenantId: tenant, name: name, hlc: '');
    unitsData.addAll([unit(1, 'pcs'), unit(2, 'botol'), unit(3, 'dus')]);
    unitCounts.addAll({fakeId(401): 2, fakeId(402): 1});
    locationsData.addAll([
      StockLocation(
        id: fakeId(101),
        tenantId: tenant,
        outletId: fakeId(2),
        name: 'Etalase',
        isDefault: true,
        hlc: '',
      ),
      StockLocation(
        id: fakeId(102),
        tenantId: tenant,
        outletId: fakeId(2),
        name: 'Gudang',
        hlc: '',
      ),
    ]);
  }

  bool permitted;

  /// Ukuran (dipakai 1 menu) dan Topping.
  final modifierGroupsData = seedModifierGroups();
  final categoriesData = <ProductCategory>[];
  final productCounts = <UuidValue, int>{};
  final unitsData = <MeasureUnit>[];
  final unitCounts = <UuidValue, int>{};
  final locationsData = <StockLocation>[];

  /// Galat berikutnya (sekali pakai).
  Exception? nextError;
  var _next = 500;

  Result<T> _run<T>(T Function() body) {
    final e = nextError;
    nextError = null;
    if (e != null) return Result.error(e);
    if (!permitted) {
      return const Result.error(NotPermitted(Permission.productsManage));
    }
    try {
      return Result.ok(body());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  List<ProductCategory> get _ordered => [...categoriesData]
    ..sort(
      (a, b) => a.sortOrder != b.sortOrder
          ? a.sortOrder.compareTo(b.sortOrder)
          : a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

  List<CategoryRef> get _refs => [
    for (final c in categoriesData)
      CategoryRef(id: c.id.uuid, name: c.name, parentId: c.parentId?.uuid),
  ];

  ProductCategory _find(UuidValue id) =>
      categoriesData.where((c) => c.id == id).firstOrNull ??
      (throw MasterNotFound());

  void _replace(ProductCategory row) =>
      categoriesData[categoriesData.indexWhere((c) => c.id == row.id)] = row;

  UuidValue? _parent(String? id) =>
      id == null ? null : UuidValue.fromString(id);

  @override
  Future<Result<List<CategoryRow>>> categories() async => _run(() {
    final names = {for (final c in categoriesData) c.id: c.name};
    return [
      for (final c in _ordered)
        CategoryRow(
          category: c,
          productCount: productCounts[c.id] ?? 0,
          parentName: names[c.parentId],
        ),
    ];
  });

  @override
  Future<Result<ProductCategory>> createCategory(CategoryDraft draft) async =>
      _run(() {
        final errors = validateCategory(draft, existing: _refs);
        if (errors.isNotEmpty) throw CategoryInvalid(errors);
        final row = ProductCategory(
          id: fakeId(_next++),
          tenantId: fakeId(1),
          name: draft.name.trim(),
          parentId: _parent(draft.parentId),
          color: draft.color,
          showInCashier: draft.showInCashier,
          isActive: draft.isActive,
          sortOrder: categoriesData.length,
          hlc: '',
        );
        categoriesData.add(row);
        return row;
      });

  @override
  Future<Result<ProductCategory>> updateCategory(
    UuidValue id,
    CategoryDraft draft,
  ) async => _run(() {
    final current = _find(id);
    final errors = validateCategory(draft, id: id.uuid, existing: _refs);
    if (errors.isNotEmpty) throw CategoryInvalid(errors);
    final row = current.copyWith(
      name: draft.name.trim(),
      parentId: _parent(draft.parentId),
      color: draft.color,
      showInCashier: draft.showInCashier,
      isActive: draft.isActive,
      version: current.version + 1,
    );
    _replace(row);
    return row;
  });

  @override
  Future<Result<ProductCategory>> setCategoryActive(
    UuidValue id,
    bool active,
  ) async => _run(() {
    final row = _find(id).copyWith(isActive: active);
    _replace(row);
    return row;
  });

  @override
  Future<Result<void>> moveCategory(UuidValue id, int delta) async => _run(() {
    final ordered = _ordered;
    final index = ordered.indexWhere((c) => c.id == id);
    if (index < 0) throw MasterNotFound();
    final moved = moveInOrder(ordered, index, delta);
    for (var i = 0; i < moved.length; i++) {
      _replace(moved[i].copyWith(sortOrder: i));
    }
  });

  @override
  Future<Result<void>> deleteCategory(UuidValue id) async => _run(() {
    _find(id);
    final products = productCounts[id] ?? 0;
    final children = categoriesData.where((c) => c.parentId == id).length;
    if (products > 0 || children > 0) {
      throw MasterInUse(products: products, children: children);
    }
    categoriesData.removeWhere((c) => c.id == id);
  });

  @override
  Future<Result<List<UnitRow>>> units() async => _run(
    () => [
      for (final u
          in [...unitsData]..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          ))
        UnitRow(unit: u, productCount: unitCounts[u.id] ?? 0),
    ],
  );

  @override
  Future<Result<MeasureUnit>> createUnit(String name) async => _run(() {
    final error = validateUnitName(
      name,
      existing: unitsData.map((u) => u.name),
    );
    if (error != null) throw UnitInvalid(error);
    final u = MeasureUnit(
      id: fakeId(_next++),
      tenantId: fakeId(1),
      name: name.trim(),
      hlc: '',
    );
    unitsData.add(u);
    return u;
  });

  @override
  Future<Result<MeasureUnit>> renameUnit(UuidValue id, String name) async =>
      _run(() {
        final i = unitsData.indexWhere((u) => u.id == id);
        if (i < 0) throw MasterNotFound();
        final error = validateUnitName(
          name,
          existing: unitsData.where((u) => u.id != id).map((u) => u.name),
        );
        if (error != null) throw UnitInvalid(error);
        return unitsData[i] = unitsData[i].copyWith(name: name.trim());
      });

  @override
  Future<Result<void>> deleteUnit(UuidValue id) async => _run(() {
    if (!unitsData.any((u) => u.id == id)) throw MasterNotFound();
    final products = unitCounts[id] ?? 0;
    if (products > 0) throw MasterInUse(products: products);
    unitsData.removeWhere((u) => u.id == id);
  });

  @override
  Future<Result<List<StockLocation>>> locations() async =>
      _run(() => List.of(locationsData));

  @override
  Future<Result<List<ModifierGroupDetail>>> modifierGroups() async =>
      _run(() => List.of(modifierGroupsData));

  @override
  Future<Result<ModifierGroup>> saveModifierGroup(
    UuidValue? id,
    ModifierGroupDraft draft,
  ) async => _run(() {
    final index = id == null
        ? -1
        : modifierGroupsData.indexWhere((g) => g.id == id);
    if (id != null && index < 0) throw MasterNotFound();
    final errors = validateModifierGroup(
      draft,
      existingNames: [
        for (final g in modifierGroupsData)
          if (g.id != id) g.name,
      ],
    );
    if (errors.isNotEmpty) {
      throw ModifierGroupInvalid(
        errors,
        optionErrors: modifierOptionErrors(draft),
      );
    }
    final old = index < 0 ? null : modifierGroupsData[index];
    final group = ModifierGroup(
      id: old?.id ?? fakeId(_next++),
      tenantId: fakeId(1),
      name: draft.name.trim(),
      minSelect: draft.minSelect,
      maxSelect: draft.maxSelect,
      sortOrder: old?.group.sortOrder ?? modifierGroupsData.length,
      hlc: '',
    );
    final detail = ModifierGroupDetail(
      group: group,
      options: [
        for (final (i, o) in draft.options.indexed)
          ModifierOption(
            id: o.id == null ? fakeId(_next++) : UuidValue.fromString(o.id!),
            tenantId: fakeId(1),
            modifierGroupId: group.id,
            name: o.name.trim(),
            priceDelta: o.priceDelta.value,
            isDefault: o.isDefault,
            isAvailable: o.isAvailable,
            sortOrder: i,
            hlc: '',
          ),
      ],
      productCount: old?.productCount ?? 0,
    );
    if (index < 0) {
      modifierGroupsData.add(detail);
    } else {
      modifierGroupsData[index] = detail;
    }
    return group;
  });

  @override
  Future<Result<void>> moveModifierGroup(UuidValue id, int delta) async =>
      _run(() {
        final i = modifierGroupsData.indexWhere((g) => g.id == id);
        if (i < 0) throw MasterNotFound();
        final j = (i + delta).clamp(0, modifierGroupsData.length - 1);
        final g = modifierGroupsData.removeAt(i);
        modifierGroupsData.insert(j, g);
      });

  @override
  Future<Result<void>> deleteModifierGroup(UuidValue id) async => _run(() {
    final g = modifierGroupsData.where((g) => g.id == id).firstOrNull;
    if (g == null) throw MasterNotFound();
    if (g.productCount > 0) throw MasterInUse(products: g.productCount);
    modifierGroupsData.remove(g);
  });
}
