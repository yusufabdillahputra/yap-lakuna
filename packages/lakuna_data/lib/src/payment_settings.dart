import 'dart:convert';
import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show DatabaseSession, Transaction;

import 'media.dart';
import 'settings_scope.dart';
import 'stock.dart';
import 'store.dart';

/// Kunci `settings.key` untuk QRIS statis per cabang (F1-18, 1.26b).
const qrisStaticSettingKey = 'payments.qris_static';

/// Isian Pengaturan › Metode pembayaran › QRIS statis.
class QrisStaticSettings {
  const QrisStaticSettings({
    this.enabled = false,
    this.mediaId,
    this.merchantName = '',
    this.nmid = '',
    this.terminalCode = '',
    this.settlementNote = '',
  });

  factory QrisStaticSettings.fromJson(Map<String, Object?> json) {
    String text(String key) => json[key] is String ? json[key]! as String : '';
    final media = json['mediaId'];
    return QrisStaticSettings(
      enabled: json['enabled'] == true,
      mediaId: media is String ? UuidValue.fromString(media) : null,
      merchantName: text('merchantName'),
      nmid: text('nmid'),
      terminalCode: text('terminalCode'),
      settlementNote: text('settlementNote'),
    );
  }

  /// *QRIS statis aktif di kasir*.
  final bool enabled;

  /// Stiker QRIS di `media_files`.
  final UuidValue? mediaId;
  final String merchantName;

  /// Nomor ID merchant nasional, huruf besar.
  final String nmid;
  final String terminalCode;

  /// *Dana masuk ke*: petunjuk kasir saat cek mutasi.
  final String settlementNote;

  Map<String, Object?> toJson() => {
    'enabled': enabled,
    'mediaId': mediaId?.uuid,
    'merchantName': merchantName,
    'nmid': nmid,
    'terminalCode': terminalCode,
    'settlementNote': settlementNote,
  };

  QrisStaticSettings copyWith({
    bool? enabled,
    String? merchantName,
    String? nmid,
    String? terminalCode,
    String? settlementNote,
  }) => QrisStaticSettings(
    enabled: enabled ?? this.enabled,
    mediaId: mediaId,
    merchantName: merchantName ?? this.merchantName,
    nmid: nmid ?? this.nmid,
    terminalCode: terminalCode ?? this.terminalCode,
    settlementNote: settlementNote ?? this.settlementNote,
  );

  QrisStaticSettings _normalized(UuidValue? media) => QrisStaticSettings(
    enabled: enabled,
    mediaId: media,
    merchantName: merchantName.trim(),
    nmid: normalizeNmid(nmid),
    terminalCode: terminalCode.trim(),
    settlementNote: settlementNote.trim(),
  );
}

/// Gambar stiker baru yang dipilih pemilik.
class QrisImageUpload {
  const QrisImageUpload({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

/// Pengaturan QRIS statis cabang beserta gambarnya.
class QrisConfig {
  const QrisConfig({required this.settings, this.media, this.imageBytes});

  final QrisStaticSettings settings;
  final MediaFile? media;

  /// `null` bila belum ada gambar atau berkasnya belum ada di perangkat ini.
  final Uint8List? imageBytes;

  /// QRIS statis bisa dipakai di kasir: aktif dan gambarnya ada.
  bool get isUsable => settings.enabled && imageBytes != null;
}

/// Gambar stiker ditolak (format atau ukuran).
class QrisImageInvalid implements Exception {
  const QrisImageInvalid(this.error);

  final QrisImageError error;

  @override
  String toString() => 'QrisImageInvalid($error)';
}

/// Isian QRIS tidak sah.
class QrisSettingsInvalid implements Exception {
  const QrisSettingsInvalid(this.errors);

  final Set<QrisSettingsError> errors;

  @override
  String toString() => 'QrisSettingsInvalid($errors)';
}

/// Pengaturan QRIS statis cabang [scope].
Future<QrisConfig> loadQrisConfig(LakunaStore store, CatalogScope scope) async {
  final settings = await readQrisSettings(store.session, scope);
  final media = await _media(store.session, null, scope, settings.mediaId);
  return QrisConfig(
    settings: settings,
    media: media,
    imageBytes: media == null ? null : await readMediaFile(store, media),
  );
}

/// Membaca isian QRIS statis cabang [scope] (bawaan: nonaktif).
Future<QrisStaticSettings> readQrisSettings(
  DatabaseSession session,
  CatalogScope scope, {
  Transaction? transaction,
}) async {
  final row = await _row(session, transaction, scope);
  if (row == null) return const QrisStaticSettings();
  final json = jsonDecode(row.valueJson);
  return json is Map<String, Object?>
      ? QrisStaticSettings.fromJson(json)
      : const QrisStaticSettings();
}

/// Menyimpan isian QRIS statis cabang [scope]. [image] baru menggantikan
/// gambar lama; tanpa [image] gambar lama tetap dipakai. Gagal dengan
/// [QrisImageInvalid] atau [QrisSettingsInvalid] tanpa menulis apa pun.
Future<QrisConfig> saveQrisSettings(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required QrisStaticSettings settings,
  QrisImageUpload? image,
}) async {
  ImageHeader? header;
  if (image != null) {
    final check = checkQrisImage(image.bytes);
    if (check.error case final error?) throw QrisImageInvalid(error);
    header = check.header;
  }
  await store.write(actor: staffId, (w) async {
    final current = await _row(w.session, w.transaction, scope);
    final previous = current == null
        ? null
        : QrisStaticSettings.fromJson(
            jsonDecode(current.valueJson) as Map<String, Object?>,
          );
    final oldMedia = await _media(
      w.session,
      w.transaction,
      scope,
      previous?.mediaId,
    );
    final errors = validateQrisSettings(
      enabled: settings.enabled,
      hasImage: image != null || oldMedia != null,
      merchantName: settings.merchantName,
      nmid: settings.nmid,
      terminalCode: settings.terminalCode,
      settlementNote: settings.settlementNote,
    );
    if (errors.isNotEmpty) throw QrisSettingsInvalid(errors);

    final s = await w.stamp();
    var mediaId = oldMedia?.id;
    if (image != null) {
      final media = await storeMediaFile(
        w,
        store,
        scope,
        bytes: image.bytes,
        header: header!,
        fileName: image.fileName,
        kind: MediaKind.qrisSticker,
        outletId: scope.outletId,
        stamp: s,
      );
      mediaId = media.id;
    }
    final value = jsonEncode(settings._normalized(mediaId).toJson());
    if (current == null) {
      await w.insert(
        Setting(
          tenantId: scope.tenantId,
          outletId: scope.outletId,
          scopeKey: settingScopeOutlet(scope.outletId),
          key: qrisStaticSettingKey,
          valueJson: value,
          createdAt: s.now,
          updatedAt: s.now,
          createdBy: staffId,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    } else {
      await w.update(
        current.copyWith(
          valueJson: value,
          version: current.version + 1,
          updatedAt: s.now,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    }
  });
  return loadQrisConfig(store, scope);
}

Future<Setting?> _row(
  DatabaseSession session,
  Transaction? transaction,
  CatalogScope scope,
) => Setting.db.findFirstRow(
  session,
  where: (t) =>
      t.tenantId.equals(scope.tenantId) &
      t.scopeKey.equals(settingScopeOutlet(scope.outletId)) &
      t.key.equals(qrisStaticSettingKey) &
      t.deletedAt.equals(null),
  transaction: transaction,
);

Future<MediaFile?> _media(
  DatabaseSession session,
  Transaction? transaction,
  CatalogScope scope,
  UuidValue? id,
) async {
  if (id == null) return null;
  return MediaFile.db.findFirstRow(
    session,
    where: (m) =>
        m.id.equals(id) &
        m.tenantId.equals(scope.tenantId) &
        m.deletedAt.equals(null),
    transaction: transaction,
  );
}
