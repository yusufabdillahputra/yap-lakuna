import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/ui/settings/fnb_rates_view_model.dart';

import '../../testing/fake_dining_admin_repository.dart';

void main() {
  test('parsePercentBp', () {
    expect(parsePercentBp('5'), 500);
    expect(parsePercentBp('5,5'), 550);
    expect(parsePercentBp('10.5'), 1050);
    expect(parsePercentBp(' 0 '), 0);
    expect(parsePercentBp(''), 0);
    expect(parsePercentBp('12,25'), 1225);
    expect(parsePercentBp('abc'), isNull);
    expect(parsePercentBp('5,555'), isNull);
    expect(percentInput(1050, decimal: ','), '10,5');
    expect(percentInput(500, decimal: ','), '5');
  });

  test('muat, ubah, validasi langkah 0,5 dan batas, simpan', () async {
    final repo = FakeDiningAdminRepository()
      ..savedRates = const FnbRates(
        service: BasisPoints(500),
        tax: BasisPoints(1000),
      );
    final vm = FnbRatesViewModel(repository: repo);
    await vm.load.execute();
    expect(vm.service, const BasisPoints(500));
    expect(vm.tax, const BasisPoints(1000));
    expect(vm.preview.total, const Money(115500));

    vm.setService('5,25');
    expect(vm.serviceInvalid, isTrue);
    vm.setService('35');
    expect(vm.serviceInvalid, isTrue);
    vm.setService('7,5');
    vm.setTax('25');
    expect(vm.taxInvalid, isTrue);
    expect(vm.canSave, isFalse);
    vm.setTax('11');
    expect(vm.canSave, isTrue);
    expect(vm.dirty, isTrue);
    // 100.000 + service 7.500 + PB1 11% x 107.500 = 11.825.
    expect(vm.preview.tax, const Money(11825));

    await vm.save.execute();
    expect(repo.savedRates.service, const BasisPoints(750));
    expect(repo.savedRates.tax, const BasisPoints(1100));
    expect(vm.dirty, isFalse);
    expect(vm.saved, isTrue);
  });
}
