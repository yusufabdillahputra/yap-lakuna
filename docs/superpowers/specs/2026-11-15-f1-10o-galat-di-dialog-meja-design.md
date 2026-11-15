# F1-10o · Simpan area / meja / rentang yang ditolak tidak menutup dialog

- **Fase:** 1
- **Status:** Rilis v0.109.0
- **Layar:** 1.17 Master data › Meja & area: dialog *Area*, *Meja*,
  *Rentang meja*.
- **Acuan:** gap "Isian dialog hilang saat simpan ditolak" di
  [F1-10n](2026-11-15-f1-10n-dialog-meja-area-design.md). Polanya sama
  dengan dialog grup modifier / grup pelanggan / jenis pengeluaran, yang
  menyimpan dari dalam dialog dan menampilkan galat di dialog.

## Masalah

Dialog menutup lebih dulu, baru tab menyimpan. Bila penyimpanan ditolak
(nama area/meja kembar, nama terlalu panjang, salah satu nama rentang
sudah dipakai), galat tampil di tab dan isian hilang. Untuk *Rentang
meja* staf harus mengatur ulang awalan, nomor, kursi, dan area.

## Aturan

1. **Simpan** menjalankan penyimpanan dari dalam dialog. Berhasil: dialog
   tertutup dan daftar dimuat ulang (seperti sebelumnya). Ditolak: dialog
   tetap terbuka dengan isian utuh, dan pesan galat tampil di dialog
   (di atas tombol), dengan teks yang sama seperti galat di tab sebelumnya
   (mis. "Nama sudah dipakai.", "Nama M7 sudah dipakai.").
2. Galat simpan dari dialog tidak lagi tampil sebagai peringatan di tab.
   Galat aksi lain di tab (hapus, urut) tetap tampil di tab.
3. Selama simpan berjalan tombol **Simpan** nonaktif dan dialog tidak bisa
   ditutup (ketuk di luar, Esc, Batal, kembali diabaikan).
4. Setelah simpan ditolak, dialog masih dianggap berubah bila isiannya
   berbeda dari saat dibuka; menutupnya tetap bertanya (F1-10n).
5. Mengubah isian menghapus pesan galat simpan.

## Rancangan teknis

- Dialog menerima `onSave: Future<Exception?> Function(T value)`; `null` =
  berhasil, selain itu galatnya. Dialog sendiri mengubah galat menjadi
  pesan (`diningSetupErrorMessage` dengan nama rentang / batas nama area)
  memakai `context`-nya, karena tab bisa dibangun ulang selama dialog
  terbuka (lebar melewati 900 px memindahkan isi Master data dari `Row` ke
  `Column`). Mixin `_DialogSaving` memegang `saving` dan `saveError`;
  `DiscardChangesScope(busy: saving)`.
- Galat tak terduga (bukan `Exception`, mis. `StateError`) ditangkap dan
  tampil sebagai *Aksi gagal. Coba lagi.* agar dialog tidak terkunci.
- Tab membuat `onSave` yang menjalankan perintah VM (`addArea`,
  `renameArea`, `saveTable`, `addRange`), memanggil `vm.clearError()` agar
  peringatan tab tidak ikut tampil, lalu mengembalikan galatnya.
- Pesan galat hanya dihapus bila teks isian benar-benar berubah (geser
  kursor memicu `onChange` Forui tanpa mengubah teks).
- Galat dialog: `FAlert` destruktif dengan kunci `dining-setup-dialog-error`.

## Pengujian

- `dining_tables_tab_test.dart`: area kembar → dialog tetap terbuka, nama
  masih terisi, pesan di dialog, tidak ada peringatan tab; ubah nama lalu
  simpan berhasil menutup; meja kembar; rentang bentrok (pesan "Nama M7
  sudah dipakai.", isian rentang utuh); setelah ditolak Esc tetap
  bertanya; mengetik menghapus pesan; simpan yang berjalan tidak bisa
  ditutup (repo palsu ditahan dengan `Completer`); ubah nama area kembar;
  Enter / ketuk Simpan / Batal saat simpan berjalan diabaikan (satu
  panggilan simpan); `StateError` dari repo tidak mengunci dialog; tab
  dibangun ulang (lebar 800 px) saat dialog terbuka tetap menampilkan
  galat.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Galat simpan area / meja / rentang di dialog, isian utuh | 1.17 | Rilis v0.109.0 | Mixin `_DialogSaving`. |
| Galat per isian (mis. nama kembar di bawah kolom Nama) | — | Rilis v0.111.0 | [F1-10p](2026-11-15-f1-10p-galat-per-isian-meja-design.md): nama di bawah Nama, kursi di bawah Kursi, nama rentang di pratinjau. |
| Kunci isian selama simpan berjalan | — | Belum | Isian tetap bisa diketik selama simpan (biasanya sesaat); nilai yang disimpan adalah nilai saat Simpan ditekan. |
