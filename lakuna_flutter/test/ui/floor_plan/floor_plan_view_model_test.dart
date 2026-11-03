import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/image_file_picker.dart';
import 'package:lakuna_flutter/ui/floor_plan/floor_plan_view_model.dart';

import '../../testing/fake_dining_admin_repository.dart';
import '../../testing/fake_payment_settings_repository.dart';
import '../../testing/fake_stock_repository.dart' show fakeId;
import '../../testing/floor_seed.dart';

void main() {
  late FakeDiningAdminRepository repo;
  late FakeImagePicker picker;
  late FloorPlanViewModel vm;

  Future<void> start({UuidValue? area}) async {
    repo = FakeDiningAdminRepository();
    picker = FakeImagePicker();
    vm = FloorPlanViewModel(
      repository: repo,
      picker: picker,
      initialArea: area,
    );
    await vm.load.execute();
  }

  FloorItem item(String name) => vm.items.firstWhere((i) => i.name == name);

  test('muat: area pertama, mode grid, meja belum ditempatkan', () async {
    await start();
    expect(vm.area!.name, 'Indoor');
    expect(vm.mode, DiningLayoutMode.grid);
    expect(vm.showCanvas, isFalse);
    expect(vm.unplaced.map((i) => i.name), ['M1', 'M2']);
    expect(vm.placed, isEmpty);
    expect(vm.dirty, isFalse);
    expect(vm.world, (width: 800, height: 560));
  });

  test('area awal dari rute', () async {
    await start(area: fakeId(802));
    expect(vm.area!.name, 'Teras');
    expect(vm.unplaced.map((i) => i.name), ['T1']);
  });

  test('palet: M<n> berikutnya di tengah, tersnap 20, terpilih', () async {
    await start();
    vm.addPreset(TablePreset.all.first, cx: 400, cy: 300);
    final m = vm.selected!;
    expect(m.name, 'M3');
    expect(
      (m.shape, m.seats, m.width, m.height),
      (TableShape.round, 2, 60, 60),
    );
    // 400 − 30 = 370 → 380; 300 − 30 = 270 → 280.
    expect((m.x, m.y), (380, 280));
    expect(vm.dirty, isTrue);
    expect(vm.canUndo, isTrue);
  });

  test('tempatkan, geser dengan dan tanpa snap', () async {
    await start();
    final key = item('M1').key;
    vm.place(key, cx: 400, cy: 300);
    expect((item('M1').x, item('M1').y), (360, 260));
    expect(vm.selected!.name, 'M1');
    vm.moveTo(key, 123, 47);
    expect((item('M1').x, item('M1').y), (120, 40));
    vm.toggleSnap();
    vm.moveTo(key, 123, 47);
    expect((item('M1').x, item('M1').y), (123, 47));
    vm.moveTo(key, -10, 9000);
    expect((item('M1').x, item('M1').y), (0, 5000));
  });

  test('ubah ukuran dibatasi 20–600 dan tersnap', () async {
    await start();
    final key = item('M1').key;
    vm.place(key, cx: 400, cy: 300);
    vm.resizeTo(key, 341, 259, 133, 5);
    expect(
      (item('M1').x, item('M1').y, item('M1').width, item('M1').height),
      (340, 260, 140, 20),
    );
  });

  test('properti: orientasi tukar sisi, bentuk bulat sama sisi', () async {
    await start();
    vm.addPreset(TablePreset.all[2], cx: 400, cy: 300); // panjang 140×80
    vm.setVertical(true);
    expect((vm.selected!.width, vm.selected!.height), (80, 140));
    expect(vm.selected!.vertical, isTrue);
    vm.setVertical(false);
    expect((vm.selected!.width, vm.selected!.height), (140, 80));
    vm.setShape(TableShape.round);
    expect((vm.selected!.width, vm.selected!.height), (80, 80));
    vm.setCanMerge(true);
    expect(vm.selected!.canMerge, isTrue);
  });

  test('ketik nama dan kursi digabung jadi satu langkah undo', () async {
    await start();
    vm.select(item('M1').key);
    vm.setName('M');
    vm.setName('Me');
    vm.setName('Meja 1');
    vm.setSeats(null); // kolom kosong diabaikan
    vm.setSeats(6);
    expect((vm.selected!.name, vm.selected!.seats), ('Meja 1', 6));
    vm.undo();
    expect((vm.selected!.name, vm.selected!.seats), ('Meja 1', 4));
    vm.undo();
    expect(vm.selected!.name, 'M1');
    expect(vm.dirty, isFalse);
    vm.redo();
    vm.redo();
    expect((vm.selected!.name, vm.selected!.seats), ('Meja 1', 6));
    expect(vm.canRedo, isFalse);
  });

  test('pilihan bentuk/orientasi: tiap ketukan satu langkah undo', () async {
    await start();
    vm.addPreset(TablePreset.all[2], cx: 400, cy: 300); // panjang
    vm.setShape(TableShape.square);
    vm.setShape(TableShape.round);
    vm.undo();
    expect(vm.selected!.shape, TableShape.square);
  });

  test(
    'geser/ubah ukuran tanpa perubahan draf tetap memicu gambar ulang',
    () async {
      await start();
      final key = item('M1').key;
      vm.place(key, cx: 400, cy: 300); // 360, 260
      final revision = vm.revision;
      var notified = 0;
      vm.addListener(() => notified++);
      // Kanvas melaporkan 365 (belum di-snap) → draf tetap 360.
      vm.moveTo(key, 365, 262);
      expect((item('M1').x, item('M1').y), (360, 260));
      expect(vm.revision, greaterThan(revision));
      expect(notified, 1);
      vm.resizeTo(key, 360, 260, 83, 79);
      expect((item('M1').width, item('M1').height), (80, 80));
      expect(notified, 2);
      expect(vm.canUndo, isTrue);
      vm.undo();
      expect(item('M1').x, isNull); // hanya langkah tempatkan
    },
  );

  test('hapus: meja tersimpan masuk daftar hapus, meja baru hilang', () async {
    await start();
    vm.addPreset(TablePreset.all[1], cx: 100, cy: 100);
    vm.deleteSelected();
    expect(vm.items.map((i) => i.name), ['M1', 'M2']);
    vm.select(item('M2').key);
    vm.deleteSelected();
    await vm.save.execute();
    expect(repo.lastLayout!.deleted, [fakeId(852)]);
    expect(repo.tables.map((t) => t.name), ['M1', 'T1']);
  });

  test('simpan: draf + mode, lalu muat ulang dan tidak kotor', () async {
    await start();
    repo.tables.add(
      DiningTable(
        id: fakeId(870),
        tenantId: fakeId(1),
        outletId: fakeId(2),
        name: 'Bar 1',
        seats: 1,
        hlc: '',
      ),
    );
    await vm.load.execute();
    expect(vm.unplaced.map((i) => i.name), ['M1', 'M2', 'Bar 1']);
    vm.setMode(DiningLayoutMode.floor);
    vm.place(item('M1').key, cx: 400, cy: 300);
    vm.addPreset(TablePreset.all[3], cx: 200, cy: 200);
    await vm.save.execute();
    final sent = repo.lastLayout!;
    expect(sent.mode, DiningLayoutMode.floor);
    // Bar 1 (tanpa area, belum ditempatkan) tidak dikirim.
    expect(sent.tables.map((t) => (t.name, t.x)), [
      ('M1', 360),
      ('M2', null),
      ('M3', 120),
    ]);
    expect(vm.dirty, isFalse);
    expect(vm.mode, DiningLayoutMode.floor);
    expect(vm.selected!.name, 'M3');
    expect(vm.placed.map((i) => i.name), ['M1', 'M3']);
  });

  test('simpan ditolak: galat menunjuk meja draf', () async {
    await start();
    vm.select(item('M2').key);
    vm.setName('m1');
    await vm.save.execute();
    expect(vm.error, isA<DiningNameInvalid>());
    expect(vm.errorItem!.key, item('m1').key);
    expect(vm.dirty, isTrue);
    vm.setName('M9');
    expect(vm.error, isNull);
  });

  test('unggah gambar: SVG boleh, mode denah, draf tetap', () async {
    await start();
    vm.place(item('M1').key, cx: 400, cy: 300);
    picker.next = PickedImage(
      name: 'denah.svg',
      size: 60,
      bytes: Uint8List.fromList(
        utf8.encode('<svg viewBox="0 0 1600 1200" xmlns="x"></svg>'),
      ),
    );
    await vm.upload.execute(false);
    expect(picker.lastVector, isTrue);
    expect(vm.image!.isSvg, isTrue);
    expect(vm.world, (width: 800, height: 600));
    expect(vm.mode, DiningLayoutMode.floor);
    expect(vm.showCanvas, isTrue);
    expect(item('M1').placed, isTrue);
    expect(vm.dirty, isTrue);
  });

  test('unggah: terlalu besar ditolak tanpa menyimpan; batal diam', () async {
    await start();
    picker.next = const PickedImage(name: 'besar.png', size: 6 << 20);
    await vm.upload.execute(false);
    expect(
      vm.error,
      isA<FloorImageInvalid>().having(
        (e) => e.error,
        'error',
        FloorImageError.tooLarge,
      ),
    );
    expect(repo.images, isEmpty);
    await vm.upload.execute(false);
    expect(vm.image, isNull);

    picker
      ..camera = true
      ..next = PickedImage(name: 'foto.png', size: 69, bytes: samplePng);
    await vm.upload.execute(true);
    expect(picker.photoCalls, 1);
    expect(vm.image, isNotNull);
  });

  test('pindah area membuang draf; tambah area memilih area baru', () async {
    await start();
    vm.addPreset(TablePreset.all.first, cx: 0, cy: 0);
    vm.selectArea(fakeId(802));
    expect(vm.dirty, isFalse);
    expect(vm.items.map((i) => i.name), ['T1']);
    await vm.addArea.execute('Rooftop');
    expect(vm.area!.name, 'Rooftop');
    expect(vm.items, isEmpty);
    await vm.addArea.execute('rooftop');
    // Pesan galat area, bukan galat nama meja.
    expect(vm.error, isA<FloorAreaInvalid>());
  });
}
