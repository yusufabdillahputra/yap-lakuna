import 'permission.dart';
import 'setup.dart' show passwordMinLength;

/// Izin untuk kunci role [roleKey]. Role bawaan memakai
/// [DefaultRole.permissions]; kunci tak dikenal tidak mendapat izin apa pun.
/// Pemilik ([isOwner]) selalu mendapat semua izin.
///
/// Role buatan pemilik (F1-17) akan membaca daftar izinnya dari database.
Set<Permission> permissionsForRole(String roleKey, {bool isOwner = false}) {
  if (isOwner) return Permission.values.toSet();
  for (final role in DefaultRole.values) {
    if (role.key == roleKey) return role.permissions;
  }
  return const {};
}

/// Inisial untuk avatar staf: huruf pertama dua kata pertama, atau dua huruf
/// pertama bila namanya satu kata.
String staffInitials(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.isEmpty) return '?';
  if (words.length == 1) {
    final w = words.first;
    return w.substring(0, w.length < 2 ? w.length : 2).toUpperCase();
  }
  return words.take(2).map((w) => w[0]).join().toUpperCase();
}

/// Panjang maksimal nama staf dan nama role custom (F1-17).
const staffNameMaxLength = 60;

/// Masalah validasi pengguna & role (F1-17).
enum StaffIssue {
  required,
  tooLong,
  invalidPin,
  pinMismatch,
  passwordTooShort,
  passwordMismatch,
  beyondOwnPermissions,
}

/// Kolom pasangan rahasia: nilai baru dan kolom ulangi.
enum CredentialField { secret, retype }

final _pinPattern = RegExp(r'^[0-9]{6}$');

/// Nama staf atau role: wajib (setelah dipangkas), maksimal
/// [staffNameMaxLength] karakter.
StaffIssue? staffNameIssue(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return StaffIssue.required;
  if (trimmed.length > staffNameMaxLength) return StaffIssue.tooLong;
  return null;
}

/// PIN baru tepat 6 angka dan kolom ulangi sama (aturan 1.1b/1.25b).
Map<CredentialField, StaffIssue> validatePinPair(String pin, String retype) =>
    _pair(
      _pinPattern.hasMatch(pin) ? null : StaffIssue.invalidPin,
      pin,
      retype,
      StaffIssue.pinMismatch,
    );

/// Kata sandi baru minimal [passwordMinLength] karakter dan kolom ulangi
/// sama.
Map<CredentialField, StaffIssue> validatePasswordPair(
  String password,
  String retype,
) => _pair(
  password.length < passwordMinLength ? StaffIssue.passwordTooShort : null,
  password,
  retype,
  StaffIssue.passwordMismatch,
);

Map<CredentialField, StaffIssue> _pair(
  StaffIssue? secretIssue,
  String secret,
  String retype,
  StaffIssue mismatch,
) => {
  CredentialField.secret: ?secretIssue,
  if (retype.isEmpty)
    CredentialField.retype: StaffIssue.required
  else if (retype != secret)
    CredentialField.retype: mismatch,
};

/// Kunci role custom dari [name]: snake_case ASCII, awalan `custom_` bila
/// kosong atau sama dengan role bawaan, akhiran `_2`, `_3`, … bila sudah ada
/// di [taken].
String roleKeyFor(String name, Set<String> taken) {
  final slug = name
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  final reserved = DefaultRole.values.map((r) => r.key).toSet();
  final base = slug.isEmpty
      ? 'custom'
      : (reserved.contains(slug) ? 'custom_$slug' : slug);
  if (!taken.contains(base)) return base;
  for (var i = 2; ; i++) {
    final candidate = '${base}_$i';
    if (!taken.contains(candidate)) return candidate;
  }
}

/// Kunci izin dipisah koma, urut sesuai enum [Permission].
String encodePermissions(Set<Permission> permissions) => [
  for (final p in Permission.values)
    if (permissions.contains(p)) p.key,
].join(',');

/// Kebalikan [encodePermissions]; kunci yang tidak dikenal diabaikan.
Set<Permission> decodePermissions(String keys) => {
  for (final raw in keys.split(',')) ?Permission.fromKey(raw.trim()),
};

/// Izin efektif staf: pemilik selalu semua izin; role dengan baris tersimpan
/// ([stored] tidak `null`) memakai izin itu; selain itu bawaan
/// ([permissionsForRole]).
Set<Permission> effectivePermissions({
  required String roleKey,
  bool isOwner = false,
  String? stored,
}) {
  if (isOwner) return Permission.values.toSet();
  if (stored != null) return decodePermissions(stored);
  return permissionsForRole(roleKey);
}

/// Batas wewenang: aktor yang bukan pemilik hanya boleh memberi izin yang ia
/// miliki sendiri.
StaffIssue? grantIssue({
  required bool actorIsOwner,
  required Set<Permission> actorPermissions,
  required Set<Permission> granted,
}) {
  if (actorIsOwner) return null;
  return actorPermissions.containsAll(granted)
      ? null
      : StaffIssue.beyondOwnPermissions;
}
