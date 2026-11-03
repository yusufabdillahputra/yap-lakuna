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

  /// Kasir mode bill: bayar open bill [id] (F1-10).
  static String cashierBill(String id) => '$cashier?bill=$id';

  /// Meja & open bill (F1-10).
  static const tables = '/meja';

  /// Layar Meja dengan bill [id] terpilih.
  static String tablesBill(String id) => '$tables?bill=$id';

  /// Daftar produk & stok (F1-07).
  static const products = '/produk';

  /// Form produk baru (F1-07).
  static const productNew = '/produk/baru';

  /// Form ubah produk [id] (F1-07).
  static String product(String id) => '/produk/$id';

  /// Stok: penyesuaian, kartu stok, stok minimum, lokasi (F1-08).
  static const stock = '/stok';

  /// Stok dengan tab tertentu terbuka (nama `StockTab`, mis. `locations`).
  static String stockTab(String tab) => '$stock?tab=$tab';

  /// Master data: kategori, satuan, lokasi, metode bayar (F1-09).
  static const master = '/master';

  /// Modul yang belum dibangun: `/modul/<kunci>`.
  static String module(String key) => '/modul/$key';
}
