# F1-07r · Tombol Simpan di dialog *Buang perubahan?* form produk

- **Fase:** 1
- **Status:** Rilis v0.121.0
- **Layar:** 1.15b Form produk; dialog *Buang perubahan?* (F1-07q).
- **Acuan:** gap "Simpan langsung dari dialog" di
  [F1-07q](2026-11-15-f1-07q-keluar-form-produk-design.md). Gap yang sama
  ada di form pembelian (F1-12f), penyesuaian stok (F1-08k), pengeluaran
  (F1-15c), dan dialog master data / pelanggan / supplier (F1-09b,
  F1-13e); form produk dikerjakan lebih dulu karena paling panjang diisi.

## Masalah

Staf yang mengubah harga lalu langsung mengetuk menu lain, **Ganti
kasir**, atau tombol ✕ jendela hanya mendapat pilihan **Batal** (kembali
ke form) atau **Buang**. Untuk menyimpan, ia harus memilih Batal, menekan
Simpan, lalu mengulang navigasinya. Aplikasi kasir lain umumnya memberi
pilihan *Simpan* langsung di dialog yang sama.

## Aturan

1. Dialog *Buang perubahan?* dari form produk (Batal, menu samping,
   tombol kembali, **Ganti kasir**, ✕ jendela) punya tiga tombol:
   **Batal**, **Buang**, dan **Simpan** (tombol utama, paling kanan). Di
   ponsel (lebar isi dialog < 300 px) ketiganya tersusun ke bawah selebar
   dialog dengan **Simpan** paling atas, karena tidak muat sebaris.
2. **Simpan** menutup dialog lalu menjalankan simpan yang sama dengan
   tombol Simpan form (validasi, foto, stok awal). Bila berhasil, navigasi
   yang tertahan diteruskan ke tujuannya (menu yang diketuk, layar masuk
   setelah Ganti kasir, atau aplikasi tertutup); daftar produk tidak
   dibuka lebih dulu.
3. Bila simpan gagal (isian wajib kosong, SKU kembar, galat penyimpanan),
   kasir tetap di form dengan pesan galatnya, sama dengan menekan Simpan
   di form. Navigasi dibatalkan; tidak ada dialog kedua.
4. Selama simpan berjalan, tombol form mati seperti biasa dan navigasi
   lain (menu lain, Ganti kasir, ✕ jendela) ditolak; hanya tujuan yang
   memicu dialog yang diteruskan bila simpan berhasil.
5. Setelah simpan berhasil, form diisi ulang dari produk tersimpan (ID
   produk dan varian, tanpa stok awal). Form bisa tetap tampil, mis. tombol
   kembali Android di halaman form yang dibuka langsung (aplikasi ke
   latar); **Simpan** berikutnya mengubah produk yang sama, tidak membuat
   produk kedua atau stok awal ganda.
6. Dialog lain yang memakai `confirmDiscardChanges` tetap dua tombol
   sampai gap-nya dikerjakan.

## Rancangan teknis

- `confirmDiscardChanges(..., onSave:)`: bila `onSave` diisi, dialog
  menampilkan tombol `<key>-save` (`discardSave` "Simpan" / "Save"). Hasil
  pilihan Simpan: dialog ditutup lalu `await onSave()` menjadi jawaban
  (`true` = boleh pergi).
- `ProductFormViewModel.saveBeforeLeaving()`: `save.execute()`, lalu bila
  berhasil menyimpan `_savedId`, mengisi ulang form (`_reload`) dan
  menandai tersimpan.
- `ProductFormScreen._confirmLeave` memberi `onSave` yang memanggilnya
  sambil menyalakan `LeaveGuard.saving`; selama itu `canLeave` langsung
  `false` (bukan ikut menunggu jawaban navigasi yang ditahan).

## Pengujian

- Widget `confirm_discard_test.dart`: tanpa `onSave` tidak ada tombol
  Simpan; dengan `onSave` jawaban mengikuti hasil simpan.
- Alur `product_flow_test.dart` (grup F1-07r): menu samping → Simpan →
  harga tersimpan dan layar Stok terbuka; produk baru tanpa isian wajib →
  Simpan → tetap di form dengan galat; galat penyimpanan → tetap di form;
  menu lain selama simpan berjalan ditolak; Ganti kasir → Simpan →
  tersimpan dan layar masuk; ✕ jendela → Simpan → tersimpan dan aplikasi
  keluar; ponsel 360 px: tombol tersusun ke bawah, tombol kembali sistem →
  Simpan → Simpan lagi tidak membuat produk kedua.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Simpan dari dialog *Buang perubahan?* form produk | 1.15b | Rilis v0.121.0 | `confirmDiscardChanges(onSave:)`. |
| Simpan dari dialog di form lain | — | Rilis v0.126.0 | Pengeluaran v0.122.0 ([F1-15d](2026-11-20-f1-15d-simpan-dari-dialog-pengeluaran-design.md)); penyesuaian stok v0.123.0 ([F1-08n](2026-11-20-f1-08n-simpan-dari-dialog-penyesuaian-design.md)); pembelian v0.124.0 ([F1-12i](2026-11-20-f1-12i-simpan-draf-dari-dialog-pembelian-design.md)); pelanggan & supplier v0.125.0 ([F1-13g](2026-11-20-f1-13g-simpan-dari-dialog-pelanggan-supplier-design.md)); master data v0.126.0 ([F1-09c](2026-11-20-f1-09c-simpan-dari-dialog-master-data-design.md)). |
| Simpan dari dialog saat form tertutup halaman lain | — | Belum | Mis. ✕ jendela saat Cetak label terbuka di atas form yang berubah: simpan berjalan di form yang tertutup; bila gagal, pesan galatnya baru terlihat setelah kembali ke form. |
