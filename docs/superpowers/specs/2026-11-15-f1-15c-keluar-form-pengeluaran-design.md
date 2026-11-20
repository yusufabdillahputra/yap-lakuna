# F1-15c · Peringatan keluar dari layar Pengeluaran dengan isian belum disimpan

- **Fase:** 1
- **Status:** Rilis v0.99.0
- **Layar:** 1.22 Pengeluaran (form *Catat pengeluaran* di samping daftar,
  atau dialog di layar sempit).
- **Acuan:** gap "Form lain (pengeluaran, pelanggan, supplier)" di
  [F1-12f](2026-11-14-f1-12f-keluar-tanpa-menyimpan-design.md). Pola dan
  dialog sama dengan form pembelian (F1-12f) dan produk
  ([F1-07q](2026-11-15-f1-07q-keluar-form-produk-design.md)). Storeku tidak
  punya aturan ini.

## Masalah

Staf mengetik keterangan, nominal, dan memotret nota di form *Catat
pengeluaran*. Pindah menu sebelum menekan *Simpan* membuang semuanya
tanpa bertanya. Di layar sempit, isian dialog tetap tersimpan saat dialog
ditutup dengan *Batal* (dialog dibuka lagi masih berisi), tetapi hilang
saat staf pindah menu.

## Aturan

1. Form dianggap **berisi** bila keterangan (selain spasi), nominal
   (bukan Rp0), foto nota, atau tanggal selain hari ini sudah diisi.
   Jenis dan sumber dana **tidak** dihitung: keduanya tetap terpilih
   setelah *Simpan* (memudahkan mencatat beberapa pengeluaran sejenis),
   jadi bukan isian yang bisa hilang.
2. Setelah *Simpan* berhasil, form kosong lagi dan layar boleh
   ditinggalkan.
3. Meninggalkan layar Pengeluaran saat form berisi, lewat menu samping /
   bawah atau tombol kembali sistem, menampilkan **Buang perubahan?**
   ("Pengeluaran yang sedang diisi belum disimpan dan akan hilang.") dengan
   **Batal** dan **Buang**. Berlaku di layar lebar (form di samping) dan
   layar sempit (form di dialog yang sudah ditutup).
4. Membuka detail pengeluaran, mengubah periode, mencari, atau ekspor
   tidak meninggalkan layar, jadi tidak ditanyakan.
5. Selama *Simpan* atau pilih foto nota berjalan, keluar ditahan sampai
   selesai. Ganti kasir tidak ditahan.
6. Pengeluaran adalah halaman menu tingkat atas: memilih **Buang** setelah
   tombol kembali sistem menutup aplikasi (Android), sama seperti tombol
   kembali saat form kosong. Menu bawah yang diketuk saat dialog form
   masih terbuka juga ditanyakan; **Buang** menutup dialog dan layar.

## Rancangan teknis

- `ExpenseFormViewModel.hasUnsavedChanges` (aturan 1) dan `busy`
  (`save.running || pickReceipt.running`).
- Router: `onExit: formExit` + `leaveGuard: leaveGuards.of(state.pageKey)`
  di `/pengeluaran`; `ExpensesScreen` memasang `check` di `initState` /
  `didUpdateWidget` dan melepasnya di `dispose`. Dialog lewat
  `confirmDiscardChanges` (kunci `expense-discard`).

## Pengujian

- VM: kosong; keterangan spasi saja; nominal; foto; tanggal lain lalu
  kembali ke hari ini; jenis / sumber dana saja; setelah simpan.
- Widget (`expenses_flow_test.dart`): 1440 px isi lalu menu samping →
  dialog, *Batal* tetap, *Buang* keluar; tombol kembali sistem; form
  kosong keluar tanpa dialog; keluar ditahan selama simpan; 360 px isi
  dialog, *Batal* dialog, menu bawah → dialog; menu bawah saat dialog form
  terbuka.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Peringatan keluar dari Pengeluaran dengan isian belum disimpan | 1.22 | Rilis v0.99.0 | Menu samping / bawah, tombol kembali sistem. |
| Simpan langsung dari dialog | 1.21 | Rilis v0.122.0 | [F1-15d](2026-11-20-f1-15d-simpan-dari-dialog-pengeluaran-design.md). |
| Form pelanggan & supplier (dialog) | 1.20, 1.21 | Rilis v0.100.0 | [F1-13e](2026-11-15-f1-13e-dialog-pelanggan-supplier-design.md). |
| Tanggal hari ini yang dipilih manual lewat tengah malam | — | Diterima | Setelah muat ulang esok hari, tanggal itu menjadi kemarin dan dihitung berisi (menyimpan akan mencatat kemarin). |
