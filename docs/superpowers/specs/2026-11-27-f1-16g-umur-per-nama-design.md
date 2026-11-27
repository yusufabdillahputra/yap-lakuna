# F1-16g — Umur piutang/hutang per pelanggan dan supplier

Tanggal: 2026-11-27 · Modul: F1-16 Laporan (1.24, tab **Piutang & hutang**)
· Gap 11 di `docs/superpowers/GAP-FASE1.md`, gap 90 di STATUS-JEDA ·
Rilis: v0.147.0

## Masalah

F1-16c menambah tabel **Umur piutang** dan **Umur hutang** per kelompok
(belum jatuh tempo, lewat 1–30, 31–60, 61–90, > 90 hari). Tabel per
pelanggan dan per supplier tetap hanya berisi *Nota terbuka*, *Lewat
tempo* (jumlah nota), dan *Sisa*. Pemilik tahu ada Rp 150.000 yang lewat
lebih dari 90 hari, tetapi tidak tahu milik siapa, sehingga harus membuka
nota pelanggan satu per satu.

## Aturan

1. Tabel **Piutang per pelanggan** dan **Hutang per supplier** mendapat
   kolom kelompok umur F1-16c: *Belum jatuh tempo*, *Lewat 1–30 hari*,
   *Lewat 31–60 hari*, *Lewat 61–90 hari*, *Lewat > 90 hari*. Isinya sisa
   nota pelanggan atau supplier itu di kelompok tersebut.
   - Kelompok tanpa sisa dibiarkan kosong agar angka yang ada mudah
     terlihat.
   - Kolom *Lewat tempo* (jumlah nota) dihapus. Lewat tempo kini terlihat
     dari kolom kelompok, dan jumlah pelanggannya tetap ada di kartu
     *Piutang jatuh tempo*.
   - Urutan kolom pelanggan: Pelanggan, Nota terbuka, lima kelompok, Sisa.
   - Urutan kolom supplier: Supplier, Nota terbuka, Jatuh tempo terdekat,
     lima kelompok, Sisa.
2. Jumlah kelima kelompok satu baris = *Sisa* baris itu, dan jumlah satu
   kolom kelompok = baris kelompok itu di tabel umur F1-16c. Keduanya
   dihitung dari pembacaan nota yang sama.
3. Tampilan:
   - Di layar lebar tabel berkolom penuh. Kedua tabel menjadi kartu bila
     lebar isinya di bawah 900 px, sehingga di jendela 1280 px keduanya
     masih berupa tabel (temuan review: batas 960 px untuk supplier
     membuat tabel supplier menjadi kartu di 1280 px, tepat di bawah tabel
     pelanggan yang berkolom).
   - Kartu menampilkan nama dan *Sisa*, lalu *Nota terbuka*, *Jatuh tempo
     terdekat* (supplier), dan hanya kelompok yang berisi, mis. *Lewat >
     90 hari: Rp 150.000*.
4. Unduhan PDF/Excel tab Piutang & hutang memakai kolom yang sama:
   Baris, Nota terbuka, Jatuh tempo terdekat, lima kelompok, Sisa.
   - Baris tabel umur F1-16c mengisi *Nota terbuka* dan *Sisa*. Kolom
     kelompoknya kosong karena kelompoknya sudah menjadi nama baris.
   - Baris *Total* per pelanggan/supplier mengisi kolom kelompok juga.
   - PDF tab ini dicetak **mendatar** (A4 landscape) karena 9 kolom
     tidak muat di A4 tegak.

## Rancangan teknis

- `lakuna_data` `DebtReport` mendapat `customerAging` /
  `supplierAging` (`Map<UuidValue, Aging>`) dan `agingOfCustomer(id)` /
  `agingOfSupplier(id)` (`Aging.empty` bila tidak ada). `loadDebtReport`
  mengisinya dari peta nota bersisa yang sama dengan `receivableAging` /
  `payableAging`.
- `ReportTable.landscape` (bawaan `false`). `buildReportPdf` memakai
  `PdfPageFormat.a4.landscape` bila `true`.
- UI `reports_extra_view.dart` `_Debts`: kolom kelompok di kedua tabel,
  `cardWidth` 900 untuk keduanya. Sel kelompok nol berisi `''` sehingga kartu
  menyembunyikannya.
- `report_labels.dart` `reportTable` tab debts: kolom baru, `landscape:
  true`. Tanpa kunci l10n baru, karena judul kolom memakai
  `agingBucketLabel`.

## Pengujian

- Data: per pelanggan dan per supplier, kelompok sesuai jatuh tempo nota,
  jumlah per baris = sisa, dan jumlah per kolom = umur total.
- Label ekspor: kolom, sel kelompok per nama, baris Total, landscape.
- Dokumen: PDF landscape bila `landscape`.
- Widget: tabel 1440 px menampilkan kolom kelompok; kartu 360/800 px
  hanya menampilkan kelompok berisi; kedua tabel berkolom di 1280 dan
  1440 px; tanpa overflow di 360, 800, 1024, 1280, dan 1440 px.
- Uji manual Xvfb: tab Piutang & hutang desktop dan ponsel.

## Status & gap

| Topik | Kode | Catatan |
| --- | --- | --- |
| Kolom kelompok umur per pelanggan dan supplier | Rilis v0.147.0 | Layar dan unduhan. |
| Ketuk nama untuk melihat nota per kelompok | Belum | Buka Pelanggan/Supplier dari menu. |
