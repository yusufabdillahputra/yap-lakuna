import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_flutter/ui/core/theme/theme.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Aturan kontras kanvas "Desain UI Lakuna" (spec desain, bagian "Aturan
/// kontras dan mode gelap"): semua teks minimal 4.5:1.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

Color _textColor(WidgetTester tester, Finder text) => tester
    .widget<RichText>(
      find.descendant(of: text, matching: find.byType(RichText)).first,
    )
    .text
    .style!
    .color!;

Future<void> _pumpThemed(
  WidgetTester tester,
  FThemeData theme,
  Widget child,
) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: FTheme(
        data: theme,
        child: ColoredBox(
          color: theme.colors.background,
          child: Center(child: child),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  final light = lakunaLightTheme(touch: false);
  final dark = lakunaDarkTheme(touch: false);

  testWidgets('tombol destructive gelap: isi #C10007, teks terbaca', (
    tester,
  ) async {
    await _pumpThemed(
      tester,
      dark,
      FButton(
        variant: .destructive,
        onPress: () {},
        child: const Text('Hapus'),
      ),
    );
    final fill = tester
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(FButton),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((b) => b.decoration)
        .whereType<ShapeDecoration>()
        .map((d) => d.color)
        .whereType<Color>()
        .first;
    expect(fill, const Color(0xFFC10007));
    final label = _textColor(tester, find.text('Hapus'));
    expect(contrast(label, fill), greaterThanOrEqualTo(4.5));
  });

  testWidgets('teks/ikon destructive gelap tetap #FF6467 di luar tombol', (
    tester,
  ) async {
    expect(dark.colors.destructive, const Color(0xFFFF6467));
    expect(
      contrast(dark.colors.destructive, dark.colors.card),
      greaterThanOrEqualTo(4.5),
    );
  });

  testWidgets('navigasi bawah gelap: menu aktif memakai Sky muda #74D4FF', (
    tester,
  ) async {
    await _pumpThemed(
      tester,
      dark,
      FBottomNavigationBar(
        index: 0,
        children: const [
          FBottomNavigationBarItem(
            icon: Icon(TablerIcons.home),
            label: Text('Beranda'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(TablerIcons.box),
            label: Text('Produk'),
          ),
        ],
      ),
    );
    final active = _textColor(tester, find.text('Beranda'));
    expect(active, const Color(0xFF74D4FF));
    expect(
      contrast(active, dark.colors.background),
      greaterThanOrEqualTo(4.5),
    );
    final inactive = _textColor(tester, find.text('Produk'));
    expect(
      contrast(inactive, dark.colors.background),
      greaterThanOrEqualTo(4.5),
    );
  });

  testWidgets('navigasi bawah terang: menu aktif tetap Sky #0069A8', (
    tester,
  ) async {
    await _pumpThemed(
      tester,
      light,
      FBottomNavigationBar(
        index: 0,
        children: const [
          FBottomNavigationBarItem(
            icon: Icon(TablerIcons.home),
            label: Text('Beranda'),
          ),
        ],
      ),
    );
    expect(_textColor(tester, find.text('Beranda')), const Color(0xFF0069A8));
  });

  testWidgets('tab tidak aktif di tema terang: #52525C, minimal 4.5:1', (
    tester,
  ) async {
    await _pumpThemed(
      tester,
      light,
      SizedBox(
        width: 400,
        height: 200,
        child: FTabs(
          children: const [
            FTabEntry(label: Text('Harian'), child: SizedBox()),
            FTabEntry(label: Text('Bulanan'), child: SizedBox()),
          ],
        ),
      ),
    );
    final inactive = _textColor(tester, find.text('Bulanan'));
    expect(inactive, const Color(0xFF52525C));
    expect(
      contrast(inactive, light.colors.muted),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('pasangan token teks utama memenuhi 4.5:1 di kedua tema', () {
    for (final t in [light, dark]) {
      final c = t.colors;
      expect(contrast(c.foreground, c.background), greaterThanOrEqualTo(4.5));
      expect(contrast(c.foreground, c.card), greaterThanOrEqualTo(4.5));
      expect(contrast(c.mutedForeground, c.card), greaterThanOrEqualTo(4.5));
      expect(
        contrast(c.primaryForeground, c.primary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(c.secondaryForeground, c.secondary),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  testWidgets('ikon prefix FTile di tema gelap memakai Sky muda', (
    tester,
  ) async {
    await _pumpThemed(
      tester,
      dark,
      SizedBox(
        width: 400,
        child: FTile(
          prefix: const Icon(TablerIcons.sun),
          title: const Text('Terang'),
          onPress: () {},
        ),
      ),
    );
    final color = IconTheme.of(
      tester.element(find.byIcon(TablerIcons.sun)),
    ).color!;
    expect(color, const Color(0xFF74D4FF));
    expect(contrast(color, dark.colors.card), greaterThanOrEqualTo(4.5));
  });

  testWidgets('ikon prefix di dalam FTileGroup tema gelap juga Sky muda', (
    tester,
  ) async {
    await _pumpThemed(
      tester,
      dark,
      SizedBox(
        width: 400,
        child: FTileGroup(
          children: [
            FTile(
              prefix: const Icon(TablerIcons.moon),
              title: const Text('Gelap'),
              onPress: () {},
            ),
          ],
        ),
      ),
    );
    final color = IconTheme.of(
      tester.element(find.byIcon(TablerIcons.moon)),
    ).color!;
    expect(color, const Color(0xFF74D4FF));
  });
}
