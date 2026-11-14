import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart'
    show ProductCategory, UuidValue;
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/receipt_settings_repository.dart';
import '../../data/services/receipt_printer.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Stasiun printer tiket: dapur (F1-10e) atau bar (F1-10j).
enum PrinterStation { kitchen, bar }

/// Pengaturan › Struk & printer › *Printer dapur* (F1-10e): printer khusus
/// tiket dapur di perangkat ini. Tanpa printer dapur, tiket memakai printer
/// struk lewat *Cetak tiket*. Dengan [station] bar (F1-10j) VM yang sama
/// mengatur *Printer bar* beserta kategori menu yang dicetak di bar.
class KitchenPrinterViewModel extends ChangeNotifier {
  KitchenPrinterViewModel({
    required this._repository,
    required this._printer,
    this.station = PrinterStation.kitchen,
  }) {
    load = Command0(_load)..addListener(notifyListeners);
    searchBluetooth = Command0(_searchBluetooth)..addListener(notifyListeners);
    choose = Command1(_choose)..addListener(notifyListeners);
    forget = Command0(_forget)..addListener(notifyListeners);
    testPrint = Command1(_testPrint)..addListener(notifyListeners);
  }

  final ReceiptSettingsRepository _repository;
  final ReceiptPrinter _printer;
  final PrinterStation station;
  bool get _isBar => station == PrinterStation.bar;

  late final Command0<void> load;
  late final Command0<void> searchBluetooth;

  /// Memilih printer dapur (jaringan / Bluetooth) dengan kertas terpilih.
  late final Command1<void, PrinterSelection> choose;

  /// Kembali ke *Sama dengan printer struk*.
  late final Command0<void> forget;
  late final Command1<void, List<ReceiptLine>> testPrint;

  var _loaded = false;
  KitchenPrinter? _kitchen;
  PrinterKind? _kind;
  var _paper = ReceiptPaper.mm58;
  List<PrinterSelection> _bluetooth = const [];
  var _bluetoothSearched = false;
  var _networkAddress = '';
  var _networkInvalid = false;
  var _revision = 0;
  PrinterFailureReason? _failure;
  var _testSent = false;
  var _disposed = false;
  List<ProductCategory> _categories = const [];
  Set<UuidValue> _categoryIds = const {};

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  bool get loaded => _loaded;

  /// Kategori menu induk yang bisa diarahkan ke bar.
  List<ProductCategory> get categories => _categories;

  /// Kategori yang dicetak di bar (tersimpan, atau dipakai saat printer
  /// dipilih).
  Set<UuidValue> get categoryIds => _categoryIds;

  /// Printer bar tersimpan tanpa kategori: belum ada yang ke bar.
  bool get needsCategory => _isBar && _kitchen != null && _categoryIds.isEmpty;

  /// Kategori [id] masuk / keluar dari bar; langsung tersimpan bila printer
  /// bar sudah dipilih.
  void toggleCategory(UuidValue id) {
    if (!_isBar || busy) return;
    final previous = _categoryIds;
    _categoryIds = previous.contains(id)
        ? ({...previous}..remove(id))
        : {...previous, id};
    notifyListeners();
    final saved = _kitchen;
    if (saved == null) return;
    choose.execute(saved.printer).then((_) {
      if (choose.error && identical(_kitchen, saved)) {
        _categoryIds = previous;
        notifyListeners();
      }
    });
  }

  bool get supportsBluetooth => _printer.supportsBluetooth;

  /// Printer dapur tersimpan; `null` = sama dengan printer struk.
  KitchenPrinter? get kitchen => _kitchen;

  /// Pilihan yang sedang ditampilkan: `null` = sama dengan printer struk,
  /// [PrinterKind.network] atau [PrinterKind.bluetooth].
  PrinterKind? get kind => _kind;

  /// Lebar kertas tiket dapur.
  ReceiptPaper get paper => _paper;

  List<PrinterSelection> get bluetoothPrinters => _bluetooth;
  bool get bluetoothSearched => _bluetoothSearched;
  String get networkAddress => _networkAddress;
  bool get networkAddressInvalid => _networkInvalid;

  /// Naik saat alamat dimuat ulang agar field membaca nilai awal lagi.
  int get revision => _revision;

  /// Galat printer terakhir (cari, tes cetak).
  PrinterFailureReason? get failure => _failure;
  bool get testSent => _testSent;
  bool get canTest => _kitchen != null && !busy;

  bool get busy =>
      searchBluetooth.running ||
      choose.running ||
      forget.running ||
      testPrint.running;

  /// `null` = *Sama dengan printer struk*: melupakan printer dapur yang
  /// tersimpan.
  void setKind(PrinterKind? kind) {
    if (kind == PrinterKind.system) return;
    if (kind == PrinterKind.bluetooth && !supportsBluetooth) return;
    if (kind == null && _kitchen != null) {
      if (!busy) forget.execute();
      return;
    }
    _kind = kind;
    _failure = null;
    _testSent = false;
    notifyListeners();
  }

  /// Lebar kertas dapur; langsung tersimpan bila printer dapur yang tampil
  /// sudah tersimpan, selain itu dipakai saat printer berikutnya dipilih.
  void setPaper(ReceiptPaper paper) {
    final saved = _kitchen;
    final current = saved?.printer.kind == _kind ? saved : null;
    if (paper == _paper || (current != null && busy)) return;
    _paper = paper;
    notifyListeners();
    if (current == null) return;
    choose.execute(current.printer).then((_) {
      if (choose.error && _kitchen == current) {
        _paper = current.paper;
        notifyListeners();
      }
    });
  }

  void setNetworkAddress(String v) {
    _networkAddress = v;
    _networkInvalid = false;
    notifyListeners();
  }

  /// *Pakai alamat ini*.
  Future<void> useNetworkAddress() async {
    final parsed = parseNetworkAddress(_networkAddress);
    if (parsed == null) {
      _networkInvalid = true;
      notifyListeners();
      return;
    }
    final (host, port) = parsed;
    await choose.execute(
      PrinterSelection(
        kind: PrinterKind.network,
        name: host,
        address: '$host:$port',
      ),
    );
  }

  Future<Result<void>> _load() async {
    if (_isBar) {
      final categories = await _repository.menuCategories();
      if (categories case Error(:final error)) return Result.error(error);
      _categories = (categories as Ok<List<ProductCategory>>).value;
    }
    final result = _isBar
        ? await _repository.loadBarPrinter()
        : await _repository.loadKitchenPrinter();
    if (result case Error(:final error)) return Result.error(error);
    _apply((result as Ok<KitchenPrinter?>).value);
    _loaded = true;
    return const Result.ok(null);
  }

  void _apply(KitchenPrinter? kitchen) {
    _kitchen = kitchen;
    _kind = kitchen?.printer.kind;
    _paper = kitchen?.paper ?? _paper;
    if (_isBar && kitchen != null) _categoryIds = kitchen.categoryIds;
    if (kitchen?.printer case PrinterSelection(
      kind: PrinterKind.network,
      :final address,
    )) {
      _networkAddress = address;
      _networkInvalid = false;
      _revision++;
    }
  }

  Future<Result<void>> _choose(PrinterSelection printer) async {
    final next = KitchenPrinter(
      printer: printer,
      paper: _paper,
      categoryIds: _isBar ? _categoryIds : const {},
    );
    final result = await _save(next);
    if (result case Ok()) {
      _apply(next);
      _failure = null;
      _testSent = false;
    }
    return result;
  }

  Future<Result<void>> _forget() async {
    final result = await _save(null);
    if (result case Ok()) {
      _kitchen = null;
      _kind = null;
      _failure = null;
      _testSent = false;
    }
    return result;
  }

  Future<Result<void>> _save(KitchenPrinter? next) => _isBar
      ? _repository.saveBarPrinter(next)
      : _repository.saveKitchenPrinter(next);

  Future<Result<void>> _printerAction(Future<void> Function() body) async {
    _failure = null;
    _testSent = false;
    try {
      await body();
      return const Result.ok(null);
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

  /// Tiket contoh [lines] ke printer dapur.
  Future<Result<void>> _testPrint(List<ReceiptLine> lines) {
    final kitchen = _kitchen;
    if (kitchen == null) return Future.value(const Result.ok(null));
    return _printerAction(() async {
      await _printer.print(
        kitchen.printer,
        lines,
        kitchen.paper,
        jobName: _isBar ? 'Lakuna bar test' : 'Lakuna kitchen test',
      );
      _testSent = true;
    });
  }
}
