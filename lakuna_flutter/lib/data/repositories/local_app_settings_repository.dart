import 'package:flutter/widgets.dart';
import 'package:lakuna_data/lakuna_data.dart';

import '../../utils/result.dart';
import 'app_settings_repository.dart';

/// Menyimpan pengaturan tampilan di `local_preferences` perangkat. Setelah
/// login PIN tersedia (F1-02), pengaturan pindah ke per staf.
class LocalAppSettingsRepository implements AppSettingsRepository {
  LocalAppSettingsRepository(this._preferences);

  final LocalPreferences _preferences;

  static const _themeKey = 'ui.theme_mode';
  static const _localeKey = 'ui.locale';

  @override
  Future<Result<AppThemeMode>> themeMode() => _guard(() async {
    final raw = await _preferences.get(_themeKey);
    return AppThemeMode.values.asNameMap()[raw] ?? AppThemeMode.system;
  });

  @override
  Future<Result<void>> setThemeMode(AppThemeMode mode) =>
      _guard(() => _preferences.set(_themeKey, mode.name));

  @override
  Future<Result<Locale>> locale() => _guard(() async {
    final raw = await _preferences.get(_localeKey);
    return supportedAppLocales.firstWhere(
      (l) => l.languageCode == raw,
      orElse: () => defaultAppLocale,
    );
  });

  @override
  Future<Result<void>> setLocale(Locale locale) =>
      _guard(() => _preferences.set(_localeKey, locale.languageCode));

  Future<Result<T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Result.ok(await body());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
