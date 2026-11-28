import 'package:flutter/foundation.dart';
import 'package:lakuna_data/lakuna_data.dart' show parsePairingInput;

import '../../data/repositories/hosting_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';
import 'hosting_view_model.dart' show HostingFormIncomplete;

/// Kode perangkat: 1–6 huruf atau angka (mis. `K02`).
final _deviceCodePattern = RegExp(r'^[A-Z0-9]{1,6}$');

/// Gabung ke toko versi hosting lewat kode pasang (F2-01 aturan 10):
/// tempel `<alamat>#<kode>`, periksa, pilih cabang dan kode perangkat, lalu
/// data toko ditarik dan aplikasi dimuat ulang.
class JoinViewModel extends ChangeNotifier {
  JoinViewModel({required this._repository, this._restart}) {
    check = Command0(_check)..addListener(notifyListeners);
    join = Command0(_join)..addListener(notifyListeners);
  }

  final HostingRepository _repository;

  /// Memuat ulang aplikasi setelah data siap (`null` di tes).
  final Future<void> Function()? _restart;

  late final Command0<List<PairingOutlet>> check;
  late final Command0<void> join;

  String _server = '';
  String _code = '';
  String get serverUrl => _server.trim();
  String get code => _code;

  /// Naik setiap kode lengkap ditempel, agar isian alamat dan kode dibuat
  /// ulang dengan nilai baru.
  int _fillRevision = 0;
  int get fillRevision => _fillRevision;

  List<PairingOutlet>? _outlets;
  List<PairingOutlet>? get outlets => _outlets;
  PairingOutlet? _outlet;
  PairingOutlet? get outlet => _outlet;
  String _deviceCode = '';
  String get deviceCode => _deviceCode;
  String _deviceName = '';
  int _localSales = 0;

  /// Penjualan di database lokal yang akan diganti (peringatan).
  int get localSales => _localSales;
  var _staged = false;
  bool get staged => _staged;
  var _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  // Perintah tidak dibuang: [join] masih menunggu [_restart] saat aplikasi
  // dimuat ulang dan dialog dilepas.
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  bool get busy => check.running || join.running || _staged;

  /// Isian alamat: kode lengkap `<alamat>#<kode>` mengisi keduanya.
  void setServer(String value) {
    final parsed = parsePairingInput(value);
    if (value.contains('#') && parsed.serverUrl != null) {
      _server = parsed.serverUrl!;
      _code = parsed.code;
      _fillRevision++;
    } else {
      _server = value;
    }
    _resetCheck();
  }

  void setCode(String value) {
    final parsed = parsePairingInput(value);
    if (parsed.serverUrl != null && value.contains('#')) {
      _server = parsed.serverUrl!;
      _fillRevision++;
    }
    _code = parsed.code;
    _resetCheck();
  }

  void _resetCheck() {
    _outlets = null;
    _outlet = null;
    check.clearResult();
    join.clearResult();
    notifyListeners();
  }

  bool get canCheck => serverUrl.isNotEmpty && _code.length >= 8 && !busy;

  Future<Result<List<PairingOutlet>>> _check() async {
    final result = await _repository.pairingOutlets(serverUrl, _code);
    if (result case Ok(:final value)) {
      _outlets = value;
      _outlet = value.length == 1 ? value.single : null;
      if (await _repository.localSales() case Ok(:final value)) {
        _localSales = value;
      }
    }
    return result;
  }

  void selectOutlet(PairingOutlet outlet) {
    _outlet = outlet;
    notifyListeners();
  }

  void setDeviceCode(String value) {
    _deviceCode = value.trim().toUpperCase();
    notifyListeners();
  }

  void setDeviceName(String value) {
    _deviceName = value;
    notifyListeners();
  }

  bool get deviceCodeValid => _deviceCodePattern.hasMatch(_deviceCode);

  bool get canJoin =>
      _outlet != null &&
      deviceCodeValid &&
      _deviceName.trim().isNotEmpty &&
      !busy;

  Future<Result<void>> _join() async {
    final outlet = _outlet;
    if (outlet == null || !deviceCodeValid) {
      return const Result.error(HostingFormIncomplete());
    }
    final result = await _repository.join(
      serverUrl,
      code: _code,
      outletId: outlet.id,
      deviceCode: _deviceCode,
      deviceName: _deviceName.trim(),
    );
    if (result case Error(:final error)) return Result.error(error);
    _staged = true;
    notifyListeners();
    await _restart?.call();
    return const Result.ok(null);
  }
}
