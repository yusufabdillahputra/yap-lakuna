import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/expenses_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

UuidValue _id() => UuidValue.fromString(newId());

/// Pengeluaran palsu di memori (F1-15), meniru aturan `lakuna_data`:
/// validasi, nomor EX, kas laci butuh sesi dan tanggal hari ini, batal
/// dengan alasan, jenis unik dan tidak bisa dihapus bila dipakai.
class FakeExpensesRepository extends ExpensesRepository {
  FakeExpensesRepository({
    this.canManage = true,
    this.canUseDrawer = true,
    this.hasOpenSession = true,
    bool seed = true,
  }) {
    for (final name in defaultExpenseCategories) {
      _category(name);
    }
    if (!seed) return;
    _seed(
      'Sewa tempat November',
      2500000,
      'Sewa tempat',
      10,
      30,
      FundingSource.bank,
      receipt: true,
    );
    _seed(
      'Plastik kresek & cup',
      120000,
      'Plastik & kemasan',
      10,
      31,
      FundingSource.storeCash,
      receipt: true,
    );
    _seed(
      'Bensin antar barang',
      50000,
      'Transport',
      11,
      1,
      FundingSource.storeCash,
    );
    _seed(
      'Token listrik',
      500000,
      'Listrik & air',
      11,
      1,
      FundingSource.bank,
      receipt: true,
    );
    _seed(
      'Beli es batu',
      80000,
      'Bahan habis pakai',
      11,
      2,
      FundingSource.drawer,
      receipt: true,
    );
  }

  bool canManage;
  bool canUseDrawer;
  bool hasOpenSession;
  final _tenant = _id();
  final _outlet = _id();
  final _device = _id();
  final _staff = _id();
  final today = DateTime.utc(2026, 11, 4);

  final categoryList = <ExpenseCategory>[];
  final expenses = <Expense>[];
  final requests = <ExpenseRequest>[];
  final receipts = <UuidValue, Uint8List>{};

  /// Dipanggil saat pengeluaran kas laci tercatat (mis. menulis gerakan
  /// kas di [FakeCashDrawerRepository]).
  void Function(Expense expense, String categoryName)? onDrawerExpense;

  /// Galat berikutnya untuk aksi apa pun (sekali pakai).
  Exception? nextError;

  ExpenseCategory _category(String name) {
    final c = ExpenseCategory(
      id: _id(),
      tenantId: _tenant,
      name: name,
      hlc: '',
    );
    categoryList.add(c);
    return c;
  }

  ExpenseCategory categoryByName(String name) =>
      categoryList.firstWhere((c) => c.name == name);

  void _seed(
    String description,
    int amount,
    String category,
    int month,
    int day,
    FundingSource funding, {
    bool receipt = false,
  }) {
    final e = Expense(
      id: _id(),
      tenantId: _tenant,
      outletId: _outlet,
      deviceId: _device,
      staffId: _staff,
      expenseCategoryId: categoryByName(category).id,
      number:
          'EX-PST-K01-26${month.toString().padLeft(2, '0')}'
          '${day.toString().padLeft(2, '0')}-0001',
      spentOn: DateTime.utc(2026, month, day),
      description: description,
      amount: amount,
      fundingSource: funding,
      cashSessionId: funding == FundingSource.drawer ? _id() : null,
      receiptMediaId: receipt ? _id() : null,
      createdAt: DateTime.utc(2026, month, day, 3),
      hlc: '',
    );
    expenses.add(e);
  }

  Expense byDescription(String d) =>
      expenses.firstWhere((e) => e.description == d);

  Future<Result<T>> _guard<T>(T Function() body) async {
    await Future<void>.delayed(Duration.zero);
    if (nextError case final e?) {
      nextError = null;
      return Result.error(e);
    }
    if (!canManage) {
      return const Result.error(NotPermitted(Permission.expensesManage));
    }
    try {
      return Result.ok(body());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  List<ExpenseCategory> get _active =>
      [...categoryList]
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  ExpenseRow _row(Expense e) => ExpenseRow(
    expense: e,
    categoryName:
        categoryList
            .where((c) => c.id == e.expenseCategoryId)
            .firstOrNull
            ?.name ??
        '',
    staffName: 'Yusuf',
    sessionStaffName: e.cashSessionId == null ? null : 'Sari',
    voidedByName: e.voidedBy == null ? null : 'Yusuf',
  );

  @override
  Future<Result<ExpensesSetup>> load() async => _guard(
    () => ExpensesSetup(
      today: today,
      categories: _active,
      canUseDrawer: canUseDrawer,
      hasOpenSession: hasOpenSession,
    ),
  );

  @override
  Future<Result<List<ExpenseRow>>> list(DateRange range) async => _guard(() {
    final rows =
        [
          for (final e in expenses)
            if (range.contains(e.spentOn)) _row(e),
        ]..sort((a, b) {
          final d = b.expense.spentOn.compareTo(a.expense.spentOn);
          return d != 0
              ? d
              : b.expense.createdAt.compareTo(a.expense.createdAt);
        });
    return rows;
  });

  @override
  Future<Result<Expense>> record(ExpenseRequest request) async => _guard(() {
    requests.add(request);
    final issues = validateExpense(
      description: request.description,
      hasCategory: request.categoryId != null,
      amount: request.amount,
    );
    if (issues.isNotEmpty) throw ExpenseInvalid(issues);
    final drawer = request.funding == FundingSource.drawer;
    if (drawer && !canUseDrawer) {
      throw const NotPermitted(Permission.cashMovementsCreate);
    }
    final spentOn = drawer ? today : request.spentOn;
    if (spentOn.isAfter(today)) throw ExpenseDateInvalid();
    if (drawer && !hasOpenSession) throw CashSessionNotOpen();
    final e = Expense(
      id: _id(),
      tenantId: _tenant,
      outletId: _outlet,
      deviceId: _device,
      staffId: _staff,
      expenseCategoryId: request.categoryId!,
      number:
          'EX-PST-K01-261104-${(expenses.length + 1).toString().padLeft(4, '0')}',
      spentOn: spentOn,
      description: request.description.trim(),
      amount: request.amount.value,
      fundingSource: request.funding,
      cashSessionId: drawer ? _id() : null,
      cashMovementId: drawer ? _id() : null,
      receiptMediaId: request.receipt == null ? null : _id(),
      createdAt: DateTime.utc(2026, 11, 4, 3, expenses.length),
      hlc: '',
    );
    expenses.add(e);
    if (request.receipt case final r?) receipts[e.id] = r.bytes;
    if (drawer) onDrawerExpense?.call(e, _row(e).categoryName);
    return e;
  });

  @override
  Future<Result<ExpenseRow>> detail(UuidValue id) async => _guard(() {
    final e = expenses.where((e) => e.id == id).firstOrNull;
    if (e == null) throw ExpenseNotFound();
    return _row(e);
  });

  @override
  Future<Result<Expense>> cancel(UuidValue id, String reason) async =>
      _guard(() {
        if (!validateExpenseVoidReason(reason)) {
          throw ExpenseVoidReasonInvalid();
        }
        final i = expenses.indexWhere((e) => e.id == id);
        if (i < 0) throw ExpenseNotFound();
        final e = expenses[i];
        if (e.voidedAt != null) throw ExpenseAlreadyVoided();
        if (e.fundingSource == FundingSource.drawer && !canUseDrawer) {
          throw const NotPermitted(Permission.cashMovementsCreate);
        }
        if (e.fundingSource == FundingSource.drawer && !hasOpenSession) {
          throw CashSessionNotOpen();
        }
        final v = e.copyWith(
          voidedAt: DateTime.utc(2026, 11, 4, 5),
          voidedBy: _staff,
          voidReason: reason.trim(),
        );
        expenses[i] = v;
        return v;
      });

  @override
  Future<Result<Uint8List?>> receipt(UuidValue id) async =>
      _guard(() => receipts[id]);

  @override
  Future<Result<List<ExpenseCategoryRow>>> categories() async => _guard(
    () => [
      for (final c in _active)
        ExpenseCategoryRow(
          category: c,
          usage: expenses.where((e) => e.expenseCategoryId == c.id).length,
        ),
    ],
  );

  @override
  Future<Result<ExpenseCategory>> saveCategory({
    UuidValue? id,
    required String name,
  }) async => _guard(() {
    if (!validateExpenseCategoryName(name)) throw ExpenseCategoryInvalid();
    final clean = name.trim();
    if (categoryList.any(
      (c) => c.id != id && c.name.toLowerCase() == clean.toLowerCase(),
    )) {
      throw ExpenseCategoryNameTaken();
    }
    if (id != null) {
      final i = categoryList.indexWhere((c) => c.id == id);
      if (i < 0) throw ExpenseCategoryNotFound();
      return categoryList[i] = categoryList[i].copyWith(name: clean);
    }
    return _category(clean);
  });

  @override
  Future<Result<void>> deleteCategory(UuidValue id) async => _guard(() {
    if (expenses.any((e) => e.expenseCategoryId == id)) {
      throw ExpenseCategoryInUse();
    }
    categoryList.removeWhere((c) => c.id == id);
  });
}
