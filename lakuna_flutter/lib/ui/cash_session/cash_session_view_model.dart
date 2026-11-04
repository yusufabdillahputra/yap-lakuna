import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/cash_drawer_repository.dart';
import '../../data/repositories/expenses_repository.dart';
import '../../data/services/image_file_picker.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Membaca nominal rupiah dari teks (titik/spasi diabaikan). Teks kosong
/// atau tanpa angka → `null`.
Money? parseRupiah(String text) {
  final digits = text.replaceAll(RegExp('[^0-9]'), '');
  if (digits.isEmpty) return null;
  return Money(int.parse(digits));
}

/// Keadaan layar sesi kasir.
enum CashStage {
  loading,
  loadFailed,

  /// Belum ada sesi terbuka: kartu *Buka sesi kasir*.
  openForm,

  /// Sesi terbuka: kas laci (1.3b).
  drawer,

  /// Hitung uang fisik dan tutup (1.3).
  closeForm,

  /// Kartu hasil setelah tutup.
  closed,
}

/// View model layar sesi kasir (F1-03).
class CashSessionViewModel extends ChangeNotifier {
  CashSessionViewModel({
    required this._repository,
    required this._permissions,
    this._expenses,
    this._picker = const FileSelectorImagePicker(),
  }) {
    pickReceipt = Command1(_pickReceipt)..addListener(notifyListeners);
    load = Command0(_load)..addListener(notifyListeners);
    open = Command0(_open)..addListener(notifyListeners);
    saveMovement = Command0(_saveMovement)..addListener(notifyListeners);
    close = Command0(_close)..addListener(notifyListeners);
  }

  final CashDrawerRepository _repository;
  final Set<Permission> _permissions;

  /// Pengeluaran (F1-15) untuk opsi *Catat juga sebagai pengeluaran*.
  final ExpensesRepository? _expenses;
  final ImageFilePicker _picker;

  /// Memilih foto nota pengeluaran; argumen `true` = kamera.
  late final Command1<void, bool> pickReceipt;

  late final Command0<ActiveCashSession?> load;
  late final Command0<ActiveCashSession> open;
  late final Command0<ActiveCashSession> saveMovement;
  late final Command0<CashSession> close;

  ActiveCashSession? _active;
  CashSession? _closed;
  bool _loaded = false;
  bool _loadFailed = false;
  bool _closing = false;
  Exception? _error;

  ActiveCashSession? get active => _active;

  /// Sesi yang baru ditutup, untuk kartu hasil.
  CashSession? get closed => _closed;
  bool get loaded => _loaded;

  /// Galat yang bukan milik satu field (izin, sesi berubah di layar lain,
  /// galat database).
  Exception? get error => _error;

  bool get canOpen => _permissions.contains(Permission.cashSessionOpen);
  bool get canClose => _permissions.contains(Permission.cashSessionClose);
  bool get canRecordMovement =>
      _permissions.contains(Permission.cashMovementsCreate);

  /// Uang keluar bisa dicatat juga sebagai pengeluaran (F1-15).
  bool get canRecordExpense =>
      _expenses != null &&
      _permissions.contains(Permission.expensesManage) &&
      canRecordMovement;

  CashStage get stage {
    if (_closed != null) return CashStage.closed;
    if (!_loaded) return _loadFailed ? CashStage.loadFailed : CashStage.loading;
    if (_active == null) return CashStage.openForm;
    return _closing ? CashStage.closeForm : CashStage.drawer;
  }

  // --- Buka sesi -----------------------------------------------------------

  String _openingCash = '';
  String _openingNote = '';
  CashError? _openingCashError;

  CashError? get openingCashError => _openingCashError;

  void setOpeningCash(String text) {
    _openingCash = text;
    if (_openingCashError != null) {
      _openingCashError = null;
      notifyListeners();
    }
  }

  CashError? _openingNoteError;

  CashError? get openingNoteError => _openingNoteError;

  void setOpeningNote(String text) {
    _openingNote = text;
    if (_openingNoteError != null) {
      _openingNoteError = null;
      notifyListeners();
    }
  }

  // --- Uang masuk/keluar ---------------------------------------------------

  CashDirection _direction = CashDirection.outflow;
  String _movementAmount = '';
  String _movementNote = '';
  CashError? _movementAmountError;
  CashError? _movementNoteError;
  int _movementFormVersion = 0;

  CashDirection get direction => _direction;
  CashError? get movementAmountError => _movementAmountError;
  CashError? get movementNoteError => _movementNoteError;

  /// Keterangan uang keluar menjadi keterangan pengeluaran bila sakelar
  /// pengeluaran aktif, jadi batasnya ikut batas pengeluaran.
  int get movementNoteMaxLength =>
      asExpense ? ExpenseLimits.description : cashNoteMaxLength;

  /// Naik setiap uang laci tersimpan; view memakainya sebagai kunci agar
  /// field kembali kosong.
  int get movementFormVersion => _movementFormVersion;

  void setDirection(CashDirection direction) {
    if (_direction == direction) return;
    _direction = direction;
    notifyListeners();
  }

  void setMovementAmount(String text) {
    _movementAmount = text;
    if (_movementAmountError != null) {
      _movementAmountError = null;
      notifyListeners();
    }
  }

  void setMovementNote(String text) {
    _movementNote = text;
    if (_movementNoteError != null) {
      _movementNoteError = null;
      notifyListeners();
    }
  }

  // --- Catat juga sebagai pengeluaran (F1-15) ------------------------------

  ExpensesSetup? _expenseSetup;
  var _asExpense = false;
  UuidValue? _expenseCategoryId;
  var _expenseCategoryMissing = false;
  ExpenseReceipt? _receipt;
  var _receiptRejected = false;

  /// Jenis pengeluaran aktif (kosong bila tidak bisa mencatat pengeluaran).
  List<ExpenseCategory> get expenseCategories =>
      _expenseSetup?.categories ?? const [];

  /// Sakelar *Catat juga sebagai pengeluaran* aktif (hanya uang keluar).
  bool get asExpense =>
      _asExpense && canRecordExpense && _direction == CashDirection.outflow;
  UuidValue? get expenseCategoryId => _expenseCategoryId;

  /// Jenis belum dipilih saat simpan.
  bool get expenseCategoryMissing => _expenseCategoryMissing;
  ExpenseReceipt? get receipt => _receipt;

  /// Foto terakhir ditolak (bukan gambar sah atau > 5 MB).
  bool get receiptRejected => _receiptRejected;
  bool get canTakePhoto => _picker.canTakePhoto;

  void setAsExpense(bool value) {
    if (_asExpense == value) return;
    _asExpense = value;
    if (value) _loadExpenseSetup();
    notifyListeners();
  }

  void setExpenseCategory(UuidValue? id) {
    _expenseCategoryId = id;
    _expenseCategoryMissing = false;
    notifyListeners();
  }

  void removeReceipt() {
    _receipt = null;
    _receiptRejected = false;
    notifyListeners();
  }

  Future<void> _loadExpenseSetup() async {
    final expenses = _expenses;
    if (expenses == null || !canRecordExpense) return;
    switch (await expenses.load()) {
      case Ok(:final value):
        _expenseSetup = value;
      case Error(:final error):
        // Tampil di kotak galat umum; jenis tetap kosong.
        _error = error;
    }
    notifyListeners();
  }

  Future<Result<void>> _pickReceipt(bool camera) async {
    try {
      final picked = camera
          ? await _picker.takePhoto(maxBytes: ExpenseLimits.receiptMaxBytes)
          : await _picker.pickImage(maxBytes: ExpenseLimits.receiptMaxBytes);
      if (picked == null) return const Result.ok(null);
      final bytes = picked.bytes;
      if (bytes == null || readImageHeader(bytes) == null) {
        _receiptRejected = true;
      } else {
        _receipt = ExpenseReceipt(bytes: bytes, fileName: picked.name);
        _receiptRejected = false;
      }
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  // --- Tutup sesi ----------------------------------------------------------

  final _sheets = <int, int>{};
  Money _coins = Money.zero;
  String _closingNote = '';
  CashError? _closingNoteError;

  CashError? get closingNoteError => _closingNoteError;

  CashCount get count => CashCount(sheets: Map.of(_sheets), coins: _coins);
  Money get countedTotal => count.total;
  Money subtotal(int denomination) =>
      Money(denomination * (_sheets[denomination] ?? 0));

  int sheetsOf(int denomination) => _sheets[denomination] ?? 0;
  Money get coins => _coins;

  /// Selisih = dihitung − seharusnya.
  Money get difference =>
      _active?.drawer.differenceFor(countedTotal) ?? Money.zero;

  /// Ke formulir tutup sesi. Hitungan dan catatan selalu mulai kosong
  /// (field-nya juga kosong saat dipasang ulang), lalu rekap dimuat ulang
  /// agar seharusnya di laci memuat gerakan kas terbaru.
  void startClosing() {
    _closing = true;
    _error = null;
    _clearCount();
    _clearMovementForm();
    notifyListeners();
    load.execute();
  }

  void cancelClosing() {
    _closing = false;
    _error = null;
    _clearCount();
    _clearMovementForm();
    notifyListeners();
  }

  void setSheets(int denomination, String text) {
    final sheets = parseRupiah(text)?.value ?? 0;
    if (sheets == 0) {
      _sheets.remove(denomination);
    } else {
      _sheets[denomination] = sheets;
    }
    notifyListeners();
  }

  void setCoins(String text) {
    _coins = parseRupiah(text) ?? Money.zero;
    notifyListeners();
  }

  void setClosingNote(String text) {
    _closingNote = text;
    if (_closingNoteError != null) {
      _closingNoteError = null;
      notifyListeners();
    }
  }

  /// Dari kartu hasil kembali ke formulir buka sesi.
  void startNew() {
    _closed = null;
    _openingCash = '';
    _openingNote = '';
    notifyListeners();
  }

  // --- Perintah ------------------------------------------------------------

  Future<Result<ActiveCashSession?>> _load() async {
    final result = await _repository.loadCurrent();
    switch (result) {
      case Ok(:final value):
        _active = value;
        _loaded = true;
        _loadFailed = false;
        if (value == null) _closing = false;
      case Error():
        _loadFailed = !_loaded;
    }
    return result;
  }

  Future<Result<ActiveCashSession>> _open() async {
    _error = null;
    final cash = parseRupiah(_openingCash);
    _openingCashError = cash == null
        ? CashError.required
        : validateOpeningCash(cash);
    _openingNoteError = validateOpeningNote(_openingNote);
    if (_openingCashError case final e?) {
      return Result.error(CashInputInvalid(CashField.openingCash, e));
    }
    if (_openingNoteError case final e?) {
      return Result.error(CashInputInvalid(CashField.note, e));
    }
    final result = await _repository.open(
      openingCash: cash!,
      note: _openingNote,
    );
    await _apply(result, onOk: _resetForms);
    return result;
  }

  Future<Result<ActiveCashSession>> _saveMovement() async {
    final session = _active;
    if (session == null) return Result.error(CashSessionNotOpen());
    _error = null;
    final amount = parseRupiah(_movementAmount);
    _movementAmountError = amount == null
        ? CashError.required
        : validateMovementAmount(amount);
    _movementNoteError = validateMovementNote(_movementNote);
    // Semua galat isian pengeluaran tampil sekaligus.
    _expenseCategoryMissing = asExpense && _expenseCategoryId == null;
    if (_movementAmountError case final e?) {
      return Result.error(CashInputInvalid(CashField.amount, e));
    }
    if (asExpense && _movementNote.trim().isEmpty) {
      _movementNoteError = CashError.required;
    } else if (asExpense &&
        _movementNote.trim().length > ExpenseLimits.description) {
      _movementNoteError = CashError.tooLong;
    }
    if (_movementNoteError case final e?) {
      return Result.error(CashInputInvalid(CashField.note, e));
    }
    if (asExpense) return _saveExpense(session, amount!);
    final result = await _repository.recordMovement(
      session.session.id,
      direction: _direction,
      amount: amount!,
      note: _movementNote,
    );
    await _apply(
      result,
      onOk: _clearMovementForm,
    );
    return result;
  }

  /// Uang keluar + pengeluaran laci dalam satu dokumen `EX-`.
  Future<Result<ActiveCashSession>> _saveExpense(
    ActiveCashSession session,
    Money amount,
  ) async {
    final categoryId = _expenseCategoryId;
    if (categoryId == null) {
      _expenseCategoryMissing = true;
      notifyListeners();
      return const Result.error(ExpenseInvalid({ExpenseIssue.category}));
    }
    final today = _expenseSetup?.today ?? _date(DateTime.now());
    final recorded = await _expenses!.record(
      ExpenseRequest(
        description: _movementNote,
        categoryId: categoryId,
        amount: amount,
        funding: FundingSource.drawer,
        spentOn: today,
        receipt: _receipt,
      ),
    );
    if (recorded case Error(:final error)) {
      await _handleError(error);
      return Result.error(error);
    }
    final reloaded = await _repository.loadCurrent();
    switch (reloaded) {
      case Ok(:final value?):
        _active = value;
        _clearMovementForm();
        return Result.ok(value);
      case Ok():
        final error = CashSessionNotOpen();
        await _handleError(error);
        return Result.error(error);
      case Error(:final error):
        _error = error;
        return Result.error(error);
    }
  }

  static DateTime _date(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  Future<Result<CashSession>> _close() async {
    final session = _active;
    if (session == null) return Result.error(CashSessionNotOpen());
    _error = null;
    _closingNoteError = validateClosingNote(difference, _closingNote);
    if (_closingNoteError case final e?) {
      return Result.error(CashInputInvalid(CashField.note, e));
    }
    final result = await _repository.close(
      session.session.id,
      count: count,
      note: _closingNote,
    );
    switch (result) {
      case Ok(:final value):
        _closed = value;
        _active = null;
        _closing = false;
        _resetForms();
      case Error(:final error):
        await _handleError(error);
    }
    return result;
  }

  Future<void> _apply(
    Result<ActiveCashSession> result, {
    required VoidCallback onOk,
  }) async {
    switch (result) {
      case Ok(:final value):
        _active = value;
        onOk();
      case Error(:final error):
        await _handleError(error);
    }
  }

  /// Galat field ditempel di field-nya; sesi yang berubah di layar lain
  /// memuat ulang layar; sisanya ditampilkan sebagai galat umum.
  Future<void> _handleError(Exception error) async {
    switch (error) {
      case CashInputInvalid(field: CashField.openingCash, error: final e):
        _openingCashError = e;
      case CashInputInvalid(field: CashField.amount, error: final e):
        _movementAmountError = e;
      case CashInputInvalid(field: CashField.note, error: final e):
        if (_closing) {
          _closingNoteError = e;
        } else if (_active != null) {
          _movementNoteError = e;
        } else {
          _openingNoteError = e;
        }
      case CashSessionAlreadyOpen() || CashSessionNotOpen():
        _error = error;
        await _load();
      default:
        _error = error;
    }
  }

  void _resetForms() {
    _clearCount();
    _clearMovementForm();
    _direction = CashDirection.outflow;
  }

  void _clearCount() {
    _sheets.clear();
    _coins = Money.zero;
    _closingNote = '';
    _closingNoteError = null;
  }

  /// Mengosongkan formulir uang laci; view memasang ulang field-nya lewat
  /// [movementFormVersion] agar yang tampak sama dengan yang tersimpan.
  void _clearMovementForm() {
    _movementAmount = '';
    _movementNote = '';
    _movementAmountError = null;
    _movementNoteError = null;
    _asExpense = false;
    _expenseCategoryId = null;
    _expenseCategoryMissing = false;
    _receipt = null;
    _receiptRejected = false;
    _movementFormVersion++;
  }

  @override
  void dispose() {
    for (final c in [load, open, saveMovement, close]) {
      c.dispose();
    }
    pickReceipt.dispose();
    super.dispose();
  }
}
