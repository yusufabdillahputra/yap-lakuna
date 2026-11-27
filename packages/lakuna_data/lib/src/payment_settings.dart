import 'dart:convert';
import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show DatabaseSession, Transaction;

import 'json_uuid.dart';
import 'media.dart';
import 'sales.dart' show SalePaymentRequest;
import 'settings_scope.dart';
import 'staff_access.dart';
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
    this.cashierConfirmWithoutPin = true,
    this.showOnPhone = true,
  });

  factory QrisStaticSettings.fromJson(Map<String, Object?> json) {
    String text(String key) => json[key] is String ? json[key]! as String : '';
    final media = json['mediaId'];
    return QrisStaticSettings(
      enabled: json['enabled'] == true,
      mediaId: media is String ? tryUuid(media) : null,
      merchantName: text('merchantName'),
      nmid: text('nmid'),
      terminalCode: text('terminalCode'),
      settlementNote: text('settlementNote'),
      // Bawaan hidup: baris lama sebelum F1-05h tidak berubah perilakunya.
      cashierConfirmWithoutPin: json['cashierConfirmWithoutPin'] != false,
      // Bawaan hidup: baris lama sebelum F1-18e tetap menampilkan gambar.
      showOnPhone: json['showOnPhone'] != false,
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

  /// *Kasir boleh konfirmasi tanpa PIN manajer* (F1-05h, bawaan hidup).
  /// Lihat `canConfirmQrisDirectly`.
  final bool cashierConfirmWithoutPin;

  /// *Tampilkan juga di layar mobile kasir* (F1-18e, bawaan hidup): gambar
  /// stiker di tata letak ponsel kasir. Mati = kotak petunjuk saja.
  final bool showOnPhone;

  Map<String, Object?> toJson() => {
    'enabled': enabled,
    'mediaId': mediaId?.uuid,
    'merchantName': merchantName,
    'nmid': nmid,
    'terminalCode': terminalCode,
    'settlementNote': settlementNote,
    'cashierConfirmWithoutPin': cashierConfirmWithoutPin,
    'showOnPhone': showOnPhone,
  };

  QrisStaticSettings copyWith({
    bool? enabled,
    String? merchantName,
    String? nmid,
    String? terminalCode,
    String? settlementNote,
    bool? cashierConfirmWithoutPin,
    bool? showOnPhone,
  }) => QrisStaticSettings(
    enabled: enabled ?? this.enabled,
    mediaId: mediaId,
    merchantName: merchantName ?? this.merchantName,
    nmid: nmid ?? this.nmid,
    terminalCode: terminalCode ?? this.terminalCode,
    settlementNote: settlementNote ?? this.settlementNote,
    cashierConfirmWithoutPin:
        cashierConfirmWithoutPin ?? this.cashierConfirmWithoutPin,
    showOnPhone: showOnPhone ?? this.showOnPhone,
  );

  QrisStaticSettings _normalized(UuidValue? media) => QrisStaticSettings(
    enabled: enabled,
    mediaId: media,
    merchantName: merchantName.trim(),
    nmid: normalizeNmid(nmid),
    terminalCode: terminalCode.trim(),
    settlementNote: settlementNote.trim(),
    cashierConfirmWithoutPin: cashierConfirmWithoutPin,
    showOnPhone: showOnPhone,
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

/// Pengonfirmasi QRIS tidak boleh menekan *Sudah Terbayar* langsung
/// (F1-05h): butuh penyetuju ber-PIN, atau penyetujunya tidak berhak.
class QrisConfirmNotPermitted implements Exception {
  const QrisConfirmNotPermitted();

  @override
  String toString() => 'QrisConfirmNotPermitted';
}

/// Ada pembayaran QRIS statis yang dikonfirmasi di [payments].
bool confirmsQris(List<SalePaymentRequest> payments) =>
    payments.any((p) => p.method == PaymentMethod.qrisStatic && p.confirmed);

/// Siapa yang mengonfirmasi QRIS (F1-05h): [approverId] bila ada, selain
/// itu [staffId]. Orang itu harus staf aktif cabang yang
/// `canConfirmQrisDirectly` menurut sakelar cabang, selain itu
/// [QrisConfirmNotPermitted]. Hasilnya dicatat di `payments.confirmed_by`.
Future<UuidValue> requireQrisConfirmer(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  UuidValue? approverId,
}) async {
  final settings = await readQrisSettings(store.session, scope);
  final confirmer = approverId ?? staffId;
  // Pemilik tanpa keanggotaan cabang tetap bertugas sebagai `owner`.
  final staff = await findActingStaff(
    store,
    tenantId: scope.tenantId,
    outletId: scope.outletId,
    staffId: confirmer,
  );
  if (staff == null ||
      !canConfirmQrisDirectly(
        staff.permissions,
        cashierWithoutPin: settings.cashierConfirmWithoutPin,
      )) {
    throw const QrisConfirmNotPermitted();
  }
  return confirmer;
}

/// Pengaturan QRIS statis cabang [scope]. Berkas gambar yang tidak bisa
/// dibaca dilewati (QRIS tidak siap dipakai) dan dilaporkan ke [onError],
/// supaya Kasir tetap terbuka (F1-06c).
Future<QrisConfig> loadQrisConfig(
  LakunaStore store,
  CatalogScope scope, {
  void Function(Object error, StackTrace stack)? onError,
}) async {
  final settings = await readQrisSettings(store.session, scope);
  final media = await _media(store.session, null, scope, settings.mediaId);
  Uint8List? imageBytes;
  if (media != null) {
    try {
      imageBytes = await readMediaFile(store, media);
    } on Object catch (e, st) {
      onError?.call(e, st);
    }
  }
  return QrisConfig(settings: settings, media: media, imageBytes: imageBytes);
}

/// Membaca isian QRIS statis cabang [scope] (bawaan: nonaktif).
Future<QrisStaticSettings> readQrisSettings(
  DatabaseSession session,
  CatalogScope scope, {
  Transaction? transaction,
}) async {
  final row = await _row(session, transaction, scope);
  return row == null ? const QrisStaticSettings() : _decode(row);
}

/// QRIS statis cabang [scope] siap dipakai di checkout: aktif dan baris
/// gambarnya masih ada.
Future<bool> qrisStaticReady(
  DatabaseSession session,
  CatalogScope scope, {
  Transaction? transaction,
}) async {
  final settings = await readQrisSettings(
    session,
    scope,
    transaction: transaction,
  );
  if (!settings.enabled) return false;
  final media = await _media(session, transaction, scope, settings.mediaId);
  return media != null;
}

/// Isi baris yang rusak (bukan objek JSON) dibaca sebagai bawaan.
QrisStaticSettings _decode(Setting row) {
  try {
    final json = jsonDecode(row.valueJson);
    return json is Map<String, Object?>
        ? QrisStaticSettings.fromJson(json)
        : const QrisStaticSettings();
  } on FormatException {
    // JSON atau UUID gambar rusak.
    return const QrisStaticSettings();
  }
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
    final previous = current == null ? null : _decode(current);
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
