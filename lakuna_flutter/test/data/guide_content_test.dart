import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/data/repositories/guide_repository.dart';
import 'package:lakuna_flutter/data/services/guide_markdown.dart';
import 'package:lakuna_flutter/utils/result.dart';

/// Konten Panduan sungguhan (assets/guide): lengkap ID + EN, tautan dan
/// gambar tidak putus, tanpa berkas yatim.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('daftar isi dan artikel lengkap di kedua bahasa', () async {
    final repo = AssetGuideRepository();
    final sections = switch (await repo.toc()) {
      Ok(:final value) => value,
      Error(:final error) => throw error,
    };
    final slugs = [for (final s in sections) ...s.slugs];
    expect(slugs.toSet(), hasLength(slugs.length), reason: 'slug ganda');
    expect(slugs.length, greaterThanOrEqualTo(27));
    for (final s in sections) {
      for (final lang in GuideLanguage.values) {
        expect(s.titles[lang], isNotNull, reason: '${s.id} ${lang.name}');
      }
    }

    final used = <String>{};
    for (final lang in GuideLanguage.values) {
      for (final slug in slugs) {
        final path = GuideAssets.article(lang, slug);
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: path);
        // Diurai langsung (bukan lewat cadangan ID) agar galat jelas.
        final GuideDocument doc;
        try {
          doc = parseGuideMarkdown(file.readAsStringSync());
        } on FormatException catch (e) {
          fail('$path: $e');
        }
        expect(doc.title, isNotEmpty, reason: path);
        expect(doc.blocks, isNotEmpty, reason: path);
        used.add(path);
        for (final link in doc.links) {
          expect(slugs, contains(link), reason: '$path → $link');
        }
        for (final image in doc.images) {
          final img = GuideAssets.image(lang, image);
          final bytes = File(img).readAsBytesSync();
          expect(
            String.fromCharCodes(bytes.sublist(0, 4)),
            'RIFF',
            reason: img,
          );
          expect(
            String.fromCharCodes(bytes.sublist(8, 12)),
            'WEBP',
            reason: img,
          );
          expect(bytes.length, lessThanOrEqualTo(150 * 1024), reason: img);
          used.add(img);
        }
      }
    }

    final onDisk = [
      for (final f in Directory(GuideAssets.root).listSync(recursive: true))
        if (f is File && !f.path.endsWith('toc.json')) f.path,
    ];
    expect(onDisk.where((p) => !used.contains(p)), isEmpty, reason: 'yatim');
  });

  test('aset Panduan didaftarkan di pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final dir in [
      'assets/guide/',
      'assets/guide/id/',
      'assets/guide/en/',
      'assets/guide/img/id/',
      'assets/guide/img/en/',
    ]) {
      expect(pubspec, contains('- $dir'), reason: dir);
    }
  });
}
