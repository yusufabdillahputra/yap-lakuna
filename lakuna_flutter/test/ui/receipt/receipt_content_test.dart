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

  Payment pay(PaymentMethod method, int amount, {int change = 0}) => Payment(
    tenantId: tenantId,
    saleId: saleId,
    method: method,
    amount: amount,
    changeAmount: change,
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
}
