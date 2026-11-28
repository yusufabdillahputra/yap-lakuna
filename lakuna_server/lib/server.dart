import 'dart:io';

import 'package:serverpod_auth_idp_server/core.dart';

import 'src/auth/smtp_email.dart';
import 'src/cache_busting.dart';
import 'src/generated/serverpod.dart';
import 'src/media/media_storage.dart';
import 'src/web/routes/app_config_route.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod. The generated Serverpod class is already connected
  // with your project's generated code.
  final pod = Serverpod(args);

  // Initialize authentication services for the server.
  // Token managers will be used to validate and issue authentication keys,
  // and the identity providers will be the authentication options available for users.
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      // Use JWT for authentication keys towards the server.
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      // Email pemilik versi hosting (F2-01): kode verifikasi dikirim lewat
      // SMTP dari passwords.yaml (smtpHost, smtpPort, smtpUser,
      // smtpPassword, smtpFrom); tanpa SMTP kode dicatat di log server.
      smtpEmailIdpConfig(),
    ],
  );

  // Serve all files in the web/static relative directory under /web.
  // These are used by the default web page.
  pod.webServer.addRoute(
    StaticRoute.withCacheBusting(cacheBustingConfig),
    cacheBustingConfig.mountPrefix,
  );

  // Setup the app config route.
  // We build this configuration based on the servers api url and serve it to
  // the flutter app.
  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/assets/assets/config.json',
  );

  // Checks if the flutter web app has been built and serves it if it has.
  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    // Serve the flutter web app under /.
    pod.webServer.addRoute(
      FlutterRoute(
        appDir,
        // If building the Flutter app with WASM, set the below parameter to
        // true and add the --wasm flag to the flutter build command.
        enableWasmHeaders: false,
      ),
      '/',
    );
  } else {
    // If the flutter web app has not been built, serve the build app page.
    final defaultRoute = StaticRoute.file(
      File(
        Uri(path: 'web/pages/build_flutter_app.html').toFilePath(),
      ),
    );

    pod.webServer.addMiddleware(
      FallbackMiddleware(
        fallback: defaultRoute,
        on: (response) => response.statusCode == 404,
      ).call,
      '/',
    );

    pod.webServer.addRoute(
      defaultRoute,
      '/**',
    );
  }

  // Media toko (F2-01 aturan 19): S3-compatible bila s3Endpoint, s3AccessKey,
  // s3SecretKey, dan s3Bucket diisi di passwords.yaml atau
  // SERVERPOD_PASSWORD_<kunci>; selain itu di database. Lakuna tidak
  // memakai Serverpod Cloud.
  final s3 = S3Settings.fromPasswords({
    for (final key in s3PasswordKeys) key: pod.getPassword(key),
  });
  for (final storage in mediaStorages(s3)) {
    pod.addCloudStorage(storage);
  }

  // Start the server.
  await pod.start();
}
