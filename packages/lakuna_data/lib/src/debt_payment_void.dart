import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import 'customers.dart' show DebtPaymentNotFound, requireCustomerActor;
import 'sale_core.dart' show requireOpenCashSession;
import 'stock.dart';
import 'store.dart';
import 'suppliers.dart' show requireSupplierActor;

// Batal pembayaran piutang pelanggan (`BP-`) dan hutang supplier (`BH-`)
// (F1-13c). Pembayaran tetap ada dengan jejak batal; alokasinya
// di-soft-delete sehingga sisa nota/pembelian kembali, dan uang laci
// dijurnal balik di sesi kasir yang sedang terbuka di perangkat ini.

/// `cash_movements.source` kas keluar saat batal terima piutang tunai.
const debtPaymentVoidCashSource = 'debt_payment_void';

/// `cash_movements.source` kas masuk saat batal bayar hutang dari laci.
const supplierPaymentVoidCashSource = 'supplier_payment_void';

class DebtPaymentAlreadyVoided implements Exception {
  @override
  String toString() => 'DebtPaymentAlreadyVoided';
}

class DebtPaymentVoidReasonInvalid implements Exception {
  @override
  String toString() => 'DebtPaymentVoidReasonInvalid';
}

/// Pembayaran [payment] masuk/keluar laci: piutang tunai yang tercatat di
/// sesi kasir, atau hutang yang dibayar dari laci.
bool debtPaymentTouchesDrawer(DebtPayment payment) => switch (payment.party) {
  DebtParty.customer => payment.cashSessionId != null,
  DebtParty.supplier => payment.fundingSource == FundingSource.drawer,
};

/// Membatalkan pembayaran piutang/hutang [paymentId] dengan [reason].
Future<DebtPayment> voidDebtPayment(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue paymentId,
  required String reason,
}) async {
  if (!validateDebtPaymentVoidReason(reason)) {
    throw DebtPaymentVoidReasonInvalid();
  }
  final existing = await DebtPayment.db.findById(store.session, paymentId);
  if (existing == null ||
      existing.tenantId != scope.tenantId ||
      existing.outletId != scope.outletId ||
      existing.deletedAt != null) {
    throw DebtPaymentNotFound();
  }
  // Pihak yang sudah dihapus (saldonya nol saat dihapus) tidak boleh
  // kembali berpiutang/berhutang.
  final party = switch (existing.party) {
    DebtParty.customer => (await Customer.db.findById(
      store.session,
      existing.customerId!,
    ))?.deletedAt,
    DebtParty.supplier => (await Supplier.db.findById(
      store.session,
      existing.supplierId!,
    ))?.deletedAt,
  };
  if (party != null) throw DebtPaymentNotFound();
  final drawer = debtPaymentTouchesDrawer(existing);
  switch (existing.party) {
    case DebtParty.customer:
      await requireCustomerActor(store, scope, staffId, Permission.debtsManage);
      if (drawer) {
        await requireCustomerActor(
          store,
          scope,
          staffId,
          Permission.cashMovementsCreate,
        );
      }
    case DebtParty.supplier:
      await requireSupplierActor(store, scope, staffId, [
        Permission.debtsManage,
        if (drawer) Permission.cashMovementsCreate,
      ]);
  }
  return store.write(actor: staffId, (w) async {
    final p = await DebtPayment.db.findById(
      w.session,
      paymentId,
      transaction: w.transaction,
    );
    if (p == null || p.deletedAt != null) throw DebtPaymentNotFound();
    if (p.voidedAt != null) throw DebtPaymentAlreadyVoided();
    final s = await w.stamp();
    final cash = drawer ? await requireOpenCashSession(store, w, scope) : null;
    final customer = p.party == DebtParty.customer;
    final movement = cash == null
        ? null
        : await w.insert(
            CashMovement(
              tenantId: scope.tenantId,
              outletId: scope.outletId,
              cashSessionId: cash.id,
              direction: customer
                  ? CashDirection.outflow
                  : CashDirection.inflow,
              amount: p.amount,
              note: 'Batal ${p.number}',
              source: customer
                  ? debtPaymentVoidCashSource
                  : supplierPaymentVoidCashSource,
              createdAt: s.now,
              updatedAt: s.now,
              createdBy: staffId,
              updatedBy: staffId,
              hlc: s.hlc.toString(),
              originDeviceId: s.deviceId,
            ),
            s,
          );
    final allocations = await DebtPaymentAllocation.db.find(
      w.session,
      where: (a) =>
          a.tenantId.equals(scope.tenantId) &
          a.debtPaymentId.equals(p.id) &
          a.deletedAt.equals(null),
      transaction: w.transaction,
    );
    for (final a in allocations) {
      await w.update(
        a.copyWith(
          deletedAt: s.now,
          version: a.version + 1,
          updatedAt: s.now,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    }
    return w.update(
      p.copyWith(
        voidedAt: s.now,
        voidedBy: staffId,
        voidReason: reason.trim(),
        voidCashMovementId: movement?.id,
        version: p.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  });
}
