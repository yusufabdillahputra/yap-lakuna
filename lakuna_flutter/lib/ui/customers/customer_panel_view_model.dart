import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/customers_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Metode terima pembayaran piutang, urut tampilan.
const debtPaymentMethodOrder = [
  PaymentMethod.cash,
  PaymentMethod.transfer,
  PaymentMethod.qrisStatic,
];

/// Panel satu pelanggan (1.20): ringkasan limit, nota belum lunas, terima
/// pembayaran dengan alokasi otomatis atau manual, dan riwayat bayar.
class CustomerPanelViewModel extends ChangeNotifier {
  CustomerPanelViewModel({
    required this._repository,
    required this.customerId,
  }) {
    load = Command0(_load)..addListener(notifyListeners);
    receive = Command0(_receive)..addListener(notifyListeners);
    delete = Command0(_delete)..addListener(notifyListeners);
    voidPayment = Command1(_voidPayment)..addListener(notifyListeners);
  }

  final CustomersRepository _repository;
  final UuidValue customerId;

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    load.dispose();
    receive.dispose();
    delete.dispose();
    voidPayment.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  late final Command0<void> load;

  /// Hasil = pembayaran tersimpan (untuk membuka kuitansi).
  late final Command0<DebtPayment> receive;
  late final Command0<void> delete;

  /// Batal pembayaran (F1-13c): argumen = (id pembayaran, alasan).
  late final Command1<DebtPayment, (UuidValue, String)> voidPayment;

  CustomersSetup? _setup;
  CustomerDetail? _detail;
  Exception? _error;

  var _amount = Money.zero;
  var _method = PaymentMethod.cash;
  DateTime? _paidOn;
  var _manual = false;
  final _allocations = <UuidValue, Money>{};
  var _note = '';
  var _submitted = false;
  var _generation = 0;

  CustomersSetup? get setup => _setup;
  CustomerDetail? get detail => _detail;
  Exception? get error => _error;
  Money get amount => _amount;
  PaymentMethod get method => _method;
  DateTime get paidOn => _paidOn ?? _detail?.today ?? DateTime.now();
  bool get manual => _manual;
  String get note => _note;

  /// Naik saat isian dikosongkan agar field dibuat ulang.
  int get generation => _generation;

  bool get canReceive => _setup?.canReceive ?? false;
  bool get canManage => _setup?.canManage ?? false;
  bool get hasOpenSession => _setup?.hasOpenSession ?? false;

  /// Tunai masuk laci hanya bila sesi terbuka dan tanggal bayar hari ini;
  /// selain itu dicatat sebagai kas toko.
  bool get cashToDrawer =>
      hasOpenSession && _detail != null && paidOn == _detail!.today;

  List<OpenReceivable<UuidValue>> get _open => [
    for (final r in _detail?.open ?? const <ReceivableSale>[])
      OpenReceivable(id: r.sale.id, outstanding: r.outstanding),
  ];

  /// Alokasi per nota: isian manual, atau otomatis nota terlama dulu.
  Map<UuidValue, Money> get allocations => _manual
      ? Map.unmodifiable(_allocations)
      : allocateOldestFirst(_amount, _open);

  Money get allocatedTotal => Money.sum(allocations.values);

  /// Galat pembayaran saat ini (`null` = sah). Jumlah nol tidak dianggap
  /// galat sebelum disimpan.
  DebtPaymentIssue? get issue {
    if (_amount == Money.zero && !_submitted) return null;
    return validateDebtPayment(
      _amount,
      _open,
      manual: _manual ? _allocations : null,
    );
  }

  /// Sisa piutang setelah pembayaran ini (≥ 0).
  Money get balanceAfter {
    final rest = (_detail?.row.outstanding ?? Money.zero) - _amount;
    return rest.isNegative ? Money.zero : rest;
  }

  bool get canSubmit => _valid && !receive.running;

  /// Isian sah untuk disimpan (tanpa melihat perintah yang sedang jalan,
  /// karena [_receive] sendiri berjalan di dalam [receive]).
  bool get _valid =>
      canReceive &&
      (_detail?.open.isNotEmpty ?? false) &&
      _amount > Money.zero &&
      validateDebtPayment(
            _amount,
            _open,
            manual: _manual ? _allocations : null,
          ) ==
          null;

  Future<Result<void>> _load() async {
    if (_setup == null) {
      switch (await _repository.load()) {
        case Ok(:final value):
          _setup = value;
        case Error(:final error):
          _error = error;
          return Result.error(error);
      }
    }
    switch (await _repository.detail(customerId)) {
      case Ok(:final value):
        _detail = value;
        _error = null;
        _allocations.removeWhere(
          (id, _) => !value.open.any((r) => r.sale.id == id),
        );
        return const Result.ok(null);
      case Error(:final error):
        _error = error;
        return Result.error(error);
    }
  }

  void setAmount(Money amount) {
    if (_amount == amount) return;
    _amount = amount;
    notifyListeners();
  }

  /// Isi jumlah = seluruh piutang.
  void payAll() {
    _amount = _detail?.row.outstanding ?? Money.zero;
    if (_manual) {
      _allocations
        ..clear()
        ..addAll(allocateOldestFirst(_amount, _open));
    }
    _generation++;
    notifyListeners();
  }

  void setMethod(PaymentMethod method) {
    if (_method == method || !debtPaymentMethods.contains(method)) return;
    _method = method;
    notifyListeners();
  }

  void setPaidOn(DateTime date) {
    _paidOn = DateTime.utc(date.year, date.month, date.day);
    notifyListeners();
  }

  void setNote(String note) {
    _note = note;
  }

  /// Alokasi manual mulai dari hasil otomatis.
  void setManual(bool manual) {
    if (_manual == manual) return;
    if (manual) {
      _allocations
        ..clear()
        ..addAll(allocateOldestFirst(_amount, _open));
    }
    _manual = manual;
    _generation++;
    notifyListeners();
  }

  void setAllocation(UuidValue saleId, Money amount) {
    if (!_manual) return;
    if (amount == Money.zero) {
      _allocations.remove(saleId);
    } else {
      _allocations[saleId] = amount;
    }
    notifyListeners();
  }

  Future<Result<DebtPayment>> _receive() async {
    _submitted = true;
    if (!_valid) {
      notifyListeners();
      return Result.error(
        DebtPaymentInvalid(issue ?? DebtPaymentIssue.amount),
      );
    }
    final note = _note.trim();
    final result = await _repository.receivePayment(
      DebtPaymentRequest(
        customerId: customerId,
        amount: _amount,
        method: _method,
        paidOn: paidOn,
        allocations: _manual ? Map.of(_allocations) : null,
        note: note.isEmpty ? null : note,
      ),
    );
    if (result is Ok<DebtPayment>) {
      _amount = Money.zero;
      _manual = false;
      _allocations.clear();
      _note = '';
      _submitted = false;
      _generation++;
      await _load();
    }
    return result;
  }

  /// Pembayaran [p] bisa dibatalkan di sini: staf punya `debts:manage`,
  /// belum batal, dan dicatat di cabang ini.
  bool canVoid(DebtPayment p) =>
      canReceive &&
      p.voidedAt == null &&
      _setup?.outletId != null &&
      p.outletId == _setup!.outletId;

  Future<Result<DebtPayment>> _voidPayment((UuidValue, String) args) async {
    final (id, reason) = args;
    final result = await _repository.voidPayment(id, reason);
    if (result is Ok<DebtPayment>) await _load();
    return result;
  }

  Future<Result<void>> _delete() => _repository.delete(customerId);
}
