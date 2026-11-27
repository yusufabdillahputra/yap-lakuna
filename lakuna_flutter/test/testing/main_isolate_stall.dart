import 'dart:async';

/// Menjalankan [run] sambil mengukur jeda terlama di isolate utama
/// (F1-19f): timer berdetak tiap 5 ms; pekerjaan berat di isolate ini
/// membuat detak tertahan selama pekerjaan itu.
Future<({T result, Duration longestStall, Duration elapsed})>
measureMainIsolateStall<T>(Future<T> Function() run) async {
  final clock = Stopwatch()..start();
  var last = Duration.zero;
  var longest = Duration.zero;
  final timer = Timer.periodic(const Duration(milliseconds: 5), (_) {
    final now = clock.elapsed;
    if (now - last > longest) longest = now - last;
    last = now;
  });
  try {
    final result = await run();
    final end = clock.elapsed;
    if (end - last > longest) longest = end - last;
    return (result: result, longestStall: longest, elapsed: end);
  } finally {
    timer.cancel();
  }
}
