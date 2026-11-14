# Rencana F1-07n — Buang metadata lokasi dari gambar

Spec: [F1-07n](../specs/2026-11-14-f1-07n-buang-metadata-foto-design.md).

## Langkah

- [x] **Tes domain** `stripImageMetadata` (JPEG, PNG, WebP, orientasi,
  berkas rusak); lalu implementasi.
- [x] **Tes data** foto produk kecil dan stiker QRIS ber-Exif GPS; lalu
  panggil di `storeMediaFile`.
- [x] **Review** subagent baru; perbaiki Critical/Important.
- [x] **Uji manual Xvfb**: unggah foto ber-GPS, periksa berkas `media/`.
- [x] **Dokumen**: spec F1-07l, README, STATUS-JEDA, panduan, CHANGELOG
  0.72.0, pubspec `0.72.0+75`.
- [x] **PR, merge, cek rilis.**
