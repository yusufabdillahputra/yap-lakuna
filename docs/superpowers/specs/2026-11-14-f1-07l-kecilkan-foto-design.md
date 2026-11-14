# F1-07l — Kecilkan foto produk dan foto faktur

- **Status:** Rilis v0.62.0
- **Layar:** 1.16 *Form produk* (kotak foto), 1.19 *Pembelian* (foto
  faktur di form dan detail).
- **Acuan:** gap [F1-07f](2026-11-13-f1-07f-foto-produk-design.md)
  *Kecilkan foto ke 1.024 px WebP* dan
  [F1-12b](2026-11-14-f1-12b-foto-faktur-design.md) *Kecilkan foto ke
  WebP*; spec Storeku F1-07 ("Foto dikecilkan … disimpan
  `media/<sha256>.<ext>`").

## Tujuan

Foto dari galeri ponsel atau kamera sering 3–10 MB. Sekarang foto seperti
itu ditolak (produk maks 2 MB, faktur maks 5 MB), jadi pemilik harus
mengecilkannya sendiri. Lakuna mengecilkan foto otomatis sebelum disimpan,
sehingga foto besar bisa dipakai langsung dan folder `media/` serta berkas
backup tetap kecil.

## Aturan

1. **Batas pilih naik ke 20 MB** untuk foto produk dan foto faktur
   (`ProductLimits.photoInputMaxBytes`,
   `PurchaseLimits.invoicePhotoInputMaxBytes`). Berkas tetap harus PNG,
   JPG, atau WebP menurut isinya, dan paling banyak **50 MP** menurut
   header (`photoMaxPixels`) agar berkas kecil yang menyatakan ukuran
   raksasa tidak menghabiskan memori ponsel; di atas itu dianggap *terlalu
   besar*. Animasi (WebP/APNG) hanya bingkai pertamanya yang dipakai.
2. **Ukuran simpan:** sisi terpanjang paling banyak **1.024 px** untuk
   foto produk dan **2.000 px** untuk foto faktur (agar tulisan faktur
   tetap terbaca). Rasio tetap; gambar tidak pernah diperbesar.
3. **Format simpan:** JPEG kualitas 85. Gambar dengan piksel transparan
   (PNG/WebP ber-alpha, mis. logo produk) disimpan sebagai PNG agar latar
   tidak menjadi hitam; bila PNG itu masih melebihi batas simpan, gambar
   diratakan ke latar putih dan disimpan sebagai JPEG.
   - Perbedaan dengan Storeku: JPEG, bukan WebP, karena belum ada encoder
     WebP murni Dart. Ukurannya setara untuk foto produk (±100–300 KB).
4. **Orientasi EXIF** dari kamera diterapkan ke piksel sebelum disimpan,
   karena JPEG hasil tidak membawa EXIF lagi. Akibatnya data EXIF lain
   (lokasi GPS, model ponsel) ikut terbuang dari foto yang dikecilkan.
5. **Foto kecil dibiarkan:** bila sisi terpanjang sudah di dalam batas dan
   berkas ≤ 512 KB, berkas disimpan apa adanya. Foto di atas batas sisi
   selalu dikecilkan. Foto dalam batas sisi tetapi > 512 KB dienkode
   ulang dan hasilnya dipakai hanya bila lebih kecil dari aslinya (tetap
   dibatasi aturan 6).
6. **Batas simpan tetap:** hasil akhir maks 2 MB (produk) / 5 MB (faktur).
   Berkas yang tidak bisa didekode atau hasilnya masih melebihi batas
   ditolak dengan pesan lama (*terlalu besar* / *bukan gambar*).
7. **Tidak membekukan layar:** dekode, ubah ukuran, dan enkode berjalan di
   isolate terpisah (`Isolate.run`) sebelum transaksi database dimulai.
   Galat apa pun di isolate dilaporkan sebagai *bukan gambar*. Izin
   pembelian diperiksa sebelum foto didekode.
8. Foto lama yang sudah tersimpan tidak diubah.

## Komponen

- `lakuna_domain`: `ProductLimits.photoInputMaxBytes`,
  `ProductLimits.photoMaxSide = 1024`,
  `PurchaseLimits.invoicePhotoInputMaxBytes`,
  `PurchaseLimits.invoicePhotoMaxSide = 2000`.
- `lakuna_data/lib/src/photo_shrink.dart`:
  `shrinkPhoto(bytes, {maxSide, maxBytes, keepBytes = 512 KB,
  quality = 85})` → `Uint8List`, gagal dengan `PhotoShrinkFailure`
  (`unreadable` / `tooManyPixels`); paket `image`, pure Dart, di isolate.
- `setProductPhoto`, `savePurchaseDraft`, `receivePurchase`,
  `setPurchaseInvoicePhoto` mengecilkan foto dulu, lalu memeriksa batas
  simpan.
- Flutter: VM form produk dan pembelian memakai batas pilih 20 MB; teks
  petunjuk dan pesan galat diperbarui.

## Pengujian

- Data: foto besar dikecilkan (sisi ≤ batas, JPEG), PNG transparan tetap
  PNG, orientasi EXIF diterapkan, foto kecil tidak diubah, berkas rusak
  ditolak, foto produk 3.000 px tersimpan ≤ 1.024 px, foto faktur
  tersimpan ≤ 2.000 px, berkas di atas 20 MB ditolak.
- Flutter: VM menerima pilihan di atas batas lama.
- Uji manual Xvfb: pilih foto produk besar, lihat ukuran berkas di
  `media/`.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Kecilkan foto produk dan faktur | 1.16, 1.19 | Rilis v0.62.0 | Selesai. |
| Simpan WebP | Storeku F1-07 | Belum | Butuh encoder WebP; JPEG dipakai. |
| Kecilkan foto nota pengeluaran / bukti bayar supplier | — | Rilis v0.63.0 | [F1-15b](2026-11-14-f1-15b-kecilkan-foto-nota-design.md). |
| Kecilkan denah / QRIS | — | Belum | Tetap batas 5 MB; sengaja tidak dikecilkan agar kode QR dan garis denah tetap tajam. |
| Buang EXIF dari foto kecil yang tidak dikecilkan | — | Rilis v0.72.0 ([F1-07n](2026-11-14-f1-07n-buang-metadata-foto-design.md)) | Semua gambar yang disimpan dibersihkan tanpa enkode ulang. |
| JPEG/WebP yang tidak didukung paket `image` | — | Belum | JPEG aritmetika / 12-bit dan sebagian varian WebP ditolak bila perlu dikecilkan (> 512 KB atau di atas batas sisi); berkas kecil tetap diterima apa adanya. |
| Pesan khusus *hasil kecil masih terlalu besar* | — | Belum | Jarang (PNG transparan sudah jatuh ke JPEG); memakai pesan *terlalu besar* / *bukan gambar* yang ada. |
