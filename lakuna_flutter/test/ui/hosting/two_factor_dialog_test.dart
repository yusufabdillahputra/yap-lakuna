import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/data/repositories/hosting_repository.dart'
    show SyncOfflineException;
import 'package:lakuna_client/lakuna_client.dart' show UuidValue;
import 'package:lakuna_domain/lakuna_domain.dart' show Permission;
import 'package:lakuna_flutter/data/repositories/session_repository.dart'
    show StaffProfile;
import 'package:lakuna_flutter/routing/routes.dart';
import 'package:material_ui/material_ui.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_hosting_repository.dart';
import '../../testing/fake_session_repository.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key).last);
  await tester.pumpAndSettle();
  await tester.tap(_key(key).last);
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String key, String text) async {
  await tester.enterText(
    find.descendant(of: _key(key).last, matching: find.byType(EditableText)),
    text,
  );
  await tester.pumpAndSettle();
}

const _hostingRoute = '${Routes.settings}?bagian=hosting';

FakeHostingRepository _active() => FakeHostingRepository(
  state: hostingState(active: true, serverUrl: 'https://sync.tokoku.id'),
);

void main() {
  for (final size in [const Size(1280, 800), const Size(360, 740)]) {
    final w = size.width.toInt();

    testWidgets('kartu aktif: Verifikasi 2 langkah · Belum aktif, aktifkan '
        'sampai kode cadangan ($w px)', (tester) async {
      final hosting = _active();
      await pumpLakuna(
        tester,
        size: size,
        initialLocation: _hostingRoute,
        hosting: hosting,
      );
      expect(
        find.text('Verifikasi 2 langkah · Belum aktif'),
        findsOneWidget,
      );
      await _tap(tester, 'two-factor-enable');
      expect(_key('two-factor-pin'), findsWidgets);
      await _enter(tester, 'two-factor-pin', '123456');
      await _tap(tester, 'two-factor-submit');
      await _enter(tester, 'two-factor-email', 'sari@contoh.id');
      await _enter(tester, 'two-factor-password', 'rahasia123');
      await _tap(tester, 'two-factor-submit');
      expect(_key('two-factor-qr'), findsOneWidget);
      expect(
        find.text('JBSW Y3DP EHPK 3PXP JBSW Y3DP EHPK 3PXP'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await _enter(tester, 'two-factor-code-2', '123456');
      await _tap(tester, 'two-factor-submit');
      expect(_key('two-factor-backup-codes'), findsOneWidget);
      expect(find.text('KODE-0001'), findsOneWidget);
      await _tap(tester, 'two-factor-submit');
      await _tap(tester, 'two-factor-submit');
      expect(_key('two-factor-pin'), findsNothing);
      expect(find.text('Verifikasi 2 langkah · Aktif'), findsOneWidget);
      expect(_key('two-factor-disable'), findsOneWidget);
    });
  }

  testWidgets('kata sandi salah: pesan di langkah akun', (tester) async {
    await pumpLakuna(
      tester,
      initialLocation: _hostingRoute,
      hosting: _active(),
    );
    await _tap(tester, 'two-factor-enable');
    await _enter(tester, 'two-factor-pin', '123456');
    await _tap(tester, 'two-factor-submit');
    await _enter(tester, 'two-factor-email', 'sari@contoh.id');
    await _enter(tester, 'two-factor-password', 'salah');
    await _tap(tester, 'two-factor-submit');
    expect(_key('two-factor-email'), findsOneWidget);
    expect(_key('two-factor-error'), findsOneWidget);
  });

  testWidgets(
    'staf dengan sync:manage yang bukan pemilik tidak melihat baris verifikasi 2 langkah',
    (
      tester,
    ) async {
      await pumpLakuna(
        tester,
        initialLocation: _hostingRoute,
        hosting: _active(),
        session: FakeSessionRepository()
          ..current = StaffProfile(
            id: UuidValue.fromString('01900000-0000-7000-8000-00000000aa01'),
            name: 'Pengelola sync',
            roleKey: 'owner',
            isOwner: false,
            hasPin: true,
            permissions: Permission.values.toSet(),
          ),
      );
      expect(_key('hosting-section'), findsOneWidget);
      expect(_key('two-factor-row'), findsNothing);
    },
  );

  testWidgets('offline: status butuh internet', (tester) async {
    final hosting = _active()
      ..twoFactorStatusError = const SyncOfflineException();
    await pumpLakuna(
      tester,
      initialLocation: _hostingRoute,
      hosting: hosting,
    );
    expect(
      find.text('Verifikasi 2 langkah · Status butuh internet'),
      findsOneWidget,
    );
    expect(_key('two-factor-enable'), findsNothing);
  });
}
