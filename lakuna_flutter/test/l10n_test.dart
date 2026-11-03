import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/l10n/gen/app_localizations.dart';

Set<String> _keys(String path) {
  final map = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return map.keys.where((k) => !k.startsWith('@')).toSet();
}

void main() {
  test('app_id.arb dan app_en.arb punya kunci yang sama', () {
    final id = _keys('lib/l10n/app_id.arb');
    final en = _keys('lib/l10n/app_en.arb');
    expect(id.difference(en), isEmpty, reason: 'kunci hanya ada di app_id.arb');
    expect(en.difference(id), isEmpty, reason: 'kunci hanya ada di app_en.arb');
  });

  test('sisa percobaan PIN memakai bentuk tunggal di bahasa Inggris', () {
    final en = lookupAppLocalizations(const Locale('en'));
    expect(en.loginWrongPin(1), 'Wrong PIN. 1 attempt left.');
    expect(en.loginWrongPin(3), 'Wrong PIN. 3 attempts left.');
    final id = lookupAppLocalizations(const Locale('id'));
    expect(id.loginWrongPin(1), 'PIN salah. Sisa 1 percobaan.');
  });
}
