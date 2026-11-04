import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/customers_repository.dart';
import '../../data/services/kuitansi_pdf.dart';
import '../../data/services/receipt_printer.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Format kuitansi pembayaran piutang (1.20b).
enum KuitansiFormat { a5, thermal }

/// Halaman kuitansi pembayaran piutang (1.20b): pratinjau A5 dan struk,
/// cetak, dan bagikan PDF. [copy] = cetak ulang (tanda *SALINAN*).
class KuitansiViewModel extends ChangeNotifier {
  KuitansiViewModel({
    required this._repository,
    required this._printer,
    required this.paymentId,
    this.copy = false,
  }) {
    load = Command0(_load)..addListener(notifyListeners);
    printA5 = Command1(_printA5)..addListener(notifyListeners);
    shareA5 = Command1(_shareA5)..addListener(notifyListeners);
    printThermal = Command1(_printThermal)..addListener(notifyListeners);
    shareThermal = Command1(_shareThermal)..addListener(notifyListeners);
  }

  final CustomersRepository _repository;
  final ReceiptPrinter _printer;
  final UuidValue paymentId;
  final bool copy;

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    for (final c in [load, printA5, shareA5, printThermal, shareThermal]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  late final Command0<void> load;
  late final Command1<void, KuitansiDocument> printA5;
  late final Command1<String?, KuitansiDocument> shareA5;
  late final Command1<void, List<ReceiptLine>> printThermal;
  late final Command1<String?, List<ReceiptLine>> shareThermal;

  CustomersSetup? _setup;
  DebtPaymentReceipt? _receipt;
  Exception? _error;
  var _format = KuitansiFormat.a5;
  var _showDetails = true;
  var _showBalance = true;
  String? _city;
  PrinterFailureReason? _printFailure;
  String? _savedPath;

  CustomersSetup? get setup => _setup;
  DebtPaymentReceipt? get receipt => _receipt;
  Exception? get error => _error;
  KuitansiFormat get format => _format;
  bool get showDetails => _showDetails;
  bool get showBalance => _showBalance;
  String get city => _city ?? _setup?.city ?? '';
  PrinterFailureReason? get printFailure => _printFailure;

  /// Lokasi PDF yang disimpan di desktop.
  String? get savedPath => _savedPath;

  ReceiptPaper get paper => _setup?.receipt.settings.paper ?? ReceiptPaper.mm58;

  PrinterSelection get _printerSelection =>
      _setup?.printer ??
      const PrinterSelection(kind: PrinterKind.system, name: '');

  bool get busy =>
      printA5.running ||
      shareA5.running ||
      printThermal.running ||
      shareThermal.running;

  Future<Result<void>> _load() async {
    final setup = await _repository.load();
    final receipt = await _repository.receipt(paymentId);
    switch ((setup, receipt)) {
      case (Ok(value: final s), Ok(value: final r)):
        _setup = s;
        _receipt = r;
        _error = null;
        return const Result.ok(null);
      case (Error(:final error), _) || (_, Error(:final error)):
        _error = error;
        return Result.error(error);
    }
  }

  void setFormat(KuitansiFormat f) {
    if (_format == f) return;
    _format = f;
    notifyListeners();
  }

  void setShowDetails(bool v) {
    _showDetails = v;
    notifyListeners();
  }

  void setShowBalance(bool v) {
    _showBalance = v;
    notifyListeners();
  }

  void setCity(String v) {
    _city = v;
    notifyListeners();
  }

  String get _fileName => '${_receipt?.payment.number ?? 'kuitansi'}.pdf';

  Future<Result<T>> _guard<T>(Future<T> Function() body) async {
    _printFailure = null;
    try {
      return Result.ok(await body());
    } on PrinterFailure catch (e) {
      _printFailure = e.reason;
      return Result.error(e);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<void>> _printA5(KuitansiDocument doc) => _guard(() async {
    final pdf = await buildKuitansiPdf(doc);
    await _printer.printDocument(pdf, jobName: doc.number);
  });

  Future<Result<String?>> _shareA5(KuitansiDocument doc) => _guard(() async {
    _savedPath = null;
    final path = await _printer.shareDocument(
      await buildKuitansiPdf(doc),
      fileName: _fileName,
    );
    _savedPath = path;
    return path;
  });

  Future<Result<void>> _printThermal(List<ReceiptLine> lines) => _guard(
    () => _printer.print(
      _printerSelection,
      lines,
      paper,
      jobName: _receipt?.payment.number ?? 'Lakuna',
    ),
  );

  Future<Result<String?>> _shareThermal(List<ReceiptLine> lines) =>
      _guard(() async {
        _savedPath = null;
        final path = await _printer.sharePdf(
          lines,
          paper,
          fileName: _fileName,
        );
        _savedPath = path;
        return path;
      });
}
