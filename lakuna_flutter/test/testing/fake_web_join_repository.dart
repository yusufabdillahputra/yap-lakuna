import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart' show PullProgress;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    show
        EmailAccountPasswordResetException,
        EmailAccountPasswordResetExceptionReason;
import 'package:lakuna_flutter/data/repositories/web_join_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

/// [WebJoinRepository] dan [WebLoginRepository] palsu: mencatat panggilan,
/// progres pull dan galat bisa diatur.
class FakeWebJoinRepository implements WebJoinRepository, WebLoginRepository {
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

  List<WebTenant> tenants = [
    WebTenant(
      tenantId: UuidValue.fromString('01900000-0000-7000-8000-000000000001'),
      name: 'Toko Bu Ani',
    ),
  ];

  /// Galat berikutnya dari [signIn] / [open] (sekali pakai).
  Exception? signInError;
  Exception? openError;
  final signInCalls = <(String, String, String)>[];
  final openCalls = <({String code, UuidValue tenantId, bool remember})>[];
  final resetCalls = <String>[];

  @override
  Future<Result<List<WebTenant>>> signIn(
    String serverUrl, {
    required String email,
    required String password,
  }) async {
    signInCalls.add((serverUrl, email, password));
    if (signInError case final e?) {
      signInError = null;
      return Result.error(e);
    }
    return Result.ok(tenants);
  }

  @override
  Future<Result<String>> open(
    String serverUrl, {
    required String code,
    required UuidValue tenantId,
    required bool remember,
  }) async {
    openCalls.add((code: code, tenantId: tenantId, remember: remember));
    if (openError case final e?) {
      openError = null;
      return Result.error(e);
    }
    return Result.ok(database);
  }

  @override
  Future<Result<UuidValue>> startPasswordReset(
    String serverUrl,
    String email,
  ) async {
    resetCalls.add('start:$email');
    return Result.ok(
      UuidValue.fromString('01900000-0000-7000-8000-0000000000f1'),
    );
  }

  @override
  Future<Result<String>> verifyPasswordReset(
    String serverUrl, {
    required UuidValue requestId,
    required String code,
  }) async {
    resetCalls.add('verify:$code');
    if (code != '12345678') {
      return Result.error(
        EmailAccountPasswordResetException(
          reason: EmailAccountPasswordResetExceptionReason.invalid,
        ),
      );
    }
    return const Result.ok('token-reset');
  }

  @override
  Future<Result<void>> finishPasswordReset(
    String serverUrl, {
    required String token,
    required String password,
  }) async {
    resetCalls.add('finish:$token:$password');
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> discard(String database) async {
    discarded.add(database);
    return const Result.ok(null);
  }
}
