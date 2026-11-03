import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/payment_settings_repository.dart';
import 'package:lakuna_flutter/data/services/image_file_picker.dart';
import 'package:lakuna_flutter/utils/result.dart';

/// QRIS statis di memori dengan aturan validasi `lakuna_domain`.
class FakePaymentSettingsRepository extends PaymentSettingsRepository {
  FakePaymentSettingsRepository({QrisConfig? initial})
    : config = initial ?? const QrisConfig(settings: QrisStaticSettings());

  QrisConfig config;

  /// Galat berikutnya (sekali pakai).
  Exception? nextError;
  final saves = <(QrisStaticSettings, QrisImageUpload?)>[];

  @override
  Future<Result<QrisConfig>> loadQris() async => Result.ok(config);

  @override
  Future<Result<QrisConfig>> saveQris(
    QrisStaticSettings settings, {
    QrisImageUpload? image,
  }) async {
    final e = nextError;
    nextError = null;
    if (e != null) return Result.error(e);
    if (image != null) {
      if (checkQrisImage(image.bytes).error case final error?) {
        return Result.error(QrisImageInvalid(error));
      }
    }
    final errors = validateQrisSettings(
      enabled: settings.enabled,
      hasImage: image != null || config.imageBytes != null,
      merchantName: settings.merchantName,
      nmid: settings.nmid,
      terminalCode: settings.terminalCode,
      settlementNote: settings.settlementNote,
    );
    if (errors.isNotEmpty) return Result.error(QrisSettingsInvalid(errors));
    saves.add((settings, image));
    final header = image == null ? null : readImageHeader(image.bytes)!;
    final media = image == null
        ? config.media
        : MediaFile(
            tenantId: UuidValue.fromString(newId()),
            kind: MediaKind.qrisSticker,
            fileName: image.fileName,
            mimeType: header!.mimeType,
            sizeBytes: image.bytes.length,
            sha256: 'x',
            width: header.width,
            height: header.height,
            storageKey: 'x.${header.extension}',
            hlc: '',
          );
    config = QrisConfig(
      settings: QrisStaticSettings(
        enabled: settings.enabled,
        mediaId: media?.id,
        merchantName: settings.merchantName.trim(),
        nmid: normalizeNmid(settings.nmid),
        terminalCode: settings.terminalCode.trim(),
        settlementNote: settings.settlementNote.trim(),
      ),
      media: media,
      imageBytes: image?.bytes ?? config.imageBytes,
    );
    return Result.ok(config);
  }
}

/// Pemilih gambar palsu: mengembalikan [next] (sekali pakai).
class FakeImagePicker extends ImageFilePicker {
  PickedImage? next;
  var calls = 0;

  /// Argumen `vector` panggilan terakhir.
  bool? lastVector;

  /// Kamera tersedia (denah 1.7c).
  var camera = false;
  var photoCalls = 0;

  @override
  bool get canTakePhoto => camera;

  @override
  Future<PickedImage?> takePhoto({required int maxBytes}) {
    photoCalls++;
    return pickImage(maxBytes: maxBytes);
  }

  @override
  Future<PickedImage?> pickImage({
    required int maxBytes,
    bool vector = false,
  }) async {
    calls++;
    lastVector = vector;
    final picked = next;
    next = null;
    if (picked == null) return null;
    final bytes = picked.bytes;
    return PickedImage(
      name: picked.name,
      size: picked.size,
      bytes: bytes != null && bytes.length > maxBytes ? null : bytes,
    );
  }
}
