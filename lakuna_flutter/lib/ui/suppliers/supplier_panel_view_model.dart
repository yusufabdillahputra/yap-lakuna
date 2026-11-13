import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/suppliers_repository.dart';
import '../../data/services/image_file_picker.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Sumber dana bayar hutang, urut tampilan.
const supplierFundingOrder = [
  FundingSource.storeCash,
  FundingSource.drawer,
  FundingSource.bank,
];

/// Alasan foto bukti ditolak sebelum disimpan.
enum ProofIssue { tooLarge, invalid }

/// Alasan bayar dari kas laci tidak bisa dipakai.
enum DrawerIssue { notPermitted, noSession, notToday }

/// Panel satu supplier (1.21): pembelian berhutang, bayar hutang dengan
/// alokasi otomatis atau manual, foto bukti, dan riwayat bayar.
class SupplierPanelViewModel extends ChangeNotifier {
  SupplierPanelViewModel({
    required this._repository,
    required this.supplierId,
    this._picker = const FileSelectorImagePicker(),
  }) {
    load = Command0(_load)..addListener(notifyListeners);
    pay = Command0(_pay)..addListener(notifyListeners);
    delete = Command0(_delete)..addListener(notifyListeners);
    voidPayment = Command1(_voidPayment)..addListener(notifyListeners);
    pickProof = Command1(_pickProof)..addListener(notifyListeners);
  }

  final SuppliersRepository _repository;
  final ImageFilePicker _picker;
  final UuidValue supplierId;

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    load.dispose();
    pay.dispose();
    delete.dispose();
    voidPayment.dispose();
    pickProof.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  late final Command0<void> load;

  /// Hasil = pembayaran tersimpan.
  late final Command0<DebtPayment> pay;
  late final Command0<void> delete;

  /// Batal pembayaran (F1-13c): argumen = (id pembayaran, alasan).
  late final Command1<DebtPayment, (UuidValue, String)> voidPayment;

  /// Argumen `true` = kamera.
  late final Command1<void, bool> pickProof;

  SuppliersSetup? _setup;
  SupplierDetail? _detail;
  Exception? _error;

  var _amount = Money.zero;
  var _funding = FundingSource.storeCash;
  DateTime? _paidOn;
  var _reference = '';
  var _note = '';
  var _manual = false;
  final _allocations = <UuidValue, Money>{};
  SupplierPaymentProof? _proof;
  ProofIssue? _proofIssue;
  var _submitted = false;
  var _generation = 0;

  SuppliersSetup? get setup => _setup;
  SupplierDetail? get detail => _detail;
  Exception? get error => _error;
  Money get amount => _amount;
  FundingSource get funding => _funding;
  DateTime get paidOn => _paidOn ?? _detail?.today ?? DateTime.now();
  String get reference => _reference;
  String get note => _note;
  bool get manual => _manual;
  SupplierPaymentProof? get proof => _proof;
  ProofIssue? get proofIssue => _proofIssue;
  bool get canTakePhoto => _picker.canTakePhoto;

  /// Naik saat isian dikosongkan agar field dibuat ulang.
  int get generation => _generation;

  bool get canPay => _setup?.canPay ?? false;
  bool get canManage => _setup?.canManage ?? false;

  /// Kas laci tidak bisa dipakai saat ini (`null` = bisa).
  DrawerIssue? get drawerIssue {
    if (_funding != FundingSource.drawer) return null;
    if (!(_setup?.canUseDrawer ?? false)) return DrawerIssue.notPermitted;
    if (!(_setup?.hasOpenSession ?? false)) return DrawerIssue.noSession;
    if (_detail != null && paidOn != _detail!.today) {
      return DrawerIssue.notToday;
    }
    return null;
  }

  List<OpenReceivable<UuidValue>> get _open => [
    for (final p in _detail?.open ?? const <PayablePurchase>[])
      OpenReceivable(id: p.purchase.id, outstanding: p.outstanding),
  ];

  /// Alokasi per pembelian: isian manual, atau otomatis jatuh tempo
  /// terdekat dulu.
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

  /// Sisa hutang setelah pembayaran ini (≥ 0).
  Money get balanceAfter {
    final rest = (_detail?.row.debt ?? Money.zero) - _amount;
    return rest.isNegative ? Money.zero : rest;
  }

  /// Jatuh tempo terdekat pembelian yang masih bersisa setelah alokasi ini.
  DateTime? get nextDueAfter {
    final a = allocations;
    DateTime? best;
    for (final p in _detail?.open ?? const <PayablePurchase>[]) {
      if (p.outstanding - (a[p.purchase.id] ?? Money.zero) <= Money.zero) {
        continue;
      }
      final d = p.purchase.dueOn;
      if (d != null && (best == null || d.isBefore(best))) best = d;
    }
    return best;
  }

  bool get canSubmit => _valid && !pay.running;

  /// Isian sah (tanpa melihat [pay] yang sedang jalan, karena [_pay]
  /// sendiri berjalan di dalamnya).
  bool get _valid =>
      canPay &&
      (_detail?.open.isNotEmpty ?? false) &&
      _amount > Money.zero &&
      drawerIssue == null &&
      validateDebtPayment(
            _amount,
            _open,
            manual: _manual ? _allocations : null,
          ) ==
          null;

  Future<Result<void>> _load() async {
    // Setup dimuat ulang setiap kali agar status sesi kasir (kas laci)
    // tidak basi bila sesi dibuka/ditutup selama panel terbuka.
    switch (await _repository.load()) {
      case Ok(:final value):
        _setup = value;
      case Error(:final error):
        _error = error;
        return Result.error(error);
    }
    switch (await _repository.detail(supplierId)) {
      case Ok(:final value):
        _detail = value;
        _error = null;
        _allocations.removeWhere(
          (id, _) => !value.open.any((p) => p.purchase.id == id),
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

  /// Isi jumlah = seluruh hutang.
  void payAll() {
    _amount = _detail?.row.debt ?? Money.zero;
    if (_manual) {
      _allocations
        ..clear()
        ..addAll(allocateOldestFirst(_amount, _open));
    }
    _generation++;
    notifyListeners();
  }

  void setFunding(FundingSource funding) {
    if (_funding == funding) return;
    _funding = funding;
    notifyListeners();
  }

  void setPaidOn(DateTime date) {
    _paidOn = DateTime.utc(date.year, date.month, date.day);
    notifyListeners();
  }

  void setReference(String v) => _reference = v;

  void setNote(String v) => _note = v;

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

  void setAllocation(UuidValue purchaseId, Money amount) {
    if (!_manual) return;
    if (amount == Money.zero) {
      _allocations.remove(purchaseId);
    } else {
      _allocations[purchaseId] = amount;
    }
    notifyListeners();
  }

  void removeProof() {
    _proof = null;
    _proofIssue = null;
    notifyListeners();
  }

  Future<Result<void>> _pickProof(bool camera) async {
    try {
      final picked = camera
          ? await _picker.takePhoto(maxBytes: SupplierLimits.proofMaxBytes)
          : await _picker.pickImage(maxBytes: SupplierLimits.proofMaxBytes);
      if (picked == null) return const Result.ok(null);
      final bytes = picked.bytes;
      if (bytes == null) {
        _proofIssue = ProofIssue.tooLarge;
      } else if (readImageHeader(bytes) == null) {
        _proofIssue = ProofIssue.invalid;
      } else {
        _proof = SupplierPaymentProof(bytes: bytes, fileName: picked.name);
        _proofIssue = null;
      }
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<DebtPayment>> _pay() async {
    _submitted = true;
    if (!_valid) {
      notifyListeners();
      return Result.error(
        SupplierPaymentInvalid(issue ?? DebtPaymentIssue.amount),
      );
    }
    final reference = _reference.trim();
    final note = _note.trim();
    final result = await _repository.pay(
      SupplierPaymentRequest(
        supplierId: supplierId,
        amount: _amount,
        funding: _funding,
        paidOn: paidOn,
        allocations: _manual ? Map.of(_allocations) : null,
        reference: reference.isEmpty ? null : reference,
        note: note.isEmpty ? null : note,
        proof: _proof,
      ),
    );
    if (result is Ok<DebtPayment>) {
      _amount = Money.zero;
      _manual = false;
      _allocations.clear();
      _reference = '';
      _note = '';
      _proof = null;
      _proofIssue = null;
      _submitted = false;
      _generation++;
      await _load();
    }
    return result;
  }

  /// Pembayaran [p] bisa dibatalkan di sini: staf punya `debts:manage`,
  /// belum batal, dan dicatat di cabang ini.
  bool canVoid(DebtPayment p) =>
      canPay &&
      p.voidedAt == null &&
      _setup?.outletId != null &&
      p.outletId == _setup!.outletId;

  Future<Result<DebtPayment>> _voidPayment((UuidValue, String) args) async {
    final (id, reason) = args;
    final result = await _repository.voidPayment(id, reason);
    if (result is Ok<DebtPayment>) await _load();
    return result;
  }

  Future<Result<void>> _delete() => _repository.delete(supplierId);
}
