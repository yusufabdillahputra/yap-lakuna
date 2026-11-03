import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'config/app_environment.dart';
import 'data/repositories/app_settings_repository.dart';
import 'data/repositories/local_app_settings_repository.dart';
import 'routing/router.dart';
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

  runApp(
    MultiProvider(
      providers: [
        Provider<LakunaStore>.value(value: store),
        Provider<AppEnvironment>.value(value: environment),
        Provider<AppSettingsRepository>.value(value: settingsRepository),
        ChangeNotifierProvider<AppSettingsViewModel>.value(value: settings),
      ],
      child: LakunaApp(
        settings: settings,
        router: createRouter(settings: settings),
      ),
    ),
  );
}
