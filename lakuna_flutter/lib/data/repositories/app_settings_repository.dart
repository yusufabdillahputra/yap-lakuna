import 'package:flutter/widgets.dart';

import '../../utils/result.dart';

/// Pilihan tema pengguna.
enum AppThemeMode { light, dark, system }

/// Pengaturan tampilan aplikasi (tema dan bahasa).
abstract class AppSettingsRepository {
  Future<Result<AppThemeMode>> themeMode();
  Future<Result<void>> setThemeMode(AppThemeMode mode);
  Future<Result<Locale>> locale();
  Future<Result<void>> setLocale(Locale locale);
}

/// Bahasa yang didukung; Indonesia bawaan.
const supportedAppLocales = [Locale('id'), Locale('en')];
const defaultAppLocale = Locale('id');
