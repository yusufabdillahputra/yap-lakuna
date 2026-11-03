import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/cashier_repository.dart';
import '../../data/services/receipt_printer.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';
import '../products/product_list_view_model.dart' show productMatches;

/// Tahap layar kasir: memilih barang, membayar, atau nota selesai.
enum CashierStage { browse, pay, done }

/// Pilihan di layar bayar: satu metode, atau bagi beberapa metode.
enum PayMode { cash, card, transfer, qris, split }

/// Satu bagian split payment. QRIS menunggu *Sudah Terbayar*.
@immutable
class SplitPart {
  const SplitPart({
    required this.method,
    required this.amount,
    this.confirmed = false,
  });

  final PaymentMethod method;
  final Money amount;

  /// QRIS sudah dikonfirmasi; metode lain selalu dianggap diterima.
  final bool confirmed;

  bool get isCash => method == PaymentMethod.cash;
  bool get isPending => method == PaymentMethod.qrisStatic && !confirmed;
}

/// Alasan bagian split belum bisa ditambah.
enum SplitDraftError {
  /// Nominal nol.
  empty,

  /// Sudah ada bagian tunai.
  cashExists,

  /// Non-tunai melebihi sisa (kembalian hanya dari tunai).
  overRemaining,

  /// Sudah lunas.
  settled,
}

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
  CashierViewModel({required this._repository, required this._printer}) {
    load = Command0(_load)..addListener(notifyListeners);
    pay = Command0(_pay)..addListener(notifyListeners);
    printReceipt = Command1(_printReceipt)..addListener(notifyListeners);
    shareReceipt = Command1(_shareReceipt)..addListener(notifyListeners);
  }

  /// Tombol hapus satu digit di keypad.
  static const backspace = '⌫';

  /// Batas digit uang diterima (≤ Rp 999 triliun).
  static const maxDigits = 15;

  final CashierRepository _repository;
  final ReceiptPrinter _printer;

  late final Command0<CashierData> load;
  late final Command0<CheckoutResult> pay;

  /// Mencetak baris struk nota terakhir (F1-06).
  late final Command1<void, List<ReceiptLine>> printReceipt;

  /// PDF struk: hasil = lokasi berkas di desktop, `null` di share sheet.
  late final Command1<String?, List<ReceiptLine>> shareReceipt;

  CashierData? _data;
  String _query = '';
  String? _unknownCode;
  UuidValue? _categoryId;
  final _items = <_Item>[];
  var _nextKey = 0;

  CashierStage _stage = CashierStage.browse;
  PayMode _mode = PayMode.cash;
  Money _received = Money.zero;
  String _reference = '';
  final _parts = <SplitPart>[];
  PaymentMethod _draftMethod = PaymentMethod.cash;
  Money? _draftAmount;
  CheckoutResult? _result;
  Exception? _error;
  PrinterFailureReason? _printFailure;
  var _printed = false;
  String? _sharedPath;
  final _autoPrinted = <String>{};

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Penyimpanan bisa selesai setelah layar ditutup (mis. *Ganti kasir*
  /// saat bayar); jangan memberi tahu view model yang sudah dibuang.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

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

  /// Semua varian × satuan [product]. Satuan dasar hanya disebut bila
  /// produk punya satuan konversi, agar pilihan bisa dibedakan.
  List<SaleOption> optionsFor(CatalogProduct product) {
    final hasUnits = product.variants.any((v) => v.units.isNotEmpty);
    return [
      for (final v in product.variants) ...[
        SaleOption(
          product: product,
          variant: v,
          label: _label(v.name, hasUnits ? product.baseUnit : null),
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
  }

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
  PayMode get mode => _mode;

  /// Metode untuk [mode] satu metode; `null` saat split.
  PaymentMethod? get method => switch (_mode) {
    PayMode.cash => PaymentMethod.cash,
    PayMode.card => PaymentMethod.card,
    PayMode.transfer => PaymentMethod.transfer,
    PayMode.qris => PaymentMethod.qrisStatic,
    PayMode.split => null,
  };

  Money get received => _received;
  String get reference => _reference;
  CheckoutResult? get result => _result;

  /// QRIS statis cabang; `null` bila nonaktif.
  CashierQris? get qris => _data?.qris;

  /// Staf boleh menekan *Sudah Terbayar*.
  bool get canConfirmPayments => _data?.canConfirmPayments ?? false;

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

  /// *Selesaikan pembayaran* aktif. QRIS tunggal memakai *Sudah Terbayar*
  /// ([canConfirmQris]), bukan tombol ini.
  bool get canPay =>
      !cartIsEmpty &&
      !pay.running &&
      switch (_mode) {
        PayMode.cash => change != null,
        PayMode.card || PayMode.transfer => !referenceTooLong,
        PayMode.qris => false,
        PayMode.split => splitSettlement.isSettled && !hasPendingQris,
      };

  /// *Sudah Terbayar* untuk QRIS tunggal aktif.
  bool get canConfirmQris =>
      !cartIsEmpty && !pay.running && qris != null && canConfirmPayments;

  void startPayment() {
    if (cartIsEmpty) return;
    _stage = CashierStage.pay;
    _mode = PayMode.cash;
    _received = Money.zero;
    _reference = '';
    _parts.clear();
    _draftMethod = PaymentMethod.cash;
    _draftAmount = null;
    _error = null;
    notifyListeners();
  }

  void backToCart() {
    if (pay.running) return;
    _stage = CashierStage.browse;
    _error = null;
    notifyListeners();
  }

  void setMode(PayMode m) {
    if (m == PayMode.qris && qris == null) return;
    _mode = m;
    _reference = '';
    _error = null;
    notifyListeners();
  }

  /// *Belum masuk* di QRIS tunggal: kembali ke tunai tanpa menyimpan.
  void qrisNotReceived() {
    if (pay.running) return;
    setMode(PayMode.cash);
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

  // --- Split -------------------------------------------------------------

  List<SplitPart> get parts => List.unmodifiable(_parts);

  Settlement get splitSettlement => settleTender(totals.total, [
    for (final p in _parts) TenderPart(p.amount, isCash: p.isCash),
  ]);

  bool get hasPendingQris => _parts.any((p) => p.isPending);

  /// Metode yang bisa dipilih di form tambah bagian.
  List<PaymentMethod> get splitMethods => [
    PaymentMethod.cash,
    PaymentMethod.card,
    PaymentMethod.transfer,
    // Bagian QRIS harus dikonfirmasi; tanpa izin tidak ditawarkan.
    if (qris != null && canConfirmPayments) PaymentMethod.qrisStatic,
  ];

  PaymentMethod get draftMethod => _draftMethod;

  /// Nominal bagian baru; bawaan = sisa.
  Money get draftAmount => _draftAmount ?? splitSettlement.remaining;

  SplitDraftError? get draftError {
    final settlement = splitSettlement;
    if (_parts.isNotEmpty && settlement.remaining == Money.zero) {
      return SplitDraftError.settled;
    }
    final amount = draftAmount;
    if (amount <= Money.zero) return SplitDraftError.empty;
    if (_draftMethod == PaymentMethod.cash) {
      return _parts.any((p) => p.isCash) ? SplitDraftError.cashExists : null;
    }
    return amount > settlement.remaining ? SplitDraftError.overRemaining : null;
  }

  void setDraftMethod(PaymentMethod m) {
    _draftMethod = m;
    notifyListeners();
  }

  void setDraftAmount(Money m) {
    _draftAmount = m;
    notifyListeners();
  }

  /// *Tambah metode*. QRIS masuk sebagai menunggu konfirmasi.
  void addPart() {
    if (pay.running || draftError != null) return;
    _parts.add(SplitPart(method: _draftMethod, amount: draftAmount));
    _draftAmount = null;
    _draftMethod = _parts.any((p) => p.isCash)
        ? PaymentMethod.card
        : PaymentMethod.cash;
    _error = null;
    notifyListeners();
  }

  void removePart(int index) {
    if (pay.running) return;
    _parts.removeAt(index);
    _draftAmount = null;
    _error = null;
    if (!_parts.any((p) => p.isCash)) _draftMethod = PaymentMethod.cash;
    notifyListeners();
  }

  /// *Sudah Terbayar* untuk bagian QRIS [index].
  void confirmPart(int index) {
    if (pay.running || !canConfirmPayments) return;
    final p = _parts[index];
    _parts[index] = SplitPart(
      method: p.method,
      amount: p.amount,
      confirmed: true,
    );
    notifyListeners();
  }

  List<SalePaymentRequest> _payments() => switch (_mode) {
    PayMode.cash => [SalePaymentRequest.cash(_received)],
    PayMode.card => [
      SalePaymentRequest(method: PaymentMethod.card, reference: _reference),
    ],
    PayMode.transfer => [
      SalePaymentRequest(method: PaymentMethod.transfer, reference: _reference),
    ],
    PayMode.qris => const [
      SalePaymentRequest(method: PaymentMethod.qrisStatic, confirmed: true),
    ],
    PayMode.split => [
      for (final p in _parts)
        SalePaymentRequest(
          method: p.method,
          amount: p.amount,
          confirmed: p.confirmed,
        ),
    ],
  };

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
      payments: _payments(),
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
    _resetPrint();
    _query = '';
    notifyListeners();
    load.execute();
  }

  // --- Struk (F1-06) -------------------------------------------------------

  /// Lebar kertas struk cabang ini.
  ReceiptPaper get receiptPaper =>
      _data?.receipt.settings.paper ?? ReceiptPaper.mm58;

  /// Cetak otomatis setelah bayar diaktifkan untuk cabang ini.
  bool get autoPrintEnabled => _data?.receipt.settings.autoPrint ?? false;

  /// Printer terpilih di perangkat ini; `null` = dialog cetak sistem.
  PrinterSelection? get printer => _data?.printer;

  /// Galat cetak terakhir; nota tetap tersimpan.
  PrinterFailureReason? get printFailure => _printFailure;

  /// Struk nota ini sudah terkirim ke printer.
  bool get printed => _printed;

  /// Lokasi PDF yang disimpan di desktop.
  String? get sharedPath => _sharedPath;

  bool get printing => printReceipt.running || shareReceipt.running;

  /// Cetak otomatis belum dijalankan untuk nota ini dan diaktifkan di
  /// Pengaturan dengan printer langsung (Bluetooth/LAN).
  bool get shouldAutoPrint {
    final sale = _result?.sale;
    return sale != null &&
        _stage == CashierStage.done &&
        autoPrintEnabled &&
        (printer?.isDirect ?? false) &&
        !_autoPrinted.contains(sale.number);
  }

  /// Cetak otomatis sekali per nota.
  Future<void> autoPrint(List<ReceiptLine> lines) async {
    if (!shouldAutoPrint) return;
    _autoPrinted.add(_result!.sale.number);
    await printReceipt.execute(lines);
  }

  void _resetPrint() {
    _printFailure = null;
    _printed = false;
    _sharedPath = null;
  }

  Future<Result<void>> _printReceipt(List<ReceiptLine> lines) async {
    _resetPrint();
    try {
      await _printer.print(
        printer ?? const PrinterSelection(kind: PrinterKind.system, name: ''),
        lines,
        receiptPaper,
        jobName: _result?.sale.number ?? 'Lakuna',
      );
      _printed = printer?.isDirect ?? false;
      return const Result.ok(null);
    } on PrinterFailure catch (e) {
      _printFailure = e.reason;
      return Result.error(e);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<String?>> _shareReceipt(List<ReceiptLine> lines) async {
    _resetPrint();
    try {
      final path = await _printer.sharePdf(
        lines,
        receiptPaper,
        fileName: '${_result?.sale.number ?? 'struk'}.pdf',
      );
      _sharedPath = path;
      return Result.ok(path);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
