# F1-11d — Cari nota lewat nama barang di Riwayat

- **Fase:** 1
- **Status:** Dalam pengerjaan (v0.81.0)
- **Layar:** 1.14 *Riwayat transaksi*, kolom cari.
- **Acuan:** gap [F1-11b](2026-11-14-f1-11b-cari-nota-riwayat-design.md)
  *Cari nama item*. Storeku belum punya pencarian riwayat.

## Tujuan

Pelanggan sering datang untuk retur dengan membawa barang, bukan nota:
"kemarin saya beli Minyak Goreng 2 L di sini". Kasir hanya bisa mencari
nomor nota, pelanggan, atau referensi, jadi harus menggulir hari demi
hari. Mencari nama barang langsung menampilkan nota yang memuatnya.

## Aturan

1. Kata kunci (F1-11b, dipangkas, tanpa beda huruf A–Z) juga cocok bila
   **nama produk** atau **nama varian** salah satu barang nota memuat kata
   kunci. Barang yang dihapus dari bill sebelum dibayar (soft delete)
   tidak ikut. Nama yang dicocokkan adalah salinan nama saat transaksi
   (`sale_items.product_name` / `variant_name`), jadi produk yang kemudian
   diganti namanya tetap ditemukan dengan nama lamanya.
2. Aturan F1-11b lain tetap: semua tanggal, filter kasir/metode/status
   berlaku, bill F&B yang dibatalkan sebelum ditutup tidak ikut, terbaru
   dulu, maks 200 nota dengan tanda terpotong.
3. Petunjuk kolom cari menjadi *Cari no. nota, pelanggan, barang, atau
   referensi* / *Search receipt no., customer, item, or reference*.
4. Kunci barang dibaca dari maks 5.000 baris barang yang cocok terbaru;
   kata kunci yang sangat umum (mis. satu huruf) bisa tidak menemukan nota
   yang sangat lama. Batas ini mencegah daftar ID nota raksasa di kueri.

## Rancangan teknis

- `_searchSales` (`lakuna_data/lib/src/history.dart`): kueri
  `SaleItem` (tenant, `product_name ILIKE` atau `variant_name ILIKE`,
  `deleted_at` kosong, urut `created_at` turun, batas 5.000), cek ulang di
  Dart, kumpulkan `sale_id` ke set `withItem`, lalu digabung ke klausa
  teks `s.id.inSet(...)` dan `matches()` seperti referensi pembayaran.
- l10n `historySearchHint` diubah (ID + EN).

## Tes

- Data: nota ditemukan lewat nama produk (huruf kecil, potongan kata) dan
  nama varian, semua tanggal; barang yang dihapus dari bill sebelum bayar
  tidak membuat bill cocok; filter status tetap berlaku; `%` bukan
  wildcard.
- Widget Riwayat: petunjuk kolom cari baru.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Cari nota lewat nama produk / varian | 1.14 | Dalam pengerjaan | — |
| Kata kunci melintasi nama produk + varian (mis. `Beras 5 kg`) | — | Belum | Dicocokkan per kolom; ketik nama produk saja atau nama varian saja. |
| Sorot barang yang cocok di daftar | — | Belum | Daftar menampilkan nota; buka rinciannya untuk melihat barang. |
