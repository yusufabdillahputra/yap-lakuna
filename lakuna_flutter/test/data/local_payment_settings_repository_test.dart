import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/local_payment_settings_repository.dart';
import 'package:lakuna_flutter/data/repositories/local_store_repository.dart';
import 'package:lakuna_flutter/data/repositories/payment_settings_repository.dart';
import 'package:lakuna_flutter/data/repositories/session_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../testing/fake_session_repository.dart';

T _ok<T>(Result<T> result) => (result as Ok<T>).value;
Exception _err<T>(Result<T> result) => (result as Error<T>).error;

void main() {
  late Directory dir;
  late LakunaStore store;
  late FakeSessionRepository session;
  late LocalPaymentSettingsRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('lakuna_payset_');
    store = await LakunaStore.open('${dir.path}/lakuna.sqlite');
    final stores = LocalStoreRepository(
      store,
      hasher: const CredentialHasher.forTesting(),
      platform: DevicePlatform.linux,
    );
    final ctx = _ok(
      await stores.setup(
        SetupInput(
          businessType: BusinessKind.retail,
          businessName: 'Toko Bu Ani',
          outletName: 'Cabang Pusat',
          outletCode: 'PST',
          deviceCode: 'K01',
          timezone: 'Asia/Jakarta',
          ownerName: 'Ani',
          email: 'ani@contoh.id',
          password: 'rahasia123',
          passwordConfirm: 'rahasia123',
          pin: '123456',
          pinConfirm: '123456',
        ),
      ),
    );
    session = FakeSessionRepository()
      ..current = StaffProfile(
        id: ctx.owner.id,
        name: ctx.owner.name,
        roleKey: 'owner',
        isOwner: true,
        hasPin: true,
        permissions: Permission.values.toSet(),
      );
    repo = LocalPaymentSettingsRepository(
      store,
      stores: stores,
      session: session,
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test('simpan dan muat QRIS statis', () async {
    expect(_ok(await repo.loadQris()).isUsable, isFalse);
    final bytes = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
      0, 0, 0, 13, 0x49, 0x48, 0x44, 0x52, //
      0, 0, 4, 56, 0, 0, 5, 248, 8, 6, 0, 0, 0, 0, 0, 0, 0, 0,
    ]);
    final saved = _ok(
      await repo.saveQris(
        const QrisStaticSettings(enabled: true, nmid: 'id1'),
        image: QrisImageUpload(bytes: bytes, fileName: 'q.png'),
      ),
    );
    expect(saved.isUsable, isTrue);
    expect((saved.media!.width, saved.media!.height), (1080, 1528));
    expect(_ok(await repo.loadQris()).settings.nmid, 'ID1');
    expect(
      _err(await repo.saveQris(const QrisStaticSettings(nmid: '-'))),
      isA<QrisSettingsInvalid>(),
    );
  });

  test('tanpa settings:manage ditolak', () async {
    session.current = staffWithPermissions({Permission.salesCreate});
    expect(
      _err(await repo.loadQris()),
      isA<NotPermitted>().having(
        (e) => e.permission,
        'permission',
        Permission.settingsManage,
      ),
    );
    expect(
      _err(await repo.saveQris(const QrisStaticSettings())),
      isA<NotPermitted>(),
    );
  });
}
