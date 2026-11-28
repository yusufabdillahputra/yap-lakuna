import 'dart:io';

/// Menghapus database di [path] beserta berkas WAL/jurnalnya. Database harus
/// sudah ditutup.
Future<void> deleteWebDatabase(String path) async {
  for (final suffix in ['', '-wal', '-shm', '-journal']) {
    final file = File('$path$suffix');
    if (file.existsSync()) await file.delete();
  }
}
