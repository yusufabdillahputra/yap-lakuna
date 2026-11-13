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
}
