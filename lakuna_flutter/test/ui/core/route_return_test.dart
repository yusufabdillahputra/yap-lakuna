import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lakuna_flutter/ui/core/route_return.dart';

class _List extends StatefulWidget {
  const _List({super.key});

  @override
  State<_List> createState() => _ListState();
}

class _ListState extends State<_List> with RouteReturnMixin<_List> {
  var returns = 0;

  @override
  void onRouteReturn() => returns++;

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

void main() {
  late GoRouter router;
  late GlobalKey<_ListState> key;

  Future<void> pump(WidgetTester tester) async {
    key = GlobalKey<_ListState>();
    router = GoRouter(
      routes: [
        ShellRoute(
          builder: (context, state, child) => child,
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => _List(key: key),
            ),
            GoRoute(
              path: '/detail',
              builder: (context, state) => const SizedBox.expand(),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      WidgetsApp.router(routerConfig: router, color: const Color(0xFF000000)),
    );
  }

  testWidgets('halaman ditutup biasa: tanda lepas, tanpa onRouteReturn', (
    tester,
  ) async {
    await pump(tester);
    final list = key.currentState!;
    final done = list.whileAway(() => router.push<void>('/detail'));
    await tester.pumpAndSettle();
    expect(list.isAway, isTrue);
    router.pop();
    await tester.pumpAndSettle();
    await done;
    expect(list.isAway, isFalse);
    expect(list.returns, 0);
  });

  testWidgets('kembali lewat go: onRouteReturn sekali, tanda lepas', (
    tester,
  ) async {
    await pump(tester);
    final list = key.currentState!;
    unawaited(list.whileAway(() => router.push<void>('/detail')));
    await tester.pumpAndSettle();
    expect(list.returns, 0);
    router.go('/');
    await tester.pumpAndSettle();
    expect(identical(key.currentState, list), isTrue);
    expect(list.isAway, isFalse);
    expect(list.returns, 1);
  });

  testWidgets('dua halaman terbuka: tanda tetap sampai keduanya ditutup', (
    tester,
  ) async {
    await pump(tester);
    final list = key.currentState!;
    final first = Completer<void>();
    final second = Completer<void>();
    unawaited(list.whileAway(() => first.future));
    unawaited(list.whileAway(() => second.future));
    second.complete();
    await tester.pump();
    expect(list.isAway, isTrue);
    first.complete();
    await tester.pump();
    expect(list.isAway, isFalse);
  });

  testWidgets('future lama selesai setelah kembali lewat go: tidak '
      'mengurangi halaman baru', (tester) async {
    await pump(tester);
    final list = key.currentState!;
    final old = Completer<void>();
    unawaited(
      list.whileAway(() async {
        await router.push<void>('/detail');
        await old.future;
      }),
    );
    await tester.pumpAndSettle();
    router.go('/');
    await tester.pumpAndSettle();
    expect(list.returns, 1);
    final fresh = Completer<void>();
    unawaited(list.whileAway(() => fresh.future));
    old.complete();
    await tester.pump();
    expect(list.isAway, isTrue);
    fresh.complete();
    await tester.pump();
    expect(list.isAway, isFalse);
  });
}
