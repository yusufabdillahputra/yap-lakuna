import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  test('kolom per lebar kertas', () {
    expect(ReceiptPaper.mm58.columns, 32);
    expect(ReceiptPaper.mm80.columns, 48);
  });

  group('wrapText', () {
    test('bungkus per kata, tanpa spasi berlebih', () {
      expect(wrapText('Beras  Premium   Pandan Wangi 5 kg', 12), [
        'Beras',
        'Premium',
        'Pandan Wangi',
        '5 kg',
      ]);
    });

    test('kata lebih panjang dari kolom dipotong paksa', () {
      expect(wrapText('ABCDEFGHIJ KL', 4), ['ABCD', 'EFGH', 'IJ', 'KL']);
    });

    test('teks kosong → tanpa baris', () {
      expect(wrapText('   ', 10), isEmpty);
    });
  });

  group('layoutPair', () {
    test('muat: label kiri, nilai kanan, lebar penuh', () {
      final lines = layoutPair('TOTAL', '180.000', 32, bold: true);
      expect(lines, [
        const ReceiptLine('TOTAL                    180.000', bold: true),
      ]);
      expect(lines.single.text.length, 32);
    });

    test('tidak muat: label di baris sendiri, nilai rata kanan', () {
      final lines = layoutPair('No', 'PST-K01-261103-0001-PANJANG-SEKALI', 32);
      expect(lines, [
        const ReceiptLine('No'),
        const ReceiptLine(
          'PST-K01-261103-0001-PANJANG-SEKA',
          align: ReceiptAlign.right,
        ),
        const ReceiptLine('LI', align: ReceiptAlign.right),
      ]);
    });

    test('pas: label + satu spasi + nilai = kolom', () {
      expect(
        layoutPair('A' * 20, 'B' * 11, 32).single.text,
        '${'A' * 20} ${'B' * 11}',
      );
    });
  });

  group('layoutReceipt', () {
    const content = ReceiptContent(
      storeName: 'WARUNG CONTOH',
      outletName: 'Cabang Pusat',
      header: ['Jl. Melati No. 12', '0812-0000-0001'],
      meta: [
        ReceiptPair('No', 'PST-K01-261103-0001'),
        ReceiptPair('Tgl', '03/11/26 16.00'),
        ReceiptPair('Kasir', 'Sari'),
      ],
      items: [
        ReceiptItem(
          name: 'Beras Premium 5 kg',
          detail: '2 x 70.000',
          amount: '140.000',
        ),
        ReceiptItem(
          name: 'Minyak Goreng Kemasan Pouch Isi Ulang 2 L',
          detail: '1 Dus x 210.000',
          amount: '210.000',
        ),
      ],
      totals: [
        ReceiptPair('TOTAL', '350.000', bold: true),
        ReceiptPair('Tunai', '400.000'),
        ReceiptPair('Kembali', '50.000'),
      ],
      footer: ['Terima kasih, sampai jumpa lagi!'],
    );

    test('58 mm: urutan bagian dan isi baris', () {
      final lines = layoutReceipt(content, ReceiptPaper.mm58);
      final rule = '-' * 32;
      expect(lines.map((l) => l.text), [
        'WARUNG CONTOH',
        'Cabang Pusat',
        'Jl. Melati No. 12',
        '0812-0000-0001',
        rule,
        'No           PST-K01-261103-0001',
        'Tgl               03/11/26 16.00',
        'Kasir                       Sari',
        rule,
        'Beras Premium 5 kg',
        '  2 x 70.000             140.000',
        'Minyak Goreng Kemasan Pouch Isi',
        'Ulang 2 L',
        '  1 Dus x 210.000        210.000',
        rule,
        'TOTAL                    350.000',
        'Tunai                    400.000',
        'Kembali                   50.000',
        rule,
        'Terima kasih, sampai jumpa lagi!',
      ]);
      expect(lines.first.bold, isTrue);
      expect(lines.first.align, ReceiptAlign.center);
      expect(lines[2].align, ReceiptAlign.center);
      expect(lines[15].bold, isTrue);
      expect(lines.last.align, ReceiptAlign.center);
      for (final l in lines) {
        expect(l.text.length, lessThanOrEqualTo(32), reason: l.text);
      }
    });

    test('80 mm: pasangan selebar 48 kolom', () {
      final lines = layoutReceipt(content, ReceiptPaper.mm80);
      expect(lines.map((l) => l.text), contains('TOTAL${' ' * 36}350.000'));
      expect(lines.map((l) => l.text), contains('-' * 48));
      expect(
        lines.map((l) => l.text),
        contains('Minyak Goreng Kemasan Pouch Isi Ulang 2 L'),
      );
    });

    test('label status (mis. CETAK ULANG) tebal di tengah setelah header', () {
      const reprint = ReceiptContent(
        storeName: 'TOKO',
        banner: 'CETAK ULANG',
        totals: [ReceiptPair('TOTAL', '1.000')],
      );
      final lines = layoutReceipt(reprint, ReceiptPaper.mm58);
      expect(lines.map((l) => l.text), [
        'TOKO',
        '-' * 32,
        'CETAK ULANG',
        '-' * 32,
        'TOTAL                      1.000',
      ]);
      expect(lines[2].bold, isTrue);
      expect(lines[2].align, ReceiptAlign.center);
    });
  });

  group('teks header/footer', () {
    test('receiptTextLines: rapikan dan buang baris kosong', () {
      expect(receiptTextLines('  Jl. Melati 12 \n\n 0812  \n'), [
        'Jl. Melati 12',
        '0812',
      ]);
      expect(receiptTextLines(null), isEmpty);
    });

    test('validateReceiptSettings: maks 4 baris, 48 karakter', () {
      expect(
        validateReceiptSettings(header: 'a\nb\nc\nd', footer: null),
        isEmpty,
      );
      expect(
        validateReceiptSettings(header: 'a\nb\nc\nd\ne', footer: 'x' * 49),
        {
          ReceiptSettingsError.headerTooManyLines,
          ReceiptSettingsError.footerLineTooLong,
        },
      );
      expect(
        validateReceiptSettings(header: 'y' * 49, footer: '1\n2\n3\n4\n5'),
        {
          ReceiptSettingsError.headerLineTooLong,
          ReceiptSettingsError.footerTooManyLines,
        },
      );
    });
  });

  test('teks non-ASCII diratakan dulu agar satu karakter = satu kolom '
      '(emoji, ß, aksen terurai)', () {
    const nfdCafe = 'Cafe\u0301';
    final lines = [
      ...layoutPair('Kopi \u2615 $nfdCafe', '12.000', 32),
      ...layoutPair('Stra\u00dfe', '1.000', 32),
      for (final l in wrapText('Teh \u{1F375} manis $nfdCafe', 10))
        ReceiptLine(l),
    ];
    for (final l in lines.take(2)) {
      expect(l.text.length, 32, reason: l.text);
    }
    for (final l in lines) {
      expect(l.text, receiptAscii(l.text), reason: l.text);
      expect(l.text.length, lessThanOrEqualTo(32));
    }
    expect(lines.first.text, startsWith('Kopi ? Cafe '));
  });

  test('modifier tampil di bawah nama item, menjorok', () {
    final lines = layoutReceipt(
      const ReceiptContent(
        storeName: 'KOPI',
        items: [
          ReceiptItem(
            name: 'Kopi Susu Aren',
            extras: ['+ Besar', '+ Tanpa gula -3.000'],
            detail: '2 x 24.000',
            amount: '50.000',
          ),
        ],
      ),
      ReceiptPaper.mm58,
    ).map((l) => l.text).toList();
    final i = lines.indexOf('Kopi Susu Aren');
    expect(lines.sublist(i + 1, i + 3), ['  + Besar', '  + Tanpa gula -3.000']);
    expect(lines[i + 3], startsWith('  2 x 24.000'));
  });
}
