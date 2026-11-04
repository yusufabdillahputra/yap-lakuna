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
/// [credit] = simpan sebagai piutang pelanggan (F1-13, 1.5b).
enum PayMode { cash, card, transfer, qris, split, credit }

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
    this.discount,
  });

  /// Diskon manual baris (F1-04b).
  final ManualDiscount? discount;

  /// Potongan diskon baris dari total baris setelah grosir.
  Money get discountCut => discount?.cut(priced.lineTotal) ?? Money.zero;

  /// Total baris bersih setelah diskon manual.
  Money get netTotal => priced.lineTotal - discountCut;

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
  ManualDiscount? discount;
}

/// Siapa yang boleh memberi diskon manual di Kasir (F1-04b).
enum DiscountAccess {
  /// Staf punya `sales:discount`.
  direct,

  /// Staf tanpa izin; diskon butuh persetujuan PIN manajer.
  approval,

  /// Staf tanpa izin dan persetujuan PIN dimatikan.
  none,
}

/// Penyetuju diskon manual yang PIN-nya sudah diperiksa.
typedef DiscountApprover = ({UuidValue id, String name});

/// Diskon rupiah yang melebihi dasar dipangkas ke dasarnya (mis. jumlah
/// baris berkurang setelah diskon diberikan).
ManualDiscount _fit(ManualDiscount d, Money base) =>
    d.kind == DiscountKind.amount && d.amount > base
    ? ManualDiscount.amount(base)
    : d;

/// Semua varian × satuan [product]. Satuan dasar hanya disebut bila
/// produk punya satuan konversi, agar pilihan bisa dibedakan.
List<SaleOption> saleOptionsFor(CatalogProduct product) {
  final hasUnits = product.variants.any((v) => v.units.isNotEmpty);
  return [
    for (final v in product.variants) ...[
      SaleOption(
        product: product,
        variant: v,
        label: _optionLabel(v.name, hasUnits ? product.baseUnit : null),
        price: v.sellPrice,
      ),
      for (final u in v.units)
        SaleOption(
          product: product,
          variant: v,
          unit: u,
          label: _optionLabel(v.name, '${u.name} (${u.factor.format()})'),
          price: conversionSellPrice(
            variantPrice: v.sellPrice,
            factor: u.factor,
            unitPrice: u.sellPrice,
          ),
        ),
    ],
  ];
}

String _optionLabel(String variant, String? unit) => [
  if (variant.trim().isNotEmpty) variant.trim(),
  ?unit,
].join(' · ');

/// View model kasir retail (1.4 / 1.11) dan bayar (1.5 / 1.5c), F1-04/F1-05.
/// Keranjang hidup selama layar kasir terbuka; bayar adalah tahap di layar
/// yang sama agar keranjang tidak hilang.
/// Bagian split bill yang dibayar di layar Bayar (F1-10c): tamu [guest]
/// (mode per item / rata) atau nominal [amount] (nominal bebas).
class BillPart {
  const BillPart({this.guest, this.amount});

  final String? guest;
  final Money? amount;
}

/// Bill yang lunas di luar layar Bayar (mis. *Sudah Terbayar* di layar
/// split): layar kasir langsung menampilkan struknya.
class CompletedBill {
  const CompletedBill(this.bill, this.result);

  final OpenBill bill;
  final CheckoutResult result;
}

class CashierViewModel extends ChangeNotifier {
  CashierViewModel({required this._repository, required this._printer}) {
    load = Command0(_load)..addListener(notifyListeners);
    openBill = Command1(_openBill)..addListener(notifyListeners);
    pay = Command0(_pay)..addListener(notifyListeners);
    loadCredit = Command0(_loadCredit)..addListener(notifyListeners);
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

  /// Mode bill (F1-10): memuat open bill lalu langsung ke tahap bayar.
  late final Command1<OpenBill, UuidValue> openBill;

  /// Hasil `null` = bagian split terbayar tapi bill belum lunas (kembali
  /// ke layar split lewat [onLeaveBill]).
  late final Command0<CheckoutResult?> pay;

  /// Pelanggan untuk pemilih kredit (1.5b).
  late final Command0<void> loadCredit;

  /// Mencetak baris struk nota terakhir (F1-06).
  late final Command1<void, List<ReceiptLine>> printReceipt;

  /// PDF struk: hasil = lokasi berkas di desktop, `null` di share sheet.
  late final Command1<String?, List<ReceiptLine>> shareReceipt;

  CashierData? _data;
  OpenBill? _bill;
  BillPart? _part;
  var _waitQris = false;
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
  CustomersOverview? _creditCustomers;
  UuidValue? _creditCustomerId;
  var _creditDown = Money.zero;
  DateTime? _creditDue;
  var _creditQuery = '';
  ManualDiscount? _billDiscount;
  DiscountApprover? _discountApprover;

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
      if ((_categoryId == null ||
              p.categoryId == _categoryId ||
              _data?.categoryParents[p.categoryId] == _categoryId) &&
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

  /// Semua varian × satuan [product] ([saleOptionsFor]).
  List<SaleOption> optionsFor(CatalogProduct product) =>
      saleOptionsFor(product);

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
        discount: i.discount,
      ),
  ];

  bool get cartIsEmpty => _items.isEmpty;
  int get lineCount => _items.length;

  /// Σ jumlah semua baris (dalam satuan baris masing-masing).
  Qty get itemQuantity => _items.fold(Qty.zero, (sum, i) => sum + i.quantity);

  SaleTotals get totals => SaleTotals.of(lines.map((l) => l.priced));

  // --- Diskon manual (F1-04b) ---------------------------------------------

  DiscountAccess get discountAccess {
    final data = _data;
    if (data == null || billMode) return DiscountAccess.none;
    if (data.canDiscount) return DiscountAccess.direct;
    return data.salesRules.discountNeedsPin
        ? DiscountAccess.approval
        : DiscountAccess.none;
  }

  bool get canOfferDiscount => discountAccess != DiscountAccess.none;

  /// Diskon berikutnya butuh dialog PIN manajer dulu.
  bool get discountNeedsApproval =>
      discountAccess == DiscountAccess.approval && _discountApprover == null;

  DiscountApprover? get discountApprover => _discountApprover;

  /// Penyetuju dari dialog PIN; berlaku sampai keranjang selesai/kosong.
  void approveDiscounts(DiscountApprover approver) {
    _discountApprover = approver;
    notifyListeners();
  }

  ManualDiscount? get billDiscount => _billDiscount;

  /// Σ potongan diskon baris.
  Money get lineDiscount => Money.sum(lines.map((l) => l.discountCut));

  /// Σ total baris bersih (dasar diskon nota).
  Money get linesNet => totals.total - lineDiscount;

  /// Potongan diskon nota.
  Money get billDiscountCut => _billDiscount?.cut(linesNet) ?? Money.zero;

  /// Total sebelum pembulatan.
  Money get netTotal => linesNet - billDiscountCut;

  /// Ada diskon baris atau nota di keranjang.
  bool get hasDiscount =>
      _billDiscount != null || _items.any((i) => i.discount != null);

  /// Nota senilai [net] habis (nol atau kurang), juga setelah pembulatan.
  bool _wipesOut(Money net) =>
      net <= Money.zero ||
      roundTotal(net, _data?.salesRules.rounding ?? TotalRounding.none) <=
          Money.zero;

  /// Diskon menghabiskan total (mis. jumlah baris berkurang setelah diskon
  /// diberikan): bayar ditahan sampai diskon diubah.
  bool get discountBlocksPay => hasDiscount && _wipesOut(netTotal);

  /// Galat diskon baris [index] untuk [discount]; `null` bila sah. Total
  /// nota (setelah diskon nota dan pembulatan) harus tetap bernilai.
  DiscountIssue? lineDiscountIssue(int index, ManualDiscount discount) {
    final line = lines[index];
    final issue = discount.issue(line.priced.lineTotal);
    if (issue != null) return issue;
    final net =
        linesNet + line.discountCut - discount.cut(line.priced.lineTotal);
    final bill = _billDiscount?.cut(net) ?? Money.zero;
    return _wipesOut(net - bill) ? DiscountIssue.tooLarge : null;
  }

  /// Galat diskon nota: total nota harus tetap bernilai setelah pembulatan.
  DiscountIssue? billDiscountIssue(ManualDiscount discount) {
    final base = linesNet;
    final issue = discount.issue(base);
    if (issue != null) return issue;
    return _wipesOut(base - discount.cut(base)) ? DiscountIssue.tooLarge : null;
  }

  void setLineDiscount(int index, ManualDiscount? discount) {
    _items[index].discount = discount;
    notifyListeners();
  }

  void setBillDiscount(ManualDiscount? discount) {
    _billDiscount = discount;
    notifyListeners();
  }

  void _resetDiscounts() {
    _billDiscount = null;
    _discountApprover = null;
  }

  /// Selisih pembulatan total keranjang (aturan cabang, F1-18).
  Money get rounding {
    final total = netTotal;
    return roundTotal(
          total,
          _data?.salesRules.rounding ?? TotalRounding.none,
        ) -
        total;
  }

  /// Total keranjang setelah diskon dan pembulatan (yang dibayar).
  Money get grandTotal => netTotal + rounding;

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
      if (_items.isEmpty) _resetDiscounts();
    }
    notifyListeners();
  }

  /// Jumlah diketik; nol atau kurang menghapus baris.
  void setQuantity(int index, Qty quantity) {
    if (quantity.isPositive) {
      _items[index].quantity = quantity;
    } else {
      _items.removeAt(index);
      if (_items.isEmpty) _resetDiscounts();
    }
    notifyListeners();
  }

  void remove(int index) {
    _items.removeAt(index);
    if (_items.isEmpty) _resetDiscounts();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _resetDiscounts();
    notifyListeners();
  }

  // --- Mode bill (F1-10) --------------------------------------------------

  /// Open bill yang sedang dibayar; `null` = kasir retail biasa.
  OpenBill? get bill => _bill;
  bool get billMode => _bill != null;

  Future<Result<OpenBill>> _openBill(UuidValue id) async {
    final result = await _repository.loadBill(id);
    if (result case Ok(:final value)) {
      // Bill kosong (mis. tautan lama) tidak bisa dibayar: tampilkan galat,
      // jangan jatuh ke keranjang retail dengan mode bill aktif.
      if (value.items.isEmpty) return Result.error(SaleEmpty());
      if (_part != null) {
        if (_partError(value) case final e?) return Result.error(e);
      }
      _bill = value;
      startPayment();
    }
    return result;
  }

  /// Tampilkan struk bill yang sudah lunas (tahap selesai, cetak otomatis
  /// tetap berlaku).
  void showReceipt(CompletedBill done) {
    _bill = done.bill;
    _result = done.result;
    _stage = CashierStage.done;
    notifyListeners();
  }

  /// Bagian split yang dibayar; diatur sebelum [openBill].
  BillPart? get part => _part;

  void setPart(BillPart? value) => _part = value;

  /// Tautan bagian yang tidak bisa dibayar lagi (mis. sudah lunas).
  SplitInvalid? _partError(OpenBill bill) {
    final split = bill.split;
    if (split == null) return const SplitInvalid(SplitError.notSet);
    final guest = _part?.guest;
    if (guest == null) {
      return split.next == null
          ? const SplitInvalid(SplitError.partPaid)
          : null;
    }
    final part = split.parts.where((p) => p.label == guest).firstOrNull;
    if (part == null) return const SplitInvalid(SplitError.guest);
    if (part.payments.isNotEmpty) {
      return const SplitInvalid(SplitError.partPaid);
    }
    return null;
  }

  /// Membayar satu bagian split bill, bukan seluruh bill.
  bool get partMode => _bill != null && _part != null;

  /// Label tamu yang dibayar: tamu terpilih atau tamu berikutnya di mode
  /// nominal bebas.
  String? get partLabel => _part?.guest ?? _bill?.split?.next?.label;

  /// Total yang dibayar: bagian tamu, total bill (dengan service & PB1),
  /// atau keranjang.
  Money get payTotal {
    final part = _part;
    final bill = _bill;
    if (part != null && bill != null) {
      if (part.amount case final amount?) return amount;
      final split = bill.split;
      final due = split?.parts
          .where((p) => p.label == part.guest)
          .firstOrNull
          ?.due;
      return due ?? Money.zero;
    }
    return bill?.charges.total ?? grandTotal;
  }

  /// Jumlah baris yang dibayar.
  int get payLineCount => _bill?.items.length ?? lineCount;

  bool get _nothingToPay => _bill == null
      ? cartIsEmpty || discountBlocksPay
      : _bill!.items.isEmpty || (partMode && payTotal <= Money.zero);

  // --- Bayar ---------------------------------------------------------------

  CashierStage get stage => _stage;
  PayMode get mode => _mode;

  /// Metode untuk [mode] satu metode; `null` saat split.
  PaymentMethod? get method => switch (_mode) {
    PayMode.cash => PaymentMethod.cash,
    PayMode.card => PaymentMethod.card,
    PayMode.transfer => PaymentMethod.transfer,
    PayMode.qris => PaymentMethod.qrisStatic,
    PayMode.split || PayMode.credit => null,
  };

  // --- Kredit (F1-13, 1.5b) --------------------------------------------------

  /// Tombol *Kredit / piutang* tampil: staf `debts:manage`, bukan open bill.
  bool get canSellOnCredit =>
      (_data?.canSellOnCredit ?? false) && _bill == null;

  CustomersOverview? get creditCustomers => _creditCustomers;
  String get creditQuery => _creditQuery;

  /// Pelanggan yang cocok dengan pencarian, yang punya limit dulu.
  List<CustomerRow> get creditCandidates {
    final q = _creditQuery.trim().toLowerCase();
    final rows = [
      for (final r in _creditCustomers?.rows ?? const <CustomerRow>[])
        if (q.isEmpty ||
            r.customer.name.toLowerCase().contains(q) ||
            (r.customer.phone ?? '').contains(q))
          r,
    ];
    rows.sort((a, b) {
      final la = a.creditLimit > Money.zero ? 0 : 1;
      final lb = b.creditLimit > Money.zero ? 0 : 1;
      if (la != lb) return la - lb;
      return a.customer.name.toLowerCase().compareTo(
        b.customer.name.toLowerCase(),
      );
    });
    return rows;
  }

  CustomerRow? get creditCustomer => switch (_creditCustomerId) {
    final id? =>
      _creditCustomers?.rows.where((r) => r.customer.id == id).firstOrNull,
    null => null,
  };

  Money get creditDown => _creditDown;
  DateTime get creditToday => _creditCustomers?.today ?? DateTime.now().toUtc();
  DateTime? get creditDue => _creditDue;

  /// Bagian nota yang menjadi piutang.
  Money get creditDebt {
    final rest = payTotal - _creditDown;
    return rest.isNegative ? Money.zero : rest;
  }

  /// Sisa limit setelah nota ini (boleh negatif = melebihi limit).
  Money get creditRemainingAfter {
    final c = creditCustomer;
    if (c == null) return Money.zero;
    return c.creditLimit - c.outstanding - creditDebt;
  }

  /// Galat kredit saat ini; `null` = boleh disimpan.
  CreditIssue? get creditIssueNow {
    final c = creditCustomer;
    final due = _creditDue;
    if (c == null || due == null) return null;
    return creditIssue(
      limit: c.creditLimit,
      outstanding: c.outstanding,
      total: payTotal,
      downPayment: _creditDown,
      dueOn: due,
      today: creditToday,
    );
  }

  bool get _creditReady =>
      creditCustomer != null && _creditDue != null && creditIssueNow == null;

  Future<Result<void>> _loadCredit() async {
    final result = await _repository.creditCustomers();
    if (result case Ok(:final value)) _creditCustomers = value;
    return result;
  }

  void setCreditQuery(String q) {
    _creditQuery = q;
    notifyListeners();
  }

  /// Memilih pelanggan; jatuh tempo = hari ini + tempo standar.
  void selectCreditCustomer(UuidValue id) {
    final row = _creditCustomers?.rows
        .where((r) => r.customer.id == id)
        .firstOrNull;
    if (row == null) return;
    _creditCustomerId = id;
    _creditDue = creditToday.add(Duration(days: row.termDays));
    _error = null;
    notifyListeners();
  }

  void clearCreditCustomer() {
    _creditCustomerId = null;
    _creditDue = null;
    notifyListeners();
  }

  void setCreditDown(Money m) {
    _creditDown = m;
    _error = null;
    notifyListeners();
  }

  void setCreditDue(DateTime d) {
    _creditDue = DateTime.utc(d.year, d.month, d.day);
    _error = null;
    notifyListeners();
  }

  Money get received => _received;
  String get reference => _reference;
  CheckoutResult? get result => _result;

  /// QRIS statis cabang; `null` bila nonaktif.
  CashierQris? get qris => _data?.qris;

  /// Staf boleh menekan *Sudah Terbayar*.
  bool get canConfirmPayments => _data?.canConfirmPayments ?? false;

  /// Galat simpan terakhir (sesi tertutup, produk tidak tersedia, dll.).
  Exception? get error => _error;

  List<Money> get quickAmounts => quickCashAmounts(payTotal);

  /// Kembalian tunai, `null` bila uang kurang.
  Money? get change => cashChange(total: payTotal, received: _received);

  /// Kekurangan uang tunai (nol bila cukup).
  Money get shortBy {
    final short = payTotal - _received;
    return short.value > 0 ? short : Money.zero;
  }

  bool get referenceTooLong => validatePaymentReference(_reference) != null;

  /// *Selesaikan pembayaran* aktif. QRIS tunggal memakai *Sudah Terbayar*
  /// ([canConfirmQris]), bukan tombol ini.
  bool get canPay =>
      !_nothingToPay &&
      !pay.running &&
      switch (_mode) {
        PayMode.cash => change != null,
        PayMode.card || PayMode.transfer => !referenceTooLong,
        PayMode.qris => false,
        PayMode.split => splitSettlement.isSettled && !hasPendingQris,
        PayMode.credit => _creditReady,
      };

  /// *Sudah Terbayar* untuk QRIS tunggal aktif.
  bool get canConfirmQris =>
      !_nothingToPay && !pay.running && qris != null && canConfirmPayments;

  /// *Simpan, tunggu konfirmasi* (QRIS bagian split): bagian tersimpan
  /// sebagai menunggu dan dikonfirmasi nanti di layar split.
  bool get canWaitQris =>
      partMode && !_nothingToPay && !pay.running && qris != null;

  /// Simpan bagian QRIS sebagai menunggu konfirmasi.
  Future<void> waitQris() async {
    if (!canWaitQris) return;
    _waitQris = true;
    try {
      await pay.execute();
    } finally {
      _waitQris = false;
    }
  }

  void startPayment() {
    if (_nothingToPay) return;
    _stage = CashierStage.pay;
    _mode = PayMode.cash;
    _received = Money.zero;
    _reference = '';
    _parts.clear();
    _draftMethod = PaymentMethod.cash;
    _draftAmount = null;
    _error = null;
    _creditCustomerId = null;
    _creditDown = Money.zero;
    _creditDue = null;
    _creditQuery = '';
    notifyListeners();
  }

  /// Dipanggil saat keluar dari mode bill (kembali ke layar Meja).
  VoidCallback? onLeaveBill;

  /// Dipanggil oleh *Kembali ke meja* setelah bill lunas; bawaan
  /// [onLeaveBill]. Mode bagian split kembali ke layar split saat belum
  /// lunas, tapi ke layar Meja setelah lunas.
  VoidCallback? onBillDone;

  void backToCart() {
    if (pay.running) return;
    if (billMode) {
      onLeaveBill?.call();
      return;
    }
    _stage = CashierStage.browse;
    _error = null;
    notifyListeners();
  }

  void setMode(PayMode m) {
    if (m == PayMode.qris && qris == null) return;
    if (m == PayMode.credit && !canSellOnCredit) return;
    // Muat ulang setiap masuk mode kredit: piutang bisa berubah (bayar
    // piutang, retur) sejak terakhir dimuat.
    if (m == PayMode.credit && _mode != PayMode.credit && !loadCredit.running) {
      loadCredit.execute();
    }
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

  Settlement get splitSettlement => settleTender(payTotal, [
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
    // DP kredit dibuat lapisan data dari `SaleCredit.downPayment`.
    PayMode.credit => const [],
  };

  Future<Result<CheckoutResult?>> _payPart(OpenBill bill, BillPart part) async {
    final pending = _waitQris;
    final result = await _repository.payBillPart(
      bill.id,
      guest: part.amount == null ? part.guest : null,
      amount: part.amount,
      payments: pending
          ? const [SalePaymentRequest(method: PaymentMethod.qrisStatic)]
          : _payments(),
      pending: pending,
    );
    switch (result) {
      case Ok(value: SplitPayResult(:final receipt?)):
        _result = receipt;
        _stage = CashierStage.done;
        return Result.ok(receipt);
      case Ok():
        onLeaveBill?.call();
        return const Result.ok(null);
      case Error(:final error):
        _error = error;
        return Result.error(error);
    }
  }

  Future<Result<CheckoutResult?>> _pay() async {
    _error = null;
    final bill = _bill;
    if (bill != null && _part != null) return _payPart(bill, _part!);
    final result = bill != null
        ? await _repository.payBill(bill.id, _payments())
        : await _repository.checkout(
            lines: [
              for (final l in lines)
                SaleLineRequest(
                  variantId: l.variant.id,
                  productUnitId: l.unit?.id,
                  quantity: l.quantity,
                  discount: switch (l.discount) {
                    final d? => _fit(d, l.priced.lineTotal),
                    null => null,
                  },
                ),
            ],
            discount: switch (_billDiscount) {
              final d? => _fit(d, linesNet),
              null => null,
            },
            // Penyetuju hanya dikirim bila memang ada diskon.
            discountApproverId: hasDiscount ? _discountApprover?.id : null,
            payments: _payments(),
            credit: _mode == PayMode.credit
                ? SaleCredit(
                    customerId: _creditCustomerId!,
                    downPayment: _creditDown,
                    dueOn: _creditDue!,
                  )
                : null,
          );
    switch (result) {
      case Ok(:final value):
        _result = value;
        _items.clear();
        _resetDiscounts();
        // Piutang pelanggan berubah: muat ulang saat kredit dipakai lagi.
        if (_mode == PayMode.credit) _creditCustomers = null;
        _stage = CashierStage.done;
      case Error(:final error):
        _error = error;
        // Persetujuan kedaluwarsa atau ditolak: minta PIN lagi saat diskon
        // diterapkan ulang.
        if (error
            case DiscountNotPermitted() ||
                NotPermitted(
                  permission: Permission.salesDiscount,
                )) {
          _discountApprover = null;
        }
    }
    return result;
  }

  /// Kembali ke kasir kosong dan muat ulang katalog (stok terbaru).
  /// *Transaksi baru* ditahan selama struk dicetak/dibagikan agar hasilnya
  /// tidak menempel ke nota berikutnya.
  bool get canStartNewTransaction => !printing;

  void newTransaction() {
    if (!canStartNewTransaction) return;
    if (billMode) {
      (onBillDone ?? onLeaveBill)?.call();
      return;
    }
    _stage = CashierStage.browse;
    _result = null;
    _error = null;
    _resetPrint();
    printReceipt.clearResult();
    shareReceipt.clearResult();
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
    if (!shouldAutoPrint || printing) return;
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
    final sale = _result?.sale.number;
    try {
      await _printer.print(
        printer ?? const PrinterSelection(kind: PrinterKind.system, name: ''),
        lines,
        receiptPaper,
        jobName: sale ?? 'Lakuna',
      );
      if (_result?.sale.number == sale) _printed = printer?.isDirect ?? false;
      return const Result.ok(null);
    } on PrinterFailure catch (e) {
      if (_result?.sale.number == sale) _printFailure = e.reason;
      return Result.error(e);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<String?>> _shareReceipt(List<ReceiptLine> lines) async {
    _resetPrint();
    final sale = _result?.sale.number;
    try {
      final path = await _printer.sharePdf(
        lines,
        receiptPaper,
        fileName: '${sale ?? 'struk'}.pdf',
      );
      if (_result?.sale.number == sale) _sharedPath = path;
      return Result.ok(path);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
