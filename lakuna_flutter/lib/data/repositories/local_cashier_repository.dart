import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/log_error.dart';
import '../../utils/result.dart';
import 'cashier_repository.dart';
import 'session_repository.dart';
import 'store_repository.dart';

/// [CashierRepository] di atas database perangkat.
class LocalCashierRepository extends CashierRepository {
  LocalCashierRepository(
    this._store, {
    required this._stores,
    required this._session,
    required this._preferences,
  });

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;
  final LocalPreferences _preferences;

  @override
  Future<Result<CashierData>> load() => _guard((ctx, staff) async {
    final scope = CatalogScope.of(ctx);
    final products = [
      for (final p in await listProducts(_store, scope))
        if (p.isActive && p.variants.isNotEmpty) p,
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final all = await listCategories(_store, scope);
    final categories = cashierCategories(all, {
      for (final p in products) p.categoryId,
    });
    final open = await findOpenCashSession(_store, CashScope.of(ctx));
    CashierSession? session;
    if (open != null) {
      final opener = await StaffMember.db.findFirstRow(
        _store.session,
        where: (s) =>
            s.id.equals(open.openedBy) & s.tenantId.equals(ctx.tenant.id),
      );
      session = CashierSession(
        id: open.id,
        openedAt: open.openedAt,
        openedByName: opener?.name ?? '',
      );
    }
    final qris = await loadQrisConfig(_store, scope, onError: logQrisError);
    final salesRules = await loadSalesRules(_store.session, scope);
    return CashierData(
      salesRules: salesRules,
      products: products,
      categories: categories,
      categoryParents: {
        for (final c in all)
          if (c.parentId != null) c.id: c.parentId!,
      },
      businessName: ctx.tenant.name,
      outletName: ctx.outlet.name,
      staffName: staff.name,
      timezone: ctx.outlet.timezone ?? ctx.tenant.timezone,
      session: session,
      qris: qris.isUsable
          ? CashierQris(
              image: qris.imageBytes!,
              merchantName: qris.settings.merchantName,
              nmid: qris.settings.nmid,
              terminalCode: qris.settings.terminalCode,
              settlementNote: qris.settings.settlementNote,
              showOnPhone: qris.settings.showOnPhone,
            )
          : null,
      canConfirmPayments: canConfirmQrisDirectly(
        staff.permissions,
        cashierWithoutPin: qris.settings.cashierConfirmWithoutPin,
      ),
      qrisWithoutPin: qris.settings.cashierConfirmWithoutPin,
      canSellOnCredit: staff.can(Permission.debtsManage),
      canDiscount: staff.can(Permission.salesDiscount),
      canAddCustomer: staff.can(Permission.customersManage),
      receipt: await loadReceiptConfigOrDefault(
        _store,
        scope,
        onError: logReceiptError,
      ),
      printer: await loadPrinterSelection(_preferences),
    );
  });

  @override
  Future<Result<CheckoutResult>> checkout({
    required List<SaleLineRequest> lines,
    required List<SalePaymentRequest> payments,
    SaleCredit? credit,
    ManualDiscount? discount,
    UuidValue? discountApproverId,
    UuidValue? customerId,
    UuidValue? parkedSaleId,
    UuidValue? qrisApproverId,
  }) => _guard((ctx, staff) async {
    _requireQrisApproval(qrisApproverId);
    if (credit != null && !staff.can(Permission.debtsManage)) {
      throw const NotPermitted(Permission.debtsManage);
    }
    // Id penyetuju saja tidak cukup: PIN-nya harus baru diperiksa di sini.
    if (discountApproverId != null &&
        !_session.hasApproval(discountApproverId, Permission.salesDiscount)) {
      throw const NotPermitted(Permission.salesDiscount);
    }
    final result = await checkoutSale(
      _store,
      CatalogScope.of(ctx),
      staffId: staff.id,
      lines: lines,
      payments: payments,
      credit: credit,
      discount: discount,
      discountApproverId: discountApproverId,
      customerId: customerId,
      parkedSaleId: parkedSaleId,
      qrisApproverId: qrisApproverId,
    );
    if (discountApproverId != null) {
      _session.consumeApproval(discountApproverId, Permission.salesDiscount);
    }
    _consumeQrisApproval(qrisApproverId);
    return result;
  });

  /// Penyetuju QRIS (F1-05h) harus baru memasukkan PIN-nya; aturan siapa
  /// yang boleh menyetujui diperiksa lapisan data.
  void _requireQrisApproval(UuidValue? approverId) {
    if (approverId != null &&
        !_session.hasApproval(approverId, Permission.paymentsConfirm)) {
      throw const NotPermitted(Permission.paymentsConfirm);
    }
  }

  void _consumeQrisApproval(UuidValue? approverId) {
    if (approverId != null) {
      _session.consumeApproval(approverId, Permission.paymentsConfirm);
    }
  }

  @override
  Future<Result<CustomersOverview>> creditCustomers() => _guard((ctx, staff) {
    if (!staff.can(Permission.debtsManage)) {
      throw const NotPermitted(Permission.debtsManage);
    }
    return listCustomers(_store, CatalogScope.of(ctx));
  });

  @override
  Future<Result<CustomersOverview>> customers() =>
      _guard((ctx, _) => listCustomers(_store, CatalogScope.of(ctx)));

  @override
  Future<Result<Sale>> park({
    required List<SaleLineRequest> lines,
    ManualDiscount? discount,
    UuidValue? customerId,
    String? note,
    UuidValue? replaceId,
  }) => _guard(
    (ctx, staff) => parkSale(
      _store,
      CatalogScope.of(ctx),
      staffId: staff.id,
      lines: lines,
      discount: discount,
      customerId: customerId,
      note: note,
      replaceId: replaceId,
    ),
  );

  @override
  Future<Result<List<ParkedSaleRow>>> parkedSales() => _guard(
    (ctx, _) => listParkedSales(_store.session, CatalogScope.of(ctx)),
  );

  @override
  Future<Result<ParkedSale>> loadParked(UuidValue id) => _guard(
    (ctx, _) => loadParkedSale(_store.session, CatalogScope.of(ctx), id),
  );

  @override
  Future<Result<void>> deleteParked(UuidValue id) => _guard(
    (ctx, staff) => deleteParkedSale(
      _store,
      CatalogScope.of(ctx),
      staffId: staff.id,
      id: id,
    ),
  );

  @override
  Future<Result<OpenBill>> loadBill(UuidValue billId) => _guard(
    (ctx, _) => loadOpenBill(_store, CatalogScope.of(ctx), billId),
  );

  @override
  Future<Result<CheckoutResult>> payBill(
    UuidValue billId,
    List<SalePaymentRequest> payments, {
    SaleCredit? credit,
    UuidValue? qrisApproverId,
  }) => _guard((ctx, staff) async {
    _requireQrisApproval(qrisApproverId);
    if (credit != null && !staff.can(Permission.debtsManage)) {
      throw const NotPermitted(Permission.debtsManage);
    }
    final result = await payOpenBill(
      _store,
      CatalogScope.of(ctx),
      staffId: staff.id,
      billId: billId,
      payments: payments,
      credit: credit,
      qrisApproverId: qrisApproverId,
    );
    _consumeQrisApproval(qrisApproverId);
    return result;
  });

  @override
  Future<Result<SplitPayResult>> payBillPart(
    UuidValue billId, {
    String? guest,
    Money? amount,
    required List<SalePaymentRequest> payments,
    bool pending = false,
    SaleCredit? credit,
    UuidValue? qrisApproverId,
  }) => _guard((ctx, staff) async {
    if (credit != null && !staff.can(Permission.debtsManage)) {
      throw const NotPermitted(Permission.debtsManage);
    }
    _requireQrisApproval(qrisApproverId);
    final result = await paySplitPart(
      _store,
      CatalogScope.of(ctx),
      staffId: staff.id,
      billId: billId,
      guest: guest,
      amount: amount,
      payments: payments,
      pending: pending,
      credit: credit,
      qrisApproverId: qrisApproverId,
    );
    _consumeQrisApproval(qrisApproverId);
    return result;
  });

  Future<Result<T>> _guard<T>(
    Future<T> Function(StoreContext ctx, StaffProfile staff) body,
  ) async {
    const permission = Permission.salesCreate;
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    final staff = _session.current;
    if (staff == null || !staff.can(permission)) {
      return const Result.error(NotPermitted(permission));
    }
    try {
      return Result.ok(await body(ctx, staff));
    } on Exception catch (e) {
      return Result.error(e);
    } on StateError catch (e) {
      // Data toko tidak lengkap (cabang/perangkat/lokasi stok hilang):
      // tampilkan sebagai galat, jangan biarkan Command menggantung.
      return Result.error(Exception(e.message));
    }
  }
}
