import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_flutter/data/repositories/app_settings_repository.dart';
import 'package:lakuna_flutter/data/repositories/local_app_settings_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

void main() {
  test(
    'tema dan bahasa tersimpan di database lokal dan bawaannya benar',
    () async {
      final dir = await Directory.systemTemp.createTemp('lakuna_app_');
      addTearDown(() => dir.delete(recursive: true));
      final store = await LakunaStore.open('${dir.path}/lakuna.sqlite');
      addTearDown(store.close);
      final repo = LocalAppSettingsRepository(LocalPreferences(store.session));

      expect((await repo.themeMode() as Ok).value, AppThemeMode.system);
      expect((await repo.locale() as Ok).value, const Locale('id'));

      await repo.setThemeMode(AppThemeMode.dark);
      await repo.setLocale(const Locale('en'));
      expect((await repo.themeMode() as Ok).value, AppThemeMode.dark);
      expect((await repo.locale() as Ok).value, const Locale('en'));
    },
  );
}
