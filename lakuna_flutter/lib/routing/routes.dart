/// Jalur navigasi aplikasi.
abstract final class Routes {
  static const home = '/';
  static const settings = '/pengaturan';

  /// Setup toko pertama (F1-01).
  static const setup = '/setup';

  /// Login PIN dan ganti kasir (F1-02).
  static const login = '/masuk';

  /// Modul yang belum dibangun: `/modul/<kunci>`.
  static String module(String key) => '/modul/$key';
}
