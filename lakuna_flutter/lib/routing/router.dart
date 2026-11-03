import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../data/repositories/session_repository.dart';
import '../data/repositories/store_repository.dart';
import '../ui/coming_soon/coming_soon_view.dart';
import '../ui/core/app_shell.dart';
import '../ui/core/menu.dart';
import '../ui/home/home_view.dart';
import '../ui/login/login_view.dart';
import '../ui/onboarding/onboarding_view.dart';
import '../ui/settings/app_settings_view_model.dart';
import '../ui/settings/settings_view.dart';
import 'routes.dart';

/// Router aplikasi:
/// - toko belum ada → [Routes.setup];
/// - toko ada tanpa staf bertugas → [Routes.login];
/// - staf bertugas di [Routes.setup]/[Routes.login] → Beranda;
/// - modul yang izinnya tidak dimiliki staf → Beranda.
GoRouter createRouter({
  required AppSettingsViewModel settings,
  required StoreRepository store,
  required SessionRepository session,
  String initialLocation = Routes.home,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: Listenable.merge([store, session]),
    redirect: (context, state) {
      final location = state.matchedLocation;
      if (store.current == null) {
        return location == Routes.setup ? null : Routes.setup;
      }
      final staff = session.current;
      if (staff == null) {
        return location == Routes.login ? null : Routes.login;
      }
      if (location == Routes.login || location == Routes.setup) {
        return Routes.home;
      }
      final moduleKey = state.pathParameters['key'];
      if (moduleKey != null) {
        final entry = menuEntryByKey(moduleKey);
        if (entry != null && !entry.allows(staff.permissions)) {
          return Routes.home;
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.setup,
        builder: (context, state) => OnboardingScreen(
          repository: store,
          session: session,
          settings: settings,
        ),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) =>
            LoginScreen(session: session, store: store),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(
          location: state.uri.path,
          session: session,
          child: child,
        ),
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (context, state) =>
                HomeView(store: store, session: session),
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
