/// Jalur navigasi aplikasi.
abstract final class Routes {
  static const home = '/';
  static const settings = '/pengaturan';

  /// Modul yang belum dibangun: `/modul/<kunci>`.
  static String module(String key) => '/modul/$key';
}
