# Rencana F1-08h · Tanda "sudah di draf" di tab *Stok minimum*

Spec: [F1-08h](../specs/2026-11-14-f1-08h-tanda-sudah-di-draf-design.md).
Rilis: v0.94.0+97.

- [x] 1. Tes gagal dulu: VM `draftNumberOf` (cocok, draf pertama, galat,
  tanpa fungsi, muat ulang) dan widget 1280 / 360 px.
- [x] 2. `RestockDraft.variantIds`; `StockViewModel.restockDrafts` +
  `draftNumberOf`; `_MinimumPanel`; wiring `StockScreen`; l10n ID/EN.
- [x] 3. Format, analyze, semua tes (data 502, Flutter 1154).
- [x] 4. Review subagent: 2 Important diperbaiki (nomor draf terpotong di
  360 px → dibungkus utuh + tes `didExceedMaxLines`; tes izin + penghitung
  kueri, diverifikasi mutasi); Minor: kueri draf paralel, warna tema
  gelap, komentar penangkapan izin.
- [x] 5. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-08h/`.
- [x] 6. Dokumen: spec, gap F1-08g, README spec, STATUS-JEDA, panduan
  stok ID/EN, CHANGELOG, versi.
- [x] 7. PR, CI hijau, squash-merge, rilis (#100).
