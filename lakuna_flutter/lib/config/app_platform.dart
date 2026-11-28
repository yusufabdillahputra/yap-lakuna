import 'package:flutter/foundation.dart' show kIsWeb;

/// Kemampuan platform tempat aplikasi berjalan (F2-02). Disuntik agar
/// perilaku web bisa diuji di VM.
class AppPlatform {
  const AppPlatform({required this.isWeb});

  /// Platform saat ini.
  static const current = AppPlatform(isWeb: kIsWeb);

  /// Aplikasi perangkat (desktop/tablet/ponsel).
  static const native = AppPlatform(isWeb: false);

  /// Berjalan di browser sebagai perangkat web versi hosting.
  final bool isWeb;

  /// Kasir, meja/open bill, sesi kasir, dan shift (aturan 3).
  bool get supportsCashier => !isWeb;

  /// Backup lokal, backup otomatis, dan pulihkan (aturan 9).
  bool get supportsLocalBackup => !isWeb;
}
