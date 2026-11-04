import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/ui/settings/about_view_model.dart';

void main() {
  test('lisensi dikelompokkan per paket dan diurutkan', () async {
    final vm = AboutViewModel(
      licenses: () => Stream.fromIterable([
        const LicenseEntryWithLineBreaks(['zeta'], 'Lisensi Z.'),
        const LicenseEntryWithLineBreaks(['Alpha', 'beta'], 'Lisensi AB.'),
        const LicenseEntryWithLineBreaks(['alpha'], 'Lisensi a kecil.'),
        const LicenseEntryWithLineBreaks(['Alpha'], 'Satu.\n\nDua.'),
      ]),
    );
    expect(vm.licenses, isEmpty);
    await vm.load.execute();
    expect(vm.load.error, isFalse);
    expect(vm.licenses.map((l) => l.package), [
      'Alpha',
      'alpha',
      'beta',
      'zeta',
    ]);
    final alpha = vm.licenses[0];
    expect(alpha.count, 2);
    expect(vm.licenses[2].count, 1);
    // Paragraf diurai saat dibuka; pemisah antar-entri berupa null.
    expect(alpha.paragraphs().map((p) => p?.text), [
      'Lisensi AB.',
      null,
      'Satu.',
      'Dua.',
    ]);
  });

  test('galat saat membaca lisensi menjadi load.error', () async {
    final vm = AboutViewModel(
      licenses: () => Stream.error(Exception('rusak')),
    );
    await vm.load.execute();
    expect(vm.load.error, isTrue);
    expect(vm.licenses, isEmpty);
  });

  test('galat bukan Exception juga menjadi load.error', () async {
    final vm = AboutViewModel(licenses: () => Stream.error(StateError('x')));
    await vm.load.execute();
    expect(vm.load.error, isTrue);
  });
}
