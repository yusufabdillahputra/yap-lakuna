import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/history_repository.dart';
import '../../data/services/receipt_printer.dart';
import '../../data/services/spreadsheet_exporter.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Void nota: alasan dan penyetuju (`null` = staf bertugas).
typedef SaleVoidRequest = ({String reason, UuidValue? approverId});

/// Layar Riwayat transaksi, void & retur (F1-11, 1.14).
class HistoryViewModel extends ChangeNotifier {
  HistoryViewModel({
    required this._repository,
    required this._printer,
    required this._exporter,
    UuidValue? initialSale,
  }) : _selectedId = initialSale {
    load = Command0(_load)..addListener(notifyListeners);
    submitReturn = Command0(_submitReturn)..addListener(notifyListeners);
    voidSale = Command1(_voidSale)..addListener(notifyListeners);
    printReceipt = Command1(_printReceipt)..addListener(notifyListeners);
    shareReceipt = Command1(_shareReceipt)..addListener(notifyListeners);
    export = Command1(_export)..addListener(notifyListeners);
  }

  final HistoryRepository _repository;
  final ReceiptPrinter _printer;
  final SpreadsheetExporter _exporter;

  late final Command0<void> load;
  late final Command0<SaleReturn> submitReturn;
  late final Command1<Sale, SaleVoidRequest> voidSale;
  late final Command1<void, List<ReceiptLine>> printReceipt;
  late final Command1<String?, List<ReceiptLine>> shareReceipt;
  late final Command1<String?, Uint8List> export;

  HistoryData? _data;
  HistoryPage? _page;
  var _filter = const HistoryFilter();
  UuidValue? _selectedId;
  SaleDetail? _detail;
  Exception? _error;
  Exception? _detailError;
  var _listing = false;
  var _loadingDetail = false;

  // Form retur.
  final _returnQty = <UuidValue, int>{};
  var _reason = SaleReturnReason.damaged;
  var _note = '';
  RefundMethod? _refund;
  bool? _restock;
  Exception? _returnError;

  // Struk & ekspor.
  PrinterFailureReason? _printFailure;
  var _printed = false;
  String? _pdfPath;
  String? _exportPath;

  /// Naik setiap form retur dikosongkan, dipakai sebagai kunci kolom teks
  /// agar isi lama tidak tertinggal.
  var _formGeneration = 0;

  HistoryData? get data => _data;
  HistoryPage? get page => _page;
  HistoryFilter get filter => _filter;
  UuidValue? get selectedId => _selectedId;
  SaleDetail? get detail => _detail;

  /// Galat memuat layar atau daftar.
  Exception? get error => _error;

  /// Galat memuat rincian nota terpilih.
  Exception? get detailError => _detailError;
  bool get listing => _listing;
  bool get loadingDetail => _loadingDetail;

  bool get canReturn => _data?.canReturn ?? false;

  /// Staf bertugas bisa void sendiri; tanpa izin ini butuh persetujuan.
  bool get canVoid => _data?.canVoid ?? false;

  /// Nota terpilih masih bisa diretur oleh staf ini.
  bool get returnable => canReturn && (_detail?.canReturn ?? false);

  /// Nota terpilih memenuhi syarat void (lepas dari izin staf).
  bool get voidable => _detail != null && _detail!.voidBlock == null;

  Future<Result<void>> _load() async {
    final data = await _repository.load();
    switch (data) {
      case Ok(:final value):
        _data = value;
      case Error(:final error):
        _error = error;
        return Result.error(error);
    }
    final listed = await _list();
    if (_selectedId case final id?) await _fetchDetail(id);
    return listed;
  }

  /// Memuat ulang daftar dan rincian (mis. setelah kembali dari halaman
  /// rincian di layar sempit).
  Future<void> refresh() async {
    await _list();
    if (_selectedId case final id?) await _fetchDetail(id);
  }

  Future<Result<void>> _list() async {
    _listing = true;
    notifyListeners();
    final filter = _filter;
    final result = await _repository.list(filter);
    // Filter berganti selama memuat: hasil lama dibuang.
    if (!identical(filter, _filter)) return const Result.ok(null);
    _listing = false;
    switch (result) {
      case Ok(:final value):
        _page = value;
        _error = null;
      case Error(:final error):
        _error = error;
    }
    notifyListeners();
    return result is Error<HistoryPage>
        ? Result.error(result.error)
        : const Result.ok(null);
  }

  void setFilter(HistoryFilter filter) {
    _filter = filter;
    unawaited(_list());
  }

  void select(UuidValue? saleId) {
    if (_selectedId == saleId && _detail != null) return;
    _selectedId = saleId;
    _detail = null;
    _resetForms();
    notifyListeners();
    if (saleId != null) unawaited(_fetchDetail(saleId));
  }

  Future<void> _fetchDetail(UuidValue id) async {
    _loadingDetail = true;
    _detailError = null;
    notifyListeners();
    final result = await _repository.detail(id);
    if (_selectedId != id) return;
    _loadingDetail = false;
    switch (result) {
      case Ok(:final value):
        _detail = value;
        for (final item in value.items) {
          final qty = _returnQty[item.id];
          if (qty != null && qty > value.remainingMilli(item)) {
            _returnQty.remove(item.id);
          }
        }
      case Error(:final error):
        _detail = null;
        _detailError = error;
    }
    notifyListeners();
  }

  void _resetForms() {
    _returnQty.clear();
    _reason = SaleReturnReason.damaged;
    _note = '';
    _refund = null;
    _restock = null;
    _returnError = null;
    _printFailure = null;
    _printed = false;
    _pdfPath = null;
    _formGeneration++;
    submitReturn.clearResult();
    voidSale.clearResult();
  }

  // --- Retur ---------------------------------------------------------------

  int returnQty(SaleItem item) => _returnQty[item.id] ?? 0;

  /// Jumlah retur baris [item], dibatasi sisa yang bisa diretur.
  void setReturnQty(SaleItem item, int milli) {
    final max = _detail?.remainingMilli(item) ?? 0;
    final value = milli.clamp(0, max);
    if (value == 0) {
      _returnQty.remove(item.id);
    } else {
      _returnQty[item.id] = value;
    }
    _returnError = null;
    notifyListeners();
  }

  /// Tambah/kurang satu satuan; sisa pecahan diambil utuh.
  void stepReturn(SaleItem item, int direction) {
    final current = returnQty(item);
    final max = _detail?.remainingMilli(item) ?? 0;
    if (direction > 0) {
      setReturnQty(item, current + 1000 > max ? max : current + 1000);
    } else {
      final down = current % 1000 == 0
          ? current - 1000
          : current - current % 1000;
      setReturnQty(item, down);
    }
  }

  /// Isi semua sisa baris.
  void returnAll() {
    final detail = _detail;
    if (detail == null) return;
    for (final item in detail.items) {
      final left = detail.remainingMilli(item);
      if (left > 0) _returnQty[item.id] = left;
    }
    _returnError = null;
    notifyListeners();
  }

  SaleReturnReason get reason => _reason;

  void setReason(SaleReturnReason reason) {
    _reason = reason;
    _returnError = null;
    notifyListeners();
  }

  String get note => _note;

  void setNote(String note) {
    _note = note;
    if (_returnError is ReturnInvalid) _returnError = null;
    notifyListeners();
  }

  /// Bagian retur yang memotong sisa piutang nota kredit (F1-13).
  Money get returnDebtCut {
    final outstanding = _detail?.outstanding ?? Money.zero;
    final total = returnTotal;
    return total < outstanding ? total : outstanding;
  }

  /// Uang yang dikembalikan setelah piutang dipotong.
  Money get returnRefund => returnTotal - returnDebtCut;

  /// Pilihan uang kembali tampil kecuali retur seluruhnya memotong piutang.
  bool get returnNeedsRefundMethod =>
      !(returnDebtCut > Money.zero && returnRefund == Money.zero);

  /// Uang kembali: tunai bawaan bila perangkat punya sesi terbuka; retur
  /// yang seluruhnya memotong piutang memakai `debt`.
  RefundMethod get refundMethod {
    if (!returnNeedsRefundMethod) return RefundMethod.debt;
    final chosen = _refund;
    if (chosen != null && chosen != RefundMethod.debt) return chosen;
    return (_data?.hasOpenSession ?? false)
        ? RefundMethod.cash
        : RefundMethod.transfer;
  }

  bool get cashRefundAvailable => _data?.hasOpenSession ?? false;

  void setRefundMethod(RefundMethod method) {
    _refund = method;
    _returnError = null;
    notifyListeners();
  }

  /// Kembalikan ke stok: bawaan mengikuti alasan sampai diubah.
  bool get restock => _restock ?? restockByDefault(returnReasonKind(_reason));

  void setRestock(bool value) {
    _restock = value;
    notifyListeners();
  }

  /// Nilai retur yang sedang diisi.
  Money get returnTotal {
    final detail = _detail;
    if (detail == null) return Money.zero;
    var total = Money.zero;
    for (final item in detail.items) {
      final qty = returnQty(item);
      if (qty > 0 && qty <= detail.remainingMilli(item)) {
        total += detail.returnValue(item, qty);
      }
    }
    return total;
  }

  bool get hasReturnLines => _returnQty.values.any((q) => q > 0);

  Exception? get returnError => _returnError;

  Future<Result<SaleReturn>> _submitReturn() async {
    final detail = _detail;
    if (detail == null) return Result.error(SaleNotFound());
    final lines = [
      for (final item in detail.items)
        if (returnQty(item) > 0)
          ReturnLine(saleItemId: item.id, quantity: Qty(returnQty(item))),
    ];
    final result = await _repository.returnSale(
      saleId: detail.sale.id,
      lines: lines,
      reason: _reason,
      note: _note.trim().isEmpty ? null : _note.trim(),
      refundMethod: refundMethod,
      restock: restock,
    );
    switch (result) {
      case Ok():
        final id = detail.sale.id;
        _resetForms();
        await _list();
        await _fetchDetail(id);
      case Error(:final error):
        _returnError = error;
    }
    return result;
  }

  // --- Void ----------------------------------------------------------------

  Future<Result<Sale>> _voidSale(SaleVoidRequest request) async {
    final detail = _detail;
    if (detail == null) return Result.error(SaleNotFound());
    final result = await _repository.voidSale(
      saleId: detail.sale.id,
      reason: request.reason,
      approverId: request.approverId,
    );
    if (result is Ok) {
      await _list();
      await _fetchDetail(detail.sale.id);
    }
    return result;
  }

  // --- Struk ---------------------------------------------------------------

  ReceiptPaper get paper => _data?.receipt.settings.paper ?? ReceiptPaper.mm58;

  /// Logo struk saat ini (F1-06b), `null` bila tidak ditampilkan.
  Uint8List? get receiptLogo => _data?.receipt.logoBytes;
  PrinterFailureReason? get printFailure => _printFailure;
  bool get printed => _printed;

  /// Lokasi PDF struk yang disimpan di desktop.
  String? get pdfPath => _pdfPath;

  /// Lokasi berkas Excel yang disimpan di desktop.
  String? get exportPath => _exportPath;

  int get formGeneration => _formGeneration;

  Future<Result<void>> _printReceipt(List<ReceiptLine> lines) async {
    _printFailure = null;
    _printed = false;
    final printer =
        _data?.printer ??
        const PrinterSelection(kind: PrinterKind.system, name: '');
    try {
      await _printer.print(
        printer,
        lines,
        paper,
        jobName: _detail?.sale.number ?? 'Lakuna',
        logo: receiptLogo,
      );
      _printed = printer.isDirect;
      return const Result.ok(null);
    } on PrinterFailure catch (e) {
      _printFailure = e.reason;
      return Result.error(e);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<String?>> _shareReceipt(List<ReceiptLine> lines) async {
    _pdfPath = null;
    try {
      final path = await _printer.sharePdf(
        lines,
        paper,
        fileName: '${_detail?.sale.number ?? 'struk'}.pdf',
        logo: receiptLogo,
      );
      _pdfPath = path;
      return Result.ok(path);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  // --- Ekspor --------------------------------------------------------------

  /// Nama berkas ekspor: `riwayat-<rentang>-<yymmdd>.xlsx`.
  String exportFileName(DateTime now) {
    String two(int n) => n.toString().padLeft(2, '0');
    final date = '${two(now.year % 100)}${two(now.month)}${two(now.day)}';
    final range = switch (_filter.range) {
      HistoryRange.today => 'hari-ini',
      HistoryRange.yesterday => 'kemarin',
      HistoryRange.week => '7-hari',
    };
    return 'riwayat-$range-$date.xlsx';
  }

  Future<Result<String?>> _export(Uint8List bytes) async {
    _exportPath = null;
    try {
      final tz = _data?.timezone;
      final path = await _exporter.save(
        bytes,
        fileName: exportFileName(outletLocalTime(DateTime.now().toUtc(), tz)),
      );
      _exportPath = path;
      return Result.ok(path);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  void dispose() {
    load.dispose();
    submitReturn.dispose();
    voidSale.dispose();
    printReceipt.dispose();
    shareReceipt.dispose();
    export.dispose();
    super.dispose();
  }
}
