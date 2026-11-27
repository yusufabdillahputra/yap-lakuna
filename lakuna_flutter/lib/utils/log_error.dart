import 'package:flutter/foundation.dart';

/// Mencatat galat yang dilewati agar aplikasi tetap jalan (F1-06c):
/// stdout di desktop, logcat di Android. Sama dengan galat muat lain di
/// `bootstrap.dart` dan `app_root.dart`.
void logError(String context, Object error, [StackTrace? stack]) =>
    debugPrint('$context: $error${stack == null ? '' : '\n$stack'}');

/// Penerima galat untuk `loadReceiptConfig` (F1-06c).
void logReceiptError(Object error, StackTrace stack) =>
    logError('Pengaturan atau logo struk gagal dibaca', error, stack);

/// Penerima galat untuk `loadQrisConfig` (F1-06c).
void logQrisError(Object error, StackTrace stack) =>
    logError('Gambar QRIS gagal dibaca', error, stack);
