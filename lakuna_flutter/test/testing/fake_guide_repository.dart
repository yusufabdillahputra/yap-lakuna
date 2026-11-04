import 'package:lakuna_flutter/data/repositories/guide_repository.dart';
import 'package:lakuna_flutter/data/services/guide_markdown.dart';
import 'package:lakuna_flutter/utils/result.dart';

/// Panduan kecil untuk tes view model dan widget.
class FakeGuideRepository implements GuideRepository {
  FakeGuideRepository({Map<String, String>? id, Map<String, String>? en})
    : _id = id ?? sampleGuideId,
      _en = en ?? sampleGuideEn;

  final Map<String, String> _id;
  final Map<String, String> _en;
  Exception? tocError;

  static const sections = [
    GuideSection(
      id: 'start',
      titles: {GuideLanguage.id: 'Mulai', GuideLanguage.en: 'Getting started'},
      slugs: ['install-owner', 'first-product'],
    ),
    GuideSection(
      id: 'cashier',
      titles: {GuideLanguage.id: 'Kasir', GuideLanguage.en: 'Cashier'},
      slugs: ['pay-qris'],
    ),
  ];

  @override
  Future<Result<List<GuideSection>>> toc() async =>
      tocError == null ? const Result.ok(sections) : Result.error(tocError!);

  @override
  Future<Result<GuideDocument>> article(
    GuideLanguage language,
    String slug,
  ) async {
    final text = (language == GuideLanguage.en ? _en[slug] : null) ?? _id[slug];
    if (text == null) return Result.error(Exception('tidak ada $slug'));
    return Result.ok(parseGuideMarkdown(text));
  }
}

const sampleGuideId = {
  'install-owner':
      '# Instalasi & akun pemilik\n\nPasang aplikasi lalu buat akun pemilik.',
  'first-product':
      '# Menambah produk pertama\n\n## Langkah\n\n1. Buka **Produk**.\n'
      '2. Tekan *Tambah produk*.\n\n> [!note] Lihat juga '
      '[QRIS statis](pay-qris).',
  'pay-qris':
      '# Menerima QRIS statis\n\nKasir mengonfirmasi setelah dana masuk.\n\n'
      '> [!warning] Pastikan dana benar-benar masuk.\n\n'
      '![Layar bayar QRIS](pay-qris)',
};

const sampleGuideEn = {
  'install-owner':
      '# Installation & owner account\n\nInstall the app, then create the '
      'owner account.',
  'first-product': '# Adding your first product\n\n1. Open **Products**.',
  'pay-qris':
      '# Accepting static QRIS\n\nThe cashier confirms once the money '
      'arrives.',
};
