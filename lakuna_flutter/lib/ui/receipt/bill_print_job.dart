import 'package:flutter/foundation.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/services/receipt_printer.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Cetak / bagikan PDF tagihan yang belum dibayar dari dialog pratinjau
/// (F1-10k Meja, F1-10m tamu split): status galat, terkirim, dan lokasi
/// PDF untuk dialog yang sedang terbuka.
class BillPrintJob extends ChangeNotifier {
  BillPrintJob({
    required this._printer,
    required this.selection,
    required this.paper,
    required this.logo,
    required this.jobName,
  }) {
    printBill = Command1(_print)..addListener(notifyListeners);
    shareBill = Command1(_share)..addListener(notifyListeners);
  }

  final ReceiptPrinter _printer;

  /// Printer struk perangkat; `null` = dialog cetak sistem.
  final PrinterSelection? Function() selection;
  final ReceiptPaper Function() paper;

  /// Logo struk (F1-06b), `null` bila tidak ditampilkan.
  final Uint8List? Function() logo;

  /// Nama job cetak dan berkas PDF tanpa ekstensi.
  final String Function() jobName;

  /// Cetak ke printer struk.
  late final Command1<void, List<ReceiptLine>> printBill;

  /// Simpan / bagikan sebagai PDF.
  late final Command1<String?, List<ReceiptLine>> shareBill;

  PrinterFailureReason? _printFailure;
  var _printed = false;
  var _printError = false;
  var _shareError = false;
  String? _pdfPath;

  /// Naik tiap dialog dibuka: hasil cetak/PDF dari dialog lama (printer
  /// lambat) tidak ditampilkan di dialog berikutnya.
  var _gen = 0;
  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    // Printer lambat bisa selesai setelah layar ditutup.
    if (!_disposed) super.notifyListeners();
  }

  PrinterFailureReason? get printFailure => _printFailure;

  /// Cetak gagal (galat printer atau lainnya).
  bool get printError => _printError;

  /// PDF gagal dibuat/dibagikan.
  bool get shareError => _shareError;

  /// Terkirim ke printer langsung (bukan dialog cetak sistem).
  bool get printed => _printed;

  /// Lokasi PDF yang disimpan di desktop.
  String? get pdfPath => _pdfPath;

  bool get running => printBill.running || shareBill.running;

  /// Hapus hasil cetak/bagikan sebelumnya saat dialog dibuka.
  void reset() {
    _gen++;
    _printFailure = null;
    _printed = false;
    _printError = false;
    _shareError = false;
    _pdfPath = null;
    printBill.clearResult();
    shareBill.clearResult();
    notifyListeners();
  }

  Future<Result<void>> _print(List<ReceiptLine> lines) async {
    final gen = _gen;
    _printFailure = null;
    _printed = false;
    _printError = false;
    final printer =
        selection() ??
        const PrinterSelection(kind: PrinterKind.system, name: '');
    try {
      await _printer.print(
        printer,
        lines,
        paper(),
        jobName: jobName(),
        logo: logo(),
      );
      if (gen == _gen) _printed = printer.isDirect;
      return const Result.ok(null);
    } on PrinterFailure catch (e) {
      if (gen == _gen) {
        _printFailure = e.reason;
        _printError = true;
      }
      return Result.error(e);
    } on Exception catch (e) {
      if (gen == _gen) _printError = true;
      return Result.error(e);
    }
  }

  Future<Result<String?>> _share(List<ReceiptLine> lines) async {
    final gen = _gen;
    _pdfPath = null;
    _shareError = false;
    try {
      final path = await _printer.sharePdf(
        lines,
        paper(),
        fileName: '${jobName()}.pdf',
        logo: logo(),
      );
      if (gen == _gen) _pdfPath = path;
      return Result.ok(path);
    } on Exception catch (e) {
      if (gen == _gen) _shareError = true;
      return Result.error(e);
    }
  }
}
