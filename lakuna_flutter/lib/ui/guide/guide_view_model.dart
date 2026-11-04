import 'package:flutter/foundation.dart';

import '../../data/repositories/guide_repository.dart';
import '../../data/services/guide_markdown.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// View model Panduan (1.27, F1-21): daftar isi, artikel aktif, bahasa,
/// pencarian, dan urutan sebelumnya/berikutnya.
class GuideViewModel extends ChangeNotifier {
  GuideViewModel({
    required this._repository,
    required this._language,
    String? initialSlug,
  }) : _slug = initialSlug {
    load = Command0(_load)..addListener(notifyListeners);
    setLanguage = Command1(_setLanguage)..addListener(notifyListeners);
  }

  final GuideRepository _repository;

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
  late final Command1<void, GuideLanguage> setLanguage;

  GuideLanguage _language;
  GuideLanguage get language => _language;

  List<GuideSection> _sections = const [];
  List<GuideSection> get sections => _sections;

  /// Artikel bahasa aktif per slug.
  Map<String, GuideDocument> _docs = const {};

  String? _slug;
  String? get slug => _slug;
  GuideDocument? get article => _docs[_slug];

  String? _query;
  List<String>? _results;

  /// Slug hasil pencarian (judul cocok lebih dulu); `null` bila tidak
  /// sedang mencari.
  List<String>? get results => _results;
  String get query => _query ?? '';

  List<String> get _order => [for (final s in _sections) ...s.slugs];

  String titleOf(String slug) => _docs[slug]?.title ?? slug;

  GuideSection? sectionOf(String slug) {
    for (final s in _sections) {
      if (s.slugs.contains(slug)) return s;
    }
    return null;
  }

  String? get sectionTitle => switch (_slug) {
    final slug? => sectionOf(slug)?.title(_language),
    null => null,
  };

  String? get previous {
    final order = _order;
    final i = order.indexOf(_slug ?? '');
    return i > 0 ? order[i - 1] : null;
  }

  String? get next {
    final order = _order;
    final i = order.indexOf(_slug ?? '');
    return i >= 0 && i < order.length - 1 ? order[i + 1] : null;
  }

  /// Membuka artikel [slug] (diabaikan bila tidak ada di daftar isi).
  void open(String slug) {
    if (!_order.contains(slug)) return;
    _slug = slug;
    notifyListeners();
  }

  void search(String query) {
    final q = query.trim().toLowerCase();
    _query = query;
    if (q.isEmpty) {
      _results = null;
    } else {
      final byTitle = <String>[];
      final byBody = <String>[];
      for (final slug in _order) {
        final doc = _docs[slug];
        if (doc == null) continue;
        if (doc.title.toLowerCase().contains(q)) {
          byTitle.add(slug);
        } else if (doc.plainText.toLowerCase().contains(q)) {
          byBody.add(slug);
        }
      }
      _results = [...byTitle, ...byBody];
    }
    notifyListeners();
  }

  /// Memuat semua artikel [language] (kecil; dibutuhkan untuk judul daftar
  /// isi dan pencarian). Artikel yang gagal dimuat dilewati.
  Future<Map<String, GuideDocument>> _loadDocs(GuideLanguage language) async {
    final entries = await Future.wait([
      for (final slug in _order)
        _repository.article(language, slug).then((r) => (slug, r)),
    ]);
    return {
      for (final (slug, r) in entries)
        if (r case Ok(:final value)) slug: value,
    };
  }

  Future<Result<void>> _load() async {
    switch (await _repository.toc()) {
      case Error(:final error):
        return Result.error(error);
      case Ok(:final value):
        _sections = value;
    }
    _docs = await _loadDocs(_language);
    if (!_order.contains(_slug)) {
      _slug = _order.isEmpty ? null : _order.first;
    }
    // Pencarian yang diketik sebelum artikel selesai dimuat.
    if (_query case final q?) search(q);
    return const Result.ok(null);
  }

  Future<Result<void>> _setLanguage(GuideLanguage language) async {
    if (load.running || (language == _language && _docs.isNotEmpty)) {
      return const Result.ok(null);
    }
    _docs = await _loadDocs(language);
    _language = language;
    if (_query case final q?) search(q);
    return const Result.ok(null);
  }
}
