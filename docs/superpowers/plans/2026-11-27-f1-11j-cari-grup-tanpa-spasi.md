# Rencana F1-11j — Cari grup modifier, kata tanpa spasi, garis miring Unicode

Spec: `docs/superpowers/specs/2026-11-27-f1-11j-cari-grup-tanpa-spasi-design.md`

- [x] 1. Domain: tes `phoneSearchKeys` U+2044 dan U+29F8 (gagal), lalu
      tambah ke `_unicodeSlashes`. Tes draf pelanggan `021⁄5551234`.
- [x] 2. Data: tes `history_test.dart` nama grup modifier (gagal), lalu
      subkueri `group_name` dan `itemMatches` menerima grup.
- [x] 3. Data: tes kata tanpa spasi (gagal), lalu `REPLACE(LOWER(..), ' ',
      '')` di SQL dan Dart. Uji mutasi SQL dan Dart.
- [x] 4. Panduan Riwayat ID/EN, spec F1-11e/F1-11f/F1-13f, README specs,
      STATUS-JEDA, GAP-FASE1, CHANGELOG, pubspec 0.149.0+152.
- [x] 5. Format, analyze, semua tes, review subagent, uji Xvfb.
- [ ] 6. PR dan rilis.
