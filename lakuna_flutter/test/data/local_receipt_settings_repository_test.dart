import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/local_receipt_settings_repository.dart';
import 'package:lakuna_flutter/data/repositories/local_store_repository.dart';
import 'package:lakuna_flutter/data/repositories/receipt_settings_repository.dart';
import 'package:lakuna_flutter/data/repositories/session_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../testing/fake_session_repository.dart';

T _ok<T>(Result<T> result) => (result as Ok<T>).value;
Exception _err<T>(Result<T> result) => (result as Error<T>).error;

void main() {
  late Directory dir;
  late LakunaStore store;
  late FakeSessionRepository session;
  late LocalReceiptSettingsRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('lakuna_receipt_');
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
    repo = LocalReceiptSettingsRepository(
      store,
      stores: stores,
      session: session,
      preferences: LocalPreferences(store.session),
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test('simpan dan muat struk cabang serta printer perangkat', () async {
    final config = _ok(await repo.loadReceipt());
    expect(config.settings.paper, ReceiptPaper.mm58);
    final saved = _ok(
      await repo.saveReceipt(
        const ReceiptSettings(paper: ReceiptPaper.mm80, footer: 'Makasih'),
      ),
    );
    expect(saved.footerLines, ['Makasih']);
    expect(_ok(await repo.loadReceipt()).settings.paper, ReceiptPaper.mm80);
    expect(
      _err(await repo.saveReceipt(ReceiptSettings(header: 'x' * 60))),
      isA<ReceiptSettingsInvalid>(),
    );

    expect(_ok(await repo.loadPrinter()), isNull);
    const printer = PrinterSelection(
      kind: PrinterKind.network,
      name: 'Dapur',
      address: '192.168.1.50:9100',
    );
    _ok(await repo.savePrinter(printer));
    expect(_ok(await repo.loadPrinter()), printer);
  });

  test('printer dapur: simpan, muat, lupakan; kasir ditolak', () async {
    expect(_ok(await repo.loadKitchenPrinter()), isNull);
    const kitchen = KitchenPrinter(
      printer: PrinterSelection(
        kind: PrinterKind.network,
        name: '10.0.0.9',
        address: '10.0.0.9:9100',
      ),
      paper: ReceiptPaper.mm80,
    );
    _ok(await repo.saveKitchenPrinter(kitchen));
    expect(_ok(await repo.loadKitchenPrinter()), kitchen);
    expect(_ok(await repo.loadPrinter()), isNull);
    session.current = staffWithPermissions({Permission.salesCreate});
    expect(_ok(await repo.loadKitchenPrinter()), kitchen);
    expect(_err(await repo.saveKitchenPrinter(null)), isA<NotPermitted>());
  });

  test('kasir tanpa settings:manage: baca boleh, ubah ditolak', () async {
    session.current = staffWithPermissions({Permission.salesCreate});
    expect(_ok(await repo.loadReceipt()).settings.paper, ReceiptPaper.mm58);
    expect(_ok(await repo.loadPrinter()), isNull);
    expect(
      _err(await repo.saveReceipt(const ReceiptSettings())),
      isA<NotPermitted>().having(
        (e) => e.permission,
        'permission',
        Permission.settingsManage,
      ),
    );
    expect(_err(await repo.savePrinter(null)), isA<NotPermitted>());
  });
}
