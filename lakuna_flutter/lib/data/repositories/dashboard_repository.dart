import 'package:lakuna_client/lakuna_client.dart' show TenantStatus, UuidValue;
import 'package:lakuna_data/lakuna_data.dart' show DashboardData;

import '../../utils/result.dart';

export 'repository_errors.dart';

/// Dashboard semua cabang 2.3 (F2-02 tahap 3). Butuh `reports:view`.
abstract class DashboardRepository {
  /// Angka hari ini dari data tersinkron di perangkat; [outletId] `null` =
  /// semua cabang.
  Future<Result<DashboardData>> load({UuidValue? outletId});

  /// Perangkat dan konflik dari server; gagal bila offline.
  Future<Result<TenantStatus>> tenantStatus();
}
