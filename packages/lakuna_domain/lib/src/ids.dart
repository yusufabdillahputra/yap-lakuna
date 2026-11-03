import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// ID baru (UUIDv7, urut waktu) dibuat di perangkat, sehingga data tidak
/// perlu dipetakan ulang saat naik ke server.
String newId() => _uuid.v7();
