# F1-11d — Cari nota lewat nama barang di Riwayat

- **Fase:** 1
- **Status:** Rilis v0.81.0
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
   dulu, maks 100 nota dengan tanda terpotong.
3. Petunjuk kolom cari menjadi *Cari no. nota, pelanggan, barang, atau
   referensi* / *Search receipt no., customer, item, or reference*.
4. Tidak ada batas jumlah baris barang: nota lama dengan nama barang yang
   sangat laris (mis. `kopi` di kedai kopi) tetap ditemukan bila lolos
   filter, dan barang cabang lain tidak memakan jatah hasil.

## Rancangan teknis

- `_searchSales` (`lakuna_data/lib/src/history.dart`): klausa teks kueri
  nota mendapat `"sales"."id" IN (SELECT "sale_id" FROM "sale_items" WHERE
  tenant AND deleted_at IS NULL AND (LOWER(product_name) LIKE LOWER(pola)
  OR LOWER(variant_name) LIKE LOWER(pola)))` sebagai `Expression` mentah
  (nilai di-escape lewat `EscapedExpression`). Cabang, status, kasir, dan
  tanggal tetap dari kueri nota luar.
- Per kelompok 200 nota, nota yang tidak cocok lewat nomor/pelanggan/
  referensi dibaca barangnya (`sale_id IN` kelompok itu) dan dicek ulang di
  Dart agar `%` dan `_` tetap literal.
- l10n `historySearchHint` diubah (ID + EN).

## Tes

- Data: nota ditemukan lewat nama produk (huruf kecil, potongan kata) dan
  nama varian, semua tanggal; barang yang dihapus dari bill sebelum bayar
  tidak membuat bill cocok; filter status, metode, dan kasir tetap
  berlaku; `%` dan `_` bukan wildcard.
- Widget Riwayat: petunjuk kolom cari baru.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Cari nota lewat nama produk / varian | 1.14 | Rilis v0.81.0 | Semua tanggal; barang yang dihapus dari bill tidak dihitung. |
| Kata kunci melintasi nama produk + varian (mis. `Beras 5 kg`) | 1.14 | Rilis v0.101.0 | [F1-11e](2026-11-15-f1-11e-cari-beberapa-kata-barang-design.md): setiap kata harus ada di nama produk atau varian satu baris barang, urutan bebas. |
| Cari nama modifier (mis. `extra keju`) | 1.14 | Rilis v0.103.0 | [F1-11f](2026-11-15-f1-11f-cari-nama-modifier-design.md): nama opsi modifier baris yang sama. |
| Sorot barang yang cocok di daftar | — | Belum | Daftar menampilkan nota; buka rinciannya untuk melihat barang. |
