import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../l10n/gen/app_localizations.dart';
import 'app_settings_view_model.dart';
import 'appearance_tiles.dart';

/// Pengaturan tampilan: tema dan bahasa.
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
      ]),
      builder: (context, _) {
        final failed =
            viewModel.setThemeMode.error || viewModel.setLocale.error;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Align(
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
