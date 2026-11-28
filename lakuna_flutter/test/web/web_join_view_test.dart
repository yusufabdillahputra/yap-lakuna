import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart' show PullProgress;
import 'package:lakuna_flutter/data/services/web_session_store.dart';
import 'package:lakuna_flutter/ui/web/web_join_view.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../testing/fake_web_join_repository.dart';

/// Pull yang berhenti di tengah sampai [release] selesai.
class _SlowRepository extends FakeWebJoinRepository {
  final release = Completer<void>();

  @override
  Future<Result<void>> pull(String database, {PullProgress? onPull}) async {
    pullCalls.add(database);
    onPull?.call(2, 3);
    await release.future;
    onPull?.call(5, 0);
    return const Result.ok(null);
  }
}

void main() {
  testWidgets('formulir kode pasang lalu *Menyiapkan data toko* dengan '
      'progres', (tester) async {
    final repo = _SlowRepository();
    final sessions = MemoryWebSessionStore(delete: (_) async {});
    var joined = 0;
    await tester.pumpWidget(
      WebJoinApp(
        repository: repo,
        sessions: sessions,
        onJoined: () async => joined++,
        initialServer: 'https://toko.contoh.id',
        locale: const Locale('id'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('web-join')), findsOneWidget);
    expect(find.text('Masuk ke toko versi hosting'), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('web-join-code-0')),
        matching: find.byType(EditableText),
      ),
      'ABCD2345',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('web-join-submit')));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const ValueKey('web-preparing')), findsOneWidget);
    expect(find.text('2 dari 5 perubahan'), findsOneWidget);
    repo.release.complete();
    await tester.pumpAndSettle();
    expect(joined, 1);
    expect(sessions.activeDatabase, 'lakuna-web.sqlite');
  });

  testWidgets('pull terputus: Coba lagi dan Batal', (tester) async {
    final repo = FakeWebJoinRepository()..pullError = Exception('putus');
    final sessions = MemoryWebSessionStore(delete: (_) async {});
    await sessions.setPendingDatabase('lakuna-web.sqlite');
    await tester.pumpWidget(
      WebJoinApp(
        repository: repo,
        sessions: sessions,
        onJoined: () async {},
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('web-preparing-retry')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('web-preparing-cancel')));
    await tester.pumpAndSettle();
    expect(repo.discarded, ['lakuna-web.sqlite']);
    expect(find.byKey(const ValueKey('web-join')), findsOneWidget);
  });
}
