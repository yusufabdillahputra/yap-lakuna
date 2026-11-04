import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/guide_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../products/product_widgets.dart' show LoadFailedAlert;
import 'guide_article_view.dart';
import 'guide_view_model.dart';

/// Lebar minimum untuk daftar isi di samping artikel.
const _twoPaneWidth = 900.0;

/// Panduan pengguna (1.27, F1-21): daftar isi, cari, ID/EN, artikel.
/// Di layar sempit daftar isi dan artikel tampil bergantian.
class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key, required this.repository, this.initialSlug});

  final GuideRepository repository;

  /// Artikel pertama yang dibuka (`?artikel=`).
  final String? initialSlug;

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  GuideViewModel? _vm;

  /// Layar sempit: artikel (true) atau daftar isi (false).
  late bool _showArticle = widget.initialSlug != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _vm ??= GuideViewModel(
      repository: widget.repository,
      language: GuideLanguage.of(Localizations.localeOf(context).languageCode),
      initialSlug: widget.initialSlug,
    )..load.execute();
  }

  @override
  void dispose() {
    _vm?.dispose();
    super.dispose();
  }

  void _open(String slug) {
    _vm!.open(slug);
    setState(() => _showArticle = true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = _vm!;
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) => LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= _twoPaneWidth;
          final l10n = AppLocalizations.of(context);
          final Widget body;
          if (vm.load.error) {
            body = Padding(
              padding: const EdgeInsets.all(16),
              child: LoadFailedAlert(
                key: const ValueKey('guide-load-error'),
                message: l10n.guideLoadError,
                onRetry: vm.load.execute,
              ),
            );
          } else if (vm.sections.isEmpty) {
            body = const Center(child: FCircularProgress());
          } else if (wide) {
            body = Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 280,
                  child: _Nav(vm: vm, onOpen: _open),
                ),
                Expanded(
                  child: _Article(vm: vm, onOpen: _open),
                ),
              ],
            );
          } else if (_showArticle && vm.results == null) {
            body = _Article(
              vm: vm,
              onOpen: _open,
              onBack: () => setState(() => _showArticle = false),
            );
          } else {
            body = _Nav(vm: vm, onOpen: _open);
          }
          return Column(
            key: const ValueKey('guide-screen'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(vm: vm, wide: wide),
              Expanded(child: body),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.vm, required this.wide});

  final GuideViewModel vm;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final title = Wrap(
      spacing: 10,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          l10n.guideTitle,
          style: theme.typography.display.lg.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        FBadge(
          key: const ValueKey('guide-offline'),
          variant: .secondary,
          child: Text(l10n.guideOffline),
        ),
      ],
    );
    final search = FTextField(
      key: const ValueKey('guide-search'),
      hint: l10n.guideSearchHint,
      prefixBuilder: (context, style, _) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 12),
        child: Icon(
          TablerIcons.search,
          size: 18,
          color: theme.colors.mutedForeground,
        ),
      ),
      control: .managed(onChange: (v) => vm.search(v.text)),
    );
    final language = Semantics(
      label: l10n.guideLanguageLabel,
      container: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          for (final lang in GuideLanguage.values)
            FButton(
              key: ValueKey('guide-lang-${lang.name}'),
              size: .sm,
              mainAxisSize: .min,
              variant: lang == vm.language ? .primary : .outline,
              onPress: vm.setLanguage.running
                  ? null
                  : () => vm.setLanguage.execute(lang),
              child: Text(lang.name.toUpperCase()),
            ),
        ],
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colors.border)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: wide ? 28 : 16, vertical: 12),
        child: wide
            ? Row(
                spacing: 14,
                children: [
                  title,
                  const Spacer(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Semantics(
                      label: l10n.guideSearchLabel,
                      child: search,
                    ),
                  ),
                  language,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 10,
                children: [
                  Row(
                    children: [
                      Expanded(child: title),
                      language,
                    ],
                  ),
                  search,
                ],
              ),
      ),
    );
  }
}

/// Daftar isi, atau hasil pencarian saat sedang mencari.
class _Nav extends StatelessWidget {
  const _Nav({required this.vm, required this.onOpen});

  final GuideViewModel vm;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final muted = theme.typography.body.xs.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
      color: theme.colors.mutedForeground,
    );
    Widget item(String slug, {String? subtitle, required String prefix}) {
      final selected = slug == vm.slug;
      return FTappable(
        key: ValueKey('$prefix-$slug'),
        selected: selected,
        semanticsLabel: vm.titleOf(slug),
        onPress: () => onOpen(slug),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? theme.colors.secondary : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    vm.titleOf(slug),
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? theme.colors.primary
                          : theme.colors.foreground,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final results = vm.results;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.muted.withValues(alpha: 0.5),
        border: Border(right: BorderSide(color: theme.colors.border)),
      ),
      child: SingleChildScrollView(
        key: const ValueKey('guide-toc'),
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 18,
          children: [
            if (results != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  results.isEmpty
                      ? l10n.guideNoResults
                      : l10n.guideResults(results.length),
                  key: ValueKey(
                    results.isEmpty ? 'guide-no-results' : 'guide-results',
                  ),
                  style: results.isEmpty ? theme.typography.body.sm : muted,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 2,
                children: [
                  for (final slug in results)
                    item(
                      slug,
                      prefix: 'guide-result',
                      subtitle: vm.sectionOf(slug)?.title(vm.language),
                    ),
                ],
              ),
            ] else
              for (final section in vm.sections)
                Semantics(
                  container: true,
                  label: section.title(vm.language),
                  explicitChildNodes: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 2,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
                        child: ExcludeSemantics(
                          child: Text(
                            section.title(vm.language).toUpperCase(),
                            style: muted,
                          ),
                        ),
                      ),
                      for (final slug in section.slugs)
                        item(slug, prefix: 'guide-toc'),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _Article extends StatelessWidget {
  const _Article({required this.vm, required this.onOpen, this.onBack});

  final GuideViewModel vm;
  final ValueChanged<String> onOpen;

  /// Layar sempit: kembali ke daftar isi.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final doc = vm.article;
    if (doc == null) return const SizedBox.shrink();
    (String, String)? link(String? slug) =>
        slug == null ? null : (slug, vm.titleOf(slug));
    return SingleChildScrollView(
      key: ValueKey('guide-article-scroll-${vm.slug}-${vm.language.name}'),
      padding: onBack == null
          ? const EdgeInsets.fromLTRB(48, 36, 48, 48)
          : const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              if (onBack case final back?)
                FButton(
                  key: const ValueKey('guide-back'),
                  variant: .ghost,
                  size: .sm,
                  mainAxisSize: .min,
                  prefix: const Icon(TablerIcons.arrowLeft),
                  onPress: back,
                  child: Text(l10n.guideContents),
                ),
              GuideArticleView(
                document: doc,
                language: vm.language,
                sectionTitle: vm.sectionTitle,
                previous: link(vm.previous),
                next: link(vm.next),
                onOpen: onOpen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
