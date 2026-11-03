import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/app_settings_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import 'app_settings_view_model.dart';

/// Pilihan tema dan bahasa; dipakai di Pengaturan dan langkah 1 setup toko.
class AppearanceTiles extends StatelessWidget {
  const AppearanceTiles({super.key, required this.viewModel});

  final AppSettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          FTileGroup(
            label: Text(l10n.settingsTheme),
            children: [
              for (final (mode, label, icon) in [
                (AppThemeMode.light, l10n.themeLight, TablerIcons.sun),
                (AppThemeMode.dark, l10n.themeDark, TablerIcons.moon),
                (
                  AppThemeMode.system,
                  l10n.themeSystem,
                  TablerIcons.deviceDesktop,
                ),
              ])
                FTile(
                  key: ValueKey('theme-${mode.name}'),
                  prefix: Icon(icon),
                  title: Text(label),
                  selected: viewModel.themeMode == mode,
                  suffix: viewModel.themeMode == mode
                      ? const Icon(TablerIcons.check)
                      : null,
                  onPress: () => viewModel.setThemeMode.execute(mode),
                ),
            ],
          ),
          FTileGroup(
            label: Text(l10n.settingsLanguage),
            children: [
              for (final (locale, label) in [
                (const Locale('id'), l10n.languageIndonesian),
                (const Locale('en'), l10n.languageEnglish),
              ])
                FTile(
                  key: ValueKey('locale-${locale.languageCode}'),
                  title: Text(label),
                  selected: viewModel.locale == locale,
                  suffix: viewModel.locale == locale
                      ? const Icon(TablerIcons.check)
                      : null,
                  onPress: () => viewModel.setLocale.execute(locale),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
