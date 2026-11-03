import 'package:flutter/foundation.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/dining_admin_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Persen isian ("5", "5,5", "10.5") → basis poin; kosong = 0; tidak sah
/// → `null`. Paling banyak dua desimal.
int? parsePercentBp(String text) {
  final t = text.trim().replaceAll(',', '.');
  if (t.isEmpty) return 0;
  final m = RegExp(r'^(\d{1,3})(?:\.(\d{1,2}))?$').firstMatch(t);
  if (m == null) return null;
  final frac = (m.group(2) ?? '').padRight(2, '0');
  return int.parse(m.group(1)!) * 100 + int.parse(frac);
}

/// Basis poin → isian persen tanpa nol berlebih ("10,5", "5").
String percentInput(int bp, {required String decimal}) {
  final whole = bp ~/ 100;
  final frac = bp % 100;
  if (frac == 0) return '$whole';
  final digits = frac % 10 == 0 ? '${frac ~/ 10}' : '$frac'.padLeft(2, '0');
  return '$whole$decimal$digits';
}

/// Subtotal contoh pratinjau tarif.
const fnbPreviewSubtotal = Money(100000);

/// View model Pengaturan › Pajak & service (F1-10).
class FnbRatesViewModel extends ChangeNotifier {
  FnbRatesViewModel({required this._repository}) {
    load = Command0(_load)..addListener(notifyListeners);
    save = Command0(_save)..addListener(notifyListeners);
  }

  final DiningAdminRepository _repository;

  late final Command0<FnbRates> load;
  late final Command0<FnbRates> save;

  FnbRates _stored = const FnbRates();
  int? _service = 0;
  int? _tax = 0;
  var _saved = false;
  var _rev = 0;
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

  /// Naik setiap kali isian diisi ulang dari data (kunci field).
  int get revision => _rev;

  BasisPoints get service => BasisPoints(_service ?? 0);
  BasisPoints get tax => BasisPoints(_tax ?? 0);

  bool get serviceInvalid =>
      _service == null ||
      !validateFnbRate(BasisPoints(_service!), FnbLimits.serviceBp);

  bool get taxInvalid =>
      _tax == null || !validateFnbRate(BasisPoints(_tax!), FnbLimits.taxBp);

  bool get dirty =>
      _service != _stored.service.value || _tax != _stored.tax.value;

  bool get canSave =>
      !serviceInvalid &&
      !taxInvalid &&
      dirty &&
      !save.running &&
      load.completed;

  /// Tersimpan dan belum diubah lagi.
  bool get saved => _saved;

  /// Contoh hitungan dine in dari subtotal Rp 100.000.
  FnbCharges get preview => fnbCharges(
    fnbPreviewSubtotal,
    dineIn: true,
    serviceBp: serviceInvalid ? BasisPoints.zero : service,
    taxBp: taxInvalid ? BasisPoints.zero : tax,
  );

  void setService(String text) {
    _service = parsePercentBp(text);
    _saved = false;
    notifyListeners();
  }

  void setTax(String text) {
    _tax = parsePercentBp(text);
    _saved = false;
    notifyListeners();
  }

  void _apply(FnbRates rates) {
    _stored = rates;
    _service = rates.service.value;
    _tax = rates.tax.value;
    _rev++;
  }

  Future<Result<FnbRates>> _load() async {
    final result = await _repository.rates();
    if (result case Ok(:final value)) _apply(value);
    return result;
  }

  Future<Result<FnbRates>> _save() async {
    final result = await _repository.saveRates(
      FnbRates(service: service, tax: tax),
    );
    if (result case Ok(:final value)) {
      _stored = value;
      _saved = true;
    }
    return result;
  }
}
