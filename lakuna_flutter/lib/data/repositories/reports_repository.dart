import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';

export 'repository_errors.dart';

/// Laporan & laba rugi cabang ini (F1-16). Butuh `reports:view`, dicek di
/// sini juga; angka laba hanya ada dengan `reports:view_profit`.
abstract class ReportsRepository {
  Future<Result<ReportData>> load(ReportPeriod period);

  /// Tab Stok: kartu stok ringkas [period]; nilai hanya dengan izin laba.
  Future<Result<StockReport>> loadStock(ReportPeriod period);

  /// Tab Kas & sesi.
  Future<Result<CashReport>> loadCash(ReportPeriod period);

  /// Tab Piutang & hutang: posisi hari ini.
  Future<Result<DebtReport>> loadDebts();

  /// Tab Retur.
  Future<Result<ReturnsReport>> loadReturns(ReportPeriod period);
}
