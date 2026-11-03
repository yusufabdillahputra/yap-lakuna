import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

SetupInput _valid({
  String businessName = 'Warung Contoh',
  String outletName = 'Cabang Pusat',
  String outletCode = 'PST',
  String deviceCode = 'K01',
  String timezone = 'Asia/Jakarta',
  String ownerName = 'Yusuf',
  String email = 'yusuf@contoh.id',
  String password = 'rahasia123',
  String pin = '123456',
  String pinConfirm = '123456',
}) => SetupInput(
  businessType: BusinessKind.retail,
  businessName: businessName,
  outletName: outletName,
  outletCode: outletCode,
  deviceCode: deviceCode,
  timezone: timezone,
  ownerName: ownerName,
  email: email,
  password: password,
  pin: pin,
  pinConfirm: pinConfirm,
);

void main() {
  test('input lengkap tidak punya galat', () {
    expect(_valid().validate(), isEmpty);
  });

  group('kode cabang dan perangkat', () {
    test('dinormalkan: dipangkas dan huruf besar', () {
      final input = _valid(outletCode: ' pst ', deviceCode: 'k01');
      expect(input.outletCode, 'PST');
      expect(input.deviceCode, 'K01');
      expect(input.validate(), isEmpty);
    });

    for (final bad in ['P', 'PUSAT01', 'PS-T', 'PS T', '']) {
      test('"$bad" ditolak', () {
        expect(_valid(outletCode: bad).validate(), {
          SetupField.outletCode: SetupError.invalidCode,
        });
        expect(_valid(deviceCode: bad).validate(), {
          SetupField.deviceCode: SetupError.invalidCode,
        });
      });
    }
  });

  test('nama kosong atau lebih dari 60 karakter ditolak', () {
    expect(_valid(businessName: '   ').validate(), {
      SetupField.businessName: SetupError.required,
    });
    expect(_valid(outletName: 'x' * 61).validate(), {
      SetupField.outletName: SetupError.tooLong,
    });
    expect(_valid(ownerName: '').validate(), {
      SetupField.ownerName: SetupError.required,
    });
    expect(_valid(businessName: '  Toko Bu Ani ').businessName, 'Toko Bu Ani');
  });

  test('email wajib, format benar, disimpan huruf kecil', () {
    expect(_valid(email: '').validate(), {
      SetupField.email: SetupError.required,
    });
    expect(_valid(email: 'yusuf@contoh').validate(), {
      SetupField.email: SetupError.invalidEmail,
    });
    expect(_valid(email: ' Yusuf@Contoh.ID ').email, 'yusuf@contoh.id');
  });

  test('kata sandi minimal 8 karakter', () {
    expect(_valid(password: '1234567').validate(), {
      SetupField.password: SetupError.passwordTooShort,
    });
  });

  test('PIN tepat 6 angka dan konfirmasi sama', () {
    expect(_valid(pin: '12345', pinConfirm: '12345').validate(), {
      SetupField.pin: SetupError.invalidPin,
    });
    expect(_valid(pin: '12345a', pinConfirm: '12345a').validate(), {
      SetupField.pin: SetupError.invalidPin,
    });
    expect(_valid(pinConfirm: '654321').validate(), {
      SetupField.pinConfirm: SetupError.pinMismatch,
    });
  });

  test('zona waktu hanya WIB, WITA, WIT', () {
    expect(setupTimezones.map((z) => z.id), [
      'Asia/Jakarta',
      'Asia/Makassar',
      'Asia/Jayapura',
    ]);
    expect(setupTimezones.map((z) => z.label), ['WIB', 'WITA', 'WIT']);
    expect(_valid(timezone: 'Asia/Singapore').validate(), {
      SetupField.timezone: SetupError.invalidTimezone,
    });
  });

  test('galat bisa dibatasi per langkah wizard', () {
    final input = _valid(businessName: '', pin: '1', pinConfirm: '1');
    expect(input.validate(fields: SetupField.businessStep), {
      SetupField.businessName: SetupError.required,
    });
    expect(input.validate(fields: SetupField.ownerStep).keys, [SetupField.pin]);
  });
}
