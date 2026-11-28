import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/app_root.dart';
import 'package:lakuna_flutter/bootstrap.dart';
import 'package:lakuna_flutter/config/app_platform.dart';
import 'package:lakuna_flutter/data/services/web_session_store.dart';

void main() {
  const web = AppPlatform(isWeb: true);

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
  }

  testWidgets('web tanpa sesi: layar gabung, database tidak dibuka', (
    tester,
  ) async {
    final opened = <String>[];
    await tester.pumpWidget(
      LakunaRoot(
        platform: web,
        webSessions: MemoryWebSessionStore(),
        resolvePath: () async => throw StateError('tidak dipakai di web'),
        boot: (p) async {
          opened.add(p);
          throw StateError('tidak boleh dibuka');
        },
      ),
    );
    await settle(tester);
    expect(find.byKey(const ValueKey('web-join')), findsOneWidget);
    expect(opened, isEmpty);
  });

  testWidgets('web dengan sesi: membuka database sesi itu', (tester) async {
    final sessions = MemoryWebSessionStore();
    await sessions.setActiveDatabase('lakuna-abc.sqlite');
    final opened = <String>[];
    await tester.pumpWidget(
      LakunaRoot(
        platform: web,
        webSessions: sessions,
        resolvePath: () async => throw StateError('tidak dipakai di web'),
        boot: (p) async {
          opened.add(p);
          return AppInstance(
            close: () async {},
            app: const Directionality(
              textDirection: TextDirection.ltr,
              child: Text('aplikasi'),
            ),
          );
        },
      ),
    );
    await settle(tester);
    expect(opened, ['lakuna-abc.sqlite']);
    expect(find.text('aplikasi'), findsOneWidget);
  });

  testWidgets('database sesi kosong atau rusak (penyimpanan dihapus '
      'browser): kembali ke layar masuk, bukan wizard toko baru', (
    tester,
  ) async {
    final sessions = MemoryWebSessionStore(delete: (_) async {});
    await sessions.setActiveDatabase('lakuna-abc.sqlite');
    await tester.pumpWidget(
      LakunaRoot(
        platform: web,
        webSessions: sessions,
        resolvePath: () async => throw StateError('tidak dipakai di web'),
        boot: (p) async => throw const WebSessionLost(),
      ),
    );
    await settle(tester);
    expect(find.byKey(const ValueKey('web-join')), findsOneWidget);
    expect(sessions.activeDatabase, isNull);
    expect(sessions.staleDatabases, ['lakuna-abc.sqlite']);
  });

  for (final problem in WebStartProblem.values) {
    testWidgets('web tidak bisa mulai (${problem.name}): pesan, tanpa '
        'database', (tester) async {
      final opened = <String>[];
      await tester.pumpWidget(
        LakunaRoot(
          platform: web,
          webSessions: MemoryWebSessionStore(problem: problem)
            ..setActiveDatabase('lakuna-abc.sqlite'),
          resolvePath: () async => throw StateError('tidak dipakai di web'),
          boot: (p) async {
            opened.add(p);
            throw StateError('tidak boleh dibuka');
          },
        ),
      );
      await settle(tester);
      expect(
        find.byKey(ValueKey('web-problem-${problem.name}')),
        findsOneWidget,
      );
      expect(opened, isEmpty);
    });
  }

  testWidgets('Keluar: database sesi dihapus setelah ditutup, peringatan '
      'tutup tab mati, lalu layar masuk', (tester) async {
    final deleted = <String>[];
    final closed = <String>[];
    final sessions = MemoryWebSessionStore(delete: (n) async => deleted.add(n));
    await sessions.setActiveDatabase('lakuna-abc.sqlite');
    sessions.setUnsentGuard(true);
    AppRestart? root;
    await tester.pumpWidget(
      LakunaRoot(
        platform: web,
        webSessions: sessions,
        resolvePath: () async => throw StateError('tidak dipakai di web'),
        boot: (p) async => AppInstance(
          close: () async {
            // Dicatat: database belum dihapus selama masih terbuka.
            closed.add('$p dihapus=${deleted.length}');
          },
          app: Builder(
            builder: (context) {
              root = AppRestart.maybeOf(context);
              return const Directionality(
                textDirection: TextDirection.ltr,
                child: Text('aplikasi'),
              );
            },
          ),
        ),
      ),
    );
    await settle(tester);
    expect(find.text('aplikasi'), findsOneWidget);
    expect(root?.webSessions, same(sessions));
    unawaited(root!.signOut!());
    await settle(tester);
    expect(closed, ['lakuna-abc.sqlite dihapus=0']);
    expect(deleted, ['lakuna-abc.sqlite']);
    expect(sessions.activeDatabase, isNull);
    expect(sessions.unsentGuard, isFalse);
    expect(find.byKey(const ValueKey('web-join')), findsOneWidget);
  });

  test('sesi diganti: database lama masuk antrean hapus', () async {
    final deleted = <String>[];
    final sessions = MemoryWebSessionStore(delete: (n) async => deleted.add(n));
    await sessions.setActiveDatabase('lama.sqlite');
    await sessions.setActiveDatabase(null);
    expect(sessions.activeDatabase, isNull);
    expect(sessions.staleDatabases, ['lama.sqlite']);
    await sessions.purgeStale();
    expect(deleted, ['lama.sqlite']);
    expect(sessions.staleDatabases, isEmpty);
  });
}
