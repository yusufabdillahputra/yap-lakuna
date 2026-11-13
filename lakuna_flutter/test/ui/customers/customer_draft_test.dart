import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/ui/customers/customer_form_dialog.dart';

void main() {
  test('kata pencarian Kasir menjadi isian awal pelanggan baru', () {
    expect(customerDraftFromQuery(''), (name: '', phone: ''));
    expect(customerDraftFromQuery('  Siti '), (name: 'Siti', phone: ''));
    // HP dinormalisasi agar form menampilkannya rapi.
    expect(customerDraftFromQuery('0812-3456-7890'), (
      name: '',
      phone: '081234567890',
    ));
    expect(customerDraftFromQuery('+62 812 3456'), (
      name: '',
      phone: '08123456',
    ));
    expect(customerDraftFromQuery('(021) 555.1234'), (
      name: '',
      phone: '0215551234',
    ));
    // Terlalu pendek untuk nomor: dianggap nama.
    expect(customerDraftFromQuery('88'), (name: '88', phone: ''));
    expect(customerDraftFromQuery('+'), (name: '+', phone: ''));
    expect(customerDraftFromQuery('Toko 88'), (name: 'Toko 88', phone: ''));
  });
}
