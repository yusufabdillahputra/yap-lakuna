# F1-07q · Peringatan keluar dari form produk tanpa menyimpan

- **Fase:** 1
- **Status:** Rilis v0.98.0
- **Layar:** 1.16 form *Tambah produk* / *Edit produk*.
- **Acuan:** gap "Form lain (produk, pengeluaran, pelanggan)" di
  [F1-12f](2026-11-14-f1-12f-keluar-tanpa-menyimpan-design.md). Pola dan
  dialog sama dengan form pembelian. Storeku tidak punya aturan ini.

## Masalah

Form produk memuat banyak isian: info produk, varian, satuan konversi,
harga grosir, modifier, dan foto. Tombol *Kembali* / *Batal*, tombol
kembali sistem, dan menu samping langsung membuang semuanya tanpa bertanya.

## Aturan

1. Form dianggap **berubah** bila isiannya berbeda dari keadaan terakhir
   yang dimuat atau disimpan: nama, kategori, jenis, satuan dasar, SKU,
   merek, sakelar aktif / pajak / tiket dapur / catatan bebas, modifier
   terpasang, varian (nama, SKU, barcode, harga modal & jual, stok
   minimum, stok awal varian baru), satuan konversi, harga grosir, dan foto
   (foto baru atau foto tersimpan yang dilepas). Mengetik lalu
   mengembalikan isian ke semula tidak dihitung berubah. Pindah tab atau
   memilih varian di tab Satuan / Grosir bukan perubahan.
2. Keadaan awal: produk baru = form kosong dengan satu varian; produk lama
   = data tersimpan.
3. Setelah *Simpan* berhasil (termasuk foto) atau produk diarsipkan, form
   boleh ditinggalkan. Bila produk tersimpan tetapi fotonya gagal, isian
   data yang tersimpan menjadi keadaan awal baru dan foto tetap terhitung
   berubah: melepas foto itu membuat form tidak berubah lagi, sedangkan
   mengembalikan harga ke nilai lama terhitung berubah.
4. Barcode yang diisi dari data tersimpan setelah kembali dari *Cetak
   label* (F1-07j) bukan perubahan bila form sebelumnya belum berubah.
5. Meninggalkan form yang berubah lewat *Kembali*, *Batal*, tombol kembali
   sistem, atau menu samping / bawah menampilkan **Buang perubahan?**
   ("Perubahan produk {nama} belum disimpan dan akan hilang.", atau "Produk
   baru ini belum disimpan dan akan hilang." bila nama kosong) dengan
   **Batal** dan **Buang**. Membuka *Cetak label* tidak meninggalkan form.
6. Selama *Simpan* atau *Arsipkan* berjalan, keluar ditahan sampai
   selesai. Ganti kasir tidak ditahan.

## Rancangan teknis

- `ProductFormViewModel.hasUnsavedChanges`: `_dataSignature()` dan
  `_photoSignature()` (daftar rata, dibanding dengan `listEquals`, agar
  teks berisi pemisah tidak membuat dua isian berbeda tampak sama)
  dibanding salinannya, diisi di akhir `_load`, setelah `_save` (dan foto)
  berhasil, setelah arsip berhasil, dan di `refreshBarcodes` bila form
  belum berubah.
- Router: `onExit` + `LeaveGuard` (F1-12f) di `/produk/baru` dan
  `/produk/:id`; `ProductFormScreen` memasang `check`.

## Pengujian

- VM: baru / lama belum berubah; ketik lalu kembalikan; tambah satuan,
  grosir, varian; pindah tab; foto; simpan; galat simpan; arsip; barcode
  dari Cetak label.
- Widget (`product_flow_test.dart`): Batal / menu samping → dialog,
  *Batal* tetap, *Buang* keluar; form tanpa perubahan dan setelah simpan
  keluar tanpa dialog.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Peringatan keluar dari form produk yang berubah | 1.16 | Rilis v0.98.0 | Kembali, Batal, tombol kembali sistem, menu samping. |
| Simpan langsung dari dialog | — | Belum | Dialog hanya Batal / Buang. |
| Form pengeluaran, pelanggan, supplier | — | Belum | Belum bertanya. |
| Barcode dari Cetak label saat form sudah berubah | — | Belum | Ikut terhitung perubahan staf; membatalkan ubahan lain tetap bertanya. |
| Tombol kembali sistem di halaman form yang dibuka langsung | — | Belum | Bila form tidak berubah atau dipilih Buang, aplikasi tertutup (perilaku go_router tanpa halaman di bawahnya), sama seperti sebelumnya. |
