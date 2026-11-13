import 'dart:typed_data';

import 'package:characters/characters.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show ColumnOrderingOperations, DatabaseSession, Transaction;

import 'customers.dart' show outletToday;
import 'media.dart';
import 'purchases.dart';
import 'sale_core.dart' show requireOpenCashSession;
import 'staff_access.dart';
import 'stock.dart';
import 'store.dart';
import 'sync_tx.dart';

// Supplier & hutang (F1-14, layar 1.21). Hutang tidak pernah disimpan
// sebagai saldo: selalu dihitung dari pembelian, pembayaran di muka,
// alokasi pembayaran hutang, dan retur beli yang memotong hutang.

// --- Galat --------------------------------------------------------------------

/// Aktor bukan staf aktif cabang ini atau tidak punya [permission].
class SupplierActorNotPermitted implements Exception {
  const SupplierActorNotPermitted(this.permission);

  final Permission permission;

  @override
  String toString() => 'SupplierActorNotPermitted(${permission.key})';
}

class SupplierInvalid implements Exception {
  const SupplierInvalid(this.issues);

  final Set<SupplierIssue> issues;

  @override
  String toString() => 'SupplierInvalid($issues)';
}

/// Nama supplier sudah dipakai (tanpa membedakan huruf besar/kecil).
class SupplierNameTaken implements Exception {
  @override
  String toString() => 'SupplierNameTaken';
}

class SupplierNotFound implements Exception {
  @override
  String toString() => 'SupplierNotFound';
}

/// Supplier masih punya hutang, jadi tidak bisa dihapus.
class SupplierHasDebt implements Exception {
  @override
  String toString() => 'SupplierHasDebt';
}

class SupplierPaymentInvalid implements Exception {
  const SupplierPaymentInvalid(this.issue);

  final DebtPaymentIssue issue;

  @override
  String toString() => 'SupplierPaymentInvalid($issue)';
}

/// Tanggal bayar di masa depan.
class SupplierPaymentDateInvalid implements Exception {
  @override
  String toString() => 'SupplierPaymentDateInvalid';
}

/// Bayar dari kas laci hanya untuk tanggal hari ini.
class SupplierPaymentDrawerDate implements Exception {
  @override
  String toString() => 'SupplierPaymentDrawerDate';
}

/// Catatan atau no. bukti terlalu panjang.
class SupplierPaymentTextInvalid implements Exception {
  @override
  String toString() => 'SupplierPaymentTextInvalid';
}

/// Foto bukti bukan PNG/JPG/WebP atau lebih dari batas.
class SupplierPaymentProofInvalid implements Exception {
  @override
  String toString() => 'SupplierPaymentProofInvalid';
}

/// [staffId] staf aktif cabang ini dengan semua izin [needed].
Future<void> requireSupplierActor(
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
      throw SupplierActorNotPermitted(p);
    }
  }
}

DateTime _date(DateTime d) => DateTime.utc(d.year, d.month, d.day);

String? _text(String? s) {
  final t = s?.trim();
  return t == null || t.isEmpty ? null : t;
}

// --- Hutang per pembelian -----------------------------------------------------

/// Pembelian yang masih berhutang.
class PayablePurchase {
  const PayablePurchase({
    required this.purchase,
    required this.outstanding,
    required this.overdue,
  });

  final Purchase purchase;
  final Money outstanding;
  final bool overdue;

  PayableOrder get order => PayableOrder(
    dueOn: purchase.dueOn,
    purchasedOn: purchase.purchasedOn,
    number: purchase.number,
  );
}

/// Pembelian berhutang per supplier, urut jatuh tempo terdekat dulu.
Future<Map<UuidValue, List<PayablePurchase>>> _payables(
  DatabaseSession session,
  UuidValue tenantId,
  DateTime today, {
  UuidValue? supplierId,
  Transaction? transaction,
}) async {
  final purchases = await Purchase.db.find(
    session,
    where: (p) =>
        p.tenantId.equals(tenantId) &
        (supplierId == null
            ? p.supplierId.notEquals(null)
            : p.supplierId.equals(supplierId)) &
        p.status.equals(PurchaseStatus.received) &
        p.deletedAt.equals(null),
    transaction: transaction,
  );
  final candidates = [
    for (final p in purchases)
      if (p.paidAmount < p.total) p,
  ];
  final ids = [for (final p in candidates) p.id];
  final returns = await purchaseReturnsOf(
    session,
    tenantId,
    ids,
    transaction: transaction,
  );
  final paid = await purchaseDebtPaidOf(
    session,
    tenantId,
    ids,
    transaction: transaction,
  );
  final result = <UuidValue, List<PayablePurchase>>{};
  for (final p in candidates) {
    final rest = purchaseDebtOf(
      p,
      returns[p.id] ?? const <PurchaseReturn>[],
      allocated: paid[p.id] ?? Money.zero,
    );
    if (rest <= Money.zero) continue;
    result
        .putIfAbsent(p.supplierId!, () => [])
        .add(
          PayablePurchase(
            purchase: p,
            outstanding: rest,
            overdue: isOverdue(p.dueOn, today),
          ),
        );
  }
  for (final list in result.values) {
    list.sort((a, b) => a.order.compareTo(b.order));
  }
  return result;
}

// --- Supplier -----------------------------------------------------------------

/// Satu baris daftar supplier (1.21).
class SupplierRow {
  const SupplierRow({
    required this.supplier,
    required this.debt,
    required this.openCount,
    required this.overdueCount,
    required this.nearestDue,
  });

  final Supplier supplier;
  final Money debt;
  final int openCount;
  final int overdueCount;

  /// Jatuh tempo terdekat pembelian yang masih berhutang.
  final DateTime? nearestDue;
}

class SuppliersOverview {
  const SuppliersOverview({required this.rows, required this.today});

  /// Urut nama.
  final List<SupplierRow> rows;

  /// Tanggal hari ini di cabang (UTC tengah malam).
  final DateTime today;

  Money get totalDebt => Money.sum(rows.map((r) => r.debt));

  /// Supplier yang masih dihutangi.
  int get creditorCount => rows.where((r) => r.debt > Money.zero).length;

  /// Pembelian terlambat.
  int get overdueCount => rows.fold(0, (sum, r) => sum + r.overdueCount);

  DateTime? get nearestDue {
    DateTime? best;
    for (final r in rows) {
      final d = r.nearestDue;
      if (d != null && (best == null || d.isBefore(best))) best = d;
    }
    return best;
  }
}

SupplierRow _row(Supplier s, List<PayablePurchase> open) {
  DateTime? nearest;
  for (final p in open) {
    final d = p.purchase.dueOn;
    if (d != null && (nearest == null || d.isBefore(nearest))) nearest = d;
  }
  return SupplierRow(
    supplier: s,
    debt: Money.sum(open.map((p) => p.outstanding)),
    openCount: open.length,
    overdueCount: open.where((p) => p.overdue).length,
    nearestDue: nearest,
  );
}

Future<List<Supplier>> _activeSuppliers(
  DatabaseSession session,
  UuidValue tenantId, {
  Transaction? transaction,
}) => Supplier.db.find(
  session,
  where: (s) => s.tenantId.equals(tenantId) & s.deletedAt.equals(null),
  transaction: transaction,
);

/// Supplier tenant dengan hutangnya, urut nama.
Future<SuppliersOverview> loadSuppliersOverview(
  LakunaStore store,
  CatalogScope scope, {
  DateTime? now,
}) async {
  final session = store.session;
  final today = await outletToday(
    session,
    scope,
    now ?? DateTime.now().toUtc(),
  );
  final suppliers = await _activeSuppliers(session, scope.tenantId);
  final open = await _payables(session, scope.tenantId, today);
  suppliers.sort(
    (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
  );
  return SuppliersOverview(
    today: today,
    rows: [for (final s in suppliers) _row(s, open[s.id] ?? const [])],
  );
}

/// Rincian supplier untuk panel 1.21.
class SupplierDetail {
  const SupplierDetail({
    required this.row,
    required this.open,
    required this.payments,
    required this.today,
  });

  final SupplierRow row;

  /// Pembelian berhutang, jatuh tempo terdekat dulu.
  final List<PayablePurchase> open;

  /// Pembayaran hutang, terbaru dulu.
  final List<DebtPayment> payments;
  final DateTime today;

  Supplier get supplier => row.supplier;
}

Future<Supplier> _supplier(
  DatabaseSession session,
  CatalogScope scope,
  UuidValue id, {
  Transaction? transaction,
}) async {
  final s = await Supplier.db.findById(session, id, transaction: transaction);
  if (s == null || s.tenantId != scope.tenantId || s.deletedAt != null) {
    throw SupplierNotFound();
  }
  return s;
}

Future<SupplierDetail> loadSupplierDetail(
  LakunaStore store,
  CatalogScope scope,
  UuidValue supplierId, {
  DateTime? now,
}) async {
  final session = store.session;
  final today = await outletToday(
    session,
    scope,
    now ?? DateTime.now().toUtc(),
  );
  final s = await _supplier(session, scope, supplierId);
  final open =
      (await _payables(
        session,
        scope.tenantId,
        today,
        supplierId: s.id,
      ))[s.id] ??
      const <PayablePurchase>[];
  final payments = await DebtPayment.db.find(
    session,
    where: (p) =>
        p.tenantId.equals(scope.tenantId) &
        p.supplierId.equals(s.id) &
        p.deletedAt.equals(null),
    orderByList: (p) => [p.createdAt.desc(), p.number.desc()],
  );
  return SupplierDetail(
    row: _row(s, open),
    open: open,
    payments: payments,
    today: today,
  );
}

/// Pembelian diterima dari supplier [supplierId] di cabang ini, terbaru
/// dulu. Dibatasi cabang agar setiap baris bisa dibuka di layar Pembelian
/// (yang juga per cabang); hutang tetap dihitung se-tenant.
Future<List<PurchaseRow>> listSupplierPurchases(
  LakunaStore store,
  CatalogScope scope,
  UuidValue supplierId,
) async {
  final session = store.session;
  final s = await Supplier.db.findById(session, supplierId);
  if (s == null || s.tenantId != scope.tenantId) throw SupplierNotFound();
  final purchases = await Purchase.db.find(
    session,
    where: (p) =>
        p.tenantId.equals(scope.tenantId) &
        p.outletId.equals(scope.outletId) &
        p.supplierId.equals(supplierId) &
        p.status.equals(PurchaseStatus.received) &
        p.deletedAt.equals(null),
    orderByList: (p) => [p.purchasedOn.desc(), p.number.desc()],
  );
  return purchaseRowsOf(
    session,
    scope.tenantId,
    purchases,
    suppliers: {s.id: s},
  );
}

/// Isian form supplier.
class SupplierInput {
  const SupplierInput({
    this.id,
    required this.name,
    this.phone,
    this.contactName,
    this.category,
    this.address,
    this.note,
    this.termDays = SupplierLimits.defaultTermDays,
  });

  final UuidValue? id;
  final String name;
  final String? phone;
  final String? contactName;
  final String? category;
  final String? address;
  final String? note;
  final int termDays;
}

/// Menambah atau mengubah supplier ([SupplierInput.id]).
Future<Supplier> saveSupplier(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required SupplierInput input,
}) async {
  final issues = validateSupplier(
    name: input.name,
    termDays: input.termDays,
    phone: input.phone,
    contactName: input.contactName,
    category: input.category,
    address: input.address,
    note: input.note,
  );
  if (issues.isNotEmpty) throw SupplierInvalid(issues);
  await requireSupplierActor(store, scope, staffId, [
    Permission.suppliersManage,
  ]);
  final name = input.name.trim();
  final phone = normalizePhone(input.phone ?? '');
  return store.write(actor: staffId, (w) async {
    final all = await _activeSuppliers(
      w.session,
      scope.tenantId,
      transaction: w.transaction,
    );
    if (all.any(
      (s) => s.id != input.id && s.name.toLowerCase() == name.toLowerCase(),
    )) {
      throw SupplierNameTaken();
    }
    final s = await w.stamp();
    final fields = (
      name: name,
      phone: phone.isEmpty ? null : phone,
      contactName: _text(input.contactName),
      category: _text(input.category),
      address: _text(input.address),
      note: _text(input.note),
      termDays: input.termDays,
    );
    if (input.id case final id?) {
      final old = await _supplier(
        w.session,
        scope,
        id,
        transaction: w.transaction,
      );
      return w.update(
        old.copyWith(
          name: fields.name,
          phone: fields.phone,
          contactName: fields.contactName,
          category: fields.category,
          address: fields.address,
          note: fields.note,
          termDays: fields.termDays,
          version: old.version + 1,
          updatedAt: s.now,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    }
    return w.insert(
      Supplier(
        tenantId: scope.tenantId,
        name: fields.name,
        phone: fields.phone,
        contactName: fields.contactName,
        category: fields.category,
        address: fields.address,
        note: fields.note,
        termDays: fields.termDays,
        createdAt: s.now,
        updatedAt: s.now,
        createdBy: staffId,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  });
}

class SupplierImportSummary {
  const SupplierImportSummary({required this.created, required this.updated});

  final int created;
  final int updated;
}

/// Import supplier (F1-14b). Kunci = nama tanpa beda huruf: nama yang sudah
/// ada memperbarui kolom yang terisi saja, nama baru dibuat dengan tempo
/// standar bila tempo kosong. Semua baris dalam satu transaksi.
Future<SupplierImportSummary> importSuppliers(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required List<SupplierImportRow> rows,
}) async {
  await requireSupplierActor(store, scope, staffId, [
    Permission.suppliersManage,
  ]);
  // Baris dari luar aplikasi diperiksa ulang, sama dengan `saveSupplier`;
  // satu baris salah membatalkan seluruh import.
  for (final r in rows) {
    final issues = validateSupplier(
      name: r.name,
      termDays: r.termDays ?? SupplierLimits.defaultTermDays,
      phone: r.phone,
      contactName: r.contactName,
      category: r.category,
      address: r.address,
      note: r.note,
    );
    final phone = r.phone == null ? null : normalizePhone(r.phone!);
    if (phone != null && phone.isEmpty) {
      throw const SupplierInvalid({SupplierIssue.phone});
    }
    if (issues.isNotEmpty) throw SupplierInvalid(issues);
  }
  return store.write(actor: staffId, (w) async {
    final s = await w.stamp();
    final byName = {
      for (final x in await _activeSuppliers(
        w.session,
        scope.tenantId,
        transaction: w.transaction,
      ))
        x.name.toLowerCase(): x,
    };
    var created = 0;
    var updated = 0;
    for (final r in rows) {
      final name = r.name.trim();
      final phone = r.phone == null ? null : normalizePhone(r.phone!);
      final key = name.toLowerCase();
      final old = byName[key];
      if (old != null) {
        final next = old.copyWith(
          phone: phone ?? old.phone,
          contactName: _text(r.contactName) ?? old.contactName,
          category: _text(r.category) ?? old.category,
          address: _text(r.address) ?? old.address,
          note: _text(r.note) ?? old.note,
          termDays: r.termDays ?? old.termDays,
        );
        updated++;
        // Import ulang berkas yang sama tidak menulis (dan menyinkronkan)
        // baris yang tidak berubah.
        if (next.phone == old.phone &&
            next.contactName == old.contactName &&
            next.category == old.category &&
            next.address == old.address &&
            next.note == old.note &&
            next.termDays == old.termDays) {
          continue;
        }
        byName[key] = await w.update(
          next.copyWith(
            version: old.version + 1,
            updatedAt: s.now,
            updatedBy: staffId,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
      } else {
        byName[key] = await w.insert(
          Supplier(
            tenantId: scope.tenantId,
            name: name,
            phone: phone,
            contactName: _text(r.contactName),
            category: _text(r.category),
            address: _text(r.address),
            note: _text(r.note),
            termDays: r.termDays ?? SupplierLimits.defaultTermDays,
            createdAt: s.now,
            updatedAt: s.now,
            createdBy: staffId,
            updatedBy: staffId,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
        created++;
      }
    }
    return SupplierImportSummary(created: created, updated: updated);
  });
}

/// Menghapus (soft delete) supplier tanpa hutang.
Future<void> deleteSupplier(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue supplierId,
}) async {
  await requireSupplierActor(store, scope, staffId, [
    Permission.suppliersManage,
  ]);
  await store.write(actor: staffId, (w) async {
    final supplier = await _supplier(
      w.session,
      scope,
      supplierId,
      transaction: w.transaction,
    );
    final open = await _payables(
      w.session,
      scope.tenantId,
      DateTime.utc(1970),
      supplierId: supplier.id,
      transaction: w.transaction,
    );
    if ((open[supplier.id] ?? const []).isNotEmpty) throw SupplierHasDebt();
    final s = await w.stamp();
    await w.update(
      supplier.copyWith(
        deletedAt: s.now,
        version: supplier.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  });
}

// --- Bayar hutang ---------------------------------------------------------------

/// `cash_movements.source` untuk bayar hutang supplier dari laci.
const supplierPaymentCashSource = 'supplier_payment';

/// Foto bukti bayar yang dipilih pengguna.
class SupplierPaymentProof {
  const SupplierPaymentProof({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

class SupplierPaymentRequest {
  const SupplierPaymentRequest({
    required this.supplierId,
    required this.amount,
    required this.funding,
    required this.paidOn,
    this.allocations,
    this.reference,
    this.note,
    this.proof,
  });

  final UuidValue supplierId;
  final Money amount;
  final FundingSource funding;

  /// Tanggal bayar (kalender).
  final DateTime paidOn;

  /// Alokasi manual per pembelian; `null` = otomatis jatuh tempo terdekat.
  final Map<UuidValue, Money>? allocations;

  /// No. bukti transfer.
  final String? reference;
  final String? note;
  final SupplierPaymentProof? proof;
}

Future<String> _nextPaymentNumber(
  SyncTx w,
  CatalogScope scope,
  DateTime now,
) async {
  final outlet = await Outlet.db.findById(
    w.session,
    scope.outletId,
    transaction: w.transaction,
  );
  final device = await Device.db.findById(
    w.session,
    scope.deviceId,
    transaction: w.transaction,
  );
  final tenant = await Tenant.db.findById(
    w.session,
    scope.tenantId,
    transaction: w.transaction,
  );
  if (outlet == null || device == null) {
    throw StateError('Cabang/perangkat ${scope.outletId} tidak ditemukan.');
  }
  final local = outletLocalTime(now, outlet.timezone ?? tenant?.timezone);
  final prefix = 'BH-${receiptPrefix(outlet.code, device.code, local)}';
  final existing = await DebtPayment.db.find(
    w.session,
    where: (p) => p.tenantId.equals(scope.tenantId) & p.number.like('$prefix%'),
    transaction: w.transaction,
  );
  final counter = nextReceiptCounter(existing.map((p) => p.number), prefix);
  return supplierPaymentNumber(outlet.code, device.code, local, counter);
}

/// Membayar hutang supplier dalam satu transaksi: dokumen `BH-`, alokasi
/// per pembelian, foto bukti, dan kas keluar bila dari laci.
Future<DebtPayment> paySupplierDebt(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required SupplierPaymentRequest request,
}) async {
  final note = _text(request.note);
  final reference = _text(request.reference);
  if ((note?.characters.length ?? 0) > SupplierLimits.paymentNote ||
      (reference?.characters.length ?? 0) > SupplierLimits.reference) {
    throw SupplierPaymentTextInvalid();
  }
  final drawer = request.funding == FundingSource.drawer;
  await requireSupplierActor(store, scope, staffId, [
    Permission.debtsManage,
    if (drawer) Permission.cashMovementsCreate,
  ]);
  final proof = request.proof;
  final header = proof == null ? null : readImageHeader(proof.bytes);
  if (proof != null &&
      (header == null || proof.bytes.length > SupplierLimits.proofMaxBytes)) {
    throw SupplierPaymentProofInvalid();
  }
  return store.write(actor: staffId, (w) async {
    final s = await w.stamp();
    final today = await outletToday(
      w.session,
      scope,
      s.now,
      transaction: w.transaction,
    );
    final paidOn = _date(request.paidOn);
    if (paidOn.isAfter(today)) throw SupplierPaymentDateInvalid();
    if (drawer && paidOn != today) throw SupplierPaymentDrawerDate();
    final supplier = await _supplier(
      w.session,
      scope,
      request.supplierId,
      transaction: w.transaction,
    );
    final open =
        (await _payables(
          w.session,
          scope.tenantId,
          today,
          supplierId: supplier.id,
          transaction: w.transaction,
        ))[supplier.id] ??
        const <PayablePurchase>[];
    final payables = [
      for (final p in open)
        OpenReceivable(id: p.purchase.id, outstanding: p.outstanding),
    ];
    final issue = validateDebtPayment(
      request.amount,
      payables,
      manual: request.allocations,
    );
    if (issue != null) throw SupplierPaymentInvalid(issue);
    final allocations =
        request.allocations ?? allocateOldestFirst(request.amount, payables);
    final total = Money.sum(open.map((p) => p.outstanding));
    final cash = drawer ? await requireOpenCashSession(store, w, scope) : null;
    final media = proof == null
        ? null
        : await storeMediaFile(
            w,
            store,
            scope,
            bytes: proof.bytes,
            header: header!,
            fileName: proof.fileName,
            kind: MediaKind.paymentProof,
            stamp: s,
            outletId: scope.outletId,
          );
    final number = await _nextPaymentNumber(w, scope, s.now);
    final payment = await w.insert(
      DebtPayment(
        tenantId: scope.tenantId,
        outletId: scope.outletId,
        deviceId: scope.deviceId,
        staffId: staffId,
        party: DebtParty.supplier,
        supplierId: supplier.id,
        number: number,
        amount: request.amount.value,
        fundingSource: request.funding,
        paidOn: paidOn,
        cashSessionId: cash?.id,
        balanceAfter: (total - request.amount).value,
        reference: reference,
        proofMediaId: media?.id,
        note: note,
        createdAt: s.now,
        updatedAt: s.now,
        createdBy: staffId,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
    for (final p in open) {
      final amount = allocations[p.purchase.id];
      if (amount == null || amount <= Money.zero) continue;
      await w.insert(
        DebtPaymentAllocation(
          tenantId: scope.tenantId,
          debtPaymentId: payment.id,
          documentType: DebtDocumentType.purchase,
          purchaseId: p.purchase.id,
          amount: amount.value,
          balanceBefore: p.outstanding.value,
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
    if (cash != null) {
      await w.insert(
        CashMovement(
          tenantId: scope.tenantId,
          outletId: scope.outletId,
          cashSessionId: cash.id,
          direction: CashDirection.outflow,
          amount: request.amount.value,
          note: 'Bayar hutang $number · ${supplier.name}',
          source: supplierPaymentCashSource,
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
    return payment;
  });
}

/// Isi foto bukti pembayaran [paymentId]; `null` bila tidak ada atau
/// berkasnya belum ada di perangkat ini.
Future<Uint8List?> loadSupplierPaymentProof(
  LakunaStore store,
  CatalogScope scope,
  UuidValue paymentId,
) async {
  final session = store.session;
  final payment = await DebtPayment.db.findById(session, paymentId);
  if (payment == null ||
      payment.tenantId != scope.tenantId ||
      payment.proofMediaId == null) {
    return null;
  }
  final media = await MediaFile.db.findById(session, payment.proofMediaId!);
  return media == null ? null : readMediaFile(store, media);
}
