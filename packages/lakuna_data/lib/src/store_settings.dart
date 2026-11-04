import 'dart:convert';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show DatabaseSession, Transaction;

import 'sales.dart' show NegativeStock;
import 'settings_scope.dart';
import 'stock.dart' show CatalogScope;
import 'store.dart';
import 'sync_tx.dart';

/// Pengaturan toko & cabang (F1-18 lanjutan): profil, aturan penjualan &
/// stok.

/// Kunci `settings` aturan *Penjualan & stok* (per cabang).
const salesRulesKey = 'sales.rules';

/// Nota ditolak karena stok produk akan minus sementara aturan cabang
/// melarang stok minus.
class SaleStockShort implements Exception {
  const SaleStockShort(this.items);

  /// Produk yang stoknya tidak cukup (stok setelah transaksi).
  final List<NegativeStock> items;

  @override
  String toString() => 'SaleStockShort(${items.map((i) => i.name).join(', ')})';
}

/// Isian profil toko atau cabang tidak sah.
class StoreProfileInvalid implements Exception {
  const StoreProfileInvalid({this.name, this.outlet = const {}});

  /// Galat nama usaha.
  final ProfileIssue? name;

  /// Galat isian cabang.
  final Map<OutletProfileField, ProfileIssue> outlet;

  @override
  String toString() => 'StoreProfileInvalid(name: $name, outlet: $outlet)';
}

/// Baris `settings` cabang [scope] untuk [key].
Future<Setting?> outletSettingRow(
  DatabaseSession session,
  CatalogScope scope,
  String key, {
  Transaction? transaction,
}) => Setting.db.findFirstRow(
  session,
  where: (t) =>
      t.tenantId.equals(scope.tenantId) &
      t.scopeKey.equals(settingScopeOutlet(scope.outletId)) &
      t.key.equals(key) &
      t.deletedAt.equals(null),
  transaction: transaction,
);

/// Menulis [valueJson] ke `settings` cabang [scope] (sisip atau ubah).
/// Tidak menulis apa pun bila nilainya sama.
Future<void> writeOutletSetting(
  SyncTx w,
  CatalogScope scope, {
  required String key,
  required String valueJson,
  required UuidValue staffId,
}) async {
  final current = await outletSettingRow(
    w.session,
    scope,
    key,
    transaction: w.transaction,
  );
  if (current?.valueJson == valueJson) return;
  final s = await w.stamp();
  if (current == null) {
    await w.insert(
      Setting(
        tenantId: scope.tenantId,
        outletId: scope.outletId,
        scopeKey: settingScopeOutlet(scope.outletId),
        key: key,
        valueJson: valueJson,
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
    await w.update(
      current.copyWith(
        valueJson: valueJson,
        version: current.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  }
}

/// Aturan *Penjualan & stok* cabang [scope] (bawaan bila belum diatur).
Future<SalesRules> loadSalesRules(
  DatabaseSession session,
  CatalogScope scope, {
  Transaction? transaction,
}) async {
  final row = await outletSettingRow(
    session,
    scope,
    salesRulesKey,
    transaction: transaction,
  );
  if (row == null) return const SalesRules();
  try {
    return SalesRules.fromJson(jsonDecode(row.valueJson));
  } on FormatException {
    return const SalesRules();
  }
}

/// Menyimpan aturan *Penjualan & stok* cabang [scope].
Future<SalesRules> saveSalesRules(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required SalesRules rules,
}) async {
  await store.write(
    actor: staffId,
    (w) => writeOutletSetting(
      w,
      scope,
      key: salesRulesKey,
      valueJson: jsonEncode(rules.toJson()),
      staffId: staffId,
    ),
  );
  return loadSalesRules(store.session, scope);
}

/// Menolak transaksi bila [negative] berisi stok minus sementara aturan
/// cabang melarangnya. Dipanggil di dalam transaksi tulis agar semua
/// perubahan dibatalkan.
Future<void> enforceStockRule(
  SyncTx w,
  CatalogScope scope,
  List<NegativeStock> negative,
) async {
  if (negative.isEmpty) return;
  final rules = await loadSalesRules(
    w.session,
    scope,
    transaction: w.transaction,
  );
  if (!rules.allowNegativeStock) throw SaleStockShort(negative);
}

/// Mengubah nama usaha (tenant).
Future<Tenant> saveStoreProfile(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required String name,
}) async {
  final issue = storeNameIssue(name);
  if (issue != null) throw StoreProfileInvalid(name: issue);
  return store.write(actor: staffId, (w) async {
    final tenant = (await Tenant.db.findById(
      w.session,
      scope.tenantId,
      transaction: w.transaction,
    ))!;
    final clean = name.trim();
    if (tenant.name == clean) return tenant;
    final s = await w.stamp();
    return w.update(
      tenant.copyWith(
        name: clean,
        version: tenant.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  });
}

/// Mengubah nama, alamat, dan telepon cabang [scope]. Kode cabang tidak
/// berubah (dipakai di nomor dokumen).
Future<Outlet> saveOutletProfile(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required String name,
  required String address,
  required String phone,
}) async {
  final issues = outletProfileIssues(
    name: name,
    address: address,
    phone: phone,
  );
  if (issues.isNotEmpty) throw StoreProfileInvalid(outlet: issues);
  String? opt(String v) => v.trim().isEmpty ? null : v.trim();
  return store.write(actor: staffId, (w) async {
    final outlet = (await Outlet.db.findById(
      w.session,
      scope.outletId,
      transaction: w.transaction,
    ))!;
    final next = (name.trim(), opt(address), opt(phone));
    if ((outlet.name, outlet.address, outlet.phone) == next) return outlet;
    final s = await w.stamp();
    return w.update(
      outlet.copyWith(
        name: next.$1,
        address: next.$2,
        phone: next.$3,
        version: outlet.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  });
}
