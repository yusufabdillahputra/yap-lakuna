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
  });

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;

  @override
  Future<Result<CashierData>> load() => _guard((ctx, staff) async {
    final scope = CatalogScope.of(ctx);
    final products = [
      for (final p in await listProducts(_store, scope))
        if (p.isActive && p.variants.isNotEmpty) p,
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final used = {for (final p in products) p.categoryId};
    final categories = [
      for (final c in await listCategories(_store, scope))
        if (used.contains(c.id)) c,
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
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
    return CashierData(
      products: products,
      categories: categories,
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
    );
  });

  @override
  Future<Result<CheckoutResult>> checkout({
    required List<SaleLineRequest> lines,
    required List<SalePaymentRequest> payments,
  }) => _guard((ctx, staff) {
    if (payments.any((p) => p.method == PaymentMethod.qrisStatic) &&
        !staff.can(Permission.paymentsConfirm)) {
      throw const NotPermitted(Permission.paymentsConfirm);
    }
    return checkoutSale(
      _store,
      CatalogScope.of(ctx),
      staffId: staff.id,
      lines: lines,
      payments: payments,
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
