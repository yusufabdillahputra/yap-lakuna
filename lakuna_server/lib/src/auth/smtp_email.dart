/// Pengiriman kode verifikasi email lewat SMTP (F2-01). Server Lakuna
/// berjalan di VPS sendiri, jadi email tidak dikirim lewat Serverpod Cloud.
/// Tanpa pengaturan SMTP (pengembangan, tes) kode dicatat di log server.
library;

import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

/// Kunci `passwords.yaml` / `SERVERPOD_PASSWORD_<kunci>` untuk SMTP.
const smtpPasswordKeys = [
  'smtpHost',
  'smtpPort',
  'smtpUser',
  'smtpPassword',
  'smtpFrom',
];

class SmtpSettings {
  const SmtpSettings({
    required this.host,
    required this.port,
    required this.fromAddress,
    this.fromName,
    this.username,
    this.password,
  });

  /// `null` bila `smtpHost` atau `smtpFrom` belum diisi.
  static SmtpSettings? fromPasswords(Map<String, String?> passwords) {
    final host = passwords['smtpHost']?.trim() ?? '';
    final from = passwords['smtpFrom']?.trim() ?? '';
    if (host.isEmpty || from.isEmpty) return null;
    final named = RegExp(r'^(.*)<(.+)>$').firstMatch(from);
    return SmtpSettings(
      host: host,
      port: int.tryParse(passwords['smtpPort'] ?? '') ?? 587,
      fromAddress: (named?.group(2) ?? from).trim(),
      fromName: named?.group(1)?.trim().isEmpty ?? true
          ? null
          : named!.group(1)!.trim(),
      username: passwords['smtpUser'],
      password: passwords['smtpPassword'],
    );
  }

  final String host;
  final int port;
  final String fromAddress;
  final String? fromName;
  final String? username;
  final String? password;

  /// Port 465 = SSL langsung; port lain memakai STARTTLS.
  bool get ssl => port == 465;

  SmtpServer get server => SmtpServer(
    host,
    port: port,
    ssl: ssl,
    username: username,
    password: password,
  );
}

enum VerificationKind { registration, passwordReset, login }

/// Subjek dan isi email kode verifikasi.
({String subject, String body}) verificationEmail(
  VerificationKind kind,
  String code,
) {
  final (subject, purpose) = switch (kind) {
    VerificationKind.registration => (
      'Kode verifikasi Lakuna: $code',
      'mendaftarkan akun pemilik Lakuna',
    ),
    VerificationKind.passwordReset => (
      'Kode atur ulang kata sandi Lakuna: $code',
      'mengatur ulang kata sandi akun Lakuna',
    ),
    VerificationKind.login => (
      'Kode masuk Lakuna: $code',
      'masuk ke akun Lakuna',
    ),
  };
  return (
    subject: subject,
    body:
        'Kode untuk $purpose:\n\n'
        '    $code\n\n'
        'Kode ini hanya berlaku sebentar. Abaikan email ini bila Anda tidak '
        'memintanya.\n',
  );
}

/// Konfigurasi email Serverpod yang mengirim kode lewat SMTP dari
/// `passwords.yaml`, atau mencatatnya di log bila SMTP belum diatur.
EmailIdpConfigFromPasswords smtpEmailIdpConfig() {
  Future<void> deliver(
    Session session,
    VerificationKind kind,
    String email,
    String code,
  ) async {
    final settings = SmtpSettings.fromPasswords({
      for (final key in smtpPasswordKeys)
        key: Serverpod.instance.getPassword(key),
    });
    if (settings == null) {
      session.log(
        'SMTP belum diatur; kode ${kind.name} untuk $email: $code',
        level: LogLevel.warning,
      );
      return;
    }
    final content = verificationEmail(kind, code);
    final message = mailer.Message()
      ..from = mailer.Address(settings.fromAddress, settings.fromName)
      ..recipients.add(email)
      ..subject = content.subject
      ..text = content.body;
    try {
      await mailer.send(message, settings.server);
    } on Object catch (e) {
      // Sama seperti pengirim bawaan: jangan gagalkan pendaftaran atau
      // membocorkan apakah akun ada; admin melihatnya di log.
      session.log('Gagal mengirim email ke $email: $e', level: LogLevel.error);
    }
  }

  return EmailIdpConfigFromPasswords(
    sendRegistrationVerificationCode:
        (
          session, {
          required email,
          required accountRequestId,
          required verificationCode,
          required transaction,
        }) => deliver(
          session,
          VerificationKind.registration,
          email,
          verificationCode,
        ),
    sendPasswordResetVerificationCode:
        (
          session, {
          required email,
          required passwordResetRequestId,
          required verificationCode,
          required transaction,
        }) => deliver(
          session,
          VerificationKind.passwordReset,
          email,
          verificationCode,
        ),
    sendOtpLoginVerificationCode:
        (
          session, {
          required email,
          required otpLoginRequestId,
          required verificationCode,
          required transaction,
        }) => deliver(session, VerificationKind.login, email, verificationCode),
  );
}
