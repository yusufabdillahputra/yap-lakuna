import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/purchases_repository.dart' show PurchaseRestock;
import '../../data/repositories/stock_repository.dart';
import '../../data/services/spreadsheet_exporter.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Tanda barang di bawah minimum yang sudah ada di draf pembelian
/// (F1-08h/F1-08l): nomor draf pertama, banyaknya draf, dan jumlah dipesan
/// dalam satuan dasar.
typedef DraftMark = ({String number, int drafts, Qty ordered});

/// Tab layar Stok (1.18).
enum StockTab { list, adjustment, card, minimum, locations }

/// Hasil *Scan / tambah produk*.
enum AddByCodeResult { added, already, notFound }

/// Label pilihan produk yang unik: nama tampilan, ditambah SKU/barcode bila
/// ada nama kembar (nama produk tidak wajib unik).
Map<UuidValue, String> uniqueStockLabels(List<StockRow> rows) {
  final counts = <String, int>{};
  for (final r in rows) {
    counts[r.displayName] = (counts[r.displayName] ?? 0) + 1;
  }
  final used = <String>{};
  final labels = <UuidValue, String>{};
  for (final r in rows) {
    var label = r.displayName;
    if (counts[label]! > 1) {
      label = '$label · ${r.sku ?? r.barcode ?? r.baseUnit}';
    }
    final base = label;
    for (var n = 2; !used.add(label); n++) {
      label = '$base ($n)';
    }
    labels[r.variantId] = label;
  }
  return labels;
}

/// Satu baris draf penyesuaian.
class AdjustmentDraftLine {
  const AdjustmentDraftLine({
    required this.row,
    this.physical,
    this.note = '',
    this.countedSystem,
  });

  final StockRow row;

  /// `null` = belum diisi (tidak ikut disimpan).
  final Qty? physical;
  final String note;

  /// Stok sistem saat jumlah fisik diisi (F1-08q).
  final Qty? countedSystem;

  /// Stok sistem sudah berubah sejak baris ini dihitung (F1-08q).
  bool get systemChanged =>
      physical != null && countedSystem != null && countedSystem != row.stock;

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
    Qty? Function()? countedSystem,
  }) => AdjustmentDraftLine(
    row: row ?? this.row,
    physical: physical == null ? this.physical : physical(),
    note: note ?? this.note,
    countedSystem: countedSystem == null ? this.countedSystem : countedSystem(),
  );
}

/// Layar Stok (F1-08, 1.18): daftar stok per lokasi, penyesuaian, kartu
/// stok, stok minimum, dan lokasi.
class StockViewModel extends ChangeNotifier {
  StockViewModel({
    required this._repository,
    required this.canAdjust,
    this._exporter = const PlatformSpreadsheetExporter(),
    this._restockDrafts,
  }) {
    load = Command0(_load)..addListener(notifyListeners);
    save = Command0(_save)..addListener(notifyListeners);
    printList = Command1(_print)..addListener(notifyListeners);
  }

  final StockRepository _repository;
  final SpreadsheetExporter _exporter;

  /// Draf pembelian ke lokasi ini yang memuat barang di bawah minimum
  /// (F1-08g/h); `null` bila staf tidak boleh membuat pembelian.
  final Future<Result<List<RestockDraft>>> Function(
    UuidValue locationId,
    Iterable<UuidValue> variantIds,
  )?
  _restockDrafts;

  var _inDraft = const <UuidValue, DraftMark>{};

  /// Jumlah saran beli ulang barang [row] dalam satuan dasar: dipakai
  /// *Buat pembelian* (F1-08c) dan keterangan *dari saran* (F1-08l).
  static Qty suggestedOf(StockRow row) =>
      restockQuantity(row.stock, row.minStock);

  /// Kekurangan jumlah di draf [mark] dari saran barang [row], satuan dasar;
  /// [Qty.zero] bila draf sudah cukup (F1-08p).
  static Qty shortfallOf(StockRow row, DraftMark mark) {
    final short = suggestedOf(row).milli - mark.ordered.milli;
    return short > 0 ? Qty(short) : Qty.zero;
  }

  /// Draf pertama, banyaknya draf, dan jumlah yang sudah dipesan (satuan
  /// dasar, semua draf) untuk barang [variantId] (F1-08l).
  DraftMark? draftMarkOf(UuidValue variantId) => _inDraft[variantId];

  /// Staf boleh menyimpan penyesuaian dan mengubah lokasi.
  final bool canAdjust;

  late final Command0<void> load;
  late final Command0<StockAdjustmentResult> save;

  /// *Cetak stok* (F1-08b): membuat PDF lewat pembuat dari tampilan (butuh
  /// terjemahan & font) lalu menyimpannya dengan nama berkas. Hasil =
  /// lokasi berkas di desktop, `null` bila share sheet.
  late final Command1<String?, (Future<Uint8List> Function(), String)>
  printList;

  String? _printPath;

  /// Lokasi PDF cetak stok terakhir (desktop).
  String? get printPath => _printPath;

  /// Isian *Buat pembelian* dari daftar di bawah minimum (F1-08c): lokasi
  /// yang sedang dilihat dan jumlah saran [restockQuantity]. `null` bila
  /// daftar kosong atau data lokasi belum selaras (sedang memuat / gagal).
  PurchaseRestock? get restock {
    final locationId = _rowsLocationId;
    if (!_loaded ||
        _below.isEmpty ||
        locationId == null ||
        locationId != _locationId ||
        load.running) {
      return null;
    }
    return PurchaseRestock(
      locationId: locationId,
      locationName: printLocationName,
      lines: [
        for (final r in _below)
          (
            variantId: r.variantId,
            quantity: suggestedOf(r),
          ),
      ],
    );
  }

  /// Lokasi milik [rows] (bisa tertinggal dari [location] selagi memuat
  /// atau bila muat lokasi baru gagal).
  UuidValue? _rowsLocationId;

  /// Baris yang dicetak: semua baris lokasi, tanpa saringan pencarian.
  List<StockRow> get printRows => _rows;

  /// Nama lokasi milik [printRows].
  String get printLocationName =>
      _locations.where((l) => l.id == _rowsLocationId).firstOrNull?.name ?? '';

  /// Ada baris untuk dicetak, baris itu milik lokasi terpilih, dan tidak
  /// sedang memuat atau menyimpan.
  bool get canPrint =>
      _loaded &&
      _rows.isNotEmpty &&
      _rowsLocationId == _locationId &&
      !load.running &&
      !printList.running;

  Future<Result<String?>> _print(
    (Future<Uint8List> Function(), String) file,
  ) async {
    _printPath = null;
    try {
      final bytes = await file.$1();
      final path = await _exporter.save(bytes, fileName: file.$2);
      _printPath = path;
      return Result.ok(path);
    } on Exception catch (e) {
      return Result.error(e);
    } on Object catch (e, stack) {
      // Error dari pembuat PDF atau share sheet: laporkan agar bisa
      // ditelusuri, tampilkan pesan gagal biasa.
      FlutterError.reportError(
        FlutterErrorDetails(exception: e, stack: stack, library: 'stock'),
      );
      return Result.error(Exception('$e'));
    }
  }

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
    printList.clearResult();
    _printPath = null;
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
      sameBarcode(r.barcode, q);

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

  /// Draf berisi baris atau catatan (F1-08k). Alasan saja tidak dihitung.
  bool get hasDraftContent => _lines.isNotEmpty || _note.trim().isNotEmpty;

  /// Draf berisi yang belum tersimpan di perangkat (F1-08o), sehingga akan
  /// hilang bila layar ditinggalkan atau lokasi diganti (F1-08k).
  bool get hasUnsavedChanges => canAdjust && hasDraftContent && !draftStored;

  /// Perubahan draf terakhir sudah tersimpan di perangkat (F1-08o).
  bool get draftStored => _draftStored == _draftChange;

  /// Draf terakhir tidak tersimpan di perangkat (F1-08o): tulisnya gagal,
  /// atau draf tersimpan lokasi ini gagal dibaca sehingga perubahan tidak
  /// ditulis agar draf itu tidak tertimpa.
  bool get draftWriteFailed =>
      canAdjust &&
      (_draftFailed == _draftChange ||
          (_draftLocation == null && !draftStored));

  /// Lokasi sedang dimuat: draf tersimpannya belum dibaca dan baris masih
  /// milik lokasi lama, jadi isian draf nonaktif dan perubahan diabaikan
  /// (F1-08o).
  bool get draftLoading => canAdjust && _draftLocation == null && load.running;

  /// Naik setiap draf berubah (F1-08o).
  var _draftChange = 0;

  /// [_draftChange] terakhir yang berhasil ditulis / gagal ditulis.
  var _draftStored = 0;
  var _draftFailed = -1;

  /// Lokasi yang drafnya sudah dipulihkan, selalu lokasi yang tampil.
  /// `null` selama lokasi baru dimuat: draf tidak ditulis sampai draf
  /// tersimpan lokasi itu dibaca, agar tidak tertimpa.
  UuidValue? _draftLocation;

  /// Tulis draf berantai agar urutannya terjaga.
  Future<void> _draftWrites = Future.value();

  /// Menunggu tulis draf yang sedang berjalan, paling lama [timeout], agar
  /// keluar layar sesaat setelah mengetik tidak bertanya (F1-08o).
  Future<void> flushDraft({
    Duration timeout = const Duration(seconds: 2),
  }) => _draftWrites.timeout(timeout, onTimeout: () {});

  /// Menulis draf sekarang ke perangkat (F1-08o).
  void _persistDraft() {
    final location = _draftLocation;
    if (!canAdjust || location == null) return;
    final change = _draftChange;
    final draft = hasDraftContent
        ? StockAdjustmentDraft(
            reason: _reason,
            note: _note,
            lines: [
              for (final l in _lines)
                StockAdjustmentDraftLine(
                  variantId: l.row.variantId,
                  physical: l.physical,
                  note: l.note,
                  countedSystem: l.countedSystem,
                ),
            ],
          )
        : null;
    _draftWrites = _draftWrites.then((_) async {
      final result = await _repository.saveAdjustmentDraft(location, draft);
      switch (result) {
        case Ok():
          if (change > _draftStored) _draftStored = change;
        case Error():
          _draftFailed = change;
      }
      notifyListeners();
    });
  }

  /// Memasang draf tersimpan [location] yang sudah dibaca (F1-08o). Galat
  /// baca dianggap tanpa draf.
  void _restoreDraft(
    UuidValue location,
    Result<StockAdjustmentDraft?> result,
  ) {
    // Galat baca: jangan menulis apa pun ke lokasi ini agar draf yang
    // tersimpan tidak tertimpa; dibaca lagi saat muat berikutnya.
    if (result is Error) return;
    _draftLocation = location;
    final draft = (result as Ok<StockAdjustmentDraft?>).value;
    if (draft != null) {
      _reason = draft.reason;
      _note = draft.note;
      _lines = [
        for (final l in draft.lines)
          if (_rows.where((r) => r.variantId == l.variantId).firstOrNull
              case final row?)
            AdjustmentDraftLine(
              row: row,
              physical: l.physical,
              note: l.note,
              countedSystem: l.countedSystem,
            ),
      ];
      _draftRevision++;
    }
    // Yang tampil sama dengan yang tersimpan.
    _draftChange++;
    _draftStored = _draftChange;
  }

  /// Penyesuaian sedang disimpan: keluar ditahan (F1-08k).
  bool get busy => save.running;

  bool get _ready =>
      canAdjust && location != null && _lines.any((l) => l.physical != null);

  /// Varian yang belum ada di draf, untuk pilihan *tambah produk*.
  List<StockRow> get addableRows => [
    for (final r in _rows)
      if (!_lines.any((l) => l.row.variantId == r.variantId)) r,
  ];

  void setReason(StockAdjustmentReason r) {
    if (draftLoading) return;
    _reason = r;
    _touched();
  }

  void setNote(String v) {
    if (draftLoading) return;
    _note = v;
    _touched();
  }

  void addLine(UuidValue variantId) {
    if (draftLoading || _lines.any((l) => l.row.variantId == variantId)) return;
    final row = _rows.where((r) => r.variantId == variantId).firstOrNull;
    if (row == null) return;
    _lines = [..._lines, AdjustmentDraftLine(row: row)];
    _touched();
  }

  /// *Scan / tambah produk*: barcode atau SKU persis, atau nama yang hanya
  /// cocok dengan satu produk.
  AddByCodeResult addByCode(String code) {
    final q = code.trim().toLowerCase();
    if (q.isEmpty) return AddByCodeResult.notFound;
    final exact = _rows.where(
      (r) => sameBarcode(r.barcode, q) || r.sku?.toLowerCase() == q,
    );
    final byName = _rows.where(
      (r) => r.displayName.toLowerCase().contains(q),
    );
    final row = exact.isNotEmpty
        ? exact.first
        : (byName.length == 1 ? byName.first : null);
    if (row == null) return AddByCodeResult.notFound;
    if (_lines.any((l) => l.row.variantId == row.variantId)) {
      return AddByCodeResult.already;
    }
    addLine(row.variantId);
    return AddByCodeResult.added;
  }

  void removeLine(UuidValue variantId) {
    if (draftLoading) return;
    _lines = [
      for (final l in _lines)
        if (l.row.variantId != variantId) l,
    ];
    _touched();
  }

  /// Angka baru mencatat stok sistem saat ini sebagai stok saat dihitung
  /// (F1-08q). Angka sama tidak: Forui memanggil `onChange` saat fokus.
  void setPhysical(UuidValue variantId, Qty? qty) => _updateLine(
    variantId,
    (l) => qty == l.physical
        ? l
        : l.copyWith(
            physical: () => qty,
            countedSystem: () => qty == null ? null : l.row.stock,
          ),
  );

  /// *Sudah dicek*: stok sistem terbaru menjadi stok saat dihitung
  /// (F1-08q).
  void acknowledgeSystemChange(UuidValue variantId) => _updateLine(
    variantId,
    (l) => l.copyWith(countedSystem: () => l.row.stock),
  );

  /// Baris yang stok sistemnya berubah sejak dihitung (F1-08q).
  int get systemChangedCount => _lines.where((l) => l.systemChanged).length;

  void setLineNote(UuidValue variantId, String note) =>
      _updateLine(variantId, (l) => l.copyWith(note: note));

  void _updateLine(
    UuidValue variantId,
    AdjustmentDraftLine Function(AdjustmentDraftLine) change,
  ) {
    if (draftLoading) return;
    final i = _lines.indexWhere((l) => l.row.variantId == variantId);
    if (i < 0) return;
    final next = change(_lines[i]);
    // Tanpa perubahan (mis. `onChange` Forui saat fokus): draf tidak
    // ditulis ulang.
    if (identical(next, _lines[i])) return;
    _lines = [..._lines]..[i] = next;
    _touched();
  }

  void _touched() {
    _saveError = null;
    _lastSaved = null;
    _draftChange++;
    _persistDraft();
    notifyListeners();
  }

  /// Mengosongkan draf di layar saja (lokasi diganti: draf lokasi lama
  /// tetap tersimpan, F1-08o).
  void _resetDraft() {
    _lines = [];
    _note = '';
    _reason = StockAdjustmentReason.routineCheck;
    _saveError = null;
    _draftRevision++;
    _draftChange++;
    _draftStored = _draftChange;
  }

  /// Mengosongkan draf dan menghapus draf tersimpan lokasi ini.
  void _clearDraft() {
    _resetDraft();
    _persistDraft();
  }

  /// *Batal*, atau *Buang* di dialog keluar / ganti lokasi: kosongkan draf
  /// dan hapus draf tersimpan lokasi ini (F1-08o).
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

  /// Membuka tab *Kartu stok* untuk [variantId] di [locationId] sebelum
  /// layar dimuat (tautan dari detail pembelian, F1-12c). Produk atau
  /// lokasi yang tidak ada jatuh ke pilihan bawaan saat dimuat.
  void focusCard({required UuidValue variantId, UuidValue? locationId}) {
    _tab = StockTab.card;
    _cardVariantId = variantId;
    if (locationId != null) _locationId = locationId;
    _focus = (variantId, locationId);
  }

  /// Tautan [focusCard] yang belum diperiksa pada muat pertama.
  (UuidValue, UuidValue?)? _focus;
  bool _cardFocusMissing = false;

  /// Produk atau lokasi dari tautan [focusCard] tidak ada lagi, sehingga
  /// kartu stok bawaan yang tampil. Hilang setelah staf memilih sendiri.
  bool get cardFocusMissing => _cardFocusMissing;

  Future<void> selectCardVariant(UuidValue variantId) async {
    _cardFocusMissing = false;
    _cardVariantId = variantId;
    // Kartu produk sebelumnya tidak boleh tampil di bawah nama yang baru.
    _card = null;
    notifyListeners();
    await _loadCard();
    notifyListeners();
  }

  Future<void> _loadCard() async {
    final id = _cardVariantId;
    final locationId = _locationId;
    if (id == null) {
      _card = null;
      return;
    }
    final result = await _repository.card(
      variantId: id,
      locationId: locationId,
    );
    // Jawaban lama (produk/lokasi sudah diganti) dibuang.
    if (id != _cardVariantId || locationId != _locationId) return;
    _card = switch (result) {
      Ok(:final value) => value,
      Error() => null,
    };
  }

  // --- Lokasi ---

  StockLocationNameError? _locationError;
  StockLocationNameError? get locationError => _locationError;

  /// Ditolak selama penyesuaian disimpan, agar draf lokasi yang disimpan
  /// tetap terhapus setelahnya (F1-08o).
  Future<void> selectLocation(UuidValue id) async {
    if (id == _locationId || save.running) return;
    _locationId = id;
    _cardFocusMissing = false;
    _resetDraft();
    _draftLocation = null;
    printList.clearResult();
    _printPath = null;
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
        // Nama lokasi juga tampil di daftar penyesuaian terakhir.
        final recent = await _repository.recentAdjustments();
        if (recent case Ok(:final value)) _recent = value;
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

  /// Memuat lokasi yang dipilih. Bila lokasi diganti selagi memuat, hasil
  /// lama dibuang dan lokasi terbaru dimuat (perintah [load] mengabaikan
  /// panggilan kedua selagi berjalan).
  Future<Result<void>> _load() async {
    while (true) {
      final result = await _loadOnce(_locationId);
      switch (result) {
        case Error(:final error):
          return Result.error(error);
        case Ok(value: true):
          return const Result.ok(null);
        case Ok():
          continue;
      }
    }
  }

  /// Barang di bawah minimum yang sudah ada di draf pembelian ke [location]
  /// (F1-08h): draf pertama (paling cocok, lalu terbaru) menang. Galat
  /// diabaikan agar daftar stok tetap tampil.
  Future<Map<UuidValue, DraftMark>> _draftsOf(
    UuidValue? location,
    List<StockRow> below,
  ) async {
    final find = _restockDrafts;
    if (find == null || location == null || below.isEmpty) return const {};
    final result = await find(location, {for (final r in below) r.variantId});
    if (result case Ok(:final value)) {
      final map = <UuidValue, DraftMark>{};
      for (final d in value) {
        for (final id in d.variantIds) {
          final ordered = d.quantities[id]?.milli ?? 0;
          map[id] = switch (map[id]) {
            null => (number: d.number, drafts: 1, ordered: Qty(ordered)),
            final m => (
              number: m.number,
              drafts: m.drafts + 1,
              ordered: Qty(m.ordered.milli + ordered),
            ),
          };
        }
      }
      return map;
    }
    return const {};
  }

  /// `true` bila hasilnya dipakai; `false` bila lokasi sudah diganti.
  Future<Result<bool>> _loadOnce(UuidValue? requested) async {
    final locations = await _repository.locations();
    if (locations case Error(:final error)) return Result.error(error);
    final list = (locations as Ok<List<StockLocation>>).value;
    final target = list.any((l) => l.id == requested)
        ? requested
        : list.firstOrNull?.id;
    final rows = await _repository.stock(locationId: target);
    if (rows case Error(:final error)) return Result.error(error);
    final below = await _repository.belowMinimum(locationId: target);
    if (below case Error(:final error)) return Result.error(error);
    final belowRows = (below as Ok<List<StockRow>>).value;
    // Dibaca bersamaan dengan data penyesuaian agar daftar tidak menunggu
    // dua kueri pembelian berturut-turut.
    final drafts = _draftsOf(target, belowRows);
    final recent = await _repository.recentAdjustments();
    final number = await _repository.nextAdjustmentNumber();
    final inDraft = await drafts;
    // Draf penyesuaian tersimpan lokasi ini, sekali per pemilihan lokasi
    // (F1-08o).
    // Perubahan yang belum tersimpan (draf gagal dibaca sebelumnya) tidak
    // ditimpa draf lama.
    final stored =
        canAdjust && target != null && _draftLocation != target && draftStored
        ? await _repository.adjustmentDraft(target)
        : null;
    // Staf mengganti lokasi selagi memuat: jangan tampilkan data lama.
    if (_locationId != requested) return const Result.ok(false);
    _inDraft = inDraft;
    _locations = list;
    _locationId = target;
    _rows = (rows as Ok<List<StockRow>>).value;
    _rowsLocationId = target;
    _below = belowRows;
    _recent = switch (recent) {
      Ok(:final value) => value,
      Error() => const [],
    };
    _nextNumber = switch (number) {
      Ok(:final value) => value,
      Error() => null,
    };
    if (stored != null && target != null) _restoreDraft(target, stored);
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
    if (_focus case (final variant, final location)?) {
      _focus = null;
      _cardFocusMissing =
          variant != _cardVariantId || (location != null && location != target);
    }
    await _loadCard();
    _loaded = true;
    return const Result.ok(true);
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
