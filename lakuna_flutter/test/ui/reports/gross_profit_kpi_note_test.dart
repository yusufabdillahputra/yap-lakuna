import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/l10n/gen/app_localizations.dart';
import 'package:lakuna_flutter/ui/reports/report_labels.dart';

void main() {
  final id = lookupAppLocalizations(const Locale('id'));
  final en = lookupAppLocalizations(const Locale('en'));

  test('KPI laba kotor: tanpa target, tanpa penjualan, tercapai, kurang '
      '(F1-16e)', () {
    expect(grossProfitKpiNote(id, 2400, null), 'Dari harga pokok saat jual');
    expect(grossProfitKpiNote(id, null, 2500), 'Target toko 25%');
    expect(
      grossProfitKpiNote(id, 2400, 2500),
      'Margin 24,0% · Target toko 25% · kurang 1,0 poin',
    );
    expect(
      grossProfitKpiNote(en, 2180, 2500),
      'Margin 21.8% · Store target 25% · 3.2 points short',
    );
    expect(
      grossProfitKpiNote(en, 2600, 2500),
      'Margin 26.0% · Store target 25% · met',
    );
  });

  test('pembulatan sama dengan tampilan, dan margin negatif', () {
    // 24,96% tampil 25,0%: tercapai, bukan "kurang 0,0 poin".
    expect(
      grossProfitKpiNote(id, 2496, 2500),
      'Margin 25,0% · Target toko 25% · tercapai',
    );
    expect(
      grossProfitKpiNote(id, 2494, 2500),
      'Margin 24,9% · Target toko 25% · kurang 0,1 poin',
    );
    expect(
      grossProfitKpiNote(id, -500, 2500),
      'Margin -5,0% · Target toko 25% · kurang 30,0 poin',
    );
  });
}
