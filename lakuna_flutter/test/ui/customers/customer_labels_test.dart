import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_flutter/l10n/gen/app_localizations.dart';
import 'package:lakuna_flutter/ui/customers/customer_labels.dart';
import 'package:lakuna_flutter/ui/customers/customer_panel_view_model.dart';

void main() {
  final id = lookupAppLocalizations(const Locale('id'));
  final en = lookupAppLocalizations(const Locale('en'));

  test('galat rekening tujuan terima piutang (F1-13i)', () {
    expect(
      customerErrorMessage(id, const DebtTransferAccountMissing()),
      'Pilih rekening tujuan transfer.',
    );
    expect(
      customerErrorMessage(id, SaleTransferAccountInvalid()),
      'Rekening tujuan maksimal 100 karakter. Rapikan rekening di '
      'Pengaturan toko.',
    );
    expect(
      customerErrorMessage(en, SaleTransferAccountInvalid()),
      startsWith('The destination account can be up to 100 characters.'),
    );
  });
}
