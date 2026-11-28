import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart'
    show HostingAlreadyActive, HostingNotActive;
import 'package:lakuna_flutter/l10n/gen/app_localizations.dart';
import 'package:lakuna_flutter/ui/hosting/hosting_texts.dart';

void main() {
  for (final locale in const [Locale('id'), Locale('en')]) {
    test('galat aktif/belum aktif punya teks sendiri ($locale)', () {
      final l10n = lookupAppLocalizations(locale);
      for (final e in const [HostingNotActive(), HostingAlreadyActive()]) {
        final text = hostingErrorText(l10n, e);
        expect(text, isNot(contains('Instance of')));
        expect(text, isNot(l10n.hostingErrorGeneric('$e')));
      }
    });
  }
}
