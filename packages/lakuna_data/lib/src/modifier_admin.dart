import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show DatabaseSession, Transaction;

import 'master_data.dart' show MasterInUse, MasterNotFound;
import 'stock.dart';
import 'store.dart';

/// Master grup modifier F1-10b (1.17b). Grup per tenant; opsi dihapus
/// lunak agar nota lama tetap utuh (nama & harga juga disalin di
/// `sale_item_modifiers`).

class ModifierGroupInvalid implements Exception {
  const ModifierGroupInvalid(this.errors, {this.optionErrors = const {}});

  final List<ModifierGroupError> errors;

  /// Indeks opsi → galat pertama, untuk ditandai di baris form.
  final Map<int, ModifierGroupError> optionErrors;

  @override
  String toString() => 'ModifierGroupInvalid(${errors.map((e) => e.name)})';
}

/// Grup dengan opsi (belum dihapus, urut) untuk master dan sheet 1.8.
class ModifierGroupDetail {
  const ModifierGroupDetail({
    required this.group,
    required this.options,
    this.productCount = 0,
  });

  final ModifierGroup group;
  final List<ModifierOption> options;

  /// Produk (belum dihapus) yang memasang grup ini.
  final int productCount;

  UuidValue get id => group.id;
  String get name => group.name;
  bool get isRequired => group.minSelect > 0;

  /// Aturan untuk [validateModifierSelection].
  ModifierGroupRule get rule => ModifierGroupRule(
    id: group.id.uuid,
    name: group.name,
    minSelect: group.minSelect,
    maxSelect: group.maxSelect,
    options: [
      for (final o in options)
        ModifierOptionRule(
          id: o.id.uuid,
          priceDelta: Money(o.priceDelta),
          available: o.isAvailable,
        ),
    ],
  );

  /// Isi form ubah grup.
  ModifierGroupDraft toDraft() => ModifierGroupDraft(
    name: group.name,
    minSelect: group.minSelect,
    maxSelect: group.maxSelect,
    options: [
      for (final o in options)
        ModifierOptionDraft(
          id: o.id.uuid,
          name: o.name,
          priceDelta: Money(o.priceDelta),
          isDefault: o.isDefault,
          isAvailable: o.isAvailable,
        ),
    ],
  );
}

int _order(int a, int b) => a.compareTo(b);

Future<List<ModifierGroup>> _groups(
  DatabaseSession session,
  UuidValue tenantId, {
  Set<UuidValue>? ids,
  Transaction? transaction,
}) async => (await ModifierGroup.db.find(
  session,
  where: (g) =>
      g.tenantId.equals(tenantId) &
      g.deletedAt.equals(null) &
      (ids == null ? g.id.notEquals(null) : g.id.inSet(ids)),
  transaction: transaction,
))..sort((a, b) => _order(a.sortOrder, b.sortOrder));

Future<List<ModifierOption>> _options(
  DatabaseSession session,
  UuidValue tenantId,
  Iterable<UuidValue> groupIds, {
  Transaction? transaction,
}) async {
  final ids = groupIds.toSet();
  if (ids.isEmpty) return const [];
  return (await ModifierOption.db.find(
    session,
    where: (o) =>
        o.tenantId.equals(tenantId) &
        o.deletedAt.equals(null) &
        o.modifierGroupId.inSet(ids),
    transaction: transaction,
  ))..sort((a, b) => _order(a.sortOrder, b.sortOrder));
}

/// Pemasangan grup di produk yang belum dihapus (produk juga belum dihapus),
/// opsional dibatasi ke [productIds] dan/atau [groupIds].
Future<List<ProductModifierGroup>> productModifierLinks(
  DatabaseSession session,
  UuidValue tenantId, {
  Iterable<UuidValue>? productIds,
  Iterable<UuidValue>? groupIds,
  Transaction? transaction,
}) async {
  final ids = productIds?.toSet();
  final groups = groupIds?.toSet();
  if (ids != null && ids.isEmpty) return const [];
  if (groups != null && groups.isEmpty) return const [];
  final links = await ProductModifierGroup.db.find(
    session,
    where: (l) =>
        l.tenantId.equals(tenantId) &
        l.deletedAt.equals(null) &
        (ids == null ? l.id.notEquals(null) : l.productId.inSet(ids)) &
        (groups == null
            ? l.id.notEquals(null)
            : l.modifierGroupId.inSet(groups)),
    transaction: transaction,
  );
  if (links.isEmpty) return const [];
  final linked = {for (final l in links) l.productId};
  final live = {
    for (final p in await Product.db.find(
      session,
      where: (p) =>
          p.tenantId.equals(tenantId) &
          p.deletedAt.equals(null) &
          p.id.inSet(linked),
      transaction: transaction,
    ))
      p.id,
  };
  return [
    for (final l in links)
      if (live.contains(l.productId)) l,
  ]..sort((a, b) => _order(a.sortOrder, b.sortOrder));
}

/// Grup modifier tenant (semua, atau hanya [groupIds]) beserta opsi dan
/// jumlah menu pemakai.
Future<List<ModifierGroupDetail>> modifierGroupDetails(
  DatabaseSession session,
  UuidValue tenantId, {
  Iterable<UuidValue>? groupIds,
  Transaction? transaction,
}) async {
  final only = groupIds?.toSet();
  if (only != null && only.isEmpty) return const [];
  final groups = await _groups(
    session,
    tenantId,
    ids: only,
    transaction: transaction,
  );
  final options = await _options(session, tenantId, [
    for (final g in groups) g.id,
  ], transaction: transaction);
  final counts = <UuidValue, int>{};
  for (final l in await productModifierLinks(
    session,
    tenantId,
    groupIds: only,
    transaction: transaction,
  )) {
    counts[l.modifierGroupId] = (counts[l.modifierGroupId] ?? 0) + 1;
  }
  return [
    for (final g in groups)
      ModifierGroupDetail(
        group: g,
        options: [
          for (final o in options)
            if (o.modifierGroupId == g.id) o,
        ],
        productCount: counts[g.id] ?? 0,
      ),
  ];
}

/// Grup modifier per produk (urut pemasangan) untuk sheet 1.8 di layar
/// Meja. Produk tanpa grup tidak ada di peta.
Future<Map<UuidValue, List<ModifierGroupDetail>>> menuModifierGroups(
  LakunaStore store,
  CatalogScope scope,
) async {
  final links = await productModifierLinks(store.session, scope.tenantId);
  if (links.isEmpty) return const {};
  final details = {
    for (final d in await modifierGroupDetails(store.session, scope.tenantId))
      d.id: d,
  };
  final result = <UuidValue, List<ModifierGroupDetail>>{};
  for (final l in links) {
    if (details[l.modifierGroupId] case final d?) {
      (result[l.productId] ??= []).add(d);
    }
  }
  return result;
}

/// Daftar grup untuk tab Master › Grup modifier.
Future<List<ModifierGroupDetail>> modifierGroupRows(
  LakunaStore store,
  CatalogScope scope,
) => modifierGroupDetails(store.session, scope.tenantId);

ModifierGroupDraft _clean(ModifierGroupDraft d) => ModifierGroupDraft(
  name: d.name.trim(),
  minSelect: d.minSelect,
  maxSelect: d.maxSelect,
  options: [
    for (final o in d.options)
      ModifierOptionDraft(
        id: o.id,
        name: o.name.trim(),
        priceDelta: o.priceDelta,
        isDefault: o.isDefault,
        isAvailable: o.isAvailable,
      ),
  ],
);

/// Buat ([id] `null`) atau ubah grup beserta opsinya. Opsi tanpa id dibuat,
/// opsi yang tidak ada lagi di [draft] dihapus lunak. Gagal dengan
/// [ModifierGroupInvalid] atau [MasterNotFound].
Future<ModifierGroup> saveModifierGroup(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  UuidValue? id,
  required ModifierGroupDraft draft,
}) => store.write(actor: staffId, (w) async {
  final tenant = scope.tenantId;
  final groups = await _groups(w.session, tenant, transaction: w.transaction);
  final current = id == null
      ? null
      : groups.where((g) => g.id == id).firstOrNull;
  if (id != null && current == null) throw MasterNotFound();
  final d = _clean(draft);
  final errors = validateModifierGroup(
    d,
    existingNames: [
      for (final g in groups)
        if (g.id != id) g.name,
    ],
  );
  if (errors.isNotEmpty) {
    throw ModifierGroupInvalid(errors, optionErrors: modifierOptionErrors(d));
  }
  final s = await w.stamp();
  final ModifierGroup group;
  if (current == null) {
    group = await w.insert(
      ModifierGroup(
        tenantId: tenant,
        name: d.name,
        minSelect: d.minSelect,
        maxSelect: d.maxSelect,
        sortOrder:
            groups.fold<int>(-1, (m, g) => g.sortOrder > m ? g.sortOrder : m) +
            1,
        createdAt: s.now,
        updatedAt: s.now,
        createdBy: staffId,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  } else {
    group = await w.update(
      current.copyWith(
        name: d.name,
        minSelect: d.minSelect,
        maxSelect: d.maxSelect,
        version: current.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  }
  final old = current == null
      ? const <ModifierOption>[]
      : await _options(w.session, tenant, [
          current.id,
        ], transaction: w.transaction);
  final byId = {for (final o in old) o.id.uuid: o};
  final kept = <String>{};
  for (final (i, o) in d.options.indexed) {
    final prev = o.id == null ? null : byId[o.id];
    if (prev == null) {
      await w.insert(
        ModifierOption(
          tenantId: tenant,
          modifierGroupId: group.id,
          name: o.name,
          priceDelta: o.priceDelta.value,
          isDefault: o.isDefault,
          isAvailable: o.isAvailable,
          sortOrder: i,
          createdAt: s.now,
          updatedAt: s.now,
          createdBy: staffId,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
      continue;
    }
    kept.add(prev.id.uuid);
    if (prev.name == o.name &&
        prev.priceDelta == o.priceDelta.value &&
        prev.isDefault == o.isDefault &&
        prev.isAvailable == o.isAvailable &&
        prev.sortOrder == i) {
      continue;
    }
    await w.update(
      prev.copyWith(
        name: o.name,
        priceDelta: o.priceDelta.value,
        isDefault: o.isDefault,
        isAvailable: o.isAvailable,
        sortOrder: i,
        version: prev.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  }
  for (final o in old) {
    if (kept.contains(o.id.uuid)) continue;
    await w.update(
      o.copyWith(
        deletedAt: s.now,
        version: o.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  }
  return group;
});

/// Pindahkan grup [id] [delta] posisi lalu nomori ulang 0..n.
Future<void> moveModifierGroup(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue id,
  required int delta,
}) => store.write(actor: staffId, (w) async {
  final groups = await _groups(
    w.session,
    scope.tenantId,
    transaction: w.transaction,
  );
  final index = groups.indexWhere((g) => g.id == id);
  if (index < 0) throw MasterNotFound();
  final ordered = moveInOrder(groups, index, delta);
  for (var i = 0; i < ordered.length; i++) {
    final row = ordered[i];
    if (row.sortOrder == i) continue;
    final s = await w.stamp();
    await w.update(
      row.copyWith(
        sortOrder: i,
        version: row.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  }
});

/// Hapus lunak grup [id] beserta opsinya. Ditolak ([MasterInUse]) bila
/// masih dipasang di menu.
Future<void> deleteModifierGroup(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue id,
}) => store.write(actor: staffId, (w) async {
  final tenant = scope.tenantId;
  final group = (await _groups(
    w.session,
    tenant,
    transaction: w.transaction,
  )).where((g) => g.id == id).firstOrNull;
  if (group == null) throw MasterNotFound();
  final used = (await productModifierLinks(
    w.session,
    tenant,
    transaction: w.transaction,
  )).where((l) => l.modifierGroupId == id).length;
  if (used > 0) throw MasterInUse(products: used);
  final s = await w.stamp();
  for (final o in await _options(w.session, tenant, [
    id,
  ], transaction: w.transaction)) {
    await w.update(
      o.copyWith(
        deletedAt: s.now,
        version: o.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  }
  await w.update(
    group.copyWith(
      deletedAt: s.now,
      version: group.version + 1,
      updatedAt: s.now,
      updatedBy: staffId,
      hlc: s.hlc.toString(),
      originDeviceId: s.deviceId,
    ),
    s,
  );
});
