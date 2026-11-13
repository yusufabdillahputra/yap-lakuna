/// Tata letak struk teks monospace (F1-06). Layar, kertas thermal (ESC/POS),
/// dan PDF memakai baris yang sama dari [layoutReceipt].
library;

import 'escpos.dart';

/// Lebar kertas thermal dan jumlah kolom karakter (font A).
enum ReceiptPaper {
  mm58(32),
  mm80(48);

  const ReceiptPaper(this.columns);

  /// Karakter per baris.
  final int columns;
}

enum ReceiptAlign { left, center, right }

/// Satu baris struk. [text] tidak pernah lebih panjang dari kolom kertas.
class ReceiptLine {
  const ReceiptLine(
    this.text, {
    this.align = ReceiptAlign.left,
    this.bold = false,
  });

  final String text;
  final ReceiptAlign align;
  final bool bold;

  @override
  bool operator ==(Object other) =>
      other is ReceiptLine &&
      other.text == text &&
      other.align == align &&
      other.bold == bold;

  @override
  int get hashCode => Object.hash(text, align, bold);

  @override
  String toString() =>
      'ReceiptLine(${[text, if (align != ReceiptAlign.left) align.name, if (bold) 'bold'].join(', ')})';
}

/// Label kiri, nilai kanan (mis. "TOTAL ... 180.000").
class ReceiptPair {
  const ReceiptPair(this.label, this.value, {this.bold = false});

  final String label;
  final String value;
  final bool bold;
}

/// Barang: [name] lalu baris rincian [detail] (mis. "2 x 70.000") dengan
/// [amount] rata kanan.
class ReceiptItem {
  const ReceiptItem({
    required this.name,
    required this.detail,
    required this.amount,
    this.extras = const [],
    this.discount,
  });

  final String name;
  final String detail;
  final String amount;

  /// Baris tambahan di bawah nama, menjorok (modifier F&B, `+ Besar`).
  final List<String> extras;

  /// Diskon manual baris (F1-04b), di bawah baris jumlah:
  /// `Diskon 10%  -830`.
  final ReceiptPair? discount;
}

/// Isi struk yang sudah diformat (teks dan nominal), tanpa tata letak.
class ReceiptContent {
  const ReceiptContent({
    required this.storeName,
    this.outletName,
    this.header = const [],
    this.banner,
    this.meta = const [],
    this.sections = const [],
    this.items = const [],
    this.totals = const [],
    this.footer = const [],
  });

  final String storeName;
  final String? outletName;

  /// Baris header (alamat, telepon, teks bebas), rata tengah.
  final List<String> header;

  /// Label status tebal di tengah, mis. "CETAK ULANG".
  final String? banner;
  final List<ReceiptPair> meta;

  /// Blok pasangan label–nilai setelah [meta], masing-masing dipisah garis
  /// (mis. rekap sesi kasir: penjualan, kas laci, hitung uang).
  final List<List<ReceiptPair>> sections;
  final List<ReceiptItem> items;
  final List<ReceiptPair> totals;

  /// Baris penutup, rata tengah.
  final List<String> footer;
}

/// Membungkus [text] per kata menjadi baris ≤ [width]. Kata yang lebih
/// panjang dari [width] dipotong paksa. Teks kosong → tanpa baris.
List<String> wrapText(String text, int width) {
  text = receiptAscii(text);
  final lines = <String>[];
  var current = '';
  for (final word in text.split(RegExp(r'\s+'))) {
    if (word.isEmpty) continue;
    var rest = word;
    if (current.isNotEmpty && current.length + 1 + rest.length <= width) {
      current = '$current $rest';
      continue;
    }
    if (current.isNotEmpty) lines.add(current);
    while (rest.length > width) {
      lines.add(rest.substring(0, width));
      rest = rest.substring(width);
    }
    current = rest;
  }
  if (current.isNotEmpty) lines.add(current);
  return lines;
}

/// Pasangan label–nilai selebar [width]. Bila tidak muat, label di baris
/// sendiri lalu nilai rata kanan di baris berikutnya.
List<ReceiptLine> layoutPair(
  String label,
  String value,
  int width, {
  bool bold = false,
}) {
  label = receiptAscii(label);
  value = receiptAscii(value);
  final gap = width - label.length - value.length;
  if (gap >= 1) {
    return [ReceiptLine('$label${' ' * gap}$value', bold: bold)];
  }
  return [
    for (final l in wrapText(label, width)) ReceiptLine(l, bold: bold),
    for (final v in wrapText(value, width))
      ReceiptLine(v, align: ReceiptAlign.right, bold: bold),
  ];
}

/// Menyusun [content] menjadi baris struk selebar [paper]. Bagian yang
/// berisi dipisah garis `-`.
List<ReceiptLine> layoutReceipt(ReceiptContent content, ReceiptPaper paper) {
  final w = paper.columns;
  List<ReceiptLine> centered(String text, {bool bold = false}) => [
    for (final l in wrapText(text, w))
      ReceiptLine(l, align: ReceiptAlign.center, bold: bold),
  ];
  List<ReceiptLine> pairs(List<ReceiptPair> list) => [
    for (final p in list) ...layoutPair(p.label, p.value, w, bold: p.bold),
  ];

  final sections = <List<ReceiptLine>>[
    [
      ...centered(content.storeName, bold: true),
      if (content.outletName case final outlet?) ...centered(outlet),
      for (final h in content.header) ...centered(h),
    ],
    if (content.banner case final banner?) centered(banner, bold: true),
    pairs(content.meta),
    for (final section in content.sections) pairs(section),
    [
      for (final item in content.items) ...[
        for (final l in wrapText(item.name, w)) ReceiptLine(l),
        for (final e in item.extras)
          for (final l in wrapText(e, w - 2)) ReceiptLine('  $l'),
        ...layoutPair('  ${item.detail}', item.amount, w),
        if (item.discount case final d?)
          ...layoutPair('  ${d.label}', d.value, w),
      ],
    ],
    pairs(content.totals),
    [for (final f in content.footer) ...centered(f)],
  ].where((s) => s.isNotEmpty);

  final rule = ReceiptLine('-' * w);
  return [
    for (final (i, section) in sections.indexed) ...[
      if (i > 0) rule,
      ...section,
    ],
  ];
}

/// Maks baris header/footer struk.
const maxReceiptTextLines = 4;

/// Maks karakter per baris header/footer (lebar kertas 80 mm).
const maxReceiptTextLineLength = 48;

/// Baris header/footer dari isian multi-baris: dirapikan, baris kosong
/// dibuang.
List<String> receiptTextLines(String? text) => [
  for (final line in (text ?? '').split('\n'))
    if (line.trim().isNotEmpty) line.trim(),
];

enum ReceiptSettingsError {
  headerTooManyLines,
  headerLineTooLong,
  footerTooManyLines,
  footerLineTooLong,
}

/// Memeriksa isian header/footer struk. `null` = pakai bawaan (sah).
Set<ReceiptSettingsError> validateReceiptSettings({
  required String? header,
  required String? footer,
}) {
  final h = receiptTextLines(header);
  final f = receiptTextLines(footer);
  bool tooLong(List<String> lines) =>
      lines.any((l) => l.length > maxReceiptTextLineLength);
  return {
    if (h.length > maxReceiptTextLines) ReceiptSettingsError.headerTooManyLines,
    if (tooLong(h)) ReceiptSettingsError.headerLineTooLong,
    if (f.length > maxReceiptTextLines) ReceiptSettingsError.footerTooManyLines,
    if (tooLong(f)) ReceiptSettingsError.footerLineTooLong,
  };
}
