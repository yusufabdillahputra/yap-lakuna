import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/data/services/auto_backup.dart';

import '../testing/fake_backup_repository.dart';

/// F1-19d: penjadwal backup otomatis harian.
void main() {
  late FakeBackupRepository repo;
  late DateTime now;
  late AutoBackupScheduler scheduler;
  final folder = Directory('/tmp/lakuna-uji/Otomatis');

  setUp(() {
    repo = FakeBackupRepository();
    now = DateTime.utc(2026, 11, 4, 9);
    repo.now = now;
    scheduler = AutoBackupScheduler(
      repository: repo,
      folder: () async => folder,
      clock: () => now,
    );
  });

  test('belum pernah: jalan; < 24 jam: tidak; ≥ 24 jam: jalan', () async {
    expect(await scheduler.runIfDue(), isTrue);
    expect(repo.autoRuns, [folder.path]);
    now = now.add(const Duration(hours: 23, minutes: 59));
    expect(await scheduler.runIfDue(), isFalse);
    expect(repo.autoRuns, hasLength(1));
    now = repo.autoLast!.add(const Duration(hours: 24));
    repo.now = now;
    expect(await scheduler.runIfDue(), isTrue);
    expect(repo.autoRuns, hasLength(2));
  });

  test('sakelar mati: tidak jalan', () async {
    repo.autoEnabled = false;
    expect(await scheduler.runIfDue(), isFalse);
    expect(repo.autoRuns, isEmpty);
  });

  test('gagal: dicoba lagi pada pemeriksaan berikutnya', () async {
    repo.nextAutoError = const FileSystemException('disk penuh');
    expect(await scheduler.runIfDue(), isFalse);
    expect(repo.autoFailed, isTrue);
    expect(await scheduler.runIfDue(), isTrue);
    expect(repo.autoFailed, isFalse);
  });

  test('pemeriksaan tumpang tindih tidak membuat dua backup', () async {
    final gate = Completer<void>();
    repo.autoGate = gate.future;
    final first = scheduler.runIfDue();
    final second = await scheduler.runIfDue();
    expect(second, isFalse);
    gate.complete();
    expect(await first, isTrue);
    expect(repo.autoRuns, hasLength(1));
  });

  test('waktu terakhir di masa depan (jam dimundurkan): tetap jalan', () async {
    repo.autoLast = now.add(const Duration(days: 2));
    expect(await scheduler.runIfDue(), isTrue);
    expect(repo.autoRuns, hasLength(1));
  });

  test('galat selain Exception tidak lolos; dicoba lagi', () async {
    repo.nextAutoThrow = StateError('database ditutup');
    expect(await scheduler.runIfDue(), isFalse);
    expect(await scheduler.runIfDue(), isTrue);
  });

  test('dispose menunggu backup yang sedang berjalan', () async {
    final gate = Completer<void>();
    repo.autoGate = gate.future;
    final run = scheduler.runIfDue();
    var disposed = false;
    final closing = scheduler.dispose().then((_) => disposed = true);
    await Future<void>.delayed(Duration.zero);
    expect(disposed, isFalse);
    gate.complete();
    await closing;
    expect(disposed, isTrue);
    expect(await run, isTrue);
  });

  // testWidgets memakai waktu palsu, jadi Timer bisa dimajukan.
  testWidgets('start: 2 menit lalu tiap jam; dispose menghentikan', (
    tester,
  ) async {
    scheduler.start();
    await tester.pump(const Duration(minutes: 1));
    expect(repo.autoRuns, isEmpty);
    await tester.pump(const Duration(minutes: 1));
    expect(repo.autoRuns, hasLength(1));
    // Belum 24 jam: pemeriksaan per jam tidak membuat backup baru.
    await tester.pump(const Duration(hours: 3));
    expect(repo.autoRuns, hasLength(1));
    now = now.add(const Duration(hours: 25));
    repo.now = now;
    await tester.pump(const Duration(hours: 1));
    expect(repo.autoRuns, hasLength(2));
    await scheduler.dispose();
    now = now.add(const Duration(days: 3));
    await tester.pump(const Duration(hours: 5));
    expect(repo.autoRuns, hasLength(2));
  });
}
