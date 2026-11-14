import 'dart:async';

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

/// Tampilan dine in: kotak berurutan atau denah (1.7b).
enum DiningLayout { grid, floor }

/// Status meja di grid 1.7 (dihitung dari bill terbuka).
enum TableState { empty, open, billRequested }

/// Item yang ditambahkan dari lembar menu atau sheet modifier 1.8.
@immutable
class BillItemInput {
  const BillItemInput(
    this.option, {
    this.note,
    this.quantity = Qty.one,
    this.modifierIds = const [],
  });

  final SaleOption option;

  /// Catatan dapur; kosong = tanpa catatan.
  final String? note;
  final Qty quantity;

  /// Opsi modifier terpilih (urut grup).
  final List<UuidValue> modifierIds;
}

/// *Batalkan bill*: alasan dan penyetuju (F1-11; `null` = staf bertugas).
typedef BillVoid = ({String reason, UuidValue? approverId});

/// Diskon nota bill (F1-04e): `discount` `null` = hapus; `approverId`
/// penyetuju PIN manajer (`null` = staf bertugas berizin).
typedef BillDiscountChange = ({
  ManualDiscount? discount,
  UuidValue? approverId,
});

/// Diskon baris item bill (F1-04g): `discount` `null` = hapus.
typedef BillItemDiscountChange = ({
  UuidValue itemId,
  ManualDiscount? discount,
  UuidValue? approverId,
});

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
    merge = Command1(_merge)..addListener(notifyListeners);
    customers = Command0(_loadCustomers)..addListener(notifyListeners);
    setCustomer = Command1(_setCustomer)..addListener(notifyListeners);
    voidBill = Command1(_void)..addListener(notifyListeners);
    deleteEmpty = Command1(_deleteEmpty)..addListener(notifyListeners);
    printTicket = Command1(_printTicket)..addListener(notifyListeners);
    printBarTicket = Command1(_printBarTicket)..addListener(notifyListeners);
    setDiscount = Command1(_setDiscount)..addListener(notifyListeners);
    setItemDiscount = Command1(_setItemDiscount)..addListener(notifyListeners);
  }

  final DiningRepository _repository;
  final ReceiptPrinter _printer;

  late final Command0<DiningData> load;

  /// (meja, jumlah tamu).
  late final Command1<OpenBill, (UuidValue, int)> openTable;

  /// Nama pemesan opsional.
  late final Command1<OpenBill, String?> openTakeAway;

  late final Command1<OpenBill, BillItemInput> addItem;

  /// (item, jumlah baru); nol menghapus item *Baru*.
  late final Command1<OpenBill, (UuidValue, Qty)> setQuantity;
  late final Command1<OpenBill, UuidValue> markServed;
  late final Command0<KitchenSendResult> send;
  late final Command1<OpenBill, bool> requestBill;

  /// Meja tujuan.
  late final Command1<OpenBill, UuidValue> move;

  /// *Gabung meja* (F1-10d): argumen = bill sumber; tujuan = bill terpilih.
  late final Command1<OpenBill, UuidValue> merge;

  /// Daftar pelanggan untuk pemilih *Pelanggan* bill (F1-10f).
  late final Command0<void> customers;

  /// Memilih atau (`null`) menghapus pelanggan bill terpilih.
  late final Command1<OpenBill, UuidValue?> setCustomer;

  /// Alasan batal dan penyetuju (F1-11; `null` = staf bertugas).
  late final Command1<void, BillVoid> voidBill;
  late final Command1<void, UuidValue> deleteEmpty;
  late final Command1<void, List<ReceiptLine>> printTicket;

  /// Cetak (ulang) tiket bar ke printer bar (F1-10j).
  late final Command1<void, List<ReceiptLine>> printBarTicket;

  /// Terapkan / hapus diskon nota bill terpilih (F1-04e).
  late final Command1<OpenBill, BillDiscountChange> setDiscount;

  /// Terapkan / hapus diskon baris item bill terpilih (F1-04g).
  late final Command1<OpenBill, BillItemDiscountChange> setItemDiscount;

  DiningData? _data;
  DiningMode _mode = DiningMode.dineIn;
  UuidValue? _areaId;
  DiningLayout? _layout;
  UuidValue? _floorAreaId;
  UuidValue? _selectedId;
  KitchenSendResult? _ticket;

  /// Bagian tiket per stasiun (F1-10j); dapur `null` bila semua item ke
  /// bar, bar `null` tanpa item bar.
  KitchenSendResult? _kitchenPart;
  KitchenSendResult? _barPart;
  Exception? _actionError;
  PrinterFailureReason? _printFailure;
  var _ticketPrinted = false;
  PrinterFailureReason? _barPrintFailure;
  var _barTicketPrinted = false;
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

  /// Grup modifier menu [p] (urut 1.16b); kosong = langsung masuk bill.
  List<ModifierGroupDetail> modifierGroupsOf(CatalogProduct p) =>
      _data?.groupsOf(p) ?? const [];
  bool get canVoid => _data?.canVoid ?? false;
  String get staffName => _data?.staffName ?? '';

  /// Tombol *Diskon* tampil: staf berizin, atau sakelar PIN manajer hidup.
  bool get canOfferDiscount => _data?.canOfferDiscount ?? false;

  /// Staf bertugas tanpa `sales:discount`: perlu PIN manajer.
  bool get discountNeedsApproval => !(_data?.canDiscount ?? false);

  /// Galat diskon nota [discount] untuk bill terpilih; `null` bila sah.
  /// Total setelah diskon, service, PB1, dan pembulatan harus > 0.
  DiscountIssue? billDiscountIssue(ManualDiscount discount) {
    final bill = selectedBill;
    if (bill == null) return DiscountIssue.invalid;
    final subtotal = bill.charges.subtotal;
    final issue = discount.issue(subtotal);
    if (issue != null) return issue;
    final after = fnbCharges(
      subtotal,
      dineIn: !bill.isTakeAway,
      serviceBp: bill.rates.service,
      taxBp: bill.rates.tax,
      taxInclusive: bill.rates.taxInclusive,
      rounding: bill.rates.rounding,
      discount: discount,
    );
    return after.total <= Money.zero ? DiscountIssue.tooLarge : null;
  }

  /// Galat diskon baris [discount] untuk [item] bill terpilih; `null` bila
  /// sah. Dasar = total baris sebelum diskon baris; total bill setelah
  /// semua diskon harus > 0.
  DiscountIssue? itemDiscountIssue(SaleItem item, ManualDiscount discount) {
    final bill = selectedBill;
    if (bill == null) return DiscountIssue.invalid;
    final gross = Money(item.lineTotal + item.discountAmount);
    final issue = discount.issue(gross);
    if (issue != null) return issue;
    final subtotal =
        bill.charges.subtotal -
        Money(item.lineTotal) +
        gross -
        discount.cut(gross);
    final after = fnbCharges(
      subtotal,
      dineIn: !bill.isTakeAway,
      serviceBp: bill.rates.service,
      taxBp: bill.rates.tax,
      taxInclusive: bill.rates.taxInclusive,
      rounding: bill.rates.rounding,
      discount: bill.discount,
    );
    return after.total <= Money.zero ? DiscountIssue.tooLarge : null;
  }

  /// Diskon menghabiskan total bill terpilih (item berkurang): bayar ditolak
  /// sampai diskon diubah.
  bool get discountBlocksPay => switch (selectedBill) {
    final b? =>
      (b.charges.discount > Money.zero ||
              b.items.any((i) => billItemDiscountOf(i) != null)) &&
          b.charges.total <= Money.zero,
    null => false,
  };
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
      // Bawaan Denah bila ada area mode denah; pilihan diingat.
      if (floorAreas.isEmpty) {
        _layout = null;
      } else {
        _layout ??= DiningLayout.floor;
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

  /// Membuang bill [id] dari ringkasan (mis. sumber *Gabung meja*).
  void _remove(UuidValue id) {
    final o = _overview;
    if (o == null) return;
    _data = _data!.withOverview(
      DiningOverview(
        areas: o.areas,
        tables: o.tables,
        bills: [
          for (final b in o.bills)
            if (b.id != id) b,
        ],
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
    _servedOnly = 0;
    final selected = selectedBill;
    if (selected != null && selected.isTakeAway != (m == DiningMode.takeAway)) {
      _selectedId = null;
    }
    notifyListeners();
  }

  // --- Denah (1.7b) ----------------------------------------------------------

  /// Area mode denah, urut master.
  List<DiningArea> get floorAreas => [
    for (final a in areas)
      if (a.layoutMode == DiningLayoutMode.floor) a,
  ];

  /// Pilihan Grid / Denah tampil (ada area mode denah).
  bool get hasFloor => floorAreas.isNotEmpty;

  DiningLayout get layout =>
      hasFloor ? _layout ?? DiningLayout.floor : DiningLayout.grid;

  void setLayout(DiningLayout l) {
    if (layout == l) return;
    _layout = l;
    notifyListeners();
  }

  /// Area denah yang tampil.
  DiningArea? get floorArea =>
      floorAreas.where((a) => a.id == _floorAreaId).firstOrNull ??
      floorAreas.firstOrNull;

  void setFloorArea(UuidValue id) {
    _floorAreaId = id;
    notifyListeners();
  }

  FloorImage? floorImage(DiningArea area) => _data?.floorImages[area.id];

  /// Meja area [area] yang sudah / belum punya posisi.
  List<DiningTable> floorTables(DiningArea area, {required bool placed}) => [
    for (final t in tables)
      if (t.diningAreaId == area.id && (t.posX != null) == placed) t,
  ];

  /// Boleh *Atur denah* (`settings:manage`).
  bool get canArrange => _data?.canArrange ?? false;

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
    _servedOnly = 0;
    notifyListeners();
  }

  void clearSelection() {
    _selectedId = null;
    _actionError = null;
    _servedOnly = 0;
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

  bool _tableCanMerge(UuidValue? id) =>
      id != null && tables.any((t) => t.id == id && t.canMerge);

  /// [bill] dine in di meja *Boleh digabung*: aksi *Gabung meja* tampil.
  bool canMergeInto(OpenBill bill) =>
      !bill.isTakeAway && _tableCanMerge(bill.sale.diningTableId);

  /// [bill] tidak sedang di-split dan belum punya pembayaran bagian.
  static bool _unsplit(OpenBill bill) =>
      bill.sale.splitMode == null && bill.payments.isEmpty;

  /// Aksi *Gabung meja* aktif: bill ini tidak sedang di-split.
  bool canMergeNow(OpenBill bill) => canMergeInto(bill) && _unsplit(bill);

  /// Bill dine in lain di meja *Boleh digabung* yang bisa digabung ke
  /// [bill], urut meja; bill yang di-split atau berdiskon nota tidak
  /// ditawarkan (akan ditolak).
  List<OpenBill> mergeSources(OpenBill bill) => [
    for (final t in tables)
      if (t.canMerge)
        if (billFor(t) case final b?
            when b.id != bill.id &&
                _unsplit(b) &&
                b.discount == null &&
                _sameCustomer(bill, b))
          b,
  ];

  /// Bill dengan pelanggan berbeda tidak bisa digabung (F1-10f); pelanggan
  /// yang sudah dihapus dianggap tanpa pelanggan.
  static bool _sameCustomer(OpenBill a, OpenBill b) =>
      a.customer == null ||
      b.customer == null ||
      a.customer!.id == b.customer!.id;

  // --- Pelanggan bill (F1-10f) ----------------------------------------------

  CustomersOverview? _customerList;
  var _customerQuery = '';

  /// Daftar pelanggan termuat; `null` sebelum [customers] berhasil.
  CustomersOverview? get customerList => _customerList;
  String get customerQuery => _customerQuery;

  void setCustomerQuery(String q) {
    _customerQuery = q;
    notifyListeners();
  }

  /// Pelanggan yang cocok dengan [customerQuery] (nama atau nomor HP),
  /// urut nama.
  List<CustomerRow> get customerCandidates {
    final q = _customerQuery.trim().toLowerCase();
    final digits = q.replaceAll(RegExp(r'\D'), '');
    return [
      for (final r in _customerList?.rows ?? const <CustomerRow>[])
        if (q.isEmpty ||
            r.customer.name.toLowerCase().contains(q) ||
            (digits.isNotEmpty && (r.customer.phone ?? '').contains(digits)))
          r,
    ]..sort(
      (a, b) => a.customer.name.toLowerCase().compareTo(
        b.customer.name.toLowerCase(),
      ),
    );
  }

  /// Pelanggan bill bisa diubah: tidak sedang di-split.
  bool canSetCustomer(OpenBill bill) => _unsplit(bill);

  Future<Result<void>> _loadCustomers() async {
    _customerQuery = '';
    final result = await _repository.customers();
    if (result case Ok(:final value)) _customerList = value;
    return result;
  }

  Future<Result<OpenBill>> _setCustomer(UuidValue? customerId) {
    final id = _billId;
    if (id == null) return Future.value(Result.error(BillNotFound()));
    return _act(
      () => _repository.setBillCustomer(id, customerId),
      onOk: (bill) {
        _put(bill);
        _customerQuery = '';
      },
    );
  }

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
      merge.running ||
      setCustomer.running ||
      voidBill.running ||
      deleteEmpty.running ||
      setDiscount.running ||
      setItemDiscount.running;

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
    _servedOnly = 0;
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

  Future<Result<OpenBill>> _addItem(BillItemInput input) {
    final id = _billId;
    if (id == null) return Future.value(Result.error(BillNotFound()));
    final note = input.note?.trim() ?? '';
    return _act(
      () => _repository.addItem(
        id,
        SaleLineRequest(
          variantId: input.option.variant.id,
          productUnitId: input.option.unit?.id,
          quantity: input.quantity,
        ),
        note: note.isEmpty ? null : note,
        modifierIds: input.modifierIds,
      ),
      onOk: _put,
    );
  }

  Future<Result<OpenBill>> _setQuantity((UuidValue, Qty) arg) =>
      _act(() => _repository.setItemQuantity(arg.$1, arg.$2), onOk: _put);

  Future<Result<OpenBill>> _markServed(UuidValue itemId) =>
      _act(() => _repository.markServed(itemId), onOk: _put);

  /// Tiket dapur terakhir yang dikirim (dialog 1.7e); hanya hasil kirim
  /// yang punya tiket.
  KitchenSendResult? get lastTicket => _ticket;

  var _servedOnly = 0;

  /// Jumlah item menu tanpa tiket dapur yang langsung disajikan pada
  /// *Kirim ke dapur* terakhir bill ini (F1-10g); 0 setelah aksi lain.
  int get servedWithoutTicket => _servedOnly;

  void clearTicket() {
    _ticket = null;
    _kitchenPart = null;
    _barPart = null;
    _printFailure = null;
    _ticketPrinted = false;
    _autoPrintStarted = false;
    _barPrintFailure = null;
    _barTicketPrinted = false;
    _barAutoPrintStarted = false;
    printTicket.clearResult();
    printBarTicket.clearResult();
    notifyListeners();
  }

  Future<Result<KitchenSendResult>> _send() {
    final id = _billId;
    if (id == null) return Future.value(Result.error(BillNotFound()));
    return _act(
      () => _repository.sendToKitchen(id),
      onOk: (r) {
        _put(r.bill);
        _servedOnly = r.served.length;
        // Semua item bukan menu dapur: tidak ada tiket untuk ditampilkan.
        if (r.ticket == null) return;
        _ticket = r;
        final (kitchen, bar) = _splitTicket(r);
        _kitchenPart = kitchen;
        _barPart = bar;
        _printFailure = null;
        _ticketPrinted = false;
        _autoPrintStarted = false;
        _barPrintFailure = null;
        _barTicketPrinted = false;
        _barAutoPrintStarted = false;
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

  Future<Result<OpenBill>> _merge(UuidValue sourceId) async {
    final id = _billId;
    if (id == null) return Result.error(BillNotFound());
    final result = await _act(() => _repository.mergeBill(id, sourceId));
    if (result case Ok(:final value)) {
      _remove(sourceId);
      await _reloadOverview();
      _put(value);
      _selectedId = value.id;
    }
    return result;
  }

  Future<Result<void>> _void(BillVoid request) async {
    final id = _billId;
    if (id == null) return Result.error(BillNotFound());
    final result = await _act(
      () => _repository.voidBill(
        id,
        request.reason,
        approverId: request.approverId,
      ),
    );
    if (result is Ok) {
      _selectedId = null;
      await _reloadOverview();
    }
    return result;
  }

  Future<Result<OpenBill>> _setDiscount(BillDiscountChange change) {
    final id = _billId;
    if (id == null) return Future.value(Result.error(BillNotFound()));
    return _act(
      () => _repository.setDiscount(
        id,
        change.discount,
        approverId: change.approverId,
      ),
      onOk: _put,
    );
  }

  Future<Result<OpenBill>> _setItemDiscount(BillItemDiscountChange change) =>
      _act(
        () => _repository.setItemDiscount(
          change.itemId,
          change.discount,
          approverId: change.approverId,
        ),
        onOk: _put,
      );

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

  /// Printer dapur khusus perangkat ini (F1-10e).
  KitchenPrinter? get _kitchenPrinter => _data?.kitchenPrinter;

  /// Tiket dikirim ke printer dapur khusus (bukan printer struk).
  bool get ticketToKitchen => _kitchenPrinter != null;

  /// Lebar kertas tiket: kertas dapur, atau kertas struk tanpa printer
  /// dapur.
  ReceiptPaper get ticketPaper => _kitchenPrinter?.paper ?? paper;

  var _autoPrintStarted = false;

  /// Tiket terakhir belum dicetak otomatis ke printer dapur.
  bool get shouldAutoPrintTicket =>
      _kitchenPart != null && ticketToKitchen && !_autoPrintStarted;

  /// Cetak otomatis tiket [lines] ke printer dapur, sekali per tiket.
  ///
  /// Bila cetak tiket sebelumnya masih berjalan (printer lambat), tiket ini
  /// menunggu lalu dicetak, agar tidak ada tiket yang terlewat.
  Future<void> autoPrintTicket(List<ReceiptLine> lines) async {
    if (!shouldAutoPrintTicket) return;
    _autoPrintStarted = true;
    final ticket = _ticket;
    await _idle(printTicket);
    // Tetap dicetak walau modal sudah ditutup: tiket tidak boleh hilang.
    _jobTicket = ticket;
    await printTicket.execute(lines);
  }

  /// Tiket milik cetak antrean berikutnya (bisa sudah bukan [lastTicket]).
  KitchenSendResult? _jobTicket;
  KitchenSendResult? _barJobTicket;

  /// Tunggu sampai [command] tidak berjalan.
  static Future<void> _idle(Command1<void, List<ReceiptLine>> command) async {
    while (command.running) {
      final idle = Completer<void>();
      void check() {
        if (!command.running && !idle.isCompleted) idle.complete();
      }

      command.addListener(check);
      await idle.future;
      command.removeListener(check);
    }
  }

  /// Bagian tiket dapur dari kiriman terakhir; `null` bila semua item ke
  /// bar (F1-10j). Tanpa printer bar sama dengan [lastTicket].
  KitchenSendResult? get kitchenTicket => _kitchenPart;

  /// Bagian tiket bar dari kiriman terakhir (F1-10j).
  KitchenSendResult? get barTicket => _barPart;

  /// Printer bar aktif (printer + minimal satu kategori).
  KitchenPrinter? get _barPrinter => switch (_data?.barPrinter) {
    final bar? when bar.routesBar => bar,
    _ => null,
  };

  /// Lebar kertas tiket bar.
  ReceiptPaper get barPaper => _data?.barPrinter?.paper ?? paper;

  (KitchenSendResult?, KitchenSendResult?) _splitTicket(KitchenSendResult r) {
    final bar = _barPrinter;
    final data = _data;
    if (bar == null || data == null) return (r, null);
    final split = splitBarItems(
      r.items,
      variantCategories: {
        for (final p in data.products)
          for (final v in p.variants) v.id: p.categoryId,
      },
      categoryParents: data.categoryParents,
      barCategories: bar.categoryIds,
    );
    KitchenSendResult part(List<SaleItem> items) => KitchenSendResult(
      ticket: r.ticket,
      items: items,
      bill: r.bill,
      served: r.served,
      staffName: r.staffName,
    );
    if (split.bar.isEmpty) return (r, null);
    return (
      split.kitchen.isEmpty ? null : part(split.kitchen),
      part(split.bar),
    );
  }

  var _barAutoPrintStarted = false;

  /// Tiket bar terakhir belum dicetak otomatis.
  bool get shouldAutoPrintBar => _barPart != null && !_barAutoPrintStarted;

  /// Cetak otomatis tiket bar [lines] sekali per tiket; menunggu cetak bar
  /// sebelumnya seperti [autoPrintTicket].
  Future<void> autoPrintBar(List<ReceiptLine> lines) async {
    if (!shouldAutoPrintBar) return;
    _barAutoPrintStarted = true;
    final ticket = _ticket;
    await _idle(printBarTicket);
    _barJobTicket = ticket;
    await printBarTicket.execute(lines);
  }

  PrinterFailureReason? get barPrintFailure => _barPrintFailure;
  bool get barTicketPrinted => _barTicketPrinted;

  Future<Result<void>> _printBarTicket(List<ReceiptLine> lines) async {
    final ticket = _barJobTicket ?? _ticket;
    _barJobTicket = null;
    if (identical(_ticket, ticket)) {
      _barPrintFailure = null;
      _barTicketPrinted = false;
    }
    final bar = _data?.barPrinter;
    if (bar == null) return const Result.ok(null);
    try {
      await _printer.print(
        bar.printer,
        lines,
        bar.paper,
        jobName: '${kitchenTicketLabel(ticket?.ticket?.number ?? 0)} bar',
      );
      if (identical(_ticket, ticket)) _barTicketPrinted = true;
      return const Result.ok(null);
    } on PrinterFailure catch (e) {
      if (identical(_ticket, ticket)) _barPrintFailure = e.reason;
      return Result.error(e);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  PrinterFailureReason? get printFailure => _printFailure;
  bool get ticketPrinted => _ticketPrinted;

  Future<Result<void>> _printTicket(List<ReceiptLine> lines) async {
    // Hasil cetak hanya berlaku untuk tiket yang sedang tampil.
    final ticket = _jobTicket ?? _ticket;
    _jobTicket = null;
    if (identical(_ticket, ticket)) {
      _printFailure = null;
      _ticketPrinted = false;
    }
    final printer =
        _kitchenPrinter?.printer ??
        _data?.printer ??
        const PrinterSelection(kind: PrinterKind.system, name: '');
    try {
      await _printer.print(
        printer,
        lines,
        ticketPaper,
        jobName: ticket == null
            ? 'Tiket dapur'
            : kitchenTicketLabel(ticket.ticket?.number ?? 0),
      );
      if (identical(_ticket, ticket)) _ticketPrinted = printer.isDirect;
      return const Result.ok(null);
    } on PrinterFailure catch (e) {
      if (identical(_ticket, ticket)) _printFailure = e.reason;
      return Result.error(e);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
