import 'package:flutter/foundation.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/suppliers_repository.dart';
import '../../data/services/table_file.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';
import '../customers/customer_import_view_model.dart'
    show ImportFileProblem, customerImportMaxBytes;

/// Import supplier dari CSV/XLSX (1.21, F1-14b): pilih berkas, pratinjau
/// baris sah dan ditolak, lalu simpan. Batas berkas sama dengan import
/// pelanggan.
class SupplierImportViewModel extends ChangeNotifier {
  SupplierImportViewModel({
    required this._repository,
    required this._picker,
    this.onSaved,
  }) {
    pick = Command0(_pick)..addListener(notifyListeners);
    run = Command0(_run)..addListener(notifyListeners);
  }

  final SuppliersRepository _repository;
  final TableFilePicker _picker;

  /// Dipanggil setiap kali import tersimpan, agar pemanggil tetap memuat
  /// ulang daftar walau dialog ditutup lewat latar atau tombol kembali.
  final VoidCallback? onSaved;

  var _saved = false;

  /// Sudah ada import yang tersimpan (tetap `true` setelah memilih berkas
  /// lain).
  bool get saved => _saved;

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    pick.dispose();
    run.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  late final Command0<void> pick;
  late final Command0<SupplierImportSummary> run;

  String? _fileName;
  SupplierImportResult? _result;
  ImportFileProblem? _problem;

  String? get fileName => _fileName;
  SupplierImportResult? get result => _result;
  ImportFileProblem? get problem => _problem;

  List<SupplierImportRow> get rows => _result?.rows ?? const [];
  List<SupplierImportRejected> get rejected => _result?.rejected ?? const [];

  bool get canRun => rows.isNotEmpty && !run.running && !run.completed;

  Future<Result<void>> _pick() async {
    final PickedTableFile? file;
    try {
      file = await _picker.pickTable(maxBytes: customerImportMaxBytes);
    } on Exception catch (e) {
      return Result.error(e);
    }
    if (file == null) return const Result.ok(null);
    _fileName = file.name;
    _result = null;
    _problem = null;
    run.clearResult();
    final bytes = file.bytes;
    if (bytes == null) {
      _problem = ImportFileProblem.tooLarge;
      return const Result.ok(null);
    }
    try {
      final result = supplierImportRows(readTableFile(file.name, bytes));
      if (result.missingName) {
        _problem = ImportFileProblem.missingName;
      } else if (result.rows.isEmpty && result.rejected.isEmpty) {
        _problem = ImportFileProblem.empty;
      }
      _result = result;
    } on TableFileUnreadable {
      _problem = ImportFileProblem.unreadable;
    }
    return const Result.ok(null);
  }

  Future<Result<SupplierImportSummary>> _run() async {
    if (rows.isEmpty) return const Result.error(StoreNotReady());
    final result = await _repository.importRows(rows);
    if (result is Ok) {
      _saved = true;
      onSaved?.call();
    }
    return result;
  }
}
