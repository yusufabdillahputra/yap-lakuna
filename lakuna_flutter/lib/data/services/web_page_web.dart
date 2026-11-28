import 'package:web/web.dart' as web;

Future<void> reloadPage() async => web.window.location.reload();

String defaultWebServerUrl() => Uri.base.origin;
