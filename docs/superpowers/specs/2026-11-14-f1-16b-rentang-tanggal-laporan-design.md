# F1-16b — Rentang tanggal bebas di Laporan

- **Status:** Rilis v0.67.0
- **Layar:** 1.23 / 1.24 *Laporan* (pilihan **Periode**).
- **Acuan:** [F1-16](2026-11-04-f1-16-laporan-design.md) (periode Hari ini,
  7 hari terakhir, Bulan ini, 12 bulan sebelumnya).

## Tujuan

Pemilik sering butuh laporan untuk rentang yang bukan satu bulan penuh,
mis. *1–15 November* (setengah bulan gaji), satu minggu promo, atau satu
tanggal di masa lalu. Sekarang hanya ada hari ini, 7 hari terakhir, dan
bulan kalender. Modul ini menambah rentang tanggal bebas.

## Aturan

1. Pilihan **Periode** mendapat entri *Rentang tanggal…* tepat setelah
   *Bulan ini* (atau setelah rentang aktif), sebelum daftar bulan, agar
   terlihat tanpa menggulir. Memilihnya
   membuka dialog *Pilih rentang tanggal* dengan isian tanggal **Dari** dan
   **Sampai** (awal = rentang periode yang sedang tampil, dipangkas ke hari
   ini), tombol *Batal* dan *Terapkan*.
2. **Validasi** (Terapkan nonaktif selama ada galat):
   - *Sampai* tidak boleh sebelum *Dari* — *Tanggal akhir tidak boleh
     sebelum tanggal awal.*
   - *Sampai* tidak boleh melewati hari ini (tanggal lokal cabang) —
     *Tanggal tidak boleh melewati hari ini.*
   - Paling panjang 366 hari — *Rentang paling panjang 366 hari.*
3. **Label** periode (pilihan, subjudul, PDF/Excel): satu hari
   *5 Nov 2026*; bulan sama *1–15 Nov 2026*; tahun sama
   *28 Okt – 3 Nov 2026*; beda tahun *28 Des 2025 – 3 Jan 2026*
   (en: *Nov 5, 2026*, *Nov 1–15, 2026*, *Oct 28 – Nov 3, 2026*,
   *Dec 28, 2025 – Jan 3, 2026*). Rentang aktif tampil sebagai entri
   tersendiri di pilihan Periode (setelah *Bulan ini*) sehingga terlihat
   terpilih; label panjang dipotong di kotak pilihan, lengkap di subjudul.
4. **Pembanding** (Laba bersih vs periode sebelumnya, perubahan KPI):
   jumlah hari yang sama tepat sebelum *Dari*, label *N hari sebelumnya*
   (*hari sebelumnya* untuk satu hari).
5. **Nama berkas** ekspor memakai `yyyymmdd-yyyymmdd`, mis.
   `laporan-laba-rugi-20261101-20261115-261115.pdf`.
6. Berlaku untuk semua tab yang memakai periode (Ringkasan, Penjualan,
   Produk terlaris, Laba rugi, Stok, Kas & sesi, Retur); Piutang & hutang
   tetap tanpa periode. Batal tidak mengubah periode.
7. Rentang tidak disimpan; membuka Laporan lagi kembali ke *Hari ini*.

## Rancangan teknis

- Domain: `ReportPeriodKind.custom`, `ReportPeriod.custom(from, to)`
  (tanggal UTC tengah malam), `range` = rentangnya, `previousRange` =
  `days` hari sebelum `from`, `fileKey` = `yyyymmdd-yyyymmdd`, `days`,
  kesetaraan memakai tanggal. `reportRangeError(from, to, today)` →
  `ReportRangeError { endBeforeStart, future, tooLong }` atau `null`;
  `maxReportRangeDays = 366`.
- Data: tidak berubah (semua query sudah memakai `period.range` /
  `previousRange`).
- Flutter: `reportPeriodLabel` / `previousPeriodLabel` untuk custom;
  `ReportsViewModel.periods` menyertakan periode custom aktif;
  `ReportRangeDialog` (dua `FDateField.calendar`); pilihan Periode dibangun
  ulang (kunci) setelah dialog ditutup agar Batal kembali ke periode aktif.

## Tes

- Domain: rentang, pembanding (1 hari, 15 hari, lintas bulan/tahun),
  `fileKey`, kesetaraan, validasi (urutan, masa depan, 366/367 hari).
- Flutter: label id/en (4 bentuk), pembanding; VM memuat ulang dengan
  periode custom dan nama berkas; widget: pilih *Rentang tanggal…*, isi,
  galat, Terapkan → subjudul dan muat ulang; Batal → periode tetap; 360 px.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Rentang tanggal bebas | — | Rilis v0.67.0 | — |
| Simpan rentang terakhir | — | Belum | Simpan di preferensi lokal bila diminta. |
| Rentang bebas di Riwayat | — | Rilis v0.68.0 | [F1-11c](2026-11-14-f1-11c-rentang-tanggal-riwayat-design.md) (dialog dipakai bersama). |
| Kalender menolak tanggal masa depan sejak awal | — | Belum | `FDateField.calendar` Forui 0.27 belum punya batas tanggal; masa depan ditolak lewat validasi. |
| *Hari ini* setelah lewat tengah malam | — | Diambil dari muatan laporan terakhir | Muat ulang laporan (sama dengan periode lain). |
