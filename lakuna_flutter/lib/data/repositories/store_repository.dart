import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
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

  /// Cabang aktif tenant, urut dibuat (pemilih cabang di web, F2-02
  /// aturan 2a). Bawaan: cabang konteks saat ini saja.
  Future<Result<List<Outlet>>> outlets() async => Result.ok([?current?.outlet]);

  /// Memakai cabang [outletId] untuk menu back office; perangkat tetap
  /// perangkat ini. Pilihan diingat di perangkat.
  Future<Result<StoreContext>> switchOutlet(UuidValue outletId) async =>
      Result.error(const OutletUnavailable());
}

/// Cabang tidak ada, terhapus, atau pindah cabang tidak didukung.
class OutletUnavailable implements Exception {
  const OutletUnavailable();
}
