import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/stock_repository.dart';
import 'package:lakuna_flutter/ui/stock/stock_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

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

  test(
    'UPC-A 13 digit (awalan 0) cocok dengan barcode 12 digit (F1-07h)',
    () async {
      final upc = StockViewModel(
        repository: FakeStockRepository(
          rows: [
            ...sampleStockRows(),
            sampleRow(
              4,
              'Sereal Impor',
              unit: 'pcs',
              stock: Qty.units(5),
              barcode: '036000291452',
            ),
          ],
        ),
        canAdjust: true,
      );
      await upc.load.execute();
      upc.setQuery('0036000291452');
      expect(upc.filteredRows.single.productName, 'Sereal Impor');
      expect(upc.addByCode('0036000291452'), AddByCodeResult.added);
      expect(upc.lines.single.row.productName, 'Sereal Impor');
    },
  );

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

  group('draf berisi (F1-08k)', () {
    test('kosong, alasan saja, dan catatan spasi tidak dihitung', () {
      expect(vm.hasUnsavedChanges, isFalse);
      vm
        ..setReason(StockAdjustmentReason.damaged)
        ..setNote('   ');
      expect(vm.hasUnsavedChanges, isFalse);
      vm.setNote('Opname akhir bulan');
      expect(vm.hasUnsavedChanges, isTrue);
      vm.setNote('');
      expect(vm.hasUnsavedChanges, isFalse);
    });

    test('baris tanpa fisik sudah dihitung; Batal mengosongkan', () {
      vm.addLine(kopi);
      expect(vm.hasUnsavedChanges, isTrue);
      vm.removeLine(kopi);
      expect(vm.hasUnsavedChanges, isFalse);
      vm.addLine(sabun);
      vm.clearDraft();
      expect(vm.hasUnsavedChanges, isFalse);
    });

    test('simpan: busy selama berjalan, kosong setelah berhasil, tetap '
        'berisi bila gagal', () async {
      vm
        ..addLine(kopi)
        ..setPhysical(kopi, Qty.units(2));
      repo.nextError = const StockAdjustmentInvalid(
        StockAdjustmentError.noChange,
      );
      // Draf tersimpan di perangkat (F1-08o) sebelum simpan dicoba.
      repo.draftWriteError = Exception('disk penuh');
      await vm.save.execute();
      expect(vm.lines, isNotEmpty);
      expect(vm.hasUnsavedChanges, isTrue);
      repo.draftWriteError = null;

      final gate = Completer<void>();
      repo.saveGate = gate.future;
      expect(vm.busy, isFalse);
      final saving = vm.save.execute();
      expect(vm.busy, isTrue);
      gate.complete();
      await saving;
      expect(vm.busy, isFalse);
      expect(vm.hasUnsavedChanges, isFalse);
    });

    test('ganti lokasi mengosongkan draf di layar', () async {
      repo.locationList = [
        sampleLocation(1, 'Etalase', true),
        sampleLocation(2, 'Gudang', false),
      ];
      await vm.load.execute();
      vm.addLine(telur);
      await vm.selectLocation(repo.locationList[1].id);
      expect(vm.lines, isEmpty);
      expect(vm.hasUnsavedChanges, isFalse);
    });

    test('tanpa izin stock:adjust tidak pernah berisi', () async {
      vm = StockViewModel(repository: repo, canAdjust: false);
      await vm.load.execute();
      vm
        ..addLine(kopi)
        ..setNote('catatan');
      expect(vm.hasUnsavedChanges, isFalse);
    });
  });

  group('stok sistem berubah sejak dihitung (F1-08q)', () {
    Qty stockOf(UuidValue id) =>
        repo.rows.firstWhere((r) => r.variantId == id).stock;

    void changeStock(UuidValue id, Qty stock) {
      final i = repo.rows.indexWhere((r) => r.variantId == id);
      final r = repo.rows[i];
      repo.rows[i] = StockRow(
        variantId: r.variantId,
        productId: r.productId,
        productName: r.productName,
        variantName: r.variantName,
        baseUnit: r.baseUnit,
        stock: stock,
        minStock: r.minStock,
        unitCost: r.unitCost,
        sku: r.sku,
        barcode: r.barcode,
      );
    }

    test('isi fisik mencatat stok; stok berubah lalu dimuat ulang → '
        'peringatan', () async {
      final before = stockOf(kopi);
      vm
        ..addLine(kopi)
        ..addLine(sabun)
        ..setPhysical(kopi, Qty.units(3));
      expect(vm.lines.first.countedSystem, before);
      expect(vm.lines.last.countedSystem, isNull);
      expect(vm.systemChangedCount, 0);

      changeStock(kopi, before - Qty.one);
      changeStock(sabun, Qty.units(99));
      await vm.load.execute();
      final line = vm.lines.first;
      expect(line.row.stock, before - Qty.one);
      expect(line.countedSystem, before);
      expect(line.systemChanged, isTrue);
      // Belum dihitung: tidak berperingatan.
      expect(vm.lines.last.systemChanged, isFalse);
      expect(vm.systemChangedCount, 1);
      // Selisih memakai stok terbaru.
      expect(line.difference, Qty.units(3) - (before - Qty.one));
    });

    test('Sudah dicek dan angka baru menghapus peringatan; angka sama '
        'tidak; kosongkan menghapus stok saat dihitung', () async {
      final before = stockOf(kopi);
      vm
        ..addLine(kopi)
        ..setPhysical(kopi, Qty.units(3));
      changeStock(kopi, before + Qty.one);
      await vm.load.execute();
      expect(vm.systemChangedCount, 1);

      vm.setPhysical(kopi, Qty.units(3));
      expect(vm.systemChangedCount, 1);
      vm.acknowledgeSystemChange(kopi);
      expect(vm.systemChangedCount, 0);
      expect(vm.lines.single.countedSystem, before + Qty.one);

      changeStock(kopi, before);
      await vm.load.execute();
      expect(vm.systemChangedCount, 1);
      vm.setPhysical(kopi, Qty.units(4));
      expect(vm.systemChangedCount, 0);
      expect(vm.lines.single.countedSystem, before);

      vm.setPhysical(kopi, null);
      expect(vm.lines.single.countedSystem, isNull);
    });

    test('draf dipulihkan membawa stok saat dihitung', () async {
      final etalase = vm.location!.id;
      repo.drafts[etalase] = StockAdjustmentDraft(
        reason: StockAdjustmentReason.routineCheck,
        lines: [
          StockAdjustmentDraftLine(
            variantId: kopi,
            physical: Qty.units(3),
            note: '',
            countedSystem: stockOf(kopi) + Qty.units(2),
          ),
        ],
      );
      final again = StockViewModel(repository: repo, canAdjust: true);
      addTearDown(again.dispose);
      await again.load.execute();
      expect(again.lines.single.systemChanged, isTrue);
      expect(again.systemChangedCount, 1);
    });
  });

  group('draf tersimpan di perangkat (F1-08o)', () {
    late StockLocation etalase;
    late StockLocation gudang;

    setUp(() async {
      etalase = sampleLocation(1, 'Etalase', true);
      gudang = sampleLocation(2, 'Gudang', false);
      repo.locationList = [etalase, gudang];
      repo.rowsByLocation[gudang.id] = [
        sampleRow(9, 'Beras', unit: 'kg', stock: Qty.units(50)),
      ];
      await vm.load.execute();
    });

    test('setiap perubahan ditulis; tersimpan berarti tidak ada perubahan '
        'yang hilang', () async {
      vm
        ..addLine(kopi)
        ..setPhysical(kopi, Qty.units(3))
        ..setLineNote(kopi, 'rak atas')
        ..setReason(StockAdjustmentReason.damaged)
        ..setNote('Opname');
      // Tulis belum selesai: masih dianggap belum tersimpan.
      expect(vm.hasUnsavedChanges, isTrue);
      await pumpEventQueue();
      expect(vm.hasUnsavedChanges, isFalse);
      expect(vm.draftStored, isTrue);
      expect(
        repo.drafts[etalase.id],
        StockAdjustmentDraft(
          reason: StockAdjustmentReason.damaged,
          note: 'Opname',
          lines: [
            StockAdjustmentDraftLine(
              variantId: kopi,
              physical: Qty.units(3),
              note: 'rak atas',
              // Stok sistem saat dihitung (F1-08q).
              countedSystem: repo.rows
                  .firstWhere((r) => r.variantId == kopi)
                  .stock,
            ),
          ],
        ),
      );
    });

    test('dipulihkan saat dibuka lagi dengan stok sistem terbaru; barang '
        'yang hilang dibuang', () async {
      repo.drafts[etalase.id] = StockAdjustmentDraft(
        reason: StockAdjustmentReason.lost,
        note: 'Lanjut besok',
        lines: [
          StockAdjustmentDraftLine(
            variantId: sabun,
            physical: Qty.units(1),
            note: '',
          ),
          StockAdjustmentDraftLine(
            variantId: fakeId(999),
            physical: Qty.one,
            note: 'dihapus',
          ),
          StockAdjustmentDraftLine(variantId: kopi, physical: null, note: ''),
        ],
      );
      final again = StockViewModel(repository: repo, canAdjust: true);
      addTearDown(again.dispose);
      await again.load.execute();
      expect(again.reason, StockAdjustmentReason.lost);
      expect(again.note, 'Lanjut besok');
      expect(again.lines.map((l) => l.row.variantId), [sabun, kopi]);
      expect(again.lines.first.physical, Qty.units(1));
      expect(
        again.lines.first.row.stock,
        repo.rows.firstWhere((r) => r.variantId == sabun).stock,
      );
      expect(again.hasUnsavedChanges, isFalse);
      expect(again.draftStored, isTrue);
    });

    test('ganti lokasi: draf lokasi lama tetap, lokasi baru memuat '
        'drafnya sendiri', () async {
      vm.addLine(kopi);
      await pumpEventQueue();
      final beras = repo.rowsByLocation[gudang.id]!.single.variantId;
      repo.drafts[gudang.id] = StockAdjustmentDraft(
        reason: StockAdjustmentReason.routineCheck,
        lines: [
          StockAdjustmentDraftLine(
            variantId: beras,
            physical: Qty.units(48),
            note: '',
          ),
        ],
      );
      await vm.selectLocation(gudang.id);
      expect(vm.lines.single.row.variantId, beras);
      expect(repo.drafts[etalase.id]!.lines.single.variantId, kopi);

      await vm.selectLocation(etalase.id);
      expect(vm.lines.single.row.variantId, kopi);
      expect(repo.drafts[gudang.id]!.lines.single.variantId, beras);
    });

    test('simpan berhasil dan Batal menghapus draf lokasi itu', () async {
      vm
        ..addLine(kopi)
        ..setPhysical(kopi, Qty.units(2));
      await pumpEventQueue();
      expect(repo.drafts, contains(etalase.id));
      await vm.save.execute();
      await pumpEventQueue();
      expect(repo.drafts, isNot(contains(etalase.id)));

      vm.addLine(sabun);
      await pumpEventQueue();
      expect(repo.drafts, contains(etalase.id));
      vm.clearDraft();
      await pumpEventQueue();
      expect(repo.drafts, isEmpty);
    });

    test(
      'tulis gagal: belum tersimpan sampai tulis berikutnya berhasil',
      () async {
        repo.draftWriteError = Exception('disk penuh');
        vm.addLine(kopi);
        await pumpEventQueue();
        expect(vm.hasUnsavedChanges, isTrue);
        expect(vm.draftWriteFailed, isTrue);
        repo.draftWriteError = null;
        vm.setPhysical(kopi, Qty.one);
        await pumpEventQueue();
        expect(vm.hasUnsavedChanges, isFalse);
        expect(vm.draftWriteFailed, isFalse);
      },
    );

    test('tulis berurutan: tulis lama yang selesai belakangan tidak '
        'menimpa', () async {
      final gate = Completer<void>();
      repo.draftWriteGate = gate.future;
      vm.addLine(kopi);
      vm.setPhysical(kopi, Qty.units(7));
      repo.draftWriteGate = null;
      gate.complete();
      await pumpEventQueue();
      expect(repo.drafts[etalase.id]!.lines.single.physical, Qty.units(7));
      expect(vm.hasUnsavedChanges, isFalse);
    });

    test('ganti lokasi ditolak selama simpan; draf lokasi itu tetap '
        'terhapus', () async {
      vm
        ..addLine(kopi)
        ..setPhysical(kopi, Qty.units(2));
      await pumpEventQueue();
      final gate = Completer<void>();
      repo.saveGate = gate.future;
      final saving = vm.save.execute();
      await vm.selectLocation(gudang.id);
      expect(vm.location, etalase);
      gate.complete();
      await saving;
      await pumpEventQueue();
      expect(repo.saves.single.$1, etalase.id);
      expect(repo.drafts, isEmpty);
      expect(vm.location, etalase);
    });

    test('perubahan selama lokasi baru dimuat diabaikan', () async {
      final gate = Completer<void>();
      repo.stockGate = gate.future;
      final switching = vm.selectLocation(gudang.id);
      vm
        ..addLine(kopi)
        ..setNote('salah lokasi');
      expect(vm.lines, isEmpty);
      expect(vm.note, isEmpty);
      repo.stockGate = null;
      gate.complete();
      await switching;
      await pumpEventQueue();
      expect(vm.lines, isEmpty);
      expect(vm.hasUnsavedChanges, isFalse);
      expect(repo.drafts, isEmpty);
      // Setelah termuat, perubahan ditulis seperti biasa.
      final beras = repo.rowsByLocation[gudang.id]!.single.variantId;
      vm.addLine(beras);
      await pumpEventQueue();
      expect(repo.drafts[gudang.id]!.lines.single.variantId, beras);
    });

    test('galat baca draf: draf tersimpan tidak ditimpa, perubahan belum '
        'tersimpan, dibaca lagi saat muat ulang', () async {
      final stored = StockAdjustmentDraft(
        reason: StockAdjustmentReason.lost,
        lines: [
          StockAdjustmentDraftLine(
            variantId: sabun,
            physical: Qty.one,
            note: '',
          ),
        ],
      );
      repo.drafts[etalase.id] = stored;
      repo.draftReadError = Exception('disk rusak');
      final again = StockViewModel(repository: repo, canAdjust: true);
      addTearDown(again.dispose);
      await again.load.execute();
      expect(again.lines, isEmpty);
      expect(again.hasUnsavedChanges, isFalse);
      expect(again.draftWriteFailed, isFalse);

      // Tanpa perubahan: muat ulang membaca lagi.
      repo.draftReadError = null;
      await again.load.execute();
      expect(again.lines.single.row.variantId, sabun);

      // Galat baca lalu ada perubahan: tidak ditulis dan dijaga dialog.
      repo.draftReadError = Exception('disk rusak');
      final third = StockViewModel(repository: repo, canAdjust: true);
      addTearDown(third.dispose);
      await third.load.execute();
      third.addLine(kopi);
      await pumpEventQueue();
      expect(repo.drafts[etalase.id], stored);
      expect(third.hasUnsavedChanges, isTrue);
      expect(third.draftWriteFailed, isTrue);
      // Muat ulang tidak menimpa perubahan di layar dengan draf lama.
      repo.draftReadError = null;
      await third.load.execute();
      expect(third.lines.single.row.variantId, kopi);
      expect(third.hasUnsavedChanges, isTrue);
    });

    test('hapus draf gagal setelah baris terakhir dibuang: tercatat '
        'gagal tanpa dianggap perubahan', () async {
      vm.addLine(kopi);
      await pumpEventQueue();
      repo.draftWriteError = Exception('disk penuh');
      vm.removeLine(kopi);
      await pumpEventQueue();
      expect(vm.hasUnsavedChanges, isFalse);
      expect(vm.draftWriteFailed, isTrue);
      repo.draftWriteError = null;
      vm.clearDraft();
      await vm.flushDraft();
      expect(repo.drafts, isEmpty);
      expect(vm.draftWriteFailed, isFalse);
    });

    test('tanpa izin stock:adjust: draf tidak dibaca atau ditulis', () async {
      repo.drafts[etalase.id] = StockAdjustmentDraft(
        reason: StockAdjustmentReason.lost,
        lines: [
          StockAdjustmentDraftLine(
            variantId: kopi,
            physical: Qty.one,
            note: '',
          ),
        ],
      );
      final viewer = StockViewModel(repository: repo, canAdjust: false);
      addTearDown(viewer.dispose);
      await viewer.load.execute();
      expect(viewer.lines, isEmpty);
      final writes = repo.draftWrites;
      viewer.addLine(sabun);
      await pumpEventQueue();
      expect(repo.draftWrites, writes);
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

  test('kekurangan draf dari saran (F1-08p)', () {
    // Stok 2, minimum 20: saran 38.
    final row = sampleRow(
      1,
      'Teh Botol',
      unit: 'btl',
      stock: Qty.units(2),
      minStock: Qty.units(20),
    );
    DraftMark mark(Qty ordered) =>
        (number: 'PB-PST-K01-261120-0001', drafts: 1, ordered: ordered);
    expect(StockViewModel.shortfallOf(row, mark(Qty.units(5))), Qty.units(33));
    expect(
      StockViewModel.shortfallOf(row, mark(const Qty(37500))),
      const Qty(500),
    );
    expect(StockViewModel.shortfallOf(row, mark(Qty.units(38))), Qty.zero);
    expect(StockViewModel.shortfallOf(row, mark(Qty.units(50))), Qty.zero);
  });

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

    test('pilih lokasi memuat ulang daftar; draf lokasi baru kosong', () async {
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

  group('cetak stok minimum (F1-08r)', () {
    test('tab Stok minimum mencetak hanya baris di bawah minimum', () async {
      expect(vm.printsMinimum, isFalse);
      expect(vm.printRows, hasLength(3));
      vm.setTab(StockTab.minimum);
      expect(vm.printsMinimum, isTrue);
      expect(vm.printRows.map((r) => r.productName), [
        for (final r in vm.below) r.productName,
      ]);
      expect(vm.printRows, hasLength(2));
      expect(vm.canPrint, isTrue);
      // Pencarian tetap tidak menyaring.
      vm.setQuery('kopi');
      expect(vm.printRows, hasLength(2));
      vm.setTab(StockTab.list);
      expect(vm.printsMinimum, isFalse);
      expect(vm.printRows, hasLength(3));
    });

    test('tanpa barang di bawah minimum tombol mati', () async {
      await vm.addLocation('Gudang');
      final gudang = vm.locations.last.id;
      repo.rowsByLocation[gudang] = [
        sampleRow(9, 'Beras', unit: 'kg', stock: Qty.units(50)),
      ];
      await vm.selectLocation(gudang);
      vm.setTab(StockTab.minimum);
      expect(vm.below, isEmpty);
      expect(vm.canPrint, isFalse);
      vm.setTab(StockTab.list);
      expect(vm.canPrint, isTrue);
    });
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

  group('tanda sudah di draf (F1-08h)', () {
    RestockDraft draft(
      String number,
      Set<UuidValue> ids, [
      Map<UuidValue, Qty> quantities = const {},
    ]) => RestockDraft(
      purchaseId: fakeId(900 + number.length),
      number: number,
      variantIds: ids,
      quantities: quantities,
    );

    test('jumlah dipesan dijumlah dari semua draf (F1-08l)', () async {
      final v = StockViewModel(
        repository: repo,
        canAdjust: true,
        restockDrafts: (_, _) async => Result.ok([
          draft('PB-2', {kopi, telur}, {kopi: Qty.units(5), telur: Qty(500)}),
          draft('PB-1', {kopi}, {kopi: Qty.units(7)}),
        ]),
      );
      await v.load.execute();
      expect(v.draftMarkOf(kopi), (
        number: 'PB-2',
        drafts: 2,
        ordered: Qty.units(12),
      ));
      expect(v.draftMarkOf(telur), (
        number: 'PB-2',
        drafts: 1,
        ordered: Qty(500),
      ));
      expect(v.draftMarkOf(sabun), isNull);
    });

    test('barang di draf mendapat nomor draf pertama; lainnya null', () async {
      final calls = <(UuidValue, Set<UuidValue>)>[];
      final v = StockViewModel(
        repository: repo,
        canAdjust: true,
        restockDrafts: (location, ids) async {
          calls.add((location, ids.toSet()));
          return Result.ok([
            draft('PB-2', {kopi, telur}),
            draft('PB-1', {kopi}),
          ]);
        },
      );
      await v.load.execute();
      expect(calls.single.$1, v.location!.id);
      expect(calls.single.$2, {kopi, telur});
      expect(v.draftMarkOf(kopi)?.number, 'PB-2');
      expect(v.draftMarkOf(telur)?.number, 'PB-2');
      expect(v.draftMarkOf(sabun)?.number, isNull);
    });

    test('galat baca atau tanpa fungsi: tanpa tanda', () async {
      expect(vm.draftMarkOf(kopi)?.number, isNull);
      final v = StockViewModel(
        repository: repo,
        canAdjust: true,
        restockDrafts: (_, _) async => Result.error(Exception('gagal')),
      );
      await v.load.execute();
      expect(v.loaded, isTrue);
      expect(v.below, hasLength(2));
      expect(v.draftMarkOf(kopi)?.number, isNull);
    });

    test('muat ulang menyegarkan tanda', () async {
      var drafts = [
        draft('PB-1', {kopi}),
      ];
      final v = StockViewModel(
        repository: repo,
        canAdjust: true,
        restockDrafts: (_, _) async => Result.ok(drafts),
      );
      await v.load.execute();
      expect(v.draftMarkOf(kopi)?.number, 'PB-1');
      drafts = [];
      await v.load.execute();
      expect(v.draftMarkOf(kopi)?.number, isNull);
    });
  });

  group('kartu stok dari pembelian (F1-12c)', () {
    test('focusCard sebelum muat memilih lokasi, tab, dan produk', () async {
      final gudang = sampleLocation(2, 'Gudang', false);
      repo = FakeStockRepository(
        locations: [sampleLocation(1, 'Etalase', true), gudang],
      );
      vm = StockViewModel(repository: repo, canAdjust: true)
        ..focusCard(variantId: sabun, locationId: gudang.id);
      await vm.load.execute();
      expect(vm.tab, StockTab.card);
      expect(vm.location!.name, 'Gudang');
      expect(vm.cardVariantId, sabun);
      expect(vm.card, isNotNull);
      expect(vm.cardFocusMissing, isFalse);
    });

    test('produk atau lokasi yang tidak ada jatuh ke bawaan', () async {
      vm = StockViewModel(repository: repo, canAdjust: true)
        ..focusCard(variantId: fakeId(999), locationId: fakeId(998));
      await vm.load.execute();
      expect(vm.location!.name, 'Etalase');
      expect(vm.cardVariantId, kopi);
      // Staf diberi tahu tautan tidak ditemukan; hilang setelah memilih.
      expect(vm.cardFocusMissing, isTrue);
      await vm.selectCardVariant(sabun);
      expect(vm.cardFocusMissing, isFalse);
    });

    test('hanya lokasi yang hilang juga diberi tahu', () async {
      vm = StockViewModel(repository: repo, canAdjust: true)
        ..focusCard(variantId: sabun, locationId: fakeId(998));
      await vm.load.execute();
      expect(vm.cardVariantId, sabun);
      expect(vm.cardFocusMissing, isTrue);
      // Muat ulang tidak memunculkan pemberitahuan lagi.
      await vm.selectCardVariant(sabun);
      await vm.load.execute();
      expect(vm.cardFocusMissing, isFalse);
    });

    test('tanpa focusCard tidak ada pemberitahuan', () async {
      vm = StockViewModel(repository: repo, canAdjust: true);
      await vm.load.execute();
      expect(vm.cardFocusMissing, isFalse);
    });
  });
}
