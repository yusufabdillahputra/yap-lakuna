import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/expenses_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Dialog *Rincian pengeluaran*: data, foto nota, dan batal dengan alasan.
class ExpenseDetailViewModel extends ChangeNotifier {
  ExpenseDetailViewModel({
    required this._repository,
    required this.expenseId,
    this.canUseDrawer = true,
  }) {
    load = Command0(_load)..addListener(notifyListeners);
    cancel = Command0(_cancel)..addListener(notifyListeners);
  }

  final ExpensesRepository _repository;
  final UuidValue expenseId;

  /// Staf punya `cash_movements:create`; tanpa itu pengeluaran kas laci
  /// tidak bisa dibatalkan (uang kembali ke laci).
  final bool canUseDrawer;

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    load.dispose();
    cancel.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  late final Command0<void> load;
  late final Command0<Expense> cancel;

  ExpenseRow? _row;
  Uint8List? _receipt;
  Exception? _error;
  var _reason = '';
  var _confirming = false;
  var _submitted = false;

  ExpenseRow? get row => _row;
  Uint8List? get receipt => _receipt;
  Exception? get error => _error;
  String get reason => _reason;

  /// Form alasan batal sedang tampil.
  bool get confirming => _confirming;
  bool get reasonInvalid => _submitted && !validateExpenseVoidReason(_reason);
  bool get canCancel {
    final row = _row;
    if (row == null || row.voided) return false;
    return row.expense.fundingSource != FundingSource.drawer || canUseDrawer;
  }

  void startCancel() {
    _confirming = true;
    _submitted = false;
    notifyListeners();
  }

  void stopCancel() {
    _confirming = false;
    _reason = '';
    notifyListeners();
  }

  void setReason(String v) {
    _reason = v;
    notifyListeners();
  }

  Future<Result<void>> _load() async {
    switch (await _repository.detail(expenseId)) {
      case Ok(:final value):
        _row = value;
        _error = null;
      case Error(:final error):
        _error = error;
        return Result.error(error);
    }
    if (_row!.hasReceipt) {
      if (await _repository.receipt(expenseId) case Ok(:final value)) {
        _receipt = value;
      }
    }
    return const Result.ok(null);
  }

  Future<Result<Expense>> _cancel() async {
    _submitted = true;
    if (!validateExpenseVoidReason(_reason)) {
      notifyListeners();
      return Result.error(ExpenseVoidReasonInvalid());
    }
    final result = await _repository.cancel(expenseId, _reason);
    if (result is Ok<Expense>) {
      _confirming = false;
      await _load();
    }
    return result;
  }
}
