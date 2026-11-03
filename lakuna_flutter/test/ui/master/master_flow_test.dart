import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_master_data_repository.dart';
import '../../testing/fake_session_repository.dart';
import '../../testing/fake_stock_repository.dart';

Finder _input(String key) => find.descendant(
  of: find.byKey(ValueKey(key)),
  matching: find.byType(EditableText),
);

Future<void> _type(WidgetTester tester, String key, String text) async {
  await tester.ensureVisible(find.byKey(ValueKey(key)));
  await tester.enterText(_input(key), text);
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(ValueKey(key)));
  await tester.tap(find.byKey(ValueKey(key)));
  await tester.pumpAndSettle();
}

void main() {
  final sembako = fakeId(301).uuid;
  final minuman = fakeId(302).uuid;
  final kopi = fakeId(303).uuid;
  final rokok = fakeId(304).uuid;

  Future<FakeMasterDataRepository> pump(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
    String role = 'owner',
  }) async {
    final repo = FakeMasterDataRepository();
    await pumpLakuna(
      tester,
      size: size,
      initialLocation: Routes.master,
      masterData: repo,
      stock: FakeStockRepository(),
      session: FakeSessionRepository()..current = sampleStaff(role: role),
    );
    return repo;
  }

  List<String> order(FakeMasterDataRepository repo) => [
    for (final c in [
      ...repo.categoriesData,
    ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)))
      c.name,
  ];

  testWidgets('kategori: tambah, urutkan, ubah, nonaktif, hapus', (
    tester,
  ) async {
    final repo = await pump(tester);
    expect(find.text('Master data'), findsWidgets);
    expect(find.byKey(ValueKey('master-category-$kopi')), findsOneWidget);
    expect(find.text('Minuman ›'), findsOneWidget);
    expect(find.text('Nonaktif'), findsOneWidget);

    // Kategori baru dengan galat nama kembar, lalu benar.
    await _type(tester, 'master-category-name-0', 'sembako');
    await _tap(tester, 'master-category-save');
    expect(find.text('Nama kategori sudah dipakai.'), findsOneWidget);
    await _type(tester, 'master-category-name-0', 'Teh');
    await _tap(tester, 'master-color-3');
    await tester.ensureVisible(find.text('Tampil di kasir'));
    await tester.tap(find.text('Tampil di kasir'));
    await tester.pumpAndSettle();
    await _tap(tester, 'master-category-save');
    expect(find.text('Kategori Teh tersimpan.'), findsOneWidget);
    final teh = repo.categoriesData.last;
    expect(teh.name, 'Teh');
    expect(teh.color, categoryColors[3]);
    expect(teh.showInCashier, isFalse);
    expect(find.text('Tidak di kasir'), findsOneWidget);

    // Naikkan Kopi.
    await _tap(tester, 'master-category-up-$kopi');
    expect(order(repo), ['Sembako', 'Kopi', 'Minuman', 'Rokok', 'Teh']);

    // Saklar aktif Rokok.
    await _tap(tester, 'master-category-active-$rokok');
    expect(
      repo.categoriesData.firstWhere((c) => c.name == 'Rokok').isActive,
      isTrue,
    );

    // Ubah Minuman: induk terkunci karena punya subkategori.
    await _tap(tester, 'master-category-edit-$minuman');
    expect(find.text('Ubah kategori'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('master-category-parent-locked')),
      findsOneWidget,
    );
    await _type(tester, 'master-category-name-2', 'Minuman dingin');
    await _tap(tester, 'master-category-save');
    expect(find.text('Minuman dingin ›'), findsOneWidget);

    // Hapus Sembako ditolak (2 produk).
    await _tap(tester, 'master-category-edit-$sembako');
    await _tap(tester, 'master-category-delete');
    expect(
      find.text('Tidak bisa dihapus: masih dipakai 2 produk.'),
      findsOneWidget,
    );
    // Hapus Teh berhasil.
    await _tap(tester, 'master-category-edit-${teh.id.uuid}');
    await _tap(tester, 'master-category-delete');
    expect(repo.categoriesData.any((c) => c.name == 'Teh'), isFalse);
    expect(find.text('Kategori baru'), findsOneWidget);
  });

  testWidgets('satuan: tambah, ganti nama, hapus ditolak bila dipakai', (
    tester,
  ) async {
    final repo = await pump(tester);
    await _tap(tester, 'master-tab-units');
    expect(find.text('2 produk'), findsOneWidget);

    await _type(tester, 'master-unit-new', 'PCS');
    await _tap(tester, 'master-unit-add');
    expect(find.text('Nama satuan sudah dipakai.'), findsOneWidget);
    await _type(tester, 'master-unit-new', 'kg');
    await _tap(tester, 'master-unit-add');
    expect(repo.unitsData.map((u) => u.name), contains('kg'));
    expect(find.byKey(const ValueKey('master-unit-error')), findsNothing);

    final dus = fakeId(403).uuid;
    await _tap(tester, 'master-unit-rename-$dus');
    await _type(tester, 'master-unit-edit-$dus', 'Dus');
    await _tap(tester, 'master-unit-save-$dus');
    expect(repo.unitsData.firstWhere((u) => u.id == fakeId(403)).name, 'Dus');

    final pcs = fakeId(401).uuid;
    await _tap(tester, 'master-unit-delete-$pcs');
    expect(
      find.text('Tidak bisa dihapus: masih dipakai 2 produk.'),
      findsOneWidget,
    );
    await _tap(tester, 'master-unit-delete-$dus');
    expect(repo.unitsData.any((u) => u.name == 'Dus'), isFalse);
  });

  testWidgets('lokasi membuka Stok › Lokasi; metode bayar ke Pengaturan', (
    tester,
  ) async {
    await pump(tester);
    await _tap(tester, 'master-tab-locations');
    expect(find.text('Gudang'), findsOneWidget);
    await _tap(tester, 'master-locations-manage');
    expect(find.byKey(const ValueKey('stock-location-new')), findsOneWidget);
  });

  testWidgets('metode bayar menautkan ke Pengaturan', (tester) async {
    await pump(tester);
    await _tap(tester, 'master-tab-payments');
    expect(find.byKey(const ValueKey('master-payment-qrisStatic')), findsOne);
    await _tap(tester, 'master-payments-open');
    expect(find.text('Pengaturan'), findsWidgets);
  });

  testWidgets('ponsel: pil tab dan form kategori di lembar bawah', (
    tester,
  ) async {
    final repo = await pump(tester, size: const Size(390, 844));
    expect(find.byKey(const ValueKey('master-pill-categories')), findsOne);
    expect(find.byKey(const ValueKey('master-category-form')), findsNothing);
    await _tap(tester, 'master-category-new');
    await _type(tester, 'master-category-name-1', 'Roti');
    await _tap(tester, 'master-category-save');
    expect(repo.categoriesData.last.name, 'Roti');
    // Lembar tertutup, pesan sukses tampil di daftar.
    expect(find.byKey(const ValueKey('master-category-save')), findsNothing);
    expect(find.text('Kategori Roti tersimpan.'), findsOneWidget);
  });

  for (final size in const [Size(820, 1180), Size(1280, 800), Size(360, 740)]) {
    testWidgets('semua tab tampil tanpa luapan di $size', (tester) async {
      await pump(tester, size: size);
      final prefix =
          find.byKey(const ValueKey('master-pill-units')).evaluate().isEmpty
          ? 'master-tab'
          : 'master-pill';
      for (final tab in ['units', 'locations', 'payments', 'categories']) {
        await _tap(tester, '$prefix-$tab');
      }
      expect(find.byKey(ValueKey('master-category-$kopi')), findsOneWidget);
    });
  }

  testWidgets('menu Master data hanya untuk products:manage', (tester) async {
    await pump(tester, role: 'cashier');
    // Kasir tanpa products:manage diarahkan ke Beranda.
    expect(find.byKey(const ValueKey('master-tab-categories')), findsNothing);
  });
}
