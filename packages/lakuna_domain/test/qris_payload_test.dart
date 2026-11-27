import 'dart:convert';

import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

/// Panjang TLV dihitung dalam byte UTF-8, seperti pembuat QRIS.
String _tlv(String tag, String value) =>
    '$tag${utf8.encode(value).length.toString().padLeft(2, '0')}$value';

/// Payload QRIS dengan CRC benar (tag 63 dihitung).
String _qris({
  String method = '11',
  String merchantTag = '51',
  String guid = 'ID.CO.QRIS.WWW',
  String nmid = 'ID10234567890',
  String name = 'WARUNG CONTOH',
  String? terminal = 'A01',
  bool withAmount = false,
}) {
  final body = [
    _tlv('00', '01'),
    _tlv('01', method),
    _tlv(
      '26',
      _tlv('00', 'ID.DANA.WWW') +
          _tlv('01', '936009150000000001') +
          _tlv('02', '1234567890') +
          _tlv('03', 'UMI'),
    ),
    _tlv(merchantTag, _tlv('00', guid) + _tlv('02', nmid) + _tlv('03', 'UMI')),
    _tlv('52', '5812'),
    _tlv('53', '360'),
    if (withAmount) _tlv('54', '15000'),
    _tlv('58', 'ID'),
    _tlv('59', name),
    _tlv('60', 'BANDUNG'),
    if (terminal != null) _tlv('62', _tlv('07', terminal)),
    '6304',
  ].join();
  return body + qrisCrc16(body);
}

void main() {
  test('CRC16-CCITT-FALSE sesuai contoh EMVCo', () {
    expect(qrisCrc16('123456789'), '29B1');
  });

  test('QRIS statis lengkap', () {
    final p = parseQrisPayload(_qris())!;
    expect(p.isStatic, isTrue);
    expect(p.nmid, 'ID10234567890');
    expect(p.merchantName, 'WARUNG CONTOH');
    expect(p.city, 'BANDUNG');
    expect(p.terminalLabel, 'A01');
  });

  test('payload contoh nyata (CRC FD1E)', () {
    const text =
        '00020101021126580011ID.DANA.WWW0118936009150000000001021012345678900'
        '303UMI51420014ID.CO.QRIS.WWW0213ID102345678900303UMI52045812530336058'
        '02ID5913WARUNG CONTOH6007BANDUNG61054011162070703A016304FD1E';
    final p = parseQrisPayload(text)!;
    expect(p.nmid, 'ID10234567890');
    expect(p.isStatic, isTrue);
  });

  test('QRIS dinamis dikenali', () {
    final p = parseQrisPayload(_qris(method: '12', withAmount: true))!;
    expect(p.isStatic, isFalse);
    expect(p.nmid, 'ID10234567890');
  });

  test('GUID QRIS di tag 26–50 juga dibaca', () {
    final p = parseQrisPayload(_qris(merchantTag: '27'))!;
    expect(p.nmid, 'ID10234567890');
  });

  test('tanpa kode terminal: kosong', () {
    expect(parseQrisPayload(_qris(terminal: null))!.terminalLabel, isEmpty);
  });

  test('CRC salah, bukan QRIS, TLV rusak: null', () {
    final good = _qris();
    final bad = '${good.substring(0, good.length - 4)}0000';
    expect(parseQrisPayload(bad), isNull);
    expect(parseQrisPayload('https://warung.example/menu'), isNull);
    expect(parseQrisPayload(_qris(guid: 'ID.CO.LAIN.WWW')), isNull);
    expect(parseQrisPayload('000201010211269'), isNull);
    expect(parseQrisPayload(''), isNull);
  });

  test('nama merchant non-ASCII: panjang dan CRC dalam byte UTF-8', () {
    final p = parseQrisPayload(_qris(name: 'KOPI SENJA CAFÉ'))!;
    expect(p.merchantName, 'KOPI SENJA CAFÉ');
    expect(p.nmid, 'ID10234567890');
  });

  test('panjang TLV bukan dua digit: null, tidak melempar', () {
    for (final length in ['-1', ' 5', '+3']) {
      final body =
          '000201010211${'59'}$length'
          'AB'
          '6304';
      expect(parseQrisPayload(body + qrisCrc16(body)), isNull);
    }
  });
}
