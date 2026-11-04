import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:lakuna_data/lakuna_data.dart'
    show applyPendingRestore, undoRestore;
import 'package:path/path.dart' as p;

import 'bootstrap.dart';
import 'config/app_environment.dart';
import 'l10n/gen/app_localizations.dart';

/// Memuat ulang seluruh aplikasi (mis. setelah pulihkan backup, F1-19).
class AppRestart extends InheritedWidget {
  const AppRestart({
    super.key,
    required this.restart,
    this.restoreFailed = false,
    required super.child,
  });

  final Future<void> Function() restart;

  /// Backup terakhir gagal dibuka setelah dipasang, jadi data lama
  /// dikembalikan (ditampilkan di Beranda).
  final bool restoreFailed;

  static AppRestart? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppRestart>();

  @override
  bool updateShouldNotify(AppRestart oldWidget) =>
      restoreFailed != oldWidget.restoreFailed;
}

/// Akar aplikasi: memasang backup yang tertunda, membuka database, dan
/// menampilkan [StartupErrorView] bila gagal. [restart] menutup database
/// lalu mengulang semuanya dengan pohon widget baru.
class LakunaRoot extends StatefulWidget {
  const LakunaRoot({
    super.key,
    this.resolvePath = resolveDatabasePath,
    this.boot = bootstrap,
  });

  final Future<String> Function() resolvePath;
  final Future<AppInstance> Function(String databasePath) boot;

  @override
  State<LakunaRoot> createState() => _LakunaRootState();
}

class _LakunaRootState extends State<LakunaRoot> {
  AppInstance? _instance;
  Object? _error;
  String? _path;
  var _generation = 0;
  var _restoreFailed = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final path = _path ??= await widget.resolvePath();
      final dataDir = p.dirname(path);
      final kept = await applyPendingRestore(dataDir);
      AppInstance instance;
      var restoreFailed = false;
      try {
        instance = await widget.boot(path);
      } catch (e, st) {
        // Backup yang baru dipasang gagal dibuka: kembalikan data lama.
        if (kept == null) rethrow;
        debugPrint('Backup gagal dibuka, data lama dikembalikan: $e\n$st');
        await undoRestore(dataDir, kept);
        instance = await widget.boot(path);
        restoreFailed = true;
      }
      if (!mounted) return;
      setState(() {
        _instance = instance;
        _error = null;
        _restoreFailed = restoreFailed;
        _generation++;
      });
    } catch (e, st) {
      debugPrint('Lakuna gagal mulai: $e\n$st');
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<void> _restart() async {
    final old = _instance;
    setState(() => _instance = null);
    try {
      // Tunggu pohon lama dilepas sebelum database ditutup.
      await WidgetsBinding.instance.endOfFrame;
      await old?.close();
    } catch (e, st) {
      debugPrint('Lakuna gagal menutup database: $e\n$st');
    } finally {
      await _start();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error case final error?) {
      return StartupErrorView(error: error, path: _path);
    }
    final instance = _instance;
    if (instance == null) {
      return const ColoredBox(color: Color(0xFFFFFFFF));
    }
    return AppRestart(
      restart: _restart,
      restoreFailed: _restoreFailed,
      child: KeyedSubtree(key: ValueKey(_generation), child: instance.app),
    );
  }
}

/// Layar saat database gagal dibuka: pesan galat dan lokasi data yang bisa
/// disalin, bukan aplikasi yang tertutup tanpa pesan.
class StartupErrorView extends StatelessWidget {
  const StartupErrorView({super.key, required this.error, this.path});

  final Object error;
  final String? path;

  @override
  Widget build(BuildContext context) {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final l10n = lookupAppLocalizations(
      AppLocalizations.supportedLocales.any(
            (l) => l.languageCode == locale.languageCode,
          )
          ? Locale(locale.languageCode)
          : const Locale('id'),
    );
    const ink = Color(0xFF18181B);
    const muted = Color(0xFF71717A);
    final details = [
      '$error',
      if (path != null) l10n.startupErrorPath(path!),
    ].join('\n\n');
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: const Color(0xFFFFFFFF),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  key: const ValueKey('startup-error'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Text(
                      l10n.startupErrorTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                    Text(
                      l10n.startupErrorBody,
                      style: const TextStyle(fontSize: 15, color: ink),
                    ),
                    Text(
                      details,
                      key: const ValueKey('startup-error-details'),
                      style: const TextStyle(fontSize: 13, color: muted),
                    ),
                    GestureDetector(
                      key: const ValueKey('startup-error-copy'),
                      onTap: () =>
                          Clipboard.setData(ClipboardData(text: details)),
                      child: Text(
                        l10n.startupErrorCopy,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0069A8),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
