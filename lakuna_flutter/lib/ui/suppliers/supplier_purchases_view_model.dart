import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';

import '../../data/repositories/suppliers_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Dialog *Riwayat pembelian* satu supplier (1.21).
class SupplierPurchasesViewModel extends ChangeNotifier {
  SupplierPurchasesViewModel({
    required this._repository,
    required this.supplierId,
  }) {
    load = Command0(_load)..addListener(notifyListeners);
  }

  final SuppliersRepository _repository;
  final UuidValue supplierId;

  late final Command0<void> load;

  List<PurchaseRow>? _rows;
  Exception? _error;

  /// Terbaru dulu; `null` sebelum termuat.
  List<PurchaseRow>? get rows => _rows;
  Exception? get error => _error;

  @override
  void dispose() {
    load.dispose();
    super.dispose();
  }

  Future<Result<void>> _load() async {
    switch (await _repository.purchases(supplierId)) {
      case Ok(:final value):
        _rows = value;
        _error = null;
        return const Result.ok(null);
      case Error(:final error):
        _error = error;
        return Result.error(error);
    }
  }
}
