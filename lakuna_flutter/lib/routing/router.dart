import 'package:go_router/go_router.dart';

import '../ui/coming_soon/coming_soon_view.dart';
import '../ui/core/app_shell.dart';
import '../ui/home/home_view.dart';
import '../ui/settings/app_settings_view_model.dart';
import '../ui/settings/settings_view.dart';
import 'routes.dart';

GoRouter createRouter({
  required AppSettingsViewModel settings,
  String initialLocation = Routes.home,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (context, state) => const HomeView(),
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
