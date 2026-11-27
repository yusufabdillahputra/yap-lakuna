# F1-11k — Sorot kata kunci di barang cocok Riwayat

Tanggal: 2026-11-27 · Modul: F1-11 Riwayat (1.14, daftar hasil cari) ·
Gap 14 di `docs/superpowers/GAP-FASE1.md`, gap 93 di STATUS-JEDA ·
Rilis: v0.150.0

## Masalah

F1-11i menulis **Barang cocok: Es Kopi Susu Reguler, Kopi Bubuk** di bawah
nomor nota. Nama ditulis utuh tanpa penanda, jadi saat kata kuncinya
pendek (`kopi`, `5kg`) kasir harus membaca ulang setiap nama untuk melihat
bagian mana yang cocok.

## Aturan

1. Di baris **Barang cocok** (tabel desktop dan kartu ponsel), setiap
   bagian nama barang yang cocok dengan salah satu kata kunci disorot:
   huruf lebih tebal dengan latar warna primer tipis.
2. Pencocokan sorotan sama dengan pencarian barang:
   - setiap kata kunci (dipisah spasi) dicari di nama, tanpa beda huruf;
   - spasi di nama diabaikan (F1-11j), jadi `5kg` menyorot `5 kg`
     termasuk spasinya;
   - semua kemunculan disorot, dan sorotan yang bertumpuk atau bersebelahan
     digabung;
   - nama yang ditulis adalah produk + varian, jadi kata tanpa spasi bisa
     tersorot melintasi batas keduanya (produk *Ana* varian *Nas*, kata
     `ana`: *Ana Na* tersorot). Ini hanya menambah sorotan pada barang yang
     memang cocok.
3. Barang yang cocok lewat catatan, modifier, atau grup modifier
   (F1-11f/g/j) tetap ditulis, tetapi namanya mungkin tidak memuat kata
   kunci sehingga tidak ada yang disorot. Ini wajar karena yang cocok ada
   di rincian nota.
4. Awalan *Barang cocok:* dan *+n lainnya* tidak disorot. Batas dua nama,
   elipsis di tabel, dan warna teks F1-11i tetap.
5. Sorotan memakai kata kunci yang menghasilkan daftar, bukan teks yang
   sedang diketik, jadi tidak berkedip selama daftar baru dimuat.

## Rancangan teknis

- `lakuna_domain` `search.dart` (baru): `searchHighlights(String text,
  String query)` mengembalikan rentang `(start, end)` di [text], urut dan
  tidak bertumpuk.
  - Teks dipetakan per karakter (rune) ke bentuk huruf kecil tanpa spasi
    U+0020, dengan awal dan akhir karakter asal untuk tiap unit hasil. Huruf
    kecil per karakter menjaga peta indeks walau panjang huruf kecilnya
    berbeda. Huruf kecil yang bergantung konteks (sigma akhir Yunani di
    web) bisa tidak tersorot; hasil cari tidak berubah.
  - Latar sorotan 10% warna primer di tema terang (tetap ≥ 4.5:1 di baris
    terpilih) dan 16% di tema gelap.
  - Kata kunci dipecah `\s+` dan dijadikan huruf kecil, sama dengan
    `_searchSales`.
- `lakuna_data` `HistoryPage.query` (bawaan `''`): kata kunci yang dipakai
  memuat halaman, diisi `listSalesHistory` saat mencari.
- `history_view.dart` `_MatchedItems`: `Text.rich` dengan awalan dari l10n
  (dipisah lewat placeholder penanda) dan `TextSpan` per nama dengan
  bagian tersorot. Kunci widget tetap `history-match-<nota>`.
- Tanpa kunci l10n baru dan tanpa perubahan skema.

## Pengujian

- Domain: satu kata, beberapa kata, tanpa beda huruf, `5kg` pada `5 kg`
  (rentang memuat spasi), kemunculan berulang, sorotan bertumpuk
  digabung, kata yang tidak ada, kata kunci kosong, huruf non-ASCII
  (`É`), dan `%` literal.
- Data: `HistoryPage.query` berisi kata kunci saat mencari dan kosong di
  luar pencarian.
- Widget: rentang tersorot di baris *Barang cocok* (tabel 1280 px dan
  kartu 360 px), tanpa luapan.
- Uji manual Xvfb: cari `kopi` dan `5kg` di Riwayat.

## Status & gap

| Topik | Kode | Catatan |
| --- | --- | --- |
| Sorot kata kunci di barang cocok | Rilis v0.150.0 | Tabel dan kartu. |
| Tunjukkan modifier/catatan yang cocok di baris hasil | Belum | Nama barang ditulis; modifier atau catatan yang cocok terlihat di rincian nota. |
