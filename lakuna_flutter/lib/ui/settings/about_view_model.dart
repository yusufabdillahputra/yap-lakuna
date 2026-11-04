import 'package:flutter/foundation.dart';

import '../../utils/command.dart';
import '../../utils/result.dart';

/// Lisensi satu paket atau font; [texts] berisi satu teks per entri lisensi.
@immutable
class AboutLicense {
  const AboutLicense({required this.package, required this.texts});

  final String package;
  final List<String> texts;
}

/// View model Pengaturan › Tentang Lakuna (F1-22): daftar lisensi open
/// source dari [LicenseRegistry], dikelompokkan per paket.
class AboutViewModel extends ChangeNotifier {
  AboutViewModel({Stream<LicenseEntry> Function()? licenses})
    : _source = licenses ?? (() => LicenseRegistry.licenses) {
    load = Command0(_load)..addListener(notifyListeners);
  }

  final Stream<LicenseEntry> Function() _source;

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  late final Command0<void> load;

  List<AboutLicense> _licenses = const [];
  List<AboutLicense> get licenses => _licenses;

  Future<Result<void>> _load() async {
    final byPackage = <String, List<String>>{};
    try {
      await for (final entry in _source()) {
        final text = entry.paragraphs.map((p) => p.text).join('\n\n');
        for (final package in entry.packages) {
          (byPackage[package] ??= []).add(text);
        }
      }
    } on Exception catch (e) {
      return Result.error(e);
    }
    final names = byPackage.keys.toList()
      ..sort((a, b) {
        final c = a.toLowerCase().compareTo(b.toLowerCase());
        return c != 0 ? c : a.compareTo(b);
      });
    _licenses = [
      for (final name in names)
        AboutLicense(package: name, texts: List.unmodifiable(byPackage[name]!)),
    ];
    return const Result.ok(null);
  }
}
