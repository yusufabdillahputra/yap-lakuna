import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/suppliers_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

UuidValue _id() => UuidValue.fromString(newId());

/// Supplier & hutang palsu di memori (F1-14), meniru aturan `lakuna_data`:
/// validasi supplier, nama unik, alokasi jatuh tempo terdekat dulu, nomor
/// BH, kas laci butuh sesi dan tanggal hari ini.
class FakeSuppliersRepository extends SuppliersRepository {
  FakeSuppliersRepository({
    this.canManage = true,
    this.canPay = true,
    this.canUseDrawer = true,
    this.hasOpenSession = true,
    bool seed = true,
  }) {
    if (!seed) return;
    final sumber = _supplier(
      'CV Sumber Pangan',
      phone: '0215550101',
      contact: 'Pak Hendra',
      category: 'Sembako',
    );
    _purchase(sumber, 'PB-PST-D01-261028-0001', 3300000, 2000000, 28, 10, 4);
    _purchase(sumber, 'PB-PST-D01-261102-0003', 1725000, 1000000, 2, 11, 16);
    _purchase(sumber, 'PB-PST-D01-261101-0002', 400000, 400000, 1, 11, null);
    _supplier(
      'UD Makmur',
      phone: '08127770202',
      contact: 'Bu Rina',
      category: 'Minuman',
    );
    final segar = _supplier(
      'PT Segar Jaya',
      phone: '08138880303',
      category: 'Telur & sayur',
      termDays: 7,
    );
    _purchase(segar, 'PB-PST-D01-261030-0004', 480000, 0, 30, 10, 6);
  }

  bool canManage;
  bool canPay;
  bool canUseDrawer;
  bool hasOpenSession;
  final _tenant = _id();
  final _outlet = _id();
  final _device = _id();
  final _staff = _id();
  final today = DateTime.utc(2026, 11, 4);

  final suppliers = <Supplier>[];

  /// Pembelian per supplier dengan sisa hutang.
  final purchaseList = <UuidValue, List<(Purchase, Money)>>{};
  final payments = <DebtPayment>[];
  final requests = <SupplierPaymentRequest>[];
  final proofs = <UuidValue, Uint8List>{};

  /// Galat berikutnya untuk aksi apa pun (sekali pakai).
  Exception? nextError;

  Supplier _supplier(
    String name, {
    String? phone,
    String? contact,
    String? category,
    int termDays = 14,
  }) {
    final s = Supplier(
      id: _id(),
      tenantId: _tenant,
      name: name,
      phone: phone,
      contactName: contact,
      category: category,
      termDays: termDays,
      createdAt: DateTime.utc(2026, 3, 1),
      hlc: '',
    );
    suppliers.add(s);
    return s;
  }

  /// Pembelian diterima tanggal [day]/[month]; jatuh tempo [dueDay] bulan 11.
  Purchase _purchase(
    Supplier s,
    String number,
    int total,
    int paid,
    int day,
    int month,
    int? dueDay,
  ) {
    final p = Purchase(
      id: _id(),
      tenantId: _tenant,
      outletId: _outlet,
      deviceId: _device,
      stockLocationId: _id(),
      supplierId: s.id,
      staffId: _staff,
      number: number,
      status: PurchaseStatus.received,
      purchasedOn: DateTime.utc(2026, month, day),
      subtotal: total,
      discount: 0,
      shipping: 0,
      total: total,
      paidAmount: paid,
      dueOn: dueDay == null ? null : DateTime.utc(2026, 11, dueDay),
      hlc: '',
    );
    purchaseList.putIfAbsent(s.id, () => []).add((p, Money(total - paid)));
    return p;
  }

  /// Menambah pembelian berhutang (untuk tes).
  Purchase addPurchase(
    Supplier s,
    String number,
    int total, {
    int paid = 0,
    int dueDay = 20,
  }) => _purchase(s, number, total, paid, 4, 11, dueDay);

  Supplier byName(String name) => suppliers.firstWhere((s) => s.name == name);

  Future<Result<T>> _guard<T>(T Function() body, {Permission? needs}) async {
    await Future<void>.delayed(Duration.zero);
    if (nextError case final e?) {
      nextError = null;
      return Result.error(e);
    }
    if (!canManage && !canPay) {
      return const Result.error(NotPermitted(Permission.suppliersManage));
    }
    final allowed = switch (needs) {
      Permission.suppliersManage => canManage,
      Permission.debtsManage => canPay,
      _ => true,
    };
    if (!allowed) return Result.error(NotPermitted(needs!));
    try {
      return Result.ok(body());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  List<PayablePurchase> _open(UuidValue supplierId) {
    final list = [
      for (final (p, rest)
          in purchaseList[supplierId] ?? const <(Purchase, Money)>[])
        if (rest > Money.zero)
          PayablePurchase(
            purchase: p,
            outstanding: rest,
            overdue: isOverdue(p.dueOn, today),
          ),
    ]..sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  SupplierRow _row(Supplier s) {
    final open = _open(s.id);
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

  Supplier _find(UuidValue id) => suppliers.firstWhere(
    (s) => s.id == id,
    orElse: () => throw SupplierNotFound(),
  );

  @override
  Future<Result<SuppliersSetup>> load() async => _guard(
    () => SuppliersSetup(
      today: today,
      outletId: _outlet,
      canManage: canManage,
      canPay: canPay,
      canUseDrawer: canUseDrawer,
      hasOpenSession: hasOpenSession,
    ),
  );

  @override
  Future<Result<SuppliersOverview>> list() async => _guard(() {
    final sorted = [...suppliers]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return SuppliersOverview(
      today: today,
      rows: [for (final s in sorted) _row(s)],
    );
  });

  @override
  Future<Result<SupplierDetail>> detail(UuidValue id) async => _guard(() {
    final s = _find(id);
    return SupplierDetail(
      row: _row(s),
      open: _open(id),
      payments: [
        for (final p in payments.reversed)
          if (p.supplierId == id) p,
      ],
      today: today,
    );
  });

  @override
  Future<Result<Supplier>> save(SupplierInput input) async => _guard(
    needs: Permission.suppliersManage,
    () {
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
      final name = input.name.trim();
      if (suppliers.any(
        (s) => s.id != input.id && s.name.toLowerCase() == name.toLowerCase(),
      )) {
        throw SupplierNameTaken();
      }
      String? text(String? v) => (v ?? '').trim().isEmpty ? null : v!.trim();
      final phone = normalizePhone(input.phone ?? '');
      final s = Supplier(
        id: input.id ?? _id(),
        tenantId: _tenant,
        name: name,
        phone: phone.isEmpty ? null : phone,
        contactName: text(input.contactName),
        category: text(input.category),
        address: text(input.address),
        note: text(input.note),
        termDays: input.termDays,
        createdAt: DateTime.utc(2026, 11, 4),
        hlc: '',
      );
      final i = suppliers.indexWhere((x) => x.id == s.id);
      if (i < 0) {
        suppliers.add(s);
      } else {
        suppliers[i] = s;
      }
      return s;
    },
  );

  /// Baris yang diterima `importRows`.
  final imported = <List<SupplierImportRow>>[];

  @override
  Future<Result<SupplierImportSummary>> importRows(
    List<SupplierImportRow> rows,
  ) async => _guard(needs: Permission.suppliersManage, () {
    imported.add(rows);
    var created = 0;
    var updated = 0;
    for (final r in rows) {
      final name = r.name.trim();
      final existing = suppliers
          .where((s) => s.name.toLowerCase() == name.toLowerCase())
          .firstOrNull;
      if (existing != null) {
        updated++;
      } else {
        _supplier(
          name,
          phone: r.phone,
          contact: r.contactName,
          category: r.category,
          termDays: r.termDays ?? SupplierLimits.defaultTermDays,
        );
        created++;
      }
    }
    return SupplierImportSummary(created: created, updated: updated);
  });

  @override
  Future<Result<void>> delete(UuidValue id) async =>
      _guard(needs: Permission.suppliersManage, () {
        _find(id);
        if (_open(id).isNotEmpty) throw SupplierHasDebt();
        suppliers.removeWhere((s) => s.id == id);
      });

  @override
  Future<Result<DebtPayment>> pay(
    SupplierPaymentRequest request,
  ) async => _guard(needs: Permission.debtsManage, () {
    requests.add(request);
    final s = _find(request.supplierId);
    final drawer = request.funding == FundingSource.drawer;
    if (drawer && !canUseDrawer) {
      throw const NotPermitted(Permission.cashMovementsCreate);
    }
    if (request.paidOn.isAfter(today)) throw SupplierPaymentDateInvalid();
    if (drawer && request.paidOn != today) {
      throw SupplierPaymentDrawerDate();
    }
    final open = _open(s.id);
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
    if (drawer && !hasOpenSession) throw CashSessionNotOpen();
    final allocations =
        request.allocations ?? allocateOldestFirst(request.amount, payables);
    final list = purchaseList[s.id]!;
    for (var i = 0; i < list.length; i++) {
      final (p, rest) = list[i];
      final a = allocations[p.id];
      if (a != null) list[i] = (p, rest - a);
    }
    final total = Money.sum(open.map((p) => p.outstanding));
    final payment = DebtPayment(
      id: _id(),
      tenantId: _tenant,
      outletId: _outlet,
      deviceId: _device,
      staffId: _staff,
      party: DebtParty.supplier,
      supplierId: s.id,
      number:
          'BH-PST-K01-261104-${(payments.length + 1).toString().padLeft(4, '0')}',
      amount: request.amount.value,
      fundingSource: request.funding,
      paidOn: request.paidOn,
      cashSessionId: drawer ? _id() : null,
      balanceAfter: (total - request.amount).value,
      reference: request.reference,
      proofMediaId: request.proof == null ? null : _id(),
      note: request.note,
      createdAt: DateTime.utc(2026, 11, 4, 3),
      hlc: '',
    );
    payments.add(payment);
    _allocated[payment.id] = Map.of(allocations);
    if (request.proof case final proof?) {
      proofs[payment.id] = proof.bytes;
    }
    return payment;
  });

  final _allocated = <UuidValue, Map<UuidValue, Money>>{};

  /// Panggilan batal pembayaran: (id, alasan).
  final voids = <(UuidValue, String)>[];

  @override
  Future<Result<DebtPayment>> voidPayment(
    UuidValue paymentId,
    String reason,
  ) async => _guard(needs: Permission.debtsManage, () {
    voids.add((paymentId, reason));
    if (!validateDebtPaymentVoidReason(reason)) {
      throw DebtPaymentVoidReasonInvalid();
    }
    final i = payments.indexWhere((p) => p.id == paymentId);
    if (i < 0) throw DebtPaymentNotFound();
    final p = payments[i];
    if (p.voidedAt != null) throw DebtPaymentAlreadyVoided();
    final drawer = debtPaymentTouchesDrawer(p);
    if (drawer && !canUseDrawer) {
      throw const NotPermitted(Permission.cashMovementsCreate);
    }
    if (drawer && !hasOpenSession) throw CashSessionNotOpen();
    final list = purchaseList[p.supplierId] ?? [];
    final allocations = _allocated.remove(p.id) ?? const {};
    for (var j = 0; j < list.length; j++) {
      final (purchase, rest) = list[j];
      if (allocations[purchase.id] case final a?) {
        list[j] = (purchase, rest + a);
      }
    }
    return payments[i] = p.copyWith(
      voidedAt: DateTime.utc(2026, 11, 4, 4),
      voidedBy: _staff,
      voidReason: reason.trim(),
    );
  });

  @override
  Future<Result<List<PurchaseRow>>> purchases(
    UuidValue supplierId,
  ) async => _guard(() {
    final s = _find(supplierId);
    final rows = [
      for (final (p, rest)
          in purchaseList[supplierId] ?? const <(Purchase, Money)>[])
        PurchaseRow(
          purchase: p,
          supplierName: s.name,
          returned: Money.zero,
          debt: rest,
        ),
    ]..sort((a, b) => b.purchase.purchasedOn.compareTo(a.purchase.purchasedOn));
    return rows;
  });

  @override
  Future<Result<Uint8List?>> proof(UuidValue paymentId) async =>
      _guard(() => proofs[paymentId]);
}
