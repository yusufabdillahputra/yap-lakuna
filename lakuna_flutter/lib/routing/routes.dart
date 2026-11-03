/// Jalur navigasi aplikasi.
abstract final class Routes {
  static const home = '/';
  static const settings = '/pengaturan';

  /// Setup toko pertama (F1-01).
  static const setup = '/setup';

  /// Login PIN dan ganti kasir (F1-02).
  static const login = '/masuk';

  /// Sesi kasir dan kas laci (F1-03).
  static const cashSession = '/sesi-kasir';

  /// Kasir retail + bayar (F1-04/F1-05).
  static const cashier = '/kasir';

  /// Daftar produk & stok (F1-07).
  static const products = '/produk';

  /// Form produk baru (F1-07).
  static const productNew = '/produk/baru';

  /// Form ubah produk [id] (F1-07).
  static String product(String id) => '/produk/$id';

  /// Modul yang belum dibangun: `/modul/<kunci>`.
  static String module(String key) => '/modul/$key';
}
