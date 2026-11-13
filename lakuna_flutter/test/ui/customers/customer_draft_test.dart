import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/ui/customers/customer_form_dialog.dart';

void main() {
  test('kata pencarian Kasir menjadi isian awal pelanggan baru', () {
    expect(customerDraftFromQuery(''), (name: '', phone: ''));
    expect(customerDraftFromQuery('  Siti '), (name: 'Siti', phone: ''));
    expect(customerDraftFromQuery('0812 3456-789'), (
      name: '',
      phone: '0812 3456-789',
    ));
    expect(customerDraftFromQuery('+62812'), (name: '', phone: '+62812'));
    expect(customerDraftFromQuery('Toko 88'), (name: 'Toko 88', phone: ''));
  });
}
