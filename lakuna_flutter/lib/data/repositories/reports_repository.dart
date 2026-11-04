import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';

export 'repository_errors.dart';

/// Laporan & laba rugi cabang ini (F1-16). Butuh `reports:view`, dicek di
/// sini juga; angka laba hanya ada dengan `reports:view_profit`.
abstract class ReportsRepository {
  Future<Result<ReportData>> load(ReportPeriod period);
}
