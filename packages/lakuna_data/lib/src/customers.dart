import 'package:characters/characters.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show ColumnOrderingOperations, DatabaseSession, Transaction;

import 'cash.dart';
import 'staff_access.dart';
import 'stock.dart';
import 'store.dart';
import 'sync_tx.dart';

// Pelanggan & piutang (F1-13, layar 1.20 / 1.20b). Piutang tidak pernah
// disimpan sebagai saldo: selalu dihitung dari nota kredit, alokasi
// pembayaran, dan retur yang memotong piutang.

// --- Galat --------------------------------------------------------------------

/// Aktor bukan staf aktif cabang ini atau tidak punya [permission].
class CustomerActorNotPermitted implements Exception {
  const CustomerActorNotPermitted(this.permission);

  final Permission permission;

  @override
  String toString() => 'CustomerActorNotPermitted(${permission.key})';
}

class CustomerInvalid implements Exception {
  const CustomerInvalid(this.issues);

  final Set<CustomerIssue> issues;

  @override
  String toString() => 'CustomerInvalid($issues)';
}

/// Nomor HP sudah dipakai pelanggan lain di tenant ini.
class CustomerPhoneTaken implements Exception {
  @override
  String toString() => 'CustomerPhoneTaken';
}

class CustomerNotFound implements Exception {
  @override
  String toString() => 'CustomerNotFound';
}

/// Pelanggan masih punya piutang, jadi tidak bisa dihapus.
class CustomerHasDebt implements Exception {
  @override
  String toString() => 'CustomerHasDebt';
}

class CustomerGroupInvalid implements Exception {
  const CustomerGroupInvalid(this.issues);

  final Set<CustomerGroupIssue> issues;

  @override
  String toString() => 'CustomerGroupInvalid($issues)';
}

class CustomerGroupNameTaken implements Exception {
  @override
  String toString() => 'CustomerGroupNameTaken';
}

/// Grup masih dipakai tingkat harga grosir produk (F1-07c).
class CustomerGroupHasPrices implements Exception {
  @override
  String toString() => 'CustomerGroupHasPrices';
}

class CustomerGroupNotFound implements Exception {
  @override
  String toString() => 'CustomerGroupNotFound';
}

/// Grup masih dipakai pelanggan.
class CustomerGroupInUse implements Exception {
  @override
  String toString() => 'CustomerGroupInUse';
}

/// Kredit di Kasir ditolak (lihat [CreditIssue]).
class SaleCreditInvalid implements Exception {
  const SaleCreditInvalid(this.issue);

  final CreditIssue issue;

  @override
  String toString() => 'SaleCreditInvalid($issue)';
}

class DebtPaymentInvalid implements Exception {
  const DebtPaymentInvalid(this.issue);

  final DebtPaymentIssue issue;

  @override
  String toString() => 'DebtPaymentInvalid($issue)';
}

/// Tanggal bayar di masa depan.
class DebtPaymentDateInvalid implements Exception {
  @override
  String toString() => 'DebtPaymentDateInvalid';
}

/// Metode terima piutang hanya tunai, transfer, atau QRIS statis.
class DebtPaymentMethodInvalid implements Exception {
  @override
  String toString() => 'DebtPaymentMethodInvalid';
}

class DebtPaymentNotFound implements Exception {
  @override
  String toString() => 'DebtPaymentNotFound';
}

/// [staffId] staf aktif cabang ini dengan [permission].
Future<void> requireCustomerActor(
  LakunaStore store,
  CatalogScope scope,
  UuidValue staffId,
  Permission permission,
) async {
  final staff = await findStaffById(
    store,
    tenantId: scope.tenantId,
    outletId: scope.outletId,
    staffId: staffId,
  );
  if (staff == null || !staff.permissions.contains(permission)) {
    throw CustomerActorNotPermitted(permission);
  }
}

// --- Tanggal ------------------------------------------------------------------

/// Tanggal hari ini di cabang (UTC tengah malam) untuk [now].
Future<DateTime> outletToday(
  DatabaseSession session,
  CatalogScope scope,
  DateTime now, {
  Transaction? transaction,
}) async {
  final outlet = await Outlet.db.findById(
    session,
    scope.outletId,
    transaction: transaction,
  );
  final tenant = await Tenant.db.findById(
    session,
    scope.tenantId,
    transaction: transaction,
  );
  final local = outletLocalTime(now, outlet?.timezone ?? tenant?.timezone);
  return DateTime.utc(local.year, local.month, local.day);
}

DateTime _date(DateTime d) => DateTime.utc(d.year, d.month, d.day);

String? _text(String? s) {
  final t = s?.trim();
  return t == null || t.isEmpty ? null : t;
}

// --- Grup ---------------------------------------------------------------------

class CustomerGroupRow {
  const CustomerGroupRow({required this.group, required this.customerCount});

  final CustomerGroup group;
  final int customerCount;
}

Future<List<Customer>> _customers(
  DatabaseSession session,
  UuidValue tenantId, {
  Transaction? transaction,
}) => Customer.db.find(
  session,
  where: (c) => c.tenantId.equals(tenantId) & c.deletedAt.equals(null),
  transaction: transaction,
);

Future<List<CustomerGroup>> _groups(
  DatabaseSession session,
  UuidValue tenantId, {
  Transaction? transaction,
}) => CustomerGroup.db.find(
  session,
  where: (g) => g.tenantId.equals(tenantId) & g.deletedAt.equals(null),
  transaction: transaction,
);

/// Grup pelanggan tenant beserta jumlah pemakainya, urut nama.
Future<List<CustomerGroupRow>> listCustomerGroups(
  LakunaStore store,
  CatalogScope scope,
) async {
  final groups = await _groups(store.session, scope.tenantId);
  final customers = await _customers(store.session, scope.tenantId);
  final counts = <UuidValue, int>{};
  for (final c in customers) {
    if (c.customerGroupId case final id?) counts[id] = (counts[id] ?? 0) + 1;
  }
  groups.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return [
    for (final g in groups)
      CustomerGroupRow(group: g, customerCount: counts[g.id] ?? 0),
  ];
}

/// Membuat atau mengubah ([id]) grup. Nama unik tanpa membedakan huruf.
Future<CustomerGroup> saveCustomerGroup(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  UuidValue? id,
  required String name,
  required int termDays,
}) async {
  final issues = validateCustomerGroup(name: name, termDays: termDays);
  if (issues.isNotEmpty) throw CustomerGroupInvalid(issues);
  await requireCustomerActor(store, scope, staffId, Permission.customersManage);
  final clean = name.trim();
  return store.write(actor: staffId, (w) async {
    final groups = await _groups(
      w.session,
      scope.tenantId,
      transaction: w.transaction,
    );
    if (groups.any(
      (g) => g.id != id && g.name.toLowerCase() == clean.toLowerCase(),
    )) {
      throw CustomerGroupNameTaken();
    }
    final s = await w.stamp();
    if (id == null) {
      return w.insert(
        CustomerGroup(
          tenantId: scope.tenantId,
          name: clean,
          termDays: termDays,
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
    final old = groups.where((g) => g.id == id).firstOrNull;
    if (old == null) throw CustomerGroupNotFound();
    return w.update(
      old.copyWith(
        name: clean,
        termDays: termDays,
        version: old.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  });
}

/// Hapus lunak grup yang tidak dipakai pelanggan mana pun maupun harga
/// grosir produk ([CustomerGroupHasPrices]).
Future<void> deleteCustomerGroup(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue groupId,
}) async {
  await requireCustomerActor(store, scope, staffId, Permission.customersManage);
  await store.write(actor: staffId, (w) async {
    final group = await CustomerGroup.db.findById(
      w.session,
      groupId,
      transaction: w.transaction,
    );
    if (group == null ||
        group.tenantId != scope.tenantId ||
        group.deletedAt != null) {
      throw CustomerGroupNotFound();
    }
    final used = await Customer.db.count(
      w.session,
      where: (c) =>
          c.tenantId.equals(scope.tenantId) &
          c.customerGroupId.equals(groupId) &
          c.deletedAt.equals(null),
      transaction: w.transaction,
    );
    if (used > 0) throw CustomerGroupInUse();
    final priced = await ProductPriceTier.db.count(
      w.session,
      where: (t) =>
          t.tenantId.equals(scope.tenantId) &
          t.customerGroupId.equals(groupId) &
          t.deletedAt.equals(null),
      transaction: w.transaction,
    );
    if (priced > 0) throw CustomerGroupHasPrices();
    final s = await w.stamp();
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
}

/// Grup bernama [name] (tanpa membedakan huruf), dibuat bila belum ada.
Future<CustomerGroup> _groupNamed(
  SyncTx w,
  CatalogScope scope,
  String name,
  UuidValue staffId,
  SyncStamp s,
) async {
  final clean = name.trim();
  final groups = await _groups(
    w.session,
    scope.tenantId,
    transaction: w.transaction,
  );
  final same = groups
      .where((g) => g.name.toLowerCase() == clean.toLowerCase())
      .firstOrNull;
  if (same != null) return same;
  return w.insert(
    CustomerGroup(
      tenantId: scope.tenantId,
      name: clean,
      termDays: CustomerLimits.defaultTermDays,
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

// --- Piutang per nota ---------------------------------------------------------

/// Nota kredit yang masih bersisa.
class ReceivableSale {
  const ReceivableSale({
    required this.sale,
    required this.outstanding,
    required this.overdue,
  });

  final Sale sale;
  final Money outstanding;
  final bool overdue;
}

/// Status nota yang menghitung piutang (sama dengan nota terjual).
const _receivableStatuses = {
  SaleStatus.completed,
  SaleStatus.partiallyReturned,
  SaleStatus.returned,
};

/// Sisa piutang setiap nota di [sales] (nota tanpa pelanggan atau void = 0).
Future<Map<UuidValue, Money>> saleOutstandingOf(
  DatabaseSession session,
  UuidValue tenantId,
  Iterable<Sale> sales, {
  Transaction? transaction,
}) async {
  final credit = [
    for (final s in sales)
      if (s.customerId != null &&
          _receivableStatuses.contains(s.status) &&
          s.paidAmount < s.total)
        s,
  ];
  final result = <UuidValue, Money>{for (final s in sales) s.id: Money.zero};
  if (credit.isEmpty) return result;
  final allocated = <UuidValue, Money>{};
  final reduced = <UuidValue, Money>{};
  // Dipecah per 500 id agar tidak melewati batas variabel SQLite.
  for (var i = 0; i < credit.length; i += 500) {
    final ids = {for (final s in credit.skip(i).take(500)) s.id};
    for (final a in await DebtPaymentAllocation.db.find(
      session,
      where: (a) =>
          a.tenantId.equals(tenantId) &
          a.saleId.inSet(ids) &
          a.deletedAt.equals(null),
      transaction: transaction,
    )) {
      allocated[a.saleId!] =
          (allocated[a.saleId!] ?? Money.zero) + Money(a.amount);
    }
    for (final r in await SaleReturn.db.find(
      session,
      where: (r) =>
          r.tenantId.equals(tenantId) &
          r.saleId.inSet(ids) &
          r.deletedAt.equals(null),
      transaction: transaction,
    )) {
      reduced[r.saleId] =
          (reduced[r.saleId] ?? Money.zero) + Money(r.debtReduction);
    }
  }
  for (final s in credit) {
    result[s.id] = saleOutstanding(
      total: Money(s.total),
      paidAtSale: Money(s.paidAmount),
      allocated: allocated[s.id] ?? Money.zero,
      debtReduction: reduced[s.id] ?? Money.zero,
    );
  }
  return result;
}

/// Nota kredit bersisa per pelanggan, urut terlama dulu (`sold_at`, nomor).
Future<Map<UuidValue, List<ReceivableSale>>> _receivables(
  DatabaseSession session,
  UuidValue tenantId,
  DateTime today, {
  UuidValue? customerId,
  Transaction? transaction,
}) async {
  final sales = await Sale.db.find(
    session,
    where: (s) =>
        s.tenantId.equals(tenantId) &
        (customerId == null
            ? s.customerId.notEquals(null)
            : s.customerId.equals(customerId)) &
        s.status.inSet(_receivableStatuses) &
        s.deletedAt.equals(null),
    orderByList: (s) => [s.soldAt, s.number],
    transaction: transaction,
  );
  final outstanding = await saleOutstandingOf(
    session,
    tenantId,
    sales,
    transaction: transaction,
  );
  final result = <UuidValue, List<ReceivableSale>>{};
  for (final s in sales) {
    final rest = outstanding[s.id] ?? Money.zero;
    if (rest <= Money.zero) continue;
    result
        .putIfAbsent(s.customerId!, () => [])
        .add(
          ReceivableSale(
            sale: s,
            outstanding: rest,
            overdue: isOverdue(s.dueOn, today),
          ),
        );
  }
  return result;
}

/// Sisa piutang nota kredit yang lewat jatuh tempo pada [today] dan jumlah
/// pelanggannya (kartu *Piutang jatuh tempo* F1-16).
Future<(Money, int)> overdueReceivables(
  DatabaseSession session,
  UuidValue tenantId,
  DateTime today,
) async {
  final open = await _receivables(session, tenantId, today);
  var total = Money.zero;
  var customers = 0;
  for (final list in open.values) {
    final due = list.where((r) => r.overdue);
    if (due.isEmpty) continue;
    customers++;
    total += Money.sum(due.map((r) => r.outstanding));
  }
  return (total, customers);
}

/// Total piutang pelanggan [customerId].
Future<Money> customerOutstanding(
  DatabaseSession session,
  UuidValue tenantId,
  UuidValue customerId, {
  Transaction? transaction,
}) async {
  final open = await _receivables(
    session,
    tenantId,
    DateTime.utc(1970),
    customerId: customerId,
    transaction: transaction,
  );
  return Money.sum((open[customerId] ?? const []).map((r) => r.outstanding));
}

// --- Pelanggan ----------------------------------------------------------------

/// Satu baris daftar pelanggan (1.20) dan pemilih pelanggan kredit (1.5b).
class CustomerRow {
  const CustomerRow({
    required this.customer,
    required this.groupName,
    required this.termDays,
    required this.outstanding,
    required this.openCount,
    required this.overdueCount,
  });

  final Customer customer;
  final String? groupName;

  /// Tempo standar: grup, atau [CustomerLimits.defaultTermDays].
  final int termDays;
  final Money outstanding;
  final int openCount;
  final int overdueCount;

  Money get creditLimit => Money(customer.creditLimit);

  /// Sisa limit (≥ 0).
  Money get remainingLimit {
    final rest = creditLimit - outstanding;
    return rest.isNegative ? Money.zero : rest;
  }
}

class CustomersOverview {
  const CustomersOverview({required this.rows, required this.today});

  /// Urut nama.
  final List<CustomerRow> rows;

  /// Tanggal hari ini di cabang (UTC tengah malam).
  final DateTime today;

  Money get totalOutstanding => Money.sum(rows.map((r) => r.outstanding));

  /// Pelanggan yang berpiutang.
  int get debtorCount => rows.where((r) => r.outstanding > Money.zero).length;

  /// Nota terlambat.
  int get overdueCount => rows.fold(0, (sum, r) => sum + r.overdueCount);
}

CustomerRow _row(
  Customer c,
  Map<UuidValue, CustomerGroup> groups,
  List<ReceivableSale> open,
) {
  final group = groups[c.customerGroupId];
  return CustomerRow(
    customer: c,
    groupName: group?.name,
    termDays: group?.termDays ?? CustomerLimits.defaultTermDays,
    outstanding: Money.sum(open.map((r) => r.outstanding)),
    openCount: open.length,
    overdueCount: open.where((r) => r.overdue).length,
  );
}

/// Pelanggan tenant dengan piutangnya, urut nama.
Future<CustomersOverview> listCustomers(
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
  final customers = await _customers(session, scope.tenantId);
  final groups = {
    for (final g in await _groups(session, scope.tenantId)) g.id: g,
  };
  final open = await _receivables(session, scope.tenantId, today);
  customers.sort(
    (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
  );
  return CustomersOverview(
    today: today,
    rows: [for (final c in customers) _row(c, groups, open[c.id] ?? const [])],
  );
}

/// Rincian pelanggan untuk panel 1.20.
class CustomerDetail {
  const CustomerDetail({
    required this.row,
    required this.open,
    required this.payments,
    required this.today,
  });

  final CustomerRow row;

  /// Nota belum lunas, terlama dulu.
  final List<ReceivableSale> open;

  /// Pembayaran piutang, terbaru dulu.
  final List<DebtPayment> payments;
  final DateTime today;

  Customer get customer => row.customer;
}

/// Pelanggan nota non-kredit (F1-04d): milik tenant dan belum dihapus.
Future<Customer> saleCustomer(SyncTx w, CatalogScope scope, UuidValue id) =>
    _customer(w.session, scope, id, transaction: w.transaction);

Future<Customer> _customer(
  DatabaseSession session,
  CatalogScope scope,
  UuidValue id, {
  Transaction? transaction,
}) async {
  final c = await Customer.db.findById(session, id, transaction: transaction);
  if (c == null || c.tenantId != scope.tenantId || c.deletedAt != null) {
    throw CustomerNotFound();
  }
  return c;
}

Future<CustomerDetail> loadCustomerDetail(
  LakunaStore store,
  CatalogScope scope,
  UuidValue customerId, {
  DateTime? now,
}) async {
  final session = store.session;
  final today = await outletToday(
    session,
    scope,
    now ?? DateTime.now().toUtc(),
  );
  final c = await _customer(session, scope, customerId);
  final groups = {
    for (final g in await _groups(session, scope.tenantId)) g.id: g,
  };
  final open =
      (await _receivables(
        session,
        scope.tenantId,
        today,
        customerId: c.id,
      ))[c.id] ??
      const <ReceivableSale>[];
  final payments = await DebtPayment.db.find(
    session,
    where: (p) =>
        p.tenantId.equals(scope.tenantId) &
        p.customerId.equals(c.id) &
        p.deletedAt.equals(null),
    orderByList: (p) => [p.createdAt.desc(), p.number.desc()],
  );
  return CustomerDetail(
    row: _row(c, groups, open),
    open: open,
    payments: payments,
    today: today,
  );
}

/// Isian form pelanggan. [newGroupName] dipakai bila [groupId] kosong.
class CustomerInput {
  const CustomerInput({
    this.id,
    required this.name,
    this.phone,
    this.address,
    this.note,
    this.groupId,
    this.newGroupName,
    this.creditLimit = Money.zero,
  });

  final UuidValue? id;
  final String name;
  final String? phone;
  final String? address;
  final String? note;
  final UuidValue? groupId;
  final String? newGroupName;
  final Money creditLimit;
}

Future<void> _checkPhone(
  SyncTx w,
  CatalogScope scope,
  String? phone,
  UuidValue? self,
) async {
  if (phone == null) return;
  final same = await Customer.db.findFirstRow(
    w.session,
    where: (c) =>
        c.tenantId.equals(scope.tenantId) &
        c.phone.equals(phone) &
        c.deletedAt.equals(null),
    transaction: w.transaction,
  );
  if (same != null && same.id != self) throw CustomerPhoneTaken();
}

/// Membuat atau mengubah pelanggan.
Future<Customer> saveCustomer(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required CustomerInput input,
}) async {
  final issues = validateCustomer(
    name: input.name,
    phone: input.phone,
    address: input.address,
    note: input.note,
    groupName: input.newGroupName,
    creditLimit: input.creditLimit,
  );
  if (issues.isNotEmpty) throw CustomerInvalid(issues);
  await requireCustomerActor(store, scope, staffId, Permission.customersManage);
  final phone = _text(normalizePhone(input.phone ?? ''));
  return store.write(actor: staffId, (w) async {
    await _checkPhone(w, scope, phone, input.id);
    final s = await w.stamp();
    UuidValue? groupId;
    if (input.groupId case final id?) {
      final g = await CustomerGroup.db.findById(
        w.session,
        id,
        transaction: w.transaction,
      );
      if (g == null || g.tenantId != scope.tenantId || g.deletedAt != null) {
        throw const CustomerInvalid({CustomerIssue.group});
      }
      groupId = g.id;
    } else if (_text(input.newGroupName) case final name?) {
      groupId = (await _groupNamed(w, scope, name, staffId, s)).id;
    }
    if (input.id case final id?) {
      final old = await _customer(
        w.session,
        scope,
        id,
        transaction: w.transaction,
      );
      return w.update(
        old.copyWith(
          name: input.name.trim(),
          phone: phone,
          address: _text(input.address),
          note: _text(input.note),
          customerGroupId: groupId,
          creditLimit: input.creditLimit.value,
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
      Customer(
        tenantId: scope.tenantId,
        customerGroupId: groupId,
        name: input.name.trim(),
        phone: phone,
        address: _text(input.address),
        note: _text(input.note),
        creditLimit: input.creditLimit.value,
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

/// Hapus lunak pelanggan tanpa piutang.
Future<void> deleteCustomer(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue customerId,
}) async {
  await requireCustomerActor(store, scope, staffId, Permission.customersManage);
  await store.write(actor: staffId, (w) async {
    final c = await _customer(
      w.session,
      scope,
      customerId,
      transaction: w.transaction,
    );
    final debt = await customerOutstanding(
      w.session,
      scope.tenantId,
      c.id,
      transaction: w.transaction,
    );
    if (debt > Money.zero) throw CustomerHasDebt();
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

// --- Kredit di Kasir ----------------------------------------------------------

/// Nota kredit dari Kasir: sisa setelah DP tunai [downPayment] menjadi
/// piutang [customerId] dengan jatuh tempo [dueOn] (tanggal kalender).
class SaleCredit {
  const SaleCredit({
    required this.customerId,
    required this.downPayment,
    required this.dueOn,
  });

  final UuidValue customerId;
  final Money downPayment;
  final DateTime dueOn;
}

/// Memeriksa kredit [credit] untuk nota [total] di dalam transaksi tulis.
/// Mengembalikan pelanggannya.
Future<Customer> checkSaleCredit(
  SyncTx w,
  CatalogScope scope,
  SaleCredit credit,
  Money total,
  DateTime now,
) async {
  final c = await _customer(
    w.session,
    scope,
    credit.customerId,
    transaction: w.transaction,
  );
  final issue = creditIssue(
    limit: Money(c.creditLimit),
    outstanding: await customerOutstanding(
      w.session,
      scope.tenantId,
      c.id,
      transaction: w.transaction,
    ),
    total: total,
    downPayment: credit.downPayment,
    dueOn: _date(credit.dueOn),
    today: await outletToday(w.session, scope, now, transaction: w.transaction),
  );
  if (issue != null) throw SaleCreditInvalid(issue);
  return c;
}

// --- Pembayaran piutang -------------------------------------------------------

/// `cash_movements.source` untuk terima piutang tunai di laci.
const debtPaymentCashSource = 'debt_payment';

/// Metode yang bisa dipakai menerima pembayaran piutang.
const debtPaymentMethods = {
  PaymentMethod.cash,
  PaymentMethod.transfer,
  PaymentMethod.qrisStatic,
};

class DebtPaymentRequest {
  const DebtPaymentRequest({
    required this.customerId,
    required this.amount,
    required this.method,
    required this.paidOn,
    this.allocations,
    this.note,
  });

  final UuidValue customerId;
  final Money amount;
  final PaymentMethod method;

  /// Tanggal bayar (kalender).
  final DateTime paidOn;

  /// Alokasi manual per nota; `null` = otomatis terlama dulu.
  final Map<UuidValue, Money>? allocations;
  final String? note;
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
  final prefix = 'BP-${receiptPrefix(outlet.code, device.code, local)}';
  final existing = await DebtPayment.db.find(
    w.session,
    where: (p) => p.tenantId.equals(scope.tenantId) & p.number.like('$prefix%'),
    transaction: w.transaction,
  );
  final counter = nextReceiptCounter(existing.map((p) => p.number), prefix);
  return debtPaymentNumber(outlet.code, device.code, local, counter);
}

/// Menerima pembayaran piutang pelanggan dalam satu transaksi: dokumen
/// `BP-`, alokasi per nota, dan gerakan kas masuk bila tunai dengan sesi
/// kasir terbuka di perangkat ini.
Future<DebtPayment> receiveDebtPayment(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required DebtPaymentRequest request,
}) async {
  if (!debtPaymentMethods.contains(request.method)) {
    throw DebtPaymentMethodInvalid();
  }
  final note = _text(request.note);
  if ((note?.characters.length ?? 0) > CustomerLimits.note) {
    throw const CustomerInvalid({CustomerIssue.note});
  }
  await requireCustomerActor(store, scope, staffId, Permission.debtsManage);
  return store.write(actor: staffId, (w) async {
    final s = await w.stamp();
    final today = await outletToday(
      w.session,
      scope,
      s.now,
      transaction: w.transaction,
    );
    final paidOn = _date(request.paidOn);
    if (paidOn.isAfter(today)) throw DebtPaymentDateInvalid();
    final c = await _customer(
      w.session,
      scope,
      request.customerId,
      transaction: w.transaction,
    );
    final open =
        (await _receivables(
          w.session,
          scope.tenantId,
          today,
          customerId: c.id,
          transaction: w.transaction,
        ))[c.id] ??
        const <ReceivableSale>[];
    final receivables = [
      for (final r in open)
        OpenReceivable(id: r.sale.id, outstanding: r.outstanding),
    ];
    final issue = validateDebtPayment(
      request.amount,
      receivables,
      manual: request.allocations,
    );
    if (issue != null) throw DebtPaymentInvalid(issue);
    final allocations =
        request.allocations ?? allocateOldestFirst(request.amount, receivables);
    final total = Money.sum(open.map((r) => r.outstanding));

    // Uang yang diterima hari lain tidak masuk laci hari ini: dicatat
    // sebagai kas toko.
    final cash = request.method == PaymentMethod.cash && paidOn == today
        ? await findOpenCashSession(
            store,
            CashScope(
              tenantId: scope.tenantId,
              outletId: scope.outletId,
              deviceId: scope.deviceId,
            ),
            transaction: w.transaction,
          )
        : null;
    final number = await _nextPaymentNumber(w, scope, s.now);
    final payment = await w.insert(
      DebtPayment(
        tenantId: scope.tenantId,
        outletId: scope.outletId,
        deviceId: scope.deviceId,
        staffId: staffId,
        party: DebtParty.customer,
        customerId: c.id,
        number: number,
        amount: request.amount.value,
        method: request.method,
        paidOn: paidOn,
        cashSessionId: cash?.id,
        balanceAfter: (total - request.amount).value,
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
    for (final r in open) {
      final amount = allocations[r.sale.id];
      if (amount == null || amount <= Money.zero) continue;
      await w.insert(
        DebtPaymentAllocation(
          tenantId: scope.tenantId,
          debtPaymentId: payment.id,
          documentType: DebtDocumentType.sale,
          saleId: r.sale.id,
          amount: amount.value,
          balanceBefore: r.outstanding.value,
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
          direction: CashDirection.inflow,
          amount: request.amount.value,
          note: 'Pembayaran piutang $number',
          source: debtPaymentCashSource,
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

/// Satu nota di kuitansi.
class DebtReceiptLine {
  const DebtReceiptLine({
    required this.saleNumber,
    required this.soldAt,
    required this.dueOn,
    required this.balanceBefore,
    required this.amount,
  });

  final String saleNumber;
  final DateTime soldAt;
  final DateTime? dueOn;
  final Money balanceBefore;
  final Money amount;
}

/// Isi kuitansi pembayaran piutang (1.20b).
class DebtPaymentReceipt {
  const DebtPaymentReceipt({
    required this.payment,
    required this.customer,
    required this.lines,
    required this.staffName,
  });

  final DebtPayment payment;
  final Customer customer;

  /// Urut nota terlama dulu.
  final List<DebtReceiptLine> lines;
  final String staffName;

  Money get amount => Money(payment.amount);
  Money get balanceAfter => Money(payment.balanceAfter);
}

Future<DebtPaymentReceipt> loadDebtPaymentReceipt(
  LakunaStore store,
  CatalogScope scope,
  UuidValue paymentId,
) async {
  final session = store.session;
  final payment = await DebtPayment.db.findById(session, paymentId);
  if (payment == null ||
      payment.tenantId != scope.tenantId ||
      payment.deletedAt != null ||
      payment.customerId == null) {
    throw DebtPaymentNotFound();
  }
  final customer = await Customer.db.findById(session, payment.customerId!);
  if (customer == null) throw DebtPaymentNotFound();
  final allocations = await DebtPaymentAllocation.db.find(
    session,
    where: (a) =>
        a.tenantId.equals(scope.tenantId) &
        a.debtPaymentId.equals(payment.id) &
        a.deletedAt.equals(null),
  );
  final sales = {
    for (final s in await Sale.db.find(
      session,
      where: (s) =>
          s.tenantId.equals(scope.tenantId) &
          s.id.inSet({for (final a in allocations) a.saleId!}),
    ))
      s.id: s,
  };
  final lines =
      [
        for (final a in allocations)
          if (sales[a.saleId] case final sale?)
            DebtReceiptLine(
              saleNumber: sale.number,
              soldAt: sale.soldAt,
              dueOn: sale.dueOn,
              balanceBefore: Money(a.balanceBefore),
              amount: Money(a.amount),
            ),
      ]..sort((a, b) {
        final t = a.soldAt.compareTo(b.soldAt);
        return t != 0 ? t : a.saleNumber.compareTo(b.saleNumber);
      });
  final staff = await StaffMember.db.findById(session, payment.staffId);
  return DebtPaymentReceipt(
    payment: payment,
    customer: customer,
    lines: lines,
    staffName: staff?.name ?? '',
  );
}

/// Ada alokasi pembayaran piutang ke nota [saleId].
Future<bool> saleHasDebtPayments(
  DatabaseSession session,
  UuidValue tenantId,
  UuidValue saleId, {
  Transaction? transaction,
}) async =>
    await DebtPaymentAllocation.db.count(
      session,
      where: (a) =>
          a.tenantId.equals(tenantId) &
          a.saleId.equals(saleId) &
          a.deletedAt.equals(null),
      transaction: transaction,
    ) >
    0;

// --- Import -------------------------------------------------------------------

class CustomerImportSummary {
  const CustomerImportSummary({required this.created, required this.updated});

  final int created;
  final int updated;
}

/// Menyimpan baris import sah dalam satu transaksi. HP yang sudah ada
/// memperbarui pelanggan itu (hanya kolom yang terisi); grup baru dibuat.
Future<CustomerImportSummary> importCustomers(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required List<CustomerImportRow> rows,
}) async {
  await requireCustomerActor(store, scope, staffId, Permission.customersManage);
  // Baris dari luar aplikasi diperiksa ulang di lapisan data, sama dengan
  // `saveCustomer`; satu baris salah membatalkan seluruh import.
  for (final r in rows) {
    final issues = validateCustomer(
      name: r.name,
      phone: r.phone,
      address: r.address,
      note: r.note,
      groupName: r.groupName,
      creditLimit: r.creditLimit ?? Money.zero,
    );
    if (issues.isNotEmpty) throw CustomerInvalid(issues);
  }
  rows = [
    for (final r in rows)
      CustomerImportRow(
        line: r.line,
        name: r.name.trim(),
        phone: r.phone == null ? null : normalizePhone(r.phone!),
        address: _text(r.address),
        note: _text(r.note),
        groupName: _text(r.groupName),
        creditLimit: r.creditLimit,
      ),
  ];
  return store.write(actor: staffId, (w) async {
    final s = await w.stamp();
    final existing = await _customers(
      w.session,
      scope.tenantId,
      transaction: w.transaction,
    );
    final byPhone = {
      for (final c in existing)
        if (c.phone != null) c.phone!: c,
    };
    var created = 0;
    var updated = 0;
    for (final r in rows) {
      UuidValue? groupId;
      if (r.groupName case final name?) {
        groupId = (await _groupNamed(w, scope, name, staffId, s)).id;
      }
      final old = r.phone == null ? null : byPhone[r.phone];
      if (old != null) {
        final next = await w.update(
          old.copyWith(
            name: r.name,
            address: r.address ?? old.address,
            note: r.note ?? old.note,
            customerGroupId: groupId ?? old.customerGroupId,
            creditLimit: r.creditLimit?.value ?? old.creditLimit,
            version: old.version + 1,
            updatedAt: s.now,
            updatedBy: staffId,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
        byPhone[r.phone!] = next;
        updated++;
      } else {
        final c = await w.insert(
          Customer(
            tenantId: scope.tenantId,
            customerGroupId: groupId,
            name: r.name,
            phone: r.phone,
            address: r.address,
            note: r.note,
            creditLimit: r.creditLimit?.value ?? 0,
            createdAt: s.now,
            updatedAt: s.now,
            createdBy: staffId,
            updatedBy: staffId,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
        if (c.phone != null) byPhone[c.phone!] = c;
        created++;
      }
    }
    return CustomerImportSummary(created: created, updated: updated);
  });
}
