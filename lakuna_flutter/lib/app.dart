import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalCupertinoLocalizations, GlobalWidgetsLocalizations;
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'data/repositories/app_settings_repository.dart';
import 'l10n/gen/app_localizations.dart';
import 'ui/core/theme/theme.dart';
import 'ui/settings/app_settings_view_model.dart';

/// Varian tema sentuh untuk Android/iOS, desktop untuk lainnya.
bool get useTouchTheme => const {
  TargetPlatform.android,
  TargetPlatform.iOS,
  TargetPlatform.fuchsia,
}.contains(defaultTargetPlatform);

class LakunaApp extends StatelessWidget {
  const LakunaApp({super.key, required this.settings, required this.router});

  final AppSettingsViewModel settings;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    final touch = useTouchTheme;
    final light = lakunaLightTheme(touch: touch);
    final dark = lakunaDarkTheme(touch: touch);
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp.router(
        title: 'Lakuna',
        debugShowCheckedModeBanner: false,
        locale: settings.locale,
        supportedLocales: supportedAppLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...FLocalizations.localizationsDelegates,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        themeMode: switch (settings.themeMode) {
          AppThemeMode.light => ThemeMode.light,
          AppThemeMode.dark => ThemeMode.dark,
          AppThemeMode.system => ThemeMode.system,
        },
        theme: lakunaMaterialTheme(light),
        darkTheme: lakunaMaterialTheme(dark),
        builder: (context, child) {
          final themed = FTheme(
            data: Theme.brightnessOf(context) == Brightness.light
                ? light
                : dark,
            child: FToaster(child: FTooltipGroup(child: child!)),
          );
          // Ukuran tampilan *Besar*: skala teks minimal 1,15 (F1-18).
          return settings.textSize == AppTextSize.normal
              ? themed
              : MediaQuery.withClampedTextScaling(
                  minScaleFactor: settings.textSize.scale,
                  child: themed,
                );
        },
        routerConfig: router,
      ),
    );
  }
}
