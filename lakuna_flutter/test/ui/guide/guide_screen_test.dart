import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_guide_repository.dart';
import '../../testing/fake_session_repository.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

String? _text(WidgetTester tester, String key) =>
    tester.widget<Text>(_key(key)).data;

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key).last);
  await tester.pumpAndSettle();
  await tester.tap(_key(key).last);
  await tester.pumpAndSettle();
}

Future<void> _search(WidgetTester tester, String text) async {
  await tester.enterText(
    find.descendant(
      of: _key('guide-search'),
      matching: find.byType(EditableText),
    ),
    text,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Panduan 1.27 di 1440 px: daftar isi, artikel, EN, cari', (
    tester,
  ) async {
    await pumpLakuna(
      tester,
      size: const Size(1440, 900),
      initialLocation: Routes.guide,
    );
    expect(_key('guide-offline'), findsOneWidget);
    expect(_key('guide-toc-install-owner'), findsOneWidget);
    expect(_key('guide-toc-pay-qris'), findsOneWidget);
    expect(_text(tester, 'guide-article-title'), 'Instalasi & akun pemilik');
    expect(
      _text(tester, 'guide-breadcrumb'),
      'Mulai › Instalasi & akun pemilik',
    );
    expect(_key('guide-prev'), findsNothing);

    await _tap(tester, 'guide-next');
    expect(_text(tester, 'guide-article-title'), 'Menambah produk pertama');
    expect(_key('guide-callout-note'), findsOneWidget);

    await _tap(tester, 'guide-toc-pay-qris');
    expect(_text(tester, 'guide-breadcrumb'), 'Kasir › Menerima QRIS statis');
    expect(_key('guide-callout-warning'), findsOneWidget);
    // Gambar yang belum ada tidak menggagalkan artikel.
    expect(tester.takeException(), isNull);

    await _tap(tester, 'guide-lang-en');
    expect(_text(tester, 'guide-article-title'), 'Accepting static QRIS');
    expect(
      _text(tester, 'guide-breadcrumb'),
      'Cashier › Accepting static QRIS',
    );

    await _search(tester, 'owner');
    expect(_key('guide-result-install-owner'), findsOneWidget);
    expect(_key('guide-toc-pay-qris'), findsNothing);
    await _tap(tester, 'guide-result-install-owner');
    expect(
      _text(tester, 'guide-article-title'),
      'Installation & owner account',
    );

    await _search(tester, 'zzz');
    expect(_key('guide-no-results'), findsOneWidget);
    await _search(tester, '');
    expect(_key('guide-toc-pay-qris'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Panduan di 360 px: daftar isi lalu artikel', (tester) async {
    await pumpLakuna(
      tester,
      size: const Size(360, 740),
      initialLocation: Routes.guide,
    );
    expect(_key('guide-toc-first-product'), findsOneWidget);
    expect(_key('guide-article'), findsNothing);
    await _tap(tester, 'guide-toc-first-product');
    expect(_text(tester, 'guide-article-title'), 'Menambah produk pertama');
    // Tautan di dalam teks membuka artikel lain.
    await tester.ensureVisible(_key('guide-callout-note'));
    await tester.pumpAndSettle();
    await tester.tapOnText(find.textRange.ofSubstring('QRIS statis').first);
    await tester.pumpAndSettle();
    expect(_text(tester, 'guide-article-title'), 'Menerima QRIS statis');
    await _tap(tester, 'guide-back');
    expect(_key('guide-article'), findsNothing);
    expect(_key('guide-toc-pay-qris'), findsOneWidget);

    // Cari di HP: hasil, buka artikel, kembali ke hasil.
    await _search(tester, 'pemilik');
    await _tap(tester, 'guide-result-install-owner');
    expect(_text(tester, 'guide-article-title'), 'Instalasi & akun pemilik');
    await _tap(tester, 'guide-back');
    expect(_key('guide-result-install-owner'), findsOneWidget);
    // Mengetik lagi saat artikel terbuka menampilkan hasil.
    await _tap(tester, 'guide-result-install-owner');
    await _search(tester, 'qris');
    expect(_key('guide-article'), findsNothing);
    expect(_key('guide-result-pay-qris'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('teks cari tetap ada saat lebar layar melewati 900 px', (
    tester,
  ) async {
    await pumpLakuna(
      tester,
      size: const Size(1440, 900),
      initialLocation: Routes.guide,
    );
    await _search(tester, 'qris');
    tester.view.physicalSize = const Size(800, 900);
    await tester.pumpAndSettle();
    final field = tester.widget<EditableText>(
      find.descendant(
        of: _key('guide-search'),
        matching: find.byType(EditableText),
      ),
    );
    expect(field.controller.text, 'qris');
    expect(_key('guide-result-pay-qris'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tautan kontekstual membuka artikel; kasir pun boleh', (
    tester,
  ) async {
    await pumpLakuna(
      tester,
      size: const Size(360, 740),
      initialLocation: Routes.guideArticle('pay-qris'),
      session: FakeSessionRepository(
        current: sampleStaff(name: 'Dimas', role: 'cashier'),
      ),
    );
    expect(_text(tester, 'guide-article-title'), 'Menerima QRIS statis');
  });

  testWidgets('daftar isi gagal dimuat: galat dengan coba lagi', (
    tester,
  ) async {
    final guide = FakeGuideRepository()..tocError = Exception('rusak');
    await pumpLakuna(
      tester,
      size: const Size(1440, 900),
      initialLocation: Routes.guide,
      guide: guide,
    );
    expect(_key('guide-load-error'), findsOneWidget);
    guide.tocError = null;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(_key('guide-toc-pay-qris'), findsOneWidget);
  });

  testWidgets('menu Panduan membuka layar Panduan', (tester) async {
    await pumpLakuna(tester, size: const Size(1440, 1400));
    await _tap(tester, 'nav-guide');
    expect(_key('guide-screen'), findsOneWidget);
  });
}
