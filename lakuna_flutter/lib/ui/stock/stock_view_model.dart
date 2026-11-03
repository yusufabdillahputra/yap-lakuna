import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/stock_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Tab layar Stok (1.18).
enum StockTab { list, adjustment, card, minimum, locations }

/// Satu baris draf penyesuaian.
class AdjustmentDraftLine {
  const AdjustmentDraftLine({required this.row, this.physical, this.note = ''});

  final StockRow row;

  /// `null` = belum diisi (tidak ikut disimpan).
  final Qty? physical;
  final String note;

  /// Selisih terhadap stok sistem yang terakhir dimuat.
  Qty? get difference => physical == null
      ? null
      : stockDifference(system: row.stock, physical: physical!);

  Money get value => difference == null
      ? Money.zero
      : adjustmentValue(difference!, row.unitCost);

  AdjustmentDraftLine copyWith({
    StockRow? row,
    Qty? Function()? physical,
    String? note,
  }) => AdjustmentDraftLine(
    row: row ?? this.row,
    physical: physical == null ? this.physical : physical(),
    note: note ?? this.note,
  );
}

/// Layar Stok (F1-08, 1.18): daftar stok per lokasi, penyesuaian, kartu
/// stok, stok minimum, dan lokasi.
class StockViewModel extends ChangeNotifier {
  StockViewModel({required this._repository, required this.canAdjust}) {
    load = Command0(_load)..addListener(notifyListeners);
    save = Command0(_save)..addListener(notifyListeners);
  }

  final StockRepository _repository;

  /// Staf boleh menyimpan penyesuaian dan mengubah lokasi.
  final bool canAdjust;

  late final Command0<void> load;
  late final Command0<StockAdjustmentResult> save;

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  var _tab = StockTab.adjustment;
  StockTab get tab => _tab;
  void setTab(StockTab tab) {
    _tab = tab;
    notifyListeners();
  }

  List<StockLocation> _locations = const [];
  UuidValue? _locationId;
  List<StockRow> _rows = const [];
  List<StockRow> _below = const [];
  List<StockAdjustmentSummary> _recent = const [];
  String? _nextNumber;
  var _loaded = false;

  bool get loaded => _loaded;
  List<StockLocation> get locations => _locations;
  StockLocation? get location =>
      _locations.where((l) => l.id == _locationId).firstOrNull;
  List<StockRow> get rows => _rows;
  List<StockRow> get below => _below;
  List<StockAdjustmentSummary> get recent => _recent;
  String? get nextNumber => _nextNumber;

  // --- Daftar ---

  var _query = '';
  String get query => _query;
  void setQuery(String v) {
    _query = v;
    notifyListeners();
  }

  List<StockRow> get filteredRows {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _rows;
    return [
      for (final r in _rows)
        if (_matches(r, q)) r,
    ];
  }

  static bool _matches(StockRow r, String q) =>
      r.displayName.toLowerCase().contains(q) ||
      (r.sku?.toLowerCase() == q) ||
      (r.barcode?.toLowerCase() == q);

  /// Nilai stok semua baris di lokasi ini.
  Money get stockValue => _rows.fold(Money.zero, (sum, r) => sum + r.value);

  // --- Penyesuaian ---

  var _reason = StockAdjustmentReason.routineCheck;
  var _note = '';
  var _lines = <AdjustmentDraftLine>[];
  StockAdjustmentError? _saveError;
  String? _lastSaved;

  /// Naik setiap draf dikosongkan agar field membaca nilai awal lagi.
  var _draftRevision = 0;

  StockAdjustmentReason get reason => _reason;
  String get note => _note;
  List<AdjustmentDraftLine> get lines => _lines;
  StockAdjustmentError? get saveError => _saveError;
  String? get lastSaved => _lastSaved;
  int get draftRevision => _draftRevision;

  Money get totalValue => _lines.fold(Money.zero, (sum, l) => sum + l.value);

  bool get canSave => !save.running && _ready;

  bool get _ready =>
      canAdjust && location != null && _lines.any((l) => l.physical != null);

  /// Varian yang belum ada di draf, untuk pilihan *tambah produk*.
  List<StockRow> get addableRows => [
    for (final r in _rows)
      if (!_lines.any((l) => l.row.variantId == r.variantId)) r,
  ];

  void setReason(StockAdjustmentReason r) {
    _reason = r;
    _touched();
  }

  void setNote(String v) {
    _note = v;
    _touched();
  }

  void addLine(UuidValue variantId) {
    if (_lines.any((l) => l.row.variantId == variantId)) return;
    final row = _rows.where((r) => r.variantId == variantId).firstOrNull;
    if (row == null) return;
    _lines = [..._lines, AdjustmentDraftLine(row: row)];
    _touched();
  }

  /// *Scan / tambah produk*: barcode atau SKU persis, atau nama yang hanya
  /// cocok dengan satu produk. `false` bila tidak ketemu.
  bool addByCode(String code) {
    final q = code.trim().toLowerCase();
    if (q.isEmpty) return false;
    final exact = _rows.where(
      (r) => r.barcode?.toLowerCase() == q || r.sku?.toLowerCase() == q,
    );
    final byName = _rows.where(
      (r) => r.displayName.toLowerCase().contains(q),
    );
    final row = exact.isNotEmpty
        ? exact.first
        : (byName.length == 1 ? byName.first : null);
    if (row == null) return false;
    addLine(row.variantId);
    return true;
  }

  void removeLine(UuidValue variantId) {
    _lines = [
      for (final l in _lines)
        if (l.row.variantId != variantId) l,
    ];
    _touched();
  }

  void setPhysical(UuidValue variantId, Qty? qty) => _updateLine(
    variantId,
    (l) => l.copyWith(physical: () => qty),
  );

  void setLineNote(UuidValue variantId, String note) =>
      _updateLine(variantId, (l) => l.copyWith(note: note));

  void _updateLine(
    UuidValue variantId,
    AdjustmentDraftLine Function(AdjustmentDraftLine) change,
  ) {
    _lines = [
      for (final l in _lines) l.row.variantId == variantId ? change(l) : l,
    ];
    _touched();
  }

  void _touched() {
    _saveError = null;
    _lastSaved = null;
    notifyListeners();
  }

  void _clearDraft() {
    _lines = [];
    _note = '';
    _reason = StockAdjustmentReason.routineCheck;
    _saveError = null;
    _draftRevision++;
  }

  /// *Batal*: kosongkan draf.
  void clearDraft() {
    _clearDraft();
    _lastSaved = null;
    notifyListeners();
  }

  // --- Kartu stok ---

  UuidValue? _cardVariantId;
  StockCard? _card;
  UuidValue? get cardVariantId => _cardVariantId;
  StockCard? get card => _card;
  StockRow? get cardRow =>
      _rows.where((r) => r.variantId == _cardVariantId).firstOrNull;

  Future<void> selectCardVariant(UuidValue variantId) async {
    _cardVariantId = variantId;
    notifyListeners();
    await _loadCard();
    notifyListeners();
  }

  Future<void> _loadCard() async {
    final id = _cardVariantId;
    if (id == null) {
      _card = null;
      return;
    }
    final result = await _repository.card(
      variantId: id,
      locationId: _locationId,
    );
    _card = switch (result) {
      Ok(:final value) => value,
      Error() => null,
    };
  }

  // --- Lokasi ---

  StockLocationNameError? _locationError;
  StockLocationNameError? get locationError => _locationError;

  Future<void> selectLocation(UuidValue id) async {
    if (id == _locationId) return;
    _locationId = id;
    _clearDraft();
    await load.execute();
  }

  Future<bool> addLocation(String name) =>
      _locationAction(() => _repository.createLocation(name));

  Future<bool> renameLocation(UuidValue id, String name) =>
      _locationAction(() => _repository.renameLocation(id, name));

  Future<bool> _locationAction(
    Future<Result<StockLocation>> Function() action,
  ) async {
    _locationError = null;
    final result = await action();
    switch (result) {
      case Ok():
        final list = await _repository.locations();
        if (list case Ok(:final value)) _locations = value;
        notifyListeners();
        return true;
      case Error(:final error):
        if (error case StockLocationInvalid(:final error)) {
          _locationError = error;
        }
        notifyListeners();
        return false;
    }
  }

  void clearLocationError() {
    _locationError = null;
    notifyListeners();
  }

  // --- Muat dan simpan ---

  Future<Result<void>> _load() async {
    final locations = await _repository.locations();
    if (locations case Error(:final error)) return Result.error(error);
    _locations = (locations as Ok<List<StockLocation>>).value;
    if (_locationId == null || location == null) {
      _locationId = _locations.firstOrNull?.id;
    }
    final rows = await _repository.stock(locationId: _locationId);
    if (rows case Error(:final error)) return Result.error(error);
    final below = await _repository.belowMinimum(locationId: _locationId);
    if (below case Error(:final error)) return Result.error(error);
    final recent = await _repository.recentAdjustments();
    final number = await _repository.nextAdjustmentNumber();
    _rows = (rows as Ok<List<StockRow>>).value;
    _below = (below as Ok<List<StockRow>>).value;
    _recent = switch (recent) {
      Ok(:final value) => value,
      Error() => const [],
    };
    _nextNumber = switch (number) {
      Ok(:final value) => value,
      Error() => null,
    };
    // Baris draf memakai stok sistem terbaru.
    _lines = [
      for (final l in _lines)
        if (_rows.where((r) => r.variantId == l.row.variantId).firstOrNull
            case final row?)
          l.copyWith(row: row),
    ];
    if (_cardVariantId == null ||
        !_rows.any((r) => r.variantId == _cardVariantId)) {
      _cardVariantId = (_below.firstOrNull ?? _rows.firstOrNull)?.variantId;
    }
    await _loadCard();
    _loaded = true;
    return const Result.ok(null);
  }

  Future<Result<StockAdjustmentResult>> _save() async {
    final locationId = _locationId;
    if (!_ready || locationId == null) {
      return const Result.error(NotPermitted(Permission.stockAdjust));
    }
    _saveError = null;
    final result = await _repository.saveAdjustment(
      locationId: locationId,
      reason: _reason,
      note: _note.trim().isEmpty ? null : _note.trim(),
      lines: [
        for (final l in _lines)
          if (l.physical != null)
            AdjustmentLine(
              variantId: l.row.variantId,
              physical: l.physical!,
              note: l.note.trim().isEmpty ? null : l.note.trim(),
            ),
      ],
    );
    switch (result) {
      case Ok(:final value):
        _clearDraft();
        await _load();
        _lastSaved = value.adjustment.number;
      case Error(:final error):
        if (error case StockAdjustmentInvalid(:final error)) {
          _saveError = error;
        }
    }
    return result;
  }
}
