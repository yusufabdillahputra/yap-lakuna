import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Aplikasi harus berjalan tanpa internet: tidak ada gambar/font dari jaringan.
void main() {
  test('kode aplikasi tidak memuat aset dari internet', () {
    final forbidden = RegExp(
      r'Image\.network|NetworkImage|google_fonts|package:http/',
    );
    // Transport sync versi hosting memang memakai jaringan (unduh media
    // dari server toko di browser, F2-02 aturan 9), bukan aset aplikasi.
    const syncTransport = 'lib/data/services/serverpod_hosting.dart';
    final offenders = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path == syncTransport) continue;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (forbidden.hasMatch(lines[i])) {
          offenders.add('${entity.path}:${i + 1}');
        }
      }
    }
    expect(offenders, isEmpty);
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, isNot(contains('google_fonts')));
  });

  test('font Montserrat dan DM Sans ikut dibundel', () {
    for (final path in [
      'assets/fonts/Montserrat/Montserrat.ttf',
      'assets/fonts/DM_Sans/DMSans.ttf',
    ]) {
      expect(File(path).existsSync(), isTrue, reason: path);
    }
  });
}
