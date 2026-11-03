import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/dining_repository.dart';
import '../../data/services/receipt_printer.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';
import '../cashier/cashier_view_model.dart' show SaleOption;
import '../products/product_list_view_model.dart' show productMatches;

/// Dine in (grid meja) atau take away.
enum DiningMode { dineIn, takeAway }

/// Status meja di grid 1.7 (dihitung dari bill terbuka).
enum TableState { empty, open, billRequested }

/// View model layar Meja & open bill (1.7 / 1.7e, F1-10).
class DiningViewModel extends ChangeNotifier {
  DiningViewModel({required this._repository, required this._printer}) {
    load = Command0(_load)..addListener(notifyListeners);
    openTable = Command1(_openTable)..addListener(notifyListeners);
    openTakeAway = Command1(_openTakeAway)..addListener(notifyListeners);
    addItem = Command1(_addItem)..addListener(notifyListeners);
    setQuantity = Command1(_setQuantity)..addListener(notifyListeners);
    markServed = Command1(_markServed)..addListener(notifyListeners);
    send = Command0(_send)..addListener(notifyListeners);
    requestBill = Command1(_requestBill)..addListener(notifyListeners);
    move = Command1(_move)..addListener(notifyListeners);
    voidBill = Command1(_void)..addListener(notifyListeners);
    deleteEmpty = Command1(_deleteEmpty)..addListener(notifyListeners);
    printTicket = Command1(_printTicket)..addListener(notifyListeners);
  }

  final DiningRepository _repository;
  final ReceiptPrinter _printer;

  late final Command0<DiningData> load;

  /// (meja, jumlah tamu).
  late final Command1<OpenBill, (UuidValue, int)> openTable;

  /// Nama pemesan opsional.
  late final Command1<OpenBill, String?> openTakeAway;

  /// (pilihan menu, catatan dapur).
  late final Command1<OpenBill, (SaleOption, String?)> addItem;

  /// (item, jumlah baru); nol menghapus item *Baru*.
  late final Command1<OpenBill, (UuidValue, Qty)> setQuantity;
  late final Command1<OpenBill, UuidValue> markServed;
  late final Command0<KitchenSendResult> send;
  late final Command1<OpenBill, bool> requestBill;

  /// Meja tujuan.
  late final Command1<OpenBill, UuidValue> move;

  /// Alasan batal.
  late final Command1<void, String> voidBill;
  late final Command1<void, UuidValue> deleteEmpty;
  late final Command1<void, List<ReceiptLine>> printTicket;

  DiningData? _data;
  DiningMode _mode = DiningMode.dineIn;
  UuidValue? _areaId;
  UuidValue? _selectedId;
  KitchenSendResult? _ticket;
  Exception? _actionError;
  PrinterFailureReason? _printFailure;
  var _ticketPrinted = false;
  String _menuQuery = '';
  UuidValue? _menuCategory;

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

  // --- Data ----------------------------------------------------------------

  bool get loaded => _data != null;
  DiningData? get data => _data;

  /// Galat muat terakhir.
  Exception? get loadError => switch (load.result) {
    Error(:final error) => error,
    _ => null,
  };

  DiningOverview? get _overview => _data?.overview;
  List<DiningArea> get areas => _overview?.areas ?? const [];
  List<DiningTable> get tables => _overview?.tables ?? const [];
  bool get canPay => _data?.canPay ?? false;
  bool get canVoid => _data?.canVoid ?? false;
  String get staffName => _data?.staffName ?? '';
  FnbRates get rates => _overview?.rates ?? const FnbRates();

  Future<Result<DiningData>> _load() async {
    final result = await _repository.load();
    if (result case Ok(:final value)) {
      _data = value;
      if (_areaId != null &&
          !value.overview.areas.any((a) => a.id == _areaId)) {
        _areaId = null;
      }
      if (_selectedId != null && _billById(_selectedId!) == null) {
        _selectedId = null;
      }
    }
    return result;
  }

  Future<void> _reloadOverview() async {
    final result = await _repository.overview();
    if (result case Ok(:final value)) {
      _data = _data?.withOverview(value);
      if (_selectedId != null && _billById(_selectedId!) == null) {
        _selectedId = null;
      }
    }
  }

  /// Mengganti bill [bill] di ringkasan (tanpa memuat ulang semua).
  void _put(OpenBill bill) {
    final o = _overview;
    if (o == null) return;
    final bills = [
      for (final b in o.bills)
        if (b.id != bill.id) b,
      bill,
    ];
    _data = _data!.withOverview(
      DiningOverview(
        areas: o.areas,
        tables: o.tables,
        bills: bills,
        rates: o.rates,
      ),
    );
  }

  OpenBill? _billById(UuidValue id) =>
      _overview?.bills.where((b) => b.id == id).firstOrNull;

  // --- Tampilan ------------------------------------------------------------

  DiningMode get mode => _mode;

  void setMode(DiningMode m) {
    if (_mode == m) return;
    _mode = m;
    _actionError = null;
    final selected = selectedBill;
    if (selected != null && selected.isTakeAway != (m == DiningMode.takeAway)) {
      _selectedId = null;
    }
    notifyListeners();
  }

  /// Area terpilih; `null` = semua meja.
  UuidValue? get areaId => _areaId;

  void setArea(UuidValue? id) {
    _areaId = id;
    notifyListeners();
  }

  /// Meja di area terpilih, urut master.
  List<DiningTable> get visibleTables => [
    for (final t in tables)
      if (_areaId == null || t.diningAreaId == _areaId) t,
  ];

  OpenBill? billFor(DiningTable table) => _overview?.billForTable(table.id);

  TableState tableState(DiningTable table) {
    final bill = billFor(table);
    if (bill == null) return TableState.empty;
    return bill.billRequested ? TableState.billRequested : TableState.open;
  }

  int get occupiedCount => _overview?.occupiedTables ?? 0;

  /// Take away terbuka, urut nomor.
  List<OpenBill> get takeAways => _overview?.takeAways ?? const [];

  OpenBill? get selectedBill =>
      _selectedId == null ? null : _billById(_selectedId!);

  void select(OpenBill bill) {
    _selectedId = bill.id;
    _actionError = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedId = null;
    _actionError = null;
    notifyListeners();
  }

  /// Ketuk meja: memilih bill yang ada (`true`); meja kosong perlu dibuka
  /// dengan jumlah tamu (`false`).
  bool tapTable(DiningTable table) {
    final bill = billFor(table);
    if (bill == null) return false;
    select(bill);
    return true;
  }

  /// Meja kosong untuk *Pindah meja*.
  List<DiningTable> get moveTargets => [
    for (final t in tables)
      if (billFor(t) == null) t,
  ];

  /// Galat aksi bill terakhir (item terkunci, alasan kosong, dsb.).
  Exception? get actionError => _actionError;

  void clearActionError() {
    if (_actionError == null) return;
    _actionError = null;
    notifyListeners();
  }

  bool get busy =>
      openTable.running ||
      openTakeAway.running ||
      addItem.running ||
      setQuantity.running ||
      markServed.running ||
      send.running ||
      requestBill.running ||
      move.running ||
      voidBill.running ||
      deleteEmpty.running;

  // --- Menu ------------------------------------------------------------------

  String get menuQuery => _menuQuery;
  UuidValue? get menuCategory => _menuCategory;
  List<ProductCategory> get menuCategories => _data?.categories ?? const [];

  void setMenuQuery(String v) {
    _menuQuery = v;
    notifyListeners();
  }

  void setMenuCategory(UuidValue? id) {
    _menuCategory = id;
    notifyListeners();
  }

  List<CatalogProduct> get menuProducts => [
    for (final p in _data?.products ?? const <CatalogProduct>[])
      if ((_menuCategory == null ||
              p.categoryId == _menuCategory ||
              _data?.categoryParents[p.categoryId] == _menuCategory) &&
          productMatches(p, _menuQuery))
        p,
  ];

  // --- Aksi bill -------------------------------------------------------------

  Future<Result<T>> _act<T>(
    Future<Result<T>> Function() action, {
    void Function(T value)? onOk,
  }) async {
    _actionError = null;
    final result = await action();
    switch (result) {
      case Ok(:final value):
        onOk?.call(value);
      case Error(:final error):
        _actionError = error;
    }
    return result;
  }

  void _selectNew(OpenBill bill) {
    _put(bill);
    _selectedId = bill.id;
  }

  Future<Result<OpenBill>> _openTable((UuidValue, int) arg) =>
      _act(() => _repository.openTable(arg.$1, arg.$2), onOk: _selectNew);

  Future<Result<OpenBill>> _openTakeAway(String? name) async {
    final result = await _act(
      () => _repository.openTakeAway(name),
      onOk: _selectNew,
    );
    if (result is Ok) _mode = DiningMode.takeAway;
    return result;
  }

  UuidValue? get _billId => _selectedId;

  Future<Result<OpenBill>> _addItem((SaleOption, String?) arg) {
    final id = _billId;
    if (id == null) return Future.value(Result.error(BillNotFound()));
    final (option, note) = arg;
    return _act(
      () => _repository.addItem(
        id,
        SaleLineRequest(
          variantId: option.variant.id,
          productUnitId: option.unit?.id,
          quantity: Qty.one,
        ),
        note: note,
      ),
      onOk: _put,
    );
  }

  Future<Result<OpenBill>> _setQuantity((UuidValue, Qty) arg) =>
      _act(() => _repository.setItemQuantity(arg.$1, arg.$2), onOk: _put);

  Future<Result<OpenBill>> _markServed(UuidValue itemId) =>
      _act(() => _repository.markServed(itemId), onOk: _put);

  /// Tiket dapur terakhir yang dikirim (dialog 1.7e).
  KitchenSendResult? get lastTicket => _ticket;

  void clearTicket() {
    _ticket = null;
    _printFailure = null;
    _ticketPrinted = false;
    printTicket.clearResult();
    notifyListeners();
  }

  Future<Result<KitchenSendResult>> _send() {
    final id = _billId;
    if (id == null) return Future.value(Result.error(BillNotFound()));
    return _act(
      () => _repository.sendToKitchen(id),
      onOk: (r) {
        _put(r.bill);
        _ticket = r;
        _printFailure = null;
        _ticketPrinted = false;
      },
    );
  }

  Future<Result<OpenBill>> _requestBill(bool requested) {
    final id = _billId;
    if (id == null) return Future.value(Result.error(BillNotFound()));
    return _act(() => _repository.setBillRequested(id, requested), onOk: _put);
  }

  Future<Result<OpenBill>> _move(UuidValue tableId) {
    final id = _billId;
    if (id == null) return Future.value(Result.error(BillNotFound()));
    return _act(() => _repository.moveBill(id, tableId), onOk: _put);
  }

  Future<Result<void>> _void(String reason) async {
    final id = _billId;
    if (id == null) return Result.error(BillNotFound());
    final result = await _act(() => _repository.voidBill(id, reason));
    if (result is Ok) {
      _selectedId = null;
      await _reloadOverview();
    }
    return result;
  }

  Future<Result<void>> _deleteEmpty(UuidValue billId) async {
    final result = await _act(() => _repository.deleteEmptyBill(billId));
    if (result is Ok) {
      if (_selectedId == billId) _selectedId = null;
      await _reloadOverview();
    }
    return result;
  }

  // --- Tiket dapur -----------------------------------------------------------

  ReceiptPaper get paper => _data?.receipt.settings.paper ?? ReceiptPaper.mm58;

  PrinterFailureReason? get printFailure => _printFailure;
  bool get ticketPrinted => _ticketPrinted;

  Future<Result<void>> _printTicket(List<ReceiptLine> lines) async {
    _printFailure = null;
    _ticketPrinted = false;
    final printer =
        _data?.printer ??
        const PrinterSelection(kind: PrinterKind.system, name: '');
    try {
      await _printer.print(
        printer,
        lines,
        paper,
        jobName: _ticket == null
            ? 'Tiket dapur'
            : kitchenTicketLabel(_ticket!.ticket.number),
      );
      _ticketPrinted = printer.isDirect;
      return const Result.ok(null);
    } on PrinterFailure catch (e) {
      _printFailure = e.reason;
      return Result.error(e);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
