import 'package:flutter/widgets.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_flutter/l10n/gen/app_localizations.dart';
import 'package:lakuna_flutter/ui/stock/stock_view.dart';

void main() {
  final id = lookupAppLocalizations(const Locale('id'));
  final en = lookupAppLocalizations(const Locale('en'));

  test('catatan gerak stok: penanda void diterjemahkan', () {
    expect(stockEntryNote(id, voidMovementNote), 'Nota di-void');
    expect(stockEntryNote(en, voidMovementNote), 'Sale voided');
    expect(stockEntryNote(id, 'Pecah'), 'Pecah');
    expect(stockEntryNote(id, ''), isNull);
    expect(stockEntryNote(id, null), isNull);
  });
}
