import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/receipt_settings_repository.dart';
import '../../data/repositories/reports_repository.dart';
import '../../data/services/receipt_printer.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';
import '../cash_session/session_recap_content.dart';
import '../receipt/printer_labels.dart';
import '../receipt/receipt_content.dart' show receiptDate;
import '../receipt/receipt_paper_view.dart';

/// Dialog *Rekap sesi* di Laporan › Kas & sesi (F1-03e): memuat rekap sesi
/// tertutup, lalu cetak ulang atau bagikan PDF dengan mesin struk F1-06.
class SessionRecapDialogViewModel extends ChangeNotifier {
  SessionRecapDialogViewModel({
    required this._repository,
    required this._sessionId,
    this._receiptSettings,
    this._printer,
    this._timezone,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    load = Command0(_load)..addListener(notifyListeners);
    print = Command1(_print)..addListener(notifyListeners);
    share = Command1(_share)..addListener(notifyListeners);
  }

  final ReportsRepository _repository;
  final UuidValue _sessionId;

  /// Kertas, logo, dan printer struk; `null` = tidak bisa dicetak.
  final ReceiptSettingsRepository? _receiptSettings;
  final ReceiptPrinter? _printer;
  final String? _timezone;
  final DateTime Function() _clock;

  late final Command0<void> load;

  /// Argumen = baris rekap dari `sessionRecapContent`.
  late final Command1<void, List<ReceiptLine>> print;
  late final Command1<String?, List<ReceiptLine>> share;

  SessionRecap? _recap;
  String _deviceCode = '';
  Object? _loadError;
  ReceiptPaper _paper = ReceiptPaper.mm58;
  Uint8List? _logo;
  PrinterSelection? _printerSelection;
  var _printed = false;
  var _printError = false;
  PrinterFailureReason? _printFailure;
  var _shareError = false;
  String? _pdfPath;
  DateTime? _loadedAt;
  var _disposed = false;

  SessionRecap? get recap => _recap;

  /// Waktu muat, untuk baris *Dicetak ulang* di pratinjau.
  DateTime get loadedAt => _loadedAt ?? _clock();

  /// Waktu sekarang, untuk baris *Dicetak ulang* saat tombol ditekan.
  DateTime now() => _clock();

  /// Kode perangkat tempat sesi dibuka.
  String get deviceCode => _deviceCode;

  /// Sesi tidak ada di cabang ini atau belum ditutup.
  bool get notClosed => _loadError is CashSessionNotClosed;
  bool get loadFailed => _loadError != null;

  ReceiptPaper get paper => _paper;
  Uint8List? get logo => _logo;

  /// Layanan cetak tersedia (sama dengan F1-03b: printer dan pengaturan
  /// struk).
  bool get canPrint => _printer != null && _receiptSettings != null;

  /// Terkirim ke printer langsung (bukan dialog cetak sistem).
  bool get printed => _printed;
  bool get printError => _printError;
  PrinterFailureReason? get printFailure => _printFailure;
  bool get shareError => _shareError;

  /// Lokasi PDF yang disimpan di desktop.
  String? get pdfPath => _pdfPath;

  bool get busy => print.running || share.running;

  /// `rekap-sesi-YYMMDD-HHMM` dari waktu tutup, sama dengan F1-03b.
  String get fileName {
    final closed = _recap?.closed;
    final t = outletLocalTime(
      closed?.closedAt ?? closed?.updatedAt ?? _clock(),
      _timezone,
    );
    String two(int n) => n.toString().padLeft(2, '0');
    return 'rekap-sesi-${two(t.year % 100)}${two(t.month)}${two(t.day)}-'
        '${two(t.hour)}${two(t.minute)}';
  }

  Future<Result<void>> _load() async {
    _loadError = null;
    _loadedAt = _clock();
    if (_receiptSettings case final settings?) {
      if (await settings.loadReceipt() case Ok(:final value)) {
        _paper = value.settings.paper;
        _logo = value.logoBytes;
      }
      if (await settings.loadPrinter() case Ok(:final value)) {
        _printerSelection = value;
      }
    }
    final result = await _repository.loadSessionRecap(_sessionId);
    switch (result) {
      case Ok(:final value):
        _recap = SessionRecap.fromClosed(value);
        _deviceCode = value.deviceCode;
      case Error(:final error):
        _recap = null;
        _loadError = error;
    }
    return result;
  }

  void _resetOutput() {
    _printed = false;
    _printError = false;
    _printFailure = null;
    _shareError = false;
    _pdfPath = null;
  }

  Future<Result<void>> _print(List<ReceiptLine> lines) async {
    final printer = _printer;
    if (printer == null || !canPrint) return const Result.ok(null);
    _resetOutput();
    final selection =
        _printerSelection ??
        const PrinterSelection(kind: PrinterKind.system, name: '');
    try {
      await printer.print(
        selection,
        lines,
        _paper,
        jobName: fileName,
        logo: _logo,
      );
      _printed = selection.isDirect;
      return const Result.ok(null);
    } on PrinterFailure catch (e) {
      _printFailure = e.reason;
      _printError = true;
      return Result.error(e);
    } on Exception catch (e) {
      _printError = true;
      return Result.error(e);
    }
  }

  Future<Result<String?>> _share(List<ReceiptLine> lines) async {
    final printer = _printer;
    if (printer == null || !canPrint) return const Result.ok(null);
    _resetOutput();
    try {
      final path = await printer.sharePdf(
        lines,
        _paper,
        fileName: '$fileName.pdf',
        logo: _logo,
      );
      _pdfPath = path;
      return Result.ok(path);
    } on Exception catch (e) {
      _shareError = true;
      return Result.error(e);
    }
  }

  /// Dialog bisa ditutup saat muat / cetak masih berjalan.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  /// Command tidak di-dispose: aksi yang masih berjalan memanggil
  /// `notifyListeners` miliknya sendiri saat selesai.
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Membuka dialog *Rekap sesi* untuk sesi tertutup [sessionId] (F1-03e).
Future<void> showSessionRecapDialog(
  BuildContext context, {
  required ReportsRepository repository,
  required UuidValue sessionId,
  required String businessName,
  required String outletName,
  required String? timezone,
  ReceiptSettingsRepository? receiptSettings,
  ReceiptPrinter? printer,
}) => showFDialog<void>(
  context: context,
  builder: (context, style, animation) => FDialog(
    animation: animation,
    constraints: const BoxConstraints(minWidth: 280, maxWidth: 460),
    // Builder ini bisa dipanggil ulang (tema, inset); view model dibuat
    // sekali di State dialog.
    builder: (context, style) => _SessionRecapDialog(
      repository: repository,
      sessionId: sessionId,
      receiptSettings: receiptSettings,
      printer: printer,
      businessName: businessName,
      outletName: outletName,
      timezone: timezone,
    ),
  ),
);

class _SessionRecapDialog extends StatefulWidget {
  const _SessionRecapDialog({
    required this.repository,
    required this.sessionId,
    required this.receiptSettings,
    required this.printer,
    required this.businessName,
    required this.outletName,
    required this.timezone,
  });

  final ReportsRepository repository;
  final UuidValue sessionId;
  final ReceiptSettingsRepository? receiptSettings;
  final ReceiptPrinter? printer;
  final String businessName;
  final String outletName;
  final String? timezone;

  @override
  State<_SessionRecapDialog> createState() => _SessionRecapDialogState();
}

class _SessionRecapDialogState extends State<_SessionRecapDialog> {
  late final _vm = SessionRecapDialogViewModel(
    repository: widget.repository,
    sessionId: widget.sessionId,
    receiptSettings: widget.receiptSettings,
    printer: widget.printer,
    timezone: widget.timezone,
  );

  @override
  void initState() {
    super.initState();
    unawaited(_vm.load.execute());
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  /// [at] = waktu *Dicetak ulang*: saat muat untuk pratinjau, saat tombol
  /// ditekan untuk cetak / PDF.
  List<ReceiptLine> _lines(
    AppLocalizations l10n,
    SessionRecap recap,
    DateTime at,
  ) => layoutReceipt(
    sessionRecapContent(
      l10n,
      recap: recap,
      businessName: widget.businessName,
      outletName: widget.outletName,
      deviceCode: _vm.deviceCode,
      timezone: widget.timezone,
      reprintedAt: at,
    ),
    _vm.paper,
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _vm,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      final recap = _vm.recap;
      final title = recap == null
          ? l10n.reportsSessionRecapOpen
          : l10n.reportsSessionRecapTitle(
              receiptDate(
                outletLocalTime(recap.closed.openedAt, widget.timezone),
              ),
            );
      final busy = _vm.busy;
      return Padding(
        key: const ValueKey('reports-recap-dialog'),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              title,
              style: theme.typography.display.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_vm.load.running && recap == null)
              const Center(child: FCircularProgress())
            else if (_vm.loadFailed)
              FAlert(
                key: const ValueKey('reports-recap-load-error'),
                variant: .destructive,
                title: Text(
                  _vm.notClosed
                      ? l10n.reportsSessionRecapNotClosed
                      : l10n.reportsSessionRecapLoadFailed,
                ),
              )
            else if (recap != null)
              Flexible(
                child: SingleChildScrollView(
                  child: Center(
                    child: ReceiptPaperView(
                      key: const ValueKey('reports-recap-paper'),
                      lines: _lines(l10n, recap, _vm.loadedAt),
                      paper: _vm.paper,
                      logo: _vm.logo,
                    ),
                  ),
                ),
              ),
            if (_vm.printError)
              FAlert(
                key: const ValueKey('reports-recap-print-error'),
                variant: .destructive,
                title: Text(printerFailureMessage(l10n, _vm.printFailure)),
              )
            else if (_vm.printed)
              FAlert(
                key: const ValueKey('reports-recap-printed'),
                title: Text(l10n.cashRecapPrinted),
              ),
            if (_vm.shareError)
              FAlert(
                key: const ValueKey('reports-recap-share-error'),
                variant: .destructive,
                title: Text(l10n.cashRecapShareError),
              )
            else if (_vm.pdfPath case final path?)
              FAlert(
                key: const ValueKey('reports-recap-pdf-saved'),
                title: Text(l10n.receiptPdfSaved(path)),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                FButton(
                  key: const ValueKey('reports-recap-close'),
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: () => Navigator.of(context).pop(),
                  child: Flexible(child: Text(l10n.historyClose)),
                ),
                if (recap != null && _vm.canPrint) ...[
                  FButton(
                    key: const ValueKey('reports-recap-share'),
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: busy
                        ? null
                        : () => _vm.share.execute(
                            _lines(l10n, recap, _vm.now()),
                          ),
                    prefix: const Icon(TablerIcons.share),
                    child: Flexible(child: Text(l10n.receiptShare)),
                  ),
                  FButton(
                    key: const ValueKey('reports-recap-print'),
                    mainAxisSize: .min,
                    onPress: busy
                        ? null
                        : () => _vm.print.execute(
                            _lines(l10n, recap, _vm.now()),
                          ),
                    prefix: const Icon(TablerIcons.printer),
                    child: Flexible(child: Text(l10n.cashRecapPrint)),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    },
  );
}
