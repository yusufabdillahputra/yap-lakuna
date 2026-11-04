import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../testing/app_harness.dart';

void main() {
  testWidgets('beranda tampil dalam bahasa Indonesia dengan status offline', (
    tester,
  ) async {
    await pumpLakuna(tester);
    expect(find.text('Selamat datang di Lakuna'), findsOneWidget);
    expect(find.text('Offline · data di perangkat ini'), findsOneWidget);
    expect(find.text('0192f3a1-7c00-7000-8000-000000000001'), findsOneWidget);
  });

  testWidgets('desktop memakai sidebar dengan semua menu fase 1', (
    tester,
  ) async {
    await pumpLakuna(tester);
    expect(find.byKey(const ValueKey('sidebar')), findsOneWidget);
    for (final label in [
      'Beranda',
      'Kasir',
      'Meja',
      'Sesi kasir',
      'Riwayat',
      'Produk',
      'Stok',
      'Pembelian',
      'Pelanggan',
      'Supplier',
      'Pengeluaran',
      'Laporan',
      'Pengguna & role',
      'Pengaturan',
      'Panduan',
    ]) {
      // Sidebar memakai daftar malas: gulir sampai entri dibangun.
      await tester.scrollUntilVisible(
        find.text(label),
        120,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('sidebar')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text(label), findsWidgets, reason: label);
    }
    await tester.pumpAndSettle();
  });

  testWidgets('mobile memakai navigasi bawah, tanpa sidebar', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpLakuna(tester, size: const Size(400, 800));
    expect(find.byKey(const ValueKey('sidebar')), findsNothing);
    // Sesuai kanvas 1.15m: Beranda, Kasir, Produk, Riwayat, Lainnya.
    for (final key in ['home', 'cashier', 'products', 'history', 'more']) {
      expect(find.byKey(ValueKey('nav-$key')), findsOneWidget, reason: key);
    }
    expect(find.byKey(const ValueKey('nav-settings')), findsNothing);
    expect(
      find.bySemanticsLabel(RegExp('Offline · data di perangkat ini')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('mobile: Lainnya membuka menu sisanya, mis. Stok', (
    tester,
  ) async {
    await pumpLakuna(tester, size: const Size(400, 800));
    await tester.tap(find.byKey(const ValueKey('nav-more')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('more-cash_session')), findsOneWidget);
    expect(find.byKey(const ValueKey('more-settings')), findsOneWidget);
    expect(find.byKey(const ValueKey('more-products')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('more-stock')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('more-stock')), findsNothing);
    expect(find.text('Penyesuaian stok baru'), findsOneWidget);
  });

  testWidgets('tablet memakai sidebar', (tester) async {
    await pumpLakuna(tester, size: const Size(900, 700));
    expect(find.byKey(const ValueKey('sidebar')), findsOneWidget);
  });

  testWidgets('menu modul yang belum dibangun membuka halaman segera hadir', (
    tester,
  ) async {
    await pumpLakuna(tester, initialLocation: Routes.module('users'));
    expect(find.text('Pengguna & role segera hadir'), findsOneWidget);
  });

  testWidgets('menu Laporan membuka layar laporan', (tester) async {
    await pumpLakuna(tester);
    await tester.tap(find.byKey(const ValueKey('nav-reports')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('reports-kpi-sales')), findsOneWidget);
  });

  testWidgets('menu Pengeluaran membuka layar pengeluaran', (tester) async {
    await pumpLakuna(tester);
    await tester.tap(find.byKey(const ValueKey('nav-expenses')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('expenses-by-category')), findsOneWidget);
  });

  testWidgets('menu Supplier membuka layar supplier & hutang', (tester) async {
    await pumpLakuna(tester);
    await tester.tap(find.byKey(const ValueKey('nav-suppliers')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('suppliers-total')), findsOneWidget);
  });

  testWidgets('menu Pelanggan membuka layar pelanggan & piutang', (
    tester,
  ) async {
    await pumpLakuna(tester);
    await tester.tap(find.byKey(const ValueKey('nav-customers')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('customers-total')), findsOneWidget);
  });

  testWidgets('menu Pembelian membuka layar pembelian', (tester) async {
    await pumpLakuna(tester);
    await tester.tap(find.byKey(const ValueKey('nav-purchases')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('purchases-empty')), findsOneWidget);
  });

  testWidgets('menu Stok membuka layar stok', (tester) async {
    await pumpLakuna(tester);
    await tester.tap(find.byKey(const ValueKey('nav-stock')));
    await tester.pumpAndSettle();
    expect(find.text('Penyesuaian stok baru'), findsOneWidget);
  });

  testWidgets('menu Produk membuka daftar produk', (tester) async {
    await pumpLakuna(tester);
    await tester.tap(find.byKey(const ValueKey('nav-products')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('products-empty')), findsOneWidget);
  });
}
