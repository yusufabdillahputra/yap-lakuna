import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/backup_repository.dart'
    show BackupInvalid;
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_backup_repository.dart';
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
  await _type(tester, SetupField.passwordConfirm, 'rahasia123');
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
    expect(find.byKey(const ValueKey('home-greeting')), findsNothing);
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

  testWidgets('ulangi kata sandi yang berbeda menahan langkah 3', (
    tester,
  ) async {
    await pumpLakuna(tester, store: FakeStoreRepository());
    await _next(tester);
    await tester.tap(find.byKey(const ValueKey('business-retail')));
    await _type(tester, SetupField.businessName, 'Warung Contoh');
    await _type(tester, SetupField.outletName, 'Cabang Pusat');
    await _type(tester, SetupField.outletCode, 'PST');
    await _next(tester);
    await _type(tester, SetupField.ownerName, 'Yusuf');
    await _type(tester, SetupField.email, 'yusuf@contoh.id');
    await _type(tester, SetupField.password, 'rahasia123');
    await _type(tester, SetupField.passwordConfirm, 'rahasia124');
    await _type(tester, SetupField.pin, '123456');
    await _type(tester, SetupField.pinConfirm, '123456');
    await _next(tester);
    expect(find.text('Langkah 3 dari 4'), findsOneWidget);
    expect(find.text('Kata sandi tidak sama'), findsOneWidget);
  });

  testWidgets('tablet: alur lengkap lalu masuk beranda dengan nama toko', (
    tester,
  ) async {
    final store = FakeStoreRepository();
    await pumpLakuna(tester, store: store, size: const Size(1194, 834));
    await _completeWizard(tester);

    expect(store.setupCalls.single.outletCode, 'BDG');
    expect(store.setupCalls.single.businessType, BusinessKind.fnb);
    expect(find.byKey(const ValueKey('home-greeting')), findsOneWidget);
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
    expect(find.byKey(const ValueKey('home-greeting')), findsOneWidget);
    expect(find.text('Siapkan toko Anda dalam 4 langkah'), findsNothing);
  });

  for (final size in const [Size(1280, 800), Size(360, 740)]) {
    testWidgets('pulihkan dari backup di langkah 1 ${size.width.toInt()} px '
        '(F1-19b)', (tester) async {
      final backup = FakeBackupRepository();
      final files = FakeBackupFiles();
      await pumpLakuna(
        tester,
        store: FakeStoreRepository(),
        size: size,
        backup: backup,
        backupFiles: files,
      );
      final restore = find.byKey(const ValueKey('onboarding-restore'));
      await tester.ensureVisible(restore);
      await tester.pumpAndSettle();
      await tester.tap(restore);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('setup-restore')), findsOneWidget);
      expect(find.byKey(const ValueKey('setup-restore-submit')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('setup-restore-pick')));
      await tester.pumpAndSettle();
      expect(
        find.text('Warung Contoh · Cabang Pusat · perangkat K01'),
        findsOneWidget,
      );
      final submit = find.byKey(const ValueKey('setup-restore-submit'));
      expect(tester.widget<FButton>(submit).onPress, isNull);
      final confirm = find.descendant(
        of: find.byKey(const ValueKey('setup-restore-confirm')),
        matching: find.byType(EditableText),
      );
      await tester.ensureVisible(confirm);
      await tester.enterText(confirm, 'warung contoh');
      await tester.pumpAndSettle();
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(backup.staged, [files.picked]);
    });
  }

  testWidgets('langkah 2 tidak menampilkan pulihkan; galat berkas tampil', (
    tester,
  ) async {
    final backup = FakeBackupRepository()
      ..inspectError = const BackupInvalid('rusak');
    await pumpLakuna(tester, store: FakeStoreRepository(), backup: backup);
    await tester.tap(find.byKey(const ValueKey('onboarding-restore')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('setup-restore-pick')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('setup-restore-error')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('setup-restore-cancel')));
    await tester.pumpAndSettle();
    await _next(tester);
    expect(find.byKey(const ValueKey('onboarding-restore')), findsNothing);
  });
}
