import 'package:flutter/widgets.dart';

import '../../data/repositories/app_settings_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// State tema dan bahasa untuk seluruh aplikasi.
class AppSettingsViewModel extends ChangeNotifier {
  AppSettingsViewModel({required this._repository}) {
    load = Command0(_load);
    setThemeMode = Command1(_setThemeMode);
    setLocale = Command1(_setLocale);
    setTextSize = Command1(_setTextSize);
  }

  final AppSettingsRepository _repository;

  late final Command0<void> load;
  late final Command1<void, AppThemeMode> setThemeMode;
  late final Command1<void, Locale> setLocale;
  late final Command1<void, AppTextSize> setTextSize;
  AppTextSize _textSize = AppTextSize.normal;

  /// Ukuran tampilan perangkat ini (skala teks).
  AppTextSize get textSize => _textSize;

  AppThemeMode _themeMode = AppThemeMode.system;
  Locale _locale = defaultAppLocale;

  AppThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  Future<Result<void>> _load() async {
    final theme = await _repository.themeMode();
    final locale = await _repository.locale();
    if (await _repository.textSize() case Ok(:final value)) _textSize = value;
    if (theme case Ok(:final value)) _themeMode = value;
    if (locale case Ok(:final value)) _locale = value;
    notifyListeners();
    return switch ((theme, locale)) {
      (Error(:final error), _) ||
      (_, Error(:final error)) => Result.error(error),
      _ => const Result.ok(null),
    };
  }

  Future<Result<void>> _setThemeMode(AppThemeMode mode) async {
    final previous = _themeMode;
    _themeMode = mode;
    notifyListeners();
    final result = await _repository.setThemeMode(mode);
    if (result is Error) {
      _themeMode = previous;
      notifyListeners();
    }
    return result;
  }

  Future<Result<void>> _setTextSize(AppTextSize size) async {
    final previous = _textSize;
    _textSize = size;
    notifyListeners();
    final result = await _repository.setTextSize(size);
    if (result is Error) {
      _textSize = previous;
      notifyListeners();
    }
    return result;
  }

  Future<Result<void>> _setLocale(Locale locale) async {
    final previous = _locale;
    _locale = locale;
    notifyListeners();
    final result = await _repository.setLocale(locale);
    if (result is Error) {
      _locale = previous;
      notifyListeners();
    }
    return result;
  }
}
