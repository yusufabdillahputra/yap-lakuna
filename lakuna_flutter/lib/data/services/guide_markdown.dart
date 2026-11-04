/// Subset Markdown untuk artikel Panduan (F1-21). Dirender sendiri agar
/// tetap offline dan memakai komponen Forui.
///
/// Didukung: `# H1` (judul, wajib di baris pertama berisi), `## H2`,
/// paragraf, `1. ` / `- ` daftar, `> [!note]` / `> [!warning]` kotak,
/// `![keterangan](nama)` gambar, dan inline `**tebal**`, `*miring*`,
/// `[teks](slug)`.
library;

enum GuideSpanStyle { plain, bold, italic }

/// Potongan teks inline; [link] berisi slug artikel tujuan.
final class GuideSpan {
  const GuideSpan(this.text, {this.style = GuideSpanStyle.plain, this.link});

  final String text;
  final GuideSpanStyle style;
  final String? link;
}

sealed class GuideBlock {
  const GuideBlock();
}

final class GuideHeading extends GuideBlock {
  const GuideHeading(this.text);
  final String text;
}

final class GuideParagraph extends GuideBlock {
  const GuideParagraph(this.spans);
  final List<GuideSpan> spans;
}

/// Daftar bernomor atau berpoin. [numbers] berisi nomor tertulis tiap
/// item (daftar bernomor yang diselingi sub-daftar tetap berlanjut);
/// [nested] = sub-daftar berpoin yang ditulis menjorok.
final class GuideList extends GuideBlock {
  const GuideList({
    required this.ordered,
    required this.items,
    this.numbers = const [],
    this.nested = false,
  });
  final bool ordered;
  final List<List<GuideSpan>> items;
  final List<int> numbers;
  final bool nested;
}

enum GuideCalloutKind { note, warning }

final class GuideCallout extends GuideBlock {
  const GuideCallout(this.kind, this.spans);
  final GuideCalloutKind kind;
  final List<GuideSpan> spans;
}

/// Tangkapan layar `img/<bahasa>/<name>.webp`.
final class GuideImage extends GuideBlock {
  const GuideImage({required this.name, required this.caption});
  final String name;
  final String caption;
}

final class GuideDocument {
  const GuideDocument({required this.title, required this.blocks});

  final String title;
  final List<GuideBlock> blocks;

  Iterable<List<GuideSpan>> get _spanGroups sync* {
    for (final b in blocks) {
      switch (b) {
        case GuideParagraph(:final spans) || GuideCallout(:final spans):
          yield spans;
        case GuideList(:final items):
          yield* items;
        case GuideHeading() || GuideImage():
          break;
      }
    }
  }

  /// Slug yang ditautkan artikel ini, urut kemunculan.
  List<String> get links => [
    for (final spans in _spanGroups)
      for (final s in spans) ?s.link,
  ];

  List<String> get images => [
    for (final b in blocks)
      if (b is GuideImage) b.name,
  ];

  /// Teks tanpa tanda Markdown, untuk pencarian.
  String get plainText {
    final out = StringBuffer(title);
    for (final b in blocks) {
      out.write('\n');
      switch (b) {
        case GuideHeading(:final text):
          out.write(text);
        case GuideImage(:final caption):
          out.write(caption);
        case GuideParagraph(:final spans) || GuideCallout(:final spans):
          out.write(spans.map((s) => s.text).join());
        case GuideList(:final items):
          out.write(items.map((i) => i.map((s) => s.text).join()).join('\n'));
      }
    }
    return out.toString();
  }
}

final _ordered = RegExp(r'^(\d+)\.\s+(.*)$');
final _bullet = RegExp(r'^[-*]\s+(.*)$');
final _callout = RegExp(r'^>\s*\[!(\w+)\]\s*(.*)$');
final _image = RegExp(r'^!\[([^\]]*)\]\(([^)\s]+)\)$');

/// Mengurai [source]; melempar [FormatException] bila bentuknya tidak
/// dikenal (tes konten menangkapnya sebelum rilis).
GuideDocument parseGuideMarkdown(String source) {
  final lines = source.replaceAll('\r\n', '\n').split('\n');
  var i = 0;
  while (i < lines.length && lines[i].trim().isEmpty) {
    i++;
  }
  if (i >= lines.length || !lines[i].startsWith('# ')) {
    throw const FormatException('Artikel harus diawali "# Judul"');
  }
  final title = lines[i].substring(2).trim();
  i++;

  final blocks = <GuideBlock>[];
  List<String>? paragraph;
  GuideList? list;

  void flushParagraph() {
    if (paragraph case final p?) {
      blocks.add(GuideParagraph(parseGuideInline(p.join(' '))));
    }
    paragraph = null;
  }

  void flushList() {
    if (list case final l?) blocks.add(l);
    list = null;
  }

  for (; i < lines.length; i++) {
    final raw = lines[i];
    final line = raw.trim();
    final indented = raw.startsWith(' ') || raw.startsWith('\t');
    if (line.isEmpty) {
      flushParagraph();
      // Daftar boleh dipisah baris kosong; ditutup oleh blok lain.
      continue;
    }
    if (line.startsWith('# ')) {
      throw FormatException('Judul H1 hanya boleh satu', line);
    }
    if (line.startsWith('###')) {
      throw FormatException('Hanya judul # dan ## yang didukung', line);
    }
    if (line.startsWith('## ')) {
      flushParagraph();
      flushList();
      blocks.add(GuideHeading(line.substring(3).trim()));
      continue;
    }
    if (_callout.firstMatch(line) case final m?) {
      flushParagraph();
      flushList();
      final kind = switch (m[1]!.toLowerCase()) {
        'note' => GuideCalloutKind.note,
        'warning' => GuideCalloutKind.warning,
        _ => throw FormatException('Jenis kotak tidak dikenal', m[1]),
      };
      final text = [m[2]!];
      while (i + 1 < lines.length && lines[i + 1].trim().startsWith('>')) {
        i++;
        final next = lines[i].trim();
        if (_callout.hasMatch(next)) {
          throw FormatException('Pisahkan dua kotak dengan baris kosong', next);
        }
        text.add(next.substring(1).trim());
      }
      blocks.add(
        GuideCallout(
          kind,
          parseGuideInline(text.where((t) => t.isNotEmpty).join(' ')),
        ),
      );
      continue;
    }
    if (line.startsWith('>')) {
      throw FormatException('Kotak harus diawali > [!note] / [!warning]', line);
    }
    if (_image.firstMatch(line) case final m?) {
      flushParagraph();
      flushList();
      blocks.add(GuideImage(name: m[2]!, caption: m[1]!.trim()));
      continue;
    }
    final ordered = _ordered.firstMatch(line);
    final bullet = ordered == null ? _bullet.firstMatch(line) : null;
    if (ordered != null || bullet != null) {
      flushParagraph();
      final isOrdered = ordered != null;
      final nested = !isOrdered && indented;
      if (list case final l?
          when l.ordered != isOrdered || l.nested != nested) {
        flushList();
      }
      final item = parseGuideInline(ordered?[2] ?? bullet![1]!);
      list = GuideList(
        ordered: isOrdered,
        nested: nested,
        items: [...?list?.items, item],
        numbers: [
          ...?list?.numbers,
          ?(ordered == null ? null : int.parse(ordered[1]!)),
        ],
      );
      continue;
    }
    flushList();
    (paragraph ??= []).add(line);
  }
  flushParagraph();
  flushList();
  return GuideDocument(title: title, blocks: blocks);
}

final _inline = RegExp(
  r'\*\*(.+?)\*\*|\*([^*\s][^*]*?)\*|\[([^\]]+)\]\(([^)\s]+)\)',
);

/// Inline: `**tebal**`, `*miring*`, `[teks](slug)`; sisanya teks biasa.
List<GuideSpan> parseGuideInline(String text) {
  final spans = <GuideSpan>[];
  var last = 0;
  for (final m in _inline.allMatches(text)) {
    if (m.start > last) spans.add(GuideSpan(text.substring(last, m.start)));
    if (m[1] case final bold?) {
      spans.add(GuideSpan(bold, style: GuideSpanStyle.bold));
    } else if (m[2] case final italic?) {
      spans.add(GuideSpan(italic, style: GuideSpanStyle.italic));
    } else {
      spans.add(GuideSpan(m[3]!, link: m[4]));
    }
    last = m.end;
  }
  if (last < text.length) spans.add(GuideSpan(text.substring(last)));
  return spans;
}
