import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/table_file.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_customers_repository.dart';
import '../../testing/fake_receipt_printer.dart';
import '../../testing/fake_session_repository.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

Finder _keyPrefix(String prefix) => find.byWidgetPredicate(
  (w) =>
      w.key is ValueKey<String> &&
      (w.key! as ValueKey<String>).value.startsWith(prefix),
);

/// Baris nota belum lunas di panel pelanggan.
Finder _openRows() => find.byWidgetPredicate(
  (w) =>
      w.key is ValueKey<String> &&
      (w.key! as ValueKey<String>).value.startsWith('customer-open-') &&
      (w.key! as ValueKey<String>).value != 'customer-open-table',
);

Finder _input(Finder field) =>
    find.descendant(of: field, matching: find.byType(EditableText));

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, Finder field, String text) async {
  await tester.ensureVisible(field);
  await tester.enterText(_input(field), text);
  await tester.pumpAndSettle();
}

class _Picker extends TableFilePicker {
  _Picker(this.file);

  final PickedTableFile? file;

  @override
  Future<PickedTableFile?> pickTable({required int maxBytes}) async => file;
}

PickedTableFile _csv(String text) {
  final bytes = Uint8List.fromList(utf8.encode(text));
  return PickedTableFile(
    name: 'pelanggan.csv',
    size: bytes.length,
    bytes: bytes,
  );
}

void main() {
  late FakeCustomersRepository repo;
  late FakeReceiptPrinter printer;

  Future<void> pump(
    WidgetTester tester,
    Size size, {
    FakeCustomersRepository? customers,
    FakeSessionRepository? session,
    String location = Routes.customers,
  }) async {
    repo = customers ?? FakeCustomersRepository();
    printer = FakeReceiptPrinter();
    await pumpLakuna(
      tester,
      size: size,
      initialLocation: location,
      customers: repo,
      receiptPrinter: printer,
      session: session,
    );
  }

  UuidValue idOf(String name) =>
      repo.customers.firstWhere((c) => c.name == name).id;

  testWidgets(
    'desktop: pilih pelanggan → terima pembayaran → kuitansi A5 → riwayat',
    (tester) async {
      await pump(tester, const Size(1440, 900));
      expect(_keyPrefix('customers-row-'), findsNWidgets(4));
      expect(_key('customers-pick-hint'), findsOneWidget);
      // Total piutang 1.150.000 + 640.000 + 275.000.
      expect(
        find.descendant(
          of: _key('customers-total'),
          matching: find.text('Rp 2.065.000'),
        ),
        findsOneWidget,
      );

      final ani = idOf('Toko Bu Ani');
      await _tap(tester, _key('customers-row-${ani.uuid}'));
      expect(_key('customer-panel-${ani.uuid}'), findsOneWidget);
      expect(_openRows(), findsNWidgets(3));

      // 650.000 melunasi nota terlama (500.000) dan 150.000 nota kedua.
      await _type(tester, _key('customer-amount-0'), '650000');
      await _tap(tester, _key('customer-receive'));
      expect(repo.requests, hasLength(1));
      expect(repo.requests.single.amount, Money(650000));
      expect(repo.requests.single.allocations, isNull);
      final payment = repo.payments.single;
      expect(payment.balanceAfter, 500000);

      // Simpan langsung membuka kuitansi.
      expect(_key('kuitansi-panel'), findsOneWidget);
      expect(find.text(payment.number), findsWidgets);
      await _tap(tester, _key('kuitansi-print'));
      expect(printer.documentPrints, hasLength(1));
      expect(
        String.fromCharCodes(printer.documentPrints.single.$1.take(5)),
        '%PDF-',
      );

      await _tap(tester, _key('kuitansi-back'));
      expect(_key('customer-panel-${ani.uuid}'), findsOneWidget);
      expect(_key('customer-payment-${payment.id.uuid}'), findsOneWidget);
      expect(_openRows(), findsNWidgets(2));

      // Cari menyaring nama/HP.
      await _type(tester, _key('customers-search'), 'kantin');
      expect(_keyPrefix('customers-row-'), findsOneWidget);
    },
  );

  testWidgets('desktop: alokasi manual harus sama dengan jumlah bayar', (
    tester,
  ) async {
    await pump(tester, const Size(1440, 900));
    final ani = idOf('Toko Bu Ani');
    await _tap(tester, _key('customers-row-${ani.uuid}'));
    await _type(tester, _key('customer-amount-0'), '300000');
    await _tap(tester, _key('customer-manual'));
    final newest = repo.sales[ani]!.last.$1.id;
    final oldest = repo.sales[ani]!.first.$1.id;
    // Mode manual diisi awal dengan alokasi otomatis (semua ke nota terlama).
    expect(
      find.descendant(
        of: _key('customer-alloc-${oldest.uuid}-1'),
        matching: find.text('300.000'),
      ),
      findsOneWidget,
    );
    await _type(tester, _key('customer-alloc-${oldest.uuid}-1'), '100000');
    // Kurang 200.000 → tombol simpan mati.
    expect(tester.widget<FButton>(_key('customer-receive')).onPress, isNull);
    await _type(tester, _key('customer-alloc-${newest.uuid}-1'), '200000');
    await _tap(tester, _key('customer-receive'));
    expect(repo.requests.single.allocations, {
      newest: Money(200000),
      oldest: Money(100000),
    });
  });

  testWidgets('desktop: tambah pelanggan baru dengan grup baru', (
    tester,
  ) async {
    await pump(tester, const Size(1440, 900));
    await _tap(tester, _key('customers-new'));
    expect(_key('customer-form'), findsOneWidget);
    // Simpan kosong → galat nama, tidak tersimpan.
    await _tap(tester, _key('customer-form-save'));
    expect(repo.customers, hasLength(4));
    await _type(tester, _key('customer-form-name'), 'Bu Wati');
    await _type(tester, _key('customer-form-phone'), '0813-1111-2222');
    await _type(tester, _key('customer-form-limit'), '750000');
    await _tap(tester, _key('customer-form-save'));
    final wati = repo.customers.firstWhere((c) => c.name == 'Bu Wati');
    expect(wati.phone, '081311112222');
    expect(wati.creditLimit, 750000);
    expect(_key('customer-form'), findsNothing);
    expect(_key('customer-panel-${wati.id.uuid}'), findsOneWidget);
    expect(_key('customer-no-debt'), findsOneWidget);
  });

  testWidgets(
    'desktop: import CSV memperbarui & menambah, baris salah ditolak',
    (
      tester,
    ) async {
      repo = FakeCustomersRepository();
      printer = FakeReceiptPrinter();
      await pumpLakuna(
        tester,
        size: const Size(1440, 900),
        initialLocation: Routes.customers,
        customers: repo,
        receiptPrinter: printer,
        tablePicker: _Picker(
          _csv(
            'Nama,No. HP,Limit kredit\n'
            'Toko Bu Ani,081322221010,3000000\n'
            'Bu Wati,81311112222,0\n'
            ',0812,0\n',
          ),
        ),
      );
      await _tap(tester, _key('customers-import'));
      await _tap(tester, _key('customer-import-pick'));
      expect(_key('customer-import-ready'), findsOneWidget);
      expect(_key('customer-import-rejected'), findsOneWidget);
      await _tap(tester, _key('customer-import-run'));
      expect(repo.imported.single, hasLength(2));
      expect(_key('customer-import-done'), findsOneWidget);
      await _tap(tester, _key('customer-import-close'));
      expect(_keyPrefix('customers-row-'), findsNWidgets(5));
    },
  );

  for (final size in const [Size(1280, 800), Size(360, 740)]) {
    testWidgets('batal pembayaran piutang ${size.width.toInt()} px (F1-13c)', (
      tester,
    ) async {
      final customers = FakeCustomersRepository();
      final ani = customers.customers.firstWhere(
        (c) => c.name == 'Toko Bu Ani',
      );
      await customers.receivePayment(
        DebtPaymentRequest(
          customerId: ani.id,
          amount: const Money(650000),
          method: PaymentMethod.cash,
          paidOn: DateTime.utc(2026, 11, 3),
        ),
      );
      final payment = customers.payments.single;
      await pump(tester, size, customers: customers);
      await _tap(tester, _key('customers-row-${ani.id.uuid}'));
      expect(_openRows(), findsNWidgets(2));

      await _tap(tester, _key('customer-payment-void-${payment.id.uuid}'));
      expect(_key('debt-void-dialog'), findsOneWidget);
      expect(_key('debt-void-drawer'), findsOneWidget);
      // Alasan wajib.
      await _tap(tester, _key('debt-void-confirm'));
      expect(repo.voids, isEmpty);
      expect(
        find.text('Alasan wajib diisi, maksimal 200 karakter.'),
        findsOneWidget,
      );
      await _type(tester, _key('debt-void-reason'), 'Salah nominal');
      await _tap(tester, _key('debt-void-confirm'));
      expect(repo.voids.single, (payment.id, 'Salah nominal'));
      expect(_key('debt-void-dialog'), findsNothing);
      expect(
        _key('customer-payment-voided-${payment.id.uuid}'),
        findsOneWidget,
      );
      expect(find.text('Batal: Salah nominal'), findsOneWidget);
      if (size.width >= 1280) {
        // Ringkasan daftar ikut diperbarui.
        expect(
          find.descendant(
            of: _key('customers-total'),
            matching: find.text('Rp 2.065.000'),
          ),
          findsOneWidget,
        );
      }
      expect(_key('customer-payment-void-${payment.id.uuid}'), findsNothing);
      expect(_openRows(), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('batal pembayaran: galat sesi kasir tampil di dialog', (
    tester,
  ) async {
    final customers = FakeCustomersRepository();
    final ani = customers.customers.firstWhere((c) => c.name == 'Toko Bu Ani');
    await customers.receivePayment(
      DebtPaymentRequest(
        customerId: ani.id,
        amount: const Money(100000),
        method: PaymentMethod.cash,
        paidOn: DateTime.utc(2026, 11, 3),
      ),
    );
    customers.hasOpenSession = false;
    final payment = customers.payments.single;
    await pump(tester, const Size(1280, 800), customers: customers);
    await _tap(tester, _key('customers-row-${ani.id.uuid}'));
    await _tap(tester, _key('customer-payment-void-${payment.id.uuid}'));
    await _type(tester, _key('debt-void-reason'), 'Salah');
    await _tap(tester, _key('debt-void-confirm'));
    expect(_key('debt-void-error'), findsOneWidget);
    expect(
      find.text('Buka sesi kasir dulu: uang laci perlu dijurnal balik.'),
      findsOneWidget,
    );
    await _tap(tester, _key('debt-void-back'));
    expect(_key('debt-void-dialog'), findsNothing);
  });

  testWidgets('mobile: buka pelanggan di halaman sendiri, lalu kembali', (
    tester,
  ) async {
    await pump(tester, const Size(360, 740));
    final sri = idOf('Warung Mbak Sri');
    await _tap(tester, _key('customers-row-${sri.uuid}'));
    expect(_key('customer-back'), findsOneWidget);
    expect(_key('customer-panel-${sri.uuid}'), findsOneWidget);
    await _tap(tester, _key('customer-pay-all'));
    await _tap(tester, _key('customer-receive'));
    expect(repo.requests.single.amount, Money(275000));
    expect(_key('kuitansi-panel'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _tap(tester, _key('kuitansi-back'));
    expect(_key('customer-no-debt'), findsOneWidget);
    await _tap(tester, _key('customer-back'));
    expect(_keyPrefix('customers-row-'), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tanpa izin pelanggan/piutang → kembali ke Beranda', (
    tester,
  ) async {
    await pump(
      tester,
      const Size(1280, 800),
      session: FakeSessionRepository()
        ..current = staffWithPermissions({Permission.salesCreate}),
    );
    expect(_key('customers-scroll'), findsNothing);
  });

  testWidgets('tautan kuitansi rusak kembali ke daftar pelanggan', (
    tester,
  ) async {
    await pump(
      tester,
      const Size(1280, 800),
      location: '${Routes.customers}/kuitansi/bukan-id',
    );
    expect(_key('customers-scroll'), findsOneWidget);
  });
}
