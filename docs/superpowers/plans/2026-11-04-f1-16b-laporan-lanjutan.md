# Rencana F1-16b · Laporan lanjutan (v0.21.0)

Spec: `docs/superpowers/specs/2026-11-04-f1-16-laporan-design.md`, bagian
*Bagian kedua (v0.21.0)*.

**Tujuan:** tab Stok, Kas & sesi, Piutang & hutang, dan Retur di layar
Laporan, dengan unduh PDF/Excel, tanpa perubahan skema.

**Arsitektur:** rumus murni di `lakuna_domain/report.dart`
(`stockMovementRows`, `cashSourceRows`, `returnReasonRows`); pemuat per tab di
`lakuna_data/reports_extra.dart` (`loadStockReport`, `loadCashReport`,
`loadDebtReport`, `loadReturnsReport`, semua lewat cek izin yang sama dengan
`buildReport`); repositori menambah empat metode; view model memuat data tab
saat tab dibuka dan menyimpannya per (tab, periode).

## Langkah

- [x] Domain (TDD): ringkasan pergerakan stok per varian (awal, masuk,
  keluar, akhir) dari daftar pergerakan + batas periode; kelompok gerakan
  kas per sumber; ringkasan retur per alasan.
- [x] Data (TDD): `loadStockReport` (semua lokasi cabang, hanya barang, nilai
  hanya dengan izin laba), `loadCashReport` (sesi dibuka pada periode, sesi
  terbuka memakai `cashDrawerFor`, gerakan kas per sumber),
  `loadDebtReport` (pelanggan + supplier hari ini), `loadReturnsReport`
  (retur pada periode + nomor nota + petugas). Tes skenario dan izin.
- [x] Repositori: `ReportsRepository.loadStock/loadCash/loadDebts/
  loadReturns`, versi lokal + palsu.
- [x] View model (TDD): tab baru, muat saat tab dibuka, data usang
  disembunyikan, nama berkas per tab.
- [x] Label + tabel ekspor per tab (TDD).
- [x] UI: empat tab (KPI + tabel, kartu di 360 px), kunci widget, ARB id/en.
- [x] Tes widget 1440 / 800 / 360, kasir tanpa izin laba (kolom nilai
  hilang).
- [x] Format, analyze, semua tes.
- [x] Uji manual Xvfb 1280x800 + tangkapan layar.
- [x] CHANGELOG 0.21.0, versi `0.21.0+22`, status spec + README spec.
- [ ] Review kode (subagent), perbaiki Critical/Important.
- [ ] PR, CI hijau, squash merge, cek rilis.
