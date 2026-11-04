import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show DatabaseSession, Transaction;

import 'customers.dart' show outletToday;
import 'media.dart';
import 'sale_core.dart' show requireOpenCashSession;
import 'staff_access.dart';
import 'stock.dart';
import 'store.dart';
import 'sync_tx.dart';

// Pengeluaran operasional (F1-15, layar 1.22). Dokumen `EX-` per outlet;
// dari kas laci menulis kas keluar di sesi kasir terbuka. Koreksi = batal
// (dengan jejak) lalu catat baru.

// --- Galat --------------------------------------------------------------------

/// Aktor bukan staf aktif cabang ini atau tidak punya [permission].
class ExpenseActorNotPermitted implements Exception {
  const ExpenseActorNotPermitted(this.permission);

  final Permission permission;

  @override
  String toString() => 'ExpenseActorNotPermitted(${permission.key})';
}

class ExpenseInvalid implements Exception {
  const ExpenseInvalid(this.issues);

  final Set<ExpenseIssue> issues;

  @override
  String toString() => 'ExpenseInvalid($issues)';
}

/// Tanggal pengeluaran di masa depan.
class ExpenseDateInvalid implements Exception {
  @override
  String toString() => 'ExpenseDateInvalid';
}

/// Pengeluaran dari kas laci harus bertanggal hari ini.
class ExpenseDrawerDate implements Exception {
  @override
  String toString() => 'ExpenseDrawerDate';
}

/// Foto nota bukan gambar sah atau terlalu besar.
class ExpenseReceiptInvalid implements Exception {
  @override
  String toString() => 'ExpenseReceiptInvalid';
}

class ExpenseNotFound implements Exception {
  @override
  String toString() => 'ExpenseNotFound';
}

class ExpenseAlreadyVoided implements Exception {
  @override
  String toString() => 'ExpenseAlreadyVoided';
}

class ExpenseVoidReasonInvalid implements Exception {
  @override
  String toString() => 'ExpenseVoidReasonInvalid';
}

class ExpenseCategoryInvalid implements Exception {
  @override
  String toString() => 'ExpenseCategoryInvalid';
}

/// Nama jenis sudah dipakai (tanpa membedakan huruf besar/kecil).
class ExpenseCategoryNameTaken implements Exception {
  @override
  String toString() => 'ExpenseCategoryNameTaken';
}

class ExpenseCategoryNotFound implements Exception {
  @override
  String toString() => 'ExpenseCategoryNotFound';
}

/// Jenis sudah dipakai pengeluaran, jadi tidak bisa dihapus.
class ExpenseCategoryInUse implements Exception {
  @override
  String toString() => 'ExpenseCategoryInUse';
}

/// `cash_movements.source` pengeluaran dari laci.
const expenseCashSource = 'expense';

/// `cash_movements.source` pengembalian ke laci saat pengeluaran dibatalkan.
const expenseVoidCashSource = 'expense_void';

Future<void> requireExpenseActor(
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
      throw ExpenseActorNotPermitted(p);
    }
  }
}

DateTime _date(DateTime d) => DateTime.utc(d.year, d.month, d.day);

// --- Jenis pengeluaran --------------------------------------------------------

/// Jenis pengeluaran aktif dengan jumlah pengeluaran yang memakainya.
class ExpenseCategoryRow {
  const ExpenseCategoryRow({required this.category, required this.usage});

  final ExpenseCategory category;

  /// Jumlah pengeluaran (termasuk yang batal) yang memakai jenis ini.
  final int usage;
}

Future<List<ExpenseCategory>> _activeCategories(
  DatabaseSession session,
  UuidValue tenantId, {
  Transaction? transaction,
}) async {
  final rows = await ExpenseCategory.db.find(
    session,
    where: (c) => c.tenantId.equals(tenantId) & c.deletedAt.equals(null),
    transaction: transaction,
  );
  rows.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return rows;
}

/// Membuat jenis bawaan sekali per tenant (bila tenant belum pernah punya
/// jenis apa pun, termasuk yang sudah dihapus).
Future<void> ensureExpenseCategories(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
}) async {
  final any = await ExpenseCategory.db.findFirstRow(
    store.session,
    where: (c) => c.tenantId.equals(scope.tenantId),
  );
  if (any != null) return;
  await requireExpenseActor(store, scope, staffId, [Permission.expensesManage]);
  await store.write(actor: staffId, (w) async {
    final again = await ExpenseCategory.db.findFirstRow(
      w.session,
      where: (c) => c.tenantId.equals(scope.tenantId),
      transaction: w.transaction,
    );
    if (again != null) return;
    final s = await w.stamp();
    for (final name in defaultExpenseCategories) {
      await w.insert(
        ExpenseCategory(
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
    }
  });
}

/// Jenis pengeluaran aktif, urut nama, dengan jumlah pemakaian.
Future<List<ExpenseCategoryRow>> listExpenseCategories(
  LakunaStore store,
  CatalogScope scope,
) async {
  final session = store.session;
  final categories = await _activeCategories(session, scope.tenantId);
  final expenses = await Expense.db.find(
    session,
    where: (e) => e.tenantId.equals(scope.tenantId) & e.deletedAt.equals(null),
  );
  final usage = <UuidValue, int>{};
  for (final e in expenses) {
    usage[e.expenseCategoryId] = (usage[e.expenseCategoryId] ?? 0) + 1;
  }
  return [
    for (final c in categories)
      ExpenseCategoryRow(category: c, usage: usage[c.id] ?? 0),
  ];
}

Future<ExpenseCategory> _category(
  DatabaseSession session,
  CatalogScope scope,
  UuidValue id, {
  Transaction? transaction,
}) async {
  final c = await ExpenseCategory.db.findById(
    session,
    id,
    transaction: transaction,
  );
  if (c == null || c.tenantId != scope.tenantId || c.deletedAt != null) {
    throw ExpenseCategoryNotFound();
  }
  return c;
}

/// Menambah ([id] `null`) atau mengganti nama jenis pengeluaran.
Future<ExpenseCategory> saveExpenseCategory(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  UuidValue? id,
  required String name,
}) async {
  if (!validateExpenseCategoryName(name)) throw ExpenseCategoryInvalid();
  await requireExpenseActor(store, scope, staffId, [Permission.expensesManage]);
  final clean = name.trim();
  return store.write(actor: staffId, (w) async {
    final all = await _activeCategories(
      w.session,
      scope.tenantId,
      transaction: w.transaction,
    );
    if (all.any(
      (c) => c.id != id && c.name.toLowerCase() == clean.toLowerCase(),
    )) {
      throw ExpenseCategoryNameTaken();
    }
    final s = await w.stamp();
    if (id != null) {
      final old = await _category(
        w.session,
        scope,
        id,
        transaction: w.transaction,
      );
      return w.update(
        old.copyWith(
          name: clean,
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
      ExpenseCategory(
        tenantId: scope.tenantId,
        name: clean,
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

/// Menghapus (soft delete) jenis yang belum dipakai pengeluaran mana pun.
Future<void> deleteExpenseCategory(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue categoryId,
}) async {
  await requireExpenseActor(store, scope, staffId, [Permission.expensesManage]);
  await store.write(actor: staffId, (w) async {
    final c = await _category(
      w.session,
      scope,
      categoryId,
      transaction: w.transaction,
    );
    final used = await Expense.db.findFirstRow(
      w.session,
      where: (e) =>
          e.tenantId.equals(scope.tenantId) &
          e.expenseCategoryId.equals(c.id) &
          e.deletedAt.equals(null),
      transaction: w.transaction,
    );
    if (used != null) throw ExpenseCategoryInUse();
    final s = await w.stamp();
    await w.update(
      c.copyWith(
        deletedAt: s.now,
        version: c.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  });
}

// --- Catat pengeluaran --------------------------------------------------------

/// Foto nota yang dipilih pengguna.
class ExpenseReceipt {
  const ExpenseReceipt({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

class ExpenseRequest {
  const ExpenseRequest({
    required this.description,
    required this.categoryId,
    required this.amount,
    required this.funding,
    required this.spentOn,
    this.receipt,
  });

  final String description;
  final UuidValue? categoryId;
  final Money amount;
  final FundingSource funding;

  /// Tanggal pengeluaran (kalender).
  final DateTime spentOn;
  final ExpenseReceipt? receipt;
}

Future<String> _nextExpenseNumber(
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
  final prefix = 'EX-${receiptPrefix(outlet.code, device.code, local)}';
  final existing = await Expense.db.find(
    w.session,
    where: (e) => e.tenantId.equals(scope.tenantId) & e.number.like('$prefix%'),
    transaction: w.transaction,
  );
  final counter = nextReceiptCounter(existing.map((e) => e.number), prefix);
  return expenseNumber(outlet.code, device.code, local, counter);
}

/// Mencatat pengeluaran dalam satu transaksi: dokumen `EX-`, foto nota, dan
/// kas keluar bila dari laci.
Future<Expense> recordExpense(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required ExpenseRequest request,
}) async {
  final issues = validateExpense(
    description: request.description,
    hasCategory: request.categoryId != null,
    amount: request.amount,
  );
  if (issues.isNotEmpty) throw ExpenseInvalid(issues);
  final drawer = request.funding == FundingSource.drawer;
  await requireExpenseActor(store, scope, staffId, [
    Permission.expensesManage,
    if (drawer) Permission.cashMovementsCreate,
  ]);
  final receipt = request.receipt;
  final header = receipt == null ? null : readImageHeader(receipt.bytes);
  if (receipt != null &&
      (header == null ||
          receipt.bytes.length > ExpenseLimits.receiptMaxBytes)) {
    throw ExpenseReceiptInvalid();
  }
  final description = request.description.trim();
  return store.write(actor: staffId, (w) async {
    final s = await w.stamp();
    final today = await outletToday(
      w.session,
      scope,
      s.now,
      transaction: w.transaction,
    );
    final spentOn = _date(request.spentOn);
    if (spentOn.isAfter(today)) throw ExpenseDateInvalid();
    if (drawer && spentOn != today) throw ExpenseDrawerDate();
    final category = await _category(
      w.session,
      scope,
      request.categoryId!,
      transaction: w.transaction,
    );
    final cash = drawer ? await requireOpenCashSession(store, w, scope) : null;
    final media = receipt == null
        ? null
        : await storeMediaFile(
            w,
            store,
            scope,
            bytes: receipt.bytes,
            header: header!,
            fileName: receipt.fileName,
            kind: MediaKind.expenseReceipt,
            stamp: s,
            outletId: scope.outletId,
          );
    final movement = cash == null
        ? null
        : await w.insert(
            CashMovement(
              tenantId: scope.tenantId,
              outletId: scope.outletId,
              cashSessionId: cash.id,
              direction: CashDirection.outflow,
              amount: request.amount.value,
              note: description,
              source: expenseCashSource,
              createdAt: s.now,
              updatedAt: s.now,
              createdBy: staffId,
              updatedBy: staffId,
              hlc: s.hlc.toString(),
              originDeviceId: s.deviceId,
            ),
            s,
          );
    final number = await _nextExpenseNumber(w, scope, s.now);
    return w.insert(
      Expense(
        tenantId: scope.tenantId,
        outletId: scope.outletId,
        deviceId: scope.deviceId,
        staffId: staffId,
        expenseCategoryId: category.id,
        number: number,
        spentOn: spentOn,
        description: description,
        amount: request.amount.value,
        fundingSource: request.funding,
        cashSessionId: cash?.id,
        cashMovementId: movement?.id,
        receiptMediaId: media?.id,
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

/// Membatalkan pengeluaran dengan [reason]. Pengeluaran laci mengembalikan
/// uang ke laci di sesi kasir yang sedang buka di perangkat ini.
Future<Expense> voidExpense(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue expenseId,
  required String reason,
}) async {
  if (!validateExpenseVoidReason(reason)) throw ExpenseVoidReasonInvalid();
  final existing = await Expense.db.findById(store.session, expenseId);
  final drawer = existing?.fundingSource == FundingSource.drawer;
  await requireExpenseActor(store, scope, staffId, [
    Permission.expensesManage,
    if (drawer) Permission.cashMovementsCreate,
  ]);
  return store.write(actor: staffId, (w) async {
    final e = await Expense.db.findById(
      w.session,
      expenseId,
      transaction: w.transaction,
    );
    if (e == null ||
        e.tenantId != scope.tenantId ||
        e.outletId != scope.outletId ||
        e.deletedAt != null) {
      throw ExpenseNotFound();
    }
    if (e.voidedAt != null) throw ExpenseAlreadyVoided();
    final s = await w.stamp();
    final cash = e.fundingSource == FundingSource.drawer
        ? await requireOpenCashSession(store, w, scope)
        : null;
    final movement = cash == null
        ? null
        : await w.insert(
            CashMovement(
              tenantId: scope.tenantId,
              outletId: scope.outletId,
              cashSessionId: cash.id,
              direction: CashDirection.inflow,
              amount: e.amount,
              note: 'Batal ${e.number} · ${e.description}',
              source: expenseVoidCashSource,
              createdAt: s.now,
              updatedAt: s.now,
              createdBy: staffId,
              updatedBy: staffId,
              hlc: s.hlc.toString(),
              originDeviceId: s.deviceId,
            ),
            s,
          );
    return w.update(
      e.copyWith(
        voidedAt: s.now,
        voidedBy: staffId,
        voidReason: reason.trim(),
        voidCashMovementId: movement?.id,
        version: e.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  });
}

// --- Daftar & ringkasan -------------------------------------------------------

/// Satu baris daftar pengeluaran.
class ExpenseRow {
  const ExpenseRow({
    required this.expense,
    required this.categoryName,
    required this.staffName,
    this.sessionStaffName,
    this.voidedByName,
  });

  final Expense expense;
  final String categoryName;

  /// Staf yang mencatat.
  final String staffName;

  /// Pembuka sesi kasir untuk pengeluaran laci (*Kas laci · sesi Sari*).
  final String? sessionStaffName;
  final String? voidedByName;

  bool get voided => expense.voidedAt != null;
  bool get hasReceipt => expense.receiptMediaId != null;
}

/// Total per jenis.
class ExpenseCategoryTotal {
  const ExpenseCategoryTotal({required this.name, required this.total});

  final String name;
  final Money total;
}

/// Total pengeluaran tidak batal di [rows] dan rinciannya per jenis
/// (terbesar dulu, lalu nama).
(Money, List<ExpenseCategoryTotal>) summarizeExpenses(
  Iterable<ExpenseRow> rows,
) {
  final by = <String, Money>{};
  var total = Money.zero;
  for (final r in rows) {
    if (r.voided) continue;
    final amount = Money(r.expense.amount);
    total += amount;
    by[r.categoryName] = (by[r.categoryName] ?? Money.zero) + amount;
  }
  final list =
      [
        for (final e in by.entries)
          ExpenseCategoryTotal(name: e.key, total: e.value),
      ]..sort((a, b) {
        final c = b.total.compareTo(a.total);
        return c != 0 ? c : a.name.compareTo(b.name);
      });
  return (total, list);
}

/// Pengeluaran cabang ini dengan tanggal di [range], terbaru dulu.
Future<List<ExpenseRow>> listExpenses(
  LakunaStore store,
  CatalogScope scope,
  DateRange range,
) async {
  final session = store.session;
  final expenses = await Expense.db.find(
    session,
    where: (e) =>
        e.tenantId.equals(scope.tenantId) &
        e.outletId.equals(scope.outletId) &
        e.deletedAt.equals(null) &
        (e.spentOn >= range.from) &
        (e.spentOn <= range.to),
  );
  expenses.sort((a, b) {
    final d = b.spentOn.compareTo(a.spentOn);
    if (d != 0) return d;
    final c = b.createdAt.compareTo(a.createdAt);
    return c != 0 ? c : b.number.compareTo(a.number);
  });
  return _rows(session, scope, expenses);
}

Future<List<ExpenseRow>> _rows(
  DatabaseSession session,
  CatalogScope scope,
  List<Expense> expenses,
) async {
  if (expenses.isEmpty) return const [];
  final categories = {
    for (final c in await ExpenseCategory.db.find(
      session,
      where: (c) => c.tenantId.equals(scope.tenantId),
    ))
      c.id: c.name,
  };
  final staff = {
    for (final s in await StaffMember.db.find(
      session,
      where: (s) => s.tenantId.equals(scope.tenantId),
    ))
      s.id: s.name,
  };
  final sessionIds = {for (final e in expenses) ?e.cashSessionId};
  final openers = <UuidValue, String>{};
  for (final id in sessionIds) {
    final cs = await CashSession.db.findById(session, id);
    if (cs != null) openers[id] = staff[cs.openedBy] ?? '';
  }
  return [
    for (final e in expenses)
      ExpenseRow(
        expense: e,
        categoryName: categories[e.expenseCategoryId] ?? '',
        staffName: staff[e.staffId] ?? '',
        sessionStaffName: e.cashSessionId == null
            ? null
            : openers[e.cashSessionId],
        voidedByName: e.voidedBy == null ? null : staff[e.voidedBy],
      ),
  ];
}

/// Satu pengeluaran cabang ini.
Future<ExpenseRow> loadExpense(
  LakunaStore store,
  CatalogScope scope,
  UuidValue expenseId,
) async {
  final e = await Expense.db.findById(store.session, expenseId);
  if (e == null ||
      e.tenantId != scope.tenantId ||
      e.outletId != scope.outletId ||
      e.deletedAt != null) {
    throw ExpenseNotFound();
  }
  return (await _rows(store.session, scope, [e])).single;
}

/// Isi foto nota pengeluaran [expenseId]; `null` bila tidak ada atau
/// berkasnya belum ada di perangkat ini.
Future<Uint8List?> loadExpenseReceipt(
  LakunaStore store,
  CatalogScope scope,
  UuidValue expenseId,
) async {
  final e = await Expense.db.findById(store.session, expenseId);
  if (e == null || e.tenantId != scope.tenantId || e.receiptMediaId == null) {
    return null;
  }
  final media = await MediaFile.db.findById(store.session, e.receiptMediaId!);
  return media == null ? null : readMediaFile(store, media);
}

/// Nama jenis pengeluaran per gerakan kas di sesi [sessionId] (lencana
/// *Pengeluaran · jenis* di rekap sesi kasir).
Future<Map<UuidValue, String>> expenseLabelsForSession(
  LakunaStore store,
  CatalogScope scope,
  UuidValue sessionId,
) async {
  final expenses = await Expense.db.find(
    store.session,
    where: (e) =>
        e.tenantId.equals(scope.tenantId) &
        e.cashSessionId.equals(sessionId) &
        e.deletedAt.equals(null),
  );
  if (expenses.isEmpty) return const {};
  final categories = {
    for (final c in await ExpenseCategory.db.find(
      store.session,
      where: (c) => c.tenantId.equals(scope.tenantId),
    ))
      c.id: c.name,
  };
  return {
    for (final e in expenses)
      ?e.cashMovementId: categories[e.expenseCategoryId] ?? '',
  };
}
