import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/cash_drawer_repository.dart';
import 'package:lakuna_flutter/l10n/gen/app_localizations.dart';
import 'package:lakuna_flutter/ui/cash_session/session_recap_content.dart';

void main() {
  final id = lookupAppLocalizations(const Locale('id'));
  final en = lookupAppLocalizations(const Locale('en'));
  final tenant = UuidValue.fromString(newId());
  final outlet = UuidValue.fromString(newId());

  // 01.00 UTC = 08.00 WIB.
  final opened = CashSession(
    tenantId: tenant,
    outletId: outlet,
    deviceId: UuidValue.fromString(newId()),
    status: CashSessionStatus.opened,
    openedBy: UuidValue.fromString(newId()),
    openedAt: DateTime.utc(2026, 11, 13, 1),
    openingCash: 200000,
    hlc: 'h',
  );

  CashMovement movement(CashDirection d, int amount, String note, int hour) =>
      CashMovement(
        tenantId: tenant,
        outletId: outlet,
        cashSessionId: opened.id,
        direction: d,
        amount: amount,
        note: note,
        createdAt: DateTime.utc(2026, 11, 13, hour, 15),
        hlc: 'h',
      );

  final movements = [
    movement(CashDirection.outflow, 20000, 'Beli es batu', 3),
    movement(CashDirection.inflow, 50000, 'Tambah kembalian', 4),
  ];

  SessionRecap recap({int difference = -5000, String? note = 'Uang pas'}) {
    const count = CashCount(sheets: {100000: 3, 50000: 4}, coins: Money(5000));
    final drawer = cashDrawerOf(
      opened,
      movements,
      cashSales: const Money(300000),
    );
    return SessionRecap(
      active: ActiveCashSession(
        session: opened,
        openedByName: 'Yusuf',
        movements: movements,
        drawer: drawer,
        sales: const SessionSalesSummary(
          count: 12,
          total: Money(450000),
          cash: Money(300000),
          nonCash: Money(150000),
          voidCount: 1,
        ),
      ),
      closed: opened.copyWith(
        status: CashSessionStatus.closed,
        closedAt: DateTime.utc(2026, 11, 13, 10),
        expectedCash: 530000,
        countedCash: 505000,
        difference: difference,
        countedBreakdown: jsonEncode(count.toJson()),
        closingNote: note,
      ),
      closerName: 'Sari',
    );
  }

  ReceiptContent content(AppLocalizations l10n, SessionRecap r) =>
      sessionRecapContent(
        l10n,
        recap: r,
        businessName: 'Warung Contoh',
        outletName: 'Cabang Pusat',
        deviceCode: 'K01',
        timezone: 'Asia/Jakarta',
      );

  String p(String label, String value) =>
      '$label${' ' * (32 - label.length - value.length)}$value';

  test('rekap 58 mm: info, penjualan, kas laci, gerakan, hitung, selisih', () {
    final lines = layoutReceipt(content(id, recap()), ReceiptPaper.mm58);
    final rule = '-' * 32;
    expect(lines.map((l) => l.text), [
      'Warung Contoh',
      'Cabang Pusat',
      rule,
      'REKAP SESI KASIR',
      rule,
      p('Perangkat', 'K01'),
      p('Dibuka', '13/11/26 08.00'),
      p('Dibuka oleh', 'Yusuf'),
      p('Ditutup', '13/11/26 17.00'),
      p('Ditutup oleh', 'Sari'),
      rule,
      p('Transaksi', '12'),
      p('Penjualan', '450.000'),
      p('Tunai', '300.000'),
      p('Non-tunai', '150.000'),
      p('Void / retur', '1 / 0'),
      rule,
      p('Saldo awal', '200.000'),
      p('Penjualan tunai', '300.000'),
      p('Uang masuk', '50.000'),
      p('Uang keluar', '-20.000'),
      rule,
      p('10.15 Beli es batu', '-20.000'),
      p('11.15 Tambah kembalian', '50.000'),
      rule,
      p('100.000 x 3', '300.000'),
      p('50.000 x 4', '200.000'),
      p('Receh', '5.000'),
      rule,
      p('Seharusnya di laci', '530.000'),
      p('Uang dihitung', '505.000'),
      p('Selisih', '-5.000'),
      rule,
      'Catatan: Uang pas',
    ]);
    final bold = {
      for (final l in lines)
        if (l.bold) l.text,
    };
    expect(bold, contains('REKAP SESI KASIR'));
    expect(bold, contains(p('Seharusnya di laci', '530.000')));
    expect(bold, contains(p('Selisih', '-5.000')));
  });

  test('selisih pas tanpa catatan; bahasa Inggris', () {
    final lines = layoutReceipt(
      content(en, recap(difference: 0, note: null)),
      ReceiptPaper.mm58,
    ).map((l) => l.text).toList();
    expect(lines, contains('CASH SESSION RECAP'));
    expect(lines, contains(p('Difference', 'Exact')));
    expect(lines, contains(p('Opening cash', '200,000')));
    expect(lines.last, isNot(startsWith('Note')));
  });
}
