import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_flutter/data/repositories/repository_errors.dart';
import 'package:lakuna_flutter/ui/master/dining_setup_view_model.dart';

import '../../testing/fake_dining_admin_repository.dart';

void main() {
  late FakeDiningAdminRepository repo;
  late DiningSetupViewModel vm;

  setUp(() async {
    repo = FakeDiningAdminRepository();
    vm = DiningSetupViewModel(repository: repo);
    await vm.load.execute();
  });

  test('memuat area dan meja dengan nama area', () {
    expect(vm.areas.map((a) => a.name), ['Indoor', 'Teras']);
    expect(vm.tables.map((t) => t.name), ['M1', 'M2', 'T1']);
    expect(vm.areaName(vm.tables.last.diningAreaId), 'Teras');
    expect(vm.areaName(null), isNull);
  });

  test('area: tambah, kembar ditolak, ganti nama, urutkan, hapus', () async {
    await vm.addArea.execute('indoor');
    expect(vm.error, isA<DiningNameInvalid>());
    await vm.addArea.execute('Lantai 2');
    expect(vm.error, isNull);
    expect(vm.areas.map((a) => a.name), ['Indoor', 'Teras', 'Lantai 2']);

    final lantai = vm.areas.last;
    await vm.renameArea.execute((lantai.id, 'Rooftop'));
    await vm.moveArea.execute((vm.areas.last.id, -1));
    expect(vm.areas.map((a) => a.name), ['Indoor', 'Rooftop', 'Teras']);

    await vm.deleteArea.execute(vm.areas.first.id);
    expect(vm.error, isA<DiningInUse>());
    await vm.deleteArea.execute(lantai.id);
    expect(vm.areas.map((a) => a.name), ['Indoor', 'Teras']);
  });

  test('meja: tambah, ubah, kursi tidak sah, hapus meja terisi', () async {
    final teras = vm.areas.last.id;
    await vm.saveTable.execute((
      null,
      DiningTableDraft(name: 'T2', areaId: teras, seats: 6),
    ));
    expect(vm.tables.last.name, 'T2');
    await vm.saveTable.execute((
      vm.tables.last.id,
      DiningTableDraft(name: 'T2', areaId: teras, seats: 0),
    ));
    expect(vm.error, isA<DiningSeatsInvalid>());
    await vm.saveTable.execute((
      vm.tables.last.id,
      const DiningTableDraft(name: 'VIP', seats: 8),
    ));
    expect(vm.tables.last.name, 'VIP');
    expect(vm.areaName(vm.tables.last.diningAreaId), isNull);

    repo.busyTables.add(vm.tables.first.id);
    await vm.deleteTable.execute(vm.tables.first.id);
    expect(vm.error, isA<DiningInUse>());
    await vm.moveTable.execute((vm.tables.last.id, -1));
    expect(vm.tables.map((t) => t.name), ['M1', 'M2', 'VIP', 'T1']);
  });

  test('tambah beberapa: pratinjau, kembar ditolak semua', () async {
    expect(DiningSetupViewModel.rangePreview('M', 3, 5), ['M3', 'M4', 'M5']);
    expect(DiningSetupViewModel.rangePreview('M', 5, 3), isNull);
    await vm.addRange.execute(
      const TableRange(prefix: 'M', from: 2, to: 4, seats: 2),
    );
    expect(vm.error, isA<DiningNameInvalid>());
    expect(vm.tables, hasLength(3));
    await vm.addRange.execute(
      const TableRange(prefix: 'M', from: 3, to: 6, seats: 2),
    );
    expect(vm.tables.map((t) => t.name), [
      'M1',
      'M2',
      'T1',
      'M3',
      'M4',
      'M5',
      'M6',
    ]);
    await vm.addRange.execute(
      const TableRange(prefix: 'X', from: 1, to: 60, seats: 2),
    );
    expect(vm.error, isA<DiningRangeInvalid>());
  });

  test('tanpa izin settings:manage', () async {
    repo.permitted = false;
    final denied = DiningSetupViewModel(repository: repo);
    await denied.load.execute();
    expect(denied.load.error, isTrue);
    expect(denied.loadError, isA<NotPermitted>());
  });
}
