import 'dart:async';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/ui/core/exit_guard.dart';

void main() {
  group('ExitGuard (F1-02c)', () {
    Future<void> pumpGuard(
      WidgetTester tester,
      Future<bool> Function() canExit,
    ) => tester.pumpWidget(
      ExitGuard(canExit: canExit, child: const SizedBox()),
    );

    testWidgets('boleh ditinggalkan → aplikasi ditutup', (tester) async {
      await pumpGuard(tester, () async => true);
      expect(
        await tester.binding.handleRequestAppExit(),
        AppExitResponse.exit,
      );
    });

    testWidgets('tidak boleh → aplikasi tidak ditutup', (tester) async {
      await pumpGuard(tester, () async => false);
      expect(
        await tester.binding.handleRequestAppExit(),
        AppExitResponse.cancel,
      );
    });

    testWidgets('permintaan kedua selama dialog terbuka diabaikan', (
      tester,
    ) async {
      var calls = 0;
      final answer = Completer<bool>();
      await pumpGuard(tester, () {
        calls++;
        return answer.future;
      });
      final first = tester.binding.handleRequestAppExit();
      final second = tester.binding.handleRequestAppExit();
      await tester.pump();
      expect(calls, 1);
      answer.complete(true);
      expect(await first, AppExitResponse.exit);
      expect(await second, AppExitResponse.cancel);
      // Setelah selesai, permintaan baru diperiksa lagi.
      expect(
        await tester.binding.handleRequestAppExit(),
        AppExitResponse.exit,
      );
      expect(calls, 2);
    });

    group('tombol tutup jendela macOS lewat kanal lakuna/window', () {
      const codec = StandardMethodCodec();

      /// Mengirim `requestClose` seperti runner macOS; `null` = tidak ada
      /// penangan (runner langsung menutup aplikasi).
      Future<Object?> requestClose(WidgetTester tester) async {
        ByteData? reply;
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          ExitGuard.windowChannel.name,
          codec.encodeMethodCall(const MethodCall('requestClose')),
          (data) => reply = data,
        );
        return reply == null ? null : codec.decodeEnvelope(reply!);
      }

      testWidgets('diizinkan: permintaan keluar berikutnya tidak bertanya '
          'lagi', (tester) async {
        var calls = 0;
        await pumpGuard(tester, () async {
          calls++;
          return true;
        });
        expect(await requestClose(tester), isTrue);
        expect(
          await tester.binding.handleRequestAppExit(),
          AppExitResponse.exit,
        );
        expect(calls, 1);
        // Izin hanya sekali: permintaan lain diperiksa lagi.
        expect(
          await tester.binding.handleRequestAppExit(),
          AppExitResponse.exit,
        );
        expect(calls, 2);
      });

      testWidgets('ditolak → false, aplikasi tetap', (tester) async {
        await pumpGuard(tester, () async => false);
        expect(await requestClose(tester), isFalse);
        expect(
          await tester.binding.handleRequestAppExit(),
          AppExitResponse.cancel,
        );
      });

      testWidgets('klik kedua selama dialog terbuka → false', (tester) async {
        var calls = 0;
        final answer = Completer<bool>();
        await pumpGuard(tester, () {
          calls++;
          return answer.future;
        });
        final first = requestClose(tester);
        await tester.pump();
        expect(await requestClose(tester), isFalse);
        // Cmd+Q selama dialog terbuka juga ditolak.
        expect(
          await tester.binding.handleRequestAppExit(),
          AppExitResponse.cancel,
        );
        expect(calls, 1);
        answer.complete(false);
        expect(await first, isFalse);
      });

      testWidgets('dilepas: kanal tanpa penangan', (tester) async {
        await pumpGuard(tester, () async => false);
        await tester.pumpWidget(const SizedBox());
        expect(await requestClose(tester), isNull);
      });
    });

    testWidgets('dilepas: tidak lagi menahan', (tester) async {
      await pumpGuard(tester, () async => false);
      await tester.pumpWidget(const SizedBox());
      expect(
        await tester.binding.handleRequestAppExit(),
        AppExitResponse.exit,
      );
    });
  });
}
