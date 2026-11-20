# F1-08k · Peringatan keluar dari layar Stok dengan draf penyesuaian

- **Fase:** 1
- **Status:** Rilis v0.104.0
- **Layar:** 1.18 Stok › tab *Penyesuaian* (kartu *Penyesuaian stok baru*),
  pilihan lokasi di kepala layar.
- **Acuan:** pola dan dialog sama dengan form pembelian
  ([F1-12f](2026-11-14-f1-12f-keluar-tanpa-menyimpan-design.md)), produk
  ([F1-07q](2026-11-15-f1-07q-keluar-form-produk-design.md)), dan
  pengeluaran ([F1-15c](2026-11-15-f1-15c-keluar-form-pengeluaran-design.md)).
  Storeku tidak punya aturan ini.

## Masalah

Saat stok opname, staf menambahkan puluhan produk ke draf penyesuaian dan
mengisi jumlah fisik satu per satu. Draf hanya hidup di layar Stok:

- pindah menu (menu samping / bawah, tombol kembali sistem) membuang
  seluruh draf tanpa bertanya;
- mengganti **lokasi** di kepala layar juga mengosongkan draf tanpa
  bertanya, padahal pilihan lokasi ada di samping tab dan mudah tersentuh.

## Aturan

1. Draf dianggap **berisi** bila ada minimal satu baris produk (sudah
   diisi fisiknya atau belum: memilih barang yang akan dihitung juga
   pekerjaan) atau catatan umum selain spasi. *Alasan umum* saja tidak
   dihitung (selalu ada nilainya dan tidak bisa disimpan tanpa baris).
2. Setelah *Simpan penyesuaian* berhasil atau *Batal* ditekan, draf kosong
   dan layar boleh ditinggalkan tanpa bertanya.
3. Meninggalkan layar Stok saat draf berisi, lewat menu samping / bawah
   atau tombol kembali sistem, menampilkan **Buang perubahan?** ("Draf
   penyesuaian stok yang sedang diisi belum disimpan dan akan hilang.")
   dengan **Batal** dan **Buang**. Berlaku di tab mana pun (draf tetap
   hidup saat berpindah tab).
4. Mengganti lokasi saat draf berisi menampilkan dialog yang sama dengan
   teks "Draf penyesuaian untuk lokasi ini akan dikosongkan bila lokasi
   diganti." **Batal** mempertahankan lokasi dan draf (pilihan lokasi
   kembali ke lokasi semula); **Buang** mengganti lokasi dan mengosongkan
   draf seperti sebelumnya. Selama simpan berjalan, pilihan lokasi kembali
   ke lokasi semula tanpa dialog (sama dengan keluar yang ditahan).
5. Membuka form pembelian dari *Stok minimum*, kartu stok, atau tab lain
   tidak meninggalkan layar Stok (halaman tetap di bawah), jadi tidak
   ditanyakan; draf masih ada saat kembali.
6. Selama *Simpan penyesuaian* berjalan, keluar ditahan sampai selesai.
   Ganti kasir tidak ditahan (sama dengan form lain).
7. Staf tanpa izin `stock:adjust` tidak punya draf, jadi tidak pernah
   ditanya.

## Rancangan teknis

- `StockViewModel.hasUnsavedChanges` (aturan 1, `canAdjust` saja) dan
  `busy` (`save.running`).
- Router: `onExit: formExit` + `leaveGuard: leaveGuards.of(state.pageKey)`
  di `/stok`. `StockScreen` memasang `check` di `initState` /
  `didUpdateWidget` dan melepasnya di `dispose`, lewat
  `confirmDiscardChanges` (kunci `stock-discard`).
- `_LocationSelect` bertanya lewat `confirmDiscardChanges` (kunci
  `stock-location-discard`) sebelum `selectLocation`; bila batal, kunci
  `FSelect` memakai revisi baru agar kembali ke lokasi semula.
- Perbaikan `LeaveGuards.of`: sebelumnya semua guard lain yang `check`-nya
  `null` dibuang, termasuk guard halaman yang baru dibuat dan belum sempat
  memasang `check`. Begitu `/stok` ikut meminta guard, form pembelian yang
  didorong dari Stok (dua halaman dibangun dalam satu frame) kehilangan
  guard-nya. Kini `LeaveGuard` mencatat apakah `check` pernah dipasang,
  dan hanya guard yang sudah dipasang lalu dilepas yang dibuang
  (termasuk guard lama dengan `pageKey` yang sama, agar halaman yang
  dibuka lagi mendapat guard baru).

## Pengujian

- VM: kosong; baris tanpa fisik; catatan spasi saja; catatan; alasan saja;
  setelah simpan; setelah *Batal*; tanpa izin.
- Widget (`stock_flow_test.dart`): 1280 px tambah baris lalu menu samping
  → dialog, *Batal* tetap, tombol kembali sistem, *Buang* keluar; draf
  kosong keluar tanpa dialog; keluar ditahan selama simpan; ganti lokasi
  dengan draf → *Batal* tetap di lokasi lama dengan draf, *Buang* pindah
  dan draf kosong; ganti lokasi tanpa draf tanpa dialog; 360 px menu bawah;
  draf tetap ada setelah membuka form pembelian dari *Stok minimum* lalu
  kembali lewat menu samping (aturan 5).
- Unit `test/ui/core/leave_guard_test.dart`: guard baru tetap ada walau
  halaman lain meminta guard lebih dulu; guard yang dilepas dibuang.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Peringatan keluar dari Stok dengan draf penyesuaian | 1.18 | Rilis v0.104.0 | Menu samping / bawah, tombol kembali sistem. |
| Peringatan ganti lokasi dengan draf penyesuaian | 1.18 | Rilis v0.104.0 | *Batal* mempertahankan lokasi dan draf. |
| Simpan draf penyesuaian untuk dilanjutkan nanti | — | Belum | Draf hanya hidup selama layar Stok terbuka. |
| Simpan langsung dari dialog | 1.18 | Rilis v0.123.0 | [F1-08n](2026-11-20-f1-08n-simpan-dari-dialog-penyesuaian-design.md): keluar dan ganti lokasi. |
| Dua dialog berturut-turut | — | Belum | Form pembelian berisi yang dibuka dari Stok berdraf, lalu menu samping: dialog form pembelian lalu dialog Stok. *Batal* di dialog kedua tetap di form pembelian dengan isiannya utuh. |
