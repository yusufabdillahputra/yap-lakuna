import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/table_file.dart';
import 'package:lakuna_flutter/ui/customers/customer_import_view_model.dart'
    show ImportFileProblem;
import 'package:lakuna_flutter/ui/suppliers/supplier_import_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/fake_suppliers_repository.dart';

class _Picker extends TableFilePicker {
  _Picker(this.file);

  PickedTableFile? file;

  @override
  Future<PickedTableFile?> pickTable({required int maxBytes}) async => file;
}

PickedTableFile _file(String name, List<int> bytes, {bool tooLarge = false}) =>
    PickedTableFile(
      name: name,
      size: bytes.length,
      bytes: tooLarge ? null : Uint8List.fromList(bytes),
    );

PickedTableFile _csv(String text) => _file('supplier.csv', utf8.encode(text));

void main() {
  late FakeSuppliersRepository repo;
  late _Picker picker;
  late SupplierImportViewModel vm;

  setUp(() {
    repo = FakeSuppliersRepository();
    picker = _Picker(null);
    vm = SupplierImportViewModel(repository: repo, picker: picker);
  });

  tearDown(() => vm.dispose());

  test('pilih berkas → pratinjau → simpan', () async {
    picker.file = _csv(
      'Nama;Kontak;Telepon;Tempo (hari)\n'
      'ud makmur;Bu Rina;;30\n'
      'Toko Plastik Jaya;Mas Budi;0813-1111-2222;\n'
      'Toko X;;123;\n',
    );
    await vm.pick.execute();
    expect(vm.fileName, 'supplier.csv');
    expect(vm.problem, isNull);
    expect(vm.rows.map((r) => r.name), ['ud makmur', 'Toko Plastik Jaya']);
    expect(
      [for (final r in vm.rejected) (r.line, r.reason)],
      [
        (4, SupplierImportRejectReason.phone),
      ],
    );
    expect(vm.canRun, isTrue);
    await vm.run.execute();
    final summary = (vm.run.result! as Ok<SupplierImportSummary>).value;
    expect(summary.created, 1);
    expect(summary.updated, 1);
    expect(repo.imported.single, hasLength(2));
    expect(repo.byName('Toko Plastik Jaya').termDays, 14);
    // Tidak bisa disimpan dua kali.
    expect(vm.canRun, isFalse);
  });

  test('berkas bermasalah', () async {
    picker.file = _file('besar.csv', const [1], tooLarge: true);
    await vm.pick.execute();
    expect(vm.problem, ImportFileProblem.tooLarge);

    picker.file = _csv('Kontak,Telepon\nA,0812345678\n');
    await vm.pick.execute();
    expect(vm.problem, ImportFileProblem.missingName);
    expect(vm.canRun, isFalse);

    picker.file = _csv('Nama,Telepon\n');
    await vm.pick.execute();
    expect(vm.problem, ImportFileProblem.empty);

    picker.file = _file('rusak.xlsx', utf8.encode('bukan zip'));
    await vm.pick.execute();
    expect(vm.problem, ImportFileProblem.unreadable);

    // Batal memilih tidak mengubah pilihan sebelumnya.
    picker.file = null;
    await vm.pick.execute();
    expect(vm.fileName, 'rusak.xlsx');
  });

  test('tanpa izin kelola supplier: galat tampil', () async {
    repo.canManage = false;
    picker.file = _csv('Nama\nCV Baru\n');
    await vm.pick.execute();
    await vm.run.execute();
    expect(vm.run.result, isA<Error<SupplierImportSummary>>());
    expect(vm.canRun, isTrue);
  });
}
