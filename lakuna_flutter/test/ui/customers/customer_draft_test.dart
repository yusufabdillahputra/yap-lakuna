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
    // Aturan sama dengan pencarian HP (F1-13f): garis miring, garis miring
    // dan tanda hubung Unicode, tanda arah tak terlihat dari WhatsApp.
    expect(customerDraftFromQuery('021/5551234'), (
      name: '',
      phone: '0215551234',
    ));
    expect(customerDraftFromQuery('0813\uFF0F2222\u20111010'), (
      name: '',
      phone: '081322221010',
    ));
    expect(customerDraftFromQuery('021\u20445551234'), (
      name: '',
      phone: '0215551234',
    ));
    expect(customerDraftFromQuery('\u202A+62 813-2222-1010\u202C'), (
      name: '',
      phone: '081322221010',
    ));
    expect(customerDraftFromQuery('0813_2222'), (name: '0813_2222', phone: ''));
    expect(customerDraftFromQuery('12/3'), (name: '12/3', phone: ''));
    // Terlalu pendek untuk nomor: dianggap nama.
    expect(customerDraftFromQuery('88'), (name: '88', phone: ''));
    expect(customerDraftFromQuery('+'), (name: '+', phone: ''));
    expect(customerDraftFromQuery('Toko 88'), (name: 'Toko 88', phone: ''));
  });
}
