import 'package:flutter/foundation.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/services/receipt_pdf.dart';
import '../../data/services/receipt_printer.dart';
import '../../utils/command.dart';
import '../../utils/log_error.dart';
import '../../utils/result.dart';

/// Pembuat PDF beberapa struk (bawaan [buildReceiptsPdf]); disuntikkan
/// di tes agar tidak memuat font.
typedef ReceiptsPdfBuilder = Future<Uint8List> Function(
  List<List<ReceiptLine>> bills,
  ReceiptPaper paper,
  Uint8List? logo,
);

/// Cetak / bagikan PDF tagihan yang belum dibayar dari dialog pratinjau
/// (F1-10k Meja, F1-10m tamu split): status galat, terkirim, dan lokasi
/// PDF untuk dialog yang sedang terbuka. Beberapa tagihan sekaligus
/// (tagihan semua tamu, F1-10r) lewat [printBills] / [shareBills].
class BillPrintJob extends ChangeNotifier {
  BillPrintJob({
    required this._printer,
    required this.selection,
    required this.paper,
    required this.logo,
    required this.jobName,
    ReceiptsPdfBuilder? buildPdf,
  }) : _buildPdf = buildPdf ?? _defaultPdf {
    printBill = Command1(_print)..addListener(notifyListeners);
    shareBill = Command1(_share)..addListener(notifyListeners);
    printBills = Command1(_printAll)..addListener(notifyListeners);
    shareBills = Command1(_shareAll)..addListener(notifyListeners);
  }

  static Future<Uint8List> _defaultPdf(
    List<List<ReceiptLine>> bills,
    ReceiptPaper paper,
    Uint8List? logo,
  ) => buildReceiptsPdf(bills, paper, logo: logo);

  final ReceiptPrinter _printer;
  final ReceiptsPdfBuilder _buildPdf;

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

  /// Cetak beberapa tagihan (F1-10r): printer langsung satu job per
  /// tagihan, dialog cetak sistem satu PDF banyak halaman.
  late final Command1<void, List<List<ReceiptLine>>> printBills;

  /// Satu PDF berisi beberapa tagihan, satu halaman per tagihan (F1-10r).
  late final Command1<String?, List<List<ReceiptLine>>> shareBills;

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

  bool get running =>
      printBill.running ||
      shareBill.running ||
      printBills.running ||
      shareBills.running;

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
    printBills.clearResult();
    shareBills.clearResult();
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

  Future<Result<void>> _printAll(List<List<ReceiptLine>> bills) async {
    if (bills.length == 1) return _print(bills.single);
    final gen = _gen;
    _printFailure = null;
    _printed = false;
    _printError = false;
    final printer =
        selection() ??
        const PrinterSelection(kind: PrinterKind.system, name: '');
    final paper = this.paper();
    final logo = this.logo();
    final name = jobName();
    try {
      if (printer.isDirect) {
        // Satu job per tagihan: tiap tamu mendapat potongan sendiri. Dialog
        // ditutup / dibuka ulang (reset) di tengah jalan: sisa tagihan tidak
        // dikirim, karena tagihannya bisa sudah tidak berlaku.
        for (final lines in bills) {
          if (gen != _gen) break;
          await _printer.print(
            printer,
            lines,
            paper,
            jobName: name,
            logo: logo,
          );
        }
      } else {
        final longest = bills.fold(0, (n, b) => b.length > n ? b.length : n);
        await _printer.printDocument(
          await _buildPdf(bills, paper, logo),
          jobName: name,
          format: receiptPageFormat(
            paper,
            longest,
            extraPt: receiptPdfLogoExtra(logo, paper),
          ),
        );
      }
      if (gen == _gen) _printed = printer.isDirect;
      return const Result.ok(null);
    } on PrinterFailure catch (e) {
      if (gen == _gen) {
        _printFailure = e.reason;
        _printError = true;
      }
      return Result.error(e);
    } on Object catch (e, st) {
      // Termasuk galat memuat font PDF (bukan Exception).
      logError('Cetak semua tagihan gagal', e, st);
      if (gen == _gen) _printError = true;
      return Result.error(e is Exception ? e : Exception('$e'));
    }
  }

  Future<Result<String?>> _shareAll(List<List<ReceiptLine>> bills) async {
    if (bills.length == 1) return _share(bills.single);
    final gen = _gen;
    _pdfPath = null;
    _shareError = false;
    try {
      final path = await _printer.shareDocument(
        await _buildPdf(bills, paper(), logo()),
        fileName: '${jobName()}.pdf',
      );
      if (gen == _gen) _pdfPath = path;
      return Result.ok(path);
    } on Object catch (e, st) {
      logError('PDF semua tagihan gagal', e, st);
      if (gen == _gen) _shareError = true;
      return Result.error(e is Exception ? e : Exception('$e'));
    }
  }
}
