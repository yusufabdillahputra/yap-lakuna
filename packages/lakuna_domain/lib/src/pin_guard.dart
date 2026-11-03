/// Pembatas percobaan PIN/kata sandi (F1-02). Setelah [maxAttempts] kali
/// salah berturut-turut, kunci itu (ID staf atau email) ditolak selama
/// [lockout]. Disimpan di memori: menutup aplikasi menghapus hitungan.
class PinGuard {
  PinGuard({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  /// Jumlah salah berturut-turut sebelum dikunci.
  static const maxAttempts = 5;

  /// Lama kunci setelah [maxAttempts] kali salah.
  static const lockout = Duration(seconds: 60);

  final DateTime Function() _clock;
  final Map<String, int> _failures = {};
  final Map<String, DateTime> _lockedUntil = {};

  /// Sisa waktu kunci (dibulatkan ke atas per detik), atau `null` bila
  /// [key] tidak sedang dikunci.
  Duration? retryAfter(String key) {
    final until = _lockedUntil[key];
    if (until == null) return null;
    final left = until.difference(_clock());
    if (left <= Duration.zero) {
      _lockedUntil.remove(key);
      return null;
    }
    final seconds = (left.inMicroseconds + 999999) ~/ 1000000;
    return Duration(seconds: seconds);
  }

  /// Sisa percobaan sebelum [key] dikunci.
  int remainingAttempts(String key) => maxAttempts - (_failures[key] ?? 0);

  /// Mencatat percobaan salah; yang ke-[maxAttempts] mengunci [key].
  void recordFailure(String key) {
    final failures = (_failures[key] ?? 0) + 1;
    if (failures >= maxAttempts) {
      _failures.remove(key);
      _lockedUntil[key] = _clock().add(lockout);
    } else {
      _failures[key] = failures;
    }
  }

  /// Percobaan benar: hitungan dan kunci [key] dihapus.
  void recordSuccess(String key) {
    _failures.remove(key);
    _lockedUntil.remove(key);
  }
}
