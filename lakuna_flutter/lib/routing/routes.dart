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

  /// *Atur denah* (1.7d), langsung ke area [area] bila ada.
  static String tablesFloor([String? area]) => Uri(
    path: '$tables/denah',
    queryParameters: area == null ? null : {'area': area},
  ).toString();

  /// Split bill open bill [id] (F1-10c, layar 1.9).
  static String tablesSplit(String id) => '$tables/split/$id';

  /// Bayar bagian split: tamu [guest] atau nominal [amount] (F1-10c).
  static String cashierBillPart(String id, {String? guest, int? amount}) => Uri(
    path: cashier,
    queryParameters: {
      'bill': id,
      'guest': ?guest,
      if (amount != null) 'amount': '$amount',
    },
  ).toString();

  /// Riwayat transaksi, void & retur (F1-11).
  static const history = '/riwayat';

  /// Rincian nota [id] di riwayat (halaman sendiri di layar sempit).
  static String historySale(String id) => '$history/$id';

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

  /// Pembelian & retur pembelian (F1-12).
  static const purchases = '/pembelian';

  /// Form pembelian baru (halaman sendiri di layar sempit).
  static const purchaseNew = '/pembelian/baru';

  /// Detail pembelian [id], atau form draf.
  static String purchase(String id) => '/pembelian/$id';

  /// Pelanggan & piutang (F1-13).
  static const customers = '/pelanggan';

  /// Rincian pelanggan [id] (halaman sendiri di layar sempit).
  static String customer(String id) => '$customers/$id';

  /// Kuitansi pembayaran piutang [id] (1.13b); [copy] = cetak ulang.
  static String kuitansi(String id, {bool copy = false}) => Uri(
    path: '$customers/kuitansi/$id',
    queryParameters: copy ? {'salinan': '1'} : null,
  ).toString();

  /// Supplier & hutang (F1-14).
  static const suppliers = '/supplier';

  /// Rincian supplier [id] (halaman sendiri di layar sempit).
  static String supplier(String id) => '$suppliers/$id';

  /// Pengeluaran (F1-15).
  static const expenses = '/pengeluaran';

  /// Laporan & laba rugi (F1-16).
  static const reports = '/laporan';

  /// Pengguna & role (F1-17).
  static const users = '/pengguna';

  /// Akun saya: ganti PIN dan kata sandi sendiri (F1-17).
  static const account = '/akun';

  /// Modul yang belum dibangun: `/modul/<kunci>`.
  static String module(String key) => '/modul/$key';
}
