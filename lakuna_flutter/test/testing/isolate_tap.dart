import 'package:flutter_test/flutter_test.dart';

/// Mengetuk [finder] yang memulai pekerjaan di isolate sungguhan (PDF,
/// F1-19f), lalu menunggu dengan waktu nyata sampai [done]. Isolate tidak
/// bisa selesai di dalam waktu palsu `testWidgets`.
Future<void> tapAndWaitForIsolate(
  WidgetTester tester,
  Finder finder,
  bool Function() done,
) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.runAsync(() async {
    await tester.tap(finder);
    for (var i = 0; i < 1000 && !done(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  });
  expect(done(), isTrue, reason: 'pekerjaan di isolate tidak selesai');
  await tester.pumpAndSettle();
}
