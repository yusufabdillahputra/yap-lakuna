import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/repository_errors.dart';
import 'package:lakuna_flutter/ui/master/modifier_groups_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/fake_master_data_repository.dart';

ModifierGroupDraft _draft(String name, {int min = 1, int max = 1}) =>
    ModifierGroupDraft(
      name: name,
      minSelect: min,
      maxSelect: max,
      options: const [
        ModifierOptionDraft(name: 'Sedang'),
        ModifierOptionDraft(name: 'Pedas', priceDelta: Money(1000)),
      ],
    );

void main() {
  late FakeMasterDataRepository repo;
  late ModifierGroupsViewModel vm;

  setUp(() async {
    repo = FakeMasterDataRepository();
    vm = ModifierGroupsViewModel(repository: repo);
    await vm.load.execute();
  });

  test('memuat grup berurutan dengan opsi dan jumlah menu', () {
    expect(vm.loaded, isTrue);
    expect(vm.groups.map((g) => g.name), ['Ukuran', 'Topping']);
    expect(vm.groups.first.productCount, 1);
    expect(vm.groups.last.options.map((o) => o.name), ['Boba', 'Keju']);
  });

  test('simpan baru, kembar ditolak tanpa spanduk, ubah', () async {
    await vm.save.execute((null, _draft('ukuran')));
    expect(vm.save.result, isA<Error<void>>());
    final error = (vm.save.result! as Error<void>).error;
    expect(
      (error as ModifierGroupInvalid).errors,
      contains(ModifierGroupError.nameDuplicate),
    );
    expect(vm.error, isNull, reason: 'galat simpan tampil di form');

    await vm.save.execute((null, _draft('Level pedas')));
    expect(vm.save.result, isA<Ok<void>>());
    expect(vm.groups.map((g) => g.name), ['Ukuran', 'Topping', 'Level pedas']);

    final level = vm.groups.last;
    await vm.save.execute((level.id, _draft('Level', min: 0, max: 2)));
    expect(vm.groups.last.name, 'Level');
    expect(vm.groups.last.isRequired, isFalse);
  });

  test('urutkan dan hapus; grup dipakai menu ditolak', () async {
    await vm.move.execute((vm.groups.last.id, -1));
    expect(vm.groups.map((g) => g.name), ['Topping', 'Ukuran']);

    await vm.delete.execute(vm.groups.last.id);
    expect(vm.error, isA<MasterInUse>());
    expect((vm.error! as MasterInUse).products, 1);

    vm.clearError();
    await vm.delete.execute(vm.groups.first.id);
    expect(vm.error, isNull);
    expect(vm.groups.map((g) => g.name), ['Ukuran']);
  });

  test('tanpa izin: muat gagal', () async {
    repo.permitted = false;
    final other = ModifierGroupsViewModel(repository: repo);
    await other.load.execute();
    expect(other.loaded, isFalse);
    expect(other.load.result, isA<Error<List<ModifierGroupDetail>>>());
    expect((other.load.result! as Error).error, isA<NotPermitted>());
  });
}
