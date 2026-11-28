import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart' show PullProgress;
import 'package:lakuna_flutter/data/repositories/web_join_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

/// [WebJoinRepository] palsu: mencatat panggilan, progres pull bisa diatur.
class FakeWebJoinRepository implements WebJoinRepository {
  List<PairingOutlet> outlets = [
    PairingOutlet(
      id: UuidValue.fromString('01900000-0000-7000-8000-000000000010'),
      code: 'PST',
      name: 'Pusat',
    ),
    PairingOutlet(
      id: UuidValue.fromString('01900000-0000-7000-8000-000000000011'),
      code: 'KMG',
      name: 'Kemang',
    ),
  ];
  String database = 'lakuna-web.sqlite';

  /// Galat berikutnya dari [pull] (sekali pakai).
  Exception? pullError;
  Exception? outletsError;

  /// Progres yang dilaporkan [pull]: (diterima, sisa).
  List<(int, int?)> pages = [(2, 3), (5, 0)];

  final outletCalls = <(String, String)>[];
  final registerCalls = <(String, String, UuidValue)>[];
  final pullCalls = <String>[];
  final discarded = <String>[];

  @override
  Future<Result<List<PairingOutlet>>> pairingOutlets(
    String serverUrl,
    String code,
  ) async {
    outletCalls.add((serverUrl, code));
    if (outletsError case final e?) return Result.error(e);
    return Result.ok(outlets);
  }

  @override
  Future<Result<String>> register(
    String serverUrl, {
    required String code,
    required UuidValue outletId,
  }) async {
    registerCalls.add((serverUrl, code, outletId));
    return Result.ok(database);
  }

  @override
  Future<Result<void>> pull(String database, {PullProgress? onPull}) async {
    pullCalls.add(database);
    if (pullError case final e?) {
      pullError = null;
      onPull?.call(pages.first.$1, pages.first.$2);
      return Result.error(e);
    }
    for (final (n, rest) in pages) {
      onPull?.call(n, rest);
    }
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> discard(String database) async {
    discarded.add(database);
    return const Result.ok(null);
  }
}
