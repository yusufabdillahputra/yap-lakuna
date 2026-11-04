import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/image_file_picker.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_payment_settings_repository.dart'
    show FakeImagePicker;
import '../../testing/fake_purchases_repository.dart';
import '../../testing/fake_session_repository.dart';
import '../../testing/fake_suppliers_repository.dart';
import '../../testing/qris_seed.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

Finder _keyPrefix(String prefix) => find.byWidgetPredicate(
  (w) =>
      w.key is ValueKey<String> &&
      (w.key! as ValueKey<String>).value.startsWith(prefix),
);

/// Baris pembelian berhutang di panel supplier.
Finder _openRows() => find.byWidgetPredicate(
  (w) =>
      w.key is ValueKey<String> &&
      (w.key! as ValueKey<String>).value.startsWith('supplier-open-') &&
      (w.key! as ValueKey<String>).value != 'supplier-open-table',
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

/// Memilih [label] di FSelect [field].
Future<void> _choose(WidgetTester tester, Finder field, String label) async {
  await _tap(tester, field);
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  late FakeSuppliersRepository repo;
  late FakeImagePicker picker;

  Future<void> pump(
    WidgetTester tester,
    Size size, {
    FakeSuppliersRepository? suppliers,
    FakeSessionRepository? session,
    FakePurchasesRepository? purchases,
    String location = Routes.suppliers,
  }) async {
    repo = suppliers ?? FakeSuppliersRepository();
    picker = FakeImagePicker();
    await pumpLakuna(
      tester,
      size: size,
      initialLocation: location,
      suppliers: repo,
      purchases: purchases,
      imagePicker: picker,
      session: session,
    );
  }

  UuidValue idOf(String name) => repo.byName(name).id;

  testWidgets(
    'desktop: pilih supplier → bayar dari bank dengan bukti → riwayat bayar',
    (tester) async {
      await pump(tester, const Size(1440, 900));
      expect(_keyPrefix('suppliers-row-'), findsNWidgets(3));
      expect(_key('suppliers-pick-hint'), findsOneWidget);
      // Total hutang 1.300.000 + 725.000 + 480.000.
      expect(
        find.descendant(
          of: _key('suppliers-total'),
          matching: find.text('Rp 2.505.000'),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Jatuh tempo terdekat: 04/11'), findsOne);

      final sumber = idOf('CV Sumber Pangan');
      await _tap(tester, _key('suppliers-row-${sumber.uuid}'));
      expect(_key('supplier-panel-${sumber.uuid}'), findsOneWidget);
      expect(find.text('CV Sumber Pangan · bayar hutang'), findsOneWidget);
      expect(_openRows(), findsNWidgets(2));

      await _type(tester, _key('supplier-amount-0'), '1300000');
      await _choose(tester, _key('supplier-funding-0'), 'Rekening bank');
      await _type(tester, _key('supplier-reference-0'), 'TRF-0211-883');
      expect(find.textContaining('Rp 725.000 (jatuh tempo 16/11)'), findsOne);
      picker.next = PickedImage(
        name: 'bukti.png',
        size: tinyPortraitPng.length,
        bytes: tinyPortraitPng,
      );
      await _tap(tester, _key('supplier-proof-pick'));
      expect(_key('supplier-proof-preview'), findsOneWidget);
      await _tap(tester, _key('supplier-pay'));

      final r = repo.requests.single;
      expect(r.amount, const Money(1300000));
      expect(r.funding, FundingSource.bank);
      expect(r.reference, 'TRF-0211-883');
      expect(r.proof, isNotNull);
      expect(_key('supplier-paid'), findsOneWidget);
      expect(_openRows(), findsOneWidget);
      final payment = repo.payments.single;
      expect(_key('supplier-payment-${payment.id.uuid}'), findsOneWidget);
      // Daftar ikut diperbarui.
      expect(
        find.descendant(
          of: _key('suppliers-total'),
          matching: find.text('Rp 1.205.000'),
        ),
        findsOneWidget,
      );

      await _tap(tester, _key('supplier-payment-proof-${payment.id.uuid}'));
      expect(_key('supplier-proof-dialog'), findsOneWidget);
      await _tap(tester, _key('supplier-proof-close'));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('desktop: kas laci tanpa sesi ditolak sebelum simpan', (
    tester,
  ) async {
    await pump(
      tester,
      const Size(1280, 800),
      suppliers: FakeSuppliersRepository(hasOpenSession: false),
    );
    final segar = idOf('PT Segar Jaya');
    await _tap(tester, _key('suppliers-row-${segar.uuid}'));
    await _tap(tester, _key('supplier-pay-all'));
    await _choose(tester, _key('supplier-funding-1'), 'Kas laci');
    expect(_key('supplier-drawer-hint'), findsOneWidget);
    expect(
      find.text('Kas laci butuh sesi kasir terbuka di perangkat ini.'),
      findsOneWidget,
    );
    await _tap(tester, _key('supplier-pay'));
    expect(repo.requests, isEmpty);
  });

  testWidgets('desktop: alokasi manual harus sama dengan jumlah bayar', (
    tester,
  ) async {
    await pump(tester, const Size(1440, 900));
    final sumber = idOf('CV Sumber Pangan');
    await _tap(tester, _key('suppliers-row-${sumber.uuid}'));
    await _type(tester, _key('supplier-amount-0'), '500000');
    await _tap(tester, _key('supplier-manual'));
    final second = repo.purchaseList[sumber]![1].$1.id;
    final first = repo.purchaseList[sumber]![0].$1.id;
    await _type(tester, _key('supplier-alloc-${first.uuid}-1'), '0');
    await _type(tester, _key('supplier-alloc-${second.uuid}-1'), '200000');
    expect(
      find.text('Jumlah kolom Bayar harus sama dengan jumlah dibayar.'),
      findsOneWidget,
    );
    await _type(tester, _key('supplier-alloc-${second.uuid}-1'), '500000');
    await _tap(tester, _key('supplier-pay'));
    expect(repo.requests.single.allocations, {second: const Money(500000)});
  });

  testWidgets('desktop: tambah supplier, ubah, lalu hapus', (tester) async {
    await pump(tester, const Size(1280, 800));
    await _tap(tester, _key('suppliers-new'));
    await _tap(tester, _key('supplier-form-save'));
    expect(find.textContaining('Nama wajib diisi'), findsOneWidget);
    await _type(tester, _key('supplier-form-name'), 'Toko Plastik Jaya');
    await _type(tester, _key('supplier-form-category'), 'Kemasan');
    await _type(tester, _key('supplier-form-term'), '30');
    await _tap(tester, _key('supplier-form-save'));
    final plastik = repo.byName('Toko Plastik Jaya');
    expect(plastik.termDays, 30);
    expect(_key('supplier-panel-${plastik.id.uuid}'), findsOneWidget);
    expect(_key('supplier-no-debt'), findsOneWidget);
    expect(find.textContaining('tempo standar 30 hari'), findsOneWidget);

    await _tap(tester, _key('supplier-edit'));
    await _type(tester, _key('supplier-form-contact'), 'Mas Budi');
    await _tap(tester, _key('supplier-form-save'));
    expect(find.textContaining('Kontak: Mas Budi'), findsOneWidget);

    await _tap(tester, _key('supplier-delete'));
    await _tap(tester, _key('supplier-delete-ok'));
    expect(_key('suppliers-pick-hint'), findsOneWidget);
    expect(repo.suppliers.any((s) => s.name == 'Toko Plastik Jaya'), isFalse);
  });

  testWidgets('hapus supplier berhutang ditolak', (tester) async {
    await pump(tester, const Size(1280, 800));
    final segar = idOf('PT Segar Jaya');
    await _tap(tester, _key('suppliers-row-${segar.uuid}'));
    await _tap(tester, _key('supplier-delete'));
    await _tap(tester, _key('supplier-delete-ok'));
    expect(_key('supplier-delete-error'), findsOneWidget);
  });

  testWidgets('riwayat pembelian membuka detail pembelian', (tester) async {
    final purchases = FakePurchasesRepository();
    await pump(tester, const Size(1280, 800), purchases: purchases);
    final sumber = idOf('CV Sumber Pangan');
    await _tap(tester, _key('suppliers-row-${sumber.uuid}'));
    await _tap(tester, _key('supplier-history-open'));
    expect(_keyPrefix('supplier-history-'), findsWidgets);
    final first = repo.purchaseList[sumber]!.first.$1;
    expect(_key('supplier-history-${first.id.uuid}'), findsOneWidget);
    await _tap(tester, _key('supplier-history-close'));
    expect(_key('supplier-history'), findsNothing);

    await _tap(tester, _key('supplier-history-open'));
    await _tap(tester, _key('supplier-history-${first.id.uuid}'));
    expect(_key('supplier-history'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w.key == const ValueKey('purchase-detail') ||
            w.key == const ValueKey('purchase-detail-error'),
      ),
      findsOneWidget,
    );
  });

  for (final size in const [Size(360, 740), Size(800, 1280)]) {
    testWidgets(
      '${size.width.toInt()} px: buka supplier di halaman sendiri, bayar',
      (tester) async {
        await pump(tester, size);
        final sumber = idOf('CV Sumber Pangan');
        await _tap(tester, _key('suppliers-row-${sumber.uuid}'));
        expect(_key('supplier-back'), findsOneWidget);
        expect(_key('supplier-panel-${sumber.uuid}'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await _tap(tester, _key('supplier-pay-all'));
        await _tap(tester, _key('supplier-pay'));
        expect(repo.requests.single.amount, const Money(2025000));
        expect(_key('supplier-no-debt'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await _tap(tester, _key('supplier-back'));
        expect(_keyPrefix('suppliers-row-'), findsNWidgets(3));
      },
    );
  }

  testWidgets('tanpa izin supplier/hutang → kembali ke Beranda', (
    tester,
  ) async {
    await pump(
      tester,
      const Size(1280, 800),
      session: FakeSessionRepository()
        ..current = staffWithPermissions({Permission.salesCreate}),
    );
    expect(_key('suppliers-scroll'), findsNothing);
  });

  testWidgets('staf gudang: kelola supplier tanpa form bayar', (tester) async {
    await pump(
      tester,
      const Size(1280, 800),
      suppliers: FakeSuppliersRepository(canPay: false),
      session: FakeSessionRepository()
        ..current = staffWithPermissions({Permission.suppliersManage}),
    );
    final sumber = idOf('CV Sumber Pangan');
    await _tap(tester, _key('suppliers-row-${sumber.uuid}'));
    expect(_key('supplier-open-table'), findsOneWidget);
    expect(_key('supplier-pay'), findsNothing);
    expect(_key('supplier-edit'), findsOneWidget);
  });
}
