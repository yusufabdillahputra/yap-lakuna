# F1-13e · Dialog pelanggan & supplier tidak tertutup tanpa bertanya

- **Fase:** 1
- **Status:** Rilis v0.100.0
- **Layar:** 1.20 dialog *Pelanggan baru* / *Ubah pelanggan* (dari daftar
  Pelanggan, panel pelanggan, dan Kasir F1-04f); 1.21 dialog *Supplier
  baru* / *Ubah supplier*.
- **Acuan:** gap "Form lain (pelanggan, supplier)" di
  [F1-12f](2026-11-14-f1-12f-keluar-tanpa-menyimpan-design.md) dan gap
  dialog di [F1-15c](2026-11-15-f1-15c-keluar-form-pengeluaran-design.md).
  Dialog *Buang perubahan?* sama. Storeku tidak punya aturan ini.

## Masalah

Kedua form berupa dialog. Mengetuk di luar dialog, menekan Esc, atau
tombol kembali sistem langsung menutup dialog dan membuang isian (nama,
HP, alamat, limit kredit, catatan). Dialog juga tampil di navigator
cabang, jadi menu samping masih bisa diketuk saat dialog terbuka dan
membuang isian tanpa bertanya.

## Aturan

1. Form dianggap **berubah** bila isiannya berbeda dari keadaan saat
   dialog dibuka:
   - pelanggan: nama, HP (dibanding setelah dinormalisasi), grup (dan nama
     grup baru bila *Grup baru* dipilih), limit kredit, alamat, catatan;
   - supplier: nama, HP (dinormalisasi), kontak, kategori, alamat,
     catatan, termin.
   Isian awal dari kata pencarian Kasir (F1-04f) adalah keadaan awal,
   bukan perubahan. Mengetik lalu mengembalikan isian tidak dihitung.
2. Menutup dialog yang berubah lewat ketukan di luar dialog, Esc, tombol
   kembali sistem, atau tombol **Batal** menampilkan **Buang perubahan?**
   ("Pelanggan yang sedang diisi belum disimpan dan akan hilang." /
   "Supplier yang sedang diisi belum disimpan dan akan hilang.") dengan
   **Batal** (kembali ke dialog) dan **Buang** (tutup dialog). Dialog yang
   tidak berubah tertutup seperti biasa.
3. Selama *Simpan* berjalan, dialog tidak bisa ditutup kecuali oleh hasil
   simpan.
4. Dialog form tampil di navigator akar sehingga menutupi menu samping /
   bawah; staf harus menyimpan atau menutup dialog lebih dulu sebelum
   pindah menu.

## Rancangan teknis

- `CustomerFormViewModel` / `SupplierFormViewModel`: `hasUnsavedChanges`
  (daftar rata dibanding `listEquals` dengan salinan dari konstruktor) dan
  `busy` (`save.running`).
- `DiscardChangesScope` di `lib/ui/core/confirm_discard.dart`: `PopScope`
  dengan `canPop: !dirty && !busy`; saat pop ditolak dan tidak sibuk,
  tampilkan `confirmDiscardChanges` lalu `Navigator.pop()` bila Buang.
  Ketukan di luar dialog, Esc, dan tombol kembali sistem semuanya lewat
  `Navigator.maybePop`, jadi satu titik menutup semua jalan.
- Tombol **Batal** memanggil `maybePop` (bukan `pop`) agar ikut ditanyakan;
  simpan tetap `pop(hasil)`.
- `showCustomerForm` / `showSupplierForm` memakai
  `useRootNavigator: true` dan `barrierDismissible: false`. Penghalang
  bawaan Forui memanggil `Navigator.pop` langsung (melewati `PopScope`),
  jadi `TapOutsideToPop` memasang latar yang bisa diketuk (`maybePop`) di
  belakang `FDialog` dan memasang ulang Esc (`DismissIntent`), yang
  dimatikan rute bila `barrierDismissible` false.

- Ditemukan saat menguji: membuka *Ubah pelanggan* untuk pelanggan yang
  punya grup memicu galat `FSelect` (nilai awal di luar daftar) sebelum
  daftar grup selesai dimuat. Nilai awal kini kosong sampai grup itu ada di
  daftar; `FSelect` dibuat ulang setelah daftar dimuat.

## Pengujian

- VM: baru kosong, isian awal dari Kasir, ubah lalu kembalikan, HP beda
  format sama nomor, grup baru, limit, termin, sibuk saat simpan.
- Widget: ketuk di luar dialog / Batal pada dialog berubah → dialog
  konfirmasi; *Batal* tetap; *Buang* menutup; dialog tak berubah langsung
  tertutup; simpan menutup tanpa bertanya; menu samping tertutup dialog.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Dialog pelanggan & supplier bertanya sebelum isian dibuang | 1.20, 1.21 | Rilis v0.100.0 | Ketuk di luar, Esc, kembali sistem, Batal. |
| Simpan langsung dari dialog konfirmasi | — | Belum | Dialog hanya Batal / Buang. |
| Dialog lain (jenis pengeluaran, grup, pembayaran piutang/hutang) | — | Belum | Isiannya pendek; tetap tertutup tanpa bertanya. |
| Ketuk di area aman ponsel (status bar, takik, indikator beranda) | — | Diterima | Latar yang bisa diketuk berada di dalam `SafeArea` rute Forui; ketukan di tepi itu tidak menutup dialog. |
| Spasi di akhir isian | — | Diterima | Dihitung perubahan (hanya menambah satu pertanyaan). |
