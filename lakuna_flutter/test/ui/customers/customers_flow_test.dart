import 'dart:async';
import 'dart:convert';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/table_file.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_spreadsheet_exporter.dart';
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

  testWidgets('desktop: dialog pelanggan yang berubah bertanya sebelum '
      'ditutup (F1-13e)', (tester) async {
    await pump(tester, const Size(1440, 900));
    // Tanpa perubahan: ketuk di luar dialog langsung menutup.
    await _tap(tester, _key('customers-new'));
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(_key('customer-form'), findsNothing);
    expect(_key('customer-discard'), findsNothing);

    await _tap(tester, _key('customers-new'));
    await _type(tester, _key('customer-form-name'), 'Bu Wati');
    // Esc saat mengetik bertanya.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_key('customer-discard'), findsOneWidget);
    await _tap(tester, _key('customer-discard-cancel'));
    expect(_key('customer-form'), findsOneWidget);

    // Dialog menutupi menu samping (navigator akar).
    await tester.tap(_key('nav-stock'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(_key('customer-form'), findsOneWidget);
    expect(_key('customer-discard'), findsOneWidget);
    expect(
      find.text('Pelanggan yang sedang diisi belum disimpan dan akan hilang.'),
      findsOneWidget,
    );
    await _tap(tester, _key('customer-discard-cancel'));
    expect(_key('customer-form'), findsOneWidget);

    // Mengetuk bagian dalam dialog (tepi kosong) tidak menutup.
    await tester.tapAt(
      tester.getTopLeft(_key('customer-form')) + const Offset(2, 2),
    );
    await tester.pumpAndSettle();
    expect(_key('customer-discard'), findsNothing);
    expect(_key('customer-form'), findsOneWidget);

    // Tombol kembali sistem bertanya.
    final popping = tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(_key('customer-discard'), findsOneWidget);
    await _tap(tester, _key('customer-discard-cancel'));
    await popping;
    expect(_key('customer-form'), findsOneWidget);

    // Tombol Batal juga bertanya.
    await _tap(tester, _key('customer-form-cancel'));
    expect(_key('customer-discard'), findsOneWidget);
    await _tap(tester, _key('customer-discard-confirm'));
    expect(_key('customer-form'), findsNothing);
    expect(repo.customers, hasLength(4));
    expect(_key('customers-new'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('Simpan dari dialog Buang perubahan? (F1-13g)', () {
    testWidgets('Esc lalu Simpan: tersimpan dan tampil di daftar', (
      tester,
    ) async {
      await pump(tester, const Size(1440, 900));
      await _tap(tester, _key('customers-new'));
      await _type(tester, _key('customer-form-name'), 'Bu Wati');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      await _tap(tester, _key('customer-discard-save'));
      expect(_key('customer-discard'), findsNothing);
      expect(_key('customer-form'), findsNothing);
      final wati = repo.customers.singleWhere((c) => c.name == 'Bu Wati');
      expect(_key('customers-row-${wati.id.uuid}'), findsOneWidget);
      // Daftar memilih pelanggan yang baru disimpan.
      expect(_key('customer-panel-${wati.id.uuid}'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('selama simpan dari pertanyaan berjalan, dialog tidak bisa '
        'ditutup dan jendela tidak keluar', (tester) async {
      await pump(tester, const Size(1440, 900));
      await _tap(tester, _key('customers-new'));
      await _type(tester, _key('customer-form-name'), 'Bu Wati');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      final gate = repo.saveGate = Completer<void>();
      await tester.tap(_key('customer-discard-save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(_key('customer-discard'), findsNothing);

      // Esc dan ketukan di luar diabaikan.
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(_key('customer-discard'), findsNothing);
      expect(_key('customer-form'), findsOneWidget);
      // Tutup jendela ditolak tanpa bertanya.
      final exit = tester.binding.handleRequestAppExit();
      await tester.pump();
      expect(_key('customer-discard'), findsNothing);
      expect(await exit, AppExitResponse.cancel);

      gate.complete();
      await tester.pumpAndSettle();
      expect(_key('customer-form'), findsNothing);
      expect(repo.customers.where((c) => c.name == 'Bu Wati'), hasLength(1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('simpan gagal: dialog tetap terbuka dengan pesan', (
      tester,
    ) async {
      await pump(tester, const Size(1440, 900));
      final ani = repo.customers.firstWhere((c) => c.name == 'Toko Bu Ani');
      final other = repo.customers.firstWhere(
        (c) => c.id != ani.id && c.phone != null,
      );
      await _tap(tester, _key('customers-row-${ani.id.uuid}'));
      await _tap(tester, _key('customer-edit'));
      await _type(tester, _key('customer-form-phone'), other.phone!);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await _tap(tester, _key('customer-discard-save'));
      expect(_key('customer-form'), findsOneWidget);
      expect(_key('customer-form-error'), findsOneWidget);
      expect(
        repo.customers.firstWhere((c) => c.id == ani.id).phone,
        ani.phone,
      );

      // Nama kosong: pesan di bawah Nama, dialog tetap.
      await _type(tester, _key('customer-form-phone'), '');
      await _type(tester, _key('customer-form-name'), '');
      await _tap(tester, _key('customer-form-cancel'));
      await _tap(tester, _key('customer-discard-save'));
      expect(_key('customer-form'), findsOneWidget);
      expect(
        repo.customers.firstWhere((c) => c.id == ani.id).name,
        'Toko Bu Ani',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('tutup jendela lalu Simpan: tersimpan lalu keluar', (
      tester,
    ) async {
      await pump(tester, const Size(1440, 900));
      await _tap(tester, _key('customers-new'));
      await _type(tester, _key('customer-form-name'), 'Bu Wati');
      final exit = tester.binding.handleRequestAppExit();
      await tester.pumpAndSettle();
      await _tap(tester, _key('customer-discard-save'));
      expect(await exit, AppExitResponse.exit);
      expect(repo.customers.where((c) => c.name == 'Bu Wati'), hasLength(1));
      expect(_key('customer-form'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tutup jendela, simpan gagal: tetap terbuka', (tester) async {
      await pump(tester, const Size(1440, 900));
      await _tap(tester, _key('customers-new'));
      await _type(tester, _key('customer-form-name'), 'Bu Wati');
      repo.nextError = Exception('disk penuh');
      final exit = tester.binding.handleRequestAppExit();
      await tester.pumpAndSettle();
      await _tap(tester, _key('customer-discard-save'));
      expect(await exit, AppExitResponse.cancel);
      expect(_key('customer-form'), findsOneWidget);
      expect(_key('customer-form-error'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('desktop: tutup jendela saat dialog pelanggan berisi isian '
      'bertanya dulu (F1-02d)', (tester) async {
    await pump(tester, const Size(1440, 900));
    await _tap(tester, _key('customers-new'));
    // Tanpa isian: aplikasi langsung boleh ditutup.
    expect(
      await tester.binding.handleRequestAppExit(),
      AppExitResponse.exit,
    );
    await _type(tester, _key('customer-form-name'), 'Bu Wati');

    var exit = tester.binding.handleRequestAppExit();
    await tester.pumpAndSettle();
    expect(_key('customer-discard'), findsOneWidget);
    await _tap(tester, _key('customer-discard-cancel'));
    expect(await exit, AppExitResponse.cancel);
    expect(_key('customer-form'), findsOneWidget);
    expect(find.text('Bu Wati'), findsOneWidget);

    exit = tester.binding.handleRequestAppExit();
    await tester.pumpAndSettle();
    await _tap(tester, _key('customer-discard-confirm'));
    expect(await exit, AppExitResponse.exit);
    expect(repo.customers, hasLength(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop: ubah pelanggan tanpa perubahan tertutup langsung; '
      'simpan gagal tetap bertanya (F1-13e)', (tester) async {
    await pump(tester, const Size(1440, 900));
    final ani = repo.customers.firstWhere((c) => c.name == 'Toko Bu Ani');
    final other = repo.customers.firstWhere(
      (c) => c.id != ani.id && c.phone != null,
    );
    await _tap(tester, _key('customers-row-${ani.id.uuid}'));
    await _tap(tester, _key('customer-edit'));
    expect(_key('customer-form'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(_key('customer-form'), findsNothing);
    expect(_key('customer-discard'), findsNothing);

    await _tap(tester, _key('customer-edit'));
    await _type(tester, _key('customer-form-phone'), other.phone!);
    await _tap(tester, _key('customer-form-save'));
    expect(_key('customer-form-error'), findsOneWidget);
    await _tap(tester, _key('customer-form-cancel'));
    expect(_key('customer-discard'), findsOneWidget);
    await _tap(tester, _key('customer-discard-confirm'));
    expect(_key('customer-form'), findsNothing);
    expect(
      repo.customers.firstWhere((c) => c.id == ani.id).phone,
      ani.phone,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop: dialog pelanggan tidak bisa ditutup selama simpan '
      '(F1-13e)', (tester) async {
    await pump(tester, const Size(1440, 900));
    await _tap(tester, _key('customers-new'));
    await _type(tester, _key('customer-form-name'), 'Bu Wati');
    final gate = repo.saveGate = Completer<void>();
    await tester.tap(_key('customer-form-save'));
    await tester.pump();
    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(_key('customer-discard'), findsNothing);
    expect(_key('customer-form'), findsOneWidget);
    gate.complete();
    await tester.pumpAndSettle();
    expect(_key('customer-form'), findsNothing);
    expect(repo.customers.where((c) => c.name == 'Bu Wati'), hasLength(1));
    expect(tester.takeException(), isNull);
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
      final exporter = FakeSpreadsheetExporter();
      await pumpLakuna(
        tester,
        exporter: exporter,
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
      await _tap(tester, _key('import-template-customers'));
      expect(exporter.saved.single.$1, 'templat-import-pelanggan.xlsx');
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

  testWidgets('unduh templat import pelanggan 360 px (F1-07g)', (
    tester,
  ) async {
    final exporter = FakeSpreadsheetExporter()
      ..path = '/home/kasir/Dokumen/Lakuna/templat-import-pelanggan.xlsx';
    await pumpLakuna(
      tester,
      size: const Size(360, 740),
      initialLocation: Routes.customers,
      customers: FakeCustomersRepository(),
      exporter: exporter,
    );
    await _tap(tester, _key('customers-import'));
    await _tap(tester, _key('import-template-customers'));
    expect(exporter.saved.single.$1, 'templat-import-pelanggan.xlsx');
    expect(_key('import-template-saved-customers'), findsOneWidget);
    // Tombol pilih berkas tetap terlihat di layar sempit.
    expect(_key('customer-import-pick'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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
      // Uangnya sudah keluar lagi dari laci (F1-03d).
      customers.drawerCash = const Money(100000);
      await pump(tester, size, customers: customers);
      await _tap(tester, _key('customers-row-${ani.id.uuid}'));
      expect(_openRows(), findsNWidgets(2));
      // Nomor pembayaran tetap satu baris, juga di 360 px.
      expect(
        tester.getSize(find.text(payment.number)).height,
        lessThan(30),
      );

      await _tap(tester, _key('customer-payment-void-${payment.id.uuid}'));
      expect(_key('debt-void-dialog'), findsOneWidget);
      expect(_key('debt-void-drawer'), findsOneWidget);
      // Uang keluar laci melebihi perkiraan (F1-03d).
      expect(_key('debt-void-drawer-short'), findsOneWidget);
      expect(
        find.textContaining('Jumlah ini lebih Rp 550.000 dari perkiraan'),
        findsOneWidget,
      );
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

  for (final size in const [Size(1280, 800), Size(360, 740)]) {
    testWidgets('terima piutang transfer: pilih rekening tujuan '
        '${size.width.toInt()} px (F1-13i)', (tester) async {
      final customers = FakeCustomersRepository()
        ..transferAccount = 'BCA 123 a.n. Warung\nMandiri 987 a.n. Warung';
      await pump(tester, size, customers: customers);
      final ani = idOf('Toko Bu Ani');
      await _tap(tester, _key('customers-row-${ani.uuid}'));
      await _type(tester, _key('customer-amount-0'), '100000');
      expect(_key('payment-transfer-account'), findsNothing); // Tunai.

      await _tap(tester, _key('customer-method-0'));
      await tester.tap(find.text('Transfer bank').last);
      await tester.pumpAndSettle();
      expect(_key('payment-transfer-account'), findsOneWidget);
      expect(_key('payment-transfer-choose'), findsOneWidget);
      expect(tester.widget<FButton>(_key('customer-receive')).onPress, isNull);

      await _tap(tester, _key('payment-transfer-copy-1'));
      expect(_key('payment-transfer-choose'), findsNothing);
      expect(
        tester.getSemantics(_key('payment-transfer-pick-1')),
        isSemantics(isSelected: true, isButton: true),
      );
      await _tap(tester, _key('customer-receive'));
      expect(
        repo.requests.single.transferAccount,
        'Mandiri 987 a.n. Warung',
      );
      final payment = repo.payments.single;
      expect(_key('kuitansi-panel'), findsOneWidget);
      expect(find.text('Mandiri 987 a.n. Warung'), findsWidgets);

      await _tap(tester, _key('kuitansi-back'));
      expect(
        tester
            .widget<Text>(_key('customer-payment-account-${payment.id.uuid}'))
            .data,
        'Ke: Mandiri 987 a.n. Warung',
      );
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

  testWidgets('keluar dari detail pelanggan lewat menu samping: daftar dimuat '
      'ulang (F1-12d)', (tester) async {
    await pump(tester, const Size(800, 1280));
    final sri = idOf('Warung Mbak Sri');
    expect(_keyPrefix('customers-row-'), findsNWidgets(4));
    await _tap(tester, _key('customers-row-${sri.uuid}'));
    expect(_key('customer-panel-${sri.uuid}'), findsOneWidget);
    repo.customers.removeWhere((c) => c.id != sri);
    await _tap(tester, _key('nav-customers'));
    expect(_key('customer-back'), findsNothing);
    expect(_keyPrefix('customers-row-'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
