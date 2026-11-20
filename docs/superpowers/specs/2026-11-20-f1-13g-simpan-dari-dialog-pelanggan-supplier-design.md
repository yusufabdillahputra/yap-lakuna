# F1-13g · Tombol Simpan di dialog *Buang perubahan?* pelanggan & supplier

- **Fase:** 1
- **Status:** Rilis v0.125.0
- **Layar:** 1.20 Pelanggan, 1.21 Supplier: dialog form pelanggan (juga dari
  Kasir › pilih pelanggan › *Pelanggan baru*) dan dialog form supplier;
  dialog *Buang perubahan?* (F1-13e, F1-02d).
- **Acuan:** gap "Simpan langsung dari dialog konfirmasi" di
  [F1-13e](2026-11-15-f1-13e-dialog-pelanggan-supplier-design.md); pola
  sama dengan form produk [F1-07r](2026-11-20-f1-07r-simpan-dari-dialog-produk-design.md).

## Masalah

Staf yang mengisi pelanggan baru (nama, HP, grup) lalu tanpa sengaja
mengetuk di luar dialog, menekan Esc, tombol kembali, Batal, atau menutup
jendela hanya bisa memilih Batal atau Buang. Untuk menyimpan ia harus
memilih Batal lalu mencari tombol Simpan di dialog form.

## Aturan

1. Dialog *Buang perubahan?* dari dialog form pelanggan dan supplier punya
   tombol **Batal**, **Buang**, dan **Simpan** (tata letak F1-07r).
2. **Simpan** menjalankan simpan yang sama dengan tombol Simpan dialog
   form. Bila berhasil, dialog form tertutup dengan hasilnya seperti biasa
   (daftar memilih pelanggan / supplier itu, kasir memasang pelanggan baru
   ke pesanan) dan aksi yang tertahan diteruskan: menutup dialog, atau
   menutup aplikasi.
3. Bila simpan gagal (isian salah, mis. nama kosong, atau ditolak
   penyimpanan, mis. HP sudah dipakai), dialog form tetap terbuka dengan
   pesan galatnya, dan aplikasi tidak ditutup.
4. Selama simpan berjalan, dialog form tidak bisa ditutup (F1-13e).

## Rancangan teknis

- `DiscardChangesScope` mendapat `onSave` opsional yang diteruskan ke
  `confirmDiscardChanges`. Simpan menutup dialog form sendiri lewat
  `Navigator.pop(hasil)`, jadi lingkup tidak menutupnya lagi (`_isCurrent`
  sudah salah saat rute sedang ditutup; ditambah tanda `_saved`).
  `canDiscardAll` memakai jawaban yang sama: `true` bila tersimpan.
- `CustomerFormDialog` dan `SupplierFormDialog`: `onSave` memanggil `_save`
  lalu `true` bila hasilnya `Ok`.
- Dialog master data (grup pelanggan, jenis pengeluaran, grup modifier,
  meja) menyusul di [F1-09c](2026-11-20-f1-09c-simpan-dari-dialog-master-data-design.md).

## Pengujian

- `confirm_discard_test.dart`: lingkup dengan `onSave` menampilkan Simpan;
  `canDiscardAll` menjawab hasil simpan; lewat `maybePop` simpan yang
  menutup rutenya sendiri tidak menutup rute di bawahnya; simpan gagal
  tetap terbuka.
- `customers_flow_test.dart` & `suppliers_flow_test.dart` grup F1-13g:
  Esc → Simpan → tersimpan dan tampil di daftar; simpan gagal → dialog
  tetap dengan pesan; ✕ jendela → Simpan → tersimpan lalu keluar.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Simpan dari dialog *Buang perubahan?* pelanggan & supplier | 1.20, 1.21 | Rilis v0.125.0 | Ketuk di luar, Esc, kembali sistem, Batal, ✕ jendela. |
| Dialog master data | 1.17 | Rilis v0.126.0 | [F1-09c](2026-11-20-f1-09c-simpan-dari-dialog-master-data-design.md). |
