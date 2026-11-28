/// Versi hosting di perangkat: aktivasi dan gabung (F2-01 aturan 9–14).
library;

import 'dart:convert';
import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart'
    show Permission, normalizeShortCode;

import 'staff_access.dart';
import 'store.dart';
import 'store_setup.dart';
import 'sync/initial_upload.dart';
import 'sync/media_sync.dart';
import 'sync/sync_engine.dart';
import 'sync/sync_transport.dart';
import 'sync_state.dart';

/// Mengubah `tenants.plan` menjadi `hosted` lewat outbox (aturan 14),
/// sebelum unggah data awal agar LWW di server tidak mengembalikan `free`.
Future<Tenant> markTenantHosted(
  LakunaStore store, {
  required UuidValue staffId,
}) => store.write(actor: staffId, (w) async {
  final tenant = (await Tenant.db.findFirstRow(
    w.session,
    where: (t) => t.deletedAt.equals(null),
    orderBy: (t) => t.createdAt,
    transaction: w.transaction,
  ))!;
  if (tenant.plan == TenantPlan.hosted) return tenant;
  final s = await w.stamp();
  return w.update(
    tenant.copyWith(
      plan: TenantPlan.hosted,
      version: tenant.version + 1,
      updatedAt: s.now,
      updatedBy: staffId,
      hlc: s.hlc.toString(),
      originDeviceId: s.deviceId,
    ),
    s,
  );
});

/// Membuat database baru di [path] untuk perangkat yang bergabung lewat
/// kode pasang: ID perangkat dari server (aturan 10a) dan tanpa unggah
/// data awal, karena datanya ditarik dari server. Melempar [StateError]
/// bila berkas sudah ada.
Future<LakunaStore> openJoinedStore(
  String path, {
  required UuidValue deviceId,
  DateTime Function()? clock,
}) async {
  final file = File(path);
  if (file.existsSync()) {
    throw StateError('Database sudah ada: $path');
  }
  await file.parent.create(recursive: true);
  final first = await LakunaStore.open(path, clock: clock);
  await first.session.db.transaction((tx) async {
    await writeSyncState(
      first.session,
      SyncStateKey.deviceId,
      deviceId.uuid,
      transaction: tx,
    );
    await writeSyncState(
      first.session,
      SyncStateKey.initialUpload,
      'done',
      transaction: tx,
    );
    await writeSyncState(
      first.session,
      SyncStateKey.initialUploadAcked,
      '1',
      transaction: tx,
    );
  });
  await first.close();
  return LakunaStore.open(path, clock: clock);
}

// --- Tahap 3: aktivasi, pasang, status (F2-01 aturan 9–16) -----------------

/// Versi protokol `sync.push`/`sync.pull` yang dipahami aplikasi ini.
/// Server dengan versi lebih lama ditolak (*Server perlu diperbarui*).
const syncProtocolVersion = 1;

/// Jalur aktivasi dan pasang perangkat ke server versi hosting. Versi nyata
/// memanggil endpoint `sync`/`activation` lewat klien Serverpod; aktivasi
/// butuh klien yang sudah login sebagai akun pemilik.
abstract interface class HostingClient {
  Future<SyncServerStatus> status(String? deviceToken);

  Future<ActivationResult> activateFirstDevice({
    required String activationCode,
    required UuidValue tenantId,
    required UuidValue deviceId,
    required String tenantName,
    required String deviceCode,
  });

  Future<String> createPairingCode(String deviceToken);

  Future<List<PairingOutlet>> pairingOutlets(String pairingCode);

  Future<ActivationResult> joinWithPairingCode({
    required String pairingCode,
    required UuidValue outletId,
    required String deviceCode,
    required String deviceName,
    required DevicePlatform platform,
  });
}

/// Galat versi hosting di perangkat.
sealed class HostingException implements Exception {
  const HostingException();
}

/// Staf tidak punya izin `sync:manage`.
class HostingNotPermitted extends HostingException {
  const HostingNotPermitted();
}

/// Versi hosting belum aktif di perangkat ini.
class HostingNotActive extends HostingException {
  const HostingNotActive();
}

/// Versi hosting sudah aktif di perangkat ini.
class HostingAlreadyActive extends HostingException {
  const HostingAlreadyActive();
}

/// Server memakai protokol sync lebih lama dari aplikasi.
class HostingServerTooOld extends HostingException {
  const HostingServerTooOld(this.serverVersion);
  final String serverVersion;
}

/// Server meminta versi aplikasi lebih baru.
class HostingAppTooOld extends HostingException {
  const HostingAppTooOld(this.minAppVersion);
  final String minAppVersion;
}

/// Data toko dari server belum lengkap (mis. cabang atau perangkat belum
/// ada) setelah ditarik saat gabung.
class HostingJoinIncomplete extends HostingException {
  const HostingJoinIncomplete();
}

/// Token perangkat versi hosting, disimpan di berkas di samping database
/// (`hosting/device-token`, izin 600 di desktop) agar tidak ikut backup
/// F1-19. Penyimpanan aman platform dicatat sebagai gap.
class HostingVault {
  HostingVault(this.dataDir);

  factory HostingVault.of(LakunaStore store) =>
      HostingVault(File(store.path).parent.path);

  final String dataDir;

  static const folder = 'hosting';

  File get _file => File(
    '$dataDir${Platform.pathSeparator}$folder'
    '${Platform.pathSeparator}device-token',
  );

  Future<String?> readToken() async {
    final file = _file;
    if (!file.existsSync()) return null;
    final token = (await file.readAsString()).trim();
    return token.isEmpty ? null : token;
  }

  Future<void> writeToken(String token) async {
    final file = _file;
    await file.parent.create(recursive: true);
    // Folder 700 lebih dulu agar berkas tidak pernah terbaca proses lain.
    // Hanya desktop POSIX: iOS tidak boleh menjalankan proses dan aplikasi
    // Android/iOS sudah terkurung di folder datanya sendiri.
    await _chmod('700', file.parent.path);
    await file.writeAsString(token, flush: true);
    await _chmod('600', file.path);
  }

  static Future<void> _chmod(String mode, String path) async {
    if (!Platform.isLinux && !Platform.isMacOS) return;
    try {
      await Process.run('chmod', [mode, path]);
    } on ProcessException {
      // Izin berkas hanya lapisan tambahan; token tetap tersimpan.
    }
  }

  Future<void> deleteToken() async {
    final file = _file;
    if (file.existsSync()) await file.delete();
  }
}

/// Ringkasan versi hosting untuk kartu Pengaturan dan chip status.
typedef HostingState = ({
  bool active,
  String? serverUrl,
  DateTime? lastSyncAt,
  int pending,
  int conflicts,
  String? lastError,

  /// *Jeda sync* aktif.
  bool paused,

  /// Pemadatan outbox (aturan 15) belum selesai.
  bool compacting,
});

/// Memeriksa versi server: protokol lebih lama → [HostingServerTooOld];
/// `minAppVersion` di atas [appVersion] → [HostingAppTooOld].
Future<SyncServerStatus> checkHostingServer(
  HostingClient client, {
  required String appVersion,
  String? deviceToken,
}) async {
  final status = await client.status(deviceToken);
  if (status.protocolVersion < syncProtocolVersion) {
    throw HostingServerTooOld(status.serverVersion);
  }
  final min = status.minAppVersion;
  if (status.protocolVersion > syncProtocolVersion ||
      (min != null &&
          // Build lokal (`dev`) dianggap terbaru.
          RegExp(r'^\d').hasMatch(appVersion) &&
          compareVersions(min, appVersion) > 0)) {
    throw HostingAppTooOld(min ?? status.serverVersion);
  }
  return status;
}

/// Membandingkan versi SemVer `x.y.z` (bagian pre-release diabaikan).
int compareVersions(String a, String b) {
  List<int> parts(String v) => [
    for (final p in v.split(RegExp(r'[-+]')).first.split('.'))
      int.tryParse(p) ?? 0,
  ];
  final x = parts(a);
  final y = parts(b);
  for (var i = 0; i < 3; i++) {
    final l = i < x.length ? x[i] : 0;
    final r = i < y.length ? y[i] : 0;
    if (l != r) return l.compareTo(r);
  }
  return 0;
}

Future<HostingState> loadHostingState(LakunaStore store) async {
  final session = store.session;
  final serverUrl = await store.syncState(SyncStateKey.serverUrl);
  final token = await HostingVault.of(store).readToken();
  final pending = await SyncOutboxEntry.db.count(
    session,
    where: (e) =>
        e.status.equals(OutboxStatus.pending) |
        e.status.equals(OutboxStatus.sent),
  );
  final rejected = await SyncOutboxEntry.db.count(
    session,
    where: (e) => e.status.equals(OutboxStatus.conflict),
  );
  final parked = await store.syncState(SyncStateKey.pullParked);
  var parkedCount = 0;
  if (parked != null && parked.isNotEmpty) {
    try {
      parkedCount = (jsonDecode(parked) as List).length;
    } on FormatException {
      parkedCount = 0;
    }
  }
  final error = await store.syncState(SyncStateKey.lastError);
  final initial = await store.syncState(SyncStateKey.initialUpload);
  return (
    active: serverUrl != null && serverUrl.isNotEmpty && token != null,
    serverUrl: serverUrl == null || serverUrl.isEmpty ? null : serverUrl,
    lastSyncAt: DateTime.tryParse(
      await store.syncState(SyncStateKey.lastSyncAt) ?? '',
    ),
    pending: pending,
    conflicts: rejected + parkedCount,
    lastError: error == null || error.isEmpty ? null : error,
    paused: await store.syncState(SyncStateKey.syncPaused) == '1',
    compacting: initial == 'pending' || initial == 'restamp',
  );
}

Future<void> _requireSyncManager(
  LakunaStore store,
  StoreContext ctx,
  UuidValue staffId,
) async {
  final staff = await findStaffById(
    store,
    tenantId: ctx.tenant.id,
    outletId: ctx.outlet.id,
    staffId: staffId,
  );
  if (staff == null || !staff.permissions.contains(Permission.syncManage)) {
    throw const HostingNotPermitted();
  }
}

/// Mengaktifkan versi hosting di perangkat pertama (aturan 9, 13–15):
/// periksa server, aktivasi dengan [activationCode] lewat [client] yang
/// sudah login sebagai pemilik, simpan token dan alamat server, tandai
/// tenant *hosted*, lalu padatkan outbox untuk unggah data awal. Siklus
/// sync berikutnya melanjutkan pemadatan bila aplikasi tertutup di tengah.
Future<void> activateHosting(
  LakunaStore store,
  StoreContext ctx, {
  required UuidValue staffId,
  required String serverUrl,
  required String activationCode,
  required HostingClient client,
  required String appVersion,
}) async {
  await _requireSyncManager(store, ctx, staffId);
  if ((await loadHostingState(store)).active) {
    throw const HostingAlreadyActive();
  }
  final status = await checkHostingServer(client, appVersion: appVersion);
  final result = await client.activateFirstDevice(
    activationCode: activationCode,
    tenantId: ctx.tenant.id,
    deviceId: store.deviceId,
    tenantName: ctx.tenant.name,
    deviceCode: ctx.device.code,
  );
  // Token hanya dikirim sekali: simpan sebelum langkah lain.
  await HostingVault.of(store).writeToken(result.deviceToken);
  await store.session.db.transaction((tx) async {
    await writeSyncState(
      store.session,
      SyncStateKey.serverUrl,
      serverUrl,
      transaction: tx,
    );
    await writeSyncState(
      store.session,
      SyncStateKey.syncPaused,
      '',
      transaction: tx,
    );
  });
  await markTenantHosted(store, staffId: staffId);
  await prepareInitialUpload(store, serverNow: status.serverTime);
}

/// Kode pasang perangkat berikutnya (aturan 10), berlaku 15 menit.
Future<String> createHostingPairingCode(
  LakunaStore store,
  StoreContext ctx, {
  required UuidValue staffId,
  required HostingClient client,
}) async {
  await _requireSyncManager(store, ctx, staffId);
  final token = await HostingVault.of(store).readToken();
  if (token == null || !(await loadHostingState(store)).active) {
    throw const HostingNotActive();
  }
  return client.createPairingCode(token);
}

/// *Jeda sync* / *Lanjutkan* (aturan 16). Kasir tetap jalan dan tulisan
/// baru masuk outbox seperti biasa.
Future<void> setSyncPaused(
  LakunaStore store,
  StoreContext ctx, {
  required UuidValue staffId,
  required bool paused,
}) async {
  await _requireSyncManager(store, ctx, staffId);
  await writeSyncState(
    store.session,
    SyncStateKey.syncPaused,
    paused ? '1' : '',
  );
}

/// Satu siklus sync versi hosting: berhenti bila dijeda, melanjutkan
/// pemadatan yang terputus (aturan 15), lalu push, pull, dan unggah berkas
/// media.
Future<SyncCycleResult> runHostingCycle(
  SyncEngine engine, {
  MediaTransport? media,
}) async {
  final store = engine.store;
  final state = await loadHostingState(store);
  if (state.paused) {
    return SyncCycleResult(
      outcome: SyncCycleOutcome.paused,
      pending: state.pending,
      conflicts: state.conflicts,
      at: state.lastSyncAt,
    );
  }
  final initial = await store.syncState(SyncStateKey.initialUpload);
  if (initial != 'done') {
    final DateTime serverNow;
    try {
      serverNow = (await engine.transport.status()).serverTime;
    } on Object catch (e) {
      return SyncCycleResult(
        outcome: isOfflineError(e)
            ? SyncCycleOutcome.offline
            : SyncCycleOutcome.attention,
        pending: state.pending,
        conflicts: state.conflicts,
        at: state.lastSyncAt,
        error: isOfflineError(e) ? 'network' : 'local',
      );
    }
    final ctx = await loadStoreContext(store);
    if (ctx != null && ctx.tenant.plan != TenantPlan.hosted) {
      await markTenantHosted(store, staffId: ctx.owner.id);
    }
    await prepareInitialUpload(store, serverNow: serverNow);
  }
  final result = await engine.runCycle();
  // Berkas media setelah barisnya di-push (aturan 19); kegagalan diulang
  // siklus berikutnya dan tidak mengubah hasil siklus.
  if (media != null && result.outcome == SyncCycleOutcome.synced) {
    await uploadPendingMedia(store, media);
  }
  if (result.outcome == SyncCycleOutcome.synced &&
      result.pending == 0 &&
      await store.syncState(SyncStateKey.initialUploadAcked) != '1') {
    await writeSyncState(store.session, SyncStateKey.initialUploadAcked, '1');
  }
  return result;
}

/// Mematikan versi hosting di perangkat ini: token dihapus dan alamat
/// server dikosongkan. Dipakai setelah pulihkan backup (kasus tepi F2-01):
/// outbox dan kursor di backup bisa basi, jadi perangkat dipasang ulang
/// sebagai perangkat baru.
Future<void> disableHosting(LakunaStore store) async {
  await HostingVault.of(store).deleteToken();
  await writeSyncState(store.session, SyncStateKey.serverUrl, '');
  // Aktivasi berikutnya (bisa ke server lain) mulai dari awal: outbox
  // dipadatkan ulang dan pull dari seq 0.
  await SyncStateEntry.db.deleteWhere(
    store.session,
    where: (t) => t.key.inSet({for (final k in _hostingSessionKeys) k.key}),
  );
}

const _hostingSessionKeys = [
  SyncStateKey.initialUpload,
  SyncStateKey.initialUploadCursor,
  SyncStateKey.initialUploadAcked,
  SyncStateKey.mediaUploadCursor,
  SyncStateKey.restampHlc,
  SyncStateKey.pullCursor,
  SyncStateKey.pullParked,
  SyncStateKey.syncPaused,
  SyncStateKey.lastError,
  SyncStateKey.lastSyncAt,
];

// --- Gabung lewat kode pasang (aturan 10, 10a) ------------------------------

const _joinDir = 'gabung';
const _joinReady = 'siap';
const _joinApplying = 'memasang';
const _dbSuffixes = ['', '-wal', '-shm', '-journal'];

String _pathJoin(String a, String b) => '$a${Platform.pathSeparator}$b';

String _stamp(DateTime t) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(t.year % 100)}${two(t.month)}${two(t.day)}-'
      '${two(t.hour)}${two(t.minute)}';
}

/// Bergabung ke toko versi hosting lewat kode pasang. Urutan: periksa
/// server, [backupFirst] (backup F1-19 data lama; gagal = berhenti), pasang
/// di server (ID dan kode perangkat baru dari server), lalu database baru
/// disiapkan di `<folder data>/gabung/` dan semua data toko ditarik dari
/// server. Database aktif belum diganti: [applyPendingJoin] memasangnya
/// saat aplikasi dimulai ulang. Sisa gabung yang gagal dihapus di awal.
Future<void> joinHosting({
  required String databasePath,
  required String serverUrl,
  required HostingClient client,
  required SyncTransport Function(String deviceToken) transport,
  required String appVersion,
  required String pairingCode,
  required UuidValue outletId,
  required String deviceCode,
  required String deviceName,
  required DevicePlatform platform,
  required Future<void> Function() backupFirst,
  DateTime Function()? clock,
}) async {
  final dataDir = File(databasePath).parent.path;
  final staging = Directory(_pathJoin(dataDir, _joinDir));
  final dbName = databasePath.split(Platform.pathSeparator).last;
  await checkHostingServer(client, appVersion: appVersion);
  final stagedDb = _pathJoin(staging.path, dbName);
  final vault = HostingVault(staging.path);
  // Gabung yang putus di tengah pull (kode sudah terpakai, perangkat sudah
  // terdaftar di server) dilanjutkan dari kursornya, bukan pasang ulang.
  final resume = await _resumableJoin(staging, stagedDb, vault, serverUrl);
  final LakunaStore joined;
  final String token;
  if (resume != null) {
    token = resume;
    joined = await LakunaStore.open(stagedDb, clock: clock);
  } else {
    await backupFirst();
    if (staging.existsSync()) await staging.delete(recursive: true);
    final result = await client.joinWithPairingCode(
      pairingCode: pairingCode,
      outletId: outletId,
      deviceCode: deviceCode,
      deviceName: deviceName,
      platform: platform,
    );
    token = result.deviceToken;
    joined = await openJoinedStore(
      stagedDb,
      deviceId: result.deviceId,
      clock: clock,
    );
    try {
      await vault.writeToken(token);
      await writeSyncState(joined.session, SyncStateKey.serverUrl, serverUrl);
    } on Object {
      await joined.close();
      rethrow;
    }
  }
  try {
    final cycle = await SyncEngine(joined, transport(token)).runCycle();
    if (cycle.outcome == SyncCycleOutcome.offline) {
      throw const SyncOfflineException();
    }
    if (await loadStoreContext(joined) == null) {
      throw const HostingJoinIncomplete();
    }
  } finally {
    await joined.close();
  }
  await File(_pathJoin(staging.path, _joinReady))
      .writeAsString(DateTime.now().toUtc().toIso8601String(), flush: true);
}

/// Token gabung yang belum selesai di [staging] untuk [serverUrl] yang
/// sama, atau `null` bila gabung harus dimulai dari awal.
Future<String?> _resumableJoin(
  Directory staging,
  String stagedDb,
  HostingVault vault,
  String serverUrl,
) async {
  if (!staging.existsSync() ||
      File(_pathJoin(staging.path, _joinReady)).existsSync() ||
      !File(stagedDb).existsSync()) {
    return null;
  }
  final token = await vault.readToken();
  if (token == null) return null;
  final store = await LakunaStore.open(stagedDb);
  try {
    if (await store.syncState(SyncStateKey.serverUrl) != serverUrl) {
      return null;
    }
  } finally {
    await store.close();
  }
  return token;
}

/// Memasang database hasil [joinHosting] sebelum database dibuka. Data
/// lama (database, media, token) dipindah ke
/// `<folder data>/sebelum-gabung-<YYMMDD-HHMM>/`, yang dikembalikan; `null`
/// bila tidak ada gabung yang siap. Aman bila aplikasi mati di tengah:
/// folder tujuan dicatat lebih dulu dan setiap langkah hanya jalan bila
/// belum selesai.
Future<String?> applyPendingJoin(String databasePath, {DateTime? now}) async {
  final dataDir = File(databasePath).parent.path;
  final dbName = databasePath.split(Platform.pathSeparator).last;
  final staging = _pathJoin(dataDir, _joinDir);
  if (!File(_pathJoin(staging, _joinReady)).existsSync()) return null;
  final applying = File(_pathJoin(staging, _joinApplying));
  final Directory keep;
  if (applying.existsSync()) {
    keep = Directory(applying.readAsStringSync().trim());
  } else {
    final base = _pathJoin(
      dataDir,
      'sebelum-gabung-${_stamp(now ?? DateTime.now())}',
    );
    var dir = Directory(base);
    for (var i = 2; dir.existsSync(); i++) {
      dir = Directory('$base-$i');
    }
    keep = dir;
    await applying.writeAsString(keep.path, flush: true);
  }
  await keep.create(recursive: true);
  final stagedDb = File(_pathJoin(staging, dbName));
  if (stagedDb.existsSync()) {
    for (final suffix in _dbSuffixes) {
      await _moveIfExists(
        File(_pathJoin(dataDir, '$dbName$suffix')),
        _pathJoin(keep.path, '$dbName$suffix'),
      );
    }
    for (final dir in ['media', HostingVault.folder]) {
      await _moveIfExists(
        Directory(_pathJoin(dataDir, dir)),
        _pathJoin(keep.path, dir),
      );
    }
    for (final suffix in _dbSuffixes.skip(1)) {
      await _moveIfExists(
        File(_pathJoin(staging, '$dbName$suffix')),
        _pathJoin(dataDir, '$dbName$suffix'),
      );
    }
    await stagedDb.rename(_pathJoin(dataDir, dbName));
  }
  final vault = Directory(_pathJoin(dataDir, HostingVault.folder));
  if (!vault.existsSync()) {
    await _moveIfExists(
      Directory(_pathJoin(staging, HostingVault.folder)),
      vault.path,
    );
  }
  await Directory(staging).delete(recursive: true);
  return keep.path;
}

Future<void> _moveIfExists(FileSystemEntity from, String to) async {
  if (!from.existsSync()) return;
  await from.rename(to);
}

// --- Isian alamat server dan kode pasang --------------------------------------

const _localHosts = {'localhost', '127.0.0.1', '::1', '10.0.2.2'};

/// Alamat server dari isian pengguna (diakhiri `/`), atau `null` bila tidak
/// sah. Tanpa skema dianggap `https`; `http` hanya untuk `localhost` (uji).
Uri? parseServerUrl(String input) {
  var text = input.trim();
  if (text.isEmpty) return null;
  if (!text.contains('://')) text = 'https://$text';
  final uri = Uri.tryParse(text);
  if (uri == null || uri.host.isEmpty || uri.userInfo.isNotEmpty) return null;
  final local = _localHosts.contains(uri.host);
  if (uri.scheme != 'https' && !(uri.scheme == 'http' && local)) return null;
  final path = uri.path.endsWith('/') ? uri.path : '${uri.path}/';
  return uri.replace(path: path, query: null, fragment: null);
}

/// Memisah *kode pasang lengkap* `<alamat>#<kode>`; kode dinormalkan
/// (huruf besar, tanpa spasi atau strip).
({String? serverUrl, String code}) parsePairingInput(String input) {
  final text = input.trim();
  final hash = text.lastIndexOf('#');
  final looksLikeUrl = text.contains('://') || text.contains('.');
  if (hash >= 0) {
    final url = text.substring(0, hash).trim();
    return (
      serverUrl: url.isEmpty ? null : url,
      code: normalizeShortCode(text.substring(hash + 1)),
    );
  }
  if (looksLikeUrl) return (serverUrl: text, code: '');
  return (serverUrl: null, code: normalizeShortCode(text));
}

/// Teks *kode pasang lengkap* untuk disalin ke perangkat baru.
String pairingShareText(Uri server, String code) {
  final s = server.toString();
  return '${s.endsWith('/') ? s.substring(0, s.length - 1) : s}#$code';
}
