# F1-07n — Buang metadata lokasi dari semua gambar yang disimpan

- **Fase:** 1
- **Status:** Rilis v0.72.0
- **Layar:** semua unggahan gambar: 1.16 foto produk, 1.19 foto faktur,
  1.22 foto nota pengeluaran, bukti bayar supplier, 1.26 stiker QRIS dan
  logo struk, 1.17c gambar denah.
- **Acuan:** gap [F1-07l](2026-11-14-f1-07l-kecilkan-foto-design.md)
  *Buang EXIF dari foto kecil yang tidak dikecilkan*.

## Tujuan

Foto dari kamera ponsel membawa metadata: lokasi GPS, waktu, model ponsel,
kadang nama pemilik. Foto yang dikecilkan (F1-07l) sudah bersih, tetapi
foto kecil (≤ 512 KB dalam batas sisi), stiker QRIS, logo struk, dan
gambar denah disimpan apa adanya. Di Fase 2 berkas `media/` ikut
tersinkron ke server dan masuk berkas backup, jadi lokasi rumah pemilik
bisa ikut tersebar. Modul ini membuang metadata itu dari setiap gambar
sebelum disimpan, tanpa mengubah piksel.

## Aturan

1. Setiap gambar PNG, JPEG, atau WebP yang disimpan ke `media/` lewat
   `storeMediaFile` dibersihkan dulu. Hash, ukuran berkas, dan nama berkas
   dihitung dari hasil yang sudah bersih.
2. Pembersihan **lossless**: data gambar tidak didekode atau dienkode
   ulang, jadi kualitas, kode QR, dan garis denah tetap tajam.
   Semua format memakai **daftar izin**: hanya bagian yang dibutuhkan untuk
   menampilkan gambar yang disimpan, sisanya (Exif, XMP, IPTC, C2PA/JUMBF,
   telemetri GPS kamera aksi, chunk privat vendor) dibuang.
3. **JPEG:** yang tetap hanya segmen non-APP (tabel, frame, scan), APP0
   (JFIF), APP2 *ICC_PROFILE* (warna), dan APP14 *Adobe*. Semua APPn lain
   dan komentar (COM) dibuang, begitu juga data setelah penanda akhir
   gambar (EOI), misalnya gambar kedua atau peta kedalaman dari ponsel.
4. **PNG:** yang tetap hanya chunk kritis (`IHDR`, `PLTE`, `IDAT`,
   `IEND`), warna (`iCCP`, `sRGB`, `gAMA`, `cHRM`, `cICP`, `mDCV`, `cLLI`,
   `sBIT`), transparansi/latar (`tRNS`, `bKGD`, `hIST`, `sPLT`), `pHYs`,
   dan animasi APNG (`acTL`, `fcTL`, `fdAT`). Data setelah `IEND` dibuang.
5. **WebP:** yang tetap hanya `VP8X`, `ICCP`, `ANIM`, `ANMF`, `ALPH`,
   `VP8 `, `VP8L`. Bit EXIF/XMP di `VP8X` dimatikan, chunk ganjil diberi
   bantalan, ukuran RIFF dihitung ulang, dan data setelah RIFF dibuang.
6. **Orientasi tetap benar:** orientasi dibaca dengan aturan yang sama
   dengan `readImageHeader` (JPEG: Exif sah pertama sebelum SOF). Bila
   nilainya selain 1 (foto ponsel yang diputar), hasil membawa Exif
   minimal yang hanya berisi tag Orientation dengan nilai yang sama di
   tempat segmen asalnya. Tidak ada tag lain (tanpa GPS, waktu, atau model
   ponsel).
7. Berkas yang strukturnya tidak bisa diurai sampai akhir (terpotong atau
   aneh) disimpan apa adanya, karena header-nya sudah dinyatakan sah;
   perilaku ini sama dengan sebelum modul ini.
8. Gambar SVG (denah) tidak diubah. Gambar lama yang sudah tersimpan
   tidak diubah.

## Rancangan teknis

- `lakuna_domain/lib/src/image_metadata.dart`:
  `Uint8List stripImageMetadata(Uint8List bytes)`, murni Dart tanpa
  dekode. Memakai pembaca orientasi Exif yang sama dengan
  `readImageHeader` (dipindah ke fungsi bersama) dan CRC-32 dari
  `hashlib` untuk chunk PNG.
- `storeMediaFile` memanggil `stripImageMetadata` sebelum menghitung
  hash. Pemanggil tidak berubah.
- Lebar/tinggi dari `readImageHeader` sama sebelum dan sesudah
  pembersihan (orientasi dipertahankan).

## Tes

- Domain: JPEG dengan Exif GPS + XMP + COM + data setelah EOI menjadi
  JPEG tanpa semua itu, segmen lain dan data scan identik; orientasi 6
  tetap terbaca 6 dan header tetap menukar sisi; JPEG progresif (beberapa
  SOS) utuh; PNG `tEXt`/`eXIf` dibuang dan CRC chunk hasil sah; WebP
  `EXIF`/`XMP ` dibuang, bit VP8X dan ukuran RIFF benar; berkas tanpa
  metadata tidak berubah; berkas terpotong dikembalikan apa adanya.
- Data: gambar yang dienkode paket `image` dengan Exif GPS disimpan lewat
  foto produk kecil → berkas di `media/` tanpa GPS dan pikselnya sama;
  stiker QRIS dengan Exif → bersih.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Buang metadata dari semua gambar yang disimpan | — | Rilis v0.72.0 | Daftar izin per format. |
| JPEG yang tidak bisa diurai sampai akhir | — | Belum | Byte asing sebelum penanda atau tanpa EOI: disimpan apa adanya (aturan 7). Opsi: buang APPn sebelum SOS lalu salin sisanya. |
| Bersihkan di luar transaksi | — | Belum | Pembersihan berjalan di `storeMediaFile` di dalam transaksi tulis; cukup cepat untuk berkas ≤ 5 MB yang disimpan. |
| Hash berkas lama | — | Belum | Gambar lama (hash dari berkas asli) tidak dianggap sama dengan unggahan ulang yang sudah bersih; hanya menambah satu berkas. |
| Bersihkan gambar lama yang sudah tersimpan | — | Belum | Butuh migrasi berkas `media/` dan hash baru. |
| Metadata di SVG denah | — | Belum | SVG berupa teks; jarang membawa lokasi. |
