import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/data/repositories/guide_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

class _Bundle extends CachingAssetBundle {
  _Bundle(this.files);

  final Map<String, String> files;
  final loads = <String>[];

  @override
  Future<ByteData> load(String key) async {
    loads.add(key);
    final text = files[key];
    if (text == null) throw FlutterError('tidak ada $key');
    return ByteData.sublistView(utf8.encode(text));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final data = await load(key);
    return utf8.decode(data.buffer.asUint8List());
  }
}

T _ok<T>(Result<T> r) => switch (r) {
  Ok(:final value) => value,
  Error(:final error) => throw error,
};

void main() {
  final toc = jsonEncode({
    'sections': [
      {
        'id': 'start',
        'title': {'id': 'Mulai', 'en': 'Getting started'},
        'articles': ['a', 'b'],
      },
    ],
  });

  test('daftar isi dan artikel per bahasa, dengan cadangan ID', () async {
    final bundle = _Bundle({
      'assets/guide/toc.json': toc,
      'assets/guide/id/a.md': '# Artikel A\n\nIsi.',
      'assets/guide/en/a.md': '# Article A\n\nBody.',
      'assets/guide/id/b.md': '# Artikel B',
    });
    final repo = AssetGuideRepository(bundle: bundle);
    final sections = _ok(await repo.toc());
    expect(sections.single.title(GuideLanguage.en), 'Getting started');
    expect(sections.single.slugs, ['a', 'b']);
    expect(_ok(await repo.article(GuideLanguage.en, 'a')).title, 'Article A');
    // Belum diterjemahkan: jatuh ke Bahasa Indonesia.
    expect(_ok(await repo.article(GuideLanguage.en, 'b')).title, 'Artikel B');
    // Disimpan di memori.
    final before = bundle.loads.length;
    await repo.article(GuideLanguage.en, 'a');
    await repo.toc();
    expect(bundle.loads.length, before);
  });

  test('artikel tidak ada atau rusak menjadi galat', () async {
    final repo = AssetGuideRepository(
      bundle: _Bundle({
        'assets/guide/toc.json': '{"sections": 1}',
        'assets/guide/id/rusak.md': 'tanpa judul',
      }),
    );
    expect(await repo.toc(), isA<Error<List<GuideSection>>>());
    expect(await repo.article(GuideLanguage.id, 'x'), isA<Error<Object>>());
    expect(
      await repo.article(GuideLanguage.id, 'rusak'),
      isA<Error<Object>>(),
    );
  });

  test('bahasa dari kode bahasa aplikasi', () {
    expect(GuideLanguage.of('en'), GuideLanguage.en);
    expect(GuideLanguage.of('id'), GuideLanguage.id);
    expect(GuideLanguage.of('jv'), GuideLanguage.id);
  });
}
