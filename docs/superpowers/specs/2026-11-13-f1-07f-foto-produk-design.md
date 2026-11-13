# F1-07f · Foto produk

- **Fase:** 1
- **Status:** Rilis v0.37.0
- **Layar:** 1.16 Form produk (kotak foto di *Info dasar*), 1.15 Daftar
  produk (thumbnail), 1.4 Kasir (foto di kartu produk).
- **Acuan:** kanvas 1.16 *Ganti foto* + thumbnail; spec Storeku F1-07
  "Foto dikecilkan … disimpan `media/<sha256>.<ext>`, dicatat di `media`".
- **Menutup gap:** F1-07 "Foto produk".

## Tujuan

Pemilik bisa memberi foto pada produk agar kasir lebih cepat mengenali
barang di layar Kasir, terutama menu F&B dan barang tanpa barcode.

## Aturan

1. **Satu foto per produk** (bukan per varian): kolom baru
   `products.photo_media_id` → `media_files` (`MediaKind.productPhoto`,
   `outlet_id` kosong karena produk berlaku untuk semua cabang).
2. **Berkas**: PNG, JPG, atau WebP sampai 2 MB, diperiksa dari isi berkas
   (`readImageHeader`), bukan dari nama. Di Android/iOS ada pilihan *Ambil
   foto* dari kamera (dikecilkan ke lebar 1.600 px, kualitas 85;
   `ProductLimits.cameraMaxWidth`). Berkas
   disimpan apa adanya di `media/<sha256>.<ext>`; berkas sama tidak disalin
   dua kali.
   - Perbedaan dengan Storeku: belum dikecilkan/dikonversi ke WebP karena
     Flutter belum punya encoder WebP bawaan; tampilan memakai `cacheWidth`
     agar memori tetap kecil (lihat gap).
3. **Form 1.16**: kotak foto 96 px di kiri atas *Info dasar*. Tombol *Pilih
   foto* / *Ganti foto*, *Ambil foto* (ponsel), dan *Hapus foto*. Pilihan
   baru langsung tampil sebagai pratinjau tetapi baru tersimpan saat
   *Simpan* (produk baru: setelah produknya tersimpan). Berkas tidak
   didukung atau terlalu besar → pesan di bawah kotak, form lain tetap.
4. **Simpan**: foto disimpan lewat `setProductPhoto` / `clearProductPhoto`
   (`LakunaStore.write` + `SyncTx`, versi produk naik), izin
   `products:manage`. Bila produk tersimpan tetapi foto gagal, form tetap
   terbuka dengan pesan *Produk tersimpan, foto gagal disimpan*, diisi
   ulang dari produk tersimpan (ID varian, tanpa stok awal) sehingga
   *Simpan* lagi hanya mengubah produk itu. Galat kamera/berkas (mis. izin
   ditolak) → pesan *Foto tidak bisa dibuka*.
5. **Tampil**: `CatalogProduct.photoPath` (lokasi berkas di perangkat,
   `null` bila tidak ada atau berkas belum tersinkron). Daftar 1.15 dan
   kartu Kasir menampilkan foto, selain itu kotak inisial seperti
   sebelumnya. Gambar rusak → kotak inisial.
6. Arsip, pulihkan, dan import tidak mengubah foto. Backup sudah membawa
   folder `media/`.

## Komponen

- Server model: `Product.photoMediaId`, `MediaKind.productPhoto`; migrasi
  `foto-produk`.
- Data: `setProductPhoto`, `clearProductPhoto`, `ProductPhotoInvalid`,
  `CatalogProduct.photoMediaId/photoPath`.
- Domain: `ProductLimits.photoMaxBytes`.
- Flutter: `CatalogRepository.setPhoto/clearPhoto`, `ProductFormViewModel`
  (`pickPhoto`, `takePhoto`, `removePhoto`, `photoPreview`), `ProductThumb`
  dengan `photoPath`.

## Pengujian

- Data: simpan foto (baris media + versi produk naik + outbox), ganti foto,
  hapus foto, berkas bukan gambar / terlalu besar → `ProductPhotoInvalid`,
  tenant lain → `ProductNotFound`, `photoPath` di katalog.
- Flutter: VM form (pilih → simpan memanggil repositori, hapus, galat
  berkas, produk baru), widget 1280/360 px (kotak foto, thumbnail di daftar).
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Foto produk di form, daftar, dan Kasir | *Ganti foto*, thumbnail | Rilis v0.37.0 | Juga di daftar menu meja F&B. |
| Kecilkan foto ke 1.024 px WebP | Storeku F1-07 | Belum | Perlu encoder gambar; sekarang batas 2 MB + `cacheWidth`. |
| Foto per varian | — | Tidak direncanakan | Satu foto per produk cukup untuk Fase 1. |
