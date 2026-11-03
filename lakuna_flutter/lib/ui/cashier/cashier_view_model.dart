import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/cashier_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';
import '../products/product_list_view_model.dart' show productMatches;

/// Tahap layar kasir: memilih barang, membayar, atau nota selesai.
enum CashierStage { browse, pay, done }

/// Hasil [CashierViewModel.scan].
enum ScanOutcome { added, unknown, empty }

/// Satu pilihan jual sebuah produk: varian × satuan (dasar atau konversi).
@immutable
class SaleOption {
  const SaleOption({
    required this.product,
    required this.variant,
    required this.label,
    required this.price,
    this.unit,
  });

  final CatalogProduct product;
  final CatalogVariant variant;

  /// `null` = satuan dasar.
  final CatalogUnit? unit;

  /// Mis. "2 L · Dus (6)" atau "5 kg".
  final String label;

  /// Harga satu satuan (tanpa grosir).
  final Money price;
}

/// Baris keranjang beserta harganya.
@immutable
class CartLine {
  const CartLine({
    required this.key,
    required this.product,
    required this.variant,
    required this.unit,
    required this.priced,
  });

  /// Kunci tampilan yang stabil.
  final int key;
  final CatalogProduct product;
  final CatalogVariant variant;
  final CatalogUnit? unit;
  final PricedLine priced;

  Qty get quantity => priced.quantity;

  /// Nama produk + varian.
  String get title => '${product.name} ${variant.name}'.trim();

  String get unitName => unit?.name ?? product.baseUnit;
}

class _Item {
  _Item(this.key, this.product, this.variant, this.unit, this.quantity);

  final int key;
  final CatalogProduct product;
  final CatalogVariant variant;
  final CatalogUnit? unit;
  Qty quantity;
}

/// View model kasir retail (1.4 / 1.11) dan bayar (1.5 / 1.5c), F1-04/F1-05.
/// Keranjang hidup selama layar kasir terbuka; bayar adalah tahap di layar
/// yang sama agar keranjang tidak hilang.
class CashierViewModel extends ChangeNotifier {
  CashierViewModel({required this._repository}) {
    load = Command0(_load)..addListener(notifyListeners);
    pay = Command0(_pay)..addListener(notifyListeners);
  }

  /// Tombol hapus satu digit di keypad.
  static const backspace = '⌫';

  /// Batas digit uang diterima (≤ Rp 999 triliun).
  static const maxDigits = 15;

  final CashierRepository _repository;

  late final Command0<CashierData> load;
  late final Command0<CheckoutResult> pay;

  CashierData? _data;
  String _query = '';
  String? _unknownCode;
  UuidValue? _categoryId;
  final _items = <_Item>[];
  var _nextKey = 0;

  CashierStage _stage = CashierStage.browse;
  PaymentMethod _method = PaymentMethod.cash;
  Money _received = Money.zero;
  String _reference = '';
  CheckoutResult? _result;
  Exception? _error;

  // --- Data ----------------------------------------------------------------

  bool get loaded => _data != null;
  CashierData? get data => _data;
  bool get hasSession => _data?.session != null;
  List<ProductCategory> get categories => _data?.categories ?? const [];
  String get query => _query;

  /// Kode terakhir yang di-scan tapi tidak dikenal (pesan di bawah kolom
  /// cari), hilang saat mengetik lagi atau scan berhasil.
  String? get unknownCode => _unknownCode;
  UuidValue? get categoryId => _categoryId;

  /// Produk setelah cari dan filter kategori.
  List<CatalogProduct> get products => [
    for (final p in _data?.products ?? const <CatalogProduct>[])
      if ((_categoryId == null || p.categoryId == _categoryId) &&
          productMatches(p, _query))
        p,
  ];

  Future<Result<CashierData>> _load() async {
    final result = await _repository.load();
    if (result case Ok(:final value)) {
      _data = value;
      if (_categoryId != null &&
          !value.categories.any((c) => c.id == _categoryId)) {
        _categoryId = null;
      }
    }
    return result;
  }

  void setQuery(String v) {
    _query = v;
    if (v.isNotEmpty) _unknownCode = null;
    notifyListeners();
  }

  void setCategory(UuidValue? id) {
    _categoryId = id;
    notifyListeners();
  }

  // --- Pilihan jual --------------------------------------------------------

  /// Semua varian × satuan [product]. Satuan hanya disebut bila varian
  /// punya satuan konversi.
  List<SaleOption> optionsFor(CatalogProduct product) => [
    for (final v in product.variants) ...[
      SaleOption(
        product: product,
        variant: v,
        label: _label(v.name, v.units.isEmpty ? null : product.baseUnit),
        price: v.sellPrice,
      ),
      for (final u in v.units)
        SaleOption(
          product: product,
          variant: v,
          unit: u,
          label: _label(v.name, '${u.name} (${u.factor.format()})'),
          price: conversionSellPrice(
            variantPrice: v.sellPrice,
            factor: u.factor,
            unitPrice: u.sellPrice,
          ),
        ),
    ],
  ];

  static String _label(String variant, String? unit) => [
    if (variant.trim().isNotEmpty) variant.trim(),
    ?unit,
  ].join(' · ');

  /// Menambah [product] bila hanya ada satu pilihan (`true`); selain itu
  /// tampilan perlu menampilkan [optionsFor] (`false`).
  bool tapProduct(CatalogProduct product) {
    final options = optionsFor(product);
    if (options.length != 1) return false;
    addOption(options.single);
    return true;
  }

  void addOption(SaleOption o) => _add(o.product, o.variant, o.unit);

  void _add(CatalogProduct p, CatalogVariant v, CatalogUnit? u) {
    final existing = _items
        .where((i) => i.variant.id == v.id && i.unit?.id == u?.id)
        .firstOrNull;
    if (existing != null) {
      existing.quantity += Qty.one;
    } else {
      _items.add(_Item(_nextKey++, p, v, u, Qty.one));
    }
    _error = null;
    _unknownCode = null;
    notifyListeners();
  }

  /// Enter di kolom cari: cocokkan persis barcode/SKU varian atau barcode
  /// satuan konversi (tanpa peka huruf dan spasi tepi).
  ScanOutcome scan(String text) {
    final code = normalizeCode(text);
    if (code.isEmpty) return ScanOutcome.empty;
    _query = '';
    bool same(String? s) => s != null && normalizeCode(s) == code;
    for (final p in _data?.products ?? const <CatalogProduct>[]) {
      for (final v in p.variants) {
        for (final u in v.units) {
          if (same(u.barcode)) {
            _add(p, v, u);
            return ScanOutcome.added;
          }
        }
        if (same(v.barcode) || same(v.sku)) {
          _add(p, v, null);
          return ScanOutcome.added;
        }
      }
    }
    _unknownCode = text.trim();
    notifyListeners();
    return ScanOutcome.unknown;
  }

  // --- Keranjang -----------------------------------------------------------

  List<CartLine> get lines => [
    for (final i in _items)
      CartLine(
        key: i.key,
        product: i.product,
        variant: i.variant,
        unit: i.unit,
        priced: priceSaleLine(
          sellPrice: i.variant.sellPrice,
          quantity: i.quantity,
          tiers: i.variant.tiers,
          factor: i.unit?.factor,
          unitPrice: i.unit?.sellPrice,
        ),
      ),
  ];

  bool get cartIsEmpty => _items.isEmpty;
  int get lineCount => _items.length;

  /// Σ jumlah semua baris (dalam satuan baris masing-masing).
  Qty get itemQuantity => _items.fold(Qty.zero, (sum, i) => sum + i.quantity);

  SaleTotals get totals => SaleTotals.of(lines.map((l) => l.priced));

  void increment(int index) {
    _items[index].quantity += Qty.one;
    notifyListeners();
  }

  /// Kurangi 1; di bawah 1 menghapus baris.
  void decrement(int index) {
    final item = _items[index];
    final next = item.quantity - Qty.one;
    if (next.isPositive) {
      item.quantity = next;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  /// Jumlah diketik; nol atau kurang menghapus baris.
  void setQuantity(int index, Qty quantity) {
    if (quantity.isPositive) {
      _items[index].quantity = quantity;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void remove(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // --- Bayar ---------------------------------------------------------------

  CashierStage get stage => _stage;
  PaymentMethod get method => _method;
  Money get received => _received;
  String get reference => _reference;
  CheckoutResult? get result => _result;

  /// Galat simpan terakhir (sesi tertutup, produk tidak tersedia, dll.).
  Exception? get error => _error;

  List<Money> get quickAmounts => quickCashAmounts(totals.total);

  /// Kembalian tunai, `null` bila uang kurang.
  Money? get change => cashChange(total: totals.total, received: _received);

  /// Kekurangan uang tunai (nol bila cukup).
  Money get shortBy {
    final short = totals.total - _received;
    return short.value > 0 ? short : Money.zero;
  }

  bool get referenceTooLong => validatePaymentReference(_reference) != null;

  bool get canPay =>
      !cartIsEmpty &&
      !pay.running &&
      !referenceTooLong &&
      (_method != PaymentMethod.cash || change != null);

  void startPayment() {
    if (cartIsEmpty) return;
    _stage = CashierStage.pay;
    _method = PaymentMethod.cash;
    _received = Money.zero;
    _reference = '';
    _error = null;
    notifyListeners();
  }

  void backToCart() {
    if (pay.running) return;
    _stage = CashierStage.browse;
    _error = null;
    notifyListeners();
  }

  void setMethod(PaymentMethod m) {
    _method = m;
    _reference = '';
    _error = null;
    notifyListeners();
  }

  void setReceived(Money m) {
    _received = m;
    notifyListeners();
  }

  /// Tombol keypad: angka, `000`, atau [backspace].
  void keypad(String key) {
    var digits = _received.value == 0 ? '' : '${_received.value}';
    if (key == backspace) {
      digits = digits.isEmpty ? '' : digits.substring(0, digits.length - 1);
    } else {
      digits = '$digits$key'.replaceFirst(RegExp('^0+'), '');
      if (digits.length > maxDigits) return;
    }
    _received = Money(digits.isEmpty ? 0 : int.parse(digits));
    notifyListeners();
  }

  void setReference(String v) {
    _reference = v;
    notifyListeners();
  }

  Future<Result<CheckoutResult>> _pay() async {
    _error = null;
    final result = await _repository.checkout(
      lines: [
        for (final i in _items)
          SaleLineRequest(
            variantId: i.variant.id,
            productUnitId: i.unit?.id,
            quantity: i.quantity,
          ),
      ],
      payment: SalePaymentRequest(
        method: _method,
        received: _method == PaymentMethod.cash ? _received : null,
        reference: _reference,
      ),
    );
    switch (result) {
      case Ok(:final value):
        _result = value;
        _items.clear();
        _stage = CashierStage.done;
      case Error(:final error):
        _error = error;
    }
    return result;
  }

  /// Kembali ke kasir kosong dan muat ulang katalog (stok terbaru).
  void newTransaction() {
    _stage = CashierStage.browse;
    _result = null;
    _error = null;
    _query = '';
    notifyListeners();
    load.execute();
  }
}
