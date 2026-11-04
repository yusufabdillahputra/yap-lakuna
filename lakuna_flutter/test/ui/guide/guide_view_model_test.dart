import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/data/repositories/guide_repository.dart';
import 'package:lakuna_flutter/ui/guide/guide_view_model.dart';

import '../../testing/fake_guide_repository.dart';

void main() {
  test('memuat daftar isi, judul, dan artikel pertama', () async {
    final vm = GuideViewModel(
      repository: FakeGuideRepository(),
      language: GuideLanguage.id,
    );
    await vm.load.execute();
    expect(vm.load.error, isFalse);
    expect(vm.sections.map((s) => s.id), ['start', 'cashier']);
    expect(vm.titleOf('pay-qris'), 'Menerima QRIS statis');
    expect(vm.slug, 'install-owner');
    expect(vm.article?.title, 'Instalasi & akun pemilik');
    expect(vm.sectionTitle, 'Mulai');
    expect(vm.previous, isNull);
    expect(vm.next, 'first-product');
  });

  test('artikel awal dari rute; slug tidak dikenal jatuh ke pertama', () async {
    final vm = GuideViewModel(
      repository: FakeGuideRepository(),
      language: GuideLanguage.id,
      initialSlug: 'pay-qris',
    );
    await vm.load.execute();
    expect(vm.article?.title, 'Menerima QRIS statis');
    expect(vm.previous, 'first-product');
    expect(vm.next, isNull);
    expect(vm.sectionTitle, 'Kasir');

    final unknown = GuideViewModel(
      repository: FakeGuideRepository(),
      language: GuideLanguage.id,
      initialSlug: 'tidak-ada',
    );
    await unknown.load.execute();
    expect(unknown.slug, 'install-owner');
  });

  test('buka artikel dan ganti bahasa', () async {
    final vm = GuideViewModel(
      repository: FakeGuideRepository(),
      language: GuideLanguage.id,
    );
    await vm.load.execute();
    vm.open('first-product');
    expect(vm.article?.title, 'Menambah produk pertama');
    vm.open('tidak-ada');
    expect(vm.slug, 'first-product');
    await vm.setLanguage.execute(GuideLanguage.en);
    expect(vm.language, GuideLanguage.en);
    expect(vm.article?.title, 'Adding your first product');
    expect(vm.sectionTitle, 'Getting started');
    expect(vm.titleOf('pay-qris'), 'Accepting static QRIS');
  });

  test('cari judul dan isi tanpa membedakan huruf besar', () async {
    final vm = GuideViewModel(
      repository: FakeGuideRepository(),
      language: GuideLanguage.id,
    );
    await vm.load.execute();
    expect(vm.results, isNull);
    vm.search('qris');
    expect(vm.results, ['pay-qris', 'first-product']);
    vm.search('  DANA  ');
    expect(vm.results, ['pay-qris']);
    vm.search('tidak ketemu');
    expect(vm.results, isEmpty);
    vm.search(' ');
    expect(vm.results, isNull);
  });

  test('daftar isi gagal dimuat', () async {
    final repo = FakeGuideRepository()..tocError = Exception('rusak');
    final vm = GuideViewModel(repository: repo, language: GuideLanguage.id);
    await vm.load.execute();
    expect(vm.load.error, isTrue);
    expect(vm.article, isNull);
  });

  test('pencarian sebelum artikel dimuat diulang setelah dimuat', () async {
    final vm = GuideViewModel(
      repository: FakeGuideRepository(),
      language: GuideLanguage.id,
    )..search('qris');
    expect(vm.results, isEmpty);
    await vm.load.execute();
    expect(vm.results, ['pay-qris', 'first-product']);
  });

  test('tidak memberi tahu pendengar setelah dibuang', () async {
    final vm = GuideViewModel(
      repository: FakeGuideRepository(),
      language: GuideLanguage.id,
    );
    final loading = vm.load.execute();
    vm.dispose();
    await loading;
  });

  test('ganti bahasa diabaikan selama daftar isi dimuat', () async {
    final vm = GuideViewModel(
      repository: FakeGuideRepository(),
      language: GuideLanguage.id,
    );
    final loading = vm.load.execute();
    await vm.setLanguage.execute(GuideLanguage.en);
    await loading;
    expect(vm.language, GuideLanguage.id);
    expect(vm.article?.title, 'Instalasi & akun pemilik');
  });
}
