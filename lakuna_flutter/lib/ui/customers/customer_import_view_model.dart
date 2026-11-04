import 'package:flutter/foundation.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/customers_repository.dart';
import '../../data/services/table_file.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Batas ukuran berkas import pelanggan.
const customerImportMaxBytes = 2 * 1024 * 1024;

/// Kenapa berkas import tidak bisa dipakai.
enum ImportFileProblem { tooLarge, unreadable, missingName, empty }

/// Import pelanggan dari CSV/XLSX (1.20): pilih berkas, pratinjau baris
/// sah dan ditolak, lalu simpan.
class CustomerImportViewModel extends ChangeNotifier {
  CustomerImportViewModel({required this._repository, required this._picker}) {
    pick = Command0(_pick)..addListener(notifyListeners);
    run = Command0(_run)..addListener(notifyListeners);
  }

  final CustomersRepository _repository;
  final TableFilePicker _picker;

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
  late final Command0<CustomerImportSummary> run;

  String? _fileName;
  CustomerImportResult? _result;
  ImportFileProblem? _problem;

  String? get fileName => _fileName;
  CustomerImportResult? get result => _result;
  ImportFileProblem? get problem => _problem;

  List<CustomerImportRow> get rows => _result?.rows ?? const [];
  List<ImportRejected> get rejected => _result?.rejected ?? const [];

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
      final table = readTableFile(file.name, bytes);
      final result = customerImportRows(table);
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

  Future<Result<CustomerImportSummary>> _run() async {
    if (rows.isEmpty) {
      return const Result.error(StoreNotReady());
    }
    return _repository.importRows(rows);
  }
}
