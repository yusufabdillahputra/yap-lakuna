import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_flutter/app_root.dart';
import 'package:lakuna_flutter/bootstrap.dart' show AppInstance;
import 'package:lakuna_flutter/data/repositories/backup_repository.dart';
import 'package:lakuna_flutter/routing/routes.dart';
import 'package:lakuna_flutter/ui/settings/backup_section.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_backup_repository.dart';
import '../../testing/fake_session_repository.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key).last);
  await tester.pumpAndSettle();
  await tester.tap(_key(key).last);
  await tester.pumpAndSettle();
}

Text _text(WidgetTester tester, String key) => tester.widget<Text>(_key(key));

void main() {
  test('ukuran berkas ringkas', () {
    expect(formatFileSize(512), '512 B');
    expect(formatFileSize(640 * 1024), '640 KB');
    expect(formatFileSize(18 * 1024 * 1024 + 200 * 1024), '18,2 MB');
    expect(formatFileSize(2 * 1024 * 1024 * 1024, decimal: '.'), '2 GB');
  });

  for (final size in [const Size(1440, 900), const Size(360, 740)]) {
    testWidgets('Data & backup (1.13) di ${size.width.toInt()} px', (
      tester,
    ) async {
      final backup = FakeBackupRepository(last: DateTime.utc(2026, 10, 1));
      final files = FakeBackupFiles();
      await pumpLakuna(
        tester,
        size: size,
        initialLocation: Routes.settingsBackup,
        backup: backup,
        backupFiles: files,
      );
      expect(_key('backup-section'), findsOneWidget);
      expect(find.text('1240'), findsOneWidget);
      expect(find.text('18 MB'), findsOneWidget);
      expect(_key('backup-hosting'), findsOneWidget);

      await _tap(tester, 'backup-now');
      expect(files.delivered, ['lakuna-backup-PST-261104-1600.zip']);
      expect(_text(tester, 'backup-result').data, contains('/docs/Lakuna'));
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in [const Size(1440, 900), const Size(360, 740)]) {
    testWidgets('backup otomatis ${size.width.toInt()} px (F1-19d)', (
      tester,
    ) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (call) async => '/docs',
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        ),
      );
      final backup = FakeBackupRepository(last: DateTime.utc(2026, 10, 1))
        ..autoLast = DateTime.utc(2026, 11, 1, 9)
        ..autoFailed = true;
      await pumpLakuna(
        tester,
        size: size,
        initialLocation: Routes.settingsBackup,
        backup: backup,
        backupFiles: FakeBackupFiles(),
      );
      await tester.ensureVisible(_key('backup-auto-card'));
      await tester.pumpAndSettle();
      expect(find.text('Backup otomatis harian'), findsOneWidget);
      expect(find.textContaining('Lakuna/Backup/Otomatis'), findsOneWidget);
      expect(find.textContaining('Backup otomatis terakhir'), findsWidgets);
      expect(_key('backup-auto-failed'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final label = find.descendant(
        of: _key('backup-auto'),
        matching: find.text('Backup otomatis harian'),
      );
      await tester.tap(label);
      await tester.pumpAndSettle();
      expect(backup.autoEnabled, isFalse);
      // Sakelar mati: pesan gagal lama tidak lagi relevan.
      expect(_key('backup-auto-failed'), findsNothing);
    });
  }

  testWidgets('pulihkan: ketik nama toko lalu pulihkan', (tester) async {
    final backup = FakeBackupRepository(last: DateTime.now().toUtc());
    final files = FakeBackupFiles();
    await pumpLakuna(
      tester,
      size: const Size(1440, 900),
      initialLocation: Routes.settingsBackup,
      backup: backup,
      backupFiles: files,
    );
    await _tap(tester, 'backup-restore');
    expect(_key('backup-restore-panel'), findsOneWidget);
    expect(find.textContaining('Cabang Pusat'), findsWidgets);

    final submit = _key('backup-restore-submit');
    await _tap(tester, 'backup-restore-submit');
    expect(backup.staged, isEmpty);

    await tester.enterText(
      find.descendant(
        of: _key('backup-restore-confirm'),
        matching: find.byType(EditableText),
      ),
      'warung contoh',
    );
    await tester.pumpAndSettle();
    expect(submit, findsOneWidget);
    await _tap(tester, 'backup-restore-submit');
    expect(backup.staged, [files.picked]);
  });

  testWidgets('pulihkan: berkas tidak sah menampilkan galat', (tester) async {
    final backup = FakeBackupRepository(last: DateTime.now().toUtc())
      ..inspectError = const BackupInvalid('zip');
    await pumpLakuna(
      tester,
      size: const Size(1440, 900),
      initialLocation: Routes.settingsBackup,
      backup: backup,
    );
    await _tap(tester, 'backup-restore');
    expect(_key('backup-restore-error'), findsOneWidget);
    expect(_key('backup-restore-panel'), findsNothing);
  });

  Future<void> enter(WidgetTester tester, String key, String text) async {
    final field = find.descendant(
      of: _key(key),
      matching: find.byType(EditableText),
    );
    await tester.ensureVisible(field);
    await tester.enterText(field, text);
    await tester.pumpAndSettle();
  }

  bool enabled(WidgetTester tester, String key) =>
      tester.widget<FButton>(_key(key)).onPress != null;

  for (final size in [const Size(1280, 800), const Size(360, 740)]) {
    testWidgets('kunci backup dengan kata sandi ${size.width.toInt()} px '
        '(F1-19c)', (tester) async {
      final backup = FakeBackupRepository(last: DateTime.utc(2026, 10, 1));
      final files = FakeBackupFiles();
      await pumpLakuna(
        tester,
        size: size,
        initialLocation: Routes.settingsBackup,
        backup: backup,
        backupFiles: files,
      );
      expect(_key('backup-password'), findsNothing);
      await _tap(tester, 'backup-lock');
      expect(_key('backup-lock-note'), findsOneWidget);
      expect(enabled(tester, 'backup-now'), isFalse);

      await enter(tester, 'backup-password', 'pendek');
      expect(find.text('Minimal 8 karakter.'), findsOneWidget);
      await enter(tester, 'backup-password', 'rahasia-toko');
      await enter(tester, 'backup-password-retype', 'rahasia-tok');
      expect(find.text('Kata sandi tidak sama.'), findsOneWidget);
      expect(enabled(tester, 'backup-now'), isFalse);
      await enter(tester, 'backup-password-retype', 'rahasia-toko');
      expect(enabled(tester, 'backup-now'), isTrue);

      await _tap(tester, 'backup-now');
      expect(backup.createdPasswords, ['rahasia-toko']);
      expect(
        _text(tester, 'backup-result').data,
        startsWith('Backup terkunci kata sandi tersimpan di'),
      );
      // Isian dikosongkan setelah backup dibuat.
      final fields = tester.widgetList<EditableText>(
        find.descendant(
          of: _key('backup-section'),
          matching: find.byType(EditableText),
        ),
      );
      expect(fields.map((f) => f.controller.text), everyElement(isEmpty));
      expect(enabled(tester, 'backup-now'), isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('pulihkan backup terkunci ${size.width.toInt()} px '
        '(F1-19c)', (tester) async {
      final backup = FakeBackupRepository(last: DateTime.now().toUtc())
        ..lockPassword = 'rahasia-toko';
      final files = FakeBackupFiles();
      await pumpLakuna(
        tester,
        size: size,
        initialLocation: Routes.settingsBackup,
        backup: backup,
        backupFiles: files,
      );
      await _tap(tester, 'backup-restore');
      expect(_key('backup-unlock-panel'), findsOneWidget);
      expect(_key('backup-restore-panel'), findsNothing);
      expect(_key('backup-restore-error'), findsNothing);
      expect(enabled(tester, 'backup-unlock'), isFalse);

      await enter(tester, 'backup-unlock-password', 'salah-sandi');
      await _tap(tester, 'backup-unlock');
      expect(find.text('Kata sandi salah. Coba lagi.'), findsOneWidget);

      await enter(tester, 'backup-unlock-password', 'rahasia-toko');
      await _tap(tester, 'backup-unlock');
      expect(_key('backup-unlock-panel'), findsNothing);
      expect(_key('backup-restore-panel'), findsOneWidget);
      await enter(tester, 'backup-restore-confirm', 'Warung Contoh');
      await _tap(tester, 'backup-restore-submit');
      expect(backup.stagedPasswords, ['rahasia-toko']);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('manajer tidak melihat Data & backup', (tester) async {
    await pumpLakuna(
      tester,
      size: const Size(1440, 900),
      initialLocation: Routes.settingsBackup,
      session: FakeSessionRepository(
        current: sampleStaff(name: 'Rina', role: 'manager'),
      ),
    );
    expect(_key('settings-section-backup'), findsNothing);
    expect(_key('backup-section'), findsNothing);
  });

  group('baris backup di Beranda', () {
    testWidgets('belum pernah backup: baris dan tautan ke Pengaturan', (
      tester,
    ) async {
      await pumpLakuna(
        tester,
        size: const Size(1440, 900),
        backup: FakeBackupRepository(),
      );
      expect(
        tester.widget<Text>(_key('home-attention-backup-text')).data,
        'Data belum pernah di-backup',
      );
      await _tap(tester, 'home-attention-backup-view');
      expect(_key('backup-section'), findsOneWidget);
    });

    testWidgets('backup baru: hari ini', (tester) async {
      await pumpLakuna(tester, size: const Size(1440, 900));
      expect(
        tester.widget<Text>(_key('home-attention-backup-text')).data,
        startsWith('Backup terakhir hari ini'),
      );
    });

    testWidgets('kasir tidak melihat baris backup', (tester) async {
      await pumpLakuna(
        tester,
        size: const Size(360, 740),
        backup: FakeBackupRepository(),
        session: FakeSessionRepository(
          current: sampleStaff(name: 'Dimas', role: 'cashier'),
        ),
      );
      expect(_key('home-attention-backup'), findsNothing);
    });
  });

  testWidgets('database gagal dibuka: layar galat dengan lokasi data', (
    tester,
  ) async {
    final dir = await tester.runAsync(
      () => Directory.systemTemp.createTemp('lakuna-root-'),
    );
    addTearDown(() => dir!.deleteSync(recursive: true));
    final path = '${dir!.path}/lakuna.sqlite';
    await tester.pumpWidget(
      LakunaRoot(
        resolvePath: () async => path,
        boot: (_) async => throw StateError('database rusak'),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(_key('startup-error'), findsOneWidget);
    final details = _text(tester, 'startup-error-details').data!;
    expect(details, contains('database rusak'));
    expect(details, contains(path));
  });

  testWidgets('backup gagal dibuka: data lama dikembalikan', (tester) async {
    final dir = await tester.runAsync(
      () => Directory.systemTemp.createTemp('lakuna-root-'),
    );
    addTearDown(() => dir!.deleteSync(recursive: true));
    final path = '${dir!.path}/lakuna.sqlite';
    File(path).writeAsStringSync('lama');
    Directory('${dir.path}/restore').createSync();
    File('${dir.path}/restore/lakuna.sqlite').writeAsStringSync('rusak');
    File('${dir.path}/restore/ready').writeAsStringSync('x');
    final opened = <String>[];
    await tester.pumpWidget(
      LakunaRoot(
        resolvePath: () async => path,
        boot: (p) async {
          final content = File(p).readAsStringSync();
          opened.add(content);
          if (content != 'lama') throw StateError('database rusak');
          return AppInstance(
            close: () async {},
            app: Builder(
              builder: (context) => Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  'gagal=${AppRestart.maybeOf(context)!.restoreFailed}',
                ),
              ),
            ),
          );
        },
      ),
    );
    for (var i = 0; i < 40 && find.byType(Text).evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
    expect(opened, ['rusak', 'lama']);
    expect(find.text('gagal=true'), findsOneWidget);
    expect(File(path).readAsStringSync(), 'lama');
    expect(
      dir.listSync().map((e) => e.path.split('/').last),
      contains(startsWith('pulihkan-gagal-')),
    );
  });
}
