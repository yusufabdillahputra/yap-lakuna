import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart' as data;

import '../../utils/result.dart';
import '../services/serverpod_hosting.dart';
import 'hosting_repository.dart' show InvalidServerUrl;

/// Masuk ke toko versi hosting dari browser (F2-02 aturan 2 dan 6) sebelum
/// database apa pun terbuka: kode pasang, perangkat web baru, lalu pull
/// pertama ke database sesi.
abstract interface class WebJoinRepository {
  /// Cabang toko untuk [code] (versi server diperiksa lebih dulu).
  Future<Result<List<PairingOutlet>>> pairingOutlets(
    String serverUrl,
    String code,
  );

  /// Membuat perangkat web baru dengan kode pasang dan menyimpan
  /// kredensialnya di database sesi kosong. Membalas nama database.
  Future<Result<String>> register(
    String serverUrl, {
    required String code,
    required UuidValue outletId,
  });

  /// Menarik data toko ke [database]; melanjutkan dari kursor bila pull
  /// sebelumnya terputus.
  Future<Result<void>> pull(String database, {data.PullProgress? onPull});

  /// Menghapus [database] (gabung dibatalkan).
  Future<Result<void>> discard(String database);
}

/// Login web pemilik (F2-02 aturan 11–13a): akun email + kata sandi, lalu
/// kode verifikasi 2 langkah membuat perangkat web tenant. Pull pertama
/// memakai [WebJoinRepository.pull].
abstract interface class WebLoginRepository {
  /// Login akun di [serverUrl] (versi server diperiksa lebih dulu) dan
  /// membalas toko miliknya. `WebAccessException(totpNotEnabled)` bila
  /// verifikasi 2 langkah belum aktif.
  Future<Result<List<WebTenant>>> signIn(
    String serverUrl, {
    required String email,
    required String password,
  });

  /// Kode authenticator atau kode cadangan → perangkat web baru tenant
  /// [tenantId], kredensialnya disimpan di database sesi kosong. Membalas
  /// nama database.
  Future<Result<String>> open(
    String serverUrl, {
    required String code,
    required UuidValue tenantId,
    required bool remember,
  });

  /// *Lupa kata sandi?*: kirim kode ke [email].
  Future<Result<UuidValue>> startPasswordReset(String serverUrl, String email);

  /// Kode dari email → token untuk kata sandi baru.
  Future<Result<String>> verifyPasswordReset(
    String serverUrl, {
    required UuidValue requestId,
    required String code,
  });

  Future<Result<void>> finishPasswordReset(
    String serverUrl, {
    required String token,
    required String password,
  });
}

/// [WebJoinRepository] dan [WebLoginRepository] lewat klien Serverpod.
class RemoteWebJoinRepository implements WebJoinRepository, WebLoginRepository {
  RemoteWebJoinRepository({
    required this._appVersion,
    HostingConnection Function(Uri server)? connect,
  }) : _connect = connect ?? ServerpodHosting.new;

  final String _appVersion;
  final HostingConnection Function(Uri server) _connect;
  final _connections = <String, HostingConnection>{};

  HostingConnection _connection(String serverUrl) {
    final uri = data.parseServerUrl(serverUrl);
    if (uri == null) throw const InvalidServerUrl();
    return _connections[uri.toString()] ??= _connect(uri);
  }

  Future<Result<T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Result.ok(await body());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<List<PairingOutlet>>> pairingOutlets(
    String serverUrl,
    String code,
  ) => _guard(() async {
    final connection = _connection(serverUrl);
    await data.checkHostingServer(connection, appVersion: _appVersion);
    return connection.pairingOutlets(code);
  });

  @override
  Future<Result<String>> register(
    String serverUrl, {
    required String code,
    required UuidValue outletId,
  }) => _guard(() async {
    final connection = _connection(serverUrl);
    // Kode perangkat web dibuat server (W01, W02, …); kode kiriman
    // diabaikan.
    final result = await connection.joinWithPairingCode(
      pairingCode: code,
      outletId: outletId,
      deviceCode: 'W',
      deviceName: 'Browser',
      platform: DevicePlatform.web,
    );
    final name = data.webDatabaseName(result.deviceId);
    await data.prepareWebSession(
      databasePath: name,
      deviceId: result.deviceId,
      deviceToken: result.deviceToken,
      serverUrl: data.parseServerUrl(serverUrl)!.toString(),
    );
    return name;
  });

  @override
  Future<Result<List<WebTenant>>> signIn(
    String serverUrl, {
    required String email,
    required String password,
  }) => _guard(() async {
    final connection = _connection(serverUrl);
    await data.checkHostingServer(connection, appVersion: _appVersion);
    await connection.login(email: email, password: password);
    return connection.webTenants();
  });

  @override
  Future<Result<String>> open(
    String serverUrl, {
    required String code,
    required UuidValue tenantId,
    required bool remember,
  }) => _guard(() async {
    final connection = _connection(serverUrl);
    final result = await connection.webOpen(
      code: code,
      tenantId: tenantId,
      remember: remember,
    );
    final name = data.webDatabaseName(result.deviceId);
    await data.prepareWebSession(
      databasePath: name,
      deviceId: result.deviceId,
      deviceToken: result.deviceToken,
      serverUrl: data.parseServerUrl(serverUrl)!.toString(),
    );
    return name;
  });

  @override
  Future<Result<UuidValue>> startPasswordReset(
    String serverUrl,
    String email,
  ) => _guard(() => _connection(serverUrl).startPasswordReset(email));

  @override
  Future<Result<String>> verifyPasswordReset(
    String serverUrl, {
    required UuidValue requestId,
    required String code,
  }) => _guard(
    () => _connection(serverUrl).verifyPasswordReset(requestId, code),
  );

  @override
  Future<Result<void>> finishPasswordReset(
    String serverUrl, {
    required String token,
    required String password,
  }) => _guard(
    () => _connection(serverUrl).finishPasswordReset(token, password),
  );

  @override
  Future<Result<void>> pull(String database, {data.PullProgress? onPull}) =>
      _guard(() async {
        final session = await data.readWebSession(database);
        if (session == null) throw const data.HostingJoinIncomplete();
        final connection = _connection(session.serverUrl);
        await data.joinHostingWeb(
          databasePath: database,
          deviceId: session.deviceId,
          deviceToken: session.deviceToken,
          serverUrl: session.serverUrl,
          transport: connection.transport(session.deviceToken),
          onPull: onPull,
        );
      });

  @override
  Future<Result<void>> discard(String database) =>
      _guard(() => data.deleteWebDatabase(database));
}
