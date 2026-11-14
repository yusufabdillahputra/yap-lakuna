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
/// baris sah dan ditolak, lalu simpan sebagai produk baru. Bila harga produk
/// yang ada ikut diperbarui, perubahan dilihat dulu sebelum simpan (F1-07m).
class ProductImportViewModel extends ChangeNotifier {
  ProductImportViewModel({
    required this._repository,
    required this._picker,
    this.onSaved,
  }) {
    pick = Command0(_pick)..addListener(notifyListeners);
    preview = Command0(_preview)..addListener(notifyListeners);
    run = Command0(_run)..addListener(notifyListeners);
  }

  final CatalogRepository _repository;
  final TableFilePicker _picker;

  /// Dipanggil setiap kali import tersimpan (lihat import pelanggan).
  final VoidCallback? onSaved;

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    pick.dispose();
    preview.dispose();
    run.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  late final Command0<void> pick;

  /// Import tanpa menyimpan untuk melihat perubahan harga (F1-07m).
  late final Command0<ProductImportSummary> preview;
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

  /// Hasil pratinjau terakhir yang masih berlaku untuk berkas dan sakelar
  /// saat ini.
  ProductImportSummary? get previewed => switch (preview.result) {
    Ok(:final value) => value,
    _ => null,
  };

  /// Sakelar perbarui menyala dan perubahan belum dilihat: tombol utama
  /// menjadi *Lihat perubahan*.
  bool get needsPreview => _updateExisting && previewed == null;

  bool get _busy =>
      pick.running || preview.running || run.running || run.completed;

  bool get canPreview => needsPreview && rows.isNotEmpty && !_busy;

  bool get canRun {
    if (rows.isEmpty || _busy) return false;
    if (!_updateExisting) return true;
    final p = previewed;
    return p != null && p.created + p.updated > 0;
  }

  /// Perbarui harga produk yang sudah ada (F1-07k); bawaan mati.
  bool get updateExisting => _updateExisting;
  var _updateExisting = false;

  void setUpdateExisting(bool value) {
    if (_busy) return;
    _updateExisting = value;
    // Pratinjau hanya berlaku untuk sakelar saat dibuat.
    preview.clearResult();
    notifyListeners();
  }

  Future<Result<void>> _pick() async {
    final PickedTableFile? file;
    try {
      file = await _picker.pickTable(maxBytes: customerImportMaxBytes);
    } on Exception catch (e) {
      return Result.error(e);
    }
    // Berkas tidak diganti di tengah pratinjau atau simpan: hasilnya akan
    // tertukar dengan berkas baru.
    if (file == null || preview.running || run.running) {
      return const Result.ok(null);
    }
    _fileName = file.name;
    _result = null;
    _problem = null;
    run.clearResult();
    preview.clearResult();
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

  Future<Result<ProductImportSummary>> _preview() async {
    if (rows.isEmpty) return const Result.error(StoreNotReady());
    return _repository.importRows(
      rows,
      updateExisting: _updateExisting,
      dryRun: true,
    );
  }

  Future<Result<ProductImportSummary>> _run() async {
    if (rows.isEmpty) return const Result.error(StoreNotReady());
    final result = await _repository.importRows(
      rows,
      updateExisting: _updateExisting,
    );
    if (result is Ok) onSaved?.call();
    return result;
  }
}
