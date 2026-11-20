# F1-11i · Barang yang cocok tampil di daftar Riwayat

- **Fase:** 1
- **Status:** Rilis v0.132.0
- **Layar:** 1.14 *Riwayat transaksi*, daftar hasil pencarian (tabel
  desktop dan kartu ponsel).
- **Acuan:** gap "Sorot barang yang cocok di daftar" di
  [F1-11d](2026-11-14-f1-11d-cari-nama-barang-design.md). Storeku belum
  punya pencarian riwayat. Penyempurnaan layar.

## Masalah

Mencari nama barang (F1-11d/e/f/g) menampilkan nota yang memuatnya, tetapi
daftar hanya menampilkan nomor, jam, kasir, metode, dan total. Saat
pelanggan datang untuk retur ("kemarin beli minyak"), kasir harus membuka
nota satu per satu untuk melihat barang mana yang cocok dan berapa
banyak nota yang benar-benar memuat barang itu.

## Aturan

1. Saat mencari, setiap baris hasil yang cocok lewat barang menampilkan
   baris kecil **Barang cocok: {nama}, {nama}** di bawah nomor nota
   (tabel) atau di bawah keterangan jam/kasir (kartu ponsel).
2. Barang cocok = baris barang nota (yang tidak dihapus dari bill) yang
   memenuhi aturan pencarian barang yang sama: setiap kata ada di nama
   produk, nama varian, catatan barang, atau nama modifier baris itu
   (F1-11d/e/f/g).
3. Nama = nama produk + nama varian saat transaksi (salinan di nota),
   berurutan seperti di nota, nama kembar sekali. Paling banyak dua nama
   ditulis; sisanya **+{n} lainnya**. Di tabel desktop yang sempit, nama
   paling banyak dua baris lalu dipotong elipsis, tetapi *+{n} lainnya*
   tetap utuh di kanannya.
4. Nota yang cocok hanya lewat nomor, pelanggan, HP, atau referensi tidak
   mendapat baris ini, kecuali barangnya juga cocok. Di luar pencarian
   tidak ada baris ini.

## Rancangan teknis

- `HistoryRow.matchedItems` (`List<String>`, bawaan kosong).
- `_searchSales` mengembalikan juga `matched: Map<saleId, List<String>>`:
  setelah hasil dipangkas ke batas, barang nota hasil dicek dengan
  `itemMatches` yang sama. Kueri barang memakai saringan kata SQL yang sama
  dengan pencarian nota (`wordClauses`), jadi hanya baris kandidat yang
  dibaca, lalu modifier hanya untuk kandidat yang belum cocok lewat
  nama/catatan. Nama di-*trim* (produk dan varian).
- `history_view.dart`: widget `_MatchedItems` berkunci
  `history-match-<nota>` (nama) dan `history-match-more-<nota>`
  (*+n lainnya*), teks kecil warna primer (biru muda `#74D4FF` di tema
  gelap, sama dengan layar lain). Tabel: `Row` dengan nama `Flexible`
  dua baris berelipsis + *+n* utuh; kartu: `Wrap`.
- l10n `historyMatchedItems`, `historyMatchedItemsMore` (ID + EN).

## Pengujian

- Data: barang cocok per nota (hanya barang yang cocok, urutan nota,
  modifier, catatan), kosong untuk cocok lewat nomor dan di luar pencarian.
- Data juga: barang yang dihapus dari bill tidak ditulis, cocok lewat
  nomor dan barang tetap menulis barang, kata ke-9 tetap menyaring.
- Widget 1280 / 360 px: baris *Barang cocok* tampil dengan +n lainnya;
  di tabel *+n lainnya* tidak terpotong dan berada di dalam baris.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Barang cocok di daftar hasil | 1.14 | Rilis v0.132.0 | Maks dua nama + *n lainnya*. |
| Sorot kata kunci di dalam nama | — | Belum | Nama ditulis utuh tanpa penanda huruf. |
