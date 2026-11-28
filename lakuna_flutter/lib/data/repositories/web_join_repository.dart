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

/// [WebJoinRepository] lewat klien Serverpod.
class RemoteWebJoinRepository implements WebJoinRepository {
  RemoteWebJoinRepository({
    required String appVersion,
    HostingConnection Function(Uri server)? connect,
  }) : _appVersion = appVersion,
       _connect = connect ?? ServerpodHosting.new;

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
