import 'package:flutter/widgets.dart';
import 'package:lakuna_flutter/data/repositories/app_settings_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

class FakeAppSettingsRepository implements AppSettingsRepository {
  FakeAppSettingsRepository({
    this.storedTheme = AppThemeMode.system,
    this.storedLocale = defaultAppLocale,
    this.storedTextSize = AppTextSize.normal,
    this.failWrites = false,
  });

  AppThemeMode storedTheme;
  Locale storedLocale;
  AppTextSize storedTextSize;

  @override
  Future<Result<AppTextSize>> textSize() async => Result.ok(storedTextSize);

  @override
  Future<Result<void>> setTextSize(AppTextSize size) async {
    if (failWrites) return Result.error(Exception('disk penuh'));
    storedTextSize = size;
    return const Result.ok(null);
  }

  bool failWrites;

  @override
  Future<Result<AppThemeMode>> themeMode() async => Result.ok(storedTheme);

  @override
  Future<Result<Locale>> locale() async => Result.ok(storedLocale);

  @override
  Future<Result<void>> setThemeMode(AppThemeMode mode) async {
    if (failWrites) return Result.error(Exception('disk penuh'));
    storedTheme = mode;
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> setLocale(Locale locale) async {
    if (failWrites) return Result.error(Exception('disk penuh'));
    storedLocale = locale;
    return const Result.ok(null);
  }
}
