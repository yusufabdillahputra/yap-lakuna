# Rencana F1-12e · Harga beli terakhir untuk barang yang ditambah manual

Spec: [F1-12e](../specs/2026-11-14-f1-12e-harga-terakhir-barang-manual-design.md).
Rilis: v0.92.0+95.

- [x] 1. Tes VM gagal dulu (satuan dasar, ubah selama menunggu, satuan
  konversi lalu kembali, galat baca) + penghitung panggilan di repositori
  palsu.
- [x] 2. `PurchaseFormViewModel._fillLastPrice` + cache `_lastPrices`.
- [x] 3. Tes widget 1440 / 360 px; panduan ID/EN.
- [x] 4. Format, analyze, semua tes.
- [x] 5. Review subagent: tanpa Critical/Important; Minor diterapkan
  (cache dikosongkan di form baru, cache restock hanya varian diminta,
  simpan menunggu pengisian harga) + tes tambahan.
- [x] 6. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-12e/`.
- [x] 7. Dokumen: spec, gap F1-08e, README spec, STATUS-JEDA, CHANGELOG,
  versi.
- [x] 8. PR, CI hijau, squash-merge, rilis (#98).
