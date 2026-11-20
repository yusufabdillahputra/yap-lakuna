# F1-09c · Tombol Simpan di dialog *Buang perubahan?* master data

- **Fase:** 1
- **Status:** Rilis v0.126.0
- **Layar:** 1.17 Master data: dialog grup pelanggan, jenis pengeluaran,
  grup modifier, area, meja, dan rentang meja; dialog *Buang perubahan?*
  (F1-09b, F1-10n, F1-02d).
- **Acuan:** gap "Simpan langsung dari dialog konfirmasi" di
  [F1-09b](2026-11-15-f1-09b-dialog-master-data-design.md); pola sama
  dengan dialog pelanggan & supplier
  [F1-13g](2026-11-20-f1-13g-simpan-dari-dialog-pelanggan-supplier-design.md).

## Masalah

Pemilik yang mengisi grup modifier (banyak opsi dan harga) lalu tanpa
sengaja mengetuk di luar dialog, menekan Esc, Batal, tombol kembali, atau
menutup jendela hanya bisa memilih Batal atau Buang. Untuk menyimpan ia
harus memilih Batal lalu menekan Simpan di dialog form.

## Aturan

1. Dialog *Buang perubahan?* dari keenam dialog master data punya tombol
   **Batal**, **Buang**, dan **Simpan** (tata letak F1-07r).
2. **Simpan** menjalankan simpan yang sama dengan tombol Simpan dialog
   form. Bila berhasil, dialog form tertutup, daftar diperbarui, dan aksi
   yang tertahan diteruskan: menutup dialog, atau menutup aplikasi.
3. Bila simpan gagal, baik isian salah (nama kosong, tempo di luar batas,
   opsi modifier kosong, rentang meja salah) maupun ditolak penyimpanan
   (nama kembar), dialog form tetap terbuka dengan pesannya, dan aplikasi
   tidak ditutup. Di dialog area / meja / rentang kursor pindah ke isian
   yang salah (F1-10q); dialog lain belum memindahkan kursor.
4. Selama simpan berjalan, dialog form tidak bisa ditutup (F1-09b).

## Rancangan teknis

- Simpan di setiap dialog menjawab `Future<bool>`: `true` hanya bila
  simpan berjalan dan berhasil. Isian yang ditolak validasi di dialog
  menjawab `false` tanpa memanggil penyimpanan.
- Jawaban tidak dibaca dari `viewModel.save.result` setelah validasi di
  dialog menolak: simpan tidak berjalan, jadi hasil itu milik simpan
  sebelumnya. Saat ini hasil dibersihkan setiap dialog dibuka, sehingga
  sisa `Ok` tidak mungkin; jawaban eksplisit menjaga agar tetap begitu
  bila view model dipakai bersama di tempat lain.
- Meja / area: `runSave` di mixin `_DialogSaving` menjawab `true` bila
  `onSave` tidak mengembalikan galat; `_save` menjawab `false` bila sedang
  menyimpan atau isian salah.
- `DiscardChangesScope(onSave: _save)` di keenam dialog (F1-13g).

## Pengujian

- Grup F1-09c di `customer_groups_tab_test.dart`,
  `expense_categories_tab_test.dart`, `modifier_groups_tab_test.dart`, dan
  `dining_tables_tab_test.dart`:
  - grup pelanggan: Esc → Simpan → tersimpan dan tampil; ✕ jendela →
    Simpan dengan nama kosong, lalu dengan nama ganda → tetap dengan
    pesan, aplikasi tidak keluar; ✕ jendela → Simpan → keluar;
  - jenis pengeluaran: ketuk di luar → Simpan → tersimpan; ✕ jendela →
    Simpan dengan nama kosong, lalu dengan nama ganda → tidak keluar;
    ✕ jendela → Simpan → keluar;
  - grup modifier: Batal → Simpan → tersimpan; ditolak (nama ganda, opsi
    kosong) lewat Esc dan ✕ jendela → tetap dengan pesan, tidak keluar;
    ✕ jendela → Simpan → keluar;
  - area: Esc → Simpan dengan nama kembar → pesan di bawah Nama dan
    kursor di Nama; ✕ jendela → Simpan nama kembar → tidak keluar; nama
    baru → tersimpan; simpan dari pertanyaan yang berjalan menahan Esc,
    ketuk di luar, dan ✕ jendela;
  - meja: ✕ jendela → Simpan dengan kursi 0 → tidak keluar; kursi benar →
    tersimpan lalu keluar;
  - rentang: Batal → Simpan dengan nama bentrok → tetap dengan pesan;
    rentang baru → tersimpan.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Simpan dari dialog *Buang perubahan?* master data | 1.17 | Rilis v0.126.0 | Grup pelanggan, jenis pengeluaran, grup modifier, area, meja, rentang meja. |
