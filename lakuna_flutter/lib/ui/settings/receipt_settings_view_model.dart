import 'package:flutter/foundation.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/receipt_settings_repository.dart';
import '../../data/services/receipt_printer.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Pengaturan › Struk & printer (1.26, F1-06): printer perangkat ini dan
/// struk cabang ini.
class ReceiptSettingsViewModel extends ChangeNotifier {
  ReceiptSettingsViewModel({
    required this._repository,
    required this._printer,
  }) {
    load = Command0(_load)..addListener(notifyListeners);
    save = Command0(_save)..addListener(notifyListeners);
    searchBluetooth = Command0(_searchBluetooth)..addListener(notifyListeners);
    choosePrinter = Command1(_choosePrinter)..addListener(notifyListeners);
    forgetPrinter = Command0(_forgetPrinter)..addListener(notifyListeners);
    testPrint = Command1(_testPrint)..addListener(notifyListeners);
  }

  final ReceiptSettingsRepository _repository;
  final ReceiptPrinter _printer;

  late final Command0<void> load;
  late final Command0<ReceiptConfig> save;
  late final Command0<void> searchBluetooth;
  late final Command1<void, PrinterSelection> choosePrinter;
  late final Command0<void> forgetPrinter;
  late final Command1<void, List<ReceiptLine>> testPrint;

  ReceiptConfig? _config;
  var _draft = const ReceiptSettings();
  Set<ReceiptSettingsError> _errors = const {};
  var _saved = false;
  var _revision = 0;

  PrinterSelection? _selected;
  late PrinterKind _kind = _defaultKind;
  List<PrinterSelection> _bluetooth = const [];
  var _bluetoothSearched = false;
  var _networkAddress = '';
  var _networkInvalid = false;
  PrinterFailureReason? _failure;
  var _testSent = false;
  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  bool get loaded => _config != null;
  bool get supportsBluetooth => _printer.supportsBluetooth;

  // --- Struk cabang ---

  ReceiptPaper get paper => _draft.paper;
  bool get autoPrint => _draft.autoPrint;

  /// Isi awal field header (isian atau bawaan alamat cabang).
  String get headerText => _draft.header ?? _config?.defaultHeader ?? '';

  /// Isi awal field footer; `null` = UI mengisi ucapan bawaan.
  String? get footerText => _draft.footer;

  /// Naik setiap isian dikembalikan agar field membaca nilai awal lagi.
  int get revision => _revision;
  bool get saved => _saved;
  Set<ReceiptSettingsError> get errors => _errors;

  /// Pengaturan draf untuk pratinjau.
  ReceiptConfig get previewConfig => ReceiptConfig(
    settings: _draft,
    defaultHeader: _config?.defaultHeader ?? '',
  );

  bool get canSave => loaded && !save.running;

  void setPaper(ReceiptPaper v) => _edit(_draft.copyWith(paper: v));
  void setHeader(String v) => _edit(_draft.copyWith(header: v));
  void setFooter(String v) => _edit(_draft.copyWith(footer: v));
  void setAutoPrint(bool v) => _edit(_draft.copyWith(autoPrint: v));

  void _edit(ReceiptSettings next) {
    _draft = next;
    _saved = false;
    notifyListeners();
  }

  /// *Batal*: kembali ke nilai tersimpan.
  void cancel() {
    _reset();
    notifyListeners();
  }

  void _reset() {
    _draft = _config?.settings ?? const ReceiptSettings();
    _errors = const {};
    _saved = false;
    _revision++;
  }

  // --- Printer perangkat ---

  /// Printer terpilih; `null` = belum ada.
  PrinterSelection? get printer => _selected;

  /// Jenis yang sedang ditampilkan di kartu printer.
  PrinterKind get kind => _kind;
  List<PrinterSelection> get bluetoothPrinters => _bluetooth;

  /// Pencarian Bluetooth sudah berhasil sekali (daftar boleh kosong).
  bool get bluetoothSearched => _bluetoothSearched;
  String get networkAddress => _networkAddress;
  bool get networkAddressInvalid => _networkInvalid;

  /// Galat printer terakhir (cari, pilih, tes cetak).
  PrinterFailureReason? get printerFailure => _failure;
  bool get testSent => _testSent;

  bool get printerBusy =>
      searchBluetooth.running ||
      choosePrinter.running ||
      forgetPrinter.running ||
      testPrint.running;

  PrinterKind get _defaultKind =>
      supportsBluetooth ? PrinterKind.bluetooth : PrinterKind.network;

  void setKind(PrinterKind kind) {
    if (kind == PrinterKind.bluetooth && !supportsBluetooth) return;
    _kind = kind;
    _failure = null;
    _testSent = false;
    notifyListeners();
  }

  void setNetworkAddress(String v) {
    _networkAddress = v;
    _networkInvalid = false;
    notifyListeners();
  }

  /// *Pakai alamat ini* untuk printer jaringan.
  Future<void> useNetworkAddress() async {
    final parsed = parseNetworkAddress(_networkAddress);
    if (parsed == null) {
      _networkInvalid = true;
      notifyListeners();
      return;
    }
    final (host, port) = parsed;
    await choosePrinter.execute(
      PrinterSelection(
        kind: PrinterKind.network,
        name: host,
        address: '$host:$port',
      ),
    );
  }

  /// *Pakai dialog cetak sistem*.
  Future<void> useSystemDialog() => choosePrinter.execute(
    const PrinterSelection(kind: PrinterKind.system, name: ''),
  );

  // --- Aksi ---

  Future<Result<void>> _load() async {
    final config = await _repository.loadReceipt();
    if (config case Error(:final error)) return Result.error(error);
    final printer = await _repository.loadPrinter();
    if (printer case Error(:final error)) return Result.error(error);
    _config = (config as Ok<ReceiptConfig>).value;
    _selected = (printer as Ok<PrinterSelection?>).value;
    _kind = _selected?.kind ?? _defaultKind;
    if (_selected case PrinterSelection(
      kind: PrinterKind.network,
      :final address,
    )) {
      _networkAddress = address;
    }
    _reset();
    return const Result.ok(null);
  }

  Future<Result<ReceiptConfig>> _save() async {
    _saved = false;
    _errors = validateReceiptSettings(
      header: _draft.header,
      footer: _draft.footer,
    );
    if (_errors.isNotEmpty) {
      return Result.error(ReceiptSettingsInvalid(_errors));
    }
    final result = await _repository.saveReceipt(_draft);
    switch (result) {
      case Ok(:final value):
        _config = value;
        _reset();
        _saved = true;
      case Error(:final error):
        if (error case ReceiptSettingsInvalid(:final errors)) _errors = errors;
    }
    return result;
  }

  Future<Result<T>> _printerAction<T>(Future<T> Function() body) async {
    _failure = null;
    _testSent = false;
    try {
      return Result.ok(await body());
    } on PrinterFailure catch (e) {
      _failure = e.reason;
      return Result.error(e);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<void>> _searchBluetooth() => _printerAction(() async {
    _bluetooth = await _printer.bluetoothPrinters();
    _bluetoothSearched = true;
  });

  Future<Result<void>> _choosePrinter(PrinterSelection printer) async {
    final result = await _repository.savePrinter(printer);
    if (result case Ok()) {
      _selected = printer;
      _kind = printer.kind;
      _failure = null;
      _testSent = false;
    }
    return result;
  }

  Future<Result<void>> _forgetPrinter() async {
    final result = await _repository.savePrinter(null);
    if (result case Ok()) {
      _selected = null;
      _failure = null;
      _testSent = false;
    }
    return result;
  }

  /// Tes cetak [lines] (struk contoh dari UI) ke printer terpilih, atau
  /// dialog cetak sistem bila belum ada.
  Future<Result<void>> _testPrint(List<ReceiptLine> lines) => _printerAction(
    () async {
      await _printer.print(
        _selected ?? const PrinterSelection(kind: PrinterKind.system, name: ''),
        lines,
        _draft.paper,
        jobName: 'Lakuna test',
      );
      _testSent = true;
    },
  );
}
