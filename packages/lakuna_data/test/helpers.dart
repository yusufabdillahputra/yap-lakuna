import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

/// Membuka store baru di folder sementara. Folder dihapus oleh [Directory.delete]
/// di tearDown pemanggil.
Future<(LakunaStore, Directory)> openTempStore({
  DateTime Function()? clock,
}) async {
  final dir = await Directory.systemTemp.createTemp('lakuna_test_');
  final store = await LakunaStore.open(
    '${dir.path}/lakuna.sqlite',
    clock: clock,
  );
  return (store, dir);
}

const testCredentials = SetupCredentials(
  pinHash: r'$argon2id$pin',
  passwordHash: r'$argon2id$password',
);

/// Toko retail contoh dengan [outletCode] dan [email] yang bisa dibedakan
/// bila satu tes butuh dua toko.
Future<StoreContext> setupTestStore(
  LakunaStore store, {
  String outletCode = 'PST',
  String email = 'yusuf@contoh.id',
}) => setupStore(
  store,
  SetupInput(
    businessType: BusinessKind.retail,
    businessName: 'Warung Contoh',
    outletName: 'Cabang Pusat',
    outletCode: outletCode,
    deviceCode: 'K01',
    timezone: 'Asia/Jakarta',
    ownerName: 'Yusuf',
    email: email,
    password: 'rahasia123',
    passwordConfirm: 'rahasia123',
    pin: '123456',
    pinConfirm: '123456',
  ),
  platform: DevicePlatform.linux,
  credentials: testCredentials,
);
