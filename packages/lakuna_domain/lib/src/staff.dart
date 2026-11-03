import 'permission.dart';

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
