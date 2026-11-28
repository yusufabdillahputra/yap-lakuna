/// Perintah admin server Lakuna (`dart bin/admin.dart` atau
/// `lakuna-admin` di container). Hanya untuk admin server, bukan peran
/// aplikasi.
library;

import 'package:args/args.dart';
import 'package:lakuna_domain/lakuna_domain.dart' show newShortCode, secretHash;
import 'package:postgres/postgres.dart' as pg;
import 'package:serverpod_shared/serverpod_shared.dart';

import 'activation.dart' show shortCodeLength;

class AdminUsageException implements Exception {
  AdminUsageException(this.message);

  final String message;

  @override
  String toString() => message;
}

sealed class AdminCommand {
  const AdminCommand(this.mode);

  /// Mode server (`development`, `staging`, `production`) untuk memilih
  /// `config/<mode>.yaml` dan kata sandi database.
  final String mode;
}

class ActivationCodeCommand extends AdminCommand {
  const ActivationCodeCommand({
    required this.note,
    required this.days,
    required String mode,
  }) : super(mode);

  final String note;
  final int days;
}

/// Menghapus verifikasi 2 langkah akun [email] (F2-02 aturan 14a).
class TotpResetCommand extends AdminCommand {
  const TotpResetCommand({required this.email, required String mode})
    : super(mode);

  final String email;
}

const adminUsage = '''
Pemakaian:
  lakuna-admin activation-code --note "<nama toko>" [--days 30] [--mode production]
  lakuna-admin totp-reset --email <email pemilik> [--mode production]

activation-code membuat kode aktivasi sekali pakai untuk versi hosting.
Kode hanya tampil sekali; berikan ke pemilik toko untuk langkah 1 Aktivasi
versi hosting.

totp-reset menghapus verifikasi 2 langkah (authenticator dan kode
cadangan) akun pemilik yang kehilangan keduanya. Pemilik lalu
mengaktifkannya ulang dari kartu Versi hosting di aplikasi.''';

AdminCommand parseAdminCommand(List<String> args) {
  final activation = ArgParser()
    ..addOption('note', help: 'Catatan, mis. nama toko pemesan.')
    ..addOption('days', defaultsTo: '30')
    ..addOption('mode', defaultsTo: 'production');
  final totpReset = ArgParser()
    ..addOption('email', help: 'Email akun pemilik.')
    ..addOption('mode', defaultsTo: 'production');
  final parser = ArgParser()
    ..addCommand('activation-code', activation)
    ..addCommand('totp-reset', totpReset);
  final ArgResults parsed;
  try {
    parsed = parser.parse(args);
  } on FormatException catch (e) {
    throw AdminUsageException('${e.message}\n\n$adminUsage');
  }
  final command = parsed.command;
  if (command == null) throw AdminUsageException(adminUsage);
  if (command.name == 'totp-reset') {
    final email = (command.option('email') ?? '').trim().toLowerCase();
    if (!RegExp(r'^[^@\s]+@[^@\s]+$').hasMatch(email)) {
      throw AdminUsageException('--email wajib diisi.\n\n$adminUsage');
    }
    return TotpResetCommand(email: email, mode: command.option('mode')!);
  }
  final note = (command.option('note') ?? '').trim();
  final days = int.tryParse(command.option('days')!) ?? 0;
  if (note.isEmpty) {
    throw AdminUsageException('--note wajib diisi.\n\n$adminUsage');
  }
  if (days < 1) {
    throw AdminUsageException('--days minimal 1.\n\n$adminUsage');
  }
  return ActivationCodeCommand(
    note: note,
    days: days,
    mode: command.option('mode')!,
  );
}

/// Menjalankan [command] terhadap database server di [serverDir] dan
/// mengembalikan teks untuk dicetak.
Future<String> runAdminCommand(
  AdminCommand command, {
  String serverDir = '.',
}) async {
  final passwords = PasswordManager(
    runMode: command.mode,
  ).loadPasswords(serverDir: serverDir);
  final config = ServerpodConfig.load(
    command.mode,
    null,
    passwords,
    serverDir: serverDir,
  );
  final db = config.database;
  if (db is! PostgresDatabaseConfig) {
    throw AdminUsageException('Database Postgres belum diatur.');
  }
  final connection = await pg.Connection.open(
    pg.Endpoint(
      host: db.host,
      port: db.port,
      database: db.name,
      username: db.user,
      password: db.password,
    ),
    settings: pg.ConnectionSettings(
      sslMode: db.requireSsl ? pg.SslMode.require : pg.SslMode.disable,
    ),
  );
  try {
    switch (command) {
      case ActivationCodeCommand(:final note, :final days):
        final code = newShortCode(shortCodeLength);
        final now = DateTime.now().toUtc();
        await connection.execute(
          pg.Sql.named(
            'INSERT INTO activation_codes '
            '(code_hash, note, created_at, expires_at) '
            'VALUES (@hash, @note, @created, @expires)',
          ),
          parameters: {
            'hash': secretHash(code),
            'note': note,
            'created': now,
            'expires': now.add(Duration(days: days)),
          },
        );
        final shown = '${code.substring(0, 4)}-${code.substring(4)}';
        return 'Kode aktivasi untuk "$note" (berlaku $days hari):\n\n'
            '    $shown\n\n'
            'Kode hanya tampil sekali.';
      case TotpResetCommand(:final email):
        return await connection.runTx((tx) async {
          final users = await tx.execute(
            pg.Sql.named(
              'SELECT "authUserId" FROM serverpod_auth_idp_email_account '
              'WHERE lower(email) = @email',
            ),
            parameters: {'email': email},
          );
          if (users.isEmpty) {
            throw AdminUsageException('Akun dengan email $email tidak ada.');
          }
          final userId = users.first.first;
          for (final table in ['owner_backup_codes', 'owner_totp']) {
            await tx.execute(
              pg.Sql.named('DELETE FROM $table WHERE auth_user_id = @user'),
              parameters: {'user': userId},
            );
          }
          return 'Verifikasi 2 langkah $email dihapus. Pemilik bisa '
              'mengaktifkannya ulang dari kartu Versi hosting di aplikasi.';
        });
    }
  } finally {
    await connection.close();
  }
}
