import 'package:flutter/foundation.dart';

import '../../utils/command.dart';
import '../../utils/result.dart';

/// Lisensi satu paket atau font beserta entri [LicenseEntry]-nya.
///
/// Paragraf baru diurai lewat [paragraphs] saat lisensi dibuka, karena teks
/// lisensi Flutter sangat panjang.
@immutable
class AboutLicense {
  const AboutLicense({required this.package, required this.entries});

  final String package;
  final List<LicenseEntry> entries;

  int get count => entries.length;

  /// Semua paragraf semua entri; `null` memisahkan entri.
  List<LicenseParagraph?> paragraphs() => [
    for (final (i, entry) in entries.indexed) ...[
      if (i > 0) null,
      ...entry.paragraphs,
    ],
  ];
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
    final byPackage = <String, List<LicenseEntry>>{};
    try {
      await for (final entry in _source()) {
        for (final package in entry.packages) {
          (byPackage[package] ??= []).add(entry);
        }
      }
    } catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
    final names = byPackage.keys.toList()
      ..sort((a, b) {
        final c = a.toLowerCase().compareTo(b.toLowerCase());
        return c != 0 ? c : a.compareTo(b);
      });
    _licenses = [
      for (final name in names)
        AboutLicense(
          package: name,
          entries: List.unmodifiable(byPackage[name]!),
        ),
    ];
    return const Result.ok(null);
  }
}
