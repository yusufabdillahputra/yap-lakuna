# F1-16e — Target margin di tab Ringkasan

Tanggal: 2026-11-27 · Modul: F1-16 Laporan (layar 1.23) · Gap 9 di
`docs/superpowers/GAP-FASE1.md`, gap 88 di STATUS-JEDA · Rilis: v0.145.0

## Masalah

Target margin kotor cabang (F1-16d, v0.133.0) hanya tampil di kartu
*Margin kotor* pada tab *Laba rugi* dan di ekspor Ringkasan. Kartu KPI
*Laba kotor* di tab *Ringkasan*, layar pertama yang dilihat pemilik, hanya
menulis *Dari harga pokok saat jual*. Untuk tahu apakah targetnya
tercapai, pemilik harus pindah tab.

## Aturan

Keterangan kartu KPI *Laba kotor* di tab Ringkasan:

1. **Tanpa target:** tetap *Dari harga pokok saat jual*.
2. **Dengan target dan margin terhitung:** *Margin 24,0% · Target toko
   25% · kurang 1,0 poin*, atau *Margin 25,3% · Target toko 25% ·
   tercapai*.
   - Teks target dan aturan pembulatannya sama dengan kartu *Margin
     kotor* (F1-16d aturan 3).
3. **Dengan target, tetapi belum ada penjualan:** *Target toko 25%*.
4. Ekspor Ringkasan tidak berubah: baris *Laba kotor* tetap `–` bila
   belum ada penjualan (aturan F1-16d 4). Di layar, target tetap ditulis
   agar pemilik ingat targetnya.
5. **Tanpa izin laba** (`reports:view_profit`): kartu tidak tampil, sama
   seperti sebelumnya, sehingga target juga tidak tampil.

## Rancangan teknis

- `grossProfitKpiNote(l10n, marginBp, targetBp)` di `report_labels.dart`
  memakai ulang `marginNote` dan `percentLabel`.
- Kunci l10n baru `reportsKpiGrossProfitTarget`, `Margin {margin} ·
  {target}`, ada di ID dan EN.

## Pengujian

- Unit `grossProfitKpiNote` (ID dan EN): pembulatan 24,96% (tercapai) dan
  24,94% (kurang 0,1 poin), margin negatif.
- Widget, di 1440 px dan 360 px:
  - tanpa target;
  - target belum tercapai;
  - target tercapai;
  - periode tanpa penjualan.
- Uji manual di Xvfb.

## Status & gap

| Topik | Kode | Catatan |
| --- | --- | --- |
| Target di KPI *Laba kotor* tab Ringkasan | Rilis v0.145.0 | Warna kartu tidak berubah; hanya keterangan. |
