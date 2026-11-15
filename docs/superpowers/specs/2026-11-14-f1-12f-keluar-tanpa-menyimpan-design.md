# F1-12f · Peringatan keluar dari form pembelian tanpa menyimpan

- **Fase:** 1
- **Status:** Rilis v0.97.0
- **Layar:** 1.19 form *Pembelian baru* / *Draf* (halaman sendiri dan panel
  samping daftar Pembelian di layar lebar).
- **Acuan:** gap "Peringatan saat keluar tanpa menyimpan tambahan" di
  [F1-08i](2026-11-14-f1-08i-tambah-ke-draf-design.md). Storeku tidak punya
  aturan ini; pola dialog mengikuti *Buang perubahan?* di editor denah
  (F1-10c).

## Masalah

Form pembelian bisa memuat banyak baris yang diketik satu per satu. Tombol
*Kembali*, tombol kembali sistem (Android), menu samping, atau memilih draf
lain di daftar langsung membuang isian tanpa bertanya. Draf yang dibuka dari
Stok minimum (F1-08i) bahkan sudah berisi tambahan yang belum tersimpan,
padahal staf mudah mengira tambahan itu sudah masuk draf.

## Aturan

1. Form dianggap **berubah** bila isiannya berbeda dari keadaan terakhir
   yang dimuat atau disimpan: supplier, supplier baru, no. faktur, tanggal,
   lokasi terima, baris (barang, satuan, jumlah, harga), diskon, ongkos
   kirim, bayar sekarang, sumber dana, jatuh tempo, catatan, dan foto
   faktur. Mengetik lalu mengembalikan isian ke semula tidak dihitung
   berubah.
2. Keadaan awal:
   - Pembelian baru kosong, atau terisi dari Stok minimum (F1-08c): isian
     setelah terisi otomatis. Isian otomatis bisa dibuat ulang dengan satu
     ketukan, jadi tidak ditanyakan.
   - Draf yang dibuka: isi draf di database. Tambahan dari Stok minimum
     (F1-08i) dihitung **berubah** karena belum tersimpan.
3. Setelah *Simpan draf* atau *Terima barang* berhasil, isian saat itu
   menjadi keadaan awal baru. Setelah *Hapus draf* berhasil, form boleh
   ditinggalkan tanpa bertanya.
4. Meninggalkan form yang berubah menampilkan dialog **Buang perubahan?**
   ("Perubahan pembelian {nomor} belum disimpan dan akan hilang.") dengan
   **Batal** (tetap di form) dan **Buang**, sama dengan dialog editor denah. Berlaku untuk:
   - tombol *Kembali* halaman dan tombol kembali sistem;
   - menu samping / bawah (pindah ke menu lain);
   - di daftar Pembelian layar lebar: memilih draf lain atau *Pembelian
     baru* saat panel form berubah, dan pindah menu.
5. Ganti kasir / keluar (staf bertugas hilang) tidak ditahan: perilaku
   lama, isian hilang.
6. Selama *Simpan draf* / *Terima barang* berjalan, keluar ditahan sampai
   selesai. Dialog menutupi seluruh layar (termasuk menu samping), dan
   navigasi kedua selama dialog terbuka tidak membuka dialog kedua.
7. Supplier baru yang diketik lalu dibatalkan, sumber dana tanpa bayar,
   dan jatuh tempo tanpa hutang tidak dihitung berubah (tidak tersimpan).
   Ubahan staf selama harga / supplier / foto otomatis dimuat tetap
   dihitung.

## Rancangan teknis

- `PurchaseFormViewModel.hasUnsavedChanges`: membandingkan `_signature()`
  (string isian aturan 1) dengan `_saved`. `_saved` diisi di `_load`
  (draf: setelah `_fill` + foto, sebelum tambahan stok minimum; baru:
  setelah isian stok minimum), setelah `_submit` berhasil, dan setelah
  `_deleteDraft` berhasil.
- `LeaveGuard` (`lib/ui/core/leave_guard.dart`): pemegang satu fungsi
  `Future<bool> Function()` per halaman rute. Router menyimpan satu guard
  per `state.pageKey` dan memasang `GoRoute.onExit` di rute
  `/pembelian`, `/pembelian/baru`, dan `/pembelian/:id`. go_router 18
  memanggil `onExit` untuk `pop`, tombol kembali sistem, dan `go` (menu
  samping), jadi satu titik menutup semua jalan keluar. `onExit` langsung
  mengizinkan bila tidak ada staf bertugas (aturan 5).
- Dialog editor denah dipindah ke `lib/ui/core/confirm_discard.dart`
  (`confirmDiscardChanges(context, body:, key:)`); denah memakai teksnya
  sendiri, pembelian memakai `purchaseDiscardBody`.
- Daftar Pembelian layar lebar: `_replaceForm` bertanya lebih dulu bila
  panel form berubah.

## Pengujian

- VM: baru (kosong / stok minimum) tidak berubah; ketik lalu kembalikan;
  tambah baris; foto faktur; draf dengan tambahan stok minimum berubah;
  simpan draf, terima, hapus draf mengembalikan ke tidak berubah.
- Widget (`purchase_flow_test.dart`): ponsel 360 px *Kembali* dan menu
  samping → dialog, *Batal* tetap di form, *Buang*
  keluar; form tanpa perubahan keluar tanpa dialog; layar lebar memilih
  draf lain → dialog; tombol kembali sistem.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Peringatan keluar dari form pembelian yang berubah | 1.19 | Rilis v0.97.0 | Kembali, tombol kembali sistem, menu samping, ganti draf di layar lebar. |
| Simpan draf langsung dari dialog | — | Belum | Dialog hanya Batal / Buang. |
| Peringatan saat ganti kasir | — | Belum | Isian hilang seperti sebelumnya. |
| Form produk | 1.16 | Rilis v0.98.0 | [F1-07q](2026-11-15-f1-07q-keluar-form-produk-design.md). |
| Pengeluaran | 1.22 | Rilis v0.99.0 | [F1-15c](2026-11-15-f1-15c-keluar-form-pengeluaran-design.md). |
| Draf penyesuaian stok | 1.18 | Rilis v0.104.0 | [F1-08k](2026-11-15-f1-08k-keluar-draf-penyesuaian-design.md). |
| Dialog pelanggan & supplier | 1.20, 1.21 | Rilis v0.100.0 | [F1-13e](2026-11-15-f1-13e-dialog-pelanggan-supplier-design.md). |
