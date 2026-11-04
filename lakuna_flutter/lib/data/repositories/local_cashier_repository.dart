import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

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
    final qris = await loadQrisConfig(_store, scope);
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
            )
          : null,
      canConfirmPayments: staff.can(Permission.paymentsConfirm),
      canSellOnCredit: staff.can(Permission.debtsManage),
      canDiscount: staff.can(Permission.salesDiscount),
      receipt: await loadReceiptConfig(_store, scope),
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
  }) => _guard((ctx, staff) async {
    if (payments.any((p) => p.method == PaymentMethod.qrisStatic) &&
        !staff.can(Permission.paymentsConfirm)) {
      throw const NotPermitted(Permission.paymentsConfirm);
    }
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
    );
    if (discountApproverId != null) {
      _session.consumeApproval(discountApproverId, Permission.salesDiscount);
    }
    return result;
  });

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
    List<SalePaymentRequest> payments,
  ) => _guard((ctx, staff) {
    if (payments.any((p) => p.method == PaymentMethod.qrisStatic) &&
        !staff.can(Permission.paymentsConfirm)) {
      throw const NotPermitted(Permission.paymentsConfirm);
    }
    return payOpenBill(
      _store,
      CatalogScope.of(ctx),
      staffId: staff.id,
      billId: billId,
      payments: payments,
    );
  });

  @override
  Future<Result<SplitPayResult>> payBillPart(
    UuidValue billId, {
    String? guest,
    Money? amount,
    required List<SalePaymentRequest> payments,
    bool pending = false,
  }) => _guard((ctx, staff) {
    if (!pending &&
        payments.any((p) => p.method == PaymentMethod.qrisStatic) &&
        !staff.can(Permission.paymentsConfirm)) {
      throw const NotPermitted(Permission.paymentsConfirm);
    }
    return paySplitPart(
      _store,
      CatalogScope.of(ctx),
      staffId: staff.id,
      billId: billId,
      guest: guest,
      amount: amount,
      payments: payments,
      pending: pending,
    );
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
