import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/app.dart';
import 'package:lakuna_flutter/config/app_environment.dart';
import 'package:lakuna_flutter/routing/router.dart';
import 'package:lakuna_flutter/routing/routes.dart';
import 'package:lakuna_flutter/ui/settings/app_settings_view_model.dart';
import 'package:provider/provider.dart';

import 'fake_app_settings_repository.dart';
import 'fake_session_repository.dart';
import 'fake_store_repository.dart';

/// Menjalankan aplikasi lengkap dengan repositori palsu pada ukuran layar
/// tertentu.
Future<AppSettingsViewModel> pumpLakuna(
  WidgetTester tester, {
  Size size = const Size(1280, 800),
  FakeAppSettingsRepository? repository,
  String initialLocation = Routes.home,
  FakeStoreRepository? store,
  FakeSessionRepository? session,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final settings = AppSettingsViewModel(
    repository: repository ?? FakeAppSettingsRepository(),
  );
  await settings.load.execute();
  final storeRepository =
      store ?? FakeStoreRepository(current: sampleStoreContext());
  // Bawaan: toko sudah ada dan pemilik sedang bertugas. Tanpa toko, belum
  // ada yang bertugas.
  final sessionRepository =
      session ??
      (FakeSessionRepository()
        ..current = storeRepository.current == null ? null : sampleStaff());
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<AppEnvironment>.value(
          value: const AppEnvironment(
            databasePath: '/tmp/lakuna.sqlite',
            deviceId: '0192f3a1-7c00-7000-8000-000000000001',
            version: '0.1.0',
          ),
        ),
      ],
      child: LakunaApp(
        settings: settings,
        router: createRouter(
          settings: settings,
          store: storeRepository,
          session: sessionRepository,
          initialLocation: initialLocation,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return settings;
}
