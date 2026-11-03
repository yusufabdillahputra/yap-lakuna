import 'dart:io';

import 'package:lakuna_data/lakuna_data.dart';

/// Membuka store baru di folder sementara. Folder dihapus oleh [Directory.delete]
/// di tearDown pemanggil.
Future<(LakunaStore, Directory)> openTempStore({DateTime Function()? clock}) async {
  final dir = await Directory.systemTemp.createTemp('lakuna_test_');
  final store = await LakunaStore.open('${dir.path}/lakuna.sqlite', clock: clock);
  return (store, dir);
}
