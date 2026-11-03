import 'package:flutter/foundation.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/session_repository.dart';
import '../../data/repositories/store_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Langkah wizard setup toko (layar 1.1).
enum OnboardingStep { languageTheme, business, owner, summary }

/// State wizard setup toko pertama (F1-01). Data baru ditulis saat [finish].
class OnboardingViewModel extends ChangeNotifier {
  OnboardingViewModel({
    required this._repository,
    required this._session,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now {
    finish = Command0(_finish);
  }

  final StoreRepository _repository;
  final SessionRepository _session;
  final DateTime Function() _now;

  late final Command0<StoreContext> finish;

  OnboardingStep _step = OnboardingStep.languageTheme;
  BusinessKind _businessType = BusinessKind.retail;
  final _values = <SetupField, String>{
    for (final f in SetupField.values) f: '',
    SetupField.deviceCode: 'K01',
    SetupField.timezone: setupTimezones.first.id,
  };
  final _shownSteps = <OnboardingStep>{};

  OnboardingStep get step => _step;

  /// Nomor langkah 1–4 untuk "Langkah n dari 4".
  int get stepNumber => _step.index + 1;
  int get stepCount => OnboardingStep.values.length;

  BusinessKind get businessType => _businessType;

  String value(SetupField field) => _values[field]!;

  SetupInput get input => SetupInput(
    businessType: _businessType,
    businessName: value(SetupField.businessName),
    outletName: value(SetupField.outletName),
    outletCode: value(SetupField.outletCode),
    deviceCode: value(SetupField.deviceCode),
    timezone: value(SetupField.timezone),
    ownerName: value(SetupField.ownerName),
    email: value(SetupField.email),
    password: value(SetupField.password),
    passwordConfirm: value(SetupField.passwordConfirm),
    pin: value(SetupField.pin),
    pinConfirm: value(SetupField.pinConfirm),
  );

  /// Galat [field], hanya setelah pengguna mencoba melanjutkan langkahnya.
  SetupError? errorFor(SetupField field) {
    final owner = _stepOf(field);
    if (!_shownSteps.contains(owner)) return null;
    return input.validate(fields: [field])[field];
  }

  /// Contoh nomor nota pertama hari ini dari kode yang diketik. Tanggalnya
  /// mengikuti zona waktu yang dipilih (WIB/WITA/WIT), bukan jam perangkat.
  String get receiptPreview {
    final zone = setupTimezones.firstWhere(
      (z) => z.id == value(SetupField.timezone),
      orElse: () => setupTimezones.first,
    );
    final local = _now().toUtc().add(Duration(hours: zone.utcOffsetHours));
    final outlet = normalizeCode(value(SetupField.outletCode));
    final device = normalizeCode(value(SetupField.deviceCode));
    return receiptNumber(
      outlet.isEmpty ? 'PST' : outlet,
      device.isEmpty ? 'K01' : device,
      local,
      1,
    );
  }

  void setBusinessType(BusinessKind kind) {
    _businessType = kind;
    notifyListeners();
  }

  void setField(SetupField field, String text) {
    _values[field] = text;
    notifyListeners();
  }

  /// Ke langkah berikutnya bila field langkah ini valid; bila tidak, galat
  /// langkah ini ditampilkan.
  void next() {
    final fields = _fieldsOf(_step);
    if (input.validate(fields: fields).isNotEmpty) {
      _shownSteps.add(_step);
      notifyListeners();
      return;
    }
    if (_step.index < OnboardingStep.values.length - 1) {
      _step = OnboardingStep.values[_step.index + 1];
      notifyListeners();
    }
  }

  void back() {
    if (_step.index == 0) return;
    // Galat setup lama tidak relevan lagi setelah isian bisa diubah.
    if (finish.error) finish.clearResult();
    _step = OnboardingStep.values[_step.index - 1];
    notifyListeners();
  }

  /// Menyimpan toko lalu langsung memulai sesi pemilik (F1-02), sehingga
  /// pemilik tidak perlu mengetik PIN tepat setelah setup.
  Future<Result<StoreContext>> _finish() async {
    final result = await _repository.setup(input);
    if (result case Ok(:final value)) _session.startOwnerSession(value);
    return result;
  }

  static List<SetupField> _fieldsOf(OnboardingStep step) => switch (step) {
    OnboardingStep.business => SetupField.businessStep,
    OnboardingStep.owner => SetupField.ownerStep,
    _ => const [],
  };

  static OnboardingStep _stepOf(SetupField field) =>
      SetupField.businessStep.contains(field)
      ? OnboardingStep.business
      : OnboardingStep.owner;
}
