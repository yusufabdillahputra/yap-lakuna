import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/app_settings_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import 'app_settings_view_model.dart';
import 'appearance_tiles.dart';

/// Bagian *Tampilan & bahasa* di Pengaturan: tema dan bahasa.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.viewModel});

  final AppSettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return ListenableBuilder(
      listenable: Listenable.merge([
        viewModel,
        viewModel.setThemeMode,
        viewModel.setLocale,
        viewModel.setTextSize,
      ]),
      builder: (context, _) {
        final failed =
            viewModel.setThemeMode.error ||
            viewModel.setLocale.error ||
            viewModel.setTextSize.error;
        return Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Text(
                  l10n.settingsAppearance,
                  style: theme.typography.display.xl2,
                ),
                if (failed)
                  FAlert(
                    variant: .destructive,
                    title: Text(l10n.settingsSaveError),
                  ),
                AppearanceTiles(viewModel: viewModel),
                FTileGroup(
                  label: Text(l10n.settingsTextSize),
                  children: [
                    for (final (size, label) in [
                      (AppTextSize.normal, l10n.settingsTextSizeNormal),
                      (AppTextSize.large, l10n.settingsTextSizeLarge),
                    ])
                      FTile(
                        key: ValueKey('text-size-${size.name}'),
                        title: Text(label),
                        selected: viewModel.textSize == size,
                        suffix: viewModel.textSize == size
                            ? const Icon(TablerIcons.check)
                            : null,
                        onPress: () => viewModel.setTextSize.execute(size),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
