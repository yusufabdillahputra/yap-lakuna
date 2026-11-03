import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart' show SessionSalesSummary;
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';

export 'repository_errors.dart';

/// Sesi kasir yang sedang terbuka beserta gerakan kas dan rekapnya.
@immutable
class ActiveCashSession {
  const ActiveCashSession({
    required this.session,
    required this.openedByName,
    required this.movements,
    required this.drawer,
    this.sales = const SessionSalesSummary(),
  });

  final CashSession session;

  /// Nama staf yang membuka sesi.
  final String openedByName;

  /// Gerakan kas sesi ini, urut waktu catat.
  final List<CashMovement> movements;

  final CashDrawer drawer;

  /// Nota lunas di sesi ini (F1-04/F1-05).
  final SessionSalesSummary sales;
}

/// Sesi kasir dan kas laci perangkat ini (F1-03). Namanya bukan
/// `CashSessionRepository` karena nama itu dipakai kode generate Serverpod. Izin staf yang bertugas diperiksa di
/// sini juga, bukan hanya di UI.
abstract class CashDrawerRepository {
  /// Sesi terbuka perangkat ini, atau `null`.
  Future<Result<ActiveCashSession?>> loadCurrent();

  /// Butuh `cash_session:open`. Gagal dengan [NotPermitted],
  /// `CashInputInvalid`, atau `CashSessionAlreadyOpen`.
  Future<Result<ActiveCashSession>> open({
    required Money openingCash,
    String note = '',
  });

  /// Butuh `cash_movements:create`. Gagal dengan [NotPermitted],
  /// `CashInputInvalid`, atau `CashSessionNotOpen`.
  Future<Result<ActiveCashSession>> recordMovement(
    UuidValue sessionId, {
    required CashDirection direction,
    required Money amount,
    required String note,
  });

  /// Butuh `cash_session:close`. Mengembalikan sesi yang sudah ditutup.
  /// Gagal dengan [NotPermitted], `CashInputInvalid`, atau
  /// `CashSessionNotOpen`.
  Future<Result<CashSession>> close(
    UuidValue sessionId, {
    required CashCount count,
    String note = '',
  });
}
