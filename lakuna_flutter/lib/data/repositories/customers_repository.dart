import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';

export 'repository_errors.dart';

/// Data awal layar Pelanggan & piutang (F1-13, 1.20).
@immutable
class CustomersSetup {
  const CustomersSetup({
    required this.today,
    required this.businessName,
    required this.outletName,
    this.outletAddress,
    this.outletPhone,
    this.timezone,
    this.canManage = false,
    this.canReceive = false,
    this.hasOpenSession = false,
    this.receipt = const ReceiptConfig(settings: ReceiptSettings()),
    this.printer,
  });

  /// Tanggal lokal cabang hari ini (UTC tengah malam).
  final DateTime today;
  final String businessName;
  final String outletName;
  final String? outletAddress;
  final String? outletPhone;
  final String? timezone;

  /// Staf punya `customers:manage` (tambah, ubah, hapus, import).
  final bool canManage;

  /// Staf punya `debts:manage` (terima pembayaran piutang).
  final bool canReceive;

  /// Perangkat ini punya sesi kasir terbuka (tunai masuk laci).
  final bool hasOpenSession;
  final ReceiptConfig receipt;
  final PrinterSelection? printer;

  /// Kota untuk tanda tangan kuitansi: bagian terakhir alamat cabang.
  String get city {
    final parts = (outletAddress ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.length > 1 ? parts.last : '';
  }
}

/// Pelanggan, grup pelanggan, dan pembayaran piutang (F1-13). Membuka modul
/// butuh `customers:manage` atau `debts:manage`; aksi tulis dicek per izin
/// di sini juga.
abstract class CustomersRepository {
  Future<Result<CustomersSetup>> load();

  Future<Result<CustomersOverview>> list();

  /// Gagal dengan `CustomerNotFound`.
  Future<Result<CustomerDetail>> detail(UuidValue id);

  /// `customers:manage`. Gagal dengan `CustomerInvalid`,
  /// `CustomerPhoneTaken`, atau `CustomerGroupInvalid`.
  Future<Result<Customer>> save(CustomerInput input);

  /// `customers:manage`. Ditolak (`CustomerHasDebt`) bila masih berpiutang.
  Future<Result<void>> delete(UuidValue id);

  Future<Result<List<CustomerGroupRow>>> groups();

  /// `customers:manage`. Gagal dengan `CustomerGroupInvalid` atau
  /// `CustomerGroupNameTaken`.
  Future<Result<CustomerGroup>> saveGroup({
    UuidValue? id,
    required String name,
    required int termDays,
  });

  /// `customers:manage`. Ditolak (`CustomerGroupInUse`) bila dipakai.
  Future<Result<void>> deleteGroup(UuidValue id);

  /// `debts:manage`. Gagal dengan `DebtPaymentInvalid`,
  /// `DebtPaymentDateInvalid`, atau `DebtPaymentMethodInvalid`.
  Future<Result<DebtPayment>> receivePayment(DebtPaymentRequest request);

  /// Isi kuitansi. Gagal dengan `DebtPaymentNotFound`.
  Future<Result<DebtPaymentReceipt>> receipt(UuidValue paymentId);

  /// `customers:manage`.
  Future<Result<CustomerImportSummary>> importRows(
    List<CustomerImportRow> rows,
  );
}
