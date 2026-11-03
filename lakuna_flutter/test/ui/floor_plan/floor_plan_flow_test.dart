import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_flutter/data/services/image_file_picker.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_dining_admin_repository.dart';
import '../../testing/fake_dining_repository.dart';
import '../../testing/fake_payment_settings_repository.dart';
import '../../testing/fake_session_repository.dart';
import '../../testing/floor_seed.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key));
  await tester.pumpAndSettle();
  await tester.tap(_key(key));
  await tester.pumpAndSettle();
}

void main() {
  late FakeDiningAdminRepository admin;
  late FakeImagePicker picker;

  Future<void> pump(WidgetTester tester, Size size) async {
    admin = FakeDiningAdminRepository();
    picker = FakeImagePicker();
    await pumpLakuna(
      tester,
      size: size,
      initialLocation: Routes.tablesFloor(),
      diningAdmin: admin,
      imagePicker: picker,
      session: FakeSessionRepository()..current = sampleStaff(),
    );
  }

  testWidgets(
    'tablet: mode denah, unggah, tambah dan tempatkan meja, simpan',
    (tester) async {
      await pump(tester, const Size(1280, 800));
      expect(find.text('Atur denah meja'), findsOneWidget);
      expect(_key('floor-grid-info'), findsOneWidget);

      await _tap(tester, 'floor-mode-floor');
      expect(_key('floor-upload'), findsOneWidget);
      expect(find.text('Unggah gambar denah area Indoor'), findsOneWidget);
      expect(_key('floor-take-photo'), findsNothing);
      expect(_key('floor-tips'), findsOneWidget);

      picker.next = PickedImage(name: 'denah.png', size: 69, bytes: samplePng);
      await _tap(tester, 'floor-pick-file');
      expect(admin.images, hasLength(1));
      expect(_key('floor-canvas'), findsOneWidget);
      expect(_key('floor-select-hint'), findsOneWidget);

      await _tap(tester, 'floor-preset-1');
      expect(find.text('Meja M3 dipilih'), findsOneWidget);
      expect(_key('floor-table-M3'), findsOneWidget);
      await _tap(tester, 'floor-unplaced-M1');
      expect(find.text('Meja M1 dipilih'), findsOneWidget);
      expect(_key('floor-table-M1'), findsOneWidget);
      await _tap(tester, 'floor-shape-round');
      await _tap(tester, 'floor-can-merge');

      await _tap(tester, 'floor-undo');
      await _tap(tester, 'floor-redo');
      expect(_key('floor-unsaved'), findsOneWidget);
      await _tap(tester, 'floor-save');
      final sent = admin.lastLayout!;
      expect(sent.mode, DiningLayoutMode.floor);
      final m1 = sent.tables.firstWhere((t) => t.name == 'M1');
      expect(
        (m1.shape, m1.canMerge, m1.x != null),
        (
          TableShape.round,
          true,
          true,
        ),
      );
      expect(sent.tables.map((t) => t.name), containsAll(['M2', 'M3']));
      expect(_key('floor-unsaved'), findsNothing);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets(
    'pindah area dengan draf menanyakan buang perubahan',
    (tester) async {
      await pump(tester, const Size(1280, 800));
      await _tap(tester, 'floor-mode-floor');
      await _tap(tester, 'floor-area-Teras');
      expect(_key('floor-discard'), findsOneWidget);
      await _tap(tester, 'floor-discard-cancel');
      expect(_key('floor-upload'), findsOneWidget);
      await _tap(tester, 'floor-area-Teras');
      await _tap(tester, 'floor-discard-confirm');
      expect(_key('floor-grid-info'), findsOneWidget);
      expect(find.textContaining('Teras'), findsWidgets);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets(
    'ponsel 360 px: unggah dan kanvas tanpa luapan',
    (tester) async {
      await pump(tester, const Size(360, 740));
      expect(tester.takeException(), isNull);
      await _tap(tester, 'floor-mode-floor');
      expect(tester.takeException(), isNull);
      picker.next = PickedImage(name: 'denah.png', size: 69, bytes: samplePng);
      await _tap(tester, 'floor-pick-file');
      expect(_key('floor-canvas'), findsOneWidget);
      await _tap(tester, 'floor-preset-0');
      expect(find.text('Meja M3 dipilih'), findsOneWidget);
      await _tap(tester, 'floor-save');
      expect(admin.lastLayout, isNotNull);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets(
    'layar Meja: Denah bawaan, ketuk meja membuka bill, chip belum ditempatkan',
    (tester) async {
      final dining = FakeDiningRepository()
        ..useFloorPlan(1, {'M1': (100, 100), 'M2': (300, 100)});
      await pumpLakuna(
        tester,
        size: const Size(1280, 800),
        initialLocation: Routes.tables,
        dining: dining,
        session: FakeSessionRepository()..current = sampleStaff(),
      );
      expect(_key('dining-layout-floor'), findsOneWidget);
      expect(_key('dining-floor-canvas'), findsOneWidget);
      expect(_key('dining-floor-locked'), findsOneWidget);
      expect(_key('dining-floor-table-M1'), findsOneWidget);
      expect(_key('dining-unplaced-M3'), findsOneWidget);
      expect(_key('dining-arrange'), findsOneWidget);

      await tester.tap(_key('dining-floor-table-M1'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: _key('dining-guests'),
          matching: find.byType(EditableText),
        ),
        '2',
      );
      await _tap(tester, 'dining-guests-open');
      expect(find.textContaining('Meja M1'), findsWidgets);

      await _tap(tester, 'dining-unplaced-M3');
      expect(_key('dining-guests'), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: _key('dining-guests-dialog'),
          matching: find.text('Batal'),
        ),
      );
      await tester.pumpAndSettle();

      await _tap(tester, 'dining-layout-grid');
      expect(_key('dining-table-M2'), findsOneWidget);
      expect(_key('dining-floor-canvas'), findsNothing);

      await _tap(tester, 'dining-arrange');
      expect(find.text('Atur denah meja'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );
}
