# F1-06b · Logo di struk

- **Fase:** 1
- **Status:** Rilis v0.39.0
- **Layar:** 1.26 *Pengaturan › Struk & printer* (logo + sakelar *Tampilkan
  logo*), struk cetak/PDF/pratinjau (1.12, 1.14, kuitansi, rekap 1.3).
- **Acuan:** kanvas 1.26 *Tampilkan logo*; spec Storeku F1-06 "logo
  raster", "`media` (logo)". Storeku belum membangunnya.
- **Menutup gap:** F1-06 "Logo di struk".

## Tujuan

Struk tampil lebih resmi dengan logo toko di atas nama toko, baik di
printer thermal maupun PDF.

## Aturan

1. **Logo per cabang**, bagian dari pengaturan struk (`receipt.settings`):
   `logoMediaId` → `media_files` (`MediaKind.receiptLogo`, `outlet_id`
   cabang) dan `showLogo`. Memilih logo baru menyalakan *Tampilkan logo*
   di form; pemilik masih bisa mematikannya sebelum *Simpan*.
2. **Berkas**: PNG atau JPG sampai 1 MB, diperiksa dari isi berkas
   (`readImageHeader`). Disarankan hitam putih dengan latar putih atau
   transparan. Berkas disimpan apa adanya di `media/<sha256>.<ext>`.
3. **Pengaturan 1.26** (izin `settings:manage`): kotak pratinjau logo,
   *Pilih logo* / *Ganti logo*, *Hapus logo*, sakelar *Tampilkan logo di
   struk* (nonaktif bila belum ada logo). Logo baru dan hapus logo ikut
   tersimpan saat *Simpan* struk. Berkas tidak didukung / terlalu besar →
   pesan di bawah kotak.
4. **Cetak** (struk penjualan, cetak ulang, kuitansi struk, tes cetak,
   rekap sesi): bila *Tampilkan logo* aktif dan berkasnya ada di
   perangkat, logo dicetak di tengah di atas nama toko.
   - **ESC/POS**: logo diperkecil ke lebar maks 256 titik (58 mm) / 384
     titik (80 mm), tinggi maks 160 titik, diubah ke hitam putih (piksel
     transparan = putih, ambang luminans 50 % dengan dithering
     Floyd–Steinberg), dikirim sebagai `GS v 0` setelah `ESC @` dan
     `ESC a 1`. Bitmap dilebarkan ke lebar cetak penuh (384 / 576 titik)
     dengan logo di tengah, karena sebagian printer murah mengabaikan
     `ESC a` untuk gambar raster.
   - **PDF / dialog cetak**: gambar asli, lebar maks 60 % kertas, tinggi
     maks 20 mm, di tengah.
   - **Pratinjau layar** (pengaturan, layar sukses, cetak ulang): gambar di
     atas kertas struk.
   - Logo gagal dibaca/didekode → struk tetap dicetak tanpa logo.
   - Tiket dapur dan cek pesanan meja F&B tidak memakai logo (dokumen
     internal, hemat kertas).
5. Struk yang sudah ada di riwayat tidak menyimpan logo; cetak ulang
   memakai logo saat ini.

## Komponen

- Server model: `MediaKind.receiptLogo` (enum `byName`, tanpa migrasi
  kolom).
- Domain: `checkReceiptLogo`, `maxReceiptLogoBytes`, `MonoBitmap`,
  `monoBitmapFromRgba` (dithering), `encodeEscPos(..., logo:)` (`GS v 0`),
  `receiptLogoMaxDots(paper)`, `receiptPrintDots(paper)`,
  `MonoBitmap.centeredIn`.
- Data: `ReceiptSettings.logoMediaId/showLogo`, `ReceiptLogoUpload`,
  `ReceiptLogoInvalid`, `saveReceiptSettings(..., logo:, removeLogo:)`,
  `ReceiptConfig.logoBytes` (hanya bila tampil dan berkas ada).
- Flutter: `ReceiptPrinter.print/sharePdf(..., logo:)`, dekode RGBA lewat
  `dart:ui`, `buildReceiptPdf(..., logo:)`, `ReceiptPaperView(logo:)`,
  `ReceiptSettingsViewModel` (pilih/hapus logo, sakelar).

## Pengujian

- Domain: bitmap (ambang, transparan, dithering), byte `GS v 0` persis,
  urutan byte dengan logo, cek berkas.
- Data: simpan logo (media + JSON), ganti, hapus, sakelar mati →
  `logoBytes` null, berkas hilang → null, berkas tidak sah.
- Flutter: VM pengaturan (pilih, hapus, simpan), pemanggil cetak meneruskan
  logo (kasir, riwayat, rekap), widget 1280/360 px.
- Uji manual Xvfb: unggah logo, tes cetak PDF menampilkan logo.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Logo di struk | *Tampilkan logo* | Rilis v0.39.0 | Tiket dapur tanpa logo |
| Logo dari profil toko | Storeku: "bersama Profil toko" | Belum | Profil toko Lakuna hanya nama usaha; logo diatur per cabang di pengaturan struk agar tiap cabang bisa berbeda. |
