# F1-10s — Jejak gabung meja

Tanggal: 2026-11-27 · Modul: F1-10 Meja F&B (1.7 gabung meja) dan F1-11
Riwayat (1.14 rincian nota) · Gap 18 (bagian kedua) di
`docs/superpowers/GAP-FASE1.md`, gap 98 di STATUS-JEDA · Rilis: v0.155.0

## Masalah

Gabung meja (F1-10d) memindahkan item bill sumber ke bill tujuan lalu
menghapus (soft delete) bill sumber. Tidak ada penanda bill tujuan, jadi
setelah nota dibayar tidak terlihat bahwa nota itu gabungan dua meja,
kapan, dan oleh siapa. Pemilik yang mengaudit "kenapa nota Meja M1 berisi
pesanan Meja M3" tidak punya jawaban.

## Aturan

1. Saat gabung, bill sumber menyimpan `merged_into_id` = bill tujuan, dalam
   transaksi yang sama dengan pemindahan item (tercatat di outbox sync).
2. Rincian nota di Riwayat menulis satu baris per bill yang digabung, di
   bawah nomor nota:
   - *Gabungan dari meja M3 (OB-PST-K01-261103-0002) · 03/11/26 09.10 ·
     Rina* (EN *Merged from table M3 (…) · … · Rina*);
   - meja sudah dihapus: *Gabungan dari bill OB-… · waktu · staf*;
   - waktu = saat gabung, zona waktu cabang; staf = yang menggabungkan
     (`updated_by` bill sumber; `—` bila tidak ditemukan).
3. Berantai: bila M3 digabung ke M2 lalu M2 ke M1, nota M1 menulis M3 dan
   M2, urut waktu gabung. Kedalaman dibatasi 20 sebagai pengaman data
   rusak.
4. Nota tanpa gabung tidak menampilkan apa pun. Gabung sebelum v0.155.0
   tidak punya jejak.
5. Hanya bill di cabang yang sama yang dicari.

## Rancangan teknis

- Model `Sale.mergedIntoId` (`merged_into_id`, `UuidValue?`) dengan indeks
  `sales_merged_into_idx`, migrasi `jejak-gabung` (server Postgres dan klien
  SQLite).
- `mergeOpenBills` mengisi `mergedIntoId` pada bill sumber.
- `lakuna_data` `history.dart`: `MergedBill` (nomor bill, meja, waktu,
  staf) dan `SaleDetail.mergedBills` dari `_mergedBills` (pencarian
  melebar per tingkat). Nama meja hanya dari meja yang belum dihapus
  (`deletedAt` kosong); waktu gabung yang sama diurutkan menurut nomor bill.
- Temuan review (Important, diperbaiki): meja yang dihapus (soft delete)
  dulu tetap tampil namanya; kini sumbernya ditulis *Gabungan dari bill …*
  dan tes data menghapus meja M3. Minor yang diperbaiki: indeks
  `merged_into_id`, doc comment `loadSaleDetail`, urutan stabil.
- `history_detail.dart`: `mergedBillLabel`, blok `history-merged`.
- l10n `historyMergedFromTable`, `historyMergedFromBill`.

## Pengujian

- Data: sumber menunjuk tujuan; berantai (M3 → M2 oleh Rina, M2 → M1 oleh
  pemilik) → dua baris urut waktu dengan meja, nomor bill, dan staf; nota
  tanpa gabung kosong.
- Widget 1280 / 360 px: dua baris (dengan dan tanpa meja) di zona WIB;
  nota lain tanpa blok jejak.
- Uji manual Xvfb: gabung dua meja, bayar, buka rincian nota di Riwayat.

## Status & gap

| Topik | Kode | Catatan |
| --- | --- | --- |
| Jejak gabung di rincian nota | Rilis v0.155.0 | Berantai, urut waktu. |
| Jejak gabung di panel bill Meja (sebelum bayar) | Belum | Terlihat setelah dibayar di Riwayat. |
| Jejak di struk cetak | Belum | Struk tetap ringkas. |
