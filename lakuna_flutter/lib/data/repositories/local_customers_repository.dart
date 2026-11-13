import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_data/lakuna_data.dart' as data;
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';
import 'customers_repository.dart';
import 'session_repository.dart';
import 'store_repository.dart';

/// [CustomersRepository] di atas database perangkat.
class LocalCustomersRepository extends CustomersRepository {
  LocalCustomersRepository(
    this._store, {
    required this._stores,
    required this._session,
    required this._preferences,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;
  final LocalPreferences _preferences;
  final DateTime Function() _clock;

  DateTime get _now => _clock().toUtc();

  @override
  Future<Result<CustomersSetup>> load() => _guard((ctx, scope, staff) async {
    return CustomersSetup(
      today: await outletToday(_store.session, scope, _now),
      businessName: ctx.tenant.name,
      outletName: ctx.outlet.name,
      outletAddress: ctx.outlet.address,
      outletPhone: ctx.outlet.phone,
      timezone: ctx.outlet.timezone ?? ctx.tenant.timezone,
      outletId: ctx.outlet.id,
      canManage: staff.can(Permission.customersManage),
      canReceive: staff.can(Permission.debtsManage),
      hasOpenSession:
          await findOpenCashSession(_store, CashScope.of(ctx)) != null,
      receipt: await loadReceiptConfig(_store, scope),
      printer: await loadPrinterSelection(_preferences),
    );
  });

  @override
  Future<Result<CustomersOverview>> list() =>
      _guard((_, scope, _) => listCustomers(_store, scope, now: _now));

  @override
  Future<Result<CustomerDetail>> detail(UuidValue id) =>
      _guard((_, scope, _) => loadCustomerDetail(_store, scope, id, now: _now));

  @override
  Future<Result<Customer>> save(CustomerInput input) => _guard(
    permission: Permission.customersManage,
    (_, scope, staff) =>
        saveCustomer(_store, scope, staffId: staff.id, input: input),
  );

  @override
  Future<Result<void>> delete(UuidValue id) => _guard(
    permission: Permission.customersManage,
    (_, scope, staff) =>
        deleteCustomer(_store, scope, staffId: staff.id, customerId: id),
  );

  @override
  Future<Result<List<CustomerGroupRow>>> groups() =>
      _guard((_, scope, _) => listCustomerGroups(_store, scope));

  @override
  Future<Result<CustomerGroup>> saveGroup({
    UuidValue? id,
    required String name,
    required int termDays,
  }) => _guard(
    permission: Permission.customersManage,
    (_, scope, staff) => saveCustomerGroup(
      _store,
      scope,
      staffId: staff.id,
      id: id,
      name: name,
      termDays: termDays,
    ),
  );

  @override
  Future<Result<void>> deleteGroup(UuidValue id) => _guard(
    permission: Permission.customersManage,
    (_, scope, staff) =>
        deleteCustomerGroup(_store, scope, staffId: staff.id, groupId: id),
  );

  @override
  Future<Result<DebtPayment>> receivePayment(DebtPaymentRequest request) =>
      _guard(
        permission: Permission.debtsManage,
        (_, scope, staff) => receiveDebtPayment(
          _store,
          scope,
          staffId: staff.id,
          request: request,
        ),
      );

  @override
  Future<Result<DebtPayment>> voidPayment(UuidValue paymentId, String reason) =>
      _guard(permission: Permission.debtsManage, (_, scope, staff) async {
        // Batal tunai laci mengeluarkan uang dari laci: izinnya sama dengan
        // gerakan kas.
        final p = await DebtPayment.db.findById(_store.session, paymentId);
        if (p != null &&
            debtPaymentTouchesDrawer(p) &&
            !staff.can(Permission.cashMovementsCreate)) {
          throw const NotPermitted(Permission.cashMovementsCreate);
        }
        return voidDebtPayment(
          _store,
          scope,
          staffId: staff.id,
          paymentId: paymentId,
          reason: reason,
        );
      });

  @override
  Future<Result<DebtPaymentReceipt>> receipt(UuidValue paymentId) =>
      _guard((_, scope, _) => loadDebtPaymentReceipt(_store, scope, paymentId));

  @override
  Future<Result<CustomerImportSummary>> importRows(
    List<CustomerImportRow> rows,
  ) => _guard(
    permission: Permission.customersManage,
    (_, scope, staff) =>
        data.importCustomers(_store, scope, staffId: staff.id, rows: rows),
  );

  Future<Result<T>> _guard<T>(
    Future<T> Function(StoreContext ctx, CatalogScope scope, StaffProfile staff)
    body, {
    Permission? permission,
  }) async {
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    final staff = _session.current;
    if (staff == null ||
        !(staff.can(Permission.customersManage) ||
            staff.can(Permission.debtsManage))) {
      return const Result.error(NotPermitted(Permission.customersManage));
    }
    if (permission != null && !staff.can(permission)) {
      return Result.error(NotPermitted(permission));
    }
    try {
      return Result.ok(await body(ctx, CatalogScope.of(ctx), staff));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
