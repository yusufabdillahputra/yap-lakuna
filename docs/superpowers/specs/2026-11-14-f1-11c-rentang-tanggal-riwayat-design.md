# F1-11c — Rentang tanggal bebas di Riwayat

- **Status:** Rilis v0.68.0
- **Layar:** 1.14 *Riwayat transaksi* (pill tanggal).
- **Acuan:** gap [F1-11b](2026-11-14-f1-11b-cari-nota-riwayat-design.md)
  dan dialog rentang [F1-16b](2026-11-14-f1-16b-rentang-tanggal-laporan-design.md).

## Tujuan

Riwayat hanya punya *Hari ini*, *Kemarin*, dan *7 hari*. Untuk melihat
semua nota satu tanggal lama atau satu bulan (mis. untuk ekspor Excel),
kasir harus mencari per nomor. Modul ini menambah rentang tanggal bebas,
memakai dialog yang sama dengan Laporan.

## Aturan

1. Pill keempat *Rentang tanggal…* setelah *7 hari*. Mengetuknya membuka
   dialog *Pilih rentang tanggal* (Dari / Sampai) yang sama dengan Laporan:
   awal = rentang yang sedang tampil, validasi sama (akhir ≥ awal, tidak
   melewati hari ini, paling panjang 366 hari).
2. *Terapkan* memuat nota dengan tanggal lokal cabang di rentang itu
   (inklusif) dan mengosongkan kolom cari. Pill keempat terpilih dan
   labelnya menjadi rentangnya (*1–15 Nov 2026*). *Batal* tidak mengubah
   apa pun.
3. Ringkasan *1–15 Nov 2026 · N transaksi · Rp X*; kolom Jam selalu
   bertanggal; filter Kasir, Metode, Status tetap berlaku.
4. Ekspor Excel bernama `riwayat-<yyyymmdd>-<yyyymmdd>-<tanggal>.xlsx`.
5. Mengetuk pill lain kembali ke rentang itu. Selama mencari (F1-11b),
   tidak ada pill yang terpilih seperti sebelumnya.

## Rancangan teknis

- Data: `HistoryRange.custom` + `HistoryFilter.days` (`DateRange` tanggal
  kalender). `historyRangeBounds(range, now, tz, days:)` →
  awal hari lokal `days.from` sampai awal hari setelah `days.to`
  (dihitung dari awal hari ini cabang dikurangi selisih hari).
- Flutter: dialog dipindah ke `ui/core/date_range_dialog.dart`
  (`showDateRangeDialog`, kunci `<prefix>-dialog/-from/-to/-apply/-cancel`);
  Laporan memakainya dengan prefix `reports-range`, Riwayat dengan
  `history-range`. `HistoryViewModel.setCustomRange`, `today`.

## Tes

- Data: rentang satu tanggal lama, rentang dua hari mencakup batas hari
  WIB, filter status tetap berlaku.
- VM: rentang aktif, query dikosongkan, nama berkas ekspor.
- Widget: pill → dialog → terapkan → ringkasan dan permintaan; batal.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Rentang tanggal bebas di Riwayat | — | Rilis v0.68.0 | — |
| Cari di dalam rentang | — | Pencarian tetap di semua tanggal | Gabungkan bila diminta. |
