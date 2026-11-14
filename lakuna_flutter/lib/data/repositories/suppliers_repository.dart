import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';

export 'repository_errors.dart';

/// Data awal layar Supplier & hutang (F1-14, 1.21).
@immutable
class SuppliersSetup {
  const SuppliersSetup({
    required this.today,
    this.outletId,
    this.canManage = false,
    this.canPay = false,
    this.canUseDrawer = false,
    this.hasOpenSession = false,
    this.drawerCash,
  });

  /// Tanggal lokal cabang hari ini (UTC tengah malam).
  final DateTime today;

  /// Cabang aktif: pembayaran cabang lain tidak bisa dibatalkan di sini.
  final UuidValue? outletId;

  /// Staf punya `suppliers:manage` (tambah, ubah, hapus).
  final bool canManage;

  /// Staf punya `debts:manage` (bayar hutang).
  final bool canPay;

  /// Staf punya `cash_movements:create` (bayar dari kas laci).
  final bool canUseDrawer;

  /// Perangkat ini punya sesi kasir terbuka.
  final bool hasOpenSession;

  /// Perkiraan uang di laci sesi terbuka (*Kas seharusnya*), `null` tanpa
  /// sesi. Untuk peringatan uang laci tidak cukup (F1-03c).
  final Money? drawerCash;
}

/// Supplier dan pembayaran hutang (F1-14). Membuka modul butuh
/// `suppliers:manage` atau `debts:manage`; aksi tulis dicek per izin di sini
/// juga.
abstract class SuppliersRepository {
  Future<Result<SuppliersSetup>> load();

  Future<Result<SuppliersOverview>> list();

  /// Gagal dengan `SupplierNotFound`.
  Future<Result<SupplierDetail>> detail(UuidValue id);

  /// `suppliers:manage`. Gagal dengan `SupplierInvalid` atau
  /// `SupplierNameTaken`.
  Future<Result<Supplier>> save(SupplierInput input);

  /// `suppliers:manage`. Import baris berkas (F1-14b) dalam satu transaksi;
  /// gagal dengan `SupplierInvalid` bila ada baris salah.
  Future<Result<SupplierImportSummary>> importRows(
    List<SupplierImportRow> rows,
  );

  /// `suppliers:manage`. Ditolak (`SupplierHasDebt`) bila masih berhutang.
  Future<Result<void>> delete(UuidValue id);

  /// `debts:manage` (+ `cash_movements:create` untuk laci). Gagal dengan
  /// `SupplierPaymentInvalid`, `SupplierPaymentDateInvalid`,
  /// `SupplierPaymentDrawerDate`, `SupplierPaymentProofInvalid`, atau
  /// `CashSessionNotOpen`.
  Future<Result<DebtPayment>> pay(SupplierPaymentRequest request);

  /// `debts:manage` (+ `cash_movements:create` bila dari laci). Gagal
  /// dengan `DebtPaymentAlreadyVoided`, `DebtPaymentVoidReasonInvalid`,
  /// `DebtPaymentNotFound`, atau `CashSessionNotOpen` (F1-13c).
  Future<Result<DebtPayment>> voidPayment(UuidValue paymentId, String reason);

  /// Semua pembelian supplier, terbaru dulu.
  Future<Result<List<PurchaseRow>>> purchases(UuidValue supplierId);

  /// Foto bukti pembayaran; `null` bila tidak ada.
  Future<Result<Uint8List?>> proof(UuidValue paymentId);
}
