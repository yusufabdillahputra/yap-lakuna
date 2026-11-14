import 'package:flutter/widgets.dart' show StringCharacters;
import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/purchases_repository.dart';
import '../../data/services/image_file_picker.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Saran harga jual satu baris barang diterima (1.19b).
@immutable
class PriceSuggestion {
  const PriceSuggestion({
    required this.item,
    required this.sellPrice,
    required this.suggested,
  });

  final PurchaseItem item;

  /// Harga jual varian sekarang (satuan dasar).
  final Money sellPrice;

  /// Harga yang menjaga margin lama.
  final Money suggested;

  /// Harga jual di bawah saran: dicentang otomatis.
  bool get below => sellPrice < suggested;
}

/// Masalah form retur pembelian sebelum dikirim.
enum PurchaseReturnIssue { empty, quantity, refundSource, note }

/// Halaman *Detail pembelian* (1.19b, F1-12): HPP, saran harga jual, dan
/// retur pembelian.
class PurchaseDetailViewModel extends ChangeNotifier {
  PurchaseDetailViewModel({
    required this._repository,
    required this.purchaseId,
    this._picker = const FileSelectorImagePicker(),
  }) {
    load = Command0(_load)..addListener(notifyListeners);
    attachInvoicePhoto = Command1(_attachInvoicePhoto)
      ..addListener(notifyListeners);
    removeInvoicePhoto = Command0(_removeInvoicePhoto)
      ..addListener(notifyListeners);
    applyPrices = Command0(_applyPrices)..addListener(notifyListeners);
    submitReturn = Command0(_submitReturn)..addListener(notifyListeners);
  }

  final PurchasesRepository _repository;
  final UuidValue purchaseId;
  final ImageFilePicker _picker;

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
  late final Command0<void> applyPrices;
  late final Command0<PurchaseReturn> submitReturn;

  /// Melampirkan atau mengganti foto faktur; argumen `true` = kamera
  /// (F1-12b).
  late final Command1<void, bool> attachInvoicePhoto;
  late final Command0<void> removeInvoicePhoto;

  Uint8List? _invoicePhoto;
  var _invoicePhotoRejected = false;

  /// Isi foto faktur; `null` bila tidak ada atau berkasnya belum ada di
  /// perangkat ini (lihat `detail.hasInvoicePhoto`).
  Uint8List? get invoicePhoto => _invoicePhoto;

  /// Berkas terakhir yang dipilih bukan gambar atau terlalu besar.
  bool get invoicePhotoRejected => _invoicePhotoRejected;
  bool get canTakePhoto => _picker.canTakePhoto;
  bool get photoBusy =>
      attachInvoicePhoto.running || removeInvoicePhoto.running;

  PurchaseSetup? _setup;
  PurchaseDetail? _detail;
  Exception? _error;
  var _suggestions = const <PriceSuggestion>[];
  var _checked = <UuidValue>{};

  // Form retur.
  var _returning = false;
  var _returnQty = <UuidValue, Qty>{};
  var _returnNote = '';
  FundingKind? _refundSource;
  var _returnAttempted = false;
  Exception? _returnError;
  var _formGeneration = 0;

  PurchaseSetup? get setup => _setup;
  PurchaseDetail? get detail => _detail;
  Exception? get error => _error;
  String? get timezone => _setup?.timezone;

  List<PriceSuggestion> get suggestions => _suggestions;

  /// Varian yang dicentang *Ubah harga*.
  Set<UuidValue> get checked => _checked;

  bool get returning => _returning;
  Map<UuidValue, Qty> get returnQty => _returnQty;
  String get returnNote => _returnNote;
  FundingKind? get refundSource => _refundSource;
  Exception? get returnError => _returnError;
  int get formGeneration => _formGeneration;

  /// Hari sampai jatuh tempo (minus = lewat); `null` bila tidak ada hutang.
  int? get dueInDays {
    final due = _detail?.purchase.dueOn;
    final today = _setup?.today;
    if (due == null || today == null || _detail!.debt.value <= 0) return null;
    return DateTime.utc(
      due.year,
      due.month,
      due.day,
    ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
  }

  Future<Result<void>> _load() async {
    final setup = await _repository.load();
    if (setup case Error(:final error)) {
      _error = error;
      return Result.error(error);
    }
    _setup = (setup as Ok<PurchaseSetup>).value;
    return _fetch();
  }

  Future<Result<void>> _fetch() async {
    final result = await _repository.detail(purchaseId);
    switch (result) {
      case Ok(:final value):
        _detail = value;
        _error = null;
        _invoicePhoto = await _photoOf(value);
        _suggestions = _suggest(value);
        _checked = {
          for (final s in _suggestions)
            if (s.below) s.item.variantId,
        };
        return const Result.ok(null);
      case Error(:final error):
        _error = error;
        return Result.error(error);
    }
  }

  Future<Uint8List?> _photoOf(PurchaseDetail d) async {
    if (!d.hasInvoicePhoto) return null;
    final photo = await _repository.invoicePhoto(d.purchase.id);
    return photo is Ok<Uint8List?> ? photo.value : null;
  }

  Future<Result<void>> _attachInvoicePhoto(bool camera) async {
    _invoicePhotoRejected = false;
    const max = PurchaseLimits.invoicePhotoMaxBytes;
    final PickedImage? picked;
    try {
      picked = camera
          ? await _picker.takePhoto(maxBytes: max)
          : await _picker.pickImage(maxBytes: max);
    } on Exception catch (e) {
      return Result.error(e);
    }
    if (picked == null) return const Result.ok(null);
    final bytes = picked.bytes;
    if (bytes == null || readImageHeader(bytes) == null) {
      _invoicePhotoRejected = true;
      return const Result.ok(null);
    }
    final result = await _repository.setInvoicePhoto(
      purchaseId,
      PurchaseInvoicePhoto(bytes: bytes, fileName: picked.name),
    );
    if (result case Error(:final error)) return Result.error(error);
    return _refresh();
  }

  Future<Result<void>> _removeInvoicePhoto() async {
    _invoicePhotoRejected = false;
    final result = await _repository.clearInvoicePhoto(purchaseId);
    if (result case Error(:final error)) return Result.error(error);
    return _refresh();
  }

  /// Muat ulang detail setelah foto berubah; centang harga yang sudah
  /// diubah pengguna tetap.
  Future<Result<void>> _refresh() async {
    final checked = _checked;
    final result = await _fetch();
    _checked = checked;
    return result;
  }

  /// Satu saran per varian, di baris pertamanya. Varian yang dibeli dalam
  /// dua satuan memakai HPP sebelum dari baris pertama dan HPP sesudah dari
  /// baris terakhir (ledger berurutan).
  static List<PriceSuggestion> _suggest(PurchaseDetail d) {
    final byVariant = <UuidValue, List<PurchaseItem>>{};
    for (final item in d.items) {
      (byVariant[item.variantId] ??= []).add(item);
    }
    return [
      for (final MapEntry(key: variantId, value: items) in byVariant.entries)
        if (items.first.avgCostBefore case final before?)
          if (items.last.avgCostAfter case final after?)
            PriceSuggestion(
              item: items.first,
              sellPrice: d.sellPrices[variantId] ?? Money.zero,
              // Dasar saran: harga jual saat barang diterima, agar saran
              // tidak naik lagi setelah harga diterapkan.
              suggested: suggestedSellPrice(
                sellPrice: Money(
                  items.first.sellPriceBefore ??
                      d.sellPrices[variantId]?.value ??
                      0,
                ),
                oldCost: Money(before),
                newCost: Money(after),
              ),
            ),
    ];
  }

  /// Staf boleh menerapkan harga jual.
  bool get canEditPrices => _setup?.canEditPrices ?? false;

  PriceSuggestion? suggestionFor(PurchaseItem item) =>
      _suggestions.where((s) => s.item.id == item.id).firstOrNull;

  void toggle(UuidValue variantId, bool value) {
    _checked = {..._checked};
    value ? _checked.add(variantId) : _checked.remove(variantId);
    notifyListeners();
  }

  Future<Result<void>> _applyPrices() async {
    final prices = <UuidValue, Money>{
      for (final s in _suggestions)
        if (_checked.contains(s.item.variantId)) s.item.variantId: s.suggested,
    };
    if (prices.isEmpty) return const Result.ok(null);
    final result = await _repository.applySellPrices(prices);
    if (result is Error<void>) return result;
    return _fetch();
  }

  // --- Retur -------------------------------------------------------------

  void openReturn() {
    _returning = true;
    _resetReturn();
    notifyListeners();
  }

  void closeReturn() {
    _returning = false;
    _resetReturn();
    notifyListeners();
  }

  void _resetReturn() {
    _returnQty = {};
    _returnNote = '';
    _refundSource = null;
    _returnAttempted = false;
    _returnError = null;
    _formGeneration++;
  }

  void setReturnQty(UuidValue itemId, Qty qty) {
    _returnQty = {..._returnQty, itemId: qty};
    _returnError = null;
    notifyListeners();
  }

  void setReturnNote(String v) {
    _returnNote = v;
    _returnError = null;
    notifyListeners();
  }

  void setRefundSource(FundingKind v) {
    _refundSource = v;
    _returnError = null;
    notifyListeners();
  }

  /// Qty retur melebihi sisa baris.
  bool exceeds(PurchaseItem item) =>
      (_returnQty[item.id]?.milli ?? 0) > (_detail?.remainingMilli(item) ?? 0);

  /// Nilai retur yang sedang diisi (baris yang melebihi sisa diabaikan).
  Money get returnTotal {
    final d = _detail;
    if (d == null) return Money.zero;
    var sum = Money.zero;
    for (final item in d.items) {
      final q = _returnQty[item.id]?.milli ?? 0;
      if (q <= 0 || exceeds(item)) continue;
      sum += returnAmount(
        share: d.landedTotal(item),
        soldMilli: item.quantityMilli,
        returnedMilli: d.returnedMilli[item.id] ?? 0,
        returningMilli: q,
      );
    }
    return sum;
  }

  ({Money debtReduction, Money refund}) get returnSplit => purchaseReturnSplit(
    amount: returnTotal,
    debt: _detail?.debt ?? Money.zero,
  );

  List<PurchaseReturnIssue> get returnIssues =>
      _returnAttempted ? _returnValidate() : const [];

  List<PurchaseReturnIssue> _returnValidate() {
    final d = _detail;
    if (d == null) return const [PurchaseReturnIssue.empty];
    final issues = <PurchaseReturnIssue>[];
    if (d.items.any(exceeds)) issues.add(PurchaseReturnIssue.quantity);
    if (!_returnQty.values.any((q) => q.milli > 0)) {
      issues.add(PurchaseReturnIssue.empty);
    }
    if (returnSplit.refund.value > 0 && _refundSource == null) {
      issues.add(PurchaseReturnIssue.refundSource);
    }
    if (_returnNote.trim().characters.length > PurchaseLimits.note) {
      issues.add(PurchaseReturnIssue.note);
    }
    return issues;
  }

  Future<Result<PurchaseReturn>> _submitReturn() async {
    _returnAttempted = true;
    _returnError = null;
    final issues = _returnValidate();
    if (issues.isNotEmpty) {
      notifyListeners();
      return Result.error(
        PurchaseReturnInvalid(
          PurchaseReturnError.values.byName(issues.first.name),
        ),
      );
    }
    final note = _returnNote.trim();
    final result = await _repository.returnPurchase(
      purchaseId: purchaseId,
      lines: [
        for (final item in _detail!.items)
          if ((_returnQty[item.id]?.milli ?? 0) > 0)
            PurchaseReturnLine(
              purchaseItemId: item.id,
              quantity: _returnQty[item.id]!,
            ),
      ],
      note: note.isEmpty ? null : note,
      refundSource: returnSplit.refund.value > 0 && _refundSource != null
          ? FundingSource.values.byName(_refundSource!.name)
          : null,
    );
    switch (result) {
      case Ok():
        _returning = false;
        _resetReturn();
        await _fetch();
      case Error(:final error):
        _returnError = error;
    }
    return result;
  }
}
