import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Informasi lingkungan yang ditampilkan di aplikasi.
class AppEnvironment {
  const AppEnvironment({
    required this.databasePath,
    required this.deviceId,
    required this.version,
  });

  final String databasePath;
  final String deviceId;
  final String version;
}

/// Versi aplikasi; disamakan dengan `version` di pubspec.yaml oleh
/// `release.yml` (`--dart-define=LAKUNA_VERSION=...`). Build lokal tanpa
/// define menampilkan `dev` agar tidak ada angka versi yang usang.
const appVersion = String.fromEnvironment(
  'LAKUNA_VERSION',
  defaultValue: 'dev',
);

/// Lokasi berkas database. `LAKUNA_DATA_DIR` menggantinya untuk uji manual.
Future<String> resolveDatabasePath() async {
  const fileName = 'lakuna.sqlite';
  if (kIsWeb) return fileName;
  final override = Platform.environment['LAKUNA_DATA_DIR'];
  final dir = (override != null && override.isNotEmpty)
      ? Directory(override)
      : await getApplicationSupportDirectory();
  await dir.create(recursive: true);
  return p.join(dir.path, fileName);
}
