import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/report_document.dart';
import 'package:lakuna_flutter/data/services/spreadsheet_exporter.dart';
import 'package:lakuna_flutter/l10n/gen/app_localizations.dart';
import 'package:lakuna_flutter/ui/purchases/purchase_detail_view_model.dart';
import 'package:lakuna_flutter/ui/purchases/purchase_form_view_model.dart';
import 'package:lakuna_flutter/ui/purchases/purchase_print.dart';

import '../../testing/fake_purchases_repository.dart';
import '../../testing/fake_spreadsheet_exporter.dart';

UuidValue _id() => UuidValue.fromString(newId());

/// F1-12c: isi PDF pembelian.
void main() {
  final id = lookupAppLocalizations(const Locale('id'));
  final en = lookupAppLocalizations(const Locale('en'));
  // 02.30 UTC = 09.30 WIB.
  final at = DateTime.utc(2026, 11, 14, 2, 30);
  final tenant = _id();
  final gula = _id();
  final minyak = _id();

  PurchaseItem item(
    UuidValue variant,
    String name,
    String unit,
    int qtyMilli,
    int price, {
    String variantName = '',
    int factorMilli = 1000,
  }) => PurchaseItem(
    tenantId: tenant,
    purchaseId: _id(),
    variantId: variant,
    productName: name,
    variantName: variantName,
    unitName: unit,
    factorMilli: factorMilli,
    quantityMilli: qtyMilli,
    unitPrice: price,
    lineTotal: price * qtyMilli ~/ 1000,
    landedUnitCost: price,
    sortOrder: 0,
    hlc: '',
  );

  PurchaseDetail detail({
    int paid = 885000,
    DateTime? dueOn,
    String? note,
    String? invoiceNo = 'SP/XI/0457',
    List<PurchaseReturn> returns = const [],
    List<PurchaseDebtPaymentLine> debtPayments = const [],
    int discount = 0,
    int shipping = 4000,
    String staffName = 'Yusuf',
  }) => PurchaseDetail(
    purchase: Purchase(
      tenantId: tenant,
      outletId: _id(),
      deviceId: _id(),
      stockLocationId: _id(),
      staffId: _id(),
      number: 'PB-PST-K01-261114-0001',
      invoiceNo: invoiceNo,
      status: PurchaseStatus.received,
      purchasedOn: DateTime.utc(2026, 11, 14),
      subtotal: 885000,
      discount: discount,
      shipping: shipping,
      total: 885000 - discount + shipping,
      paidAmount: paid,
      dueOn: dueOn,
      note: note,
      hlc: '',
    ),
    items: [
      item(gula, 'Gula Pasir', 'kg', 10000, 14500),
      item(
        minyak,
        'Minyak Goreng',
        'dus',
        4000,
        185000,
        variantName: '2 L',
        factorMilli: 6000,
      ),
    ],
    supplier: Supplier(tenantId: tenant, name: 'CV Sumber Pangan', hlc: ''),
    staffName: staffName,
    deviceCode: 'K01',
    locationName: 'Gudang',
    returns: returns,
    returnedMilli: const {},
    sellPrices: const {},
    skus: {gula: 'GLA-1', minyak: null},
    baseUnits: {gula: 'kg', minyak: 'btl'},
    debtPayments: debtPayments,
  );

  ReportTable table(PurchaseDetail d, [AppLocalizations? l10n]) =>
      purchasePrintTable(
        l10n ?? id,
        d,
        staff: 'Rina',
        printedAt: at,
        timezone: 'Asia/Jakarta',
      );

  test('lunas: judul, kolom, baris barang, ringkasan tanpa baris nol', () {
    final t = table(detail(paid: 889000));
    expect(t.title, 'Pembelian PB-PST-K01-261114-0001');
    expect(
      t.subtitle,
      'CV Sumber Pangan · No. faktur SP/XI/0457 · 14/11/2026 · Gudang · '
      'Yusuf · K01',
    );
    expect(t.headers, ['Produk', 'Qty', 'Harga beli', 'Subtotal']);
    expect(t.rows[0].cells, [
      'Gula Pasir · GLA-1',
      '10 kg',
      const XlsxNumber(14500),
      const XlsxNumber(145000),
    ]);
    expect(t.rows[1].cells, [
      'Minyak Goreng 2 L',
      '4 dus (@ 6 btl)',
      const XlsxNumber(185000),
      const XlsxNumber(740000),
    ]);
    final summary = [
      for (final r in t.rows.skip(2)) (r.cells.first, r.cells.last, r.strong),
    ];
    expect(summary, [
      ('Subtotal', const XlsxNumber(885000), false),
      ('Ongkos kirim', const XlsxNumber(4000), false),
      ('Total', const XlsxNumber(889000), true),
      ('Dibayar di muka', const XlsxNumber(889000), false),
      ('Sisa hutang', const XlsxNumber(0), true),
    ]);
    expect(t.notes, ['Dicetak 14 November 2026 09.30 oleh Rina']);
  });

  test('berhutang: diskon, bayar hutang, retur, jatuh tempo, catatan', () {
    final t = table(
      detail(
        paid: 100000,
        discount: 5000,
        shipping: 0,
        dueOn: DateTime.utc(2026, 11, 28),
        note: 'Barang datang sore',
        invoiceNo: null,
        returns: [
          PurchaseReturn(
            tenantId: tenant,
            outletId: _id(),
            deviceId: _id(),
            purchaseId: _id(),
            staffId: _id(),
            number: 'RB-PST-K01-261115-0001',
            returnedAt: DateTime.utc(2026, 11, 15, 3),
            amount: 145000,
            debtReduction: 145000,
            refundAmount: 0,
            hlc: '',
          ),
          PurchaseReturn(
            tenantId: tenant,
            outletId: _id(),
            deviceId: _id(),
            purchaseId: _id(),
            staffId: _id(),
            number: 'RB-PST-K01-261116-0001',
            returnedAt: DateTime.utc(2026, 11, 16, 3),
            amount: 50000,
            debtReduction: 0,
            refundAmount: 50000,
            hlc: '',
          ),
        ],
        debtPayments: [
          PurchaseDebtPaymentLine(
            number: 'BH-PST-K01-261120-0001',
            paidOn: DateTime.utc(2026, 11, 20),
            funding: FundingSource.bank,
            amount: const Money(200000),
          ),
        ],
      ),
    );
    expect(t.subtitle, startsWith('CV Sumber Pangan · 14/11/2026 · Gudang'));
    final summary = [for (final r in t.rows.skip(2)) r.cells.first];
    expect(summary, [
      'Subtotal',
      'Diskon faktur',
      'Total',
      'Dibayar di muka',
      'Bayar hutang',
      'Retur memotong hutang',
      'Sisa hutang',
    ]);
    // Ringkasan tertutup: 880.000 − 100.000 − 200.000 − 145.000. Retur
    // yang dibayar tunai (uang kembali) tidak memotong hutang.
    expect(t.rows.last.cells.last, const XlsxNumber(435000));
    expect(t.rows[7].cells.last, const XlsxNumber(145000));
    // Diskon dicetak positif seperti di layar.
    expect(t.rows[3].cells.last, const XlsxNumber(5000));
    expect(t.notes, [
      'Jatuh tempo sisa hutang: 28/11/2026',
      'Catatan: Barang datang sore',
      'Retur RB-PST-K01-261115-0001 · 15/11/2026 · Rp 145.000',
      'Retur RB-PST-K01-261116-0001 · 16/11/2026 · Rp 50.000',
      'Uang kembali dari retur: Rp 50.000',
      'Dicetak 14 November 2026 09.30 oleh Rina',
    ]);
  });

  test('retur seluruhnya uang kembali: tanpa baris potong hutang', () {
    final t = table(
      detail(
        paid: 889000,
        staffName: '',
        returns: [
          PurchaseReturn(
            tenantId: tenant,
            outletId: _id(),
            deviceId: _id(),
            purchaseId: _id(),
            staffId: _id(),
            number: 'RB-PST-K01-261115-0001',
            returnedAt: DateTime.utc(2026, 11, 15, 3),
            amount: 145000,
            debtReduction: 0,
            refundAmount: 145000,
            hlc: '',
          ),
        ],
      ),
    );
    // Nama staf kosong tidak meninggalkan pemisah menggantung.
    expect(t.subtitle, endsWith('· Gudang · K01'));
    expect(
      [for (final r in t.rows.skip(2)) r.cells.first],
      [
        'Subtotal',
        'Ongkos kirim',
        'Total',
        'Dibayar di muka',
        'Sisa hutang',
      ],
    );
    expect(t.notes, contains('Uang kembali dari retur: Rp 145.000'));
  });

  test('bahasa Inggris dan nama berkas', () {
    final t = table(detail(), en);
    expect(t.title, 'Purchase PB-PST-K01-261114-0001');
    expect(t.headers, ['Product', 'Qty', 'Cost price', 'Subtotal']);
    expect(
      purchasePrintFileName('PB-PST-K01-261114-0001'),
      'pembelian-pb-pst-k01-261114-0001.pdf',
    );
  });

  group('PurchaseDetailViewModel.printPdf', () {
    late FakePurchasesRepository repo;
    late FakeSpreadsheetExporter exporter;
    late PurchaseDetailViewModel vm;

    setUp(() async {
      repo = FakePurchasesRepository();
      exporter = FakeSpreadsheetExporter()..path = '/docs/pembelian.pdf';
      final form = PurchaseFormViewModel(repository: repo);
      await form.load.execute();
      form
        ..addByCode('8991234500031')
        ..payInFull();
      await form.receive.execute();
      vm = PurchaseDetailViewModel(
        repository: repo,
        purchaseId: form.draftId!,
        exporter: exporter,
      );
      await vm.load.execute();
    });

    test('menyimpan lewat exporter dan mengingat lokasinya', () async {
      expect(vm.canPrint, isTrue);
      await vm.printPdf.execute((
        () async => Uint8List.fromList([1, 2]),
        'pembelian-x.pdf',
      ));
      expect(vm.printPdf.completed, isTrue);
      expect(vm.printPath, '/docs/pembelian.pdf');
      expect(exporter.saved.single.$1, 'pembelian-x.pdf');
    });

    test('ponsel (lembar bagikan) tanpa lokasi; galat dilaporkan', () async {
      exporter.path = null;
      await vm.printPdf.execute((
        () async => Uint8List.fromList([1]),
        'a.pdf',
      ));
      expect(vm.printPdf.completed, isTrue);
      expect(vm.printPath, isNull);

      exporter.error = Exception('disk penuh');
      await vm.printPdf.execute((
        () async => Uint8List.fromList([1]),
        'a.pdf',
      ));
      expect(vm.printPdf.error, isTrue);
      expect(vm.printPath, isNull);
    });

    test('muat ulang menghapus pesan cetak lama', () async {
      await vm.printPdf.execute((
        () async => Uint8List.fromList([1]),
        'a.pdf',
      ));
      expect(vm.printPath, isNotNull);
      final reload = vm.load.execute();
      // Selama memuat ulang tombol cetak mati.
      expect(vm.canPrint, isFalse);
      await reload;
      expect(vm.printPdf.completed, isFalse);
      expect(vm.printPath, isNull);
      expect(vm.canPrint, isTrue);
    });
  });
}
