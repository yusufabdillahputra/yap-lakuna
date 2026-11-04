import 'dart:convert';

import 'package:flutter/services.dart';

import '../../utils/result.dart';
import '../services/guide_markdown.dart';

/// Bahasa konten Panduan.
enum GuideLanguage {
  id,
  en;

  /// Bahasa panduan untuk kode bahasa aplikasi; selain `en` → Indonesia.
  static GuideLanguage of(String languageCode) =>
      languageCode == 'en' ? en : id;
}

/// Kelompok daftar isi Panduan.
final class GuideSection {
  const GuideSection({
    required this.id,
    required this.titles,
    required this.slugs,
  });

  final String id;
  final Map<GuideLanguage, String> titles;
  final List<String> slugs;

  String title(GuideLanguage language) =>
      titles[language] ?? titles[GuideLanguage.id] ?? id;
}

/// Konten Panduan (F1-21): daftar isi dan artikel per bahasa.
abstract interface class GuideRepository {
  Future<Result<List<GuideSection>>> toc();

  /// Artikel [slug]; artikel yang belum diterjemahkan jatuh ke Bahasa
  /// Indonesia.
  Future<Result<GuideDocument>> article(GuideLanguage language, String slug);
}

/// Jalur aset Panduan.
abstract final class GuideAssets {
  static const root = 'assets/guide';
  static const toc = '$root/toc.json';
  static String article(GuideLanguage language, String slug) =>
      '$root/${language.name}/$slug.md';
  static String image(GuideLanguage language, String name) =>
      '$root/img/${language.name}/$name.webp';
}

/// Panduan dari aset aplikasi (tersedia offline). Hasil urai disimpan di
/// memori.
class AssetGuideRepository implements GuideRepository {
  AssetGuideRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  List<GuideSection>? _toc;
  final _articles = <String, GuideDocument>{};

  @override
  Future<Result<List<GuideSection>>> toc() async {
    if (_toc case final toc?) return Result.ok(toc);
    try {
      final json = jsonDecode(await _bundle.loadString(GuideAssets.toc));
      final sections = [
        for (final s in (json as Map<String, dynamic>)['sections'] as List)
          GuideSection(
            id: s['id'] as String,
            titles: {
              for (final l in GuideLanguage.values)
                if ((s['title'] as Map)[l.name] case final String t) l: t,
            },
            slugs: [for (final a in s['articles'] as List) a as String],
          ),
      ];
      return Result.ok(_toc = sections);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Daftar isi Panduan rusak: $e'));
    }
  }

  @override
  Future<Result<GuideDocument>> article(
    GuideLanguage language,
    String slug,
  ) async {
    final key = '${language.name}/$slug';
    if (_articles[key] case final doc?) return Result.ok(doc);
    try {
      String text;
      try {
        text = await _bundle.loadString(GuideAssets.article(language, slug));
      } catch (_) {
        if (language == GuideLanguage.id) rethrow;
        text = await _bundle.loadString(
          GuideAssets.article(GuideLanguage.id, slug),
        );
      }
      return Result.ok(_articles[key] = parseGuideMarkdown(text));
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return Result.error(Exception('Artikel $slug tidak ada: $e'));
    }
  }
}
