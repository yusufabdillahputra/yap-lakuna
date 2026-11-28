import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_flutter/config/app_platform.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../testing/app_harness.dart';
import '../testing/fake_store_repository.dart';

/// Pemilih cabang di bilah atas web (F2-02 aturan 2a).
void main() {
  const web = AppPlatform(isWeb: true);

  FakeStoreRepository twoOutlets() {
    final ctx = sampleStoreContext();
    final kmg = Outlet(
      id: UuidValue.fromString(newId()),
      tenantId: ctx.tenant.id,
      code: 'KMG',
      name: 'Cabang Kemang',
      hlc: 'h',
    );
    return FakeStoreRepository(current: ctx)..outletList = [ctx.outlet, kmg];
  }

  testWidgets('web dengan 2 cabang: pilih cabang lain', (tester) async {
    final store = twoOutlets();
    await pumpLakuna(tester, platform: web, store: store);
    final picker = find.byKey(const ValueKey('outlet-picker'));
    expect(picker, findsOneWidget);
    expect(
      find.descendant(of: picker, matching: find.text('Cabang Pusat')),
      findsOneWidget,
    );
    await tester.tap(picker);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('outlet-KMG')));
    await tester.pumpAndSettle();
    expect(store.current!.outlet.code, 'KMG');
    expect(
      find.descendant(of: picker, matching: find.text('Cabang Kemang')),
      findsOneWidget,
    );
  });

  testWidgets('pindah cabang dari halaman Stok: kembali ke Beranda cabang '
      'baru, isi halaman lama tidak dipakai', (tester) async {
    final store = twoOutlets();
    await pumpLakuna(
      tester,
      platform: web,
      store: store,
      initialLocation: Routes.stock,
    );
    expect(find.byKey(const ValueKey('home-greeting')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('outlet-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('outlet-KMG')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-greeting')), findsOneWidget);
    expect(find.textContaining('Cabang Kemang'), findsWidgets);
  });

  testWidgets('web: tanpa tombol Ganti kasir', (tester) async {
    await pumpLakuna(tester, platform: web, store: twoOutlets());
    expect(find.byKey(const ValueKey('switch-cashier')), findsNothing);
  });

  testWidgets('web dengan 1 cabang dan native: tanpa pemilih', (
    tester,
  ) async {
    await pumpLakuna(
      tester,
      platform: web,
      store: FakeStoreRepository(current: sampleStoreContext()),
    );
    expect(find.byKey(const ValueKey('outlet-picker')), findsNothing);
  });

  testWidgets('native: tanpa pemilih meski 2 cabang', (tester) async {
    await pumpLakuna(tester, store: twoOutlets());
    expect(find.byKey(const ValueKey('outlet-picker')), findsNothing);
    expect(find.byKey(const ValueKey('switch-cashier')), findsOneWidget);
  });
}
