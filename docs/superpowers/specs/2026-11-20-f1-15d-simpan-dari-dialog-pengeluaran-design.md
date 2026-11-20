# F1-15d · Tombol Simpan di dialog *Buang perubahan?* form pengeluaran

- **Fase:** 1
- **Status:** Rilis v0.122.0
- **Layar:** 1.21 Pengeluaran; dialog *Buang perubahan?* (F1-15c).
- **Acuan:** gap "Simpan langsung dari dialog" di
  [F1-15c](2026-11-15-f1-15c-keluar-form-pengeluaran-design.md); pola sama
  dengan form produk [F1-07r](2026-11-20-f1-07r-simpan-dari-dialog-produk-design.md).

## Masalah

Kasir yang sudah mengisi pengeluaran (mis. "Parkir Rp 5.000") lalu
mengetuk menu lain, **Ganti kasir**, atau ✕ jendela hanya bisa memilih
Batal atau Buang. Untuk mencatatnya ia harus kembali, menekan Simpan,
lalu mengulang navigasinya.

## Aturan

1. Dialog *Buang perubahan?* dari layar Pengeluaran punya tombol
   **Batal**, **Buang**, dan **Simpan** (tata letak dan urutan sama dengan
   F1-07r; di ponsel tersusun ke bawah, Simpan teratas).
2. **Simpan** menjalankan simpan yang sama dengan tombol Simpan form
   (validasi, foto nota, sumber dana laci). Bila berhasil, navigasi yang
   tertahan diteruskan (menu yang diketuk, layar masuk, atau aplikasi
   tertutup).
3. Bila simpan gagal karena isian (keterangan, jenis, jumlah, tanggal,
   saldo laci), kasir tetap di layar Pengeluaran dengan pesan di bawah
   isiannya. Di layar sempit, bila dialog form sedang tertutup, dialog form
   dibuka lagi agar pesannya terlihat.
4. Bila simpan ditolak penyimpanan (mis. sesi kasir sudah ditutup di
   perangkat lain), kasir tetap di layar dengan pesan galat simpan di form;
   layar memuat ulang setup seperti tombol Simpan form (`onFailed`). Di
   layar sempit dengan dialog form tertutup, dialog form dibuka lagi.
6. Bila simpan berhasil tetapi layar tetap tampil (tombol kembali Android
   di halaman tunggal), daftar dan saldo laci dimuat ulang seperti setelah
   tombol Simpan form; tidak dimuat bila halaman sedang ditutup.
5. Selama simpan berjalan, navigasi lain ditolak (`LeaveGuard.saving`,
   F1-07r).

## Rancangan teknis

- `ExpensesScreen._confirmLeave` memberi `onSave` ke
  `confirmDiscardChanges`: menyalakan `LeaveGuard.saving`, menjalankan
  `form.save.execute()`, lalu `true` bila `Ok`. `ExpenseInvalid` di layar
  sempit dengan dialog form tertutup membuka `_newDialog()` (juga untuk
  galat penyimpanan, yang selain itu memanggil `_list.refresh()`).
  Berhasil: `_list.refresh()` di callback pasca-frame bila
  `mounted && !isRouteClosing(context)`.
- Form pengeluaran sudah mengosongkan isiannya setelah simpan berhasil,
  jadi form yang tetap tampil (tombol kembali Android) tidak menyimpan dua
  kali.

## Pengujian

- `expenses_flow_test.dart` grup F1-15d: 1440 px menu lain → Simpan →
  tercatat dan layar Stok; isian kurang → tetap dengan pesan; galat
  penyimpanan → tetap; 360 px dialog form tertutup + isian kurang →
  dialog form terbuka lagi dengan pesan; 360 px dialog form terbuka →
  Simpan → tercatat dan Beranda; Ganti kasir → Simpan; kasus tepi: galat
  penyimpanan 360 px → dialog form terbuka dengan pesannya; isian kurang
  dengan dialog form terbuka → tetap satu dialog; menu lain selama simpan
  ditolak; ✕ jendela → Simpan → keluar.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Simpan dari dialog *Buang perubahan?* pengeluaran | 1.21 | Rilis v0.122.0 | `confirmDiscardChanges(onSave:)`. |
