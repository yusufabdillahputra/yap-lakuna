import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/ui/stock/stock_view_model.dart';

import '../../testing/fake_spreadsheet_exporter.dart';
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
      expect(vm.addByCode('8990001'), AddByCodeResult.added);
      expect(vm.addByCode('telur'), AddByCodeResult.added);
      expect(vm.addByCode('zzz'), AddByCodeResult.notFound);
      // Pindai ulang barang yang sudah ada: tidak menambah, beri tahu.
      expect(vm.addByCode('8990001'), AddByCodeResult.already);
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

  test(
    'kartu stok: jawaban lama tidak menimpa produk yang baru dipilih',
    () async {
      final gate = Completer<void>();
      repo.cardGate = gate.future;
      final slow = vm.selectCardVariant(sabun);
      expect(vm.card, isNull); // kartu lama tidak tampil di bawah nama baru
      repo.cardGate = null;
      await vm.selectCardVariant(telur);
      gate.complete();
      await slow;
      expect(vm.cardVariantId, telur);
      expect(vm.card!.minStock, Qty.units(15));
    },
  );

  test('nama produk kembar tetap bisa dibedakan di pilihan', () {
    final rows = [
      sampleRow(1, 'Teh Botol', unit: 'btl', stock: Qty.one, barcode: '111'),
      sampleRow(2, 'Teh Botol', unit: 'btl', stock: Qty.one, barcode: '222'),
      sampleRow(3, 'Kopi', unit: 'pcs', stock: Qty.one),
    ];
    final labels = uniqueStockLabels(rows);
    expect(labels.values.toSet(), hasLength(3));
    expect(labels[rows[2].variantId], 'Kopi');
    expect(labels[rows[0].variantId], 'Teh Botol · 111');
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

    test(
      'ganti lokasi saat muat masih berjalan memakai lokasi terbaru',
      () async {
        await vm.addLocation('Gudang');
        final gudang = vm.locations.last.id;
        repo.rowsByLocation[gudang] = [
          sampleRow(9, 'Beras', unit: 'kg', stock: Qty.units(50)),
        ];
        final gate = Completer<void>();
        repo.stockGate = gate.future;
        final first = vm.load.execute(); // Etalase, tertahan.
        await Future<void>.delayed(Duration.zero);
        repo.stockGate = null;
        await vm.selectLocation(gudang);
        gate.complete();
        await first;
        expect(vm.location!.id, gudang);
        expect(vm.rows.map((r) => r.productName), ['Beras']);
      },
    );

    test('pilih lokasi memuat ulang daftar dan mengosongkan draf', () async {
      await vm.addLocation('Gudang');
      vm.addLine(kopi);
      await vm.selectLocation(vm.locations.last.id);
      expect(vm.location!.name, 'Gudang');
      expect(vm.lines, isEmpty);
    });
  });

  group('cetak stok (F1-08b)', () {
    test(
      'simpan PDF: nama berkas, lokasi, galat, reset saat ganti lokasi',
      () async {
        final exporter = FakeSpreadsheetExporter()
          ..path = '/docs/Lakuna/stok-etalase-261114.pdf';
        final printing = StockViewModel(
          repository: repo,
          canAdjust: true,
          exporter: exporter,
        );
        await printing.load.execute();
        expect(printing.canPrint, isTrue);
        final bytes = Uint8List.fromList([1, 2, 3]);
        await printing.printList.execute((
          () async => bytes,
          'stok-etalase-261114.pdf',
        ));
        expect(exporter.saved.single.$1, 'stok-etalase-261114.pdf');
        expect(printing.printPath, '/docs/Lakuna/stok-etalase-261114.pdf');
        expect(printing.canPrint, isTrue);

        exporter.error = Exception('disk penuh');
        await printing.printList.execute((
          () async => bytes,
          'stok-etalase-261114.pdf',
        ));
        expect(printing.printList.error, isTrue);
        expect(printing.printPath, isNull);

        await printing.addLocation('Gudang');
        final gudang = printing.locations.last.id;
        repo.rowsByLocation[gudang] = [];
        await printing.selectLocation(gudang);
        expect(printing.printList.result, isNull);
        // Lokasi tanpa baris: tidak ada yang dicetak.
        expect(printing.rows, isEmpty);
        expect(printing.canPrint, isFalse);
        printing.dispose();
      },
    );
  });

  group('cetak stok: baris & lokasi selaras (F1-08b)', () {
    test(
      'selama ganti lokasi tombol mati; baris cetak tidak ikut pencarian',
      () async {
        vm.setQuery('sabun');
        expect(vm.filteredRows, hasLength(1));
        expect(vm.printRows, hasLength(3));
        expect(vm.printLocationName, 'Etalase');

        await vm.addLocation('Gudang');
        final gudang = vm.locations.last.id;
        repo.rowsByLocation[gudang] = [
          sampleRow(9, 'Beras', unit: 'kg', stock: Qty.units(50)),
        ];
        final gate = Completer<void>();
        repo.stockGate = gate.future;
        final loading = vm.selectLocation(gudang);
        await Future<void>.delayed(Duration.zero);
        // Nama lokasi baru, baris masih lokasi lama: jangan cetak.
        expect(vm.canPrint, isFalse);
        gate.complete();
        repo.stockGate = null;
        await loading;
        expect(vm.canPrint, isTrue);
        expect(vm.printLocationName, 'Gudang');
        expect(vm.printRows.single.productName, 'Beras');
      },
    );

    test(
      'muat lokasi gagal: baris lama tidak dicetak atas nama lokasi baru',
      () async {
        await vm.addLocation('Gudang');
        final gudang = vm.locations.last.id;
        repo.nextError = Exception('db');
        await vm.selectLocation(gudang);
        expect(vm.load.error, isTrue);
        expect(vm.canPrint, isFalse);
      },
    );

    test(
      'galat (Error) dari pembuat PDF ditangkap; ganti tab menghapus pesan',
      () async {
        final exporter = FakeSpreadsheetExporter();
        final printing = StockViewModel(
          repository: repo,
          canAdjust: true,
          exporter: exporter,
        );
        await printing.load.execute();
        await printing.printList.execute((
          () async => throw StateError('font'),
          'stok.pdf',
        ));
        expect(printing.printList.error, isTrue);
        expect(printing.canPrint, isTrue);
        printing.setTab(StockTab.card);
        expect(printing.printList.result, isNull);
        printing.dispose();
      },
    );
  });

  test('isian pembelian dari stok minimum (F1-08c)', () async {
    final r = vm.restock!;
    expect(r.locationName, 'Etalase');
    expect(r.locationId, vm.location!.id);
    // Kopi 2/20 → 38; Telur 12,5/15 → 18.
    expect(r.lines.map((l) => (l.variantId, l.quantity)), [
      (kopi, Qty.units(38)),
      (telur, Qty.units(18)),
    ]);

    await vm.addLocation('Gudang');
    final gudang = vm.locations.last.id;
    // Seperti data asli: minimum hanya berlaku di lokasi bawaan.
    repo.rowsByLocation[gudang] = [
      sampleRow(1, 'Kopi Sachet', unit: 'sachet', stock: Qty.units(1)),
    ];
    final gate = Completer<void>();
    repo.stockGate = gate.future;
    final loading = vm.selectLocation(gudang);
    await Future<void>.delayed(Duration.zero);
    expect(vm.restock, isNull);
    gate.complete();
    repo.stockGate = null;
    await loading;
    expect(vm.restock, isNull);
  });
}
