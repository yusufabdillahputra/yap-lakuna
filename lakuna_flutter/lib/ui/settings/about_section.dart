import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../config/app_environment.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../routing/routes.dart';
import '../products/product_widgets.dart' show LoadFailedAlert;
import 'about_view_model.dart';
import 'settings_card.dart';

/// Pengaturan › Tentang Lakuna (1.26, F1-22): versi, ringkasan privasi,
/// tautan Panduan, dan lisensi open source. Terbuka untuk semua staf.
class AboutSection extends StatefulWidget {
  const AboutSection({super.key, required this.viewModel});

  final AboutViewModel viewModel;

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  /// Paket yang teks lisensinya sedang dibuka (satu per satu agar ringan).
  String? _open;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final vm = widget.viewModel;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
      height: 1.5,
    );
    return Column(
      key: const ValueKey('about-section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        SettingsCard(
          title: 'Lakuna',
          subtitle: l10n.aboutTagline,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FBadge(
                key: const ValueKey('about-version'),
                variant: .secondary,
                child: Text(
                  '${l10n.aboutVersion} ${context.read<AppEnvironment>().version}',
                ),
              ),
              FButton(
                key: const ValueKey('about-guide'),
                variant: .outline,
                size: .sm,
                mainAxisSize: .min,
                prefix: const Icon(TablerIcons.help),
                onPress: () => context.go(Routes.guide),
                child: Flexible(child: Text(l10n.aboutOpenGuide)),
              ),
            ],
          ),
        ),
        SettingsCard(
          title: l10n.aboutPrivacyTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Text(
                l10n.aboutPrivacyLocal,
                style: muted.copyWith(color: theme.colors.foreground),
              ),
              Text(l10n.aboutPrivacyHosted, style: muted),
              Text(l10n.aboutPrivacyBackup, style: muted),
            ],
          ),
        ),
        SettingsCard(
          title: l10n.aboutLicensesTitle,
          subtitle: l10n.aboutLicensesSubtitle,
          child: ListenableBuilder(
            listenable: vm,
            builder: (context, _) {
              if (vm.load.error) {
                return LoadFailedAlert(
                  key: const ValueKey('about-licenses-error'),
                  message: l10n.aboutLicensesError,
                  onRetry: vm.load.execute,
                );
              }
              if (vm.load.running) {
                return const Center(child: FCircularProgress());
              }
              if (vm.licenses.isEmpty) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: FButton(
                    key: const ValueKey('about-licenses-show'),
                    variant: .outline,
                    size: .sm,
                    mainAxisSize: .min,
                    onPress: vm.load.execute,
                    child: Flexible(child: Text(l10n.aboutLicensesShow)),
                  ),
                );
              }
              return Column(
                key: const ValueKey('about-licenses'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final license in vm.licenses)
                    _LicenseTile(
                      license: license,
                      open: license.package == _open,
                      onToggle: () => setState(
                        () => _open = license.package == _open
                            ? null
                            : license.package,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LicenseTile extends StatelessWidget {
  const _LicenseTile({
    required this.license,
    required this.open,
    required this.onToggle,
  });

  final AboutLicense license;
  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FTappable(
            key: ValueKey('about-license-${license.package}'),
            selected: open,
            semanticsLabel: license.package,
            onPress: onToggle,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Text(
                        license.package,
                        style: theme.typography.body.sm.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ExcludeSemantics(
                      child: Text(
                        l10n.aboutLicenseCount(license.texts.length),
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ),
                    Icon(
                      open ? TablerIcons.chevronUp : TablerIcons.chevronDown,
                      size: 16,
                      color: theme.colors.mutedForeground,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                key: ValueKey('about-license-text-${license.package}'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  for (final text in license.texts)
                    Text(
                      text,
                      style: theme.typography.body.xs.copyWith(
                        fontFamily: 'DM Mono',
                        color: theme.colors.mutedForeground,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
