import 'package:lakuna_domain/lakuna_domain.dart';

/// Staf yang bertugas tidak punya [permission] (atau belum ada yang login).
class NotPermitted implements Exception {
  const NotPermitted(this.permission);

  final Permission permission;

  @override
  String toString() => 'NotPermitted(${permission.key})';
}

/// Konteks toko belum termuat; layar modul belum bisa dipakai.
class StoreNotReady implements Exception {
  const StoreNotReady();

  @override
  String toString() => 'StoreNotReady';
}
