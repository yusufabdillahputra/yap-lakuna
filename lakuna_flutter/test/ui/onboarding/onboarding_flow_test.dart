import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_store_repository.dart';

Future<void> _type(WidgetTester tester, SetupField field, String text) async {
  final input = find.descendant(
    of: find.byKey(ValueKey('field-${field.name}')),
    matching: find.byType(EditableText),
  );
  await tester.ensureVisible(input);
  await tester.enterText(input, text);
  await tester.pump();
}

Future<void> _next(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('onboarding-next')));
  await tester.pumpAndSettle();
}

Future<void> _completeWizard(WidgetTester tester) async {
  expect(find.text('Langkah 1 dari 4'), findsOneWidget);
  await _next(tester);

  expect(find.text('Jenis usaha & cabang pertama'), findsWidgets);
  await tester.tap(find.byKey(const ValueKey('business-fnb')));
  await tester.pump();
  await _type(tester, SetupField.businessName, 'Warung Contoh');
  await _type(tester, SetupField.outletName, 'Cabang Pusat');
  await _type(tester, SetupField.outletCode, 'bd-g');
  // Kode langsung huruf besar dan hanya huruf/angka saat diketik.
  expect(find.text('BDG'), findsOneWidget);
  expect(find.textContaining('BDG-K01-'), findsOneWidget);
  await _next(tester);

  expect(find.text('Langkah 3 dari 4'), findsOneWidget);
  await _type(tester, SetupField.ownerName, 'Yusuf');
  await _type(tester, SetupField.email, 'yusuf@contoh.id');
  await _type(tester, SetupField.password, 'rahasia123');
  await _type(tester, SetupField.pin, '123456');
  await _type(tester, SetupField.pinConfirm, '123456');
  await _next(tester);

  expect(find.text('Langkah 4 dari 4'), findsOneWidget);
  expect(find.text('Warung Contoh · F&B'), findsOneWidget);
  await _next(tester);
}

void main() {
  testWidgets('instal baru membuka wizard setup, bukan beranda', (
    tester,
  ) async {
    await pumpLakuna(tester, store: FakeStoreRepository());
    expect(find.text('Siapkan toko Anda dalam 4 langkah'), findsOneWidget);
    expect(find.byKey(const ValueKey('onboarding-side-panel')), findsOneWidget);
    expect(find.text('Selamat datang di Lakuna'), findsNothing);
  });

  testWidgets('galat tampil dan langkah tidak berpindah bila isian kosong', (
    tester,
  ) async {
    await pumpLakuna(tester, store: FakeStoreRepository());
    await _next(tester);
    await _next(tester);
    expect(find.text('Langkah 2 dari 4'), findsOneWidget);
    expect(find.text('Wajib diisi'), findsNWidgets(2));
    expect(find.text('2–6 huruf atau angka'), findsOneWidget);
  });

  testWidgets('tablet: alur lengkap lalu masuk beranda dengan nama toko', (
    tester,
  ) async {
    final store = FakeStoreRepository();
    await pumpLakuna(tester, store: store, size: const Size(1194, 834));
    await _completeWizard(tester);

    expect(store.setupCalls.single.outletCode, 'BDG');
    expect(store.setupCalls.single.businessType, BusinessKind.fnb);
    expect(find.text('Selamat datang di Lakuna'), findsOneWidget);
    expect(find.text('Warung Contoh · Cabang Pusat · K01'), findsOneWidget);
  });

  testWidgets('mobile: tanpa panel samping, dengan progress, alur lengkap', (
    tester,
  ) async {
    final store = FakeStoreRepository();
    await pumpLakuna(tester, store: store, size: const Size(400, 800));
    expect(find.byKey(const ValueKey('onboarding-side-panel')), findsNothing);
    await _completeWizard(tester);
    expect(store.current, isNotNull);
    expect(find.text('Warung Contoh · Cabang Pusat · K01'), findsOneWidget);
  });

  testWidgets('setup gagal menampilkan pesan dan tetap di ringkasan', (
    tester,
  ) async {
    final store = FakeStoreRepository(failSetup: true);
    await pumpLakuna(tester, store: store);
    await _completeWizard(tester);
    expect(find.text('Toko gagal disimpan. Coba lagi.'), findsOneWidget);
    expect(find.text('Langkah 4 dari 4'), findsOneWidget);
  });

  testWidgets('isian tetap ada setelah kembali ke langkah sebelumnya', (
    tester,
  ) async {
    await pumpLakuna(tester, store: FakeStoreRepository());
    await _next(tester);
    await _type(tester, SetupField.businessName, 'Toko Bu Ani');
    await _type(tester, SetupField.outletName, 'Cabang Pusat');
    await _type(tester, SetupField.outletCode, 'PST');
    await _next(tester);
    await _type(tester, SetupField.ownerName, 'Ani');
    await tester.tap(find.byKey(const ValueKey('onboarding-back')));
    await tester.pumpAndSettle();
    expect(find.text('Toko Bu Ani'), findsOneWidget);
    await _next(tester);
    expect(find.text('Ani'), findsOneWidget);
  });

  testWidgets('sakelar EN mengganti bahasa wizard', (tester) async {
    await pumpLakuna(tester, store: FakeStoreRepository());
    await tester.tap(find.byKey(const ValueKey('onboarding-lang-en')));
    await tester.pumpAndSettle();
    expect(find.text('Set up your store in 4 steps'), findsOneWidget);
  });

  testWidgets('setelah setup, jalur /setup dialihkan ke beranda', (
    tester,
  ) async {
    await pumpLakuna(tester, initialLocation: Routes.setup);
    expect(find.text('Selamat datang di Lakuna'), findsOneWidget);
    expect(find.text('Siapkan toko Anda dalam 4 langkah'), findsNothing);
  });
}
