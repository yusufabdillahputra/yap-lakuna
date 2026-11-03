import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

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
}
