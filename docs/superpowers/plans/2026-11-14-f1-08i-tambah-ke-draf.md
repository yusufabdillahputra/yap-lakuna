# Rencana F1-08i · *Buka draf* menambahkan barang stok minimum yang belum ada

Spec: [F1-08i](../specs/2026-11-14-f1-08i-tambah-ke-draf-design.md).
Rilis: v0.95.0+98.

- [x] 1. Tes VM gagal dulu (tambahan + baris lama tetap, semua sudah ada,
  simpan ke draf yang sama) dan tes alur F1-08g diperbarui (catatan + dua
  baris, 1280 / 360 px).
- [x] 2. `_applyRestockToDraft`, `_applyRestockPrices(keys)`,
  `restockIntoDraft` / `restockInDraft`; catatan form; `restock` di
  `PurchaseDetailScreen` + router; `onOpenDraft(id, restock)`; l10n ID/EN.
- [x] 3. Format, analyze, semua tes.
- [x] 4. Review subagent: 1 Important diperbaiki (barang di draf lain ikut
  ditambahkan → dibuang sebelum membuka draf, tes dua draf diverifikasi
  mutasi); Minor: catatan hilang setelah simpan, aturan satuan dan gap
  perangkat lain dicatat di spec.
- [x] 5. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-08i/`.
- [x] 6. Dokumen: spec, gap F1-08g, README spec, STATUS-JEDA, panduan
  stok ID/EN, CHANGELOG, versi.
- [ ] 7. PR, CI hijau, squash-merge, rilis.
