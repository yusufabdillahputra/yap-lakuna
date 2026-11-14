# Rencana F1-11b — Cari nota di Riwayat

Spec: [F1-11b](../specs/2026-11-14-f1-11b-cari-nota-riwayat-design.md).

**Tujuan:** kolom cari di Riwayat untuk nomor nota, pelanggan, dan
referensi pembayaran, di semua tanggal.

## Langkah

- [ ] **Tes data** `listSalesHistory` dengan `query`; lalu implementasi
  (`HistoryFilter.query`, kandidat `ilike`, cek ulang, batas 100).
- [ ] **Tes VM + widget**; lalu `setQuery`, kolom cari, ringkasan, catatan
  batas, pill tanggal mengosongkan cari, nama file ekspor; l10n id/en.
- [ ] **Review** subagent baru; perbaiki Critical/Important.
- [ ] **Uji manual Xvfb**: cari nomor, pelanggan, referensi.
- [ ] **Dokumen**: spec F1-11, README, STATUS-JEDA, panduan riwayat id/en,
  CHANGELOG 0.66.0, pubspec `0.66.0+69`.
- [ ] **PR, merge, cek rilis.**
