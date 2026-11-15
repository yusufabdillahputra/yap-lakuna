import 'dart:ui' show AppExitResponse;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Menahan permintaan menutup aplikasi dari sistem operasi desktop (tombol
/// ✕ jendela, Alt+F4, Cmd+Q) sampai [canExit] mengizinkan (F1-02c).
///
/// [canExit] biasanya `LeaveGuards.canLeaveAll`: halaman yang berubah
/// bertanya *Buang perubahan?* dulu. Permintaan yang datang selagi
/// pemeriksaan berjalan (dialog masih terbuka) ditolak tanpa bertanya lagi.
/// Galat di [canExit] dilaporkan lalu aplikasi tetap ditutup, agar jendela
/// tidak terkunci oleh penjaga yang rusak.
///
/// Di macOS tombol ✕ bertanya lewat [windowChannel] (`requestClose` →
/// `bool`) sebelum runner memanggil `NSApp.terminate`; izin itu dipakai
/// sekali oleh permintaan keluar berikutnya agar tidak bertanya dua kali.
class ExitGuard extends StatefulWidget {
  const ExitGuard({super.key, required this.canExit, required this.child});

  /// Kanal dari `MainFlutterWindow.performClose` (macOS).
  static const windowChannel = MethodChannel('lakuna/window');

  final Future<bool> Function() canExit;
  final Widget child;

  @override
  State<ExitGuard> createState() => _ExitGuardState();
}

class _ExitGuardState extends State<ExitGuard> {
  late final AppLifecycleListener _listener = AppLifecycleListener(
    onExitRequested: _onExitRequested,
  );
  bool _checking = false;

  /// Tombol ✕ macOS sudah diizinkan; permintaan keluar berikutnya langsung
  /// keluar.
  bool _approved = false;

  Future<bool> _check() async {
    if (_checking) return false;
    _checking = true;
    try {
      return await widget.canExit();
    } finally {
      _checking = false;
    }
  }

  Future<AppExitResponse> _onExitRequested() async {
    if (_approved) {
      _approved = false;
      return AppExitResponse.exit;
    }
    return await _check() ? AppExitResponse.exit : AppExitResponse.cancel;
  }

  Future<Object?> _onWindowCall(MethodCall call) async {
    if (call.method != 'requestClose') throw MissingPluginException();
    final allowed = await _check();
    if (allowed) _approved = true;
    return allowed;
  }

  @override
  void initState() {
    super.initState();
    _listener;
    ExitGuard.windowChannel.setMethodCallHandler(_onWindowCall);
  }

  @override
  void dispose() {
    ExitGuard.windowChannel.setMethodCallHandler(null);
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
