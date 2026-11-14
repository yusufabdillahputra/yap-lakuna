# Rencana F1-15b — Kecilkan foto nota pengeluaran dan bukti bayar

Spec: [F1-15b](../specs/2026-11-14-f1-15b-kecilkan-foto-nota-design.md).

**Tujuan:** foto nota pengeluaran dan bukti bayar supplier sampai 20 MB
dikecilkan otomatis ke 2.000 px sebelum disimpan.

## Langkah

- [x] **Domain** — batas pilih dan sisi maksimum di `ExpenseLimits` /
  `SupplierLimits`.
- [x] **Data** — tes nota/bukti besar tersimpan ≤ 2.000 px, > 20 MB dan
  > 50 MP ditolak, kecil tetap; lalu `recordExpense` dan `paySupplierDebt`.
- [x] **Flutter** — VM pengeluaran, kas keluar, bayar hutang memakai batas
  pilih; teks galat id/en; tes VM.
- [x] **Review** subagent baru; perbaiki Critical/Important (pratinjau foto
  20 MB didekode kecil, tes bukti rusak + outbox).
- [x] **Uji manual Xvfb**: pengeluaran dengan foto besar, cek `media/`.
- [x] **Dokumen**: spec F1-07l/F1-15/F1-14 (gap), README, STATUS-JEDA,
  panduan pengeluaran & supplier id/en, CHANGELOG 0.63.0, pubspec
  `0.63.0+66`.
- [ ] **PR, merge, cek rilis.**
