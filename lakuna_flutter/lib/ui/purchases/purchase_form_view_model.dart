import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/purchases_repository.dart';
import '../../data/services/image_file_picker.dart';
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
    this.suggested,
    this.autoPrice = false,
  });

  final int key;
  final PurchaseProductOption product;
  final PurchaseUnitOption unit;
  final Qty quantity;
  final Money unitPrice;
  final int priceRev;

  /// Jumlah saran stok minimum dalam satuan dasar (F1-08j); `null` bila
  /// baris ditambah manual atau jumlahnya sudah diubah staf. Selama ada,
  /// mengganti satuan mengonversi jumlah dari saran ini.
  final Qty? suggested;

  /// Harga diisi otomatis (harga modal / harga beli terakhir) dan belum
  /// diketik staf, jadi boleh diganti saat supplier berganti (F1-12g).
  /// Baris dari draf tersimpan dianggap sudah ditetapkan.
  final bool autoPrice;

  Money get lineTotal => unitPrice.timesMilli(quantity.milli);

  PurchaseFormLine copyWith({
    PurchaseUnitOption? unit,
    Qty? quantity,
    Money? unitPrice,
    int? priceRev,
    bool? keepSuggested,
    bool? autoPrice,
  }) => PurchaseFormLine(
    key: key,
    product: product,
    unit: unit ?? this.unit,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    priceRev: priceRev ?? this.priceRev,
    // Jumlah baru melupakan saran kecuali pemanggil sengaja menyimpannya.
    suggested: (keepSuggested ?? quantity == null) ? suggested : null,
    autoPrice: autoPrice ?? this.autoPrice,
  );

  /// [suggested] dalam satuan [unit], dibulatkan ke atas ke satuan utuh
  /// (mis. 38 botol → 7 dus isi 6).
  Qty? suggestedIn(PurchaseUnitOption unit) {
    final base = suggested;
    if (base == null) return null;
    final factor = unit.factor.milli;
    return Qty.units((base.milli + factor - 1) ~/ factor);
  }

  PurchaseLineInput get input => PurchaseLineInput(
    quantity: quantity,
    unitPrice: unitPrice,
    factorMilli: unit.factor.milli,
  );
}

/// Form *Pembelian baru* / *Draf* (1.19, F1-12). Dengan [draftId], form
/// memuat draf itu. Dengan [restock] (F1-08c), form baru terisi baris dari
/// daftar stok minimum sekali saat pertama dimuat; bersama [draftId]
/// (F1-08i), hanya barang yang belum ada di draf yang ditambahkan.
class PurchaseFormViewModel extends ChangeNotifier {
  PurchaseFormViewModel({
    required this._repository,
    this._draftId,
    this._restock,
    this._picker = const FileSelectorImagePicker(),
  }) {
    load = Command0(_load)..addListener(notifyListeners);
    pickInvoicePhoto = Command1(_pickInvoicePhoto)
      ..addListener(notifyListeners);
    saveDraft = Command0(() => _submit(receiving: false))
      ..addListener(notifyListeners);
    receive = Command0(() => _submit(receiving: true))
      ..addListener(notifyListeners);
    deleteDraft = Command0(_deleteDraft)..addListener(notifyListeners);
  }

  final PurchasesRepository _repository;
  final ImageFilePicker _picker;

  var _disposed = false;

  /// Harga beli terakhir yang sudah dibaca selama form terbuka (`null` =
  /// belum pernah dibeli) (F1-08e, F1-12e, F1-12h).
  final _lastPrices = <UuidValue, LastPurchasePrice?>{};

  /// Seperti [_lastPrices], tetapi hanya dari satu supplier (F1-12g).
  final _supplierPrices = <UuidValue, Map<UuidValue, LastPurchasePrice?>>{};

  /// Naik setiap supplier berganti; penyegaran harga yang lebih lama
  /// dibuang (F1-12g).
  var _priceRev = 0;

  /// Supplier yang harganya dipakai: supplier baru yang diketik belum
  /// punya riwayat.
  UuidValue? get _priceSupplier => _newSupplier ? null : _supplierId;

  /// Membaca harga terakhir [ids] yang belum ada di tembolok, dari semua
  /// supplier dan dari [supplier] (bila ada). `false` bila gagal dibaca.
  Future<bool> _ensureLastPrices(
    Set<UuidValue> ids,
    UuidValue? supplier,
  ) async {
    final any = {
      for (final id in ids)
        if (!_lastPrices.containsKey(id)) id,
    };
    if (any.isNotEmpty) {
      final result = await _repository.lastPurchasePrices(any);
      if (result case Ok(:final value)) {
        for (final id in any) {
          _lastPrices[id] = value[id];
        }
      } else {
        return false;
      }
    }
    if (supplier == null) return true;
    final known = _supplierPrices[supplier] ?? const {};
    final missing = {
      for (final id in ids)
        if (!known.containsKey(id)) id,
    };
    if (missing.isEmpty) return true;
    final result = await _repository.lastPurchasePrices(
      missing,
      supplierId: supplier,
    );
    if (result case Ok(:final value)) {
      final map = _supplierPrices[supplier] ??= {};
      for (final id in missing) {
        map[id] = value[id];
      }
      return true;
    }
    return false;
  }

  /// Harga terakhir [variantId] dalam [unit] dari [supplier], atau dari
  /// semua supplier bila belum pernah dibeli darinya (F1-12g). Satuan
  /// konversi hanya memakai pembelian dalam satuan yang sama (F1-12h).
  Money? _lastPriceFor(
    UuidValue variantId,
    PurchaseUnitOption unit,
    UuidValue? supplier,
  ) {
    Money? of(LastPurchasePrice? p) => switch (unit.productUnitId) {
      null => p?.perBase,
      final id => p?.perUnit[id],
    };
    return (supplier == null
            ? null
            : of(_supplierPrices[supplier]?[variantId])) ??
        of(_lastPrices[variantId]);
  }

  /// Menyegarkan harga baris otomatis setelah supplier berganti (F1-12g).
  void _startRefresh() {
    final refresh = _refreshAutoPrices();
    _pendingFills.add(refresh);
    unawaited(refresh.whenComplete(() => _pendingFills.remove(refresh)));
  }

  Future<void> _refreshAutoPrices() async {
    final rev = ++_priceRev;
    final supplier = _priceSupplier;
    final ids = {
      for (final l in _lines)
        if (l.autoPrice) l.product.variantId,
    };
    if (ids.isEmpty) return;
    if (!await _ensureLastPrices(ids, supplier)) return;
    // Supplier berganti lagi selama menunggu: penyegaran berikutnya menang.
    if (rev != _priceRev || _disposed) return;
    var changed = false;
    _lines = [
      for (final l in _lines)
        if (l.autoPrice)
          () {
            final price =
                _lastPriceFor(l.product.variantId, l.unit, supplier) ??
                l.product.defaultPrice(l.unit);
            if (price == l.unitPrice) return l;
            changed = true;
            // priceRev naik agar isian harga yang sudah tampil ikut berganti.
            return l.copyWith(unitPrice: price, priceRev: l.priceRev + 1);
          }()
        else
          l,
    ];
    if (!changed) return;
    if (saveDraft.completed) saveDraft.clearResult();
    notifyListeners();
  }

  /// Pengisian harga terakhir yang belum selesai; simpan/terima menunggunya
  /// agar draf berisi harga yang tampil di form.
  final _pendingFills = <Future<void>>{};

  void _startFill(int key) {
    final fill = _fillLastPrice(key);
    _pendingFills.add(fill);
    unawaited(fill.whenComplete(() => _pendingFills.remove(fill)));
  }

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

  /// Memilih foto faktur; argumen `true` = kamera (F1-12b).
  late final Command1<void, bool> pickInvoicePhoto;

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

  /// Isian stok minimum yang belum dipakai (dipakai sekali, F1-08c).
  PurchaseRestock? _restock;
  var _restockApplied = 0;
  var _restockSkipped = 0;
  var _restockInDraft = 0;
  var _restockIntoDraft = false;
  String? _restockLocationName;
  String? _restockSupplierName;
  var _restockSupplierCount = 0;
  var _restockPriceCount = 0;

  /// Supplier yang diisi dari pembelian terakhir (F1-08d), `null` bila
  /// tidak ada riwayat.
  String? get restockSupplierName => _restockSupplierName;

  /// Jumlah barang yang supplier terakhirnya [restockSupplierName].
  int get restockSupplierCount => _restockSupplierCount;

  /// Jumlah baris stok minimum yang harganya diisi dari pembelian terakhir
  /// (F1-08e).
  int get restockPriceCount => _restockPriceCount;

  /// Jumlah baris yang terisi dari stok minimum (0 = form biasa).
  int get restockApplied => _restockApplied;

  /// Isian stok minimum ditambahkan ke draf yang sudah ada (F1-08i).
  bool get restockIntoDraft => _restockIntoDraft;

  /// Barang stok minimum yang sudah ada di draf itu (F1-08i).
  int get restockInDraft => _restockInDraft;

  /// Varian stok minimum yang tidak bisa dibeli (diarsip, bukan barang).
  int get restockSkipped => _restockSkipped;
  String? get restockLocationName => _restockLocationName;

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

  // Foto faktur (F1-12b): yang tampil, dan apakah berbeda dari yang
  // tersimpan (dikirim saat simpan).
  Uint8List? _invoicePhoto;
  String? _invoicePhotoName;
  var _invoicePhotoChanged = false;
  var _invoicePhotoRejected = false;
  var _invoicePhotoMissing = false;

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

  /// Foto faktur yang tampil di form (baru dipilih atau milik draf).
  Uint8List? get invoicePhoto => _invoicePhoto;
  String? get invoicePhotoName => _invoicePhotoName;

  /// Berkas terakhir yang dipilih bukan gambar atau terlalu besar.
  bool get invoicePhotoRejected => _invoicePhotoRejected;

  /// Draf punya foto tetapi berkasnya belum ada di perangkat ini.
  bool get invoicePhotoMissing => _invoicePhotoMissing;

  /// Foto dipilih atau dihapus tetapi belum disimpan.
  bool get invoicePhotoUnsaved => _invoicePhotoChanged;
  bool get canTakePhoto => _picker.canTakePhoto;

  /// Galat dari repositori untuk aksi terakhir.
  Exception? get actionError => _actionError;

  bool get busy => saveDraft.running || receive.running || deleteDraft.running;

  /// Isian terakhir yang dimuat atau disimpan (F1-12f).
  String? _saved;

  /// Isian berbeda dari keadaan terakhir yang dimuat atau disimpan, jadi
  /// meninggalkan form perlu konfirmasi (F1-12f).
  bool get hasUnsavedChanges => _saved != null && _signature() != _saved;

  /// Bertambah setiap kali staf mengubah isian (F1-12f).
  var _edits = 0;

  /// Ringkasan isian yang tersimpan ke pembelian. [photoChanged] mengganti
  /// tanda foto faktur yang belum tersimpan (F1-12i).
  String _signature({bool? photoChanged}) => [
    _supplierId?.uuid,
    _newSupplier,
    if (_newSupplier) _newSupplierName,
    _invoiceNo,
    _purchasedOn.toIso8601String(),
    _locationId?.uuid,
    for (final l in _lines)
      '${l.product.variantId.uuid}/${l.unit.productUnitId?.uuid}/'
          '${l.quantity.milli}/${l.unitPrice}',
    _discount,
    _shipping,
    _paid,
    // Sumber dana dan jatuh tempo hanya tersimpan bila dipakai.
    if (_paid != Money.zero) _funding.name,
    if (totals.total > _paid) _dueOn?.toIso8601String(),
    _note,
    photoChanged ?? _invoicePhotoChanged,
  ].join('\u0001');

  void _markSaved() => _saved = _signature();

  String? get locationName =>
      _setup?.locations.where((l) => l.id == _locationId).firstOrNull?.name;

  PurchaseTotals get totals => purchaseTotals(
    [for (final l in _lines) l.input],
    discount: _discount,
    shipping: _shipping,
  );

  /// Sisa yang menjadi hutang (tidak pernah minus).
  Money get debt => purchaseDebt(total: totals.total, paid: _paid);

  /// Dibayar dari laci melebihi perkiraan uang di laci: kelebihannya, untuk
  /// peringatan saat menerima barang (F1-03c). Tidak memblokir.
  Money? get drawerShortfall =>
      _funding == FundingKind.drawer && (_setup?.canUseDrawer ?? false)
      ? drawerShortfallOf(_paid, _setup?.drawerCash)
      : null;

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
          // Tambahan stok minimum di bawah belum tersimpan (F1-12f);
          // isian yang diubah selama foto dimuat tetap terhitung.
          _markSaved();
          await _loadInvoicePhoto(value);
          if (_restock case final r?) {
            _restock = null;
            await _applyRestockToDraft(r);
          }
        case Error(:final error):
          _error = error;
          return Result.error(error);
      }
    } else {
      _blank();
      _markSaved();
      if (_restock case final r?) {
        _restock = null;
        _applyRestock(r);
        final edits = _edits;
        // Supplier dulu, agar harga diambil dari supplier itu (F1-12g).
        await _applyRestockSupplier();
        await _applyRestockPrices({for (final l in _lines) l.key});
        // Isian otomatis bisa dibuat ulang: bukan perubahan (F1-12f),
        // kecuali staf sudah mengubah isian selama menunggu.
        if (_edits == edits) _markSaved();
      }
    }
    return const Result.ok(null);
  }

  Future<void> _loadInvoicePhoto(PurchaseDetail d) async {
    _clearInvoicePhoto();
    if (!d.hasInvoicePhoto) return;
    final photo = await _repository.invoicePhoto(d.purchase.id);
    // Hanya `Ok(null)` berarti berkas belum ada; galat baca tidak
    // ditampilkan sebagai "belum ada di perangkat" (foto tetap tersimpan).
    if (photo case Ok(:final value)) {
      _invoicePhoto = value;
      _invoicePhotoMissing = value == null;
    }
  }

  void _clearInvoicePhoto() {
    _invoicePhoto = null;
    _invoicePhotoName = null;
    _invoicePhotoChanged = false;
    _invoicePhotoRejected = false;
    _invoicePhotoMissing = false;
  }

  Future<Result<void>> _pickInvoicePhoto(bool camera) async {
    _invoicePhotoRejected = false;
    const max = PurchaseLimits.invoicePhotoInputMaxBytes;
    try {
      final picked = camera
          ? await _picker.takePhoto(maxBytes: max)
          : await _picker.pickImage(maxBytes: max);
      if (picked == null) return const Result.ok(null);
      final bytes = picked.bytes;
      if (bytes == null || readImageHeader(bytes) == null) {
        _invoicePhotoRejected = true;
      } else {
        _invoicePhoto = bytes;
        _invoicePhotoName = picked.name;
        _invoicePhotoChanged = true;
        _invoicePhotoMissing = false;
        _touched();
      }
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  /// Mengosongkan foto faktur (tersimpan saat form disimpan).
  void removeInvoicePhoto() {
    _invoicePhoto = null;
    _invoicePhotoName = null;
    _invoicePhotoChanged = true;
    _invoicePhotoRejected = false;
    _invoicePhotoMissing = false;
    _touched();
  }

  /// Draf dibuka dari Stok › Stok minimum (F1-08i): barang yang belum ada
  /// ditambahkan di akhir dengan jumlah saran dan harga beli terakhir.
  /// Lokasi, supplier, dan baris draf yang sudah ada tidak diubah.
  Future<void> _applyRestockToDraft(PurchaseRestock r) async {
    final existing = {for (final l in _lines) l.product.variantId};
    final missing = [
      for (final l in r.lines)
        if (!existing.contains(l.variantId)) l,
    ];
    final before = {for (final l in _lines) l.key};
    _applyRestock(
      PurchaseRestock(
        locationId: r.locationId,
        locationName: r.locationName,
        lines: missing,
      ),
      keepLocation: true,
    );
    _restockIntoDraft = true;
    _restockInDraft = r.lines.length - missing.length;
    await _applyRestockPrices({
      for (final l in _lines)
        if (!before.contains(l.key)) l.key,
    });
  }

  void _applyRestock(PurchaseRestock r, {bool keepLocation = false}) {
    if (!keepLocation && _setup!.locations.any((l) => l.id == r.locationId)) {
      _locationId = r.locationId;
    }
    var applied = 0;
    var skipped = 0;
    for (final line in r.lines) {
      final option = _options
          .where((o) => o.variantId == line.variantId)
          .firstOrNull;
      if (option == null) {
        skipped++;
        continue;
      }
      final unit = option.unit(null);
      _lines = [
        ..._lines,
        PurchaseFormLine(
          key: _nextKey++,
          product: option,
          unit: unit,
          quantity: line.quantity,
          unitPrice: option.defaultPrice(unit),
          suggested: line.quantity,
          autoPrice: true,
        ),
      ];
      applied++;
    }
    _restockApplied = applied;
    _restockSkipped = skipped;
    // Lokasi asal sudah dihapus: catatan menyebut lokasi yang dipakai form.
    _restockLocationName = locationName ?? r.locationName;
  }

  /// Harga beli terakhir untuk baris [keys] yang terisi dari stok minimum
  /// (F1-08e). Hanya baris yang harganya belum diubah staf selama menunggu,
  /// dalam satuannya saat harga tiba (F1-12h); galat baca diabaikan (harga
  /// modal tetap dipakai).
  Future<void> _applyRestockPrices(Set<int> keys) async {
    final targets = [
      for (final l in _lines)
        if (keys.contains(l.key)) l,
    ];
    if (targets.isEmpty) return;
    final requested = {for (final l in targets) l.product.variantId};
    final supplier = _priceSupplier;
    final rev = _priceRev;
    if (await _ensureLastPrices(requested, supplier)) {
      // Supplier berganti selama menunggu: penyegarannya yang mengisi
      // harga baris otomatis (F1-12g).
      if (rev != _priceRev || supplier != _priceSupplier) return;
      var count = 0;
      final lines = <PurchaseFormLine>[];
      for (final l in _lines) {
        final price = _lastPriceFor(l.product.variantId, l.unit, supplier);
        // Harga yang diketik staf selama menunggu tidak ditimpa.
        if (price != null && keys.contains(l.key) && l.autoPrice) {
          // priceRev naik agar isian harga yang sudah tampil ikut berganti.
          lines.add(l.copyWith(unitPrice: price, priceRev: l.priceRev + 1));
          count++;
        } else {
          lines.add(l);
        }
      }
      _lines = lines;
      _restockPriceCount = count;
    }
  }

  /// Supplier terakhir untuk barang yang terisi dari stok minimum (F1-08d).
  /// Galat baca diabaikan: supplier tetap kosong seperti F1-08c.
  Future<void> _applyRestockSupplier() async {
    if (_lines.isEmpty) return;
    final result = await _repository.lastSuppliers({
      for (final l in _lines) l.product.variantId,
    });
    if (result case Ok(:final value)) {
      final suppliers = {for (final s in _setup!.suppliers) s.id: s};
      final choice = chooseRestockSupplier([
        for (final last in value.values)
          if (suppliers.containsKey(last.supplierId))
            (supplier: last.supplierId, at: last.at),
      ]);
      // Staf sudah memilih supplier selama menunggu: pilihannya dipakai.
      if (choice == null || _supplierId != null || _newSupplier) return;
      final edits = _edits;
      _changeSupplier(() {
        _supplierId = choice.supplier;
        _newSupplier = false;
      });
      // Isian otomatis, bukan ubahan staf (F1-12f).
      _edits = edits;
      _restockSupplierName = suppliers[choice.supplier]!.name;
      _restockSupplierCount = choice.count;
    }
  }

  void _blank() {
    final s = _setup!;
    // Form baru: pembelian yang baru diterima bisa mengubah harga terakhir.
    _lastPrices.clear();
    _supplierPrices.clear();
    // Penyegaran harga untuk form sebelumnya dibuang (F1-12g).
    _priceRev++;
    _draftId = null;
    _restockSupplierName = null;
    _restockSupplierCount = 0;
    _restockPriceCount = 0;
    _restockApplied = 0;
    _restockSkipped = 0;
    _restockInDraft = 0;
    _restockIntoDraft = false;
    _restockLocationName = null;
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
    _clearInvoicePhoto();
    _attempt = null;
    _actionError = null;
    _generation++;
  }

  void _fill(PurchaseDetail d) {
    final p = d.purchase;
    // Penyegaran harga untuk isian sebelumnya dibuang (F1-12g).
    _priceRev++;
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
        ? _plusDays(_purchasedOn, _termDays)
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
    _edits++;
    _actionError = null;
    // Pesan "Draf disimpan" hilang setelah isian berubah.
    if (saveDraft.completed) saveDraft.clearResult();
    notifyListeners();
  }

  /// [d] + [days] hari kalender (aman dari pergantian jam musim panas).
  static DateTime _plusDays(DateTime d, int days) =>
      DateTime(d.year, d.month, d.day + days);

  void selectSupplier(UuidValue? id) {
    final before = _priceSupplier;
    _changeSupplier(() {
      if (id != _supplierId) _restockSupplierName = null;
      _supplierId = id;
      _newSupplier = false;
    });
    if (_priceSupplier != before) _startRefresh();
  }

  /// Mengetik nama supplier baru (dibuat saat simpan).
  void useNewSupplier() {
    final before = _priceSupplier;
    _changeSupplier(() {
      _restockSupplierName = null;
      _supplierId = null;
      _newSupplier = true;
    });
    if (_priceSupplier != before) _startRefresh();
  }

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
        existing.copyWith(
          quantity: existing.quantity + Qty.units(1),
          keepSuggested: false,
        ),
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
        autoPrice: true,
      ),
    ];
    _touched();
    _startFill(_lines.last.key);
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
        if (sameBarcode(u.barcode, q)) {
          return addProduct(o.variantId, u.productUnitId);
        }
      }
    }
    final exact = _options.where(
      (o) => sameBarcode(o.barcode, q) || o.sku?.toLowerCase() == q,
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

  /// Harga beli terakhir untuk baris yang ditambah staf atau yang satuannya
  /// diganti (F1-12e, F1-12h: satuan konversi memakai pembelian terakhir
  /// dalam satuan yang sama). Harga yang sudah
  /// diubah staf selama menunggu tidak ditimpa; galat baca diabaikan (harga
  /// modal tetap) dan dicoba lagi untuk baris berikutnya.
  Future<void> _fillLastPrice(int key) async {
    final line = _line(key);
    if (line == null) return;
    final variantId = line.product.variantId;
    final supplier = _priceSupplier;
    if (!await _ensureLastPrices({variantId}, supplier)) return;
    // Supplier berganti selama menunggu: penyegarannya yang mengisi.
    if (supplier != _priceSupplier) return;
    final now = _line(key);
    if (now == null) return;
    // Harga satuan baris saat ini; satuan bisa diganti selama menunggu.
    final price = _lastPriceFor(variantId, now.unit, supplier);
    if (price == null || !now.autoPrice || now.unitPrice == price) {
      return;
    }
    // priceRev naik agar isian harga yang sudah tampil ikut berganti.
    _replace(now.copyWith(unitPrice: price, priceRev: now.priceRev + 1));
    // Draf yang tersimpan sebelum harga terisi kini berbeda dari form.
    if (saveDraft.completed) saveDraft.clearResult();
    notifyListeners();
  }

  void setQuantity(int key, Qty quantity) {
    final line = _line(key);
    if (line == null || quantity == line.quantity) return;
    // Staf menentukan jumlahnya sendiri: saran tidak lagi dikonversi.
    _replace(line.copyWith(quantity: quantity, keepSuggested: false));
    _touched();
  }

  void setUnitPrice(int key, Money price) {
    final line = _line(key);
    // Isian harga memanggil ini juga saat fokus atau seleksi berubah;
    // harga yang sama bukan ketikan staf (F1-12g).
    if (line == null || price == line.unitPrice) return;
    // Harga yang diketik staf tidak diganti otomatis lagi (F1-12g).
    _replace(line.copyWith(unitPrice: price, autoPrice: false));
    _touched();
  }

  /// Mengganti satuan baris; harga beli diisi ulang dengan harga awal
  /// satuan baru, lalu harga beli terakhir satuan itu bila ada (F1-12h).
  /// Bila varian itu sudah punya baris dengan satuan yang sama,
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
    // Saran stok minimum ikut satuan baru (F1-08j).
    final converted = line.suggestedIn(unit);
    if (twin != null) {
      _replace(
        twin.copyWith(
          quantity: twin.quantity + (converted ?? line.quantity),
          keepSuggested: false,
        ),
      );
      _lines = [
        for (final l in _lines)
          if (l.key != key) l,
      ];
    } else {
      _replace(
        line.copyWith(
          unit: unit,
          quantity: converted,
          unitPrice: line.product.defaultPrice(unit),
          priceRev: line.priceRev + 1,
          keepSuggested: true,
          autoPrice: true,
        ),
      );
      _startFill(key);
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
      invoicePhoto: _invoicePhotoChanged && _invoicePhoto != null
          ? PurchaseInvoicePhoto(
              bytes: _invoicePhoto!,
              fileName: _invoicePhotoName ?? 'faktur',
            )
          : null,
      removeInvoicePhoto: _invoicePhotoChanged && _invoicePhoto == null,
    );
  }

  Future<Result<Purchase>> _submit({required bool receiving}) async {
    if (_pendingFills.isNotEmpty) await Future.wait([..._pendingFills]);
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
    // Ringkasan isian yang dikirim, diambil sebelum menunggu penyimpanan:
    // isian yang diubah selama simpan tetap terhitung belum tersimpan, jadi
    // simpan dari dialog Buang perubahan? tidak membuangnya diam-diam
    // (F1-12i). Foto faktur ikut tersimpan, jadi tandanya dianggap bersih.
    final sent = _signature(photoChanged: false);
    final result = receiving
        ? await _repository.receive(request)
        : await _repository.saveDraft(request);
    switch (result) {
      case Ok(:final value):
        _draftId = value.id;
        _number = value.number;
        _attempt = null;
        _invoicePhotoChanged = false;
        // Barang diterima: form diganti, isian sisa tidak berarti lagi.
        if (receiving) {
          _markSaved();
        } else {
          _saved = sent;
        }
        // Tambahan stok minimum sudah tersimpan: catatan "simpan draf agar
        // tambahan tersimpan" tidak berlaku lagi (F1-08i).
        if (_restockIntoDraft) {
          _restockIntoDraft = false;
          _restockInDraft = 0;
          _restockApplied = 0;
          _restockSkipped = 0;
          _restockPriceCount = 0;
          _restockLocationName = null;
        }
      case Error(:final error):
        _actionError = error;
    }
    return result;
  }

  Future<Result<void>> _deleteDraft() async {
    final id = _draftId;
    if (id == null) return const Result.ok(null);
    final result = await _repository.deleteDraft(id);
    switch (result) {
      case Ok():
        // Draf sudah dihapus: form boleh ditinggalkan (F1-12f).
        _markSaved();
      case Error(:final error):
        _actionError = error;
    }
    return result;
  }
}
