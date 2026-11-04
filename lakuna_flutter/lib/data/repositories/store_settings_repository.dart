import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';

/// Isian *Profil toko* dan *Cabang ini* (1.26).
class StoreProfile {
  const StoreProfile({
    required this.businessName,
    required this.businessType,
    required this.timezone,
    required this.outletName,
    required this.address,
    required this.phone,
    required this.outletCode,
    required this.deviceCode,
  });

  final String businessName;
  final BusinessType businessType;

  /// ID IANA zona waktu cabang (atau tenant).
  final String timezone;
  final String outletName;
  final String address;
  final String phone;
  final String outletCode;
  final String deviceCode;
}

/// Pengaturan toko & cabang (F1-18): profil dan *Penjualan & stok*. Semua
/// butuh `settings:manage`.
abstract class StoreSettingsRepository {
  Future<Result<StoreProfile>> profile();
  Future<Result<StoreProfile>> saveBusinessName(String name);
  Future<Result<StoreProfile>> saveOutlet({
    required String name,
    required String address,
    required String phone,
  });
  Future<Result<SalesRules>> salesRules();
  Future<Result<SalesRules>> saveSalesRules(SalesRules rules);
}
