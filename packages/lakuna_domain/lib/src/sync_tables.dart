/// Daftar tabel yang disinkronkan ke server (F2-01) dan aturan dokumen
/// final. Dipakai bersama oleh server (penerap push) dan perangkat (mesin
/// sync), jadi urutan dan aturannya cukup ditulis sekali di sini.
library;

/// Cakupan baris: se-tenant atau per outlet (punya `outletId`).
enum SyncScope { tenant, outlet }

/// Jenis dokumen final (spec F2-01 aturan 7).
enum FinalKind {
  /// Nota penjualan: final setelah tidak `open`; status bergerak monoton.
  sale,

  /// Pembelian: final setelah `received`.
  purchase,

  /// Dokumen yang final sejak disisipkan; hanya kolom void yang boleh diisi.
  voidOnly,
}

/// Kolom sync yang selalu boleh berubah, juga pada dokumen final.
const Set<String> syncColumns = {
  'version',
  'updatedAt',
  'updatedBy',
  'hlc',
  'originDeviceId',
};

/// Aturan dokumen final: kapan baris dianggap final dan kolom isi mana yang
/// masih boleh berubah sesudahnya (nama field Dart, sama dengan kunci
/// payload sync). Kolom di [syncColumns] selalu boleh berubah.
class FinalStatusRule {
  const FinalStatusRule(this.kind, this.mutableColumns);

  final FinalKind kind;
  final Set<String> mutableColumns;

  /// Apakah [row] (payload/baris dengan kunci nama field Dart) sudah final.
  bool isFinal(Map<String, Object?> row) => switch (kind) {
    FinalKind.sale => row['status'] != 'open',
    FinalKind.purchase => row['status'] == 'received',
    FinalKind.voidOnly => true,
  };

  /// Status hasil gabung monoton, atau `null` bila jenis ini tanpa status.
  String? mergeStatus(String a, String b) => switch (kind) {
    FinalKind.sale => mergeSaleStatus(a, b),
    FinalKind.purchase => mergePurchaseStatus(a, b),
    FinalKind.voidOnly => null,
  };
}

/// Satu tabel sync. [parents] = tabel induk (FK) selain dirinya sendiri;
/// FK ke tabel yang sama ditulis di [selfParentColumn].
class SyncTable {
  const SyncTable(
    this.name, {
    required this.parents,
    this.scope = SyncScope.tenant,
    this.selfParentColumn,
    this.finalStatus,
  });

  final String name;
  final List<String> parents;
  final SyncScope scope;
  final String? selfParentColumn;
  final FinalStatusRule? finalStatus;
}

const _voidColumns = {'voidedAt', 'voidedBy', 'voidReason'};

const _o = SyncScope.outlet;

/// Semua tabel bisnis (`database: all`), induk lebih dulu. Tabel yang hanya
/// ada di perangkat (`sync_outbox`, `sync_state`, `local_preferences`,
/// `stock_levels`) tidak termasuk.
const List<SyncTable> syncTables = [
  SyncTable('tenants', parents: []),
  SyncTable('outlets', parents: ['tenants']),
  SyncTable('devices', parents: ['tenants', 'outlets'], scope: _o),
  SyncTable('staff_members', parents: ['tenants']),
  SyncTable('roles', parents: ['tenants']),
  SyncTable(
    'outlet_members',
    parents: ['tenants', 'outlets', 'staff_members'],
    scope: _o,
  ),
  SyncTable('stock_locations', parents: ['tenants', 'outlets'], scope: _o),
  SyncTable('settings', parents: ['tenants', 'outlets'], scope: _o),
  SyncTable(
    'staff_access_logs',
    parents: ['tenants', 'outlets', 'devices', 'staff_members'],
    scope: _o,
  ),
  SyncTable('media_files', parents: ['tenants', 'outlets'], scope: _o),
  SyncTable('units', parents: ['tenants']),
  SyncTable('categories', parents: ['tenants'], selfParentColumn: 'parentId'),
  SyncTable('customer_groups', parents: ['tenants']),
  SyncTable('customers', parents: ['tenants', 'customer_groups']),
  SyncTable('suppliers', parents: ['tenants']),
  SyncTable('expense_categories', parents: ['tenants']),
  SyncTable('modifier_groups', parents: ['tenants']),
  SyncTable('modifiers', parents: ['tenants', 'modifier_groups']),
  SyncTable(
    'products',
    parents: ['tenants', 'categories', 'units', 'media_files'],
  ),
  SyncTable('product_variants', parents: ['tenants', 'products']),
  SyncTable('product_units', parents: ['tenants', 'product_variants', 'units']),
  SyncTable(
    'price_tiers',
    parents: ['tenants', 'product_variants', 'customer_groups'],
  ),
  SyncTable(
    'product_modifier_groups',
    parents: ['tenants', 'products', 'modifier_groups'],
  ),
  SyncTable('shifts', parents: ['tenants', 'outlets'], scope: _o),
  SyncTable(
    'cash_sessions',
    parents: ['tenants', 'outlets', 'devices', 'staff_members', 'shifts'],
    scope: _o,
  ),
  SyncTable(
    'cash_movements',
    parents: ['tenants', 'outlets', 'cash_sessions'],
    scope: _o,
    finalStatus: FinalStatusRule(FinalKind.voidOnly, {}),
  ),
  SyncTable(
    'dining_areas',
    parents: ['tenants', 'outlets', 'media_files'],
    scope: _o,
  ),
  SyncTable(
    'dining_tables',
    parents: ['tenants', 'outlets', 'dining_areas'],
    scope: _o,
  ),
  SyncTable(
    'sales',
    parents: [
      'tenants',
      'outlets',
      'devices',
      'cash_sessions',
      'staff_members',
      'dining_tables',
      'customers',
    ],
    scope: _o,
    finalStatus: FinalStatusRule(FinalKind.sale, {'status', ..._voidColumns}),
  ),
  SyncTable(
    'kitchen_tickets',
    parents: ['tenants', 'outlets', 'devices', 'sales', 'staff_members'],
    scope: _o,
  ),
  SyncTable(
    'sale_items',
    parents: [
      'tenants',
      'sales',
      'product_variants',
      'product_units',
      'kitchen_tickets',
    ],
  ),
  SyncTable(
    'sale_item_modifiers',
    parents: ['tenants', 'sale_items', 'modifiers'],
  ),
  SyncTable('payments', parents: ['tenants', 'sales', 'cash_sessions']),
  SyncTable(
    'sale_returns',
    parents: [
      'tenants',
      'outlets',
      'devices',
      'cash_sessions',
      'sales',
      'staff_members',
    ],
    scope: _o,
  ),
  SyncTable(
    'sale_return_items',
    parents: ['tenants', 'sale_returns', 'sale_items'],
  ),
  SyncTable(
    'purchases',
    parents: [
      'tenants',
      'outlets',
      'devices',
      'stock_locations',
      'suppliers',
      'staff_members',
      'cash_sessions',
      'media_files',
    ],
    scope: _o,
    finalStatus: FinalStatusRule(FinalKind.purchase, {
      'status',
      'invoiceMediaId',
    }),
  ),
  SyncTable(
    'purchase_items',
    parents: ['tenants', 'purchases', 'product_variants', 'product_units'],
  ),
  SyncTable(
    'purchase_invoice_pages',
    parents: ['tenants', 'outlets', 'purchases', 'media_files'],
    scope: _o,
  ),
  SyncTable(
    'purchase_returns',
    parents: [
      'tenants',
      'outlets',
      'devices',
      'purchases',
      'staff_members',
      'cash_sessions',
    ],
    scope: _o,
  ),
  SyncTable(
    'purchase_return_items',
    parents: ['tenants', 'purchase_returns', 'purchase_items'],
  ),
  SyncTable(
    'debt_payments',
    parents: [
      'tenants',
      'outlets',
      'devices',
      'staff_members',
      'customers',
      'suppliers',
      'cash_sessions',
      'media_files',
      'cash_movements',
    ],
    scope: _o,
    finalStatus: FinalStatusRule(FinalKind.voidOnly, {
      ..._voidColumns,
      'voidCashMovementId',
    }),
  ),
  SyncTable(
    'debt_payment_allocations',
    parents: ['tenants', 'debt_payments', 'sales', 'purchases'],
  ),
  SyncTable(
    'expenses',
    parents: [
      'tenants',
      'outlets',
      'devices',
      'staff_members',
      'expense_categories',
      'cash_sessions',
      'cash_movements',
      'media_files',
    ],
    scope: _o,
    finalStatus: FinalStatusRule(FinalKind.voidOnly, {
      ..._voidColumns,
      'voidCashMovementId',
    }),
  ),
  SyncTable(
    'stock_adjustments',
    parents: ['tenants', 'outlets', 'stock_locations', 'staff_members'],
    scope: _o,
  ),
  SyncTable(
    'stock_adjustment_items',
    parents: ['tenants', 'stock_adjustments', 'product_variants'],
  ),
  SyncTable(
    'stock_movements',
    parents: ['tenants', 'outlets', 'stock_locations', 'product_variants'],
    scope: _o,
  ),
];

final Map<String, SyncTable> _byName = {for (final t in syncTables) t.name: t};

/// Tabel sync bernama [name], atau `null` bila bukan tabel sync.
SyncTable? syncTableByName(String name) => _byName[name];

const _saleRank = [
  'open',
  'completed',
  'partiallyReturned',
  'returned',
  'voided',
];

const _purchaseRank = ['draft', 'received'];

String _stronger(List<String> rank, String a, String b) =>
    rank.indexOf(a) >= rank.indexOf(b) ? a : b;

/// Gabung monoton dua status nota (aturan 7b):
/// `voided` > `returned` > `partiallyReturned` > `completed` > `open`.
String mergeSaleStatus(String a, String b) => _stronger(_saleRank, a, b);

/// Gabung monoton dua status pembelian: `received` > `draft`.
String mergePurchaseStatus(String a, String b) =>
    _stronger(_purchaseRank, a, b);
