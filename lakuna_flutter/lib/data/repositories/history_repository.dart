import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';

export 'repository_errors.dart';

/// Staf untuk filter *Kasir*.
typedef HistoryStaff = ({UuidValue id, String name});

/// Data awal layar Riwayat (F1-11, 1.14).
@immutable
class HistoryData {
  const HistoryData({
    required this.staff,
    required this.businessName,
    required this.outletName,
    this.timezone,
    this.receipt = const ReceiptConfig(settings: ReceiptSettings()),
    this.printer,
    this.canReturn = false,
    this.canVoid = false,
    this.hasOpenSession = false,
    this.drawerCash,
    this.openSessionId,
  });

  final List<HistoryStaff> staff;
  final String businessName;
  final String outletName;
  final String? timezone;
  final ReceiptConfig receipt;
  final PrinterSelection? printer;

  /// Staf bertugas punya `sales:return`.
  final bool canReturn;

  /// Staf bertugas punya `sales:void` (tanpa persetujuan).
  final bool canVoid;

  /// Perangkat ini punya sesi kasir terbuka (uang kembali tunai).
  final bool hasOpenSession;

  /// Perkiraan uang di laci sesi terbuka (*Kas seharusnya*), `null` tanpa
  /// sesi. Untuk peringatan uang laci tidak cukup (F1-03c).
  final Money? drawerCash;

  /// Sesi kasir yang terbuka di perangkat ini, untuk menghitung uang laci
  /// yang hilang saat void nota (F1-03d).
  final UuidValue? openSessionId;
}

/// Riwayat transaksi, retur, dan void (F1-11). Melihat butuh `sales:create`
/// atau `reports:view`; retur butuh `sales:return`; void butuh
/// `sales:void` milik staf bertugas atau penyetuju. Izin dicek di sini juga.
abstract class HistoryRepository {
  Future<Result<HistoryData>> load();

  Future<Result<HistoryPage>> list(HistoryFilter filter);

  /// Gagal dengan `SaleNotFound`.
  Future<Result<SaleDetail>> detail(UuidValue saleId);

  /// Gagal dengan `NotPermitted`, `ReturnInvalid`, atau
  /// `CashSessionNotOpen`.
  Future<Result<SaleReturn>> returnSale({
    required UuidValue saleId,
    required List<ReturnLine> lines,
    required SaleReturnReason reason,
    String? note,
    required RefundMethod refundMethod,
    required bool restock,
  });

  /// Void nota lunas. [approverId] = penyetuju yang PIN-nya sudah
  /// diverifikasi (`SessionRepository.verifyApprover`); `null` = staf
  /// bertugas sendiri. Gagal dengan `NotPermitted`, `ApproverNotPermitted`,
  /// atau `SaleVoidInvalid`.
  Future<Result<Sale>> voidSale({
    required UuidValue saleId,
    required String reason,
    UuidValue? approverId,
  });
}
