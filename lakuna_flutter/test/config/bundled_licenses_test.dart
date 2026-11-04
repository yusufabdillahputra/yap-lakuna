import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/config/bundled_licenses.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('lisensi font dan Bootstrap Icons terdaftar', () async {
    registerBundledLicenses();
    final texts = <String, String>{};
    await for (final entry in LicenseRegistry.licenses) {
      for (final p in entry.packages) {
        if (bundledLicenseAssets.containsKey(p)) {
          texts[p] = entry.paragraphs.map((x) => x.text).join('\n');
        }
      }
    }
    expect(
      texts.keys,
      unorderedEquals(['Montserrat', 'DM Sans', 'DM Mono', 'Bootstrap Icons']),
    );
    for (final font in ['Montserrat', 'DM Sans', 'DM Mono']) {
      expect(texts[font], contains('SIL OPEN FONT LICENSE'));
    }
    expect(texts['Bootstrap Icons'], contains('The Bootstrap Authors'));
  });
}
