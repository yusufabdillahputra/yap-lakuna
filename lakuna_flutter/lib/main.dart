import 'package:flutter/widgets.dart';

import 'app_root.dart';
import 'config/app_environment.dart';
import 'config/bundled_licenses.dart';
import 'data/repositories/web_join_repository.dart';
import 'data/services/web_page.dart';
import 'ui/web/web_join_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  registerBundledLicenses();
  final webJoin = RemoteWebJoinRepository(appVersion: appVersion);
  runApp(
    LakunaRoot(
      webJoin: (context, sessions, onJoined) => WebJoinApp(
        repository: webJoin,
        sessions: sessions,
        onJoined: onJoined,
        initialServer: defaultWebServerUrl(),
        reload: reloadPage,
      ),
    ),
  );
}
