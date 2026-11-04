import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Hasil menyerahkan berkas backup ke pengguna.
sealed class BackupDelivery {
  const BackupDelivery();
}

/// Disimpan di [path] (desktop).
class BackupSaved extends BackupDelivery {
  const BackupSaved(this.path);

  final String path;
}

/// Dibagikan lewat share sheet (Android/iOS).
class BackupShared extends BackupDelivery {
  const BackupShared();
}

/// Pengguna menutup share sheet tanpa memilih tujuan.
class BackupDismissed extends BackupDelivery {
  const BackupDismissed();
}

/// Menyimpan / membagikan berkas backup dan memilih berkas untuk dipulihkan
/// (F1-19). Diabstraksikan agar alurnya bisa diuji.
abstract class BackupFiles {
  const BackupFiles();

  Future<BackupDelivery> deliver(String path, {required String fileName});

  /// Lokasi berkas `.zip` pilihan pengguna; `null` bila dibatalkan.
  Future<String?> pickBackup();
}

/// Folder backup desktop: `Dokumen/Lakuna/Backup`.
Future<Directory> backupDirectory() async {
  try {
    final docs = await getApplicationDocumentsDirectory();
    return Directory(p.join(docs.path, 'Lakuna', 'Backup'));
  } on MissingPlatformDirectoryException {
    final base = await getApplicationSupportDirectory();
    return Directory(p.join(base.path, 'Backup'));
  }
}

class PlatformBackupFiles extends BackupFiles {
  const PlatformBackupFiles();

  static const _zip = XTypeGroup(
    label: 'Backup Lakuna (.zip)',
    extensions: ['zip'],
    mimeTypes: ['application/zip', 'application/x-zip-compressed'],
    uniformTypeIdentifiers: ['public.zip-archive'],
  );

  bool get _mobile => Platform.isAndroid || Platform.isIOS;

  @override
  Future<BackupDelivery> deliver(
    String path, {
    required String fileName,
  }) async {
    if (_mobile) {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path, mimeType: 'application/zip', name: fileName)],
          fileNameOverrides: [fileName],
        ),
      );
      return result.status == ShareResultStatus.dismissed
          ? const BackupDismissed()
          : const BackupShared();
    }
    final dir = await backupDirectory();
    await dir.create(recursive: true);
    // Dua backup di menit yang sama tidak saling menimpa.
    var target = p.join(dir.path, fileName);
    final stem = p.basenameWithoutExtension(fileName);
    for (var i = 2; File(target).existsSync(); i++) {
      target = p.join(dir.path, '$stem-$i.zip');
    }
    await File(path).copy(target);
    return BackupSaved(target);
  }

  @override
  Future<String?> pickBackup() async {
    final file = await openFile(acceptedTypeGroups: const [_zip]);
    return file?.path;
  }
}
