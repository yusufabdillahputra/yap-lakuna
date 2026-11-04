import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';
import 'expenses_repository.dart';
import 'session_repository.dart';
import 'store_repository.dart';

/// [ExpensesRepository] di atas database perangkat.
class LocalExpensesRepository extends ExpensesRepository {
  LocalExpensesRepository(
    this._store, {
    required this._stores,
    required this._session,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;
  final DateTime Function() _clock;

  @override
  Future<Result<ExpensesSetup>> load() => _guard((ctx, scope, staff) async {
    await ensureExpenseCategories(_store, scope, staffId: staff.id);
    final categories = await listExpenseCategories(_store, scope);
    return ExpensesSetup(
      today: await outletToday(_store.session, scope, _clock().toUtc()),
      categories: [for (final c in categories) c.category],
      canUseDrawer: staff.can(Permission.cashMovementsCreate),
      hasOpenSession:
          await findOpenCashSession(_store, CashScope.of(ctx)) != null,
    );
  });

  @override
  Future<Result<List<ExpenseRow>>> list(DateRange range) =>
      _guard((_, scope, _) => listExpenses(_store, scope, range));

  @override
  Future<Result<Expense>> record(ExpenseRequest request) {
    if (request.funding == FundingSource.drawer &&
        !(_session.current?.can(Permission.cashMovementsCreate) ?? false) &&
        (_session.current?.can(Permission.expensesManage) ?? false)) {
      return Future.value(
        const Result.error(NotPermitted(Permission.cashMovementsCreate)),
      );
    }
    return _guard(
      (_, scope, staff) =>
          recordExpense(_store, scope, staffId: staff.id, request: request),
    );
  }

  @override
  Future<Result<ExpenseRow>> detail(UuidValue id) =>
      _guard((_, scope, _) => loadExpense(_store, scope, id));

  @override
  Future<Result<Expense>> cancel(UuidValue id, String reason) =>
      _guard((_, scope, staff) async {
        // Batal kas laci mengembalikan uang ke laci, jadi butuh izin yang
        // sama dengan mencatatnya.
        final row = await loadExpense(_store, scope, id);
        if (row.expense.fundingSource == FundingSource.drawer &&
            !staff.can(Permission.cashMovementsCreate)) {
          throw const NotPermitted(Permission.cashMovementsCreate);
        }
        return voidExpense(
          _store,
          scope,
          staffId: staff.id,
          expenseId: id,
          reason: reason,
        );
      });

  @override
  Future<Result<Uint8List?>> receipt(UuidValue id) =>
      _guard((_, scope, _) => loadExpenseReceipt(_store, scope, id));

  @override
  Future<Result<List<ExpenseCategoryRow>>> categories() =>
      _guard((_, scope, staff) async {
        await ensureExpenseCategories(_store, scope, staffId: staff.id);
        return listExpenseCategories(_store, scope);
      });

  @override
  Future<Result<ExpenseCategory>> saveCategory({
    UuidValue? id,
    required String name,
  }) => _guard(
    (_, scope, staff) => saveExpenseCategory(
      _store,
      scope,
      staffId: staff.id,
      id: id,
      name: name,
    ),
  );

  @override
  Future<Result<void>> deleteCategory(UuidValue id) => _guard(
    (_, scope, staff) => deleteExpenseCategory(
      _store,
      scope,
      staffId: staff.id,
      categoryId: id,
    ),
  );

  Future<Result<T>> _guard<T>(
    Future<T> Function(StoreContext ctx, CatalogScope scope, StaffProfile staff)
    body,
  ) async {
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    final staff = _session.current;
    if (staff == null || !staff.can(Permission.expensesManage)) {
      return const Result.error(NotPermitted(Permission.expensesManage));
    }
    try {
      return Result.ok(await body(ctx, CatalogScope.of(ctx), staff));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
