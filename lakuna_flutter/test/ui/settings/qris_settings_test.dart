import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/image_file_picker.dart';
import 'package:lakuna_flutter/routing/routes.dart';
import 'package:lakuna_flutter/ui/settings/qris_settings_section.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_payment_settings_repository.dart';
import '../../testing/fake_session_repository.dart';
import '../../testing/qris_seed.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

Finder _input(String key) =>
    find.descendant(of: _key(key), matching: find.byType(EditableText));

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key).last);
  await tester.tap(_key(key).last);
  await tester.pumpAndSettle();
}

/// Header PNG (tanpa data gambar) berukuran [w] × [h].
Uint8List _pngHeader(int w, int h) {
  int b(int v, int s) => (v >> s) & 0xFF;
  return Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
    0, 0, 0, 13, 0x49, 0x48, 0x44, 0x52, //
    b(w, 24), b(w, 16), b(w, 8), b(w, 0), //
    b(h, 24), b(h, 16), b(h, 8), b(h, 0), //
    8, 6, 0, 0, 0, 0, 0, 0, 0, 0,
  ]);
}

void main() {
  test('formatFileSize', () {
    expect(formatFileSize(900), '900 B');
    expect(formatFileSize(412 * 1024), '412 KB');
    expect(formatFileSize(1468006), '1,4 MB');
    expect(formatFileSize(1468006, decimal: '.'), '1.4 MB');
  });

  testWidgets('pemilik: unggah stiker, isi data merchant, simpan', (
    tester,
  ) async {
    final repo = FakePaymentSettingsRepository();
    final picker = FakeImagePicker();
    await pumpLakuna(
      tester,
      initialLocation: Routes.settings,
      paymentSettings: repo,
      imagePicker: picker,
    );
    await _tap(tester, 'settings-section-payments');
    expect(_key('qris-settings'), findsOneWidget);
    expect(find.text('Belum ada gambar QRIS'), findsOneWidget);
    expect(
      find.text('Berlaku untuk Cabang Pusat · semua perangkat cabang ini'),
      findsOneWidget,
    );

    // Aktif tanpa gambar ditolak.
    await _tap(tester, 'qris-enabled');
    await _tap(tester, 'qris-settings-save');
    expect(_key('qris-settings-image-missing'), findsOneWidget);
    expect(repo.saves, isEmpty);

    // Bukan gambar → galat, tombol simpan mati.
    picker.next = PickedImage(
      name: 'qris.gif',
      size: 12,
      bytes: Uint8List.fromList('GIF89a......'.codeUnits),
    );
    await _tap(tester, 'qris-settings-pick');
    expect(find.text('File bukan PNG, JPG, atau WebP.'), findsOneWidget);
    expect(tester.widget<FButton>(_key('qris-settings-save')).onPress, isNull);

    final bytes = _pngHeader(1080, 1528);
    picker.next = PickedImage(
      name: 'qris-warung.png',
      size: 412 * 1024,
      bytes: bytes,
    );
    await _tap(tester, 'qris-settings-pick');
    expect(
      find.text(
        'Rasio vertikal terdeteksi (1 : 1,41). Gambar ditampilkan utuh, '
        'tidak dipotong.',
      ),
      findsOneWidget,
    );
    expect(find.text('Resolusi 1080 × 1528 px.'), findsOneWidget);
    expect(find.text('qris-warung.png · 412 KB'), findsOneWidget);

    await tester.enterText(_input('qris-merchant-1-0'), 'WARUNG CONTOH');
    await tester.enterText(_input('qris-nmid-1-0'), 'id-1');
    await tester.pumpAndSettle();
    await _tap(tester, 'qris-settings-save');
    expect(find.text('Hanya huruf dan angka, maks 20'), findsOneWidget);

    await tester.enterText(_input('qris-nmid-1-0'), 'id10234567890');
    await tester.enterText(
      _input('qris-settlement-1'),
      'Rekening BCA 123-456-7890',
    );
    await tester.pumpAndSettle();
    // Sakelar PIN manajer Sudah Terbayar (F1-05h): bawaan hidup.
    expect(tester.widget<FSwitch>(_key('qris-without-pin')).value, isTrue);
    await _tap(tester, 'qris-without-pin');
    // Tampilkan di ponsel kasir (F1-18e): bawaan hidup.
    expect(tester.widget<FSwitch>(_key('qris-show-on-phone')).value, isTrue);
    await _tap(tester, 'qris-show-on-phone');
    await _tap(tester, 'qris-settings-save');
    expect(_key('qris-settings-saved'), findsOneWidget);
    final (settings, image) = repo.saves.single;
    expect(settings.enabled, isTrue);
    expect(settings.cashierConfirmWithoutPin, isFalse);
    expect(settings.showOnPhone, isFalse);
    expect(settings.merchantName, 'WARUNG CONTOH');
    expect(image!.fileName, 'qris-warung.png');
    expect(image.bytes, bytes);
    // Field diisi ulang dari nilai tersimpan (NMID huruf besar).
    expect(
      tester.widget<EditableText>(_input('qris-nmid-2-0')).controller.text,
      'ID10234567890',
    );
  });

  testWidgets('gambar kecil dan mendatar: peringatan; Batal mengembalikan', (
    tester,
  ) async {
    final repo = FakePaymentSettingsRepository(
      initial: QrisConfig(
        settings: const QrisStaticSettings(enabled: true, merchantName: 'TOKO'),
        imageBytes: tinyPortraitPng,
      ),
    );
    final picker = FakeImagePicker()
      ..next = PickedImage(
        name: 'a.png',
        size: 34,
        bytes: _pngHeader(900, 600),
      );
    await pumpLakuna(
      tester,
      size: const Size(390, 844),
      initialLocation: Routes.settings,
      paymentSettings: repo,
      imagePicker: picker,
    );
    await _tap(tester, 'settings-section-payments');
    expect(_key('qris-settings-preview'), findsOneWidget);
    await _tap(tester, 'qris-settings-pick');
    expect(
      find.text(
        'Gambar tidak vertikal (1 : 0,67). Pastikan ini stiker QRIS utuh.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Resolusi 900 × 600 px. Disarankan ≥ 1000 px lebar agar tajam di '
        'tablet.',
      ),
      findsOneWidget,
    );
    await tester.enterText(_input('qris-merchant-1-0'), 'UBAH');
    await tester.pumpAndSettle();
    await _tap(tester, 'qris-settings-cancel');
    expect(
      tester.widget<EditableText>(_input('qris-merchant-2-0')).controller.text,
      'TOKO',
    );
    expect(find.text('a.png · 34 B'), findsNothing);
    expect(repo.saves, isEmpty);
  });

  testWidgets('file lebih dari 5 MB tidak dibaca dan ditolak', (tester) async {
    final picker = FakeImagePicker()
      ..next = PickedImage(
        name: 'besar.png',
        size: 6 * 1024 * 1024,
        bytes: Uint8List(6 * 1024 * 1024),
      );
    await pumpLakuna(
      tester,
      initialLocation: Routes.settings,
      imagePicker: picker,
    );
    await _tap(tester, 'settings-section-payments');
    await _tap(tester, 'qris-settings-pick');
    expect(find.text('File lebih dari 5 MB.'), findsOneWidget);
  });

  testWidgets('Foto stiker dari kamera (F1-18f)', (tester) async {
    final repo = FakePaymentSettingsRepository();
    final picker = FakeImagePicker();
    await pumpLakuna(
      tester,
      initialLocation: Routes.settings,
      paymentSettings: repo,
      imagePicker: picker,
    );
    await _tap(tester, 'settings-section-payments');
    // Tanpa kamera (desktop): hanya Pilih file.
    expect(_key('qris-settings-camera'), findsNothing);
    expect(
      find.text(
        'Pilih file stiker dari perangkat. PNG, JPG, atau WebP, maks 5 MB.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Foto stiker: kamera ada, galat izin, lalu foto tersimpan', (
    tester,
  ) async {
    final repo = FakePaymentSettingsRepository();
    final picker = FakeImagePicker()..camera = true;
    await pumpLakuna(
      tester,
      initialLocation: Routes.settings,
      paymentSettings: repo,
      imagePicker: picker,
    );
    await _tap(tester, 'settings-section-payments');
    expect(_key('qris-settings-camera'), findsOneWidget);
    expect(
      find.text(
        'Pilih file stiker atau foto lurus seluruh stiker. PNG, JPG, atau '
        'WebP, maks 5 MB.',
      ),
      findsOneWidget,
    );

    // Izin kamera ditolak: pesan galat, tidak ada gambar.
    picker.throwNext = Exception('camera_access_denied');
    await _tap(tester, 'qris-settings-camera');
    expect(_key('qris-settings-pick-failed'), findsOneWidget);
    expect(
      find.text(
        'Kamera tidak bisa dibuka. Periksa izin kamera di pengaturan '
        'perangkat, atau pilih file.',
      ),
      findsOneWidget,
    );

    // Batal di kamera: tidak terjadi apa-apa, galat tetap.
    await _tap(tester, 'qris-settings-camera');
    expect(picker.photoCalls, 2);
    expect(find.text('Belum ada gambar QRIS'), findsOneWidget);

    final bytes = _pngHeader(1080, 1528);
    picker.next = PickedImage(
      name: 'image_picker_1.jpg',
      size: bytes.length,
      bytes: bytes,
    );
    await _tap(tester, 'qris-settings-camera');
    expect(picker.lastPhotoWidth, 2000);
    expect(_key('qris-settings-pick-failed'), findsNothing);
    expect(find.text('Resolusi 1080 × 1528 px.'), findsOneWidget);

    await _tap(tester, 'qris-settings-save');
    expect(_key('qris-settings-saved'), findsOneWidget);
    expect(repo.saves.single.$2!.bytes, bytes);
  });

  testWidgets('galat Pilih file tampil, hilang saat Batal; tombol mati '
      'selama memilih (F1-18f)', (tester) async {
    final picker = FakeImagePicker()..camera = true;
    await pumpLakuna(
      tester,
      initialLocation: Routes.settings,
      imagePicker: picker,
    );
    await _tap(tester, 'settings-section-payments');
    picker.throwNext = Exception('read failed');
    await _tap(tester, 'qris-settings-pick');
    expect(
      find.text('File tidak bisa dibuka. Pilih file lain.'),
      findsOneWidget,
    );
    await _tap(tester, 'qris-settings-cancel');
    expect(_key('qris-settings-pick-failed'), findsNothing);

    // Selama kamera terbuka: kedua tombol, Simpan, dan Batal mati.
    picker.gate = Completer<void>();
    await tester.ensureVisible(_key('qris-settings-camera'));
    await tester.tap(_key('qris-settings-camera'));
    await tester.pump();
    for (final key in [
      'qris-settings-pick',
      'qris-settings-camera',
      'qris-settings-save',
      'qris-settings-cancel',
    ]) {
      expect(tester.widget<FButton>(_key(key)).onPress, isNull, reason: key);
    }
    picker.gate!.complete();
    picker.gate = null;
    await tester.pumpAndSettle();
    expect(
      tester.widget<FButton>(_key('qris-settings-pick')).onPress,
      isNotNull,
    );
  });

  group('QR terbaca (F1-18g)', () {
    // QRIS statis nyata: NMID ID10234567890, WARUNG CONTOH, terminal A01.
    const statis =
        '00020101021126580011ID.DANA.WWW0118936009150000000001021012345678900'
        '303UMI51420014ID.CO.QRIS.WWW0213ID102345678900303UMI52045812530336058'
        '02ID5913WARUNG CONTOH6007BANDUNG61054011162070703A016304FD1E';
    String dinamis() {
      final body = statis
          .substring(0, statis.length - 4)
          .replaceFirst('010211', '010212');
      return body + qrisCrc16(body);
    }

    Future<(FakePaymentSettingsRepository, FakeImagePicker)> open(
      WidgetTester tester, {
      QrisConfig? initial,
    }) async {
      final repo = FakePaymentSettingsRepository(initial: initial);
      final picker = FakeImagePicker();
      await pumpLakuna(
        tester,
        initialLocation: Routes.settings,
        paymentSettings: repo,
        imagePicker: picker,
      );
      await _tap(tester, 'settings-section-payments');
      return (repo, picker);
    }

    Future<void> pick(WidgetTester tester, FakeImagePicker picker) async {
      final bytes = _pngHeader(1080, 1528);
      picker.next = PickedImage(
        name: 'q.png',
        size: bytes.length,
        bytes: bytes,
      );
      await _tap(tester, 'qris-settings-pick');
    }

    String field(WidgetTester tester, String key) => tester
        .widget<EditableText>(
          find.descendant(
            of: find.byWidgetPredicate(
              (w) =>
                  w.key is ValueKey<String> &&
                  (w.key! as ValueKey<String>).value.startsWith('$key-'),
            ),
            matching: find.byType(EditableText),
          ),
        )
        .controller
        .text;

    testWidgets('QRIS statis: hasil pemeriksaan dan isian kosong terisi', (
      tester,
    ) async {
      final (repo, picker) = await open(tester);
      repo.qr = QrisQrRead.fromText(statis);
      await pick(tester, picker);
      expect(repo.qrReads, hasLength(1));
      expect(
        find.text(
          'QR terbaca: QRIS statis, NMID ID10234567890, merchant WARUNG '
          'CONTOH.',
        ),
        findsOneWidget,
      );
      expect(field(tester, 'qris-merchant'), 'WARUNG CONTOH');
      expect(field(tester, 'qris-nmid'), 'ID10234567890');
      expect(field(tester, 'qris-terminal'), 'A01');
      expect(_key('qris-check-qr-nmid'), findsNothing);

      await _tap(tester, 'qris-settings-save');
      final (settings, _) = repo.saves.single;
      expect(settings.nmid, 'ID10234567890');
      expect(settings.merchantName, 'WARUNG CONTOH');
      expect(settings.terminalCode, 'A01');
      // Gambar baru tersimpan: hasil QR tetap tampil tanpa baca ulang.
      expect(_key('qris-check-qr'), findsOneWidget);
      expect(repo.qrReads, hasLength(1));
    });

    testWidgets('isian yang sudah diketik tidak ditimpa; NMID beda', (
      tester,
    ) async {
      final (repo, picker) = await open(tester);
      await tester.enterText(_input('qris-merchant-1-0'), 'TOKO BU ANI');
      await tester.enterText(_input('qris-nmid-1-0'), 'ID999');
      await tester.pumpAndSettle();
      repo.qr = QrisQrRead.fromText(statis);
      await pick(tester, picker);
      expect(field(tester, 'qris-merchant'), 'TOKO BU ANI');
      expect(field(tester, 'qris-nmid'), 'ID999');
      expect(field(tester, 'qris-terminal'), 'A01');
      expect(
        find.text('NMID di isian (ID999) berbeda dengan QR (ID10234567890).'),
        findsOneWidget,
      );
    });

    testWidgets(
      'dinamis, bukan QRIS, tidak terbaca: peringatan, Simpan aktif',
      (
        tester,
      ) async {
        final (repo, picker) = await open(tester);
        repo.qr = QrisQrRead.fromText(dinamis());
        await pick(tester, picker);
        expect(
          find.text(
            'QR ini QRIS dinamis (nominal sekali pakai). Pakai stiker QRIS '
            'statis dari bank/PJP.',
          ),
          findsOneWidget,
        );

        repo.qr = QrisQrRead.fromText('https://warung.example');
        await pick(tester, picker);
        expect(
          find.text(
            'QR terbaca tapi bukan QRIS. Pastikan gambar yang dipilih adalah '
            'stiker QRIS toko.',
          ),
          findsOneWidget,
        );

        repo.qr = QrisQrRead.fromText(null);
        await pick(tester, picker);
        expect(
          find.text(
            'QR tidak terbaca dari gambar. Pastikan seluruh stiker tajam dan '
            'tidak terpotong; NMID bisa diketik manual.',
          ),
          findsOneWidget,
        );
        // NMID tetap dari QR dinamis (merchant sama), tidak dihapus.
        expect(field(tester, 'qris-nmid'), 'ID10234567890');
        expect(
          tester.widget<FButton>(_key('qris-settings-save')).onPress,
          isNotNull,
        );
      },
    );

    testWidgets('gambar tersimpan dibaca saat dibuka, tanpa isi otomatis', (
      tester,
    ) async {
      final saved = _pngHeader(1080, 1528);
      final (repo, _) = await open(
        tester,
        initial: QrisConfig(
          settings: const QrisStaticSettings(enabled: true),
          imageBytes: saved,
        ),
      );
      // Hasil bawaan fake: QR tidak terbaca.
      expect(repo.qrReads.single, saved);
      expect(_key('qris-check-qr'), findsOneWidget);
      expect(field(tester, 'qris-nmid'), isEmpty);
    });
  });

  testWidgets('kasir tanpa settings:manage hanya melihat Tampilan', (
    tester,
  ) async {
    await pumpLakuna(
      tester,
      initialLocation: Routes.settings,
      session: FakeSessionRepository()..current = sampleStaff(role: 'cashier'),
    );
    expect(_key('qris-settings'), findsNothing);
    expect(_key('settings-section-payments'), findsNothing);
    expect(_key('theme-dark'), findsOneWidget);
  });
}
