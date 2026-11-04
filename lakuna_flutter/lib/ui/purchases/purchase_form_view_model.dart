import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/purchases_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Hasil *+ Scan / cari produk*.
enum PurchaseScanResult { added, increased, notFound }

/// Satuan yang bisa dibeli untuk satu varian: satuan dasar
/// ([productUnitId] `null`) atau satuan konversi.
@immutable
class PurchaseUnitOption {
  const PurchaseUnitOption({
    required this.name,
    required this.factor,
    this.productUnitId,
    this.barcode,
    this.costPrice,
  });

  final UuidValue? productUnitId;
  final String name;

  /// Isi satuan dalam satuan dasar.
  final Qty factor;
  final String? barcode;
  final Money? costPrice;

  bool get isBase => productUnitId == null;
}

/// Varian yang bisa dibeli beserta satuannya (satuan dasar dulu).
@immutable
class PurchaseProductOption {
  const PurchaseProductOption({
    required this.variantId,
    required this.productName,
    required this.variantName,
    required this.costPrice,
    required this.units,
    this.sku,
    this.barcode,
  });

  final UuidValue variantId;
  final String productName;

  /// Kosong bila produk hanya punya satu varian.
  final String variantName;
  final String? sku;
  final String? barcode;

  /// HPP satuan dasar saat ini.
  final Money costPrice;
  final List<PurchaseUnitOption> units;

  String get displayName =>
      variantName.isEmpty ? productName : '$productName $variantName';

  PurchaseUnitOption get baseUnit => units.first;

  PurchaseUnitOption unit(UuidValue? productUnitId) =>
      units.where((u) => u.productUnitId == productUnitId).firstOrNull ??
      baseUnit;

  /// Harga beli awal per [unit]: HPP satuan itu, atau HPP dasar × isi.
  Money defaultPrice(PurchaseUnitOption unit) =>
      unit.costPrice ?? costPrice.timesMilli(unit.factor.milli);
}

/// Pilihan produk dari katalog: produk aktif yang melacak stok.
List<PurchaseProductOption> purchaseOptions(List<CatalogProduct> products) => [
  for (final p in products)
    for (final v in p.variants)
      PurchaseProductOption(
        variantId: v.id,
        productName: p.name,
        variantName: p.variants.length == 1 ? '' : v.name,
        sku: v.sku,
        barcode: v.barcode,
        costPrice: v.costPrice,
        units: [
          PurchaseUnitOption(name: p.baseUnit, factor: Qty.units(1)),
          for (final u in v.units)
            PurchaseUnitOption(
              productUnitId: u.id,
              name: u.name,
              factor: u.factor,
              barcode: u.barcode,
              costPrice: u.costPrice,
            ),
        ],
      ),
];

/// Satu baris form pembelian. [key] stabil selama form terbuka; [priceRev]
/// naik bila harga diganti dari luar field (mis. ganti satuan).
@immutable
class PurchaseFormLine {
  const PurchaseFormLine({
    required this.key,
    required this.product,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    this.priceRev = 0,
  });

  final int key;
  final PurchaseProductOption product;
  final PurchaseUnitOption unit;
  final Qty quantity;
  final Money unitPrice;
  final int priceRev;

  Money get lineTotal => unitPrice.timesMilli(quantity.milli);

  PurchaseFormLine copyWith({
    PurchaseUnitOption? unit,
    Qty? quantity,
    Money? unitPrice,
    int? priceRev,
  }) => PurchaseFormLine(
    key: key,
    product: product,
    unit: unit ?? this.unit,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    priceRev: priceRev ?? this.priceRev,
  );

  PurchaseLineInput get input => PurchaseLineInput(
    quantity: quantity,
    unitPrice: unitPrice,
    factorMilli: unit.factor.milli,
  );
}

/// Form *Pembelian baru* / *Draf* (1.19, F1-12). Dengan [draftId], form
/// memuat draf itu.
class PurchaseFormViewModel extends ChangeNotifier {
  PurchaseFormViewModel({required this._repository, this._draftId}) {
    load = Command0(_load)..addListener(notifyListeners);
    saveDraft = Command0(() => _submit(receiving: false))
      ..addListener(notifyListeners);
    receive = Command0(() => _submit(receiving: true))
      ..addListener(notifyListeners);
    deleteDraft = Command0(_deleteDraft)..addListener(notifyListeners);
  }

  final PurchasesRepository _repository;

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Perintah yang selesai setelah layar ditutup tidak memberi tahu lagi.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  late final Command0<void> load;
  late final Command0<Purchase> saveDraft;
  late final Command0<Purchase> receive;
  late final Command0<void> deleteDraft;

  /// Jatuh tempo bawaan tanpa supplier terpilih: 14 hari setelah tanggal
  /// pembelian. Supplier terpilih memakai tempo standarnya (F1-14).
  static const defaultTermDays = SupplierLimits.defaultTermDays;

  /// Tempo standar supplier terpilih, atau [defaultTermDays].
  int get _termDays => _newSupplier || _supplierId == null
      ? defaultTermDays
      : _setup?.suppliers
                .where((s) => s.id == _supplierId)
                .firstOrNull
                ?.termDays ??
            defaultTermDays;

  /// Mengganti supplier lewat [change]; jatuh tempo ikut tempo supplier
  /// baru bila masih bawaan.
  void _changeSupplier(VoidCallback change) {
    final wasDefault =
        _dueOn == null || _dueOn == _plusDays(_purchasedOn, _termDays);
    change();
    if (wasDefault) {
      _dueOn = _plusDays(_purchasedOn, _termDays);
      _generation++;
    }
    _touched();
  }

  PurchaseSetup? _setup;
  Exception? _error;
  var _options = const <PurchaseProductOption>[];
  UuidValue? _draftId;
  String _number = '';

  UuidValue? _supplierId;
  var _newSupplier = false;
  var _newSupplierName = '';
  var _invoiceNo = '';
  DateTime _purchasedOn = DateTime(2000);
  UuidValue? _locationId;
  var _lines = const <PurchaseFormLine>[];
  var _nextKey = 0;
  var _discount = Money.zero;
  var _shipping = Money.zero;
  var _paid = Money.zero;
  var _funding = FundingKind.storeCash;
  DateTime? _dueOn;
  var _note = '';

  /// Aksi terakhir yang dicoba; galat isian tampil setelahnya.
  bool? _attempt;
  Exception? _actionError;

  /// Naik setiap form dikosongkan atau diisi ulang, untuk kunci field teks.
  var _generation = 0;

  PurchaseSetup? get setup => _setup;
  Exception? get error => _error;
  List<PurchaseProductOption> get options => _options;
  UuidValue? get draftId => _draftId;
  bool get isDraft => _draftId != null;
  String get number => _number;
  int get generation => _generation;

  UuidValue? get supplierId => _supplierId;
  bool get newSupplier => _newSupplier;
  String get newSupplierName => _newSupplierName;
  String get invoiceNo => _invoiceNo;
  DateTime get purchasedOn => _purchasedOn;
  UuidValue? get locationId => _locationId;
  List<PurchaseFormLine> get lines => _lines;
  Money get discount => _discount;
  Money get shipping => _shipping;
  Money get paid => _paid;
  FundingKind get funding => _funding;
  DateTime? get dueOn => _dueOn;
  String get note => _note;

  /// Galat dari repositori untuk aksi terakhir.
  Exception? get actionError => _actionError;

  bool get busy => saveDraft.running || receive.running || deleteDraft.running;

  String? get locationName =>
      _setup?.locations.where((l) => l.id == _locationId).firstOrNull?.name;

  PurchaseTotals get totals => purchaseTotals(
    [for (final l in _lines) l.input],
    discount: _discount,
    shipping: _shipping,
  );

  /// Sisa yang menjadi hutang (tidak pernah minus).
  Money get debt => purchaseDebt(total: totals.total, paid: _paid);

  /// Galat isian untuk aksi terakhir yang dicoba (kosong sebelum mencoba).
  List<PurchaseIssue> get issues =>
      _attempt == null ? const [] : _validate(receiving: _attempt!);

  bool hasIssue(PurchaseField field, [int? index]) =>
      issues.contains(PurchaseIssue(field, index));

  List<PurchaseIssue> _validate({required bool receiving}) {
    final hasDebt = debt.value > 0;
    return validatePurchase(
      lines: [for (final l in _lines) l.input],
      discount: _discount,
      shipping: _shipping,
      paid: _paid,
      funding: _paid.value > 0 ? _funding : null,
      hasSupplier: _hasSupplier,
      purchasedOn: _purchasedOn,
      dueOn: hasDebt ? _dueOn : null,
      invoiceNo: _invoiceNo,
      note: _note,
      receiving: receiving,
    );
  }

  bool get _hasSupplier =>
      _newSupplier ? _newSupplierName.trim().isNotEmpty : _supplierId != null;

  Future<Result<void>> _load() async {
    final setup = await _repository.load();
    switch (setup) {
      case Ok(:final value):
        _setup = value;
        _options = purchaseOptions(value.products);
        _error = null;
      case Error(:final error):
        _error = error;
        return Result.error(error);
    }
    if (_draftId case final id?) {
      final detail = await _repository.detail(id);
      switch (detail) {
        case Ok(:final value):
          _fill(value);
        case Error(:final error):
          _error = error;
          return Result.error(error);
      }
    } else {
      _blank();
    }
    return const Result.ok(null);
  }

  void _blank() {
    final s = _setup!;
    _draftId = null;
    _number = s.nextNumber;
    _supplierId = null;
    _newSupplier = false;
    _newSupplierName = '';
    _invoiceNo = '';
    _purchasedOn = s.today;
    _locationId = s.locations.firstOrNull?.id;
    _lines = const [];
    _discount = Money.zero;
    _shipping = Money.zero;
    _paid = Money.zero;
    _funding = FundingKind.storeCash;
    _dueOn = _plusDays(s.today, defaultTermDays);
    _note = '';
    _attempt = null;
    _actionError = null;
    _generation++;
  }

  void _fill(PurchaseDetail d) {
    final p = d.purchase;
    _draftId = p.id;
    _number = p.number;
    _supplierId = p.supplierId;
    _newSupplier = false;
    _newSupplierName = '';
    _invoiceNo = p.invoiceNo ?? '';
    _purchasedOn = _date(p.purchasedOn);
    _locationId = p.stockLocationId;
    _lines = [
      for (final item in d.items)
        () {
          final product =
              _options
                  .where((o) => o.variantId == item.variantId)
                  .firstOrNull ??
              _snapshotOption(item);
          return PurchaseFormLine(
            key: _nextKey++,
            product: product,
            unit: product.unit(item.productUnitId),
            quantity: Qty(item.quantityMilli),
            unitPrice: Money(item.unitPrice),
          );
        }(),
    ];
    _discount = Money(p.discount);
    _shipping = Money(p.shipping);
    _paid = Money(p.paidAmount);
    _funding = p.fundingSource == null
        ? FundingKind.storeCash
        : fundingKind(p.fundingSource!);
    _dueOn = p.dueOn == null
        ? _plusDays(_purchasedOn, defaultTermDays)
        : _date(p.dueOn!);
    _note = p.note ?? '';
    _attempt = null;
    _actionError = null;
    _generation++;
  }

  /// Produk draf yang sudah tidak aktif: pakai salinan di baris.
  PurchaseProductOption _snapshotOption(PurchaseItem item) =>
      PurchaseProductOption(
        variantId: item.variantId,
        productName: item.productName,
        variantName: item.variantName,
        costPrice: Money.zero,
        units: [
          PurchaseUnitOption(
            productUnitId: item.productUnitId,
            name: item.unitName,
            factor: Qty(item.factorMilli),
          ),
        ],
      );

  static DateTime _date(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Mengosongkan form untuk pembelian baru (mis. setelah diterima).
  Future<void> startNew() async {
    _draftId = null;
    await load.execute();
  }

  void _touched() {
    _actionError = null;
    // Pesan "Draf disimpan" hilang setelah isian berubah.
    if (saveDraft.completed) saveDraft.clearResult();
    notifyListeners();
  }

  /// [d] + [days] hari kalender (aman dari pergantian jam musim panas).
  static DateTime _plusDays(DateTime d, int days) =>
      DateTime(d.year, d.month, d.day + days);

  void selectSupplier(UuidValue? id) => _changeSupplier(() {
    _supplierId = id;
    _newSupplier = false;
  });

  /// Mengetik nama supplier baru (dibuat saat simpan).
  void useNewSupplier() => _changeSupplier(() {
    _supplierId = null;
    _newSupplier = true;
  });

  void setNewSupplierName(String v) {
    _newSupplierName = v;
    _touched();
  }

  void setInvoiceNo(String v) {
    _invoiceNo = v;
    _touched();
  }

  void setPurchasedOn(DateTime d) {
    final day = _date(d);
    // Jatuh tempo ikut bergeser bila masih bawaan atau jadi sebelum tanggal.
    final due = _dueOn;
    if (due == null ||
        due == _plusDays(_purchasedOn, _termDays) ||
        due.isBefore(day)) {
      _dueOn = _plusDays(day, _termDays);
    }
    _purchasedOn = day;
    _generation++;
    _touched();
  }

  void setLocation(UuidValue id) {
    _locationId = id;
    _touched();
  }

  void setDiscount(Money v) {
    _discount = v;
    _touched();
  }

  void setShipping(Money v) {
    _shipping = v;
    _touched();
  }

  void setPaid(Money v) {
    _paid = v;
    _touched();
  }

  /// Bayar lunas: isi *Bayar sekarang* dengan total.
  void payInFull() {
    _paid = totals.total;
    _generation++;
    _touched();
  }

  void setFunding(FundingKind v) {
    _funding = v;
    _touched();
  }

  void setDueOn(DateTime d) {
    _dueOn = _date(d);
    _touched();
  }

  void setNote(String v) {
    _note = v;
    _touched();
  }

  /// Menambah varian dalam satuan [productUnitId] (`null` = dasar). Bila
  /// baris yang sama sudah ada, qty-nya bertambah satu.
  PurchaseScanResult addProduct(
    UuidValue variantId, [
    UuidValue? productUnitId,
  ]) {
    final option = _options.where((o) => o.variantId == variantId).firstOrNull;
    if (option == null) return PurchaseScanResult.notFound;
    final unit = option.unit(productUnitId);
    final existing = _lines
        .where(
          (l) =>
              l.product.variantId == variantId &&
              l.unit.productUnitId == unit.productUnitId,
        )
        .firstOrNull;
    if (existing != null) {
      _replace(
        existing.copyWith(quantity: existing.quantity + Qty.units(1)),
      );
      _generation++;
      _touched();
      return PurchaseScanResult.increased;
    }
    _lines = [
      ..._lines,
      PurchaseFormLine(
        key: _nextKey++,
        product: option,
        unit: unit,
        quantity: Qty.units(1),
        unitPrice: option.defaultPrice(unit),
      ),
    ];
    _touched();
    return PurchaseScanResult.added;
  }

  /// *Scan / cari produk*: barcode satuan konversi memilih satuannya,
  /// barcode/SKU varian memilih satuan dasar, atau nama yang hanya cocok
  /// dengan satu varian.
  PurchaseScanResult addByCode(String code) {
    final q = code.trim().toLowerCase();
    if (q.isEmpty) return PurchaseScanResult.notFound;
    for (final o in _options) {
      for (final u in o.units.skip(1)) {
        if (u.barcode?.toLowerCase() == q) {
          return addProduct(o.variantId, u.productUnitId);
        }
      }
    }
    final exact = _options.where(
      (o) => o.barcode?.toLowerCase() == q || o.sku?.toLowerCase() == q,
    );
    final byName = _options.where(
      (o) => o.displayName.toLowerCase().contains(q),
    );
    final option = exact.isNotEmpty
        ? exact.first
        : (byName.length == 1 ? byName.first : null);
    if (option == null) return PurchaseScanResult.notFound;
    return addProduct(option.variantId);
  }

  /// Saran saat mengetik di *Scan / cari produk*.
  List<PurchaseProductOption> suggestions(String query, {int limit = 6}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _options
        .where(
          (o) =>
              o.displayName.toLowerCase().contains(q) ||
              (o.sku?.toLowerCase().startsWith(q) ?? false) ||
              (o.barcode?.startsWith(q) ?? false),
        )
        .take(limit)
        .toList();
  }

  PurchaseFormLine? _line(int key) =>
      _lines.where((l) => l.key == key).firstOrNull;

  void _replace(PurchaseFormLine line) {
    _lines = [for (final l in _lines) l.key == line.key ? line : l];
  }

  void setQuantity(int key, Qty quantity) {
    final line = _line(key);
    if (line == null) return;
    _replace(line.copyWith(quantity: quantity));
    _touched();
  }

  void setUnitPrice(int key, Money price) {
    final line = _line(key);
    if (line == null) return;
    _replace(line.copyWith(unitPrice: price));
    _touched();
  }

  /// Mengganti satuan baris; harga beli diisi ulang dengan harga awal
  /// satuan baru. Bila varian itu sudah punya baris dengan satuan yang sama,
  /// kedua baris digabung.
  void setUnit(int key, UuidValue? productUnitId) {
    final line = _line(key);
    if (line == null) return;
    final unit = line.product.unit(productUnitId);
    if (unit.productUnitId == line.unit.productUnitId) return;
    final twin = _lines
        .where(
          (l) =>
              l.key != key &&
              l.product.variantId == line.product.variantId &&
              l.unit.productUnitId == unit.productUnitId,
        )
        .firstOrNull;
    if (twin != null) {
      _replace(twin.copyWith(quantity: twin.quantity + line.quantity));
      _lines = [
        for (final l in _lines)
          if (l.key != key) l,
      ];
    } else {
      _replace(
        line.copyWith(
          unit: unit,
          unitPrice: line.product.defaultPrice(unit),
          priceRev: line.priceRev + 1,
        ),
      );
    }
    _generation++;
    _touched();
  }

  void removeLine(int key) {
    _lines = [
      for (final l in _lines)
        if (l.key != key) l,
    ];
    _touched();
  }

  PurchaseRequest _request() {
    String? orNull(String s) => s.trim().isEmpty ? null : s.trim();
    final hasDebt = debt.value > 0;
    return PurchaseRequest(
      id: _draftId,
      supplierId: _newSupplier ? null : _supplierId,
      newSupplierName: _newSupplier ? orNull(_newSupplierName) : null,
      invoiceNo: orNull(_invoiceNo),
      purchasedOn: DateTime.utc(
        _purchasedOn.year,
        _purchasedOn.month,
        _purchasedOn.day,
      ),
      locationId: _locationId!,
      lines: [
        for (final l in _lines)
          PurchaseLineRequest(
            variantId: l.product.variantId,
            productUnitId: l.unit.productUnitId,
            quantity: l.quantity,
            unitPrice: l.unitPrice,
          ),
      ],
      discount: _discount,
      shipping: _shipping,
      paid: _paid,
      funding: _paid.value > 0
          ? FundingSource.values.byName(_funding.name)
          : null,
      dueOn: hasDebt && _dueOn != null
          ? DateTime.utc(_dueOn!.year, _dueOn!.month, _dueOn!.day)
          : null,
      note: orNull(_note),
    );
  }

  Future<Result<Purchase>> _submit({required bool receiving}) async {
    _attempt = receiving;
    _actionError = null;
    if (_locationId == null) {
      final error = StockLocationNotFound();
      _actionError = error;
      notifyListeners();
      return Result.error(error);
    }
    if (_validate(receiving: receiving).isNotEmpty) {
      notifyListeners();
      return Result.error(PurchaseInvalid(_validate(receiving: receiving)));
    }
    final request = _request();
    final result = receiving
        ? await _repository.receive(request)
        : await _repository.saveDraft(request);
    switch (result) {
      case Ok(:final value):
        _draftId = value.id;
        _number = value.number;
        _attempt = null;
      case Error(:final error):
        _actionError = error;
    }
    return result;
  }

  Future<Result<void>> _deleteDraft() async {
    final id = _draftId;
    if (id == null) return const Result.ok(null);
    final result = await _repository.deleteDraft(id);
    if (result case Error(:final error)) _actionError = error;
    return result;
  }
}
