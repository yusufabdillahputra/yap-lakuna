import 'dart:io';

import 'package:lakuna_server/src/sync/server_version.dart';
import 'package:test/test.dart';

void main() {
  test('versi server sama dengan versi aplikasi di pubspec', () {
    final pubspec = File('../lakuna_flutter/pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version: (\d+\.\d+\.\d+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);
    expect(serverVersion, version);
  });
}
