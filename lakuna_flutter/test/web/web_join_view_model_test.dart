import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart'
    show PullProgress, SyncOfflineException;
import 'package:lakuna_flutter/data/services/web_session_store.dart';
import 'package:lakuna_flutter/ui/web/web_join_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../testing/fake_web_join_repository.dart';

void main() {
  late FakeWebJoinRepository repo;
  late MemoryWebSessionStore sessions;
  late int joined;

  setUp(() {
    repo = FakeWebJoinRepository();
    sessions = MemoryWebSessionStore(delete: (_) async {});
    joined = 0;
  });

  WebJoinViewModel model({String server = ''}) => WebJoinViewModel(
    repository: repo,
    sessions: sessions,
    onJoined: () async => joined++,
    initialServer: server,
  );

  test(
    'kode pasang sah: perangkat web dibuat, data ditarik, sesi aktif',
    () async {
      final vm = model(server: 'https://toko.contoh.id');
      vm.setCode('abcd2345');
      expect(vm.canSubmit, isTrue);
      final seen = <(int, int?)>[];
      vm.addListener(() {
        if (vm.preparing) seen.add((vm.pulled, vm.total));
      });
      await vm.start.execute();
      expect(repo.registerCalls.single.$3, repo.outlets.first.id);
      expect(repo.registerCalls.single.$2, 'ABCD2345');
      expect(seen, containsAll([(2, 5), (5, 5)]));
      expect(sessions.activeDatabase, 'lakuna-web.sqlite');
      expect(sessions.pendingDatabase, isNull);
      expect(joined, 1);
    },
  );

  test('tempel <alamat>#<kode> di isian kode mengisi alamat', () {
    final vm = model();
    vm.setCode('https://toko.contoh.id#ABCD2345');
    expect(vm.serverUrl, 'https://toko.contoh.id');
    expect(vm.code, 'ABCD2345');
    expect(vm.serverRevision, 1);
  });

  test(
    'putus saat menarik: galat, bisa diulang tanpa perangkat baru',
    () async {
      final vm = model(server: 'https://toko.contoh.id');
      vm.setCode('ABCD2345');
      repo.pullError = const SyncOfflineException();
      await vm.start.execute();
      expect(vm.preparing, isTrue);
      expect(vm.start.result, isA<Error<void>>());
      expect(sessions.pendingDatabase, 'lakuna-web.sqlite');
      expect(sessions.activeDatabase, isNull);
      await vm.start.execute();
      expect(repo.registerCalls, hasLength(1));
      expect(repo.pullCalls, hasLength(2));
      expect(sessions.activeDatabase, 'lakuna-web.sqlite');
      expect(joined, 1);
    },
  );

  test('Batal: database dihapus dan kembali ke formulir', () async {
    final vm = model(server: 'https://toko.contoh.id');
    vm.setCode('ABCD2345');
    repo.pullError = const SyncOfflineException();
    await vm.start.execute();
    await vm.cancel.execute();
    expect(repo.discarded, ['lakuna-web.sqlite']);
    expect(sessions.pendingDatabase, isNull);
    expect(sessions.activeDatabase, isNull);
    expect(vm.preparing, isFalse);
    expect(joined, 0);
  });

  test('tab dibuka lagi di tengah pull: dilanjutkan tanpa kode pasang '
      '(Fokus review 2)', () async {
    await sessions.setPendingDatabase('lakuna-web.sqlite');
    final vm = model();
    expect(vm.preparing, isTrue);
    await vm.resumed;
    expect(repo.registerCalls, isEmpty);
    expect(repo.pullCalls, ['lakuna-web.sqlite']);
    expect(sessions.activeDatabase, 'lakuna-web.sqlite');
    expect(joined, 1);
  });

  test('toko tanpa cabang aktif: galat di formulir', () async {
    repo.outlets = [];
    final vm = model(server: 'https://toko.contoh.id');
    vm.setCode('ABCD2345');
    await vm.start.execute();
    expect(
      (vm.start.result! as Error).error,
      isA<WebJoinNoOutlet>(),
    );
    expect(repo.registerCalls, isEmpty);
    expect(vm.preparing, isFalse);
  });

  test('Batal saat pull berjalan: sesi masuk antrean hapus, halaman '
      'dimuat ulang', () async {
    final release = Completer<void>();
    final slow = _BlockingRepository(release);
    var reloads = 0;
    final vm = WebJoinViewModel(
      repository: slow,
      sessions: sessions,
      onJoined: () async => joined++,
      initialServer: 'https://toko.contoh.id',
      reload: () async => reloads++,
    );
    vm.setCode('ABCD2345');
    final running = vm.start.execute();
    await Future<void>.delayed(Duration.zero);
    expect(vm.start.running, isTrue);
    await vm.cancel.execute();
    expect(reloads, 1);
    expect(sessions.pendingDatabase, isNull);
    expect(sessions.staleDatabases, ['lakuna-web.sqlite']);
    release.complete();
    await running;
    expect(sessions.activeDatabase, isNull);
    expect(joined, 0);
  });
}

class _BlockingRepository extends FakeWebJoinRepository {
  _BlockingRepository(this.release);
  final Completer<void> release;

  @override
  Future<Result<void>> pull(String database, {PullProgress? onPull}) async {
    await release.future;
    return const Result.ok(null);
  }
}
