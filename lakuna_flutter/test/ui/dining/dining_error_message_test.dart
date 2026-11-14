import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_flutter/l10n/gen/app_localizations.dart';
import 'package:lakuna_flutter/ui/dining/dining_view.dart';

void main() {
  test('bagian dibayar di sesi lain punya pesan sendiri (F1-10i)', () {
    final id = lookupAppLocalizations(const Locale('id'));
    final en = lookupAppLocalizations(const Locale('en'));
    expect(
      diningErrorMessage(id, BillPaidInOtherSession()),
      id.diningErrorPaidOtherSession,
    );
    expect(
      diningErrorMessage(en, BillPaidInOtherSession()),
      en.diningErrorPaidOtherSession,
    );
  });
}
