import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/app.dart';
import 'package:lakuna_flutter/data/repositories/session_repository.dart';
import 'package:lakuna_flutter/routing/routes.dart';
import 'package:lakuna_flutter/ui/settings/app_settings_view_model.dart';
import 'package:lakuna_flutter/ui/stock/stock_view.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_app_settings_repository.dart';
import '../../testing/fake_session_repository.dart';
import '../../testing/fake_spreadsheet_exporter.dart';
import '../../testing/fake_stock_repository.dart';
import '../../testing/fake_store_repository.dart';

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
  final kopi = fakeId(201).uuid;
  final sabun = fakeId(202).uuid;
  final telur = fakeId(203).uuid;

  Future<FakeStockRepository> pump(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
    String role = 'owner',
    FakeSpreadsheetExporter? exporter,
    FakeStockRepository? stock,
  }) async {
    final repo = stock ?? FakeStockRepository();
    await pumpLakuna(
      tester,
      size: size,
      initialLocation: Routes.stock,
      stock: repo,
      exporter: exporter,
      session: FakeSessionRepository()..current = sampleStaff(role: role),
    );
    return repo;
  }

  testWidgets('penyesuaian: scan, tambah dari saran, isi fisik, simpan', (
    tester,
  ) async {
    final repo = await pump(tester);
    expect(find.text('Stok'), findsWidgets);
    expect(find.text('Penyesuaian stok baru'), findsOneWidget);
    expect(find.text('SA-PST-K01-261103-0001 · Yusuf'), findsOneWidget);
    expect(find.byKey(const ValueKey('stock-lines-empty')), findsOneWidget);

    // Scan barcode lalu Enter.
    await _type(tester, 'stock-add', '8990001');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey('stock-line-$kopi')), findsOneWidget);

    // Pindai ulang barang yang sama: tidak menambah baris, beri tahu.
    await _type(tester, 'stock-add', '8990001');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('stock-add-already')), findsOneWidget);

    // Kode tak dikenal.
    await _type(tester, 'stock-add', 'zzz');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Produk "zzz" tidak ditemukan.'), findsOneWidget);

    // Ketik nama lalu ketuk saran.
    await _type(tester, 'stock-add', 'tel');
    await _tap(tester, 'stock-add-suggest-$telur');
    expect(find.byKey(ValueKey('stock-line-$telur')), findsOneWidget);

    await _type(tester, 'stock-physical-$telur-0', '12,2');
    expect(find.text('-0,3'), findsOneWidget);
    expect(find.text('-Rp 7.650'), findsWidgets);
    await _type(tester, 'stock-line-note-$telur-0', 'Pecah');

    await _tap(tester, 'stock-save');
    final (_, reason, lines, _) = repo.saves.single;
    expect(reason, StockAdjustmentReason.routineCheck);
    // Kopi tanpa fisik tidak ikut.
    expect(lines.single.variantId.uuid, telur);
    expect(lines.single.physical, const Qty(12200));
    expect(lines.single.note, 'Pecah');
    expect(
      find.text('Penyesuaian SA-PST-K01-261103-0001 tersimpan.'),
      findsOneWidget,
    );
    expect(find.text('SA-PST-K01-261103-0002 · Yusuf'), findsOneWidget);
    expect(find.byKey(const ValueKey('stock-lines-empty')), findsOneWidget);
    // Daftar penyesuaian terakhir.
    expect(find.byKey(const ValueKey('stock-recent-0')), findsOneWidget);
  });

  testWidgets('galat simpan tampil dan draf tetap', (tester) async {
    final repo = await pump(tester);
    await _type(tester, 'stock-add', '8990001');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await _type(tester, 'stock-physical-$kopi-0', '2');
    repo.nextError = const StockAdjustmentInvalid(
      StockAdjustmentError.noChange,
    );
    await _tap(tester, 'stock-save');
    expect(
      find.text('Tidak ada selisih: stok fisik sama dengan stok sistem.'),
      findsOneWidget,
    );
    expect(find.byKey(ValueKey('stock-line-$kopi')), findsOneWidget);
  });

  testWidgets('tab daftar, minimum, kartu stok, dan lokasi', (tester) async {
    await pump(tester);

    await _tap(tester, 'stock-tab-list');
    expect(find.byKey(ValueKey('stock-row-$sabun')), findsOneWidget);
    expect(find.text('Di bawah minimum'), findsNWidgets(2));
    await _type(tester, 'stock-search', 'sabun');
    expect(find.byKey(ValueKey('stock-row-$kopi')), findsNothing);

    await _tap(tester, 'stock-tab-minimum');
    expect(find.byKey(ValueKey('stock-min-$kopi')), findsOneWidget);
    expect(find.text('2 / 20'), findsOneWidget);
    expect(find.text('12,5 / 15'), findsOneWidget);

    // Ketuk baris minimum membuka kartu stok produk itu.
    await _tap(tester, 'stock-min-$telur');
    expect(find.text('Stok sekarang 12,5 · minimum 15'), findsOneWidget);
    expect(find.text('Belum ada pergerakan.'), findsOneWidget);

    await _tap(tester, 'stock-tab-locations');
    expect(find.text('Etalase'), findsWidgets);
    await _type(tester, 'stock-location-new', 'Gudang');
    await _tap(tester, 'stock-location-add');
    expect(find.text('Gudang'), findsWidgets);
    await _type(tester, 'stock-location-new', 'gudang');
    await _tap(tester, 'stock-location-add');
    expect(
      find.text('Nama lokasi sudah dipakai di cabang ini.'),
      findsOneWidget,
    );

    final gudang = fakeId(102).uuid;
    await _tap(tester, 'stock-location-rename-$gudang');
    await _type(tester, 'stock-location-edit-$gudang', 'Gudang Belakang');
    await _tap(tester, 'stock-location-save-$gudang');
    expect(find.text('Gudang Belakang'), findsWidgets);
    expect(find.byKey(const ValueKey('stock-location-error')), findsNothing);
  });

  testWidgets('ponsel: tab berupa pil dan baris penyesuaian berupa kartu', (
    tester,
  ) async {
    final repo = await pump(tester, size: const Size(390, 844));
    expect(find.byKey(const ValueKey('stock-pill-adjustment')), findsOneWidget);
    await _type(tester, 'stock-add', 'sabun');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await _type(tester, 'stock-physical-$sabun-0', '14');
    expect(find.text('-1'), findsOneWidget);
    await _tap(tester, 'stock-save');
    expect(repo.saves, hasLength(1));

    await _tap(tester, 'stock-pill-list');
    expect(find.byKey(ValueKey('stock-row-$sabun')), findsOneWidget);
  });

  for (final size in const [Size(820, 1180), Size(1280, 800), Size(360, 740)]) {
    testWidgets('semua tab tampil tanpa luapan di $size', (tester) async {
      await pump(tester, size: size);
      // Lebar konten (bukan layar) menentukan tab atau pil.
      final prefix =
          find.byKey(const ValueKey('stock-pill-list')).evaluate().isEmpty
          ? 'stock-tab'
          : 'stock-pill';
      await _type(tester, 'stock-add', '8990001');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      for (final tab in [
        'list',
        'card',
        'minimum',
        'locations',
        'adjustment',
      ]) {
        await _tap(tester, '$prefix-$tab');
      }
      expect(find.byKey(ValueKey('stock-line-$kopi')), findsOneWidget);
    });
  }

  for (final size in const [Size(1280, 800), Size(360, 740)]) {
    testWidgets('cetak stok ${size.width.toInt()} px (F1-08b)', (tester) async {
      final exporter = FakeSpreadsheetExporter()
        ..path = '/home/kasir/Dokumen/Lakuna/stok-etalase.pdf';
      await pump(tester, size: size, exporter: exporter);
      // Pencarian tidak menyaring cetakan.
      await _tap(
        tester,
        size.width < 600 ? 'stock-pill-list' : 'stock-tab-list',
      );
      await _type(tester, 'stock-search', 'sabun');
      await tester.ensureVisible(find.byKey(const ValueKey('stock-print')));
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const ValueKey('stock-print')));
        await Future<void>.delayed(const Duration(seconds: 2));
      });
      await tester.pumpAndSettle();
      final (name, bytes) = exporter.saved.single;
      expect(name, matches(RegExp(r'^stok-etalase-\d{6}-\d{4}\.pdf$')));
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
      expect(
        find.text(
          'Daftar stok disimpan di /home/kasir/Dokumen/Lakuna/stok-etalase.pdf',
        ),
        findsOneWidget,
      );

      // Galat simpan: pesan galat, tombol aktif lagi.
      exporter.error = Exception('disk penuh');
      await tester.ensureVisible(find.byKey(const ValueKey('stock-print')));
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const ValueKey('stock-print')));
        await Future<void>.delayed(const Duration(seconds: 2));
      });
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('stock-print-failed')), findsOneWidget);
      expect(find.byKey(const ValueKey('stock-print-saved')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in const [Size(1280, 800), Size(360, 740)]) {
    testWidgets('cetak stok + pilihan lokasi ${size.width.toInt()} px, '
        'share sheet tanpa pesan', (tester) async {
      final exporter = FakeSpreadsheetExporter()..path = null;
      await pump(
        tester,
        size: size,
        exporter: exporter,
        stock: FakeStockRepository(
          locations: [
            sampleLocation(1, 'Etalase', true),
            sampleLocation(2, 'Gudang', false),
          ],
        ),
      );
      expect(find.byKey(const ValueKey('stock-print')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('stock-location-select-Etalase|Gudang')),
        findsOneWidget,
      );
      await tester.ensureVisible(find.byKey(const ValueKey('stock-print')));
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const ValueKey('stock-print')));
        await Future<void>.delayed(const Duration(seconds: 2));
      });
      await tester.pumpAndSettle();
      expect(exporter.saved, hasLength(1));
      expect(find.byKey(const ValueKey('stock-print-saved')), findsNothing);
      expect(find.byKey(const ValueKey('stock-print-failed')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('cetak stok mati bila lokasi tanpa barang', (tester) async {
    await pump(tester, stock: FakeStockRepository()..rows = []);
    final button = tester.widget<FButton>(
      find.byKey(const ValueKey('stock-print')),
    );
    expect(button.onPress, isNull);
  });

  testWidgets('tanpa izin stock:adjust: hanya melihat', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final settings = AppSettingsViewModel(
      repository: FakeAppSettingsRepository(),
    );
    await settings.load.execute();
    final repo = FakeStockRepository(canAdjust: false);
    final viewer = StaffProfile(
      id: fakeId(9),
      name: 'Rina',
      roleKey: 'custom',
      isOwner: false,
      hasPin: true,
      permissions: const {Permission.productsManage},
    );
    await tester.pumpWidget(
      LakunaApp(
        settings: settings,
        router: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => StockScreen(
                repository: repo,
                session: FakeSessionRepository()..current = viewer,
                store: FakeStoreRepository(current: sampleStoreContext()),
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('stock-no-permission')), findsOneWidget);
    expect(find.byKey(const ValueKey('stock-add')), findsNothing);
    await _tap(tester, 'stock-tab-locations');
    expect(find.byKey(const ValueKey('stock-location-add')), findsNothing);
  });
}
