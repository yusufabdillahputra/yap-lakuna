import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/data/services/guide_markdown.dart';

void main() {
  test('judul, paragraf, H2, daftar, kotak, gambar', () {
    final doc = parseGuideMarkdown('''
# Menerima QRIS statis

Versi gratis memakai gambar QRIS
statis milik toko.

## Langkah

1. Pilih **QRIS statis**.
2. Tekan *Sudah Terbayar*.

- Satu gambar per cabang
- Lihat [Split payment](split-payment)

> [!warning] Jangan tekan Sudah Terbayar
> hanya dari tangkapan layar.

> [!note] Catatan singkat.

![Layar bayar QRIS](pay-qris)
''');
    expect(doc.title, 'Menerima QRIS statis');
    expect(doc.blocks.map((b) => b.runtimeType.toString()), [
      'GuideParagraph',
      'GuideHeading',
      'GuideList',
      'GuideList',
      'GuideCallout',
      'GuideCallout',
      'GuideImage',
    ]);
    final p = doc.blocks[0] as GuideParagraph;
    expect(
      p.spans.single.text,
      'Versi gratis memakai gambar QRIS statis milik toko.',
    );
    final ol = doc.blocks[2] as GuideList;
    expect(ol.ordered, isTrue);
    expect(ol.items, hasLength(2));
    expect(ol.items[0].map((s) => (s.text, s.style)), [
      ('Pilih ', GuideSpanStyle.plain),
      ('QRIS statis', GuideSpanStyle.bold),
      ('.', GuideSpanStyle.plain),
    ]);
    expect(ol.items[1][1].style, GuideSpanStyle.italic);
    final ul = doc.blocks[3] as GuideList;
    expect(ul.ordered, isFalse);
    final link = ul.items[1][1];
    expect(link.text, 'Split payment');
    expect(link.link, 'split-payment');
    final warn = doc.blocks[4] as GuideCallout;
    expect(warn.kind, GuideCalloutKind.warning);
    expect(
      warn.spans.single.text,
      'Jangan tekan Sudah Terbayar hanya dari tangkapan layar.',
    );
    expect((doc.blocks[5] as GuideCallout).kind, GuideCalloutKind.note);
    final img = doc.blocks[6] as GuideImage;
    expect(img.name, 'pay-qris');
    expect(img.caption, 'Layar bayar QRIS');
    expect(doc.links, ['split-payment']);
    expect(doc.images, ['pay-qris']);
    expect(doc.plainText, contains('milik toko'));
    expect(doc.plainText, contains('Split payment'));
    expect(doc.plainText, isNot(contains('**')));
  });

  test('tanpa judul H1 ditolak', () {
    expect(
      () => parseGuideMarkdown('Paragraf saja'),
      throwsA(isA<FormatException>()),
    );
  });

  test('kotak tanpa jenis dikenal ditolak', () {
    expect(
      () => parseGuideMarkdown('# J\n\n> [!danger] x'),
      throwsA(isA<FormatException>()),
    );
  });

  test('tanda bintang tunggal tanpa pasangan tetap teks', () {
    final doc = parseGuideMarkdown('# J\n\nHarga 5 * 2 = 10.');
    final p = doc.blocks.single as GuideParagraph;
    expect(p.spans.map((s) => s.text).join(), 'Harga 5 * 2 = 10.');
  });

  test('sub-daftar menjorok di antara langkah bernomor', () {
    final doc = parseGuideMarkdown(
      '# J\n\n1. Pilih:\n   - a\n   - b\n2. Simpan.\n\n- poin',
    );
    final lists = doc.blocks.cast<GuideList>();
    expect(lists.map((l) => (l.ordered, l.nested, l.items.length)), [
      (true, false, 1),
      (false, true, 2),
      (true, false, 1),
      (false, false, 1),
    ]);
    expect(lists.first.numbers, [1]);
    expect(lists.elementAt(2).numbers, [2]);
  });

  test('daftar bernomor lanjut setelah baris kosong tetap satu daftar', () {
    final doc = parseGuideMarkdown('# J\n\n1. a\n\n2. b\n\nAkhir.');
    expect((doc.blocks.first as GuideList).items, hasLength(2));
    expect(doc.blocks, hasLength(2));
  });

  test('### dan dua kotak tanpa baris kosong ditolak', () {
    expect(
      () => parseGuideMarkdown('# J\n\n### Kecil'),
      throwsFormatException,
    );
    expect(
      () => parseGuideMarkdown('# J\n\n> [!note] a\n> [!warning] b'),
      throwsFormatException,
    );
  });
}
