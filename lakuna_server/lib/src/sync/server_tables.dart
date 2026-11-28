/// Tabel yang hanya ada di server (`database: server`, F2-01): tidak
/// disinkronkan ke perangkat dan tidak termasuk `syncTables`.
const Set<String> serverOnlyTables = {
  'sync_changes',
  'sync_conflicts',
  'device_credentials',
  'pairing_codes',
  'activation_codes',
  'tenant_owners',
};
