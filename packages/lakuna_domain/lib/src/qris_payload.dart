import 'dart:convert';

/// Isi kode QR QRIS (EMVCo Merchant-Presented Mode) yang dibaca dari gambar
/// stiker (F1-18g, 1.26b *QR terbaca*).
class QrisPayload {
  const QrisPayload({
    required this.isStatic,
    required this.nmid,
    this.merchantName = '',
    this.city = '',
    this.terminalLabel = '',
  });

  /// Tag `01` = `11` (statis); `12` = dinamis (nominal sekali pakai).
  final bool isStatic;

  /// Subtag `02` dari template merchant ber-GUID `ID.CO.QRIS.WWW`.
  final String nmid;

  /// Tag `59`.
  final String merchantName;

  /// Tag `60`.
  final String city;

  /// Subtag `07` (*terminal label*) dari tag `62`; kosong bila tidak ada.
  final String terminalLabel;
}

/// GUID template merchant QRIS nasional.
const qrisGuid = 'ID.CO.QRIS.WWW';

/// CRC16-CCITT-FALSE (poli 0x1021, awal 0xFFFF) atas byte UTF-8 [data],
/// sebagai 4 heksadesimal huruf besar seperti tag `63` EMVCo.
String qrisCrc16(String data) => _crc16(utf8.encode(data));

String _crc16(List<int> bytes) {
  var crc = 0xFFFF;
  for (final byte in bytes) {
    crc ^= byte << 8;
    for (var i = 0; i < 8; i++) {
      crc = (crc & 0x8000) != 0 ? (crc << 1) ^ 0x1021 : crc << 1;
      crc &= 0xFFFF;
    }
  }
  return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
}

bool _isDigit(int byte) => byte >= 0x30 && byte <= 0x39;

/// TLV EMVCo atas byte UTF-8: dua digit tag + dua digit panjang (dalam
/// byte). `null` bila rusak.
Map<String, List<int>>? _tlv(List<int> bytes) {
  final out = <String, List<int>>{};
  var i = 0;
  while (i < bytes.length) {
    if (i + 4 > bytes.length) return null;
    if (!bytes.sublist(i, i + 4).every(_isDigit)) return null;
    final tag = String.fromCharCodes(bytes, i, i + 2);
    final length = (bytes[i + 2] - 0x30) * 10 + bytes[i + 3] - 0x30;
    if (i + 4 + length > bytes.length) return null;
    out[tag] = bytes.sublist(i + 4, i + 4 + length);
    i += 4 + length;
  }
  return out;
}

String _text(List<int>? bytes) =>
    bytes == null ? '' : utf8.decode(bytes, allowMalformed: true).trim();

/// Baca isi QR QRIS. `null` bila bukan QRIS yang sah: TLV rusak, CRC tag
/// `63` salah, atau tidak ada template merchant ber-GUID [qrisGuid].
QrisPayload? parseQrisPayload(String text) {
  final bytes = utf8.encode(text.trim());
  // CRC menutup payload: "...6304XXXX".
  if (bytes.length < 8) return null;
  final crcAt = bytes.length - 8;
  if (String.fromCharCodes(bytes, crcAt, crcAt + 4) != '6304') return null;
  final expected = String.fromCharCodes(bytes, bytes.length - 4).toUpperCase();
  if (_crc16(bytes.sublist(0, bytes.length - 4)) != expected) return null;
  final root = _tlv(bytes);
  if (root == null) return null;

  String? nmid;
  for (var tag = 26; tag <= 51; tag++) {
    final template = root['$tag'];
    if (template == null) continue;
    final sub = _tlv(template);
    if (sub == null || _text(sub['00']).toUpperCase() != qrisGuid) continue;
    final value = _text(sub['02']);
    if (value.isNotEmpty) {
      nmid = value;
      break;
    }
  }
  if (nmid == null) return null;

  final additional = root['62'] == null ? null : _tlv(root['62']!);
  return QrisPayload(
    isStatic: _text(root['01']) != '12',
    nmid: nmid,
    merchantName: _text(root['59']),
    city: _text(root['60']),
    terminalLabel: _text(additional?['07']),
  );
}

/// Hasil membaca kode QR dari gambar stiker (F1-18g).
enum QrisQrStatus {
  /// Tidak ada QR yang terbaca dari gambar.
  notFound,

  /// QR terbaca tetapi bukan QRIS yang sah (CRC salah, GUID lain, URL).
  notQris,

  /// QRIS sah; lihat [QrisQrRead.payload].
  qris,
}

class QrisQrRead {
  const QrisQrRead._(this.status, this.payload);

  /// Dari teks QR hasil dekoder; `null` = tidak ada QR terbaca.
  factory QrisQrRead.fromText(String? text) {
    if (text == null) return const QrisQrRead._(QrisQrStatus.notFound, null);
    final payload = parseQrisPayload(text);
    return payload == null
        ? const QrisQrRead._(QrisQrStatus.notQris, null)
        : QrisQrRead._(QrisQrStatus.qris, payload);
  }

  final QrisQrStatus status;
  final QrisPayload? payload;
}
