import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_data/lakuna_data.dart';
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

    await tester.enterText(_input('qris-merchant-1'), 'WARUNG CONTOH');
    await tester.enterText(_input('qris-nmid-1'), 'id-1');
    await tester.pumpAndSettle();
    await _tap(tester, 'qris-settings-save');
    expect(find.text('Hanya huruf dan angka, maks 20'), findsOneWidget);

    await tester.enterText(_input('qris-nmid-1'), 'id10234567890');
    await tester.enterText(
      _input('qris-settlement-1'),
      'Rekening BCA 123-456-7890',
    );
    await tester.pumpAndSettle();
    await _tap(tester, 'qris-settings-save');
    expect(_key('qris-settings-saved'), findsOneWidget);
    final (settings, image) = repo.saves.single;
    expect(settings.enabled, isTrue);
    expect(settings.merchantName, 'WARUNG CONTOH');
    expect(image!.fileName, 'qris-warung.png');
    expect(image.bytes, bytes);
    // Field diisi ulang dari nilai tersimpan (NMID huruf besar).
    expect(
      tester.widget<EditableText>(_input('qris-nmid-2')).controller.text,
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
    await tester.enterText(_input('qris-merchant-1'), 'UBAH');
    await tester.pumpAndSettle();
    await _tap(tester, 'qris-settings-cancel');
    expect(
      tester.widget<EditableText>(_input('qris-merchant-2')).controller.text,
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
