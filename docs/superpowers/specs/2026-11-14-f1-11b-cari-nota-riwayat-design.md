# F1-11b — Cari nota di Riwayat

- **Status:** Rilis v0.66.0
- **Layar:** 1.14 *Riwayat transaksi*.
- **Acuan:** tujuan [F1-11](2026-11-03-f1-11-riwayat-void-retur-design.md)
  ("Kasir dan manajer bisa mencari nota"); referensi kartu/transfer
  [F1-05b](2026-11-14-f1-05b-referensi-split-struk-design.md).

## Tujuan

Riwayat hanya bisa difilter *Hari ini*, *Kemarin*, atau *7 hari*, jadi
nota yang lebih lama tidak bisa dibuka untuk cetak ulang atau retur, dan
kasir harus menggulir untuk menemukan satu nota. Modul ini menambah kolom
cari untuk nomor nota, pelanggan, atau referensi pembayaran.

## Aturan

1. **Kolom cari** di atas filter tanggal: petunjuk *Cari no. nota,
   pelanggan, atau referensi*, ikon kaca pembesar. Daftar dimuat ulang
   setiap ketikan (seperti layar Pembelian); hasil lama dibuang bila kata
   kunci berganti selama memuat.
2. **Kata kunci** dipangkas spasinya; kosong = riwayat biasa. Cocok bila
   salah satu ini **memuat** kata kunci (tanpa beda huruf besar/kecil):
   nomor nota, nama pelanggan di nota (termasuk nama pemesan bill F&B yang
   tidak punya data pelanggan), nama atau nomor HP data pelanggan, atau
   referensi pembayaran lunas nota (no. approval kartu / ref. transfer,
   F1-05b). Huruf besar/kecil hanya disamakan untuk huruf A–Z (batas
   `LIKE` SQLite).
3. **Semua tanggal:** selama mencari, filter tanggal diabaikan (tidak ada
   pill tanggal yang terpilih) sehingga nota lama bisa ditemukan. Filter
   Kasir, Metode, dan Status tetap berlaku. Mengetuk pill tanggal
   mengosongkan kolom cari dan memakai rentang itu.
4. **Batas hasil:** paling banyak 100 nota terbaru. Bila lebih, tampil
   catatan *Menampilkan 100 nota terbaru. Perjelas kata kunci untuk
   mempersempit hasil.*
5. **Ringkasan** berubah menjadi *Hasil pencarian · N transaksi · Rp X*,
   dan kolom Jam selalu menampilkan tanggal. Bila tidak ada yang cocok
   tampil *Tidak ada nota yang cocok dengan pencarian.*
6. Ekspor Excel memakai hasil pencarian; nama file
   `riwayat-cari-<tanggal>.xlsx`.
7. Data tetap dibatasi tenant dan cabang; bill F&B yang dibatalkan sebelum
   ditutup (nomor `OB-`) tetap tidak muncul.

## Rancangan teknis

- `HistoryFilter.query` (default `''`) + `searching`; `copyWith(query:)`.
- `listSalesHistory`: bila `searching`, `_searchSales` mencari
  `customers.name/phone` dan `payments.reference` (lunas) yang cocok
  (`ilike`, SQLite: `LIKE`), lalu membaca nota cabang yang
  `number`/`customer_name` cocok **atau** `customer_id`/`id` ada di hasil
  itu, dengan filter status dan kasir di SQL, tanpa batas tanggal, urut
  `sold_at` turun, **per kelompok 200 baris** sampai hasil melewati
  `historySearchLimit` (100). Semua kandidat dicek ulang di Dart dengan
  `contains` (karakter `%`/`_` tidak jadi wildcard); filter Metode dan
  bill `OB-` disaring per kelompok. Kata kunci yang cocok dengan semua nota
  (mis. kode outlet) jadi hanya membaca satu kelompok.
- `HistoryPage.truncated` dan `HistoryPage.searching`.
- `HistoryViewModel.setQuery`; `setFilter` dengan range baru mengosongkan
  query (aturan 3).

## Tes

- Data: cocok nomor (sebagian, huruf kecil), nama/HP pelanggan, nama
  pemesan bill F&B tanpa data pelanggan, referensi transfer; nota di luar
  7 hari ditemukan; filter status/metode/kasir tetap berlaku; bill `OB-`
  batal tidak ikut; `%`/`_` tidak jadi wildcard; batas + `truncated`;
  baca per kelompok kecil memberi hasil sama; kata kunci kosong = perilaku
  lama.
- VM/widget: ketik → daftar hasil + ringkasan pencarian; pill tanggal
  mengosongkan kolom cari; catatan batas; kosong → pesan tidak cocok.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Cari nomor nota, pelanggan, referensi | — | Rilis v0.66.0 | — |
| Rentang tanggal bebas (kalender) | — | Rilis v0.68.0 | [F1-11c](2026-11-14-f1-11c-rentang-tanggal-riwayat-design.md) |
| Cari nama item | — | Belum | Perlu join `sale_items`; tunggu kebutuhan. |
| Huruf non-ASCII (é, ü) tanpa beda besar/kecil | — | Belum | Batas `LIKE` SQLite; kolom nama ternormalisasi bila dibutuhkan. |
| Cari HP dengan format lain (+62, tanda hubung) | — | Belum | Normalisasi digit kata kunci untuk HP. |
| Kata kunci berisi `\` di Postgres (Fase 2) | — | Belum | Escape `\` saat pencarian dipindah ke server. |
