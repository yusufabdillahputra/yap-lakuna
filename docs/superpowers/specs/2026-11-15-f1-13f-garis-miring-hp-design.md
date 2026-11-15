# F1-13f — Garis miring di pencarian nomor HP

- **Fase:** 1
- **Status:** Rilis v0.113.0
- **Layar:** sama dengan [F1-13d](2026-11-14-f1-13d-cari-hp-format-design.md):
  1.14 *Riwayat*, 1.20 *Pelanggan*, 1.21 *Supplier*, 1.4b pilih pelanggan
  di Kasir, 1.5b *Kredit*, pilih pelanggan di bill Meja.
- **Acuan:** gap F1-13d *Garis miring dan pemisah lain (`0812/3456`)*.

## Tujuan

Sebagian pelanggan menulis nomornya dengan garis miring, terutama nomor
telepon rumah/kantor (`021/5551234`) dan catatan lama di buku nota
(`0812/3456/7890`). Saat disimpan, nomor itu sudah dinormalisasi menjadi
digit (F1-13), tetapi saat dicari dengan garis miring kolom cari
menganggapnya teks biasa sehingga pelanggan tidak ditemukan.

## Aturan

1. `/` diterima sebagai pemisah dalam kata kunci HP, sejajar dengan spasi
   dan `+ - ( ) .`. Garis miring Unicode yang bisa tersalin dari aplikasi
   lain (U+2215 *division slash*, U+FF0F *fullwidth solidus*) dianggap `/`.
2. Aturan F1-13d lain tidak berubah: minimal 3 digit, kunci = digit apa
   adanya, `+62…` / `62…` (≥ 10 digit) menjadi `0…`, kata kunci berhuruf
   tidak dicocokkan ke HP.
3. Pemisah lain (`_`, `,`, `#`, `\`) tetap tidak diterima: jarang dipakai
   di nomor HP dan lebih mungkin bagian teks lain.
4. *Pelanggan baru* dari kata pencarian (Kasir, Kredit, Meja;
   `customerDraftFromQuery`, F1-04f) memakai pola yang sama: kata kunci
   yang menghasilkan kunci HP dan memuat minimal 6 digit mengisi kolom HP,
   bukan Nama. Sebelumnya `021/5551234` atau salinan WhatsApp dengan tanda
   arah tak terlihat malah tersimpan sebagai nama.

## Catatan

- Tanggal yang diketik di kolom cari (`15/11`) kini juga menjadi kunci HP
  `1511`, begitu pula pecahan seperti `1/2/3` (kunci `123`). Riwayat tidak
  punya pencarian teks tanggal (ada filter rentang tanggal, F1-11c); teks
  mentah tetap dicocokkan dengan nama, referensi bayar, dan nama barang
  seperti sebelumnya. Kunci HP hanya **menambah** hasil (nota pelanggan
  yang HP-nya memuat `1511`), tidak pernah menyembunyikan hasil lain.

## Rancangan teknis

- `lakuna_domain` `customer.dart`: `_phoneQueryPattern` menerima `/`;
  `phoneSearchKeys` mengganti U+2215 dan U+FF0F menjadi `/` sebelum dicek.
  Semua layar sudah memakai `phoneSearchKeys` / `phoneMatchesQuery`.
- `customerDraftFromQuery` (`customer_form_dialog.dart`) memakai
  `phoneSearchKeys(q).isNotEmpty` + minimal 6 digit, menggantikan pola
  sendiri yang tidak mengenal `/` dan karakter Unicode.
- Simpan, validasi, dan import HP sudah lewat `normalizePhone` (semua
  selain digit dibuang), jadi tidak berubah.

## Tes

- Domain: `0813/2222/1010`, `0813 / 2222`, `021/5551234` (kunci
  `0215551234`), `+62/813/2222` (kunci `0813…`), U+2215 dan U+FF0F cocok;
  `0813/abc` dan `08/` tetap tidak menghasilkan kunci.
- Draf pelanggan baru: `021/5551234`, `0813` U+FF0F `2222` U+2011 `1010`,
  dan salinan WhatsApp `+62 813-2222-1010` berbingkai U+202A/U+202C
  menjadi HP; `0813_2222` dan `12/3` tetap nama.
- Domain: `+62/813` tidak cocok palsu dengan `…62813…`.
- Data: Riwayat menemukan nota pelanggan lewat `0812/3456/7890`.
- View model: Pelanggan menemukan pelanggan lewat `0857/1111`.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Garis miring di pencarian HP | — | Rilis v0.113.0 | — |
| Garis miring Unicode lain (U+2044 *fraction slash*, U+29F8) | — | Belum | Jarang tersalin dari aplikasi pesan; kata kunci tidak dicocokkan ke HP. |
