import 'package:characters/characters.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show ColumnOrderingOperations, DatabaseSession, Transaction;

import 'sale_core.dart' show requireOpenCashSession;
import 'staff_access.dart';
import 'stock.dart';
import 'stock_admin.dart' show StockLocationNotFound;
import 'store.dart';
import 'sync_tx.dart';

// --- Galat --------------------------------------------------------------------

/// Isian pembelian tidak sah; [issues] dari [validatePurchase] atau baris yang
/// tidak dikenal ([PurchaseField.lines] dengan indeks).
class PurchaseInvalid implements Exception {
  const PurchaseInvalid(this.issues);

  final List<PurchaseIssue> issues;

  @override
  String toString() => 'PurchaseInvalid($issues)';
}

/// Aktor bukan staf aktif cabang ini atau tidak punya [permission].
class PurchaseActorNotPermitted implements Exception {
  const PurchaseActorNotPermitted(this.permission);

  final Permission permission;

  @override
  String toString() => 'PurchaseActorNotPermitted(${permission.key})';
}

/// [staffId] staf aktif cabang ini dengan semua izin [needed].
Future<void> _requireActor(
  LakunaStore store,
  CatalogScope scope,
  UuidValue staffId,
  List<Permission> needed,
) async {
  final staff = await findStaffById(
    store,
    tenantId: scope.tenantId,
    outletId: scope.outletId,
    staffId: staffId,
  );
  for (final p in needed) {
    if (staff == null || !staff.permissions.contains(p)) {
      throw PurchaseActorNotPermitted(p);
    }
  }
}

/// Izin tulis pembelian: `purchases:manage`, ditambah
/// `cash_movements:create` bila uang keluar/masuk laci.
List<Permission> _needed({bool drawer = false}) => [
  Permission.purchasesManage,
  if (drawer) Permission.cashMovementsCreate,
];

class PurchaseNotFound implements Exception {
  @override
  String toString() => 'PurchaseNotFound';
}

/// Pembelian yang sudah diterima tidak bisa diubah atau dihapus.
class PurchaseNotEditable implements Exception {
  @override
  String toString() => 'PurchaseNotEditable';
}

enum PurchaseReturnError {
  /// Tidak ada baris dengan qty > 0.
  empty,

  /// Qty melebihi sisa baris, atau baris bukan milik pembelian ini.
  quantity,

  /// Stok di lokasi pembelian kurang.
  stock,

  /// Pembelian belum diterima.
  status,

  /// Ada uang kembali tetapi sumbernya belum dipilih.
  refundSource,

  /// Catatan terlalu panjang.
  note,
}

class PurchaseReturnInvalid implements Exception {
  const PurchaseReturnInvalid(this.error, {this.index});

  final PurchaseReturnError error;
  final int? index;

  @override
  String toString() => 'PurchaseReturnInvalid(${error.name}, $index)';
}

// --- Masukan ------------------------------------------------------------------

/// Baris pembelian: [quantity] dan [unitPrice] dalam satuan [productUnitId]
/// (atau satuan dasar bila `null`).
class PurchaseLineRequest {
  const PurchaseLineRequest({
    required this.variantId,
    required this.quantity,
    required this.unitPrice,
    this.productUnitId,
  });

  final UuidValue variantId;
  final UuidValue? productUnitId;
  final Qty quantity;
  final Money unitPrice;
}

/// Isi form pembelian. [id] = draf yang diubah atau diterima. Supplier dari
/// [supplierId], atau [newSupplierName] yang dibuat (atau dipakai ulang bila
/// namanya sudah ada).
class PurchaseRequest {
  const PurchaseRequest({
    this.id,
    this.supplierId,
    this.newSupplierName,
    this.invoiceNo,
    required this.purchasedOn,
    required this.locationId,
    required this.lines,
    this.discount = Money.zero,
    this.shipping = Money.zero,
    this.paid = Money.zero,
    this.funding,
    this.dueOn,
    this.note,
  });

  final UuidValue? id;
  final UuidValue? supplierId;
  final String? newSupplierName;
  final String? invoiceNo;

  /// Tanggal lokal pembelian (jam diabaikan).
  final DateTime purchasedOn;
  final UuidValue locationId;
  final List<PurchaseLineRequest> lines;
  final Money discount;
  final Money shipping;
  final Money paid;
  final FundingSource? funding;
  final DateTime? dueOn;
  final String? note;

  bool get hasSupplier =>
      supplierId != null || (newSupplierName?.trim().isNotEmpty ?? false);
}

class PurchaseReturnLine {
  const PurchaseReturnLine({
    required this.purchaseItemId,
    required this.quantity,
  });

  final UuidValue purchaseItemId;

  /// Dalam satuan baris pembelian.
  final Qty quantity;
}

FundingKind fundingKind(FundingSource s) => FundingKind.values.byName(s.name);

// --- Baca ---------------------------------------------------------------------

/// Supplier tenant, urut nama.
Future<List<Supplier>> listSuppliers(
  LakunaStore store,
  CatalogScope scope,
) async {
  final rows = await Supplier.db.find(
    store.session,
    where: (s) => s.tenantId.equals(scope.tenantId) & s.deletedAt.equals(null),
  );
  rows.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return rows;
}

/// Satu baris daftar pembelian (1.19).
class PurchaseRow {
  const PurchaseRow({
    required this.purchase,
    required this.supplierName,
    required this.returned,
    required this.debt,
  });

  final Purchase purchase;
  final String? supplierName;

  /// Total nilai retur beli.
  final Money returned;

  /// Sisa hutang (0 untuk draf).
  final Money debt;

  bool get isDraft => purchase.status == PurchaseStatus.draft;
}

/// Satu baris daftar retur pembelian.
class PurchaseReturnRow {
  const PurchaseReturnRow({
    required this.purchaseReturn,
    required this.purchaseNumber,
    required this.supplierName,
  });

  final PurchaseReturn purchaseReturn;
  final String purchaseNumber;
  final String? supplierName;
}

bool _matches(String query, Iterable<String?> fields) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  return fields.any((f) => f != null && f.toLowerCase().contains(q));
}

Future<Map<UuidValue, Supplier>> _suppliers(
  DatabaseSession session,
  UuidValue tenantId,
  Set<UuidValue> ids, {
  Transaction? transaction,
}) async {
  if (ids.isEmpty) return const {};
  final rows = await Supplier.db.find(
    session,
    where: (s) => s.tenantId.equals(tenantId) & s.id.inSet(ids),
    transaction: transaction,
  );
  return {for (final s in rows) s.id: s};
}

Future<List<PurchaseReturn>> _returnsOf(
  DatabaseSession session,
  UuidValue tenantId,
  Set<UuidValue> purchaseIds, {
  Transaction? transaction,
}) async {
  if (purchaseIds.isEmpty) return const [];
  return PurchaseReturn.db.find(
    session,
    where: (r) =>
        r.tenantId.equals(tenantId) &
        r.purchaseId.inSet(purchaseIds) &
        r.deletedAt.equals(null),
    orderByList: (r) => [r.returnedAt, r.id],
    transaction: transaction,
  );
}

Money _debtOf(Purchase p, Iterable<PurchaseReturn> returns) =>
    p.status == PurchaseStatus.draft
    ? Money.zero
    : purchaseDebt(
        total: Money(p.total),
        paid: Money(p.paidAmount),
        debtReduction: Money.sum(returns.map((r) => Money(r.debtReduction))),
      );

/// Pembelian cabang, terbaru dulu, disaring [query] (nomor, no. faktur, atau
/// nama supplier).
Future<List<PurchaseRow>> listPurchases(
  LakunaStore store,
  CatalogScope scope, {
  String query = '',
}) async {
  final session = store.session;
  final rows = await Purchase.db.find(
    session,
    where: (p) =>
        p.tenantId.equals(scope.tenantId) &
        p.outletId.equals(scope.outletId) &
        p.deletedAt.equals(null),
    orderByList: (p) => [p.purchasedOn.desc(), p.createdAt.desc()],
  );
  final suppliers = await _suppliers(session, scope.tenantId, {
    for (final p in rows)
      if (p.supplierId != null) p.supplierId!,
  });
  final returns = await _returnsOf(session, scope.tenantId, {
    for (final p in rows) p.id,
  });
  return [
    for (final p in rows)
      if (_matches(query, [
        p.number,
        p.invoiceNo,
        suppliers[p.supplierId]?.name,
      ]))
        () {
          final mine = returns.where((r) => r.purchaseId == p.id);
          return PurchaseRow(
            purchase: p,
            supplierName: suppliers[p.supplierId]?.name,
            returned: Money.sum(mine.map((r) => Money(r.amount))),
            debt: _debtOf(p, mine),
          );
        }(),
  ];
}

/// Retur pembelian cabang, terbaru dulu, disaring [query] (nomor RB, nomor
/// PB, atau supplier).
Future<List<PurchaseReturnRow>> listPurchaseReturns(
  LakunaStore store,
  CatalogScope scope, {
  String query = '',
}) async {
  final session = store.session;
  final rows = await PurchaseReturn.db.find(
    session,
    where: (r) =>
        r.tenantId.equals(scope.tenantId) &
        r.outletId.equals(scope.outletId) &
        r.deletedAt.equals(null),
    orderByList: (r) => [r.returnedAt.desc(), r.id.desc()],
  );
  final ids = {for (final r in rows) r.purchaseId};
  final purchases = ids.isEmpty
      ? const <UuidValue, Purchase>{}
      : {
          for (final p in await Purchase.db.find(
            session,
            where: (p) => p.tenantId.equals(scope.tenantId) & p.id.inSet(ids),
          ))
            p.id: p,
        };
  final suppliers = await _suppliers(session, scope.tenantId, {
    for (final p in purchases.values)
      if (p.supplierId != null) p.supplierId!,
  });
  return [
    for (final r in rows)
      if (purchases[r.purchaseId] case final p?)
        if (_matches(query, [
          r.number,
          p.number,
          suppliers[p.supplierId]?.name,
        ]))
          PurchaseReturnRow(
            purchaseReturn: r,
            purchaseNumber: p.number,
            supplierName: suppliers[p.supplierId]?.name,
          ),
  ];
}

/// Rincian pembelian (1.19b) atau isi draf untuk form.
class PurchaseDetail {
  const PurchaseDetail({
    required this.purchase,
    required this.items,
    required this.supplier,
    required this.staffName,
    required this.deviceCode,
    required this.locationName,
    required this.returns,
    required this.returnedMilli,
    required this.sellPrices,
    required this.skus,
    required this.baseUnits,
  });

  final Purchase purchase;
  final List<PurchaseItem> items;
  final Supplier? supplier;
  final String staffName;
  final String deviceCode;
  final String locationName;
  final List<PurchaseReturn> returns;

  /// Qty yang sudah diretur per baris, dalam satuan baris.
  final Map<UuidValue, int> returnedMilli;

  /// Harga jual varian saat ini (satuan dasar).
  final Map<UuidValue, Money> sellPrices;
  final Map<UuidValue, String?> skus;

  /// Nama satuan dasar per varian (untuk HPP "/btl").
  final Map<UuidValue, String> baseUnits;

  Money get returnedAmount => Money.sum(returns.map((r) => Money(r.amount)));
  Money get debtReduction =>
      Money.sum(returns.map((r) => Money(r.debtReduction)));
  Money get refunded => Money.sum(returns.map((r) => Money(r.refundAmount)));
  Money get debt => _debtOf(purchase, returns);
  bool get isDraft => purchase.status == PurchaseStatus.draft;

  int remainingMilli(PurchaseItem item) =>
      item.quantityMilli - (returnedMilli[item.id] ?? 0);

  /// Nilai mendarat baris (dasar retur).
  Money landedTotal(PurchaseItem item) => _landedTotal(purchase, items, item);
}

Money _landedTotal(Purchase p, List<PurchaseItem> items, PurchaseItem item) {
  final totals = purchaseTotals(
    [
      for (final i in items)
        PurchaseLineInput(
          quantity: Qty(i.quantityMilli),
          unitPrice: Money(i.unitPrice),
          factorMilli: i.factorMilli,
        ),
    ],
    discount: Money(p.discount),
    shipping: Money(p.shipping),
  );
  return totals.landedTotals[items.indexOf(item)];
}

Future<Purchase> _purchase(
  DatabaseSession session,
  CatalogScope scope,
  UuidValue id, {
  Transaction? transaction,
}) async {
  final p = await Purchase.db.findById(session, id, transaction: transaction);
  if (p == null ||
      p.tenantId != scope.tenantId ||
      p.outletId != scope.outletId ||
      p.deletedAt != null) {
    throw PurchaseNotFound();
  }
  return p;
}

Future<List<PurchaseItem>> _items(
  DatabaseSession session,
  UuidValue tenantId,
  UuidValue purchaseId, {
  Transaction? transaction,
}) => PurchaseItem.db.find(
  session,
  where: (i) =>
      i.tenantId.equals(tenantId) &
      i.purchaseId.equals(purchaseId) &
      i.deletedAt.equals(null),
  orderByList: (i) => [i.sortOrder, i.id],
  transaction: transaction,
);

Future<Map<UuidValue, int>> _returnedMilliOf(
  DatabaseSession session,
  UuidValue tenantId,
  List<PurchaseReturn> returns, {
  Transaction? transaction,
}) async {
  if (returns.isEmpty) return const {};
  final rows = await PurchaseReturnItem.db.find(
    session,
    where: (i) =>
        i.tenantId.equals(tenantId) &
        i.purchaseReturnId.inSet({for (final r in returns) r.id}) &
        i.deletedAt.equals(null),
    transaction: transaction,
  );
  final out = <UuidValue, int>{};
  for (final r in rows) {
    out[r.purchaseItemId] = (out[r.purchaseItemId] ?? 0) + r.quantityMilli;
  }
  return out;
}

/// Rincian pembelian [id]; [PurchaseNotFound] bila bukan milik cabang ini.
Future<PurchaseDetail> loadPurchaseDetail(
  LakunaStore store,
  CatalogScope scope,
  UuidValue id,
) async {
  final session = store.session;
  final p = await _purchase(session, scope, id);
  final items = await _items(session, scope.tenantId, p.id);
  final returns = await _returnsOf(session, scope.tenantId, {p.id});
  final variantIds = {for (final i in items) i.variantId};
  final variants = variantIds.isEmpty
      ? const <ProductVariant>[]
      : await ProductVariant.db.find(
          session,
          where: (v) => v.id.inSet(variantIds),
        );
  final products = variants.isEmpty
      ? const <Product>[]
      : await Product.db.find(
          session,
          where: (pr) => pr.id.inSet({for (final v in variants) v.productId}),
        );
  final units = products.isEmpty
      ? const <MeasureUnit>[]
      : await MeasureUnit.db.find(
          session,
          where: (u) => u.id.inSet({for (final pr in products) pr.baseUnitId}),
        );
  final productById = {for (final pr in products) pr.id: pr};
  final unitById = {for (final u in units) u.id: u.name};
  final supplier = p.supplierId == null
      ? null
      : (await _suppliers(session, scope.tenantId, {
          p.supplierId!,
        }))[p.supplierId];
  final staff = await StaffMember.db.findById(session, p.staffId);
  final device = await Device.db.findById(session, p.deviceId);
  final location = await StockLocation.db.findById(session, p.stockLocationId);
  return PurchaseDetail(
    purchase: p,
    items: items,
    supplier: supplier,
    staffName: staff?.name ?? '',
    deviceCode: device?.code ?? '',
    locationName: location?.name ?? '',
    returns: returns,
    returnedMilli: await _returnedMilliOf(session, scope.tenantId, returns),
    sellPrices: {for (final v in variants) v.id: Money(v.sellPrice)},
    skus: {for (final v in variants) v.id: v.sku},
    baseUnits: {
      for (final v in variants)
        v.id: unitById[productById[v.productId]?.baseUnitId] ?? '',
    },
  );
}

// --- Tulis --------------------------------------------------------------------

Future<String> _nextNumber(
  SyncTx w,
  CatalogScope scope,
  DateTime now, {
  required bool isReturn,
}) => _number(w.session, w.transaction, scope, now, isReturn: isReturn);

/// Nomor PB berikutnya untuk judul form (belum dipesan; nomor final dibuat
/// saat simpan).
Future<String> previewPurchaseNumber(
  LakunaStore store,
  CatalogScope scope, {
  required DateTime now,
}) => _number(store.session, null, scope, now, isReturn: false);

Future<String> _number(
  DatabaseSession session,
  Transaction? transaction,
  CatalogScope scope,
  DateTime now, {
  required bool isReturn,
}) async {
  final outlet = await Outlet.db.findById(
    session,
    scope.outletId,
    transaction: transaction,
  );
  final device = await Device.db.findById(
    session,
    scope.deviceId,
    transaction: transaction,
  );
  final tenant = await Tenant.db.findById(
    session,
    scope.tenantId,
    transaction: transaction,
  );
  if (outlet == null || device == null) {
    throw StateError('Cabang/perangkat ${scope.outletId} tidak ditemukan.');
  }
  final local = outletLocalTime(now, outlet.timezone ?? tenant?.timezone);
  final code = isReturn ? 'RB' : 'PB';
  final prefix = '$code-${receiptPrefix(outlet.code, device.code, local)}';
  final existing = isReturn
      ? (await PurchaseReturn.db.find(
          session,
          where: (r) =>
              r.tenantId.equals(scope.tenantId) & r.number.like('$prefix%'),
          transaction: transaction,
        )).map((r) => r.number)
      : (await Purchase.db.find(
          session,
          where: (p) =>
              p.tenantId.equals(scope.tenantId) & p.number.like('$prefix%'),
          transaction: transaction,
        )).map((p) => p.number);
  final counter = nextReceiptCounter(existing, prefix);
  return isReturn
      ? purchaseReturnNumber(outlet.code, device.code, local, counter)
      : purchaseNumber(outlet.code, device.code, local, counter);
}

/// Baris yang sudah dicocokkan dengan katalog.
class _ResolvedLine {
  _ResolvedLine(
    this.request,
    this.variant,
    this.product,
    this.unitName, {
    this.unit,
  });

  final PurchaseLineRequest request;
  final ProductVariant variant;
  final Product product;
  final ProductUnit? unit;
  final String unitName;

  int get factorMilli => unit?.factorMilli ?? 1000;
}

Future<List<_ResolvedLine>> _resolveLines(
  SyncTx w,
  CatalogScope scope,
  List<PurchaseLineRequest> lines, {
  required bool receiving,
}) async {
  final seen = <(UuidValue, UuidValue?)>{};
  final out = <_ResolvedLine>[];
  for (final (i, l) in lines.indexed) {
    final variant = await ProductVariant.db.findById(
      w.session,
      l.variantId,
      transaction: w.transaction,
    );
    final product = variant == null
        ? null
        : await Product.db.findById(
            w.session,
            variant.productId,
            transaction: w.transaction,
          );
    final unit = l.productUnitId == null
        ? null
        : await ProductUnit.db.findById(
            w.session,
            l.productUnitId!,
            transaction: w.transaction,
          );
    final badUnit =
        l.productUnitId != null &&
        (unit == null ||
            unit.variantId != l.variantId ||
            unit.deletedAt != null);
    if (variant == null ||
        product == null ||
        variant.tenantId != scope.tenantId ||
        variant.deletedAt != null ||
        // Draf boleh menyimpan produk yang kemudian dinonaktifkan, tetapi
        // yang diterima hanya produk aktif yang melacak stok.
        (receiving &&
            (!product.isActive ||
                product.deletedAt != null ||
                !ProductKind.values.byName(product.type.name).tracksStock)) ||
        badUnit ||
        !seen.add((l.variantId, l.productUnitId))) {
      throw PurchaseInvalid([PurchaseIssue(PurchaseField.lines, i)]);
    }
    final unitId = unit?.unitId ?? product.baseUnitId;
    final measure = await MeasureUnit.db.findById(
      w.session,
      unitId,
      transaction: w.transaction,
    );
    out.add(
      _ResolvedLine(l, variant, product, measure?.name ?? '', unit: unit),
    );
  }
  return out;
}

Future<UuidValue?> _resolveSupplier(
  SyncTx w,
  CatalogScope scope,
  PurchaseRequest r,
  SyncStamp s,
  UuidValue staffId,
) async {
  if (r.supplierId case final id?) {
    final found = await Supplier.db.findById(
      w.session,
      id,
      transaction: w.transaction,
    );
    if (found == null ||
        found.tenantId != scope.tenantId ||
        found.deletedAt != null) {
      throw const PurchaseInvalid([PurchaseIssue(PurchaseField.supplier)]);
    }
    return found.id;
  }
  final name = r.newSupplierName?.trim() ?? '';
  if (name.isEmpty) return null;
  if (name.characters.length > PurchaseLimits.supplierName) {
    throw const PurchaseInvalid([PurchaseIssue(PurchaseField.supplier)]);
  }
  final all = await Supplier.db.find(
    w.session,
    where: (x) => x.tenantId.equals(scope.tenantId) & x.deletedAt.equals(null),
    transaction: w.transaction,
  );
  final same = all
      .where((x) => x.name.toLowerCase() == name.toLowerCase())
      .firstOrNull;
  if (same != null) return same.id;
  final created = await w.insert(
    Supplier(
      tenantId: scope.tenantId,
      name: name,
      createdAt: s.now,
      updatedAt: s.now,
      createdBy: staffId,
      updatedBy: staffId,
      hlc: s.hlc.toString(),
      originDeviceId: s.deviceId,
    ),
    s,
  );
  return created.id;
}

void _validate(PurchaseRequest r, {required bool receiving}) {
  final issues = validatePurchase(
    lines: [
      for (final l in r.lines)
        PurchaseLineInput(quantity: l.quantity, unitPrice: l.unitPrice),
    ],
    discount: r.discount,
    shipping: r.shipping,
    paid: r.paid,
    funding: r.funding == null ? null : fundingKind(r.funding!),
    hasSupplier: r.hasSupplier,
    purchasedOn: r.purchasedOn,
    dueOn: r.dueOn,
    invoiceNo: r.invoiceNo,
    note: r.note,
    receiving: receiving,
  );
  if (issues.isNotEmpty) throw PurchaseInvalid(issues);
}

String? _text(String? s) {
  final t = s?.trim();
  return t == null || t.isEmpty ? null : t;
}

DateTime _date(DateTime d) => DateTime.utc(d.year, d.month, d.day);

/// Menulis dokumen dan barisnya (draf baru, ubah draf, atau terima). Baris
/// lama draf dihapus lunak dan ditulis ulang.
Future<(Purchase, List<PurchaseItem>)> _writePurchase(
  LakunaStore store,
  SyncTx w,
  CatalogScope scope,
  PurchaseRequest r, {
  required UuidValue staffId,
  required bool receiving,
}) async {
  final s = await w.stamp();
  Purchase? existing;
  if (r.id case final id?) {
    existing = await _purchase(
      w.session,
      scope,
      id,
      transaction: w.transaction,
    );
    if (existing.status != PurchaseStatus.draft) throw PurchaseNotEditable();
  }
  final location = await StockLocation.db.findById(
    w.session,
    r.locationId,
    transaction: w.transaction,
  );
  if (location == null ||
      location.tenantId != scope.tenantId ||
      location.outletId != scope.outletId ||
      location.deletedAt != null) {
    throw StockLocationNotFound();
  }
  final lines = await _resolveLines(w, scope, r.lines, receiving: receiving);
  final supplierId = await _resolveSupplier(w, scope, r, s, staffId);
  final totals = purchaseTotals(
    [
      for (final l in lines)
        PurchaseLineInput(
          quantity: l.request.quantity,
          unitPrice: l.request.unitPrice,
          factorMilli: l.factorMilli,
        ),
    ],
    discount: r.discount,
    shipping: r.shipping,
  );
  final cash =
      receiving && r.paid.value > 0 && r.funding == FundingSource.drawer
      ? await requireOpenCashSession(store, w, scope)
      : null;
  final number =
      existing?.number ?? await _nextNumber(w, scope, s.now, isReturn: false);
  final debt = receiving && totals.total > r.paid;
  final fields = (
    supplierId: supplierId,
    invoiceNo: _text(r.invoiceNo),
    purchasedOn: _date(r.purchasedOn),
    stockLocationId: location.id,
    subtotal: totals.subtotal.value,
    discount: r.discount.value,
    shipping: r.shipping.value,
    total: totals.total.value,
    paidAmount: r.paid.value,
    fundingSource: r.paid.value > 0 ? r.funding : null,
    dueOn: r.dueOn == null || (receiving && !debt) ? null : _date(r.dueOn!),
    note: _text(r.note),
  );
  final status = receiving ? PurchaseStatus.received : PurchaseStatus.draft;
  final Purchase doc;
  if (existing == null) {
    doc = await w.insert(
      Purchase(
        tenantId: scope.tenantId,
        outletId: scope.outletId,
        deviceId: scope.deviceId,
        stockLocationId: fields.stockLocationId,
        supplierId: fields.supplierId,
        staffId: staffId,
        cashSessionId: cash?.id,
        number: number,
        invoiceNo: fields.invoiceNo,
        status: status,
        purchasedOn: fields.purchasedOn,
        subtotal: fields.subtotal,
        discount: fields.discount,
        shipping: fields.shipping,
        total: fields.total,
        paidAmount: fields.paidAmount,
        fundingSource: fields.fundingSource,
        dueOn: fields.dueOn,
        note: fields.note,
        receivedAt: receiving ? s.now : null,
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
    doc = await w.update(
      existing.copyWith(
        stockLocationId: fields.stockLocationId,
        supplierId: fields.supplierId,
        staffId: receiving ? staffId : existing.staffId,
        cashSessionId: cash?.id,
        invoiceNo: fields.invoiceNo,
        status: status,
        purchasedOn: fields.purchasedOn,
        subtotal: fields.subtotal,
        discount: fields.discount,
        shipping: fields.shipping,
        total: fields.total,
        paidAmount: fields.paidAmount,
        fundingSource: fields.fundingSource,
        dueOn: fields.dueOn,
        note: fields.note,
        receivedAt: receiving ? s.now : null,
        version: existing.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
    for (final old in await _items(
      w.session,
      scope.tenantId,
      existing.id,
      transaction: w.transaction,
    )) {
      await w.update(
        old.copyWith(
          deletedAt: s.now,
          version: old.version + 1,
          updatedAt: s.now,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    }
  }

  final items = <PurchaseItem>[];
  for (final (i, l) in lines.indexed) {
    int? before;
    int? after;
    int? sellBefore;
    if (receiving) {
      sellBefore = l.variant.sellPrice;
      final tracks = ProductKind.values.byName(l.product.type.name).tracksStock;
      if (tracks) {
        before = (await _level(w, doc.stockLocationId, l.variant.id))?.avgCost;
        await recordStockMovement(
          w,
          scope,
          locationId: doc.stockLocationId,
          variantId: l.variant.id,
          quantity: totals.baseQuantities[i],
          unitCost: totals.landedUnitCosts[i],
          sourceType: StockSourceType.purchase,
          sourceId: doc.id,
          note: doc.number,
          stamp: s,
        );
        after = (await _level(w, doc.stockLocationId, l.variant.id))?.avgCost;
      }
      // HPP master = harga pokok mendarat terakhir (satuan dasar).
      final fresh = await ProductVariant.db.findById(
        w.session,
        l.variant.id,
        transaction: w.transaction,
      );
      if (fresh != null && fresh.costPrice != totals.landedUnitCosts[i].value) {
        await w.update(
          fresh.copyWith(
            costPrice: totals.landedUnitCosts[i].value,
            version: fresh.version + 1,
            updatedAt: s.now,
            updatedBy: staffId,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
      }
    }
    items.add(
      await w.insert(
        PurchaseItem(
          tenantId: scope.tenantId,
          purchaseId: doc.id,
          variantId: l.variant.id,
          productUnitId: l.unit?.id,
          productName: l.product.name,
          variantName: l.variant.name,
          unitName: l.unitName,
          factorMilli: l.factorMilli,
          quantityMilli: l.request.quantity.milli,
          unitPrice: l.request.unitPrice.value,
          lineTotal: totals.lineTotals[i].value,
          landedUnitCost: totals.landedUnitCosts[i].value,
          avgCostBefore: before,
          avgCostAfter: after,
          sellPriceBefore: sellBefore,
          sortOrder: i,
          createdAt: s.now,
          updatedAt: s.now,
          createdBy: staffId,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      ),
    );
  }

  if (cash != null) {
    await w.insert(
      CashMovement(
        tenantId: scope.tenantId,
        outletId: scope.outletId,
        cashSessionId: cash.id,
        direction: CashDirection.outflow,
        amount: r.paid.value,
        note: doc.number,
        source: purchaseCashSource,
        createdAt: s.now,
        updatedAt: s.now,
        createdBy: staffId,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  }
  return (doc, items);
}

/// `cash_movements.source` untuk bayar pembelian dan uang kembali retur beli.
const purchaseCashSource = 'purchase';

Future<StockLevel?> _level(
  SyncTx w,
  UuidValue locationId,
  UuidValue variantId,
) => StockLevel.db.findFirstRow(
  w.session,
  where: (l) =>
      l.stockLocationId.equals(locationId) & l.variantId.equals(variantId),
  transaction: w.transaction,
);

/// Menyimpan draf baru atau mengubah draf [PurchaseRequest.id]. Draf tidak
/// menggerakkan stok, kas, atau hutang.
Future<Purchase> savePurchaseDraft(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required PurchaseRequest request,
}) async {
  _validate(request, receiving: false);
  await _requireActor(store, scope, staffId, _needed());
  return store.write(actor: staffId, (w) async {
    final (doc, _) = await _writePurchase(
      store,
      w,
      scope,
      request,
      staffId: staffId,
      receiving: false,
    );
    return doc;
  });
}

/// Terima barang: dokumen final, stok masuk di lokasi (ledger + HPP
/// rata-rata), `cost_price` varian, bayar dari laci (sesi terbuka wajib).
Future<Purchase> receivePurchase(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required PurchaseRequest request,
}) async {
  _validate(request, receiving: true);
  await _requireActor(
    store,
    scope,
    staffId,
    _needed(
      drawer: request.paid.value > 0 && request.funding == FundingSource.drawer,
    ),
  );
  return store.write(actor: staffId, (w) async {
    final (doc, _) = await _writePurchase(
      store,
      w,
      scope,
      request,
      staffId: staffId,
      receiving: true,
    );
    return doc;
  });
}

/// Menghapus (lunak) draf [purchaseId] beserta barisnya.
Future<void> deletePurchaseDraft(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue purchaseId,
}) async {
  await _requireActor(store, scope, staffId, _needed());
  await store.write(actor: staffId, (w) async {
    final p = await _purchase(
      w.session,
      scope,
      purchaseId,
      transaction: w.transaction,
    );
    if (p.status != PurchaseStatus.draft) throw PurchaseNotEditable();
    final s = await w.stamp();
    for (final i in await _items(
      w.session,
      scope.tenantId,
      p.id,
      transaction: w.transaction,
    )) {
      await w.update(
        i.copyWith(
          deletedAt: s.now,
          version: i.version + 1,
          updatedAt: s.now,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    }
    await w.update(
      p.copyWith(
        deletedAt: s.now,
        version: p.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  });
}

/// Retur pembelian `RB-`: stok keluar dari lokasi pembelian dengan HPP baris,
/// nilai mengurangi hutang dulu, kelebihannya uang kembali ke
/// [refundSource] (laci → `cash_movements` masuk, butuh sesi terbuka).
Future<PurchaseReturn> returnPurchase(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue purchaseId,
  required List<PurchaseReturnLine> lines,
  String? note,
  FundingSource? refundSource,
}) async {
  final text = _text(note);
  if ((text?.characters.length ?? 0) > PurchaseLimits.note) {
    throw const PurchaseReturnInvalid(PurchaseReturnError.note);
  }
  await _requireActor(
    store,
    scope,
    staffId,
    _needed(drawer: refundSource == FundingSource.drawer),
  );
  if (!lines.any((l) => l.quantity.milli > 0)) {
    throw const PurchaseReturnInvalid(PurchaseReturnError.empty);
  }
  return store.write(actor: staffId, (w) async {
    final p = await _purchase(
      w.session,
      scope,
      purchaseId,
      transaction: w.transaction,
    );
    if (p.status != PurchaseStatus.received) {
      throw const PurchaseReturnInvalid(PurchaseReturnError.status);
    }
    final items = await _items(
      w.session,
      scope.tenantId,
      p.id,
      transaction: w.transaction,
    );
    final byId = {for (final i in items) i.id: i};
    final previous = await _returnsOf(w.session, scope.tenantId, {
      p.id,
    }, transaction: w.transaction);
    final returned = Map.of(
      await _returnedMilliOf(
        w.session,
        scope.tenantId,
        previous,
        transaction: w.transaction,
      ),
    );
    final picked = <(PurchaseItem, int, Money, int)>[];
    final needBase = <UuidValue, int>{};
    for (final (k, line) in lines.indexed) {
      final milli = line.quantity.milli;
      if (milli == 0) continue;
      final item = byId[line.purchaseItemId];
      final before = item == null ? 0 : returned[item.id] ?? 0;
      if (item == null || milli < 0 || before + milli > item.quantityMilli) {
        throw PurchaseReturnInvalid(PurchaseReturnError.quantity, index: k);
      }
      final base = Qty(milli).toBaseUnit(item.factorMilli).milli;
      needBase[item.variantId] = (needBase[item.variantId] ?? 0) + base;
      final level = await _level(w, p.stockLocationId, item.variantId);
      if ((level?.quantityMilli ?? 0) < needBase[item.variantId]!) {
        throw PurchaseReturnInvalid(PurchaseReturnError.stock, index: k);
      }
      picked.add((
        item,
        milli,
        returnAmount(
          share: _landedTotal(p, items, item),
          soldMilli: item.quantityMilli,
          returnedMilli: before,
          returningMilli: milli,
        ),
        base,
      ));
      returned[item.id] = before + milli;
    }
    final amount = Money.sum(picked.map((x) => x.$3));
    final debt = _debtOf(p, previous);
    final split = purchaseReturnSplit(amount: amount, debt: debt);
    if (split.refund.value > 0 && refundSource == null) {
      throw const PurchaseReturnInvalid(PurchaseReturnError.refundSource);
    }
    final cash = split.refund.value > 0 && refundSource == FundingSource.drawer
        ? await requireOpenCashSession(store, w, scope)
        : null;

    final s = await w.stamp();
    final doc = await w.insert(
      PurchaseReturn(
        tenantId: scope.tenantId,
        outletId: scope.outletId,
        deviceId: scope.deviceId,
        purchaseId: p.id,
        staffId: staffId,
        cashSessionId: cash?.id,
        number: await _nextNumber(w, scope, s.now, isReturn: true),
        amount: amount.value,
        debtReduction: split.debtReduction.value,
        refundAmount: split.refund.value,
        refundSource: split.refund.value > 0 ? refundSource : null,
        note: text,
        returnedAt: s.now,
        createdAt: s.now,
        updatedAt: s.now,
        createdBy: staffId,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
    for (final (item, milli, value, base) in picked) {
      await w.insert(
        PurchaseReturnItem(
          tenantId: scope.tenantId,
          purchaseReturnId: doc.id,
          purchaseItemId: item.id,
          quantityMilli: milli,
          amount: value.value,
          createdAt: s.now,
          updatedAt: s.now,
          createdBy: staffId,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
      await recordStockMovement(
        w,
        scope,
        locationId: p.stockLocationId,
        variantId: item.variantId,
        quantity: Qty(-base),
        unitCost: Money(item.landedUnitCost),
        sourceType: StockSourceType.purchaseReturn,
        sourceId: doc.id,
        note: doc.number,
        stamp: s,
      );
    }
    if (cash != null) {
      await w.insert(
        CashMovement(
          tenantId: scope.tenantId,
          outletId: scope.outletId,
          cashSessionId: cash.id,
          direction: CashDirection.inflow,
          amount: split.refund.value,
          note: doc.number,
          source: purchaseCashSource,
          createdAt: s.now,
          updatedAt: s.now,
          createdBy: staffId,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    }
    return doc;
  });
}

/// Mengubah harga jual (satuan dasar) varian [prices] lewat outbox.
Future<void> applySellPrices(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required Map<UuidValue, Money> prices,
}) async {
  if (prices.values.any((p) => p.isNegative)) {
    throw ArgumentError.value(prices, 'prices', 'tidak boleh negatif');
  }
  if (prices.isEmpty) return;
  // Harga jual milik master produk: butuh izin produk juga.
  await _requireActor(store, scope, staffId, [
    Permission.purchasesManage,
    Permission.productsManage,
  ]);
  await store.write(actor: staffId, (w) async {
    final s = await w.stamp();
    for (final MapEntry(key: id, value: price) in prices.entries) {
      final v = await ProductVariant.db.findById(
        w.session,
        id,
        transaction: w.transaction,
      );
      if (v == null || v.tenantId != scope.tenantId || v.deletedAt != null) {
        throw const PurchaseInvalid([PurchaseIssue(PurchaseField.price)]);
      }
      if (v.sellPrice == price.value) continue;
      await w.update(
        v.copyWith(
          sellPrice: price.value,
          version: v.version + 1,
          updatedAt: s.now,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    }
  });
}
