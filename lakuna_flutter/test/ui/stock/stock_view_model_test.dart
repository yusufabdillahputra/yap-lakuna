import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/ui/stock/stock_view_model.dart';

import '../../testing/fake_stock_repository.dart';

void main() {
  late FakeStockRepository repo;
  late StockViewModel vm;

  final kopi = fakeId(201);
  final sabun = fakeId(202);
  final telur = fakeId(203);

  setUp(() async {
    repo = FakeStockRepository();
    vm = StockViewModel(repository: repo, canAdjust: true);
    await vm.load.execute();
  });

  test('muat: lokasi, daftar, minimum, nomor, kartu produk pertama yang '
      'kritis', () {
    expect(vm.loaded, isTrue);
    expect(vm.location!.name, 'Etalase');
    expect(vm.rows, hasLength(3));
    expect(vm.below.map((r) => r.productName), ['Kopi Sachet', 'Telur Ayam']);
    expect(vm.nextNumber, 'SA-PST-K01-261103-0001');
    expect(vm.cardVariantId, kopi);
    expect(vm.card, isNotNull);
    expect(vm.totalValue, isA<Money>());
  });

  test('cari daftar stok: nama, SKU, atau barcode', () {
    vm.setQuery('sabun');
    expect(vm.filteredRows.single.variantId, sabun);
    vm.setQuery('8990001');
    expect(vm.filteredRows.single.variantId, kopi);
    vm.setQuery('');
    expect(vm.filteredRows, hasLength(3));
  });

  group('penyesuaian', () {
    test('tambah baris, isi fisik, selisih dan nilai, total', () {
      vm
        ..addLine(telur)
        ..addLine(kopi)
        ..addLine(sabun)
        ..addLine(sabun); // duplikat diabaikan
      expect(vm.lines.map((l) => l.row.variantId), [telur, kopi, sabun]);
      expect(vm.canSave, isFalse); // belum ada fisik

      vm
        ..setPhysical(telur, const Qty(12200))
        ..setLineNote(telur, 'Pecah')
        ..setPhysical(kopi, Qty.units(2))
        ..setPhysical(sabun, Qty.units(14));
      final t = vm.lines.first;
      expect(t.difference, const Qty(-300));
      expect(t.value, const Money(-7650));
      expect(vm.lines[1].difference, Qty.zero);
      expect(vm.totalValue, const Money(-25650));
      expect(vm.canSave, isTrue);

      vm.removeLine(kopi);
      expect(vm.lines, hasLength(2));
    });

    test('tambah lewat scan barcode/SKU/nama unik', () {
      expect(vm.addByCode('8990001'), isTrue);
      expect(vm.addByCode('telur'), isTrue);
      expect(vm.addByCode('zzz'), isFalse);
      expect(vm.lines.map((l) => l.row.variantId), [kopi, telur]);
    });

    test(
      'simpan: hanya baris terisi, alasan dan catatan, lalu muat ulang',
      () async {
        vm
          ..addLine(telur)
          ..addLine(sabun)
          ..setReason(StockAdjustmentReason.damaged)
          ..setNote('Cek mingguan')
          ..setPhysical(telur, const Qty(12000))
          ..setLineNote(telur, ' Pecah ');
        await vm.save.execute();
        final (_, reason, lines, note) = repo.saves.single;
        expect(reason, StockAdjustmentReason.damaged);
        expect(note, 'Cek mingguan');
        expect(lines.single.variantId, telur);
        expect(lines.single.physical, const Qty(12000));
        expect(lines.single.note, 'Pecah');
        expect(vm.lines, isEmpty);
        expect(vm.lastSaved, 'SA-PST-K01-261103-0001');
        expect(vm.nextNumber, 'SA-PST-K01-261103-0002');
        expect(vm.recent.single.number, 'SA-PST-K01-261103-0001');
        expect(
          vm.rows.firstWhere((r) => r.variantId == telur).stock,
          const Qty(12000),
        );
        expect(vm.reason, StockAdjustmentReason.routineCheck);
      },
    );

    test('galat simpan ditampilkan, draf tetap', () async {
      vm
        ..addLine(kopi)
        ..setPhysical(kopi, Qty.units(2));
      repo.nextError = const StockAdjustmentInvalid(
        StockAdjustmentError.noChange,
      );
      await vm.save.execute();
      expect(vm.saveError, StockAdjustmentError.noChange);
      expect(vm.lines, hasLength(1));
    });

    test('tanpa izin stock:adjust tidak bisa menyimpan', () async {
      vm = StockViewModel(repository: repo, canAdjust: false);
      await vm.load.execute();
      vm
        ..addLine(kopi)
        ..setPhysical(kopi, Qty.one);
      expect(vm.canSave, isFalse);
      await vm.save.execute();
      expect(repo.saves, isEmpty);
    });
  });

  test('kartu stok: pilih produk memuat pergerakannya', () async {
    vm
      ..addLine(sabun)
      ..setPhysical(sabun, Qty.units(13));
    await vm.save.execute();
    await vm.selectCardVariant(sabun);
    expect(vm.cardVariantId, sabun);
    expect(vm.card!.entries.single.quantity, Qty.units(-2));
    expect(vm.card!.current, Qty.units(13));
  });

  group('lokasi', () {
    test('tambah lalu ganti nama; galat duplikat', () async {
      expect(await vm.addLocation('Gudang'), isTrue);
      expect(vm.locations.map((l) => l.name), ['Etalase', 'Gudang']);
      expect(await vm.addLocation('gudang'), isFalse);
      expect(vm.locationError, StockLocationNameError.duplicate);
      final gudang = vm.locations.last.id;
      expect(await vm.renameLocation(gudang, 'Gudang Belakang'), isTrue);
      expect(vm.locations.last.name, 'Gudang Belakang');
      expect(vm.locationError, isNull);
    });

    test('pilih lokasi memuat ulang daftar dan mengosongkan draf', () async {
      await vm.addLocation('Gudang');
      vm.addLine(kopi);
      await vm.selectLocation(vm.locations.last.id);
      expect(vm.location!.name, 'Gudang');
      expect(vm.lines, isEmpty);
    });
  });
}
