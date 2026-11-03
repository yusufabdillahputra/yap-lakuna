import 'package:go_router/go_router.dart';

import '../data/repositories/store_repository.dart';
import '../ui/coming_soon/coming_soon_view.dart';
import '../ui/core/app_shell.dart';
import '../ui/home/home_view.dart';
import '../ui/onboarding/onboarding_view.dart';
import '../ui/settings/app_settings_view_model.dart';
import '../ui/settings/settings_view.dart';
import 'routes.dart';

/// Router aplikasi. Selama [store] belum punya toko, semua jalur diarahkan ke
/// [Routes.setup]; setelah setup, [Routes.setup] tidak bisa dibuka lagi.
GoRouter createRouter({
  required AppSettingsViewModel settings,
  required StoreRepository store,
  String initialLocation = Routes.home,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: store,
    redirect: (context, state) {
      final ready = store.current != null;
      final atSetup = state.matchedLocation == Routes.setup;
      if (!ready && !atSetup) return Routes.setup;
      if (ready && atSetup) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.setup,
        builder: (context, state) =>
            OnboardingScreen(repository: store, settings: settings),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (context, state) => HomeView(store: store),
          ),
          GoRoute(
            path: Routes.settings,
            builder: (context, state) => SettingsView(viewModel: settings),
          ),
          GoRoute(
            path: '/modul/:key',
            builder: (context, state) =>
                ComingSoonView(moduleKey: state.pathParameters['key']!),
          ),
        ],
      ),
    ],
  );
}
