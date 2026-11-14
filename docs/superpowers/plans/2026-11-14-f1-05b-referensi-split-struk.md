# Rencana F1-05b — Referensi kartu/transfer di split payment dan struk

Spec: [F1-05b](../specs/2026-11-14-f1-05b-referensi-split-struk-design.md).

**Tujuan:** bagian kartu/transfer di split payment bisa diberi nomor
approval/referensi, dan referensi tercetak di struk.

## Langkah

- [x] **Tes VM** split: referensi terkirim, tunai/QRIS tanpa referensi,
  terlalu panjang, isian kosong setelah tambah; lalu implementasi VM.
- [x] **Tes struk** baris referensi (id/en); lalu `receiptContent` dan l10n.
- [x] **Widget** `SplitPanel`: isian dan teks referensi; tes alur kasir.
- [ ] **Review** subagent baru; perbaiki Critical/Important.
- [ ] **Uji manual Xvfb**: split kartu + tunai dengan no. approval, lihat
  struk.
- [ ] **Dokumen**: spec F1-05 (gap), README, STATUS-JEDA, panduan
  pembayaran id/en, CHANGELOG 0.64.0, pubspec `0.64.0+67`.
- [ ] **PR, merge, cek rilis.**
