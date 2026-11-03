import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/data/repositories/app_settings_repository.dart';
import 'package:lakuna_flutter/ui/settings/app_settings_view_model.dart';

import '../testing/fake_app_settings_repository.dart';

void main() {
  test('load membaca tema dan bahasa tersimpan', () async {
    final vm = AppSettingsViewModel(
      repository: FakeAppSettingsRepository(
        storedTheme: AppThemeMode.dark,
        storedLocale: const Locale('en'),
      ),
    );
    expect(vm.themeMode, AppThemeMode.system);
    expect(vm.locale, const Locale('id'));
    await vm.load.execute();
    expect(vm.themeMode, AppThemeMode.dark);
    expect(vm.locale, const Locale('en'));
  });

  test(
    'simpan gagal mengembalikan nilai sebelumnya dan menandai error',
    () async {
      final vm = AppSettingsViewModel(
        repository: FakeAppSettingsRepository(failWrites: true),
      );
      await vm.setLocale.execute(const Locale('en'));
      expect(vm.locale, const Locale('id'));
      expect(vm.setLocale.error, isTrue);
    },
  );
}
