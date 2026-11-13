import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/customers_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

UuidValue _id() => UuidValue.fromString(newId());

/// Pelanggan & piutang palsu di memori (F1-13), meniru aturan
/// `lakuna_data`: validasi pelanggan/grup, HP unik, alokasi nota terlama
/// dulu, nomor BP, dan saldo sebelum/sesudah.
class FakeCustomersRepository extends CustomersRepository {
  FakeCustomersRepository({
    this.canManage = true,
    this.canReceive = true,
    this.hasOpenSession = true,
    bool seed = true,
  }) {
    if (!seed) return;
    final grosir = _group('Grosir', 14);
    final umum = _group('Umum', 7);
    final ani = _customer(
      'Toko Bu Ani',
      phone: '081322221010',
      group: grosir,
      limit: 2000000,
    );
    _sale(ani, 'PST-T01-261020-0012', 600000, 100000, 20, 11, 1);
    _sale(ani, 'PST-T01-261028-0031', 500000, 200000, 28, 11, 11);
    _sale(ani, 'PST-T01-261102-0061', 350000, 0, 2, 11, 16);
    final kantin = _customer(
      'Kantin SD 2',
      phone: '085711112020',
      group: grosir,
      limit: 1000000,
    );
    _sale(kantin, 'PST-T01-261030-0040', 640000, 0, 30, 11, 13);
    final sri = _customer(
      'Warung Mbak Sri',
      phone: '081290903030',
      group: umum,
      limit: 500000,
    );
    _sale(sri, 'PST-T01-261101-0050', 275000, 0, 1, 11, 8);
    _customer('Pak Darto', phone: '081945454040');
  }

  bool canManage;
  bool canReceive;
  bool hasOpenSession;
  final _tenant = _id();
  final _outlet = _id();
  final _device = _id();
  final _staff = _id();
  final today = DateTime.utc(2026, 11, 3);

  final groupList = <CustomerGroup>[];
  final customers = <Customer>[];

  /// Nota kredit per pelanggan, urut terlama dulu, dengan sisa piutang.
  final sales = <UuidValue, List<(Sale, Money)>>{};
  final payments = <DebtPayment>[];
  final receipts = <UuidValue, DebtPaymentReceipt>{};
  final requests = <DebtPaymentRequest>[];
  final imported = <List<CustomerImportRow>>[];

  /// Galat berikutnya untuk aksi apa pun (sekali pakai).
  Exception? nextError;

  CustomerGroup _group(String name, int termDays) {
    final g = CustomerGroup(
      id: _id(),
      tenantId: _tenant,
      name: name,
      termDays: termDays,
      hlc: '',
    );
    groupList.add(g);
    return g;
  }

  Customer _customer(
    String name, {
    String? phone,
    CustomerGroup? group,
    int limit = 0,
  }) {
    final c = Customer(
      id: _id(),
      tenantId: _tenant,
      customerGroupId: group?.id,
      name: name,
      phone: phone,
      creditLimit: limit,
      createdAt: DateTime.utc(2026, 3, 5),
      hlc: '',
    );
    customers.add(c);
    return c;
  }

  void _sale(
    Customer c,
    String number,
    int total,
    int paid,
    int day,
    int dueMonth,
    int dueDay,
  ) {
    final month = day > 3 ? 10 : 11;
    final sale = Sale(
      id: _id(),
      tenantId: _tenant,
      outletId: _outlet,
      deviceId: _device,
      staffId: _staff,
      number: number,
      status: SaleStatus.completed,
      subtotal: total,
      tierDiscount: 0,
      total: total,
      paidAmount: 0,
      changeAmount: 0,
      itemCount: 1,
      soldAt: DateTime.utc(2026, month, day, 3),
      customerId: c.id,
      customerName: c.name,
      dueOn: DateTime.utc(2026, dueMonth, dueDay),
      hlc: '',
    );
    (sales[c.id] ??= []).add((sale, Money(total - paid)));
  }

  Exception? _takeError() {
    final e = nextError;
    nextError = null;
    return e;
  }

  Result<T> _check<T>(Permission? permission, T Function() body) {
    if (_takeError() case final e?) return Result.error(e);
    if (!canManage && !canReceive) {
      return const Result.error(NotPermitted(Permission.customersManage));
    }
    if (permission == Permission.customersManage && !canManage ||
        permission == Permission.debtsManage && !canReceive) {
      return Result.error(NotPermitted(permission!));
    }
    try {
      return Result.ok(body());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  List<ReceivableSale> _open(UuidValue customerId) => [
    for (final (sale, rest) in sales[customerId] ?? const <(Sale, Money)>[])
      if (rest > Money.zero)
        ReceivableSale(
          sale: sale,
          outstanding: rest,
          overdue: isOverdue(sale.dueOn, today),
        ),
  ];

  /// Baris semua pelanggan saat ini (sumber pemilih Kasir di tes).
  List<CustomerRow> get rows => [for (final c in customers) _row(c)];

  CustomerRow _row(Customer c) {
    final group = groupList.where((g) => g.id == c.customerGroupId).firstOrNull;
    final open = _open(c.id);
    return CustomerRow(
      customer: c,
      groupName: group?.name,
      termDays: group?.termDays ?? CustomerLimits.defaultTermDays,
      outstanding: Money.sum(open.map((r) => r.outstanding)),
      openCount: open.length,
      overdueCount: open.where((r) => r.overdue).length,
    );
  }

  @override
  Future<Result<CustomersSetup>> load() async => _check(
    null,
    () => CustomersSetup(
      today: today,
      businessName: 'Warung Contoh',
      outletName: 'Cabang Pusat',
      outletAddress: 'Jl. Melati No. 12, Purwokerto',
      outletPhone: '0812-0000-0001',
      timezone: 'Asia/Jakarta',
      outletId: _outlet,
      canManage: canManage,
      canReceive: canReceive,
      hasOpenSession: hasOpenSession,
    ),
  );

  @override
  Future<Result<CustomersOverview>> list() async => _check(
    null,
    () => CustomersOverview(
      rows: [
        for (final c in [
          ...customers,
        ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())))
          _row(c),
      ],
      today: today,
    ),
  );

  @override
  Future<Result<CustomerDetail>> detail(UuidValue id) async => _check(null, () {
    final c = customers.where((c) => c.id == id).firstOrNull;
    if (c == null) throw CustomerNotFound();
    return CustomerDetail(
      row: _row(c),
      open: _open(id),
      payments: [
        for (final p in payments.reversed)
          if (p.customerId == id) p,
      ],
      today: today,
    );
  });

  @override
  Future<Result<Customer>> save(CustomerInput input) async => _check(
    Permission.customersManage,
    () {
      final issues = validateCustomer(
        name: input.name,
        phone: input.phone,
        address: input.address,
        note: input.note,
        groupName: input.newGroupName,
        creditLimit: input.creditLimit,
      );
      if (issues.isNotEmpty) throw CustomerInvalid(issues);
      final phone = normalizePhone(input.phone ?? '');
      if (phone.isNotEmpty &&
          customers.any((c) => c.phone == phone && c.id != input.id)) {
        throw CustomerPhoneTaken();
      }
      var groupId = input.groupId;
      if (input.newGroupName case final name? when name.trim().isNotEmpty) {
        groupId =
            (groupList
                        .where(
                          (g) =>
                              g.name.toLowerCase() == name.trim().toLowerCase(),
                        )
                        .firstOrNull ??
                    _group(name.trim(), CustomerLimits.defaultTermDays))
                .id;
      }
      String? text(String? s) => (s?.trim().isEmpty ?? true) ? null : s!.trim();
      if (input.id case final id?) {
        final i = customers.indexWhere((c) => c.id == id);
        if (i < 0) throw CustomerNotFound();
        final updated = customers[i].copyWith(
          name: input.name.trim(),
          phone: text(phone),
          address: text(input.address),
          note: text(input.note),
          customerGroupId: groupId,
          creditLimit: input.creditLimit.value,
        );
        // copyWith tidak bisa mengosongkan kolom nullable.
        customers[i] = Customer(
          id: updated.id,
          tenantId: updated.tenantId,
          customerGroupId: groupId,
          name: updated.name,
          phone: text(phone),
          address: text(input.address),
          note: text(input.note),
          creditLimit: input.creditLimit.value,
          createdAt: updated.createdAt,
          hlc: '',
        );
        return customers[i];
      }
      final c = Customer(
        id: _id(),
        tenantId: _tenant,
        customerGroupId: groupId,
        name: input.name.trim(),
        phone: text(phone),
        address: text(input.address),
        note: text(input.note),
        creditLimit: input.creditLimit.value,
        createdAt: today,
        hlc: '',
      );
      customers.add(c);
      return c;
    },
  );

  @override
  Future<Result<void>> delete(UuidValue id) async =>
      _check(Permission.customersManage, () {
        if (_open(id).isNotEmpty) throw CustomerHasDebt();
        customers.removeWhere((c) => c.id == id);
      });

  @override
  Future<Result<List<CustomerGroupRow>>> groups() async => _check(
    null,
    () => [
      for (final g in [...groupList]..sort((a, b) => a.name.compareTo(b.name)))
        CustomerGroupRow(
          group: g,
          customerCount: customers
              .where((c) => c.customerGroupId == g.id)
              .length,
        ),
    ],
  );

  @override
  Future<Result<CustomerGroup>> saveGroup({
    UuidValue? id,
    required String name,
    required int termDays,
  }) async => _check(Permission.customersManage, () {
    final issues = validateCustomerGroup(name: name, termDays: termDays);
    if (issues.isNotEmpty) throw CustomerGroupInvalid(issues);
    if (groupList.any(
      (g) => g.id != id && g.name.toLowerCase() == name.trim().toLowerCase(),
    )) {
      throw CustomerGroupNameTaken();
    }
    if (id == null) return _group(name.trim(), termDays);
    final i = groupList.indexWhere((g) => g.id == id);
    if (i < 0) throw CustomerGroupNotFound();
    return groupList[i] = groupList[i].copyWith(
      name: name.trim(),
      termDays: termDays,
    );
  });

  @override
  Future<Result<void>> deleteGroup(UuidValue id) async =>
      _check(Permission.customersManage, () {
        if (customers.any((c) => c.customerGroupId == id)) {
          throw CustomerGroupInUse();
        }
        groupList.removeWhere((g) => g.id == id);
      });

  @override
  Future<Result<DebtPayment>> receivePayment(
    DebtPaymentRequest request,
  ) async => _check(Permission.debtsManage, () {
    requests.add(request);
    if (!debtPaymentMethods.contains(request.method)) {
      throw DebtPaymentMethodInvalid();
    }
    final open = [
      for (final r in _open(request.customerId))
        OpenReceivable(id: r.sale.id, outstanding: r.outstanding),
    ];
    if (validateDebtPayment(
          request.amount,
          open,
          manual: request.allocations,
        )
        case final issue?) {
      throw DebtPaymentInvalid(issue);
    }
    final split =
        request.allocations ?? allocateOldestFirst(request.amount, open);
    final list = sales[request.customerId]!;
    final lines = <DebtReceiptLine>[];
    for (final (i, (sale, rest)) in list.indexed) {
      final paid = split[sale.id];
      if (paid == null || paid == Money.zero) continue;
      lines.add(
        DebtReceiptLine(
          saleNumber: sale.number,
          soldAt: sale.soldAt,
          dueOn: sale.dueOn,
          balanceBefore: rest,
          amount: paid,
        ),
      );
      list[i] = (sale, rest - paid);
    }
    final balance = Money.sum(
      _open(request.customerId).map((r) => r.outstanding),
    );
    final payment = DebtPayment(
      id: _id(),
      tenantId: _tenant,
      outletId: _outlet,
      deviceId: _device,
      staffId: _staff,
      party: DebtParty.customer,
      customerId: request.customerId,
      number:
          'BP-PST-K01-261103-${(payments.length + 1).toString().padLeft(4, '0')}',
      amount: request.amount.value,
      method: request.method,
      paidOn: request.paidOn,
      cashSessionId: request.method == PaymentMethod.cash && hasOpenSession
          ? _id()
          : null,
      balanceAfter: balance.value,
      note: request.note,
      createdAt: DateTime.utc(2026, 11, 3, 2, 12),
      hlc: '',
    );
    payments.add(payment);
    receipts[payment.id] = DebtPaymentReceipt(
      payment: payment,
      customer: customers.firstWhere((c) => c.id == request.customerId),
      lines: lines,
      staffName: 'Sari',
    );
    return payment;
  });

  /// Panggilan batal pembayaran: (id, alasan).
  final voids = <(UuidValue, String)>[];

  /// Pembayaran dari cabang lain (tidak bisa dibatalkan di sini).
  DebtPayment addForeignPayment(UuidValue customerId) {
    final p = DebtPayment(
      id: _id(),
      tenantId: _tenant,
      outletId: _id(),
      deviceId: _device,
      staffId: _staff,
      party: DebtParty.customer,
      customerId: customerId,
      number: 'BP-CBG-K01-261101-0001',
      amount: 10000,
      method: PaymentMethod.transfer,
      paidOn: DateTime.utc(2026, 11, 1),
      balanceAfter: 0,
      hlc: '',
    );
    payments.insert(0, p);
    return p;
  }

  @override
  Future<Result<DebtPayment>> voidPayment(
    UuidValue paymentId,
    String reason,
  ) async => _check(Permission.debtsManage, () {
    voids.add((paymentId, reason));
    if (!validateDebtPaymentVoidReason(reason)) {
      throw DebtPaymentVoidReasonInvalid();
    }
    final i = payments.indexWhere((p) => p.id == paymentId);
    if (i < 0) throw DebtPaymentNotFound();
    final p = payments[i];
    if (p.voidedAt != null) throw DebtPaymentAlreadyVoided();
    if (debtPaymentTouchesDrawer(p) && !hasOpenSession) {
      throw CashSessionNotOpen();
    }
    final list = sales[p.customerId] ?? [];
    for (final line in receipts[p.id]?.lines ?? const <DebtReceiptLine>[]) {
      final j = list.indexWhere((e) => e.$1.number == line.saleNumber);
      if (j >= 0) list[j] = (list[j].$1, list[j].$2 + line.amount);
    }
    final voided = p.copyWith(
      voidedAt: DateTime.utc(2026, 11, 3, 3),
      voidedBy: _staff,
      voidReason: reason.trim(),
    );
    payments[i] = voided;
    if (receipts[p.id] case final r?) {
      receipts[p.id] = DebtPaymentReceipt(
        payment: voided,
        customer: r.customer,
        lines: r.lines,
        staffName: r.staffName,
      );
    }
    return voided;
  });

  @override
  Future<Result<DebtPaymentReceipt>> receipt(UuidValue paymentId) async =>
      _check(null, () {
        final r = receipts[paymentId];
        if (r == null) throw DebtPaymentNotFound();
        return r;
      });

  @override
  Future<Result<CustomerImportSummary>> importRows(
    List<CustomerImportRow> rows,
  ) async => _check(Permission.customersManage, () {
    imported.add(rows);
    var created = 0;
    var updated = 0;
    for (final r in rows) {
      final existing = r.phone == null
          ? null
          : customers.where((c) => c.phone == r.phone).firstOrNull;
      if (existing != null) {
        updated++;
      } else {
        _customer(r.name, phone: r.phone, limit: r.creditLimit?.value ?? 0);
        created++;
      }
    }
    return CustomerImportSummary(created: created, updated: updated);
  });
}
