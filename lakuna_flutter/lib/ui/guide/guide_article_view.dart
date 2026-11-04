import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/guide_repository.dart';
import '../../data/services/guide_markdown.dart';
import '../../l10n/gen/app_localizations.dart';

/// Isi satu artikel Panduan (1.27): breadcrumb, judul, blok Markdown, lalu
/// tautan sebelumnya/berikutnya.
class GuideArticleView extends StatelessWidget {
  const GuideArticleView({
    super.key,
    required this.document,
    required this.language,
    required this.onOpen,
    this.sectionTitle,
    this.previous,
    this.next,
  });

  final GuideDocument document;
  final GuideLanguage language;
  final String? sectionTitle;

  /// Artikel sebelumnya/berikutnya: (slug, judul).
  final (String, String)? previous;
  final (String, String)? next;

  /// Membuka artikel lain (tautan di teks atau navigasi bawah).
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final body = theme.typography.body.md.copyWith(
      height: 1.65,
      color: theme.colors.foreground,
    );
    return Column(
      key: const ValueKey('guide-article'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        if (sectionTitle case final section?)
          Text(
            '$section › ${document.title}',
            key: const ValueKey('guide-breadcrumb'),
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        Semantics(
          header: true,
          child: Text(
            document.title,
            key: const ValueKey('guide-article-title'),
            style: theme.typography.display.xl3.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        for (final block in document.blocks)
          switch (block) {
            GuideHeading(:final text) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Semantics(
                header: true,
                child: Text(
                  text,
                  style: theme.typography.display.lg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            GuideParagraph(:final spans) => _Inline(
              spans: spans,
              style: body,
              onOpen: onOpen,
            ),
            GuideList(
              :final ordered,
              :final items,
              :final numbers,
              :final nested,
            ) =>
              Padding(
                padding: EdgeInsets.only(left: nested ? 28 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 6,
                  children: [
                    for (final (i, item) in items.indexed)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              ordered
                                  ? '${i < numbers.length ? numbers[i] : i + 1}.'
                                  : '•',
                              style: body.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Expanded(
                            child: _Inline(
                              spans: item,
                              style: body,
                              onOpen: onOpen,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            GuideCallout(:final kind, :final spans) => _Callout(
              kind: kind,
              child: (style) =>
                  _Inline(spans: spans, style: style, onOpen: onOpen),
            ),
            GuideImage(:final name, :final caption) => _Screenshot(
              asset: GuideAssets.image(language, name),
              caption: caption,
            ),
          },
        if (previous != null || next != null)
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.colors.border)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (previous case (final slug, final title))
                    _NavLink(
                      key: const ValueKey('guide-prev'),
                      label: '← $title',
                      semantics: '${l10n.guidePrevious}: $title',
                      onTap: () => onOpen(slug),
                    )
                  else
                    const SizedBox.shrink(),
                  if (next case (final slug, final title))
                    _NavLink(
                      key: const ValueKey('guide-next'),
                      label: '$title →',
                      semantics: '${l10n.guideNext}: $title',
                      onTap: () => onOpen(slug),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    super.key,
    required this.label,
    required this.semantics,
    required this.onTap,
  });

  final String label;
  final String semantics;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FTappable(
      onPress: onTap,
      semanticsLabel: semantics,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Align(
          widthFactor: 1,
          child: Text(
            label,
            style: theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Teks inline dengan tebal/miring dan tautan ke artikel lain.
class _Inline extends StatefulWidget {
  const _Inline({
    required this.spans,
    required this.style,
    required this.onOpen,
  });

  final List<GuideSpan> spans;
  final TextStyle style;
  final ValueChanged<String> onOpen;

  @override
  State<_Inline> createState() => _InlineState();
}

class _InlineState extends State<_Inline> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  TapGestureRecognizer _tap(String slug) {
    final r = TapGestureRecognizer()..onTap = () => widget.onOpen(slug);
    _recognizers.add(r);
    return r;
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    final link = widget.style.copyWith(
      color: context.theme.colors.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: context.theme.colors.primary,
    );
    return Text.rich(
      TextSpan(
        style: widget.style,
        children: [
          for (final s in widget.spans)
            if (s.link case final slug?)
              TextSpan(
                text: s.text,
                style: link,
                recognizer: _tap(slug),
              )
            else
              TextSpan(
                text: s.text,
                style: switch (s.style) {
                  GuideSpanStyle.bold => const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                  GuideSpanStyle.italic => const TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                  GuideSpanStyle.plain => null,
                },
              ),
        ],
      ),
    );
  }
}

class _Callout extends StatelessWidget {
  const _Callout({required this.kind, required this.child});

  final GuideCalloutKind kind;
  final Widget Function(TextStyle style) child;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final dark = theme.colors.brightness == Brightness.dark;
    final (bg, fg, icon) = switch (kind) {
      GuideCalloutKind.warning => (
        dark ? const Color(0xFF461901) : const Color(0xFFFEF3C6),
        dark ? const Color(0xFFFEE685) : const Color(0xFF7B3306),
        TablerIcons.alertCircle,
      ),
      GuideCalloutKind.note => (
        dark ? const Color(0xFF052F4A) : const Color(0xFFDFF2FE),
        dark ? const Color(0xFFB8E6FE) : const Color(0xFF00598A),
        TablerIcons.infoCircle,
      ),
    };
    return DecoratedBox(
      key: ValueKey('guide-callout-${kind.name}'),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, size: 20, color: fg),
            ),
            Expanded(
              child: child(
                theme.typography.body.sm.copyWith(
                  height: 1.6,
                  color: fg,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Screenshot extends StatelessWidget {
  const _Screenshot({required this.asset, required this.caption});

  final String asset;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.asset(
                asset,
                semanticLabel: caption,
                errorBuilder: (context, error, stack) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      l10n.guideImageMissing,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (caption.isNotEmpty)
          ExcludeSemantics(
            child: Text(
              caption,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
      ],
    );
  }
}
