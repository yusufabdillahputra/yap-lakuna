import 'dart:async';

import 'package:flutter/rendering.dart';
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
import 'package:lakuna_flutter/ui/products/product_widgets.dart';
import 'package:lakuna_flutter/ui/settings/app_settings_view_model.dart';
import 'package:lakuna_flutter/ui/stock/stock_view.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_app_settings_repository.dart';
import '../../testing/fake_purchases_repository.dart';
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

  group('draf penyesuaian belum disimpan (F1-08k)', () {
    Finder key(String k) => find.byKey(ValueKey(k));
    Finder locationSelect() => find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith(
            'stock-location-select-',
          ),
    );

    Future<void> addKopi(WidgetTester tester) async {
      await _type(tester, 'stock-add', '8990001');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(key('stock-line-$kopi'), findsOneWidget);
    }

    Future<void> chooseLocation(WidgetTester tester, String name) async {
      await tester.ensureVisible(locationSelect());
      await tester.pumpAndSettle();
      await tester.tap(locationSelect());
      await tester.pumpAndSettle();
      await tester.tap(find.text(name).last);
      await tester.pumpAndSettle();
    }

    testWidgets('1280 px: draf kosong keluar langsung; berisi bertanya', (
      tester,
    ) async {
      await pump(tester);
      await _tap(tester, 'nav-products');
      expect(key('stock-discard'), findsNothing);
      expect(key('stock-save'), findsNothing);

      await _tap(tester, 'nav-stock');
      // Baris tanpa fisik sudah dihitung, tab lain pun tetap ditanya.
      await addKopi(tester);
      await _tap(tester, 'stock-tab-list');
      await _tap(tester, 'nav-products');
      expect(key('stock-discard'), findsOneWidget);
      expect(
        find.text(
          'Draf penyesuaian stok yang sedang diisi belum disimpan dan '
          'akan hilang.',
        ),
        findsOneWidget,
      );
      await _tap(tester, 'stock-discard-cancel');
      await _tap(tester, 'stock-tab-adjustment');
      expect(key('stock-line-$kopi'), findsOneWidget);

      // Tombol kembali sistem: rute tingkat atas, go_router tetap
      // memanggil `onExit`.
      final popping = tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(key('stock-discard'), findsOneWidget);
      await _tap(tester, 'stock-discard-cancel');
      await popping;
      expect(key('stock-line-$kopi'), findsOneWidget);

      await _tap(tester, 'nav-products');
      await _tap(tester, 'stock-discard-confirm');
      expect(key('stock-save'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('setelah simpan atau Batal keluar tanpa bertanya; keluar '
        'ditahan selama simpan', (tester) async {
      final repo = await pump(tester);
      await addKopi(tester);
      await _tap(tester, 'stock-clear');
      await _tap(tester, 'nav-products');
      expect(key('stock-discard'), findsNothing);
      expect(key('stock-save'), findsNothing);

      await _tap(tester, 'nav-stock');
      await addKopi(tester);
      await _type(tester, 'stock-physical-$kopi-0', '3');
      final gate = Completer<void>();
      repo.saveGate = gate.future;
      await tester.ensureVisible(key('stock-save'));
      await tester.pumpAndSettle();
      await tester.tap(key('stock-save'));
      await tester.pump();
      await tester.tap(key('nav-products'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(key('stock-discard'), findsNothing);
      expect(key('stock-save'), findsOneWidget);
      gate.complete();
      await tester.pumpAndSettle();
      expect(repo.saves, hasLength(1));
      await _tap(tester, 'nav-products');
      expect(key('stock-discard'), findsNothing);
      expect(key('stock-save'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ganti lokasi dengan draf: Batal tetap, Buang pindah', (
      tester,
    ) async {
      await pump(
        tester,
        stock: FakeStockRepository(
          locations: [
            sampleLocation(1, 'Etalase', true),
            sampleLocation(2, 'Gudang', false),
          ],
        ),
      );
      // Tanpa draf: langsung pindah.
      await chooseLocation(tester, 'Gudang');
      expect(key('stock-location-discard'), findsNothing);
      expect(
        find.descendant(of: locationSelect(), matching: find.text('Gudang')),
        findsOneWidget,
      );
      await chooseLocation(tester, 'Etalase');

      await addKopi(tester);
      await chooseLocation(tester, 'Gudang');
      expect(key('stock-location-discard'), findsOneWidget);
      expect(
        find.text(
          'Draf penyesuaian untuk lokasi ini akan dikosongkan bila lokasi '
          'diganti.',
        ),
        findsOneWidget,
      );
      await _tap(tester, 'stock-location-discard-cancel');
      expect(key('stock-line-$kopi'), findsOneWidget);
      expect(
        find.descendant(of: locationSelect(), matching: find.text('Etalase')),
        findsOneWidget,
      );

      await chooseLocation(tester, 'Gudang');
      await _tap(tester, 'stock-location-discard-confirm');
      expect(key('stock-line-$kopi'), findsNothing);
      expect(key('stock-lines-empty'), findsOneWidget);
      expect(
        find.descendant(of: locationSelect(), matching: find.text('Gudang')),
        findsOneWidget,
      );
      // Draf kosong: keluar tanpa bertanya.
      await _tap(tester, 'nav-products');
      expect(key('stock-discard'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('360 px: menu bawah bertanya', (tester) async {
      await pump(tester, size: const Size(360, 740));
      await addKopi(tester);
      await _tap(tester, 'nav-home');
      expect(key('stock-discard'), findsOneWidget);
      await _tap(tester, 'stock-discard-cancel');
      expect(key('stock-line-$kopi'), findsOneWidget);
      await _tap(tester, 'nav-home');
      await _tap(tester, 'stock-discard-confirm');
      expect(key('stock-line-$kopi'), findsNothing);
      expect(tester.takeException(), isNull);
    });
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

  /// Stok minimum yang varian-variannya ada di katalog pembelian palsu.
  (FakeStockRepository, FakePurchasesRepository) restockSeed() {
    final purchases = FakePurchasesRepository();
    final variants = [
      for (final p in purchases.products)
        for (final v in p.variants) (p, v),
    ];
    StockRow row(int i, Qty stock, Qty min) => StockRow(
      variantId: variants[i].$2.id,
      productId: variants[i].$1.id,
      productName: variants[i].$1.name,
      variantName: '',
      baseUnit: 'pcs',
      stock: stock,
      minStock: min,
      unitCost: variants[i].$2.costPrice,
    );
    for (final (_, v) in variants.take(2)) {
      purchases.lastSupplierOf[v.id] = (
        supplierId: purchases.suppliers.single.id,
        at: DateTime.utc(2026, 11, 1),
      );
    }
    // Harga beli terakhir hanya untuk barang pertama (F1-08e).
    purchases.lastPriceOf[variants[0].$2.id] = const Money(31500);
    final stock = FakeStockRepository(
      // Lokasi sama dengan Pembelian agar draf per lokasi cocok (F1-08g).
      locations: purchases.locations,
      rows: [
        row(0, Qty.units(2), Qty.units(20)),
        row(1, Qty.units(1), Qty.units(3)),
      ],
    );
    return (stock, purchases);
  }

  for (final size in const [Size(1280, 800), Size(360, 740)]) {
    testWidgets('buat pembelian dari stok minimum ${size.width.toInt()} px '
        '(F1-08c)', (tester) async {
      final (stock, purchases) = restockSeed();
      await pumpLakuna(
        tester,
        size: size,
        initialLocation: Routes.stock,
        stock: stock,
        purchases: purchases,
        session: FakeSessionRepository()..current = sampleStaff(),
      );
      await _tap(
        tester,
        size.width < 600 ? 'stock-pill-minimum' : 'stock-tab-minimum',
      );
      await _tap(tester, 'stock-restock');
      expect(find.byKey(const ValueKey('purchase-form-page')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('purchase-restock-note')),
        findsOneWidget,
      );
      expect(
        find.text(
          // Lokasi Etalase (stok palsu) tidak ada di pembelian palsu: catatan
          // menyebut lokasi yang dipakai form.
          'Diisi dari stok minimum Toko: 2 barang. Periksa jumlah dan '
          'harga sebelum menyimpan.',
        ),
        findsOneWidget,
      );
      // Supplier terakhir (F1-08d) dipilih dan disebut di catatan.
      expect(
        find.text(
          'Supplier diisi dari pembelian terakhir: CV Sumber Pangan '
          '(2 dari 2 barang).',
        ),
        findsOneWidget,
      );
      // Jumlah saran: 2 × 20 − 2 = 38 dan 2 × 3 − 1 = 5.
      final qty = find.descendant(
        of: find.byKey(const ValueKey('purchase-form-page')),
        matching: find.byType(EditableText),
      );
      final texts = [
        for (final e in tester.widgetList<EditableText>(qty)) e.controller.text,
      ];
      expect(texts, containsAll(['38', '5']));
      // Harga baris pertama dari pembelian terakhir (F1-08e).
      expect(
        find.text('Harga diisi dari pembelian terakhir untuk 1 dari 2 barang.'),
        findsOneWidget,
      );
      expect(
        texts.map((t) => t.replaceAll('.', '').replaceAll(',', '')),
        contains('31500'),
      );

      // Kembali ke Stok: daftar dimuat ulang (stok sudah bertambah).
      stock.rows = [
        for (final r in stock.rows)
          StockRow(
            variantId: r.variantId,
            productId: r.productId,
            productName: r.productName,
            variantName: r.variantName,
            baseUnit: r.baseUnit,
            stock: r.minStock + r.minStock,
            minStock: r.minStock,
            unitCost: r.unitCost,
          ),
      ];
      await _tap(tester, 'purchase-back');
      expect(find.byKey(const ValueKey('stock-minimum')), findsOneWidget);
      expect(find.byKey(const ValueKey('stock-restock')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('buat pembelian lagi setelah keluar lewat menu samping '
      '(F1-08f)', (tester) async {
    final (stock, purchases) = restockSeed();
    await pumpLakuna(
      tester,
      initialLocation: Routes.stock,
      stock: stock,
      purchases: purchases,
      session: FakeSessionRepository()..current = sampleStaff(),
    );
    await _tap(tester, 'stock-tab-minimum');
    await _tap(tester, 'stock-restock');
    expect(find.byKey(const ValueKey('purchase-form-page')), findsOneWidget);

    // Stok bertambah di tempat lain, lalu staf kembali lewat menu samping
    // (bukan tombol Kembali).
    stock.rows = [
      for (final r in stock.rows)
        StockRow(
          variantId: r.variantId,
          productId: r.productId,
          productName: r.productName,
          variantName: r.variantName,
          baseUnit: r.baseUnit,
          stock: r == stock.rows.first ? r.minStock + r.minStock : r.stock,
          minStock: r.minStock,
          unitCost: r.unitCost,
        ),
    ];
    await _tap(tester, 'nav-stock');
    expect(find.byKey(const ValueKey('purchase-form-page')), findsNothing);
    // Daftar dimuat ulang: tinggal satu barang di bawah minimum.
    await _tap(tester, 'stock-tab-minimum');
    final rows = find.descendant(
      of: find.byKey(const ValueKey('stock-minimum')),
      matching: find.byType(StockPill),
    );
    expect(rows, findsOneWidget);
    // Tombol tetap bisa membuka form lagi.
    await _tap(tester, 'stock-restock');
    expect(find.byKey(const ValueKey('purchase-form-page')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('draf penyesuaian tetap ada setelah membuka form pembelian dari '
      'stok minimum (F1-08k)', (tester) async {
    final (stock, purchases) = restockSeed();
    await pumpLakuna(
      tester,
      initialLocation: Routes.stock,
      stock: stock,
      purchases: purchases,
      session: FakeSessionRepository()..current = sampleStaff(),
    );
    final first = stock.rows.first;
    await _type(tester, 'stock-add', first.productName);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    final line = ValueKey('stock-line-${first.variantId.uuid}');
    expect(find.byKey(line), findsOneWidget);

    await _tap(tester, 'stock-tab-minimum');
    await _tap(tester, 'stock-restock');
    expect(find.byKey(const ValueKey('purchase-form-page')), findsOneWidget);
    expect(find.byKey(const ValueKey('stock-discard')), findsNothing);

    // Kembali ke Stok lewat menu samping: hanya form pembelian yang keluar.
    await _tap(tester, 'nav-stock');
    if (find.byKey(const ValueKey('purchase-discard')).evaluate().isNotEmpty) {
      await _tap(tester, 'purchase-discard-confirm');
    }
    expect(find.byKey(const ValueKey('purchase-form-page')), findsNothing);
    expect(find.byKey(const ValueKey('stock-discard')), findsNothing);
    await _tap(tester, 'stock-tab-adjustment');
    expect(find.byKey(line), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ketukan ganda saat form dibuka hanya membuka satu form '
      '(F1-08f)', (tester) async {
    final (stock, purchases) = restockSeed();
    await pumpLakuna(
      tester,
      initialLocation: Routes.stock,
      stock: stock,
      purchases: purchases,
      session: FakeSessionRepository()..current = sampleStaff(),
    );
    await _tap(tester, 'stock-tab-minimum');
    final restock = find.byKey(const ValueKey('stock-restock'));
    // Dua ketukan sebelum frame berikutnya; setelah itu halaman Stok
    // tertutup form dan tidak menerima ketukan lagi.
    await tester.tap(restock);
    await tester.tap(restock);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('purchase-form-page')), findsOneWidget);
    // Kembali sekali langsung ke Stok: tidak ada form kedua di bawahnya.
    await _tap(tester, 'purchase-back');
    expect(find.byKey(const ValueKey('purchase-form-page')), findsNothing);
    expect(find.byKey(const ValueKey('stock-minimum')), findsOneWidget);
  });

  /// Draf berisi barang pertama di bawah minimum (F1-08g).
  Future<Purchase> seedDraft(FakePurchasesRepository purchases) async {
    final first = purchases.products.first.variants.first;
    final saved = await purchases.saveDraft(
      PurchaseRequest(
        purchasedOn: DateTime(2026, 11, 2),
        locationId: purchases.locations.first.id,
        lines: [
          PurchaseLineRequest(
            variantId: first.id,
            quantity: Qty.units(5),
            unitPrice: const Money(30000),
          ),
        ],
      ),
    );
    return (saved as Ok<Purchase>).value;
  }

  for (final size in const [Size(1280, 800), Size(360, 740)]) {
    testWidgets('draf berisi barang yang sama: buka draf, buat baru, batal '
        '${size.width.toInt()} px (F1-08g)', (tester) async {
      final (stock, purchases) = restockSeed();
      final draft = await seedDraft(purchases);
      await pumpLakuna(
        tester,
        size: size,
        initialLocation: Routes.stock,
        stock: stock,
        purchases: purchases,
        session: FakeSessionRepository()..current = sampleStaff(),
      );
      final tab = size.width < 600 ? 'stock-pill-minimum' : 'stock-tab-minimum';
      await _tap(tester, tab);
      await _tap(tester, 'stock-restock');
      expect(find.byKey(const ValueKey('stock-restock-draft')), findsOneWidget);
      final dialog = find.byKey(const ValueKey('stock-restock-draft'));
      expect(
        find.descendant(
          of: dialog,
          matching: find.textContaining(draft.number),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('1 dari 2 barang'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Batal: tidak ada form.
      await _tap(tester, 'stock-restock-cancel');
      expect(find.byKey(const ValueKey('stock-restock-draft')), findsNothing);
      expect(find.byKey(const ValueKey('purchase-form-page')), findsNothing);

      // Buka draf: form draf itu, barang yang belum ada ditambahkan
      // (F1-08i).
      await _tap(tester, 'stock-restock');
      await _tap(tester, 'stock-restock-open-draft');
      expect(find.byKey(const ValueKey('purchase-form-page')), findsOneWidget);
      expect(find.textContaining(draft.number), findsWidgets);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('purchase-restock-note')),
          matching: find.textContaining(
            '1 barang ditambahkan ke draf ini, 1 barang sudah ada',
          ),
        ),
        findsOneWidget,
      );
      // Baris draf + satu barang stok minimum yang belum ada.
      expect(
        find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('purchase-qty-'),
        ),
        findsNWidgets(2),
      );
      expect(tester.takeException(), isNull);
      // Tambahan belum disimpan: Kembali bertanya dulu (F1-12f).
      await _tap(tester, 'purchase-back');
      expect(find.byKey(const ValueKey('purchase-discard')), findsOneWidget);
      await _tap(tester, 'purchase-discard-confirm');
      if (size.width < 600) await _tap(tester, tab);

      // Buat draf baru: form terisi dari stok minimum seperti biasa.
      await _tap(tester, 'stock-restock');
      await _tap(tester, 'stock-restock-new');
      expect(
        find.byKey(const ValueKey('purchase-restock-note')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('kembali lewat menu saat draf dicari: ketukan kedua tetap '
      'diabaikan (F1-08g)', (tester) async {
    final (stock, purchases) = restockSeed();
    await seedDraft(purchases);
    await pumpLakuna(
      tester,
      initialLocation: Routes.stock,
      stock: stock,
      purchases: purchases,
      session: FakeSessionRepository()..current = sampleStaff(),
    );
    await _tap(tester, 'stock-tab-minimum');
    // Pencarian draf menunggu gerbang (muat daftar stok juga, F1-08h).
    final gate = purchases.restockDraftsGate = Completer<void>();
    await tester.tap(find.byKey(const ValueKey('stock-restock')));
    await tester.pump();
    // Router membangun ulang halaman Stok selagi draf masih dicari.
    await _tap(tester, 'nav-stock');
    await _tap(tester, 'stock-tab-minimum');
    await tester.tap(find.byKey(const ValueKey('stock-restock')));
    await tester.pump();
    gate.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('stock-restock-draft')), findsOneWidget);
    await _tap(tester, 'stock-restock-cancel');
    expect(find.byKey(const ValueKey('stock-restock-draft')), findsNothing);
    expect(find.byKey(const ValueKey('stock-minimum')), findsOneWidget);
  });

  for (final size in const [Size(1280, 800), Size(360, 740)]) {
    testWidgets('tanda sudah di draf di stok minimum '
        '${size.width.toInt()} px (F1-08h)', (tester) async {
      final (stock, purchases) = restockSeed();
      final draft = await seedDraft(purchases);
      final vs = [
        for (final p in purchases.products) ...p.variants,
      ];
      // Baris pertama di draf, baris kedua tidak.
      final inDraft = vs[0].id;
      final other = vs[1].id;
      await pumpLakuna(
        tester,
        size: size,
        initialLocation: Routes.stock,
        stock: stock,
        purchases: purchases,
        session: FakeSessionRepository()..current = sampleStaff(),
      );
      await _tap(
        tester,
        size.width < 600 ? 'stock-pill-minimum' : 'stock-tab-minimum',
      );
      expect(
        tester
            .widget<Text>(
              find.byKey(ValueKey('stock-min-draft-${inDraft.uuid}')),
            )
            .data,
        'Sudah di draf ${draft.number}',
      );
      // Nomor draf utuh, tidak terpotong elipsis di ponsel.
      final paragraph = tester.renderObject<RenderParagraph>(
        find.byKey(ValueKey('stock-min-draft-${inDraft.uuid}')),
      );
      expect(paragraph.didExceedMaxLines, isFalse);
      expect(paragraph.maxLines, isNull);
      expect(
        find.byKey(ValueKey('stock-min-draft-${other.uuid}')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('barang di draf lain tidak ditambahkan ke draf yang dibuka '
      '(F1-08i)', (tester) async {
    final (stock, purchases) = restockSeed();
    final vs = [for (final p in purchases.products) ...p.variants];
    // Draf A berisi barang pertama, draf B (lebih baru) barang kedua.
    for (final v in [vs[0], vs[1]]) {
      await purchases.saveDraft(
        PurchaseRequest(
          purchasedOn: DateTime(2026, 11, 2),
          locationId: purchases.locations.first.id,
          lines: [
            PurchaseLineRequest(
              variantId: v.id,
              quantity: Qty.units(5),
              unitPrice: const Money(30000),
            ),
          ],
        ),
      );
    }
    await pumpLakuna(
      tester,
      initialLocation: Routes.stock,
      stock: stock,
      purchases: purchases,
      session: FakeSessionRepository()..current = sampleStaff(),
    );
    await _tap(tester, 'stock-tab-minimum');
    await _tap(tester, 'stock-restock');
    await _tap(tester, 'stock-restock-open-draft');
    expect(find.byKey(const ValueKey('purchase-form-page')), findsOneWidget);
    // Barang pertama sudah dipesan di draf A: draf B tidak bertambah.
    expect(
      find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('purchase-qty-'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('purchase-restock-note')),
        matching: find.textContaining('sudah ada di draf ini'),
      ),
      findsOneWidget,
    );
  });

  for (final size in const [Size(1280, 800), Size(360, 740)]) {
    testWidgets('ganti satuan baris saran: 38 botol → 7 dus '
        '${size.width.toInt()} px (F1-08j)', (tester) async {
      final (stock, purchases) = restockSeed();
      await pumpLakuna(
        tester,
        size: size,
        initialLocation: Routes.stock,
        stock: stock,
        purchases: purchases,
        session: FakeSessionRepository()..current = sampleStaff(),
      );
      await _tap(
        tester,
        size.width < 600 ? 'stock-pill-minimum' : 'stock-tab-minimum',
      );
      await _tap(tester, 'stock-restock');
      Finder keyed(String prefix) => find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith(prefix),
      );
      String qtyText() => tester
          .widget<EditableText>(
            find.descendant(
              of: keyed('purchase-qty-').first,
              matching: find.byType(EditableText),
            ),
          )
          .controller
          .text;
      expect(qtyText(), '38');
      final unit = keyed('purchase-unit-').first;
      await tester.ensureVisible(unit);
      await tester.pumpAndSettle();
      await tester.tap(unit);
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Dus').last);
      await tester.pumpAndSettle();
      expect(qtyText(), '7');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('galat baca draf: langsung buka form baru (F1-08g)', (
    tester,
  ) async {
    final (stock, purchases) = restockSeed();
    await seedDraft(purchases);
    purchases.restockDraftsError = Exception('baca gagal');
    await pumpLakuna(
      tester,
      initialLocation: Routes.stock,
      stock: stock,
      purchases: purchases,
      session: FakeSessionRepository()..current = sampleStaff(),
    );
    await _tap(tester, 'stock-tab-minimum');
    await _tap(tester, 'stock-restock');
    expect(find.byKey(const ValueKey('stock-restock-draft')), findsNothing);
    expect(find.byKey(const ValueKey('purchase-restock-note')), findsOneWidget);
  });

  testWidgets('tanpa izin pembelian: tombol buat pembelian dan tanda draf '
      'tidak tampil (F1-08h)', (tester) async {
    final (stock, purchases) = restockSeed();
    await seedDraft(purchases);
    final keeper = sampleStaff(role: 'stock_keeper');
    await pumpLakuna(
      tester,
      size: const Size(1280, 800),
      initialLocation: Routes.stock,
      stock: stock,
      purchases: purchases,
      session: FakeSessionRepository()
        ..current = StaffProfile(
          id: keeper.id,
          name: keeper.name,
          roleKey: 'custom',
          isOwner: false,
          hasPin: true,
          permissions: {Permission.stockAdjust},
        ),
    );
    await _tap(tester, 'stock-tab-minimum');
    expect(find.byKey(const ValueKey('stock-minimum')), findsOneWidget);
    expect(find.byKey(const ValueKey('stock-restock')), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) => '${w.key}'.contains('stock-min-draft-'),
      ),
      findsNothing,
    );
    expect(purchases.restockDraftsCalls, 0);
  });

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
