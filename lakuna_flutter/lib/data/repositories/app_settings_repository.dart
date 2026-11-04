import 'package:flutter/widgets.dart';

import '../../utils/result.dart';

/// Pilihan tema pengguna.
enum AppThemeMode { light, dark, system }

/// Ukuran tampilan (skala teks) perangkat ini.
enum AppTextSize {
  normal(1),
  large(1.15);

  const AppTextSize(this.scale);

  final double scale;
}

/// Pengaturan tampilan aplikasi (tema, bahasa, ukuran tampilan).
abstract class AppSettingsRepository {
  Future<Result<AppThemeMode>> themeMode();
  Future<Result<void>> setThemeMode(AppThemeMode mode);
  Future<Result<Locale>> locale();
  Future<Result<void>> setLocale(Locale locale);
  Future<Result<AppTextSize>> textSize();
  Future<Result<void>> setTextSize(AppTextSize size);
}

/// Bahasa yang didukung; Indonesia bawaan.
const supportedAppLocales = [Locale('id'), Locale('en')];
const defaultAppLocale = Locale('id');
