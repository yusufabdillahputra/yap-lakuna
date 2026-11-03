import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/ui/master/master_data_view_model.dart';

import '../../testing/fake_master_data_repository.dart';
import '../../testing/fake_stock_repository.dart' show fakeId;

void main() {
  late FakeMasterDataRepository repo;
  late MasterDataViewModel vm;

  setUp(() async {
    repo = FakeMasterDataRepository();
    vm = MasterDataViewModel(repository: repo);
    await vm.load.execute();
  });

  List<String> names() => [for (final r in vm.categories) r.category.name];

  test('memuat kategori, satuan, dan lokasi', () {
    expect(vm.tab, MasterTab.categories);
    expect(names(), ['Sembako', 'Minuman', 'Kopi', 'Rokok']);
    expect(vm.units.map((u) => u.unit.name), ['botol', 'dus', 'pcs']);
    expect(vm.locations.map((l) => l.name), ['Etalase', 'Gudang']);
    expect(vm.editing, isFalse);
    // Induk hanya kategori utama.
    expect(vm.parentOptions.map((c) => c.name), [
      'Sembako',
      'Minuman',
      'Rokok',
    ]);
  });

  test('tambah kategori: galat per field lalu tersimpan', () async {
    vm.setName('sembako');
    await vm.saveCategory.execute();
    expect(vm.formErrors, [CategoryError.nameDuplicate]);
    expect(names(), hasLength(4));

    final rev = vm.formRevision;
    vm
      ..setName('Teh')
      ..setParent(fakeId(302).uuid)
      ..setColor(categoryColors[3])
      ..setShowInCashier(false);
    expect(vm.formErrors, isEmpty);
    await vm.saveCategory.execute();
    expect(vm.formErrors, isEmpty);
    expect(vm.savedName, 'Teh');
    final teh = vm.categories.last;
    expect(teh.category.name, 'Teh');
    expect(teh.parentName, 'Minuman');
    expect(teh.category.color, categoryColors[3]);
    expect(teh.category.showInCashier, isFalse);
    // Form kembali kosong untuk kategori baru.
    expect(vm.formRevision, greaterThan(rev));
    expect(vm.name, '');
    expect(vm.parentId, isNull);
    expect(vm.showInCashier, isTrue);
  });

  test('ubah kategori: isi form, induk tanpa dirinya, simpan', () async {
    final minuman = vm.categories[1];
    vm.edit(minuman);
    expect(vm.editing, isTrue);
    expect(vm.name, 'Minuman');
    // Minuman punya subkategori: tidak bisa diberi induk.
    expect(vm.parentOptions, isEmpty);

    final kopi = vm.categories[2];
    vm.edit(kopi);
    expect(vm.parentId, fakeId(302).uuid);
    expect(vm.color, categoryColors.first);
    expect(vm.parentOptions.map((c) => c.name), [
      'Sembako',
      'Minuman',
      'Rokok',
    ]);
    vm
      ..setName('Kopi susu')
      ..setParent(null)
      ..setColor(null)
      ..setActive(false);
    await vm.saveCategory.execute();
    final row = vm.categories.firstWhere(
      (r) => r.category.id == kopi.category.id,
    );
    expect(row.category.name, 'Kopi susu');
    expect(row.category.parentId, isNull);
    expect(row.category.color, isNull);
    expect(row.category.isActive, isFalse);
    expect(vm.editing, isFalse);
  });

  test('naik/turun dan saklar aktif', () async {
    await vm.move.execute((vm.categories[2].category.id, -1));
    expect(names(), ['Sembako', 'Kopi', 'Minuman', 'Rokok']);
    await vm.toggleActive.execute((vm.categories[3].category.id, true));
    expect(vm.categories[3].category.isActive, isTrue);
  });

  test('hapus: ditolak bila dipakai, berhasil bila tidak', () async {
    vm.edit(vm.categories[0]);
    await vm.deleteCategory.execute();
    expect(vm.categoryError, isA<MasterInUse>());
    expect(names(), hasLength(4));

    vm.edit(vm.categories[3]); // Rokok, 0 produk.
    expect(vm.categoryError, isNull);
    await vm.deleteCategory.execute();
    expect(names(), ['Sembako', 'Minuman', 'Kopi']);
    expect(vm.editing, isFalse);
  });

  test('satuan: tambah, ganti nama, hapus, galat', () async {
    expect(await vm.addUnit('PCS'), isFalse);
    expect(vm.unitError, UnitNameError.duplicate);
    expect(await vm.addUnit('kg'), isTrue);
    expect(vm.unitError, isNull);
    expect(vm.units.map((u) => u.unit.name), ['botol', 'dus', 'kg', 'pcs']);

    final dus = vm.units[1].unit;
    expect(await vm.renameUnit(dus.id, 'Dus'), isTrue);
    expect(vm.units[1].unit.name, 'Dus');

    final pcs = vm.units.last.unit;
    expect(await vm.deleteUnit(pcs.id), isFalse);
    expect(vm.unitInUse?.products, 2);
    expect(await vm.deleteUnit(dus.id), isTrue);
    expect(vm.unitInUse, isNull);
    expect(vm.units.map((u) => u.unit.name), ['botol', 'kg', 'pcs']);
  });

  test('tanpa izin: galat muat', () async {
    repo.permitted = false;
    final other = MasterDataViewModel(repository: repo);
    await other.load.execute();
    expect(other.load.error, isTrue);
  });
}
