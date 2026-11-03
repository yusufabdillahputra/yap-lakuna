import 'package:serverpod_client/serverpod_client.dart' show UuidValue;

/// Nilai `settings.scope_key` untuk pengaturan yang berlaku di seluruh tenant.
const settingScopeTenant = 'tenant';

/// Nilai `settings.scope_key` untuk pengaturan yang hanya berlaku di satu
/// outlet. Baris seperti ini juga mengisi `outlet_id` dengan [outletId].
String settingScopeOutlet(UuidValue outletId) => 'outlet:${outletId.uuid}';
