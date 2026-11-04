import 'package:flutter/foundation.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/catalog_repository.dart';
import '../../data/services/table_file.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';
import '../customers/customer_import_view_model.dart'
    show ImportFileProblem, customerImportMaxBytes;

/// Import produk dari CSV/XLSX (1.15, F1-07b): pilih berkas, pratinjau
/// baris sah dan ditolak, lalu simpan sebagai produk baru.
class ProductImportViewModel extends ChangeNotifier {
  ProductImportViewModel({required this._repository, required this._picker}) {
    pick = Command0(_pick)..addListener(notifyListeners);
    run = Command0(_run)..addListener(notifyListeners);
  }

  final CatalogRepository _repository;
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
  late final Command0<ProductImportSummary> run;

  String? _fileName;
  ProductImportResult? _result;
  ImportFileProblem? _problem;

  String? get fileName => _fileName;
  ProductImportResult? get result => _result;

  /// `missingName` berarti kolom Nama atau Harga jual tidak ada.
  ImportFileProblem? get problem => _problem;

  List<ProductImportRow> get rows => _result?.rows ?? const [];
  List<ProductImportRejected> get rejected => _result?.rejected ?? const [];

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
      final result = productImportRows(readTableFile(file.name, bytes));
      if (result.missingColumns) {
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

  Future<Result<ProductImportSummary>> _run() async {
    if (rows.isEmpty) return const Result.error(StoreNotReady());
    return _repository.importRows(rows);
  }
}
