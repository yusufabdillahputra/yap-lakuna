import 'dart:io';
import 'dart:typed_data';

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

  group('logo struk (F1-06b)', () {
    Future<ReceiptConfig> saveLogo(
      ReceiptSettings settings, {
      ReceiptLogoUpload? logo,
      bool removeLogo = false,
    }) => saveReceiptSettings(
      store,
      scope,
      staffId: ctx.owner.id,
      settings: settings,
      logo: logo,
      removeLogo: removeLogo,
    );

    test('simpan logo: media cabang, sakelar menyala, byte termuat', () async {
      final bytes = pngBytes(200, 80);
      final saved = await saveLogo(
        const ReceiptSettings(showLogo: true),
        logo: ReceiptLogoUpload(bytes: bytes, fileName: 'logo.png'),
      );
      expect(saved.settings.showLogo, isTrue);
      expect(saved.settings.logoMediaId, isNotNull);
      expect(saved.logoImage, bytes);
      expect(saved.logoBytes, bytes);
      final media = await MediaFile.db.findById(
        store.session,
        saved.settings.logoMediaId!,
      );
      expect(media!.kind, MediaKind.receiptLogo);
      expect(media.outletId, ctx.outlet.id);
      final outbox = await SyncOutboxEntry.db.find(store.session);
      expect(
        outbox.map((e) => e.entity),
        containsAll(['media_files', 'settings']),
      );

      // Sakelar mati: logo tetap tersimpan, tidak dicetak.
      final hidden = await saveLogo(saved.settings.copyWith(showLogo: false));
      expect(hidden.settings.logoMediaId, saved.settings.logoMediaId);
      expect(hidden.logoImage, bytes);
      expect(hidden.logoBytes, isNull);

      // Hapus logo: sakelar ikut mati.
      final removed = await saveLogo(
        hidden.settings.copyWith(showLogo: true),
        removeLogo: true,
      );
      expect(removed.settings.logoMediaId, isNull);
      expect(removed.settings.showLogo, isFalse);
      expect(removed.logoImage, isNull);
    });

    test('tanpa logo sakelar tidak bisa menyala', () async {
      final saved = await saveLogo(const ReceiptSettings(showLogo: true));
      expect(saved.settings.showLogo, isFalse);
    });

    test('logo baru dengan sakelar dimatikan pemilik tetap mati', () async {
      final saved = await saveLogo(
        const ReceiptSettings(),
        logo: ReceiptLogoUpload(bytes: pngBytes(20, 20), fileName: 'l.png'),
      );
      expect(saved.settings.logoMediaId, isNotNull);
      expect(saved.settings.showLogo, isFalse);
      expect(saved.logoBytes, isNull);
    });

    test('berkas bukan PNG/JPG atau > 1 MB ditolak tanpa menulis', () async {
      await expectLater(
        saveLogo(
          const ReceiptSettings(),
          logo: ReceiptLogoUpload(
            bytes: Uint8List.fromList([1, 2, 3]),
            fileName: 'x.txt',
          ),
        ),
        throwsA(
          isA<ReceiptLogoInvalid>().having(
            (e) => e.error,
            'error',
            ReceiptLogoError.unsupported,
          ),
        ),
      );
      final big = Uint8List(maxReceiptLogoBytes + 1)
        ..setAll(0, pngBytes(10, 10));
      await expectLater(
        saveLogo(
          const ReceiptSettings(),
          logo: ReceiptLogoUpload(bytes: big, fileName: 'besar.png'),
        ),
        throwsA(isA<ReceiptLogoInvalid>()),
      );
      expect(await Setting.db.count(store.session), 0);
    });

    test('berkas logo belum ada di perangkat → tanpa gambar', () async {
      final saved = await saveLogo(
        const ReceiptSettings(showLogo: true),
        logo: ReceiptLogoUpload(bytes: pngBytes(20, 20), fileName: 'l.png'),
      );
      final media = await MediaFile.db.findById(
        store.session,
        saved.settings.logoMediaId!,
      );
      File(
        '${store.mediaDirectory}${Platform.pathSeparator}${media!.storageKey}',
      ).deleteSync();
      final again = await loadReceiptConfig(store, scope);
      expect(again.settings.showLogo, isTrue);
      expect(again.logoImage, isNull);
      expect(again.logoBytes, isNull);

      // Baris media belum tersinkron ke perangkat ini: simpan ulang tidak
      // membuang id logo.
      await MediaFile.db.deleteRow(store.session, media);
      final kept = await saveLogo(again.settings);
      expect(kept.settings.logoMediaId, saved.settings.logoMediaId);
      expect(kept.logoImage, isNull);
    });
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
