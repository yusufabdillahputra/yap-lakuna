import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

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
      expect(find.text(label), findsWidgets, reason: label);
    }
  });

  testWidgets('mobile memakai navigasi bawah, tanpa sidebar', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpLakuna(tester, size: const Size(400, 800));
    expect(find.byKey(const ValueKey('sidebar')), findsNothing);
    expect(find.byKey(const ValueKey('nav-cashier')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav-settings')), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Offline · data di perangkat ini')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('tablet memakai sidebar', (tester) async {
    await pumpLakuna(tester, size: const Size(900, 700));
    expect(find.byKey(const ValueKey('sidebar')), findsOneWidget);
  });

  testWidgets('menu modul yang belum dibangun membuka halaman segera hadir', (
    tester,
  ) async {
    await pumpLakuna(tester);
    await tester.tap(find.byKey(const ValueKey('nav-products')));
    await tester.pumpAndSettle();
    expect(find.text('Produk segera hadir'), findsOneWidget);
  });
}
