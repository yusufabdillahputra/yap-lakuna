import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart' show StockRow;
import 'package:lakuna_flutter/data/repositories/session_repository.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import 'package:lakuna_flutter/data/services/image_file_picker.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_payment_settings_repository.dart';
import '../../testing/fake_purchases_repository.dart';
import '../../testing/fake_session_repository.dart';
import '../../testing/fake_spreadsheet_exporter.dart';
import '../../testing/fake_stock_repository.dart';
import '../../testing/floor_seed.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

Finder _keyPrefix(String prefix) => find.byWidgetPredicate(
  (w) =>
      w.key is ValueKey<String> &&
      (w.key! as ValueKey<String>).value.startsWith(prefix),
);

Finder _input(Finder field) =>
    find.descendant(of: field, matching: find.byType(EditableText));

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _scan(WidgetTester tester, String code) async {
  await tester.ensureVisible(_key('purchase-scan'));
  await tester.enterText(_input(_key('purchase-scan')), code);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, Finder field, String text) async {
  await tester.ensureVisible(field);
  await tester.enterText(_input(field), text);
  await tester.pumpAndSettle();
}

void main() {
  late FakePurchasesRepository repo;
  late FakeImagePicker picker;
  late FakeSpreadsheetExporter exporter;

  Future<void> pump(
    WidgetTester tester,
    Size size, {
    FakeSessionRepository? session,
    bool stockHasKop = true,
    Money? drawerCash,
  }) async {
    repo = FakePurchasesRepository()..drawerCash = drawerCash;
    // Layar Stok memakai lokasi dan produk yang sama dengan pembelian.
    final kop = repo.products.firstWhere(
      (p) => p.variants.any((v) => v.sku == 'KOP'),
    );
    final stock = FakeStockRepository(
      locations: repo.locations,
      rows: [
        if (stockHasKop)
          StockRow(
            variantId: kop.variants.single.id,
            productId: kop.id,
            productName: kop.name,
            variantName: '',
            baseUnit: kop.baseUnit,
            stock: Qty.units(1),
            minStock: Qty.zero,
            unitCost: const Money(1500),
          ),
        ...sampleStockRows(),
      ],
    );
    picker = FakeImagePicker();
    exporter = FakeSpreadsheetExporter()
      ..path = '/home/kasir/Dokumen/Lakuna/pembelian.pdf';
    await pumpLakuna(
      tester,
      size: size,
      initialLocation: Routes.purchases,
      purchases: repo,
      imagePicker: picker,
      exporter: exporter,
      session: session,
      stock: stock,
    );
  }

  UuidValue kopVariant() => repo.products
      .expand((p) => p.variants)
      .firstWhere((v) => v.sku == 'KOP')
      .id;

  /// Terima pembelian KOP lunas, lalu halaman detail terbuka.
  Future<void> receiveKop(WidgetTester tester, {bool narrow = false}) async {
    if (narrow) await _tap(tester, _key('purchases-new'));
    await _scan(tester, 'KOP');
    await _type(tester, _keyPrefix('purchase-price-'), '1500');
    await _tap(tester, _key('purchase-pay-full'));
    await _tap(tester, _key('purchase-receive'));
    expect(_key('purchase-detail'), findsOneWidget);
  }

  PickedImage png() => PickedImage(
    name: 'faktur-sp.png',
    size: samplePng.length,
    bytes: samplePng,
  );

  testWidgets(
    'desktop: draf → terima → saran harga → terapkan → retur dengan uang kembali',
    (tester) async {
      await pump(tester, const Size(1440, 900));
      expect(
        find.text('Pembelian baru · PB-PST-D01-261103-0001'),
        findsOneWidget,
      );
      expect(_key('purchases-empty'), findsOneWidget);

      // Barcode dus memilih satuan dus (6); harga 6 × HPP.
      await _scan(tester, '8991234500031');
      expect(find.text('Dus (6)'), findsOneWidget);
      expect(find.text('Rp 195.000'), findsWidgets);

      // Terima tanpa supplier padahal berhutang → galat, tidak tersimpan.
      await _tap(tester, _key('purchase-receive'));
      expect(
        find.text('Pilih atau ketik supplier untuk pembelian yang berhutang.'),
        findsOneWidget,
      );
      expect(repo.purchases, isEmpty);

      // Simpan draf boleh tanpa supplier.
      await _tap(tester, _key('purchase-save-draft'));
      expect(find.text('Draf · PB-PST-D01-261103-0001'), findsOneWidget);
      expect(find.text('Draf'), findsOneWidget);

      // Harga naik jadi 210.000/dus, bayar lunas, terima.
      await _type(tester, _keyPrefix('purchase-price-'), '210000');
      await _tap(tester, _key('purchase-pay-full'));
      expect(find.text('Rp 210.000'), findsWidgets);
      await _tap(tester, _key('purchase-receive'));

      // Halaman detail 1.19b.
      expect(_key('purchase-detail'), findsOneWidget);
      expect(find.text('Lunas'), findsOneWidget);
      // HPP 32.500 → (780.000 + 210.000) / 30 = 33.000; saran 36.600.
      expect(
        find.textContaining('Rp 33.000', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('Rp 36.600'), findsOneWidget);
      expect(find.text('Di bawah saran'), findsOneWidget);
      await _tap(tester, _key('purchase-apply-prices'));
      expect(repo.applied.single.values.single, const Money(36600));
      expect(find.text('Aman'), findsOneWidget);
      expect(find.text('Terapkan harga jual (0 produk)'), findsOneWidget);

      // Retur 1 dus: lunas, jadi semuanya uang kembali.
      await _tap(tester, _key('purchase-return-open'));
      await _type(tester, _keyPrefix('purchase-return-qty-'), '1');
      expect(
        find.text('Mengurangi hutang Rp 0 · uang kembali Rp 210.000'),
        findsOneWidget,
      );
      await _tap(tester, _key('purchase-return-submit'));
      expect(find.text('Pilih ke mana uang kembali.'), findsOneWidget);
      await _tap(tester, _keyPrefix('purchase-refund-source-'));
      await _tap(tester, find.text('Rekening bank').last);
      await _tap(tester, _key('purchase-return-submit'));
      expect(repo.returns.single.refundAmount, 210000);
      expect(repo.returns.single.refundSource, FundingSource.bank);
      expect(
        find.text('Retur RB-PST-D01-261103-0001 tercatat.'),
        findsOneWidget,
      );
      expect(_key('purchase-return-form'), findsNothing);

      // Kembali ke daftar: pembelian lunas dan tab retur.
      await _tap(tester, _key('purchase-back'));
      expect(
        find.text('Pembelian baru · PB-PST-D01-261103-0002'),
        findsOneWidget,
      );
      expect(find.text('Lunas'), findsOneWidget);
      await _tap(tester, _key('purchases-tab-returns'));
      expect(find.text('RB-PST-D01-261103-0001'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets('desktop: berhutang dengan supplier baru, jatuh tempo +14', (
    tester,
  ) async {
    await pump(tester, const Size(1440, 900));
    await _scan(tester, 'MYK-2L');
    await _type(tester, _keyPrefix('purchase-paid-'), '10000');
    // Supplier baru diketik lewat pilihan "+ Supplier baru".
    await _tap(tester, _keyPrefix('purchase-supplier-'));
    await _tap(tester, find.text('+ Supplier baru').last);
    await _type(tester, _keyPrefix('purchase-supplier-name-'), 'UD Makmur');
    expect(find.text('Rp 22.500'), findsWidgets);
    await _tap(tester, _key('purchase-receive'));
    final r = repo.requests.single;
    expect(r.newSupplierName, 'UD Makmur');
    expect(r.dueOn, DateTime.utc(2026, 11, 17));
    expect(_key('purchase-detail'), findsOneWidget);
    expect(find.text('Belum lunas · hutang'), findsOneWidget);
    expect(find.text('Jatuh tempo 17/11/2026 (14 hari lagi).'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('bayar dari laci melebihi perkiraan: peringatan (F1-03c)', (
    tester,
  ) async {
    await pump(tester, const Size(1440, 900), drawerCash: const Money(1000));
    await _scan(tester, 'KOP');
    await _type(tester, _keyPrefix('purchase-price-'), '1500');
    await _tap(tester, _key('purchase-pay-full'));
    await _tap(tester, _keyPrefix('purchase-funding-'));
    await tester.tap(find.text('Kas laci').last);
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Uang di laci diperkirakan Rp 1.000. Jumlah ini lebih '
        'Rp 500 dari perkiraan; pastikan uangnya ada sebelum melanjutkan.',
      ),
      findsOneWidget,
    );
    await _tap(tester, _key('purchase-receive'));
    expect(_key('purchase-detail'), findsOneWidget);
    expect(repo.requests.last.funding, FundingSource.drawer);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('ponsel 360 px: form halaman sendiri, detail bertumpuk', (
    tester,
  ) async {
    await pump(tester, const Size(360, 780));
    expect(_key('purchase-form'), findsNothing);
    await _tap(tester, _key('purchases-new'));
    expect(_key('purchase-form-page'), findsOneWidget);
    await _scan(tester, 'KOP');
    await _type(tester, _keyPrefix('purchase-price-'), '1500');
    await _tap(tester, _key('purchase-pay-full'));
    await _tap(tester, _key('purchase-receive'));
    expect(_key('purchase-detail'), findsOneWidget);
    expect(find.text('Lunas'), findsOneWidget);
    await _tap(tester, _key('purchase-back'));
    expect(_key('purchases-table'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets(
    'desktop: foto faktur di form lalu lihat, hapus, lampirkan lagi',
    (
      tester,
    ) async {
      await pump(tester, const Size(1440, 900));
      await _scan(tester, 'KOP');
      // Berkas bukan gambar ditolak dengan pesan.
      picker.next = PickedImage(
        name: 'faktur.pdf',
        size: 3,
        bytes: Uint8List.fromList([1, 2, 3]),
      );
      await _tap(tester, _key('purchase-invoice-photo-pick'));
      expect(_key('purchase-invoice-photo-error'), findsOneWidget);
      picker.next = png();
      await _tap(tester, _key('purchase-invoice-photo-pick'));
      expect(_key('purchase-invoice-photo-preview'), findsOneWidget);
      expect(find.text('faktur-sp.png'), findsOneWidget);
      await _type(tester, _keyPrefix('purchase-price-'), '1500');
      await _tap(tester, _key('purchase-pay-full'));
      await _tap(tester, _key('purchase-receive'));
      expect(repo.requests.single.invoicePhoto!.fileName, 'faktur-sp.png');

      // Detail 1.19b: gambar kecil + *Lihat foto faktur*.
      expect(_key('purchase-invoice-photo-thumb'), findsOneWidget);
      await _tap(tester, _key('purchase-invoice-photo-view'));
      expect(_key('purchase-invoice-photo-full'), findsOneWidget);
      await _tap(tester, _key('purchase-invoice-photo-full-close'));
      expect(_key('purchase-invoice-photo-full'), findsNothing);

      // Hapus butuh konfirmasi; batal tidak menghapus.
      await _tap(tester, _key('purchase-invoice-photo-remove'));
      await _tap(tester, _key('purchase-invoice-photo-cancel'));
      expect(repo.purchases.single.invoiceMediaId, isNotNull);
      await _tap(tester, _key('purchase-invoice-photo-remove'));
      await _tap(tester, _key('purchase-invoice-photo-confirm-remove'));
      expect(repo.purchases.single.invoiceMediaId, isNull);
      expect(find.text('Belum ada foto faktur.'), findsOneWidget);
      expect(find.text('Lampirkan foto faktur'), findsOneWidget);

      picker.next = png();
      await _tap(tester, _key('purchase-invoice-photo-pick'));
      expect(_key('purchase-invoice-photo-thumb'), findsOneWidget);
      expect(find.text('Ganti foto'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets('ponsel 360 px: ambil foto faktur dari kamera', (tester) async {
    await pump(tester, const Size(360, 780));
    picker.camera = true;
    await _tap(tester, _key('purchases-new'));
    await _scan(tester, 'KOP');
    picker.next = png();
    await _tap(tester, _key('purchase-invoice-photo-camera'));
    expect(picker.photoCalls, 1);
    expect(_key('purchase-invoice-photo-preview'), findsOneWidget);
    await _type(tester, _keyPrefix('purchase-price-'), '1500');
    await _tap(tester, _key('purchase-pay-full'));
    await _tap(tester, _key('purchase-receive'));
    expect(_key('purchase-detail'), findsOneWidget);
    expect(_key('purchase-invoice-photo-thumb'), findsOneWidget);
    expect(_key('purchase-invoice-photo-camera'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('desktop: cetak PDF pembelian lalu buka kartu stok (F1-12c)', (
    tester,
  ) async {
    await pump(tester, const Size(1440, 900));
    await receiveKop(tester);
    await _tap(tester, _key('purchase-print'));
    expect(
      exporter.saved.single.$1,
      'pembelian-pb-pst-d01-261103-0001.pdf',
    );
    expect(exporter.saved.single.$2.take(4), '%PDF'.codeUnits);
    expect(
      find.text(
        'PDF pembelian disimpan di /home/kasir/Dokumen/Lakuna/pembelian.pdf',
      ),
      findsOneWidget,
    );

    exporter.error = Exception('disk penuh');
    await _tap(tester, _key('purchase-print'));
    expect(_key('purchase-print-failed'), findsOneWidget);

    await _tap(tester, _keyPrefix('purchase-stock-card-'));
    expect(_key('stock-card'), findsOneWidget);
    // Kartu stok produk yang dibeli, di lokasi terima pembelian.
    expect(_key('stock-card-product-${kopVariant().uuid}'), findsOneWidget);
    expect(_key('stock-card-focus-missing'), findsNothing);
    expect(find.text('Toko'), findsWidgets);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('ponsel 360 px: cetak PDF lewat lembar bagikan', (tester) async {
    await pump(tester, const Size(360, 780));
    exporter.path = null;
    await receiveKop(tester, narrow: true);
    await _tap(tester, _key('purchase-print'));
    expect(exporter.saved, hasLength(1));
    expect(_key('purchase-print-saved'), findsNothing);
    expect(_key('purchase-print-failed'), findsNothing);
    expect(_keyPrefix('purchase-stock-card-'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('kartu stok: produk yang tidak ada lagi diberi tahu', (
    tester,
  ) async {
    await pump(tester, const Size(1440, 900), stockHasKop: false);
    await receiveKop(tester);
    await _tap(tester, _keyPrefix('purchase-stock-card-'));
    expect(_key('stock-card-focus-missing'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('tanpa izin Stok: nama produk bukan tautan kartu stok', (
    tester,
  ) async {
    await pump(
      tester,
      const Size(1440, 900),
      session: FakeSessionRepository()
        ..current = StaffProfile(
          id: UuidValue.fromString(newId()),
          name: 'Andi',
          roleKey: 'custom',
          isOwner: false,
          hasPin: true,
          permissions: const {Permission.purchasesManage},
        ),
    );
    await receiveKop(tester);
    expect(_keyPrefix('purchase-stock-card-'), findsNothing);
    expect(_key('purchase-print'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
}
