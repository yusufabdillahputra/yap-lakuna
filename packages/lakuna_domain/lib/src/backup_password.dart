import 'package:characters/characters.dart';

import 'setup.dart' show passwordMinLength;

// Kata sandi pengunci backup (F1-19c). Tidak disimpan di perangkat; hanya
// dipakai menurunkan kunci enkripsi berkas.

/// Panjang minimum kata sandi backup (sama dengan kata sandi pemilik).
const backupPasswordMinLength = passwordMinLength;

/// Panjang maksimum kata sandi backup (karakter).
const backupPasswordMaxLength = 128;

/// Masalah isian kata sandi backup.
enum BackupPasswordProblem { tooShort, tooLong, mismatch }

/// `null` bila [password] sah dan [retype] sama persis. Panjang dihitung
/// per karakter (emoji = satu).
BackupPasswordProblem? backupPasswordProblem(String password, String retype) {
  final length = password.characters.length;
  if (length < backupPasswordMinLength) return BackupPasswordProblem.tooShort;
  if (length > backupPasswordMaxLength) return BackupPasswordProblem.tooLong;
  if (retype != password) return BackupPasswordProblem.mismatch;
  return null;
}
