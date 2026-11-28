import 'package:lakuna_server/src/sync/admin_cli.dart';
import 'package:test/test.dart';

void main() {
  test('activation-code: catatan wajib, hari bawaan 30, mode production', () {
    final cmd =
        parseAdminCommand([
              'activation-code',
              '--note',
              'Toko Ani',
            ])
            as ActivationCodeCommand;
    expect(cmd.note, 'Toko Ani');
    expect(cmd.days, 30);
    expect(cmd.mode, 'production');
  });

  test('activation-code dengan --days dan --mode', () {
    final cmd =
        parseAdminCommand([
              'activation-code',
              '--note=Toko Budi',
              '--days',
              '7',
              '--mode',
              'development',
            ])
            as ActivationCodeCommand;
    expect(cmd.days, 7);
    expect(cmd.mode, 'development');
  });

  test('perintah tak dikenal atau catatan kosong: galat penggunaan', () {
    expect(() => parseAdminCommand([]), throwsA(isA<AdminUsageException>()));
    expect(
      () => parseAdminCommand(['hapus-semua']),
      throwsA(isA<AdminUsageException>()),
    );
    expect(
      () => parseAdminCommand(['activation-code', '--note', ' ']),
      throwsA(isA<AdminUsageException>()),
    );
    expect(
      () =>
          parseAdminCommand(['activation-code', '--note', 'A', '--days', '0']),
      throwsA(isA<AdminUsageException>()),
    );
  });

  test('totp-reset: email wajib, mode bawaan production', () {
    final cmd =
        parseAdminCommand(['totp-reset', '--email', ' Sari@Contoh.id '])
            as TotpResetCommand;
    expect(cmd.email, 'sari@contoh.id');
    expect(cmd.mode, 'production');
    expect(
      () => parseAdminCommand(['totp-reset']),
      throwsA(isA<AdminUsageException>()),
    );
    expect(
      () => parseAdminCommand(['totp-reset', '--email', 'bukan-email']),
      throwsA(isA<AdminUsageException>()),
    );
  });
}
