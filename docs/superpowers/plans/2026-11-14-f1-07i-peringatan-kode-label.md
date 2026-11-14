# Rencana F1-07i · Peringatan kode terlalu panjang untuk label

Spec: `docs/superpowers/specs/2026-11-14-f1-07i-peringatan-kode-label-design.md`

- [x] Tes domain `barcodeTooDense` (gagal), lalu implementasi di
      `lakuna_domain/lib/src/barcode.dart`.
- [x] `barcodeModules` dari hasil gambar paket `barcode` (rumus perkiraan
      awal ternyata salah untuk SKU campuran angka; diganti hitung persis).
- [x] `BarcodeLabelPaper.labelWidthMm` dan `barcodeWidthMm`.
- [x] Tes VM `denseRows` (gagal), lalu `BarcodeLabelViewModel.denseRows`.
- [x] Kunci l10n `labelsTooDense`, `labelsTooDenseHint` (id + en),
      `flutter gen-l10n`.
- [x] `FAlert` `labels-too-dense` di layar Cetak label + tes widget 1280/360.
- [x] Spec, gap F1-07e, README, STATUS-JEDA, panduan, CHANGELOG 0.57.0,
      pubspec 0.57.0+60.
- [x] Review subagent: cache modul, teks "produk" + jamak EN, batasi nama,
      catch spesifik, lebar A4 dari `sheetColumns`, spec disesuaikan.
- [x] Uji manual Xvfb: SKU 14 karakter ditandai di 38 × 25, aman di A4; EAN-13 aman di 38 × 25.
- [ ] PR, merge, cek rilis.
