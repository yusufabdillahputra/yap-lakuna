import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart' show UuidValue;
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/barcode_label_pdf.dart';
import 'package:lakuna_flutter/data/services/receipt_printer.dart';
import 'package:lakuna_flutter/ui/products/barcode_label_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/fake_catalog_repository.dart';
import '../../testing/fake_receipt_printer.dart';
import 'product_list_view_model_test.dart' show sampleProducts;

String _price(Money m) => m.formatIdr();

void main() {
  late FakeCatalogRepository repo;
  late FakeReceiptPrinter printer;
  late List<BarcodeLabelSheet> built;

  BarcodeLabelViewModel make({UuidValue? productId}) => BarcodeLabelViewModel(
    repository: repo,
    random: Random(7),
    printer: printer,
    initialProduct: productId,
    now: () => DateTime(2026, 11, 13, 14, 5),
    buildPdf: (sheet) async {
      built.add(sheet);
      return Uint8List.fromList([1, 2, 3]);
    },
  );

  setUp(() {
    repo = FakeCatalogRepository(seed: sampleProducts());
    printer = FakeReceiptPrinter();
    built = [];
  });

  test('baris dari varian, satuan berbarcode, dan produk tanpa kode', () async {
    final vm = make();
    await vm.load.execute();
    expect(vm.selectedOnly, isFalse);
    expect(vm.rows.map((r) => (r.title, r.code, r.price.value)), [
      ('Jasa Antar', null, 5000),
      ('Kopi Sachet', 'KOP-SCH', 2000),
      ('Minyak Goreng', '8991234500024', 36000),
      ('Minyak Goreng · dus', '899100', 216000),
    ]);
    final [jasa, kopi, minyak, dus] = vm.rows;
    expect(jasa.symbology, isNull);
    expect(jasa.printable, isFalse);
    expect(kopi.symbology, BarcodeSymbology.code128);
    expect(minyak.symbology, BarcodeSymbology.code128);
    expect(dus.stock, Qty.units(4));
    expect(minyak.stock, Qty.units(24));
    expect(vm.selected, isEmpty);
    expect(vm.total, 0);
    expect(vm.canPrint, isFalse);
  });

  test('dibuka dari form: baris produk itu sudah dipilih', () async {
    final minyak = repo.products.firstWhere((p) => p.name == 'Minyak Goreng');
    final vm = make(productId: minyak.id);
    await vm.load.execute();
    expect(vm.selected.map((r) => r.title), [
      'Minyak Goreng',
      'Minyak Goreng · dus',
    ]);
    expect(vm.total, 2);
    expect(vm.preview?.title, 'Minyak Goreng');
    expect(vm.selectedOnly, isTrue);
    expect(vm.visible, hasLength(2));
  });

  test('pilih, jumlah, isi sesuai stok, cari, hanya terpilih', () async {
    final vm = make();
    await vm.load.execute();
    final [jasa, kopi, minyak, dus] = vm.rows;
    vm.toggle(jasa, true);
    expect(vm.selected, isEmpty, reason: 'tanpa kode tidak bisa dipilih');
    vm.toggle(kopi, true);
    vm.toggle(minyak, true);
    expect(vm.quantity(kopi), 1);
    vm.setQuantity(kopi, 5);
    vm.setQuantity(minyak, 2000);
    expect(vm.quantity(minyak), BarcodeLabelViewModel.maxPerRow);
    vm.setQuantity(minyak, 0);
    expect(vm.quantity(minyak), 1);
    vm.toggle(dus, true);
    vm.fillFromStock();
    expect(vm.quantity(kopi), 2);
    expect(vm.quantity(minyak), 24);
    expect(vm.quantity(dus), 4);
    expect(vm.total, 30);
    expect(vm.pages, 2);
    vm.setSkip(20);
    expect(vm.pages, 3);
    vm.setPaper(BarcodeLabelPaper.roll38x25);
    expect(vm.pages, 30);
    final rev = vm.revision(kopi);
    final minyakRev = vm.revision(minyak);
    vm.step(kopi, -1);
    expect(vm.quantity(kopi), 1);
    expect(vm.revision(kopi), rev + 1);
    expect(vm.revision(minyak), minyakRev, reason: 'baris lain tetap');
    vm.setQuantity(kopi, 0);
    expect(vm.quantity(kopi), 1);
    expect(vm.revision(kopi), rev + 2, reason: 'kolom memuat nilai 1');
    vm.step(kopi, 1);
    expect(vm.quantity(kopi), 2);

    vm.setQuery('kopi');
    expect(vm.visible.map((r) => r.title), ['Kopi Sachet']);
    vm.setQuery('899100');
    expect(vm.visible.map((r) => r.title), ['Minyak Goreng · dus']);
    vm.setQuery('myk-2l');
    expect(vm.visible.map((r) => r.title), [
      'Minyak Goreng',
      'Minyak Goreng · dus',
    ], reason: 'SKU tetap dicari walau barcode terisi');
    vm.setQuery('');
    vm.setSelectedOnly(true);
    expect(vm.visible, hasLength(3));
    vm.toggle(kopi, false);
    expect(vm.visible, hasLength(2));
    expect(vm.quantity(kopi), 0);
  });

  test('kode terlalu panjang untuk kertas kecil ditandai (F1-07i)', () async {
    repo = FakeCatalogRepository(
      seed: [
        const ProductDraft(
          name: 'Minyak Premium',
          baseUnit: 'botol',
          variants: [
            VariantDraft(sku: 'MYK-2L-PREMIUM', sellPrice: Money(40000)),
          ],
        ),
        const ProductDraft(
          name: 'Teh',
          baseUnit: 'pcs',
          variants: [VariantDraft(barcode: '8990001000012')],
        ),
      ],
    );
    final vm = make();
    await vm.load.execute();
    final minyak = vm.rows.firstWhere((r) => r.title == 'Minyak Premium');
    final teh = vm.rows.firstWhere((r) => r.title == 'Teh');
    vm
      ..toggle(minyak, true)
      ..toggle(teh, true);
    expect(vm.denseRows, isEmpty, reason: 'A4 cukup lebar');
    vm.setPaper(BarcodeLabelPaper.roll38x25);
    expect(vm.denseRows.map((r) => r.title), ['Minyak Premium']);
    vm.setPaper(BarcodeLabelPaper.a4Sheet);
    expect(vm.denseRows, isEmpty, reason: 'kembali ke A4');
    vm.setPaper(BarcodeLabelPaper.roll50x30);
    expect(vm.denseRows.map((r) => r.title), ['Minyak Premium']);
    vm.toggle(minyak, false);
    expect(vm.denseRows, isEmpty);
  });

  test('cari UPC-A yang terbaca 13 digit (F1-07h)', () async {
    repo = FakeCatalogRepository(
      seed: [
        ...sampleProducts(),
        const ProductDraft(
          name: 'Sereal Impor',
          baseUnit: 'pcs',
          variants: [VariantDraft(barcode: '036000291452')],
        ),
      ],
    );
    final vm = make();
    await vm.load.execute();
    vm.setQuery('0036000291452');
    expect(vm.visible.single.title, 'Sereal Impor');
  });

  test('lembar: urutan baris, harga opsional, lewati hanya di A4', () async {
    final vm = make();
    await vm.load.execute();
    final [_, kopi, minyak, _] = vm.rows;
    vm.toggle(minyak, true);
    vm.setQuantity(minyak, 2);
    vm.toggle(kopi, true);
    vm.setSkip(30);
    expect(vm.skip, 23);
    expect(vm.skipRevision, 1);
    vm.setSkip(4);
    expect(vm.skipRevision, 1);
    vm.setSkip(23);
    var sheet = vm.sheet(_price);
    expect(sheet.paper, BarcodeLabelPaper.a4Sheet);
    expect(sheet.skip, 23);
    expect(sheet.labels.map((l) => (l.title, l.price)), [
      ('Kopi Sachet', 'Rp 2.000'),
      ('Minyak Goreng', 'Rp 36.000'),
      ('Minyak Goreng', 'Rp 36.000'),
    ]);
    vm.setShowPrice(false);
    vm.setPaper(BarcodeLabelPaper.roll50x30);
    sheet = vm.sheet(_price);
    expect(sheet.skip, 0);
    expect(sheet.labels.first.price, isNull);
  });

  test('batas total label', () async {
    final vm = make();
    await vm.load.execute();
    final [_, kopi, minyak, dus] = vm.rows;
    for (final r in [kopi, minyak, dus]) {
      vm.toggle(r, true);
      vm.setQuantity(r, 999);
    }
    expect(vm.total, 2997);
    expect(vm.overLimit, isTrue);
    expect(vm.canPrint, isFalse);
    vm.setQuantity(dus, 2);
    expect(vm.overLimit, isFalse);
    expect(vm.canPrint, isTrue);
  });

  test('cetak dan simpan PDF lewat printer; galat printer', () async {
    final vm = make();
    await vm.load.execute();
    vm.toggle(vm.rows[1], true);
    await vm.print.execute(vm.sheet(_price));
    expect(printer.documentPrints.single.$2, 'Label barcode');
    expect(
      printer.documentFormats.single,
      BarcodeLabelPaper.a4Sheet.pageFormat,
    );
    expect(built.single.labels.single.title, 'Kopi Sachet');

    await vm.save.execute(vm.sheet(_price));
    expect(printer.documentShares.single.$2, 'label-barcode-261113-1405.pdf');
    expect(vm.savedPath, printer.sharePath);

    printer.nextFailure = const PrinterFailure(PrinterFailureReason.connect);
    await vm.print.execute(vm.sheet(_price));
    expect(vm.print.result, isA<Error<void>>());
    expect(vm.save.result, isNull, reason: 'hanya hasil aksi terakhir');
    expect(vm.printFailure, PrinterFailureReason.connect);

    // Cetak gagal lalu simpan berhasil: galat cetak tidak tersisa.
    await vm.save.execute(vm.sheet(_price));
    expect(vm.print.result, isNull);
    expect(vm.save.completed, isTrue);
    expect(vm.printFailure, isNull);
  });

  test('galat muat katalog', () async {
    repo.nextError = Exception('rusak');
    final vm = make();
    await vm.load.execute();
    expect(vm.error, isNotNull);
    await vm.load.execute();
    expect(vm.error, isNull);
    expect(vm.rows, hasLength(4));
  });

  group('buat barcode massal (F1-07j)', () {
    bool isStoreEan(String? c) =>
        c != null && RegExp(r'^20\d{11}$').hasMatch(c);

    test('assignStoreBarcodes hanya mengisi varian yang diminta dan kosong, '
        'kode unik terhadap katalog', () {
      final products = [
        ...repo.products,
        ...FakeCatalogRepository(
          seed: [
            const ProductDraft(
              name: 'Roti',
              baseUnit: 'pcs',
              variants: [
                VariantDraft(name: 'Coklat', sellPrice: Money(5000)),
                VariantDraft(name: 'Keju', sellPrice: Money(6000)),
                VariantDraft(
                  name: 'Pandan',
                  barcode: '2000000000008',
                  sellPrice: Money(5000),
                ),
              ],
            ),
          ],
        ).products,
      ];
      final roti = products.firstWhere((p) => p.name == 'Roti');
      final jasa = products.firstWhere((p) => p.name == 'Jasa Antar');
      final ids = {
        for (final v in roti.variants) v.id,
        jasa.variants.single.id,
      };
      final assigned = assignStoreBarcodes(products, ids, Random(1));
      expect(
        {for (final (d, n) in assigned) d.name: n},
        {'Roti': 2, 'Jasa Antar': 1},
      );
      final drafts = [for (final (d, _) in assigned) d];
      expect(
        drafts.map((d) => d.name),
        unorderedEquals(['Roti', 'Jasa Antar']),
      );
      final rotiDraft = drafts.firstWhere((d) => d.name == 'Roti');
      expect(rotiDraft.variants[2].barcode, '2000000000008');
      final codes = [
        rotiDraft.variants[0].barcode,
        rotiDraft.variants[1].barcode,
        drafts
            .firstWhere((d) => d.name == 'Jasa Antar')
            .variants
            .single
            .barcode,
      ];
      expect(codes.every(isStoreEan), isTrue, reason: '$codes');
      expect(codes.toSet(), hasLength(3));
      final taken = {
        for (final p in products)
          for (final v in p.variants) ...[?v.sku, ?v.barcode],
      };
      expect(codes.any(taken.contains), isFalse);
      // Data lain tidak berubah.
      expect(rotiDraft.variants[1].sellPrice, const Money(6000));
      expect(rotiDraft.id, roti.id.uuid);
    });

    test('produk tanpa kode mendapat barcode lalu terpilih', () async {
      final vm = make();
      await vm.load.execute();
      expect(vm.missingCodeRows.map((r) => r.title), ['Jasa Antar']);
      await vm.generateBarcodes.execute(vm.missingCodeRows);
      final summary =
          (vm.generateBarcodes.result! as Ok<BarcodeGenerateSummary>).value;
      expect(summary.saved, 1);
      expect(summary.failed, isEmpty);
      expect(repo.saved, hasLength(1));
      expect(isStoreEan(repo.saved.single.variants.single.barcode), isTrue);
      expect(vm.missingCodeRows, isEmpty);
      final jasa = vm.rows.firstWhere((r) => r.title == 'Jasa Antar');
      expect(jasa.printable, isTrue);
      expect(jasa.symbology, BarcodeSymbology.ean13);
      expect(vm.quantity(jasa), 1);
    });

    test('SKU terlalu rapat diganti EAN-13, jumlah tetap', () async {
      repo = FakeCatalogRepository(
        seed: [
          ...sampleProducts(),
          const ProductDraft(
            name: 'Minyak Premium',
            baseUnit: 'botol',
            variants: [
              VariantDraft(sku: 'MYK-2L-PREMIUM', sellPrice: Money(40000)),
            ],
          ),
        ],
      );
      final vm = make();
      await vm.load.execute();
      final minyak = vm.rows.firstWhere((r) => r.title == 'Minyak Premium');
      vm
        ..toggle(minyak, true)
        ..setQuantity(minyak, 3)
        ..setPaper(BarcodeLabelPaper.roll38x25);
      expect(vm.denseWithoutBarcode.map((r) => r.title), ['Minyak Premium']);
      await vm.generateBarcodes.execute(vm.denseWithoutBarcode);
      final after = vm.rows.firstWhere((r) => r.title == 'Minyak Premium');
      expect(isStoreEan(after.code), isTrue);
      expect(vm.quantity(after), 3);
      expect(vm.denseRows, isEmpty);
      expect(
        repo.saved.single.variants.single.sku,
        'MYK-2L-PREMIUM',
        reason: 'SKU tidak diubah',
      );
    });

    test('baris padat yang sudah berbarcode tidak ditawarkan', () async {
      repo = FakeCatalogRepository(
        seed: [
          const ProductDraft(
            name: 'Kardus',
            baseUnit: 'pcs',
            variants: [
              VariantDraft(
                sku: 'X',
                barcode: 'KARDUS-PANJANG-SEKALI-01',
                sellPrice: Money(1000),
              ),
            ],
          ),
        ],
      );
      final vm = make();
      await vm.load.execute();
      vm
        ..toggle(vm.rows.single, true)
        ..setPaper(BarcodeLabelPaper.roll38x25);
      expect(vm.denseRows, hasLength(1));
      expect(vm.denseWithoutBarcode, isEmpty);
    });

    test('galat simpan semua: galat dan katalog dimuat ulang', () async {
      final vm = make();
      await vm.load.execute();
      repo.failSaveFor.add('Jasa Antar');
      await vm.generateBarcodes.execute(vm.missingCodeRows);
      expect(vm.generateBarcodes.error, isTrue);
      expect(repo.saved, isEmpty);
      expect(vm.missingCodeRows.map((r) => r.title), ['Jasa Antar']);
    });

    test('satu produk gagal: yang lain tetap tersimpan dan disebut', () async {
      repo = FakeCatalogRepository(
        seed: [
          ...sampleProducts(),
          const ProductDraft(
            name: 'Bolu',
            baseUnit: 'pcs',
            variants: [VariantDraft(sellPrice: Money(20000))],
          ),
        ],
      );
      final vm = make();
      await vm.load.execute();
      expect(vm.missingCodeRows.map((r) => r.title), ['Bolu', 'Jasa Antar']);
      repo.failSaveFor.add('Bolu');
      await vm.generateBarcodes.execute(vm.missingCodeRows);
      final summary =
          (vm.generateBarcodes.result! as Ok<BarcodeGenerateSummary>).value;
      expect(summary.saved, 1);
      expect(summary.failed, ['Bolu']);
      expect(summary.error, isNotNull);
      expect(repo.saved.map((d) => d.name), ['Jasa Antar']);
      expect(vm.missingCodeRows.map((r) => r.title), ['Bolu']);
    });

    test('memakai data terbaru, bukan saat layar dibuka', () async {
      final vm = make();
      await vm.load.execute();
      // Harga diubah di tempat lain setelah layar dibuka.
      final jasa = repo.products.firstWhere((p) => p.name == 'Jasa Antar');
      final draft = jasa.toDraft();
      await repo.save(
        ProductDraft(
          id: draft.id,
          name: draft.name,
          baseUnit: draft.baseUnit,
          kind: draft.kind,
          isActive: draft.isActive,
          variants: [
            VariantDraft(
              id: draft.variants.single.id,
              sellPrice: const Money(7500),
            ),
          ],
        ),
      );
      repo.saved.clear();
      await vm.generateBarcodes.execute(vm.missingCodeRows);
      expect(repo.saved.single.variants.single.sellPrice, const Money(7500));
    });

    test('baris berbarcode tak tercetak tidak ditawarkan', () async {
      repo = FakeCatalogRepository(
        seed: [
          const ProductDraft(
            name: 'Aneh',
            baseUnit: 'pcs',
            variants: [VariantDraft(barcode: 'ÄÖÜ', sellPrice: Money(1000))],
          ),
        ],
      );
      final vm = make();
      await vm.load.execute();
      expect(vm.rows.single.printable, isFalse);
      expect(vm.missingCodeRows, isEmpty);
    });
  });
}
