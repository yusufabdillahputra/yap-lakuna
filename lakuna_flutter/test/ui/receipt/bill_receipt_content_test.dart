import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/l10n/gen/app_localizations.dart';
import 'package:lakuna_flutter/ui/receipt/receipt_content.dart';

/// Isi struk tagihan open bill (F1-10k).
void main() {
  final id = lookupAppLocalizations(const Locale('id'));
  final en = lookupAppLocalizations(const Locale('en'));
  final tenantId = UuidValue.fromString(newId());
  final outletId = UuidValue.fromString(newId());
  final saleId = UuidValue.fromString(newId());

  SaleItem item(String name, int qtyMilli, int price, {int discount = 0}) =>
      SaleItem(
        id: UuidValue.fromString(newId()),
        tenantId: tenantId,
        saleId: saleId,
        variantId: UuidValue.fromString(newId()),
        productName: name,
        variantName: '',
        unitName: 'porsi',
        factorMilli: 1000,
        quantityMilli: qtyMilli,
        listPrice: price,
        unitPrice: price,
        lineTotal: price * qtyMilli ~/ 1000 - discount,
        discountAmount: discount,
        unitCost: 0,
        tracksStock: false,
        sortOrder: 0,
        hlc: '0',
      );

  final nasi = item('Nasi Goreng', 2000, 25000, discount: 5000);
  final teh = item('Es Teh', 2000, 5000);

  Sale sale({bool takeAway = false, SplitMode? split}) => Sale(
    id: saleId,
    tenantId: tenantId,
    outletId: outletId,
    deviceId: UuidValue.fromString(newId()),
    staffId: UuidValue.fromString(newId()),
    number: 'PST-K01-261114-0009',
    billNumber: 'PST-K01-261114-0009',
    status: SaleStatus.open,
    orderType: takeAway ? OrderType.takeAway : OrderType.dineIn,
    queueNumber: takeAway ? 3 : null,
    // Nama pemesan take away tidak dicetak sebagai pelanggan.
    customerName: 'Pak Budi',
    splitMode: split,
    splitGuests: split == null ? null : 2,
    subtotal: 0,
    tierDiscount: 0,
    total: 0,
    paidAmount: 0,
    changeAmount: 0,
    itemCount: 2,
    soldAt: DateTime.utc(2026, 11, 14, 5),
    hlc: '0',
  );

  // Subtotal 55.000 − diskon 10% (5.500) = 49.500; service 5% = 2.475;
  // PB1 10% = 5.198 (dibulatkan); total 57.173 → pembulatan +327 = 57.500.
  const charges = FnbCharges(
    subtotal: Money(55000),
    discount: Money(5500),
    service: Money(2475),
    tax: Money(5198),
    rounding: Money(327),
  );
  const rates = FnbRates(
    service: BasisPoints(500),
    tax: BasisPoints(1000),
    rounding: TotalRounding.nearest500,
  );

  OpenBill bill({
    bool takeAway = false,
    SplitMode? split,
    List<Payment> payments = const [],
    String? customer,
  }) => OpenBill(
    sale: sale(takeAway: takeAway, split: split).copyWith(discountBp: 1000),
    items: [nasi, teh],
    charges: charges,
    rates: rates,
    table: takeAway
        ? null
        : DiningTable(
            tenantId: tenantId,
            outletId: outletId,
            name: 'A5',
            hlc: '0',
          ),
    modifiers: {
      nasi.id: [
        SaleItemModifier(
          tenantId: tenantId,
          saleItemId: nasi.id,
          modifierId: UuidValue.fromString(newId()),
          groupName: 'Level',
          name: 'Pedas',
          priceDelta: 0,
          hlc: '0',
        ),
      ],
    },
    payments: payments,
    customer: customer == null
        ? null
        : BillCustomer(id: UuidValue.fromString(newId()), name: customer),
  );

  const config = ReceiptConfig(
    settings: ReceiptSettings(),
    defaultHeader: 'Jl. Melati No. 12',
    transferAccount: 'BCA 1234567890 a.n. Warung Contoh',
  );

  ReceiptContent content(
    OpenBill b, {
    AppLocalizations? l10n,
    ReceiptConfig cfg = config,
  }) => billReceiptContent(
    l10n ?? id,
    bill: b,
    businessName: 'Warung Contoh',
    outletName: 'Cabang Pusat',
    staffName: 'Sari',
    timezone: 'Asia/Jakarta',
    config: cfg,
    // 08.30 UTC = 15.30 WIB.
    now: DateTime.utc(2026, 11, 14, 8, 30),
  );

  test('banner, meta, barang, rincian F&B, total, rekening', () {
    final c = content(bill(customer: 'Bu Rina'));
    expect(c.storeName, 'WARUNG CONTOH');
    expect(c.header, ['Jl. Melati No. 12']);
    expect(c.banner, 'TAGIHAN - BELUM DIBAYAR');
    expect(c.meta.map((p) => (p.label, p.value)), [
      ('No', 'PST-K01-261114-0009'),
      ('Tgl', '14/11/26 15.30'),
      ('Kasir', 'Sari'),
      ('Pesanan', 'Meja A5'),
      ('Pelanggan', 'Bu Rina'),
    ]);
    expect(c.items.map((i) => (i.name, i.extras.join(), i.detail, i.amount)), [
      ('Nasi Goreng', '+ Pedas', '2 x 25.000', '50.000'),
      ('Es Teh', '', '2 x 5.000', '10.000'),
    ]);
    expect(c.items.first.discount?.value, '-5.000');
    expect(c.totals.map((p) => (p.label, p.value, p.bold)), [
      ('Subtotal', '55.000', false),
      ('Diskon 10%', '-5.500', false),
      ('Service 5%', '2.475', false),
      ('PB1 10%', '5.198', false),
      ('Pembulatan', '327', false),
      ('TOTAL', '57.500', true),
      ('Transfer ke: BCA 1234567890 a.n. Warung Contoh', '', false),
    ]);
    expect(c.footer, ['Terima kasih, sampai jumpa lagi!']);
  });

  test('beberapa rekening (F1-05f): satu baris per rekening', () {
    final c = content(
      bill(),
      cfg: const ReceiptConfig(
        settings: ReceiptSettings(),
        transferAccount: 'BCA 1234567890\nMandiri 987 654',
      ),
    );
    expect(c.totals.map((p) => p.label).skip(c.totals.length - 2), [
      'Transfer ke: BCA 1234567890',
      'Transfer ke: Mandiri 987 654',
    ]);
  });

  test('take away memakai label antrean; tanpa rekening tanpa baris', () {
    final c = content(
      bill(takeAway: true),
      cfg: const ReceiptConfig(settings: ReceiptSettings()),
    );
    expect(
      c.meta.map((p) => (p.label, p.value)),
      contains(('Pesanan', 'Take away TA-03')),
    );
    expect(c.totals.last.label, 'TOTAL');
    // Nama pemesan take away bukan pelanggan terdaftar.
    expect(c.meta.map((p) => p.label), isNot(contains('Pelanggan')));
    expect(c.meta.map((p) => p.value), isNot(contains('Pak Budi')));
  });

  test('diskon nota rupiah berlabel Diskon tanpa persen', () {
    final b = bill();
    final rupiah = OpenBill(
      sale: b.sale.copyWith(discountBp: 0, discountAmount: 5500),
      items: b.items,
      charges: b.charges,
      rates: b.rates,
      table: b.table,
    );
    expect(
      content(rupiah).totals.map((p) => (p.label, p.value)),
      contains(('Diskon', '-5.500')),
    );
  });

  test('split sebagian dibayar: Sudah dibayar dan Sisa tagihan', () {
    final paid = Payment(
      tenantId: tenantId,
      saleId: saleId,
      method: PaymentMethod.cash,
      amount: 30000,
      changeAmount: 1250,
      status: PaymentStatus.paid,
      guestLabel: 'A',
      paidAt: DateTime.utc(2026, 11, 14, 8),
      hlc: '0',
    );
    final c = content(bill(split: SplitMode.equal, payments: [paid]));
    final rows = c.totals.map((p) => (p.label, p.value, p.bold)).toList();
    final total = rows.indexWhere((r) => r.$1 == 'TOTAL');
    expect(rows.sublist(total), [
      ('TOTAL', '57.500', true),
      ('Sudah dibayar', '-28.750', false),
      ('Sisa tagihan', '28.750', true),
      ('Transfer ke: BCA 1234567890 a.n. Warung Contoh', '', false),
    ]);
  });

  test('QRIS bagian menunggu konfirmasi disebut di bawah sisa', () {
    final pending = Payment(
      tenantId: tenantId,
      saleId: saleId,
      method: PaymentMethod.qrisStatic,
      amount: 28750,
      changeAmount: 0,
      status: PaymentStatus.pending,
      guestLabel: 'A',
      paidAt: DateTime.utc(2026, 11, 14, 8),
      hlc: '0',
    );
    final rows = content(
      bill(split: SplitMode.equal, payments: [pending]),
    ).totals.map((p) => (p.label, p.value, p.bold)).toList();
    final total = rows.indexWhere((r) => r.$1 == 'TOTAL');
    expect(rows.sublist(total, total + 2), [
      ('TOTAL', '57.500', true),
      ('Menunggu konfirmasi', '28.750', false),
    ]);
  });

  test('bahasa Inggris dan tata letak 58 mm', () {
    final c = content(bill(), l10n: en);
    expect(c.banner, 'BILL - NOT PAID');
    expect(c.meta[3], isA<ReceiptPair>());
    expect((c.meta[3].label, c.meta[3].value), ('Order', 'Table A5'));
    final lines = layoutReceipt(c, ReceiptPaper.mm58);
    expect(lines.every((l) => l.text.length <= 32), isTrue);
    expect(lines.any((l) => l.text == 'BILL - NOT PAID'), isTrue);
  });
}
