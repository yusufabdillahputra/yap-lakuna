import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/l10n/gen/app_localizations.dart';
import 'package:lakuna_flutter/ui/receipt/receipt_content.dart';

void main() {
  final id = lookupAppLocalizations(const Locale('id'));
  final en = lookupAppLocalizations(const Locale('en'));
  final saleId = UuidValue.fromString(newId());
  final tenantId = UuidValue.fromString(newId());

  SaleItem item(
    String name,
    String variant,
    int qtyMilli,
    int price, {
    String unit = 'pcs',
    bool convertedUnit = false,
  }) => SaleItem(
    tenantId: tenantId,
    saleId: saleId,
    variantId: UuidValue.fromString(newId()),
    productUnitId: convertedUnit ? UuidValue.fromString(newId()) : null,
    productName: name,
    variantName: variant,
    unitName: unit,
    factorMilli: 1000,
    quantityMilli: qtyMilli,
    listPrice: price,
    unitPrice: price,
    lineTotal: price * qtyMilli ~/ 1000,
    unitCost: 0,
    tracksStock: true,
    sortOrder: 0,
    hlc: '0',
  );

  Payment pay(
    PaymentMethod method,
    int amount, {
    int change = 0,
    String? reference,
  }) => Payment(
    tenantId: tenantId,
    saleId: saleId,
    method: method,
    amount: amount,
    changeAmount: change,
    reference: reference,
    status: PaymentStatus.paid,
    paidAt: DateTime.utc(2026, 11, 3, 9, 5),
    hlc: '0',
  );

  CheckoutResult result(List<Payment> payments) => CheckoutResult(
    sale: Sale(
      tenantId: tenantId,
      outletId: UuidValue.fromString(newId()),
      deviceId: UuidValue.fromString(newId()),
      cashSessionId: UuidValue.fromString(newId()),
      staffId: UuidValue.fromString(newId()),
      number: 'PST-K01-261103-0007',
      status: SaleStatus.completed,
      subtotal: 181500,
      tierDiscount: 0,
      total: 181500,
      paidAmount: payments.fold(0, (s, p) => s + p.amount),
      changeAmount: payments.fold(0, (s, p) => s + p.changeAmount),
      itemCount: 2,
      // 09.05 UTC = 16.05 WIB.
      soldAt: DateTime.utc(2026, 11, 3, 9, 5),
      hlc: '0',
    ),
    items: [
      item('Beras Premium', '5 kg', 2000, 70000),
      item('Minyak Goreng', '', 1500, 27000, unit: 'Dus', convertedUnit: true),
    ],
    payments: payments,
  );

  const config = ReceiptConfig(
    settings: ReceiptSettings(),
    defaultHeader: 'Jl. Melati No. 12\n0812-0000-0001',
  );

  test('nota tunai: header, meta, barang, total, kembalian, footer', () {
    final content = saleReceiptContent(
      id,
      result: result([pay(PaymentMethod.cash, 200000, change: 18500)]),
      businessName: 'Warung Contoh',
      outletName: 'Cabang Pusat',
      staffName: 'Sari',
      timezone: 'Asia/Jakarta',
      config: config,
    );
    expect(content.storeName, 'WARUNG CONTOH');
    expect(content.outletName, 'Cabang Pusat');
    expect(content.header, ['Jl. Melati No. 12', '0812-0000-0001']);
    expect(
      content.meta.map((p) => (p.label, p.value)),
      [
        ('No', 'PST-K01-261103-0007'),
        ('Tgl', '03/11/26 16.05'),
        ('Kasir', 'Sari'),
      ],
    );
    expect(content.items.map((i) => (i.name, i.detail, i.amount)), [
      ('Beras Premium 5 kg', '2 x 70.000', '140.000'),
      ('Minyak Goreng', '1,5 Dus x 27.000', '40.500'),
    ]);
    expect(content.totals.map((p) => (p.label, p.value, p.bold)), [
      ('TOTAL', '181.500', true),
      ('Tunai', '200.000', false),
      ('Kembali', '18.500', false),
    ]);
    expect(content.footer, ['Terima kasih, sampai jumpa lagi!']);
  });

  test('split tanpa tunai: tanpa Kembali; footer kustom; bahasa Inggris', () {
    final content = saleReceiptContent(
      en,
      result: result([
        pay(PaymentMethod.card, 100000),
        pay(PaymentMethod.qrisStatic, 81500),
      ]),
      businessName: 'Warung Contoh',
      outletName: 'Cabang Pusat',
      staffName: 'Sari',
      timezone: 'Asia/Jakarta',
      config: const ReceiptConfig(
        settings: ReceiptSettings(header: '', footer: 'See you\nIG @warung'),
      ),
    );
    expect(content.header, isEmpty);
    expect(content.totals.map((p) => p.label), [
      'TOTAL',
      'Debit / credit card',
      'Static QRIS',
    ]);
    expect(content.totals.first.value, '181,500');
    expect(content.footer, ['See you', 'IG @warung']);
  });

  test('referensi kartu/transfer tercetak di bawah pembayarannya (F1-05b)', () {
    ReceiptContent content(AppLocalizations l10n) => saleReceiptContent(
      l10n,
      result: result([
        pay(PaymentMethod.card, 100000, reference: '004512'),
        pay(PaymentMethod.transfer, 50000, reference: 'TRF-0211-883'),
        pay(PaymentMethod.transfer, 20000),
        pay(PaymentMethod.cash, 20000, change: 8500),
      ]),
      businessName: 'Warung Contoh',
      outletName: 'Cabang Pusat',
      staffName: 'Sari',
      timezone: 'Asia/Jakarta',
      config: config,
    );
    expect(content(id).totals.map((p) => (p.label, p.value)), [
      ('TOTAL', '181.500'),
      ('Kartu debit / kredit', '100.000'),
      ('  No. approval', '004512'),
      ('Transfer bank', '50.000'),
      ('  Ref. transfer', 'TRF-0211-883'),
      ('Transfer bank', '20.000'),
      ('Tunai', '20.000'),
      ('Kembali', '8.500'),
    ]);
    expect(
      content(en).totals.map((p) => p.label),
      contains('  Approval no.'),
    );
    expect(
      content(en).totals.map((p) => p.label),
      contains('  Transfer ref.'),
    );
  });

  test('struk contoh untuk pratinjau dan tes cetak', () {
    final content = sampleReceiptContent(
      id,
      businessName: 'Warung Contoh',
      outletName: 'Cabang Pusat',
      staffName: 'Sari',
      config: config,
      now: DateTime(2026, 11, 3, 10, 44),
    );
    expect(content.items, hasLength(3));
    expect(content.totals.first.value, '180.000');
    expect(content.meta[1].value, '03/11/26 10.44');
    final lines = layoutReceipt(content, ReceiptPaper.mm58);
    expect(lines.every((l) => l.text.length <= 32), isTrue);
  });

  test('nota open bill F&B: pesanan, subtotal, service, PB1', () {
    final base = result([pay(PaymentMethod.cash, 210000, change: 1735)]);
    final content = saleReceiptContent(
      id,
      result: CheckoutResult(
        sale: base.sale.copyWith(
          serviceBp: 500,
          taxBp: 1050,
          serviceAmount: 9075,
          taxAmount: 20010,
          total: 208265,
        ),
        items: base.items,
        payments: base.payments,
      ),
      businessName: 'Warung Contoh',
      outletName: 'Cabang Pusat',
      staffName: 'Sari',
      timezone: 'Asia/Jakarta',
      config: config,
      orderLabel: 'Meja M4',
    );
    expect(content.meta.last.label, 'Pesanan');
    expect(content.meta.last.value, 'Meja M4');
    expect(content.totals.map((p) => (p.label, p.value)).take(4), [
      ('Subtotal', '180.500'),
      ('Service 5%', '9.075'),
      ('PB1 10,5%', '20.010'),
      ('TOTAL', '208.265'),
    ]);
    expect(percentLabel(en, 1050), '10.5%');
    expect(percentLabel(id, 1225), '12,25%');
  });

  test('PB1 termasuk harga dan pembulatan total', () {
    final base = result([pay(PaymentMethod.cash, 200000, change: 18000)]);
    final content = saleReceiptContent(
      id,
      result: CheckoutResult(
        sale: base.sale.copyWith(
          taxBp: 1000,
          taxAmount: 16409,
          taxInclusive: true,
          roundingAmount: -500,
          total: 180000,
        ),
        items: base.items,
        payments: base.payments,
      ),
      businessName: 'Warung Contoh',
      outletName: 'Cabang Pusat',
      staffName: 'Sari',
      timezone: 'Asia/Jakarta',
      config: config,
    );
    expect(content.totals.map((p) => (p.label, p.value)).take(4), [
      ('Subtotal', '180.500'),
      ('PB1 10% (termasuk)', '16.409'),
      ('Pembulatan', '-500'),
      ('TOTAL', '180.000'),
    ]);
  });

  test('nota retail dengan pembulatan menampilkan subtotal dan selisih', () {
    final base = result([pay(PaymentMethod.cash, 181000)]);
    final content = saleReceiptContent(
      id,
      result: CheckoutResult(
        sale: base.sale.copyWith(roundingAmount: 500, total: 181000),
        items: base.items,
        payments: base.payments,
      ),
      businessName: 'Warung Contoh',
      outletName: 'Cabang Pusat',
      staffName: 'Sari',
      timezone: 'Asia/Jakarta',
      config: config,
    );
    expect(content.totals.map((p) => (p.label, p.value)).take(3), [
      ('Subtotal', '180.500'),
      ('Pembulatan', '500'),
      ('TOTAL', '181.000'),
    ]);
  });

  test('diskon baris dan diskon nota', () {
    final base = result([pay(PaymentMethod.cash, 170000)]);
    final first = base.items.first;
    final content = saleReceiptContent(
      id,
      result: CheckoutResult(
        sale: base.sale.copyWith(
          discountAmount: 8000,
          discountBp: 500,
          lineDiscountAmount: 2500,
          total: 170000,
        ),
        items: [
          first.copyWith(
            lineTotal: first.lineTotal - 2500,
            discountAmount: 2500,
          ),
          ...base.items.skip(1),
        ],
        payments: base.payments,
      ),
      businessName: 'Warung Contoh',
      outletName: 'Cabang Pusat',
      staffName: 'Sari',
      timezone: 'Asia/Jakarta',
      config: config,
    );
    final item = content.items.first;
    expect(item.amount, receiptAmount(id, first.lineTotal));
    expect((item.discount!.label, item.discount!.value), ('Diskon', '-2.500'));
    expect(content.totals.map((p) => (p.label, p.value)).take(3), [
      ('Subtotal', '178.000'),
      ('Diskon 5%', '-8.000'),
      ('TOTAL', '170.000'),
    ]);
  });

  test('porsi split bill digabung kembali ke baris asal', () {
    final kopi = item('Kopi', '', 1000, 24000).copyWith(guestLabel: 'B');
    final nasi = item('Nasi', '', 1000, 29000);
    final portion = item('Kopi', '', 1000, 24000).copyWith(
      id: UuidValue.fromString(newId()),
      guestLabel: 'A',
      splitFromItemId: kopi.id,
    );
    final merged = mergeSplitPortions([kopi, nasi, portion]);
    expect(merged.map((i) => i.productName), ['Kopi', 'Nasi']);
    expect(merged.first.quantityMilli, 2000);
    expect(merged.first.lineTotal, 48000);
  });

  test('porsi berdiskon baris: potongan dijumlah, diskon beda terpisah', () {
    final kopi = item(
      'Kopi',
      '',
      1000,
      21600,
    ).copyWith(discountBp: 1000, discountAmount: 2400);
    final portion = kopi.copyWith(
      id: UuidValue.fromString(newId()),
      guestLabel: 'A',
      splitFromItemId: kopi.id,
    );
    // Porsi ketiga diubah ke diskon rupiah setelah dibagi.
    final other = item('Kopi', '', 1000, 19000).copyWith(
      id: UuidValue.fromString(newId()),
      guestLabel: 'B',
      splitFromItemId: kopi.id,
      discountAmount: 5000,
    );
    final merged = mergeSplitPortions([kopi, portion, other]);
    expect(merged, hasLength(2));
    expect(merged.first.quantityMilli, 2000);
    expect(merged.first.lineTotal, 43200);
    expect(merged.first.discountAmount, 4800);
    expect(merged.first.discountBp, 1000);
    expect(merged.last.discountAmount, 5000);
    expect(merged.last.lineTotal, 19000);
  });
}
