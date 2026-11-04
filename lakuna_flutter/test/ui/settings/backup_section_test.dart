import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
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

  group('pengingat Beranda', () {
    testWidgets('belum pernah backup: pengingat dan tombol ke Pengaturan', (
      tester,
    ) async {
      await pumpLakuna(
        tester,
        size: const Size(1440, 900),
        backup: FakeBackupRepository(),
      );
      expect(_key('home-backup-reminder'), findsOneWidget);
      await _tap(tester, 'home-backup-action');
      expect(_key('backup-section'), findsOneWidget);
    });

    testWidgets('backup baru: tanpa pengingat', (tester) async {
      await pumpLakuna(tester, size: const Size(1440, 900));
      expect(_key('home-backup-reminder'), findsNothing);
    });

    testWidgets('kasir tidak diingatkan', (tester) async {
      await pumpLakuna(
        tester,
        size: const Size(360, 740),
        backup: FakeBackupRepository(),
        session: FakeSessionRepository(
          current: sampleStaff(name: 'Dimas', role: 'cashier'),
        ),
      );
      expect(_key('home-backup-reminder'), findsNothing);
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
