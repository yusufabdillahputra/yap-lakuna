import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/customers_repository.dart';
import 'package:lakuna_flutter/l10n/gen/app_localizations.dart';
import 'package:lakuna_flutter/ui/customers/kuitansi_content.dart';

/// Rekening transfer di kuitansi bila masih ada sisa piutang (F1-05e).
void main() {
  final id = lookupAppLocalizations(const Locale('id'));
  final en = lookupAppLocalizations(const Locale('en'));
  final tenantId = UuidValue.fromString(newId());

  DebtPaymentReceipt receipt({int balanceAfter = 250000, bool voided = false}) {
    final customerId = UuidValue.fromString(newId());
    return DebtPaymentReceipt(
      payment: DebtPayment(
        tenantId: tenantId,
        outletId: UuidValue.fromString(newId()),
        deviceId: UuidValue.fromString(newId()),
        staffId: UuidValue.fromString(newId()),
        party: DebtParty.customer,
        customerId: customerId,
        number: 'BP-PST-K01-261114-0001',
        amount: 100000,
        method: PaymentMethod.cash,
        paidOn: DateTime.utc(2026, 11, 14),
        balanceAfter: balanceAfter,
        voidedAt: voided ? DateTime.utc(2026, 11, 14, 5) : null,
        voidReason: voided ? 'Salah pelanggan' : null,
        createdAt: DateTime.utc(2026, 11, 14, 3),
        hlc: '0',
      ),
      customer: Customer(
        id: customerId,
        tenantId: tenantId,
        name: 'Bu Rina',
        hlc: '0',
      ),
      lines: [
        DebtReceiptLine(
          saleNumber: 'PST-K01-261102-0001',
          soldAt: DateTime.utc(2026, 11, 2),
          dueOn: null,
          balanceBefore: const Money(350000),
          amount: const Money(100000),
        ),
      ],
      staffName: 'Sari',
    );
  }

  CustomersSetup setup(String account) => CustomersSetup(
    today: DateTime.utc(2026, 11, 14),
    businessName: 'Warung Contoh',
    outletName: 'Cabang Pusat',
    timezone: 'Asia/Jakarta',
    receipt: ReceiptConfig(
      settings: const ReceiptSettings(),
      transferAccount: account,
    ),
  );

  const account = 'BCA 1234567890 a.n. Toko Maju';

  List<String> thermal(
    DebtPaymentReceipt r, {
    String acc = account,
    bool showBalance = true,
    AppLocalizations? l10n,
  }) => [
    for (final p in kuitansiReceiptContent(
      l10n ?? id,
      receipt: r,
      setup: setup(acc),
      copy: false,
      showDetails: true,
      showBalance: showBalance,
    ).totals)
      '${p.label}|${p.value}',
  ];

  List<String> a5(
    DebtPaymentReceipt r, {
    String acc = account,
    bool showBalance = true,
  }) => [
    for (final f in kuitansiDocument(
      id,
      receipt: r,
      setup: setup(acc),
      copy: false,
      showDetails: true,
      showBalance: showBalance,
      city: '',
    ).fields)
      '${f.label}|${f.value}',
  ];

  test('thermal: rekening setelah sisa piutang', () {
    expect(thermal(receipt()), [
      'DIBAYAR|100.000',
      'Tunai · kas toko|',
      'Sisa piutang|250.000',
      'Transfer ke: $account|',
    ]);
    expect(thermal(receipt(), l10n: en).last, 'Transfer to: $account|');
  });

  test('thermal: lunas, sisa disembunyikan, batal, atau rekening kosong '
      'tanpa baris', () {
    bool has(List<String> lines) =>
        lines.any((l) => l.startsWith('Transfer ke'));
    expect(has(thermal(receipt(balanceAfter: 0))), isFalse);
    expect(has(thermal(receipt(), showBalance: false)), isFalse);
    expect(has(thermal(receipt(voided: true))), isFalse);
    expect(has(thermal(receipt(), acc: '')), isFalse);
  });

  test('A5: isian Transfer ke setelah Metode', () {
    final fields = a5(receipt());
    final method = fields.indexWhere((f) => f.startsWith('Metode|'));
    expect(fields[method + 1], 'Transfer ke|$account');

    bool has(List<String> f) => f.any((l) => l.startsWith('Transfer ke|'));
    expect(has(a5(receipt(balanceAfter: 0))), isFalse);
    expect(has(a5(receipt(), showBalance: false)), isFalse);
    expect(has(a5(receipt(voided: true))), isFalse);
    expect(has(a5(receipt(), acc: ' ')), isFalse);
  });
}
