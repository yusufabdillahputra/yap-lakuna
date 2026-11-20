# F1-16d — Target margin toko

Tanggal: 2026-11-20 · Modul: F1-16 Laporan (layar 1.24) + F1-18 Pengaturan
(1.26) · Rilis: v0.133.0

## Masalah

Kanvas 1.24 menampilkan kartu *Margin kotor* dengan keterangan *Target toko
25%*. Lakuna belum punya pengaturan target, jadi kartu hanya menulis cara
hitung (*Laba kotor ÷ penjualan bersih*). Pemilik harus mengingat sendiri
target marginnya untuk tahu apakah periode ini sudah aman. Gap *Target
margin toko* di spec F1-16.

Spec Storeku F1-16 memakai aturan yang sama (*Margin kotor vs target
toko*); perbedaan Lakuna dicatat di bawah.

## Aturan

1. *Pengaturan → Toko & cabang → Penjualan & stok* mendapat isian
   **Target margin kotor (%)** per cabang: bilangan bulat 1–99, kosong =
   tanpa target (bawaan). Disimpan bersama aturan penjualan lain (tombol
   *Simpan* kartu yang sama), izin sama (`settings:manage`).
2. Isian selain angka ditolak oleh pemformat; 0 atau lebih dari 99
   menampilkan galat *Isi 1–99, atau kosongkan bila tanpa target* dan
   tombol *Simpan* nonaktif.
3. Laporan → *Laba rugi*, kartu *Margin kotor*:
   - tanpa target: keterangan tetap *Laba kotor ÷ penjualan bersih*;
   - dengan target dan margin terhitung: **Target toko 25% · tercapai**
     bila margin ≥ target, atau **Target toko 25% · kurang 3,2 poin**
     (selisih poin persen, satu desimal) bila di bawah. Margin dibandingkan
     setelah dibulatkan ke 0,1 poin seperti tampilannya, jadi *25,0%*
     (24,96%) tercapai dan tidak pernah tertulis *kurang 0,0 poin*;
   - dengan target tetapi margin kosong (belum ada penjualan): *Target
     toko 25%*.
4. Ringkasan Excel/PDF tab *Ringkasan* menambah keterangan target pada
   baris *Laba kotor* bila target diatur dan margin terhitung (kolom
   ketiga: `24,0% · target 25%`; tanpa penjualan tetap `–`). Laporan
   tanpa izin laba tidak memuat target.
5. Data rusak (bukan bilangan bulat, di luar 100–9900 bp, atau bukan
   kelipatan 100 = bukan persen bulat) dibaca sebagai tanpa target, agar
   simpan ulang aturan lain tidak gagal; menyimpan nilai seperti itu
   ditolak (`SalesRulesInvalid`).

Perbedaan dari Storeku: target per cabang (data per perangkat), bukan per
toko, karena aturan penjualan Lakuna sudah per cabang (`sales.rules`).

## Rancangan teknis

- `SalesRules.targetMarginBp` (`int?`, bp; JSON `targetMarginBp`),
  `copyWith(targetMarginBp: () => …)` agar bisa dikosongkan.
  `targetMarginIssue(String text)` di domain: `null` bila kosong atau
  1–99, selain itu `TargetMarginIssue.outOfRange`.
  `marginGapBp(marginBp, targetBp)` = `target - margin` bila positif,
  selain itu 0.
- `ReportData.targetMarginBp` diisi `loadReport` dari `loadSalesRules`
  hanya bila staf punya izin laba.
- `StoreSettingsViewModel.setTargetMargin(String)`, `targetMarginText`,
  `targetMarginIssue`; `canSaveRules` ikut galat target.
- Kunci l10n: `storeSettingsTargetMargin`, `storeSettingsTargetMarginHint`,
  `storeSettingsTargetMarginRange`, `reportsMarginTarget`,
  `reportsMarginTargetMet`, `reportsMarginTargetShort`,
  `reportsMarginTargetExport` (ID + EN).

## Pengujian

- Domain: JSON bolak-balik, data rusak, galat isian, selisih poin.
- Data: `loadReport` memuat target hanya dengan izin laba.
- VM pengaturan: isi, kosongkan, galat, simpan.
- Widget: isian di pengaturan (1440 px); kartu margin (1440 / 360 px) tercapai /
  kurang / tanpa target / tanpa penjualan; baris ekspor.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Kode | Catatan |
| --- | --- | --- | --- |
| Target margin kotor per cabang | 1.24 "Target toko 25%" | Rilis v0.133.0 | Pengaturan 1.26, kartu Laba rugi, ekspor Ringkasan. |
| Target di tab Ringkasan (layar) | – | Belum | Kartu KPI *Laba kotor* belum menyebut target; tambah bila diminta. |
