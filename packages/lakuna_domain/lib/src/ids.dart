import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// ID baru (UUIDv7, urut waktu) dibuat di perangkat, sehingga data tidak
/// perlu dipetakan ulang saat naik ke server.
String newId() => _uuid.v7();

/// Namespace UUIDv5 untuk baris yang identitasnya ditentukan kunci alami.
const _lakunaNamespace = '6d1c5b0e-4f1a-5b8e-9c2d-1a7e3f0b9c41';

/// ID tetap (UUIDv5) dari [tenantId] dan kunci alami [key], mis. role
/// `cashier`. Dua perangkat yang membuat baris yang sama menghasilkan ID yang
/// sama, sehingga sync menggabungkannya, bukan bentrok di indeks unik.
String stableId(String tenantId, String key) =>
    _uuid.v5(_lakunaNamespace, '$tenantId/$key');
