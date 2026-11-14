import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart' show CustomerGroup, UuidValue;
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/image_file_picker.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_catalog_repository.dart';
import '../../testing/fake_payment_settings_repository.dart';
import '../../testing/fake_receipt_printer.dart';
import '../../testing/fake_session_repository.dart';
import '../../testing/floor_seed.dart';
import '../../testing/modifier_seed.dart';
import 'product_list_view_model_test.dart' show sampleProducts;

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
  Future<FakeCatalogRepository> pump(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
    List<ProductDraft>? seed,
    String location = Routes.products,
    String role = 'owner',
    List<CustomerGroup> groups = const [],
    FakeReceiptPrinter? printer,
    FakeImagePicker? picker,
  }) async {
    final repo = FakeCatalogRepository(seed: seed)..customerGroups = groups;
    await pumpLakuna(
      tester,
      size: size,
      initialLocation: location,
      catalog: repo,
      session: FakeSessionRepository()..current = sampleStaff(role: role),
      receiptPrinter: printer,
      imagePicker: picker,
    );
    return repo;
  }

  testWidgets('daftar kosong lalu tambah produk dengan satuan dan grosir', (
    tester,
  ) async {
    final repo = await pump(tester);
    expect(find.byKey(const ValueKey('products-empty')), findsOneWidget);
    expect(
      find.text('0 produk aktif · 0 di bawah stok minimum'),
      findsOneWidget,
    );

    await _tap(tester, 'products-empty-add');
    expect(find.text('Produk baru'), findsWidgets);

    await _tap(tester, 'product-save');
    expect(find.byKey(const ValueKey('product-fix-errors')), findsOneWidget);
    expect(find.text('Wajib diisi'), findsWidgets);
    expect(repo.saved, isEmpty);

    await _type(tester, 'product-name', 'Minyak Goreng');
    await _type(tester, 'product-category', 'Sembako');
    await _type(tester, 'product-base-unit', 'botol');
    await _type(tester, 'variant-0-sku', 'MYK-2L');
    await _type(tester, 'variant-0-cost', '32500');
    await _type(tester, 'variant-0-price', '36000');
    expect(find.text('36.000'), findsOneWidget);
    await _type(tester, 'variant-0-min', '12');
    await _type(tester, 'variant-0-opening', '24');

    await _tap(tester, 'product-tab-units');
    await _tap(tester, 'product-add-unit');
    await _type(tester, 'unit-1-name', 'dus');
    await _type(tester, 'unit-1-factor', '6');
    await _type(tester, 'unit-1-price', '210000');

    await _tap(tester, 'product-tab-tiers');
    await _tap(tester, 'product-add-tier');
    await _type(tester, 'tier-2-qty', '6');
    await _type(tester, 'tier-2-price', '35000');

    await _tap(tester, 'product-save');
    final saved = repo.saved.single;
    expect(saved.name, 'Minyak Goreng');
    expect(saved.category, 'Sembako');
    final v = saved.variants.single;
    expect(v.sellPrice, const Money(36000));
    expect(v.openingStock, Qty.units(24));
    expect(v.units.single.factor, Qty.units(6));
    expect(v.units.single.sellPrice, const Money(210000));
    expect(v.tiers.single.minQty, Qty.units(6));

    // Kembali ke daftar yang memuat ulang katalog.
    expect(find.text('Produk & stok'), findsWidgets);
    expect(find.text('Minyak Goreng'), findsOneWidget);
    expect(find.text('botol · dus (6)'), findsOneWidget);
    expect(find.text('≥6: Rp 35.000'), findsOneWidget);
    expect(find.text('Rp 36.000'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
  });

  for (final size in const [Size(1280, 800), Size(360, 760)]) {
    testWidgets('grosir untuk grup pelanggan (F1-07c) ${size.width}', (
      tester,
    ) async {
      final reseller = CustomerGroup(
        id: UuidValue.fromString(newId()),
        tenantId: UuidValue.fromString(newId()),
        name: 'Reseller',
        hlc: '',
      );
      final repo = await pump(tester, size: size, groups: [reseller]);
      await _tap(tester, 'products-empty-add');
      await _type(tester, 'product-name', 'Gula Pasir');
      await _type(tester, 'product-base-unit', 'kg');
      await _type(tester, 'variant-0-price', '16000');
      await _tap(tester, 'product-tab-tiers');
      await _tap(tester, 'product-add-tier');
      await _type(tester, 'tier-1-qty', '1');
      await _type(tester, 'tier-1-price', '15500');
      expect(find.text('Semua pelanggan'), findsWidgets);
      await _tap(tester, 'tier-1-group');
      await tester.tap(find.text('Reseller').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await _tap(tester, 'product-save');
      expect(
        repo.saved.single.variants.single.tiers.single.groupId,
        reseller.id.uuid,
      );
    });
  }

  for (final size in const [Size(1280, 800), Size(360, 760)]) {
    testWidgets('arsip dan pulihkan produk (F1-07d) ${size.width}', (
      tester,
    ) async {
      final repo = await pump(tester, size: size, seed: sampleProducts());
      expect(find.byKey(const ValueKey('products-archived')), findsNothing);
      final minyak = repo.products.firstWhere((p) => p.name == 'Minyak Goreng');
      final row = size.width < 600 ? 'product-card' : 'product-row';
      // Ponsel: kartu paling atas agar tidak tertutup tombol mengambang.
      await _type(tester, 'products-search', 'minyak');
      await _tap(tester, '$row-${minyak.id.uuid}');
      await _tap(tester, 'product-archive');
      expect(find.text('Arsipkan Minyak Goreng?'), findsOneWidget);
      expect(
        find.text(
          'Stok tersisa 24 botol tidak dihitung lagi di stok dan nilai stok.',
        ),
        findsOneWidget,
      );
      await _tap(tester, 'product-archive-cancel');
      expect(repo.archiveCalls, isEmpty);
      await _tap(tester, 'product-archive');
      await _tap(tester, 'product-archive-ok');

      expect(repo.archiveCalls, [minyak.id]);
      expect(tester.takeException(), isNull);

      // Kembali ke daftar: produk hilang, tombol arsip tampil.
      expect(find.text('Minyak Goreng'), findsNothing);
      await _tap(tester, 'products-archived');
      expect(find.text('Produk diarsipkan'), findsOneWidget);
      expect(find.text('Minyak Goreng'), findsOneWidget);
      expect(find.text('Sembako · Stok 24 botol'), findsOneWidget);
      await _tap(tester, 'archived-restore-${minyak.id.uuid}');
      expect(
        find.text('Minyak Goreng dipulihkan ke daftar produk.'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('archived-empty')), findsOneWidget);
      await _tap(tester, 'archived-close');
      expect(find.text('Minyak Goreng'), findsOneWidget);
      expect(find.byKey(const ValueKey('products-archived')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in const [Size(1280, 800), Size(360, 760)]) {
    testWidgets('cetak label barcode dari daftar (F1-07e) ${size.width}', (
      tester,
    ) async {
      final printer = FakeReceiptPrinter();
      final repo = await pump(
        tester,
        size: size,
        seed: sampleProducts(),
        printer: printer,
      );
      await _tap(tester, 'products-labels');
      expect(find.text('Cetak label barcode'), findsWidgets);
      expect(find.text('Tanpa barcode/SKU · Rp 5.000'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('labels-preview-empty')),
        findsOneWidget,
      );
      final kopi = repo.products.firstWhere((p) => p.name == 'Kopi Sachet');
      final kopiKey = kopi.variants.single.id.uuid;
      await _tap(tester, 'labels-check-$kopiKey');
      await _tap(tester, 'labels-more-$kopiKey');
      await _tap(tester, 'labels-more-$kopiKey');
      expect(find.text('3 label · 1 halaman'), findsWidgets);
      expect(find.byKey(const ValueKey('labels-preview')), findsOneWidget);
      await _tap(tester, 'labels-fill-stock');
      expect(find.text('2 label · 1 halaman'), findsWidgets);
      await _type(tester, 'labels-qty-$kopiKey-3', '0');
      expect(find.text('1 label · 1 halaman'), findsWidgets);
      await _type(tester, 'labels-qty-$kopiKey-4', '30');
      expect(find.text('30 label · 2 halaman'), findsWidgets);
      await _tap(tester, 'labels-paper-roll50x30');
      expect(find.byKey(const ValueKey('labels-skip')), findsNothing);
      expect(find.text('30 label · 30 halaman'), findsWidgets);
      await _tap(
        tester,
        size.width < 600 ? 'labels-bar-print' : 'labels-print',
      );
      expect(printer.documentPrints.single.$2, 'Label barcode');
      expect(
        find.byKey(const ValueKey('labels-bar')),
        size.width < 600 ? findsOneWidget : findsNothing,
      );
      await _tap(tester, 'labels-save');
      expect(printer.documentShares, hasLength(1));
      expect(find.byKey(const ValueKey('labels-saved')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _tap(tester, 'labels-back');
      expect(find.byKey(const ValueKey('labels-list')), findsNothing);
      expect(find.byKey(const ValueKey('products-labels')), findsOneWidget);
    });
  }

  for (final size in const [Size(1280, 800), Size(360, 760)]) {
    testWidgets('cetak label dari form produk memilih produk itu '
        '${size.width}', (tester) async {
      final repo = await pump(tester, size: size, seed: sampleProducts());
      final minyak = repo.products.firstWhere(
        (p) => p.name == 'Minyak Goreng',
      );
      final row = size.width < 600 ? 'product-card' : 'product-row';
      await _type(tester, 'products-search', 'minyak');
      await _tap(tester, '$row-${minyak.id.uuid}');
      await _tap(tester, 'product-labels');
      expect(find.text('2 label · 1 halaman'), findsWidgets);
      expect(find.text('Hanya yang dipilih (2)'), findsOneWidget);
      // Hanya baris terpilih yang tampil.
      expect(find.text('Kopi Sachet'), findsNothing);
      expect(find.text('899100 · Rp 216.000'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in const [Size(1280, 800), Size(360, 760)]) {
    testWidgets('foto produk: pilih, simpan, tampil di daftar (F1-07f) '
        '${size.width}', (tester) async {
      final picker = FakeImagePicker()..camera = size.width < 600;
      final repo = await pump(
        tester,
        size: size,
        seed: sampleProducts(),
        picker: picker,
      );
      final kopi = repo.products.firstWhere((p) => p.name == 'Kopi Sachet');
      final row = size.width < 600 ? 'product-card' : 'product-row';
      await _type(tester, 'products-search', 'kopi');
      await _tap(tester, '$row-${kopi.id.uuid}');
      expect(find.text('Pilih foto'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('product-photo-take')),
        size.width < 600 ? findsOneWidget : findsNothing,
      );
      expect(find.byKey(const ValueKey('product-photo-remove')), findsNothing);

      picker.next = PickedImage(
        name: 'catatan.png',
        size: 4,
        bytes: Uint8List.fromList([1, 2, 3, 4]),
      );
      await _tap(tester, 'product-photo-pick');
      expect(
        find.text('Berkas bukan gambar PNG, JPG, atau WebP.'),
        findsOneWidget,
      );
      picker.next = PickedImage(
        name: 'kopi.png',
        size: samplePng.length,
        bytes: samplePng,
      );
      await _tap(tester, 'product-photo-pick');
      expect(find.text('Ganti foto'), findsOneWidget);
      expect(find.byKey(const ValueKey('product-photo-remove')), findsOne);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('product-photo')),
          matching: find.byType(Image),
        ),
        findsOneWidget,
      );
      await _tap(tester, 'product-save');
      expect(repo.photoCalls.single.$2!.fileName, 'kopi.png');
      // Daftar memuat ulang: Kopi Sachet kini berfoto (berkas palsu tidak
      // ada, jadi tampil inisial lewat errorBuilder tanpa galat).
      expect(
        repo.products.firstWhere((p) => p.id == kopi.id).photoPath,
        '/media/kopi.png',
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('buat barcode EAN-13 toko di varian (F1-07h)', (tester) async {
    final repo = await pump(tester, location: Routes.productNew);
    await _type(tester, 'product-name', 'Kue Lapis');
    await _type(tester, 'product-base-unit', 'pcs');
    await _type(tester, 'variant-0-price', '5000');
    await _tap(tester, 'variant-0-barcode-generate');
    final text = tester.widget<EditableText>(_input('variant-0-barcode'));
    final code = text.controller.text;
    expect(code, hasLength(13));
    expect(code, startsWith('20'));
    expect(
      find.byKey(const ValueKey('variant-0-barcode-generate')),
      findsNothing,
    );
    await _tap(tester, 'product-save');
    expect(repo.saved.single.variants.single.barcode, code);
  });

  testWidgets('tombol buat barcode hilang saat barcode diketik', (
    tester,
  ) async {
    await pump(tester, location: Routes.productNew);
    expect(
      find.byKey(const ValueKey('variant-0-barcode-generate')),
      findsOneWidget,
    );
    await _type(tester, 'variant-0-barcode', '899');
    expect(
      find.byKey(const ValueKey('variant-0-barcode-generate')),
      findsNothing,
    );
  });

  testWidgets('kode kembar ditandai dan tab varian dibuka', (tester) async {
    final repo = await pump(
      tester,
      seed: sampleProducts(),
      location: Routes.productNew,
    );
    await _type(tester, 'product-name', 'Kopi Lain');
    await _type(tester, 'product-base-unit', 'pcs');
    await _type(tester, 'variant-0-sku', 'kop-sch');
    await _tap(tester, 'product-save');
    expect(find.text('Sudah dipakai Kopi Sachet'), findsOneWidget);
    expect(repo.saved, isEmpty);
  });

  testWidgets('ubah produk dari daftar, cari, dan filter kategori', (
    tester,
  ) async {
    final repo = await pump(tester, seed: sampleProducts());
    expect(
      find.text('2 produk aktif · 1 di bawah stok minimum'),
      findsOneWidget,
    );
    await _type(tester, 'products-search', 'kopi');
    expect(find.text('Minyak Goreng'), findsNothing);
    expect(find.text('Kopi Sachet'), findsOneWidget);
    await _type(tester, 'products-search', '');

    final minyak = repo.products.firstWhere((p) => p.name == 'Minyak Goreng');
    await _tap(tester, 'product-row-${minyak.id.uuid}');
    expect(find.text('Edit produk · Minyak Goreng'), findsOneWidget);
    // Varian lama tidak punya kolom stok awal.
    expect(find.byKey(const ValueKey('variant-0-opening')), findsNothing);
    await _type(tester, 'variant-0-price', '37000');
    await _tap(tester, 'product-save');
    expect(repo.saved.single.variants.single.sellPrice, const Money(37000));
    expect(find.text('Rp 37.000'), findsOneWidget);
  });

  testWidgets('tab Modifier: pasang, urut, lepas, simpan', (tester) async {
    final repo = FakeCatalogRepository(seed: sampleProducts())
      ..modifierGroups = seedModifierGroups();
    await pumpLakuna(
      tester,
      size: const Size(1280, 800),
      initialLocation: Routes.products,
      catalog: repo,
      session: FakeSessionRepository()..current = sampleStaff(),
    );
    final kopi = repo.products.firstWhere((p) => p.name == 'Kopi Sachet');
    await _tap(tester, 'product-row-${kopi.id.uuid}');
    await _tap(tester, 'product-tab-modifiers');
    expect(
      find.text(
        'Belum ada grup terpasang. Menu langsung masuk bill tanpa pilihan.',
      ),
      findsOneWidget,
    );
    await _tap(tester, 'product-modifier-attach-Topping');
    await _tap(tester, 'product-modifier-attach-Ukuran');
    expect(find.byKey(const ValueKey('product-modifier-Topping')), findsOne);
    expect(find.text('Boba +Rp 5.000, Keju +Rp 6.000'), findsOneWidget);
    await _tap(tester, 'product-modifier-up-Ukuran');
    // Sakelar dapur (F1-10g): bawaan aktif.
    for (final (key, label) in const [
      ('product-send-to-kitchen', 'Kirim ke tiket dapur'),
      ('product-allow-note', 'Bisa catatan bebas'),
    ]) {
      final target = find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.text(label),
      );
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
    }
    await _tap(tester, 'product-save');
    final [ukuran, topping] = repo.modifierGroups;
    expect(repo.saved.single.modifierGroupIds, [
      ukuran.id.uuid,
      topping.id.uuid,
    ]);
    expect(repo.saved.single.sendToKitchen, isFalse);
    expect(repo.saved.single.allowNote, isFalse);
  });

  testWidgets('ponsel: kartu, chip di bawah minimum, dan tombol tambah', (
    tester,
  ) async {
    await pump(tester, size: const Size(320, 700), seed: sampleProducts());
    expect(tester.takeException(), isNull);
    expect(find.text('2 aktif · 1 di bawah minimum'), findsOneWidget);
    expect(find.text('Stok 2 / min 20'), findsOneWidget);
    await _tap(tester, 'products-chip-low');
    expect(find.text('Minyak Goreng'), findsNothing);
    expect(find.text('Kopi Sachet'), findsOneWidget);
    await _tap(tester, 'products-fab');
    expect(find.byKey(const ValueKey('product-name')), findsOneWidget);
    expect(tester.takeException(), isNull);
    // Baris ditumpuk dengan label di ponsel.
    expect(find.text('Harga jual'), findsWidgets);
  });

  testWidgets('menu Produk tersembunyi tanpa izin products:manage', (
    tester,
  ) async {
    await pump(tester, role: 'cashier');
    expect(find.byKey(const ValueKey('products-empty')), findsNothing);
    expect(find.text('Produk & stok'), findsNothing);
  });
}
