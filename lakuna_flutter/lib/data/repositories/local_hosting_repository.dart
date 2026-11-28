import 'dart:async';
import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart' as data;
import 'package:lakuna_data/lakuna_data.dart'
    show
        HostingAlreadyActive,
        HostingNotActive,
        HostingState,
        HostingVault,
        LakunaStore,
        SyncCycleOutcome,
        SyncCycleResult,
        SyncEngine,
        SyncScheduler,
        UploadGroupProgress;
import 'package:lakuna_domain/lakuna_domain.dart' show Permission;
import 'package:path/path.dart' as p;

import '../../utils/result.dart';
import '../services/serverpod_hosting.dart';
import 'hosting_repository.dart';
import 'repository_errors.dart';
import 'session_repository.dart';
import 'store_repository.dart';

/// Umur kode pasang (sama dengan server, aturan 10).
const pairingCodeLifetime = Duration(minutes: 15);

/// Alamat *Server Lakuna* yang dibawa build rilis.
const lakunaHostingUrl = String.fromEnvironment('LAKUNA_HOSTING_URL');

/// Versi hosting di atas database perangkat dan server Serverpod.
class LocalHostingRepository extends HostingRepository {
  LocalHostingRepository(
    this._store, {
    required this._stores,
    required this._session,
    required this._appVersion,
    HostingConnection Function(Uri server)? connect,
    String? lakunaServerUrl = lakunaHostingUrl,
    DateTime Function()? clock,
  }) : _connect = connect ?? ServerpodHosting.new,
       _lakunaServerUrl = (lakunaServerUrl?.isEmpty ?? true)
           ? null
           : lakunaServerUrl,
       _clock = clock ?? DateTime.now;

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;
  final String _appVersion;
  final HostingConnection Function(Uri server) _connect;
  final String? _lakunaServerUrl;
  final DateTime Function() _clock;

  /// Koneksi per alamat selama aktivasi (sesi login pemilik di memori).
  final _connections = <String, HostingConnection>{};
  HostingConnection? _syncConnection;
  SyncScheduler? _scheduler;
  SyncStatus _status = SyncStatus.local;
  var _syncing = false;
  var _disposed = false;

  @override
  SyncStatus get status => _status;

  @override
  String? get lakunaServerUrl => _lakunaServerUrl;

  String get _dataDir => File(_store.path).parent.path;

  /// Menyalakan sync otomatis bila versi hosting aktif (saat aplikasi
  /// dibuka dan setelah aktivasi).
  Future<void> start() async {
    final state = await data.loadHostingState(_store);
    if (!state.active) {
      _setStatus(SyncStatus.local);
      return;
    }
    _setStatus(_fromState(state, SyncChipKind.syncing));
    if (_scheduler != null) {
      _scheduler!.syncNow();
      return;
    }
    final token = await HostingVault.of(_store).readToken();
    final server = data.parseServerUrl(state.serverUrl!);
    if (token == null || server == null) return;
    final connection = _syncConnection = _connect(server);
    final engine = SyncEngine(_store, connection.transport(token));
    final scheduler = _scheduler = SyncScheduler(
      () async {
        _syncing = true;
        // Siklus tanpa perubahan menunggu tidak membuat chip berkedip.
        if (_status.pending > 0 && _status.kind != SyncChipKind.paused) {
          _setStatus(
            SyncStatus(
              kind: SyncChipKind.syncing,
              pending: _status.pending,
              conflicts: _status.conflicts,
              lastSyncAt: _status.lastSyncAt,
            ),
          );
        }
        try {
          return await data.runHostingCycle(engine);
        } finally {
          _syncing = false;
        }
      },
      onResult: (r) => _setStatus(_fromResult(r)),
    );
    _store.afterWrite = scheduler.notifyWrite;
    scheduler.start();
  }

  SyncStatus _fromState(HostingState s, SyncChipKind kind) => SyncStatus(
    kind: s.paused ? SyncChipKind.paused : kind,
    pending: s.pending,
    conflicts: s.conflicts,
    lastSyncAt: s.lastSyncAt,
    error: s.lastError,
  );

  SyncStatus _fromResult(SyncCycleResult r) => SyncStatus(
    kind: switch (r.outcome) {
      SyncCycleOutcome.synced =>
        r.pending > 0 ? SyncChipKind.syncing : SyncChipKind.synced,
      SyncCycleOutcome.offline => SyncChipKind.waiting,
      SyncCycleOutcome.attention => SyncChipKind.attention,
      SyncCycleOutcome.paused => SyncChipKind.paused,
    },
    pending: r.pending,
    conflicts: r.conflicts,
    lastSyncAt: r.at,
    error: r.error,
  );

  void _setStatus(SyncStatus s) {
    if (_disposed || s == _status) return;
    _status = s;
    notifyListeners();
  }

  /// Menghentikan sync (saat aplikasi ditutup atau dimuat ulang).
  Future<void> stop() async {
    final scheduler = _scheduler;
    _scheduler = null;
    _store.afterWrite = null;
    // Siklus yang sedang berjalan selesai dulu sebelum koneksi (dan
    // sesudahnya database) ditutup.
    await scheduler?.stop();
    _syncConnection?.close();
    _syncConnection = null;
    for (final c in _connections.values) {
      c.close();
    }
    _connections.clear();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(stop());
    super.dispose();
  }

  Future<Result<T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Result.ok(await body());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<T>> _manage<T>(
    Future<T> Function(data.StoreContext ctx, StaffProfile staff) body,
  ) async {
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    final staff = _session.current;
    if (staff == null || !staff.can(Permission.syncManage)) {
      return const Result.error(NotPermitted(Permission.syncManage));
    }
    return _guard(() => body(ctx, staff));
  }

  Uri _server(String serverUrl) {
    final uri = data.parseServerUrl(serverUrl);
    if (uri == null) throw const InvalidServerUrl();
    return uri;
  }

  HostingConnection _connection(String serverUrl) {
    final uri = _server(serverUrl);
    return _connections[uri.toString()] ??= _connect(uri);
  }

  @override
  Future<Result<HostingState>> load() =>
      _guard(() => data.loadHostingState(_store));

  @override
  Future<Result<SyncServerStatus>> checkServer(String serverUrl) => _guard(
    () => data.checkHostingServer(
      _connection(serverUrl),
      appVersion: _appVersion,
    ),
  );

  @override
  Future<Result<void>> login(
    String serverUrl, {
    required String email,
    required String password,
  }) => _guard(
    () => _connection(serverUrl).login(email: email, password: password),
  );

  @override
  Future<Result<UuidValue>> startRegistration(String serverUrl, String email) =>
      _guard(() => _connection(serverUrl).startRegistration(email));

  @override
  Future<Result<String>> verifyRegistration(
    String serverUrl, {
    required UuidValue requestId,
    required String code,
  }) => _guard(
    () => _connection(serverUrl).verifyRegistration(requestId, code),
  );

  @override
  Future<Result<void>> finishRegistration(
    String serverUrl, {
    required String registrationToken,
    required String password,
  }) => _guard(
    () => _connection(
      serverUrl,
    ).finishRegistration(registrationToken, password),
  );

  @override
  Future<Result<void>> activate(
    String serverUrl, {
    required String activationCode,
  }) => _manage((ctx, staff) async {
    final uri = _server(serverUrl);
    try {
      await data.activateHosting(
        _store,
        ctx,
        staffId: staff.id,
        serverUrl: uri.toString(),
        activationCode: activationCode,
        client: _connection(serverUrl),
        appVersion: _appVersion,
      );
    } on HostingAlreadyActive {
      // Percobaan ulang setelah aktivasi terputus sesudah token tersimpan:
      // siklus sync melanjutkan tanda hosted dan pemadatan (aturan 15).
    } finally {
      // Token sudah tersimpan walau langkah sesudahnya gagal: sync tetap
      // dinyalakan agar perangkat tidak aktif tanpa sync.
      if ((await data.loadHostingState(_store)).active) await start();
    }
    // Sesi pemilik tidak dipakai lagi setelah perangkat punya token.
    _connections.remove(uri.toString())?.close();
  });

  @override
  Future<Result<List<UploadGroupProgress>>> uploadProgress() =>
      _guard(() => data.initialUploadProgress(_store));

  @override
  Future<Result<void>> setPaused(bool paused) => _manage((ctx, staff) async {
    await data.setSyncPaused(
      _store,
      ctx,
      staffId: staff.id,
      paused: paused,
    );
    final state = await data.loadHostingState(_store);
    _setStatus(
      _fromState(state, paused ? SyncChipKind.paused : SyncChipKind.syncing),
    );
    if (!paused) _scheduler?.syncNow();
  });

  @override
  void syncNow() {
    if (_syncing) return;
    _scheduler?.syncNow();
  }

  @override
  Future<Result<PairingCodeShare>> createPairingCode() =>
      _manage((ctx, staff) async {
        final state = await data.loadHostingState(_store);
        final server = data.parseServerUrl(state.serverUrl ?? '');
        final connection = _syncConnection;
        if (!state.active || server == null || connection == null) {
          throw const HostingNotActive();
        }
        final code = await data.createHostingPairingCode(
          _store,
          ctx,
          staffId: staff.id,
          client: connection,
        );
        return (
          code: code,
          shareText: data.pairingShareText(server, code),
          expiresAt: _clock().toUtc().add(pairingCodeLifetime),
        );
      });

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
  Future<Result<int>> localSales() =>
      _guard(() => Sale.db.count(_store.session));

  @override
  Future<Result<void>> join(
    String serverUrl, {
    required String code,
    required UuidValue outletId,
    required String deviceCode,
    required String deviceName,
  }) => _guard(() async {
    final ctx = _stores.current;
    // Perangkat yang sudah punya toko: hanya pemilik/pengelola sync.
    if (ctx != null &&
        !(_session.current?.can(Permission.syncManage) ?? false)) {
      throw const NotPermitted(Permission.syncManage);
    }
    final uri = _server(serverUrl);
    final connection = _connection(serverUrl);
    await data.joinHosting(
      databasePath: _store.path,
      serverUrl: uri.toString(),
      client: connection,
      transport: connection.transport,
      appVersion: _appVersion,
      pairingCode: code,
      outletId: outletId,
      deviceCode: deviceCode.trim().toUpperCase(),
      deviceName: deviceName.trim(),
      platform: currentDevicePlatform(),
      backupFirst: () async {
        if (ctx == null) return;
        final now = _clock();
        final out = p.join(
          _dataDir,
          'backup-sebelum-gabung',
          data.backupFileName(ctx, now),
        );
        await data.createBackup(
          _store,
          ctx,
          outPath: out,
          appVersion: _appVersion,
          now: now,
        );
      },
    );
  });
}
