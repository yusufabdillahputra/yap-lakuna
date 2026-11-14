import 'package:flutter/foundation.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';

/// Toko yang dipakai perangkat ini (F1-01). Router mendengarkan perubahan
/// [current]: selama `null`, aplikasi menampilkan wizard setup.
abstract class StoreRepository extends ChangeNotifier {
  /// Konteks toko, atau `null` bila setup belum dilakukan.
  StoreContext? get current;

  /// Memuat konteks toko dari database.
  Future<Result<StoreContext?>> load();

  /// Setup toko pertama, beserta [firstProduct] dalam transaksi yang sama
  /// (F1-01b). Gagal dengan [SetupAlreadyDone] bila sudah ada toko.
  Future<Result<StoreContext>> setup(
    SetupInput input, {
    ProductDraft? firstProduct,
  });
}
