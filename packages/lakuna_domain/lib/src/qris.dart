import 'image_header.dart';

/// Ukuran maksimal file stiker QRIS statis (5 MB).
const maxQrisImageBytes = 5 * 1024 * 1024;

/// Lebar minimal yang disarankan agar stiker tajam di tablet.
const recommendedQrisWidth = 1000;

enum QrisImageError {
  /// Bukan PNG, JPEG, atau WebP.
  unsupported,

  /// Lebih dari [maxQrisImageBytes].
  tooLarge,
}

/// Peringatan yang tetap boleh disimpan.
enum QrisImageWarning {
  /// Lebar ≥ tinggi: stiker QRIS biasanya vertikal.
  notPortrait,

  /// Lebar < [recommendedQrisWidth].
  lowResolution,
}

/// Hasil pemeriksaan gambar stiker QRIS (1.26b).
class QrisImageCheck {
  const QrisImageCheck({this.header, this.error, this.warnings = const {}});

  final ImageHeader? header;
  final QrisImageError? error;
  final Set<QrisImageWarning> warnings;

  /// Rasio lebar : tinggi, mis. "1 : 1,42" (dua desimal, koma).
  String? get ratioLabel {
    final h = header;
    if (h == null) return null;
    final hundredths = (h.height * 100 + h.width ~/ 2) ~/ h.width;
    final whole = hundredths ~/ 100;
    final frac = (hundredths % 100).toString().padLeft(2, '0');
    return '1 : $whole,$frac';
  }
}

/// Memeriksa [bytes] stiker QRIS: format dari isi file, ukuran file, rasio,
/// dan resolusi.
QrisImageCheck checkQrisImage(List<int> bytes) {
  final header = readImageHeader(bytes);
  if (header == null) {
    return const QrisImageCheck(error: QrisImageError.unsupported);
  }
  if (bytes.length > maxQrisImageBytes) {
    return QrisImageCheck(header: header, error: QrisImageError.tooLarge);
  }
  return QrisImageCheck(
    header: header,
    warnings: {
      if (header.width >= header.height) QrisImageWarning.notPortrait,
      if (header.width < recommendedQrisWidth) QrisImageWarning.lowResolution,
    },
  );
}

const maxQrisMerchantNameLength = 60;
const maxQrisNmidLength = 20;
const maxQrisTerminalCodeLength = 20;
const maxQrisSettlementNoteLength = 80;

enum QrisSettingsError {
  imageMissing,
  merchantNameTooLong,
  nmidInvalid,
  terminalCodeTooLong,
  settlementNoteTooLong,
}

/// NMID disimpan huruf besar tanpa spasi di tepi.
String normalizeNmid(String nmid) => nmid.trim().toUpperCase();

final _nmidPattern = RegExp(r'^[A-Z0-9]+$');

/// Validasi isian Pengaturan › QRIS statis. QRIS aktif butuh gambar.
Set<QrisSettingsError> validateQrisSettings({
  required bool enabled,
  required bool hasImage,
  required String merchantName,
  required String nmid,
  required String terminalCode,
  required String settlementNote,
}) {
  final n = normalizeNmid(nmid);
  return {
    if (enabled && !hasImage) QrisSettingsError.imageMissing,
    if (merchantName.trim().length > maxQrisMerchantNameLength)
      QrisSettingsError.merchantNameTooLong,
    if (n.isNotEmpty &&
        (n.length > maxQrisNmidLength || !_nmidPattern.hasMatch(n)))
      QrisSettingsError.nmidInvalid,
    if (terminalCode.trim().length > maxQrisTerminalCodeLength)
      QrisSettingsError.terminalCodeTooLong,
    if (settlementNote.trim().length > maxQrisSettlementNoteLength)
      QrisSettingsError.settlementNoteTooLong,
  };
}
