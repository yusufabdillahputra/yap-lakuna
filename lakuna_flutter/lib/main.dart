import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'config/app_environment.dart';
import 'data/repositories/app_settings_repository.dart';
import 'data/repositories/cash_drawer_repository.dart';
import 'data/repositories/local_app_settings_repository.dart';
import 'data/repositories/local_cash_drawer_repository.dart';
import 'data/repositories/local_session_repository.dart';
import 'data/repositories/local_store_repository.dart';
import 'data/repositories/session_repository.dart';
import 'data/repositories/store_repository.dart';
import 'routing/router.dart';
import 'utils/result.dart';
import 'ui/settings/app_settings_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final databasePath = await resolveDatabasePath();
  final store = await LakunaStore.open(databasePath, isDebugMode: kDebugMode);
  final environment = AppEnvironment(
    databasePath: databasePath,
    deviceId: store.deviceId.uuid,
    version: appVersion,
  );
  final settingsRepository = LocalAppSettingsRepository(
    LocalPreferences(store.session),
  );
  final settings = AppSettingsViewModel(repository: settingsRepository);
  await settings.load.execute();
  final storeRepository = LocalStoreRepository(store);
  if (await storeRepository.load() case Error(:final error)) {
    // Wizard tetap tampil; galatnya dicatat agar bisa dilacak.
    debugPrint('Konteks toko gagal dimuat: $error');
  }
  final sessionRepository = LocalSessionRepository(
    store,
    stores: storeRepository,
  );
  final cashDrawerRepository = LocalCashDrawerRepository(
    store,
    stores: storeRepository,
    session: sessionRepository,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<LakunaStore>.value(value: store),
        Provider<AppEnvironment>.value(value: environment),
        Provider<AppSettingsRepository>.value(value: settingsRepository),
        ChangeNotifierProvider<AppSettingsViewModel>.value(value: settings),
        ChangeNotifierProvider<StoreRepository>.value(value: storeRepository),
        ChangeNotifierProvider<SessionRepository>.value(
          value: sessionRepository,
        ),
        Provider<CashDrawerRepository>.value(value: cashDrawerRepository),
      ],
      child: LakunaApp(
        settings: settings,
        router: createRouter(
          settings: settings,
          store: storeRepository,
          session: sessionRepository,
          cashDrawer: cashDrawerRepository,
        ),
      ),
    ),
  );
}
