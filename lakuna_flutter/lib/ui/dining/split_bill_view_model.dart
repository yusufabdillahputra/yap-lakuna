import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/dining_repository.dart';
import '../../data/services/receipt_printer.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';
import '../receipt/bill_print_job.dart';

/// View model layar split bill 1.9 (F1-10c).
class SplitBillViewModel extends ChangeNotifier {
  SplitBillViewModel({
    required this._repository,
    required ReceiptPrinter printer,
    required this.billId,
  }) {
    partPrint = BillPrintJob(
      printer: printer,
      selection: () => _data?.printer,
      paper: () => paper,
      logo: () => receiptLogo,
      jobName: () => [
        'tagihan',
        _bill?.sale.billNumber ?? _bill?.sale.number ?? 'bill',
        ?_printGuest,
      ].join('-'),
    )..addListener(notifyListeners);
    load = Command0(_load)..addListener(notifyListeners);
    setMode = Command1(_setMode)..addListener(notifyListeners);
    setGuests = Command1(_setGuests)..addListener(notifyListeners);
    assign = Command1(_assign)..addListener(notifyListeners);
    confirm = Command1(_confirm)..addListener(notifyListeners);
    cancel = Command1(_cancel)..addListener(notifyListeners);
  }

  final DiningRepository _repository;
  final UuidValue billId;

  late final Command0<SplitBillData> load;

  /// Mode split; `null` membatalkan split.
  late final Command1<OpenBill, SplitMode?> setMode;
  late final Command1<OpenBill, int> setGuests;

  /// (item, tamu) — satu porsi; tamu `null` = kembali ke belum dibagi.
  late final Command1<OpenBill, (UuidValue, String?)> assign;

  /// *Sudah Terbayar* pembayaran menunggu [UuidValue].
  late final Command1<SplitPayResult, UuidValue> confirm;
  late final Command1<OpenBill, UuidValue> cancel;

  /// Cetak / PDF tagihan satu tamu (F1-10m).
  late final BillPrintJob partPrint;

  SplitBillData? _data;
  OpenBill? _bill;
  CheckoutResult? _completed;
  Exception? _error;
  Money _amount = Money.zero;

  /// Tamu di dialog tagihan yang sedang terbuka (nama job cetak).
  String? _printGuest;
  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    partPrint.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  bool get loaded => _bill != null;
  OpenBill? get bill => _bill;
  BillSplit? get split => _bill?.split;
  SplitMode? get mode => _bill?.sale.splitMode;
  bool get canPay => _data?.canPay ?? false;
  bool get canConfirm => _data?.canConfirm ?? false;

  /// Bill lunas lewat *Sudah Terbayar* di layar ini.
  CheckoutResult? get completed => _completed;

  /// Galat aksi terakhir.
  Exception? get error => _error;

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  /// Jumlah tamu: tersimpan, atau jumlah tamu bill (2–8).
  int get guests =>
      _bill?.sale.splitGuests ??
      SplitLimits.clampGuests(_bill?.sale.guestCount ?? 2);

  bool get locked => split?.locked ?? false;

  bool get busy =>
      setMode.running ||
      setGuests.running ||
      assign.running ||
      confirm.running ||
      cancel.running;

  bool get canEdit => loaded && !locked && !busy;
  bool get canAddGuest =>
      canEdit && mode != SplitMode.amount && guests < SplitLimits.maxGuests;
  bool get canRemoveGuest =>
      canEdit && mode != SplitMode.amount && guests > SplitLimits.minGuests;

  List<SaleItem> get unassigned => split?.unassigned ?? const [];

  /// *Bayar bagian X* aktif.
  bool canPayPart(GuestPart part) =>
      canPay &&
      !busy &&
      part.payments.isEmpty &&
      unassigned.isEmpty &&
      (part.due ?? Money.zero) > Money.zero;

  // --- Tagihan per tamu (F1-10m) ----------------------------------------------

  /// Konteks struk (nama usaha, cabang, kasir, zona, pengaturan struk).
  SplitBillData? get data => _data;

  ReceiptPaper get paper => _data?.receipt.settings.paper ?? ReceiptPaper.mm58;

  /// Logo struk (F1-06b), `null` bila tidak ditampilkan.
  Uint8List? get receiptLogo => _data?.receipt.logoBytes;

  /// *Cetak tagihan* tamu aktif: mode per item (tanpa porsi tanpa tamu)
  /// atau rata, tamu belum punya pembayaran, dan tagihannya > 0. Tidak
  /// butuh izin bayar.
  bool canPrintPart(GuestPart part) {
    final s = split;
    return s != null &&
        s.mode != SplitKind.amount &&
        (s.mode != SplitKind.item || s.unassigned.isEmpty) &&
        part.payments.isEmpty &&
        (part.due ?? Money.zero) > Money.zero;
  }

  /// Dialog tagihan tamu [guest] dibuka: hasil cetak sebelumnya dihapus.
  void openPartPrint(String guest) {
    _printGuest = guest;
    partPrint.reset();
  }

  // --- Nominal bebas ---------------------------------------------------------

  Money get amount => _amount;

  void setAmount(Money value) {
    _amount = value;
    notifyListeners();
  }

  bool get canPayAmount {
    final s = split;
    return canPay &&
        !busy &&
        s != null &&
        s.mode == SplitKind.amount &&
        s.next != null &&
        _amount > Money.zero &&
        _amount <= s.remaining &&
        // Tamu ke-8 (terakhir) wajib melunasi sisa.
        (guestIndex(s.next!.label) != SplitLimits.maxGuests - 1 ||
            _amount == s.remaining);
  }

  // --- Aksi -----------------------------------------------------------------

  Future<Result<SplitBillData>> _load() async {
    final result = await _repository.loadSplit(billId);
    if (result case Ok(:final value)) {
      _data = value;
      _bill = value.bill;
    }
    return result;
  }

  Future<Result<T>> _act<T>(
    Future<Result<T>> Function() action,
    void Function(T value) apply,
  ) async {
    _error = null;
    final result = await action();
    switch (result) {
      case Ok(:final value):
        apply(value);
      case Error(:final error):
        _error = error;
    }
    return result;
  }

  void _setBill(OpenBill b) => _bill = b;

  Future<Result<OpenBill>> _setMode(SplitMode? m) => _act(
    () => _repository.setSplit(billId, m, guests),
    (b) {
      _bill = b;
      _amount = Money.zero;
    },
  );

  Future<Result<OpenBill>> _setGuests(int n) =>
      _act(() => _repository.setSplit(billId, mode, n), _setBill);

  Future<Result<OpenBill>> _assign((UuidValue, String?) a) =>
      _act(() => _repository.assignPortion(a.$1, a.$2), _setBill);

  Future<Result<SplitPayResult>> _confirm(UuidValue paymentId) => _act(
    () => _repository.confirmSplitPayment(paymentId),
    (r) {
      if (r.bill case final b?) _bill = b;
      _completed = r.receipt;
    },
  );

  Future<Result<OpenBill>> _cancel(UuidValue paymentId) =>
      _act(() => _repository.cancelSplitPayment(paymentId), _setBill);
}
