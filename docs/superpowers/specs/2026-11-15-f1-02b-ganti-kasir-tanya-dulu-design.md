# F1-02b · *Ganti kasir* bertanya dulu bila form belum disimpan

- **Fase:** 1
- **Status:** Rilis v0.110.0
- **Layar:** bilah atas semua layar (1.2 *Ganti kasir*), bersama form yang
  dijaga: Pembelian (1.20), Produk (1.15), Pengeluaran (1.22), draf
  penyesuaian stok (1.18).
- **Acuan:** gap "Peringatan saat ganti kasir" di
  [F1-12f](2026-11-14-f1-12f-keluar-tanpa-menyimpan-design.md) (aturan 5).
  Login dan ganti kasir: [F1-02](2026-11-03-f1-02-login-pin-design.md).

## Masalah

Sejak F1-12f / F1-07q / F1-15c / F1-08k, meninggalkan form yang berubah
lewat Kembali atau menu samping menampilkan *Buang perubahan?*. Tombol
**Ganti kasir** di bilah atas melewati pertanyaan itu: staf yang sedang
mengisi pembelian belasan baris lalu menekan *Ganti kasir* (mis. salah
ketuk, atau ingin berganti dulu) kehilangan seluruh isian tanpa
peringatan.

## Aturan

1. Menekan **Ganti kasir** menanyakan halaman yang sedang terbuka dengan
   pertanyaan yang sama seperti meninggalkannya lewat menu samping:
   - form tidak berubah: langsung kembali ke layar login (seperti
     sebelumnya);
   - form berubah: dialog **Buang perubahan?** dengan teks halaman itu
     (mis. "Perubahan pembelian PB-… belum disimpan dan akan hilang.").
     **Batal** tetap di form, staf tetap bertugas. **Buang** keluar ke
     layar login, isian hilang.
2. Bila beberapa halaman bertumpuk yang dijaga sama-sama berubah (mis.
   form pembelian samping di layar lebar lalu detail pembelian), halaman
   teratas ditanyakan lebih dulu; *Batal* di salah satunya membatalkan
   ganti kasir.
3. Selama *Simpan* / *Terima barang* berjalan di halaman mana pun yang
   dijaga (termasuk halaman di bawah halaman teratas), *Ganti kasir*
   diabaikan (sama dengan menu samping selama simpan); tekan lagi setelah
   selesai.
4. Ketukan *Ganti kasir* kedua selama dialog terbuka jatuh di latar dialog
   (sama dengan **Batal**): tidak membuka dialog kedua dan tidak keluar.
5. Keluar paksa (staf dihapus / dinonaktifkan dari perangkat lain,
   `refreshCurrent`) tidak ditanyakan: staf itu tidak boleh lagi
   bertugas.
6. Keranjang Kasir retail tetap dikosongkan saat staf berganti (F1-04c);
   keranjang tidak ditanyakan.

## Rancangan teknis

- `LeaveGuards.canLeaveAll()`: menanyakan semua guard yang masih terpasang
  (`check != null`), mulai dari yang terakhir dibuat (halaman teratas),
  berhenti pada jawaban `false`. Memakai `LeaveGuard.canLeave` sehingga
  pertanyaan yang sedang tampil dipakai ulang.
- `AppShell` menerima `Future<bool> Function()? canSwitch`; tombol *Ganti
  kasir* memanggil `session.logout()` hanya bila `canSwitch` menjawab
  `true`. Selama dialog terbuka layar login tertutup dialog, jadi staf
  lain tidak bisa masuk di sela pertanyaan; `logout()` kedua tidak
  berbuat apa-apa.
- `router.dart` meneruskan `leaveGuards.canLeaveAll`. `onExit` tetap
  melepas semua halaman setelah `session.current == null`, jadi tidak ada
  pertanyaan kedua setelah *Buang*.
- Tanpa kunci l10n baru: teks dialog milik tiap halaman.

## Pengujian

- Unit `LeaveGuards.canLeaveAll`: tanpa guard `true`; urutan teratas
  lebih dulu; berhenti pada `false`; guard yang dilepas dilewati.
- Widget: form pembelian berubah (desktop dan ponsel) → *Ganti kasir* →
  dialog; Batal tetap di form dengan isian; Buang → layar login. Form yang
  sudah disimpan langsung ke login. Produk dan Pengeluaran berubah juga
  bertanya. Ketukan kedua di latar dialog sama dengan Batal.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| *Ganti kasir* bertanya bila form berubah | 1.2 | Rilis v0.110.0 | `LeaveGuards.canLeaveAll`. |
| Keranjang Kasir / open bill ditanyakan saat ganti kasir | — | Belum | Keranjang retail sengaja dikosongkan per staf (F1-04c); open bill tersimpan. |
| Tutup aplikasi (jendela desktop) bertanya | — | Belum | Menutup jendela tetap membuang isian. |
| Pesan saat ganti kasir ditahan simpan | — | Belum | Tombol diam selama simpan berjalan (biasanya sesaat). |
| Halaman yang sedang ditutup ditanya lagi | — | Belum | Setelah *Buang* lewat Kembali, selama animasi keluar halaman masih terpasang; *Ganti kasir* di jeda itu bertanya sekali lagi. |
