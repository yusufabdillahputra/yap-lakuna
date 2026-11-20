# F1-09b · Dialog master data tidak tertutup tanpa bertanya

- **Fase:** 1
- **Status:** Rilis v0.107.0
- **Layar:** 1.17 Master data: dialog *Grup modifier* (tab Modifier),
  *Grup pelanggan* (tab Grup pelanggan), dan *Jenis pengeluaran* (tab Jenis
  pengeluaran).
- **Acuan:** gap "Dialog pendek lain (jenis pengeluaran, grup, pembayaran)"
  di [F1-13e](2026-11-15-f1-13e-dialog-pelanggan-supplier-design.md);
  aturan dan dialog *Buang perubahan?* sama. Storeku tidak punya aturan
  ini.

## Masalah

Ketiga dialog ini tertutup langsung (ketukan di luar dialog, Esc, tombol
kembali sistem, Batal) dan membuang isian. Yang paling merugikan adalah
grup modifier: staf bisa sudah mengetik belasan opsi beserta harganya.
Dialog juga tampil di navigator cabang, sehingga menu samping masih bisa
diketuk dan membuang isian.

## Aturan

1. Dialog dianggap **berubah** bila isiannya berbeda dari keadaan saat
   dibuka:
   - grup modifier: nama, wajib/opsional, minimal (bila wajib), maksimal,
     dan daftar opsi (urutan, nama, harga, bawaan, tersedia). Dialog baru
     dimulai dengan satu opsi kosong; opsi kosong itu bukan perubahan.
   - grup pelanggan: nama, tempo (hari);
   - jenis pengeluaran: nama.
   Nama dibandingkan setelah spasi di awal/akhir dibuang, karena nama
   memang disimpan tanpa spasi itu (sengaja berbeda dari F1-13e, yang
   membandingkan isian mentah karena alamat dan catatan disimpan apa
   adanya). Minimal/maksimal dibandingkan sebagai angka, seperti saat
   disimpan ("02" sama dengan "2"). Mengetik lalu mengembalikan isian tidak
   dihitung.
2. Menutup dialog yang berubah lewat ketukan di luar dialog, Esc, tombol
   kembali sistem, atau **Batal** menampilkan **Buang perubahan?** dengan
   isi "Grup modifier yang sedang diisi belum disimpan dan akan hilang." /
   "Grup pelanggan …" / "Jenis pengeluaran …", tombol **Batal** (kembali)
   dan **Buang** (tutup). Dialog yang tidak berubah tertutup seperti biasa.
3. Selama *Simpan* berjalan, dialog tidak bisa ditutup kecuali oleh hasil
   simpan. Simpan yang gagal membiarkan dialog terbuka dan tetap bertanya.
4. Dialog tampil di navigator akar (menutupi menu samping / bawah).
5. Esc bekerja walau tidak ada isian berfokus (dialog dibuka tanpa
   autofokus, sakelar/kotak centang diklik, atau isian dilepas fokusnya):
   dialog yang tidak berubah tertutup, dialog yang berubah bertanya. Ini
   juga memperbaiki dialog pelanggan dan supplier (F1-13e), yang
   sebelumnya mengabaikan Esc dalam keadaan itu.

## Rancangan teknis

- Sama dengan F1-13e: `showFDialog(useRootNavigator: true,
  barrierDismissible: false)`, `TapOutsideToPop` di luar `FDialog`,
  `DiscardChangesScope(dirty, busy, body, dialogKey)` di dalam, tombol
  Batal memanggil `Navigator.maybePop`.
- Keadaan berubah dihitung di `State` dialog (isian disimpan di sana):
  tanda tangan awal disimpan saat `initState`, dibandingkan dengan tanda
  tangan sekarang (`listEquals`).
- `TapOutsideToPop` memasang `FocusScope(autofocus: true)` di bawah
  `Actions` Esc. Aksi Esc dicari dari fokus utama ke atas; tanpa lingkup
  ini fokus utama bisa jatuh ke lingkup rute dialog (di atas `Actions`).
  Dengan lingkup ini, dialog tanpa autofokus memfokuskan lingkupnya, isian
  yang dilepas fokusnya (`UnfocusDisposition.scope`) kembali ke lingkup ini,
  dan setelah pertanyaan ditutup fokus kembali ke dalamnya. Pendengar
  `FocusManager` global sengaja tidak dipakai: di desktop, saat jendela
  tidak aktif fokus pindah ke `rootScope` dan pendengar itu akan membuang
  fokus isian yang ditangguhkan (temuan review).
- Kunci dialog: `modifier-discard`, `customer-group-discard`,
  `expense-category-discard` (+ `-cancel` / `-confirm`). Tombol Batal
  diberi kunci `modifier-cancel`, `customer-group-cancel`,
  `expense-category-cancel`.
- l10n: `modifierDiscardBody`, `customerGroupDiscardBody`,
  `expenseCategoryDiscardBody` (ID + EN).

## Pengujian

- `modifier_groups_tab_test.dart`: dialog baru tanpa perubahan tertutup
  dengan ketukan di luar; mengetik opsi lalu Esc bertanya; Batal kembali;
  menu samping tertutup dialog dan ikut bertanya; mengembalikan isian
  tidak bertanya; ubah *Tersedia* lalu Batal + Buang tidak menyimpan.
  Tabel per isian (nama grup, minimal, maksimal, nama opsi, harga opsi,
  bawaan, tersedia, tambah opsi, hapus opsi, wajib dimatikan) lalu Esc
  selalu bertanya dan Buang tidak menyimpan; "02" untuk maksimal 2 tidak
  bertanya; simpan gagal (nama kosong) lalu Esc tetap bertanya.
  Minimal/maksimal kosong dibandingkan sebagai 0, sama dengan `_draft`.
- `customer_groups_tab_test.dart`: dialog tanpa perubahan tertutup dengan
  ketukan di luar; ubah tempo lalu ketuk di luar bertanya; Batal kembali;
  Esc bertanya; tempo dikembalikan lalu Esc langsung menutup; ubah tempo
  lalu tombol Batal bertanya dan Buang tidak menyimpan.
- `expense_categories_tab_test.dart`: spasi saja bukan perubahan; Esc
  bertanya; Buang tidak menyimpan; ketuk di luar → Batal → Esc masih
  bertanya; dialog baru ditutup Esc langsung; isian dilepas fokusnya lalu
  Esc tetap bertanya (sebelum perbaikan fokus tes ini gagal).
- Uji manual Xvfb: dialog Grup modifier (Topping) dan Jenis pengeluaran.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Tanya sebelum menutup dialog modifier, grup pelanggan, jenis pengeluaran | 1.17 | Rilis v0.107.0 | Sama dengan F1-13e. |
| Dialog area / meja / rentang meja (tab Meja) | 1.17 | Rilis v0.108.0 | [F1-10n](2026-11-15-f1-10n-dialog-meja-area-design.md). |
| Simpan langsung dari dialog konfirmasi | — | Rilis v0.126.0 | [F1-09c](2026-11-20-f1-09c-simpan-dari-dialog-master-data-design.md); termasuk dialog meja / area. |
