import 'package:flutter/widgets.dart';

import 'app_root.dart';
import 'config/app_environment.dart';
import 'config/bundled_licenses.dart';
import 'data/repositories/web_join_repository.dart';
import 'data/services/web_page.dart';
import 'ui/web/web_login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  registerBundledLicenses();
  final webJoin = RemoteWebJoinRepository(appVersion: appVersion);
  runApp(
    LakunaRoot(
      // Web tanpa sesi: login pemilik 2.2; kode pasang lewat tautan kecil
      // (F2-02 tugas 11).
      webJoin: (context, sessions, onJoined) => WebLoginApp(
        join: webJoin,
        login: webJoin,
        sessions: sessions,
        onJoined: onJoined,
        initialServer: defaultWebServerUrl(),
        reload: reloadPage,
      ),
    ),
  );
}
