import 'package:lakuna_server/src/auth/smtp_email.dart';
import 'package:test/test.dart';

void main() {
  group('SmtpSettings.fromPasswords', () {
    test('lengkap: host, port, akun, pengirim', () {
      final s = SmtpSettings.fromPasswords({
        'smtpHost': 'smtp.example.id',
        'smtpPort': '465',
        'smtpUser': 'kasir@example.id',
        'smtpPassword': 'rahasia',
        'smtpFrom': 'Lakuna <kasir@example.id>',
      })!;
      expect(s.host, 'smtp.example.id');
      expect(s.port, 465);
      expect(s.ssl, isTrue);
      expect(s.fromAddress, 'kasir@example.id');
      expect(s.fromName, 'Lakuna');
    });

    test('port 587 memakai STARTTLS, bukan SSL langsung', () {
      final s = SmtpSettings.fromPasswords({
        'smtpHost': 'smtp.example.id',
        'smtpPort': '587',
        'smtpFrom': 'kasir@example.id',
      })!;
      expect(s.ssl, isFalse);
      expect(s.fromName, isNull);
    });

    test('tanpa host atau pengirim: null (kode dicatat di log)', () {
      expect(SmtpSettings.fromPasswords({}), isNull);
      expect(
        SmtpSettings.fromPasswords({'smtpHost': 'smtp.example.id'}),
        isNull,
      );
    });
  });

  test('isi email kode verifikasi dalam Bahasa Indonesia', () {
    final email = verificationEmail(VerificationKind.registration, '123456');
    expect(email.subject, 'Kode verifikasi Lakuna: 123456');
    expect(email.body, contains('123456'));
    expect(email.body, contains('Abaikan email ini'));
    final reset = verificationEmail(VerificationKind.passwordReset, '654321');
    expect(reset.subject, 'Kode atur ulang kata sandi Lakuna: 654321');
  });
}
