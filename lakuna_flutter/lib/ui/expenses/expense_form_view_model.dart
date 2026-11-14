import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/expenses_repository.dart';
import '../../data/services/image_file_picker.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Sumber dana pengeluaran, urut tampilan desain (kas laci dulu).
const expenseFundingOrder = [
  FundingSource.drawer,
  FundingSource.storeCash,
  FundingSource.bank,
];

/// Alasan kas laci tidak bisa dipakai.
enum ExpenseDrawerIssue { notPermitted, noSession, notToday }

/// Form *Catat pengeluaran* (1.22).
class ExpenseFormViewModel extends ChangeNotifier {
  ExpenseFormViewModel({
    required this._repository,
    required ExpensesSetup setup,
    this._picker = const FileSelectorImagePicker(),
  }) : _setup = setup,
       _funding = setup.canUseDrawer && setup.hasOpenSession
           ? FundingSource.drawer
           : FundingSource.storeCash {
    save = Command0(_save)..addListener(notifyListeners);
    pickReceipt = Command1(_pickReceipt)..addListener(notifyListeners);
  }

  final ExpensesRepository _repository;
  final ImageFilePicker _picker;
  ExpensesSetup _setup;

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    save.dispose();
    pickReceipt.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  /// Hasil = pengeluaran tersimpan.
  late final Command0<Expense> save;

  /// Argumen `true` = kamera.
  late final Command1<void, bool> pickReceipt;

  var _description = '';
  UuidValue? _categoryId;
  var _amount = Money.zero;
  FundingSource _funding;
  DateTime? _spentOn;
  ExpenseReceipt? _receipt;
  var _receiptRejected = false;
  var _submitted = false;
  var _generation = 0;

  ExpensesSetup get setup => _setup;
  String get description => _description;
  UuidValue? get categoryId => _categoryId;
  Money get amount => _amount;
  FundingSource get funding => _funding;
  DateTime get spentOn => _spentOn ?? _setup.today;
  ExpenseReceipt? get receipt => _receipt;
  bool get receiptRejected => _receiptRejected;
  bool get canTakePhoto => _picker.canTakePhoto;

  /// Naik saat isian dikosongkan agar field dibuat ulang.
  int get generation => _generation;

  /// Galat isian; kosong sampai pengguna mencoba menyimpan.
  Set<ExpenseIssue> get issues => _submitted ? _issues : const {};

  Set<ExpenseIssue> get _issues => validateExpense(
    description: _description,
    hasCategory: _categoryId != null,
    amount: _amount,
  );

  /// Tanggal di masa depan.
  bool get dateInFuture => spentOn.isAfter(_setup.today);

  ExpenseDrawerIssue? get drawerIssue {
    if (_funding != FundingSource.drawer) return null;
    if (!_setup.canUseDrawer) return ExpenseDrawerIssue.notPermitted;
    if (!_setup.hasOpenSession) return ExpenseDrawerIssue.noSession;
    if (spentOn != _setup.today) return ExpenseDrawerIssue.notToday;
    return null;
  }

  /// Jumlah dari laci melebihi perkiraan uang di laci: kelebihannya, untuk
  /// peringatan (F1-03c). Tidak memblokir simpan.
  Money? get drawerShortfall =>
      _funding == FundingSource.drawer && drawerIssue == null
      ? drawerShortfallOf(_amount, _setup.drawerCash)
      : null;

  bool get _valid => _issues.isEmpty && !dateInFuture && drawerIssue == null;

  bool get canSubmit => _valid && !save.running;

  /// Setup baru (mis. jenis ditambah atau sesi kasir dibuka).
  void updateSetup(ExpensesSetup setup) {
    _setup = setup;
    if (_categoryId != null &&
        !setup.categories.any((c) => c.id == _categoryId)) {
      _categoryId = null;
    }
    notifyListeners();
  }

  void setDescription(String v) {
    _description = v;
    notifyListeners();
  }

  void setCategory(UuidValue? id) {
    _categoryId = id;
    notifyListeners();
  }

  void setAmount(Money v) {
    _amount = v;
    notifyListeners();
  }

  void setFunding(FundingSource v) {
    _funding = v;
    notifyListeners();
  }

  void setSpentOn(DateTime v) {
    _spentOn = DateTime.utc(v.year, v.month, v.day);
    notifyListeners();
  }

  void removeReceipt() {
    _receipt = null;
    _receiptRejected = false;
    notifyListeners();
  }

  Future<Result<void>> _pickReceipt(bool camera) async {
    try {
      final picked = camera
          ? await _picker.takePhoto(
              maxBytes: ExpenseLimits.receiptInputMaxBytes,
            )
          : await _picker.pickImage(
              maxBytes: ExpenseLimits.receiptInputMaxBytes,
            );
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

  Future<Result<Expense>> _save() async {
    _submitted = true;
    if (!_valid) {
      notifyListeners();
      return Result.error(ExpenseInvalid(_issues));
    }
    final result = await _repository.record(
      ExpenseRequest(
        description: _description,
        categoryId: _categoryId,
        amount: _amount,
        funding: _funding,
        spentOn: spentOn,
        receipt: _receipt,
      ),
    );
    if (result is Ok<Expense>) {
      _description = '';
      _amount = Money.zero;
      _spentOn = null;
      _receipt = null;
      _receiptRejected = false;
      _submitted = false;
      _generation++;
    }
    return result;
  }
}
