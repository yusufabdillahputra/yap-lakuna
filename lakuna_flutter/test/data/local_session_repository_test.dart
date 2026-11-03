import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/local_session_repository.dart';
import 'package:lakuna_flutter/data/repositories/local_store_repository.dart';
import 'package:lakuna_flutter/data/repositories/repository_errors.dart';
import 'package:lakuna_flutter/data/repositories/session_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

SetupInput _input() => SetupInput(
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
);

void main() {
  late Directory dir;
  late LakunaStore store;
  late LocalStoreRepository stores;
  late LocalSessionRepository session;
  late DateTime now;
  late StoreContext ctx;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('lakuna_session_');
    store = await LakunaStore.open('${dir.path}/lakuna.sqlite');
    const hasher = CredentialHasher.forTesting();
    stores = LocalStoreRepository(
      store,
      hasher: hasher,
      platform: DevicePlatform.linux,
    );
    ctx = ((await stores.setup(_input())) as Ok<StoreContext>).value;
    now = DateTime.utc(2026, 11, 3, 8);
    session = LocalSessionRepository(
      store,
      stores: stores,
      hasher: hasher,
      guard: PinGuard(clock: () => now),
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test('daftar staf berisi pemilik dengan PIN', () async {
    final staff = (await session.listStaff() as Ok<List<StaffProfile>>).value;
    expect(staff, hasLength(1));
    expect(staff.single.name, 'Ani');
    expect(staff.single.isOwner, isTrue);
    expect(staff.single.hasPin, isTrue);
  });

  test('PIN benar memulai sesi dengan semua izin pemilik', () async {
    var notified = 0;
    session.addListener(() => notified++);
    final result = await session.loginWithPin(ctx.owner.id, '123456');
    expect(result, isA<Ok<StaffProfile>>());
    expect(session.current!.id, ctx.owner.id);
    expect(session.current!.can(Permission.usersManage), isTrue);
    expect(notified, 1);
  });

  test('PIN salah mengurangi sisa percobaan, ke-5 mengunci', () async {
    for (var left = 4; left >= 1; left--) {
      final r = await session.loginWithPin(ctx.owner.id, '000000');
      final error = (r as Error).error;
      expect(error, isA<WrongPin>());
      expect((error as WrongPin).remainingAttempts, left);
    }
    final locked = await session.loginWithPin(ctx.owner.id, '000000');
    final lockError = (locked as Error).error;
    expect(lockError, isA<CredentialsLocked>());
    expect(
      (lockError as CredentialsLocked).retryAfter,
      const Duration(seconds: 60),
    );

    // PIN benar pun ditolak selama dikunci.
    final stillLocked = await session.loginWithPin(ctx.owner.id, '123456');
    expect((stillLocked as Error).error, isA<CredentialsLocked>());
    expect(session.current, isNull);

    now = now.add(const Duration(seconds: 60));
    expect(
      await session.loginWithPin(ctx.owner.id, '123456'),
      isA<Ok<StaffProfile>>(),
    );
  });

  test('percobaan bersamaan diperiksa berurutan per staf', () async {
    // Tanpa antrean, PIN benar yang dikirim bersamaan lolos sebelum
    // kegagalan ke-5 tercatat.
    final results = await Future.wait([
      for (var i = 0; i < 5; i++) session.loginWithPin(ctx.owner.id, '000000'),
      session.loginWithPin(ctx.owner.id, '123456'),
    ]);
    expect((results.last as Error).error, isA<CredentialsLocked>());
    expect(session.current, isNull);
  });

  test('sisa kunci bisa dibaca per staf dan per email', () async {
    expect(session.pinRetryAfter(ctx.owner.id), isNull);
    for (var i = 0; i < 5; i++) {
      await session.loginWithPin(ctx.owner.id, '000000');
      await session.loginWithPassword(' Ani@Contoh.id', 'salah12345');
    }
    expect(session.pinRetryAfter(ctx.owner.id), const Duration(seconds: 60));
    expect(
      session.passwordRetryAfter('ani@contoh.id'),
      const Duration(seconds: 60),
    );
  });

  test('staf yang tidak dikenal tidak bisa login', () async {
    final r = await session.loginWithPin(
      UuidValue.fromString(newId()),
      '123456',
    );
    expect((r as Error).error, isA<StaffUnavailable>());
  });

  test('pemilik bisa login dengan email dan kata sandi', () async {
    final ok = await session.loginWithPassword(' ANI@contoh.id ', 'rahasia123');
    expect(ok, isA<Ok<StaffProfile>>());
    expect(session.current!.isOwner, isTrue);
  });

  test('email atau kata sandi salah memberi galat yang sama', () async {
    final wrongPassword = await session.loginWithPassword(
      'ani@contoh.id',
      'salah12345',
    );
    final unknownEmail = await session.loginWithPassword(
      'siapa@contoh.id',
      'rahasia123',
    );
    expect((wrongPassword as Error).error, isA<WrongCredentials>());
    expect((unknownEmail as Error).error, isA<WrongCredentials>());
    expect(session.current, isNull);
  });

  test('startOwnerSession lalu logout', () {
    var notified = 0;
    session.addListener(() => notified++);
    session.startOwnerSession(ctx);
    expect(session.current!.id, ctx.owner.id);
    expect(session.current!.isOwner, isTrue);
    session.logout();
    expect(session.current, isNull);
    expect(notified, 2);
  });

  group('persetujuan PIN (F1-11)', () {
    Future<StaffMember> addCashier() {
      final actor = ctx.owner.id;
      return store.write(actor: actor, (w) async {
        final s = await w.stamp();
        final staff = await w.insert(
          StaffMember(
            tenantId: ctx.tenant.id,
            name: 'Sari',
            pinHash: const CredentialHasher.forTesting().hash('654321'),
            isActive: true,
            createdBy: actor,
            updatedBy: actor,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
        await w.insert(
          OutletMember(
            tenantId: ctx.tenant.id,
            outletId: ctx.outlet.id,
            staffMemberId: staff.id,
            roleName: DefaultRole.cashier.key,
            createdBy: actor,
            updatedBy: actor,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
        return staff;
      });
    }

    test('PIN benar memberi profil penyetuju tanpa mengganti sesi', () async {
      final cashier = await addCashier();
      await session.loginWithPin(cashier.id, '654321');
      var notified = 0;
      session.addListener(() => notified++);
      final result = await session.verifyApprover(
        ctx.owner.id,
        '123456',
        Permission.salesVoid,
      );
      expect((result as Ok<StaffProfile>).value.id, ctx.owner.id);
      expect(session.current!.id, cashier.id);
      expect(notified, 0);
    });

    test('PIN salah memakai kunci yang sama dengan login', () async {
      for (var left = 4; left >= 1; left--) {
        final r = await session.verifyApprover(
          ctx.owner.id,
          '000000',
          Permission.salesVoid,
        );
        expect(((r as Error).error as WrongPin).remainingAttempts, left);
      }
      final locked = await session.verifyApprover(
        ctx.owner.id,
        '000000',
        Permission.salesVoid,
      );
      expect((locked as Error).error, isA<CredentialsLocked>());
      expect(session.pinRetryAfter(ctx.owner.id), isNotNull);
    });

    test('staf tanpa izin ditolak walau PIN benar', () async {
      final cashier = await addCashier();
      final result = await session.verifyApprover(
        cashier.id,
        '654321',
        Permission.salesVoid,
      );
      expect((result as Error).error, isA<NotPermitted>());
    });
  });
}
