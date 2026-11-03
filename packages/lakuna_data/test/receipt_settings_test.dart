import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;

  setUp(() async {
    (store, dir) = await openTempStore();
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<ReceiptConfig> save(ReceiptSettings settings) => saveReceiptSettings(
    store,
    scope,
    staffId: ctx.owner.id,
    settings: settings,
  );

  test('belum diatur: 58 mm, header dari alamat dan telepon cabang', () async {
    expect((await loadReceiptConfig(store, scope)).headerText, '');
    await Outlet.db.updateRow(
      store.session,
      ctx.outlet.copyWith(address: ' Jl. Melati No. 12 ', phone: '0812'),
    );
    final config = await loadReceiptConfig(store, scope);
    expect(config.settings.paper, ReceiptPaper.mm58);
    expect(config.settings.header, isNull);
    expect(config.settings.footer, isNull);
    expect(config.settings.autoPrint, isFalse);
    expect(config.headerText, 'Jl. Melati No. 12\n0812');
    expect(config.headerLines, ['Jl. Melati No. 12', '0812']);
  });

  test('simpan lalu muat; header kosong tetap kosong (bukan bawaan)', () async {
    await Outlet.db.updateRow(
      store.session,
      ctx.outlet.copyWith(address: 'Jl. Melati'),
    );
    final saved = await save(
      const ReceiptSettings(
        paper: ReceiptPaper.mm80,
        header: '',
        footer:
            ' Terima kasih \n\n Barang yang sudah dibeli tidak dapat '
            'ditukar ',
        autoPrint: true,
      ),
    );
    expect(saved.settings.paper, ReceiptPaper.mm80);
    expect(saved.headerLines, isEmpty);
    expect(
      saved.settings.footer,
      'Terima kasih\nBarang yang sudah dibeli tidak dapat ditukar',
    );
    expect(saved.footerLines, hasLength(2));
    expect(saved.settings.autoPrint, isTrue);

    final again = await loadReceiptConfig(store, scope);
    expect(again.settings.paper, ReceiptPaper.mm80);
    expect(again.settings.autoPrint, isTrue);

    // Simpan ulang memperbarui baris yang sama lewat outbox.
    await save(again.settings.copyWith(paper: ReceiptPaper.mm58));
    final rows = await Setting.db.find(
      store.session,
      where: (t) => t.key.equals(receiptSettingKey),
    );
    expect(rows.single.version, 2);
    expect(rows.single.scopeKey, settingScopeOutlet(ctx.outlet.id));
    final outbox = await SyncOutboxEntry.db.find(
      store.session,
      where: (t) => t.entity.equals('settings'),
    );
    expect(outbox, hasLength(2));
  });

  test('isian terlalu panjang ditolak tanpa menulis', () async {
    await expectLater(
      save(ReceiptSettings(header: 'x' * 49, footer: '1\n2\n3\n4\n5')),
      throwsA(
        isA<ReceiptSettingsInvalid>().having((e) => e.errors, 'errors', {
          ReceiptSettingsError.headerLineTooLong,
          ReceiptSettingsError.footerTooManyLines,
        }),
      ),
    );
    expect(await Setting.db.count(store.session), 0);
  });

  test('baris rusak dibaca sebagai bawaan', () async {
    await save(const ReceiptSettings(paper: ReceiptPaper.mm80));
    final row = await Setting.db.findFirstRow(
      store.session,
      where: (t) => t.key.equals(receiptSettingKey),
    );
    await Setting.db.updateRow(store.session, row!.copyWith(valueJson: '"x"'));
    expect(
      (await loadReceiptConfig(store, scope)).settings.paper,
      ReceiptPaper.mm58,
    );
  });

  test('cabang lain tidak terbaca', () async {
    await save(const ReceiptSettings(paper: ReceiptPaper.mm80));
    final other = CatalogScope(
      tenantId: scope.tenantId,
      outletId: UuidValue.fromString(newId()),
      deviceId: scope.deviceId,
    );
    expect(
      (await loadReceiptConfig(store, other)).settings.paper,
      ReceiptPaper.mm58,
    );
  });

  group('printer perangkat', () {
    test('belum dipilih → null; simpan, muat, hapus', () async {
      final prefs = LocalPreferences(store.session);
      expect(await loadPrinterSelection(prefs), isNull);
      const printer = PrinterSelection(
        kind: PrinterKind.bluetooth,
        name: 'RPP02N',
        address: '66:22:B1:00:00:01',
      );
      await savePrinterSelection(prefs, printer);
      expect(await loadPrinterSelection(prefs), printer);
      await savePrinterSelection(prefs, null);
      expect(await loadPrinterSelection(prefs), isNull);
    });

    test('isi rusak → null', () async {
      final prefs = LocalPreferences(store.session);
      await prefs.set(printerSelectionKey, '{"kind":"usb"}');
      expect(await loadPrinterSelection(prefs), isNull);
      await prefs.set(printerSelectionKey, 'bukan json');
      expect(await loadPrinterSelection(prefs), isNull);
    });

    test('alamat jaringan host:port', () {
      expect(parseNetworkAddress('192.168.1.50:9100'), ('192.168.1.50', 9100));
      expect(parseNetworkAddress(' printer.lan '), ('printer.lan', 9100));
      expect(parseNetworkAddress('10.0.0.2:0'), isNull);
      expect(parseNetworkAddress('10.0.0.2:70000'), isNull);
      expect(parseNetworkAddress('bad host'), isNull);
      expect(parseNetworkAddress(''), isNull);
    });
  });
}
