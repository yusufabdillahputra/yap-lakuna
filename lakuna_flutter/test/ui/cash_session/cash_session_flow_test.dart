import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_cash_drawer_repository.dart';
import '../../testing/fake_session_repository.dart';

Finder _input(String key) => find.descendant(
  of: find.byKey(ValueKey(key)),
  matching: find.byType(EditableText),
);

Future<void> _type(WidgetTester tester, String key, String text) async {
  await tester.enterText(_input(key), text);
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(ValueKey(key)));
  await tester.tap(find.byKey(ValueKey(key)));
  await tester.pumpAndSettle();
}

String _text(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(ValueKey(key))).data!;

void main() {
  Future<FakeCashDrawerRepository> pump(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
    String role = 'owner',
  }) async {
    final repo = FakeCashDrawerRepository(
      permissions: permissionsForRole(role, isOwner: role == 'owner'),
    );
    await pumpLakuna(
      tester,
      size: size,
      initialLocation: Routes.cashSession,
      cashDrawer: repo,
      session: FakeSessionRepository()..current = sampleStaff(role: role),
    );
    return repo;
  }

  testWidgets('tablet: buka, catat uang keluar, tutup dengan selisih', (
    tester,
  ) async {
    final repo = await pump(tester, size: const Size(1024, 768));
    expect(find.byKey(const ValueKey('cash-open-card')), findsOneWidget);
    expect(find.text('Buka sesi kasir'), findsOneWidget);

    await _tap(tester, 'cash-open');
    expect(find.text('Wajib diisi'), findsOneWidget);

    await _type(tester, 'cash-opening-cash', '200000');
    expect(find.text('200.000'), findsOneWidget);
    await _tap(tester, 'cash-open');
    expect(repo.session?.openingCash, 200000);
    expect(find.text('Sesi kasir · Kas laci'), findsOneWidget);
    expect(_text(tester, 'cash-expected'), 'Rp 200.000');
    expect(find.byKey(const ValueKey('cash-row-opening')), findsOneWidget);

    await _type(tester, 'cash-movement-amount', '15000');
    await _type(tester, 'cash-movement-note', 'Beli es batu');
    await _tap(tester, 'cash-movement-save');
    expect(repo.movements, hasLength(1));
    expect(_text(tester, 'cash-expected'), 'Rp 185.000');
    expect(find.text('Beli es batu'), findsOneWidget);
    expect(find.text('−Rp 15.000'), findsOneWidget);
    // Formulir kosong lagi.
    expect(
      tester
          .widget<EditableText>(_input('cash-movement-amount'))
          .controller
          .text,
      isEmpty,
    );

    await _tap(tester, 'cash-start-close');
    expect(find.text('Tutup sesi kasir · Yusuf'), findsOneWidget);
    expect(_text(tester, 'cash-recap-expected'), 'Rp 185.000');

    await _type(tester, 'cash-count-100000', '1');
    await _type(tester, 'cash-count-50000', '1');
    await _type(tester, 'cash-count-20000', '1');
    await _type(tester, 'cash-count-coins', '13000');
    expect(_text(tester, 'cash-counted'), 'Rp 183.000');
    expect(_text(tester, 'cash-difference'), '−Rp 2.000');

    await _tap(tester, 'cash-close');
    expect(find.text('Wajib diisi'), findsOneWidget);
    expect(repo.session!.status, CashSessionStatus.opened);

    await _type(tester, 'cash-closing-note', 'Kembalian kurang');
    await _tap(tester, 'cash-close');
    expect(repo.session!.status, CashSessionStatus.closed);
    expect(find.text('Sesi kasir ditutup'), findsOneWidget);
    expect(_text(tester, 'cash-closed-difference'), '−Rp 2.000');

    await _tap(tester, 'cash-start-new');
    expect(find.byKey(const ValueKey('cash-open-card')), findsOneWidget);
  });

  testWidgets('uang masuk lewat tab', (tester) async {
    final repo = await pump(tester);
    await _type(tester, 'cash-opening-cash', '100000');
    await _tap(tester, 'cash-open');
    await tester.tap(find.byKey(const ValueKey('cash-direction-inflow')));
    await tester.pumpAndSettle();
    await _type(tester, 'cash-movement-amount', '50000');
    await _type(tester, 'cash-movement-note', 'Tambah kembalian');
    await _tap(tester, 'cash-movement-save');
    expect(repo.movements.single.direction, CashDirection.inflow);
    expect(find.text('+Rp 50.000'), findsOneWidget);
    expect(_text(tester, 'cash-expected'), 'Rp 150.000');
  });

  testWidgets('selisih pas ditandai Pas', (tester) async {
    await pump(tester);
    await _type(tester, 'cash-opening-cash', '100000');
    await _tap(tester, 'cash-open');
    await _tap(tester, 'cash-start-close');
    await _type(tester, 'cash-count-100000', '1');
    expect(_text(tester, 'cash-difference'), 'Pas');
    await _tap(tester, 'cash-back-to-drawer');
    expect(find.text('Sesi kasir · Kas laci'), findsOneWidget);
  });

  testWidgets('mobile: satu kolom tanpa luapan', (tester) async {
    await pump(tester, size: const Size(400, 800));
    await _type(tester, 'cash-opening-cash', '100000');
    await _tap(tester, 'cash-open');
    await _type(tester, 'cash-movement-amount', '5000');
    await _type(tester, 'cash-movement-note', 'Parkir');
    await _tap(tester, 'cash-movement-save');
    expect(find.text('Parkir'), findsOneWidget);
    await _tap(tester, 'cash-start-close');
    await _type(tester, 'cash-count-50000', '2');
    expect(_text(tester, 'cash-counted'), 'Rp 100.000');
    expect(tester.takeException(), isNull);
  });

  testWidgets('bolak-balik tutup sesi tidak menyimpan isian tersembunyi', (
    tester,
  ) async {
    final repo = await pump(tester);
    await _type(tester, 'cash-opening-cash', '100000');
    await _tap(tester, 'cash-open');
    await _type(tester, 'cash-movement-amount', '15000');
    await _type(tester, 'cash-movement-note', 'hantu');
    await _tap(tester, 'cash-start-close');
    await _type(tester, 'cash-count-100000', '3');
    await _type(tester, 'cash-closing-note', 'catatan tersembunyi');
    await _tap(tester, 'cash-back-to-drawer');
    await _tap(tester, 'cash-movement-save');
    expect(repo.movements, isEmpty);
    await _tap(tester, 'cash-start-close');
    expect(_text(tester, 'cash-counted'), 'Rp 0');
    await _tap(tester, 'cash-close');
    expect(repo.session!.status, CashSessionStatus.opened);
    expect(find.text('Wajib diisi'), findsOneWidget);
  });

  testWidgets('ponsel 320 px dengan nominal besar tanpa luapan', (
    tester,
  ) async {
    await pump(tester, size: const Size(320, 740));
    await _type(tester, 'cash-opening-cash', '1500000');
    await _tap(tester, 'cash-open');
    await _tap(tester, 'cash-start-close');
    await _type(tester, 'cash-count-100000', '15');
    await _type(tester, 'cash-count-coins', '1500000');
    expect(_text(tester, 'cash-counted'), 'Rp 3.000.000');
    expect(tester.takeException(), isNull);
  });

  testWidgets('kasir tanpa izin tutup: tombol Tutup sesi tidak tampil', (
    tester,
  ) async {
    final perms = permissionsForRole('cashier');
    final repo = FakeCashDrawerRepository(
      permissions: perms.difference({Permission.cashSessionClose}),
    );
    final staff = staffWithPermissions(
      perms.difference({Permission.cashSessionClose}),
    );
    await pumpLakuna(
      tester,
      initialLocation: Routes.cashSession,
      cashDrawer: repo,
      session: FakeSessionRepository(staff: [staff])..current = staff,
    );
    await _type(tester, 'cash-opening-cash', '100000');
    await _tap(tester, 'cash-open');
    expect(find.byKey(const ValueKey('cash-start-close')), findsNothing);
  });

  testWidgets('menu Sesi kasir tersembunyi tanpa cash_session:open', (
    tester,
  ) async {
    final staff = staffWithPermissions({
      Permission.productsManage,
    });
    await pumpLakuna(
      tester,
      initialLocation: Routes.cashSession,
      session: FakeSessionRepository(staff: [staff])..current = staff,
    );
    expect(find.text('Sesi kasir'), findsNothing);
    expect(find.text('Selamat datang di Lakuna'), findsOneWidget);
  });
}
