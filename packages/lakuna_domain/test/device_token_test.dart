import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  test('token perangkat 256 bit acak, base64url tanpa padding', () {
    final a = newDeviceToken();
    final b = newDeviceToken();
    expect(a, hasLength(43));
    expect(a, matches(RegExp(r'^[A-Za-z0-9_-]+$')));
    expect(a, isNot(b));
  });

  test('hash token = SHA-256 hex, stabil', () {
    expect(
      secretHash('abc'),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
  });

  test('kode pasang/aktivasi: panjang tetap, huruf tidak membingungkan', () {
    final code = newShortCode(8);
    expect(code, hasLength(8));
    expect(code, matches(RegExp(r'^[23456789ABCDEFGHJKMNPQRSTUVWXYZ]+$')));
  });

  test('normalizeShortCode: huruf kecil, spasi, dan strip diabaikan', () {
    expect(normalizeShortCode(' ab3d-ef7h '), 'AB3DEF7H');
  });
}
