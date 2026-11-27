import 'package:lakuna_client/lakuna_client.dart';

/// Id dari JSON pengaturan; `null` bila bukan UUID berformat sah.
/// `UuidValue.fromString` tidak memeriksa isi, dan id rusak membuat query
/// SQLite gagal (F1-06c). Hanya format yang diperiksa, bukan versi/varian.
UuidValue? tryUuid(String id) {
  try {
    return UuidValue.withFormatValidation(id);
  } on FormatException {
    return null;
  }
}
