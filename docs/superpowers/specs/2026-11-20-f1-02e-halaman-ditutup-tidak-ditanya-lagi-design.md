# F1-02e · Halaman yang sedang ditutup tidak ditanya lagi

- **Fase:** 1
- **Status:** Rilis v0.119.0
- **Layar:** halaman berpenjaga (pembelian 1.19, rincian pembelian, produk
  1.15, pengeluaran, stok 1.18) + *Ganti kasir* dan tutup jendela.
- **Acuan:** gap *Halaman yang sedang ditutup ditanya lagi* di
  [F1-02b](2026-11-15-f1-02b-ganti-kasir-tanya-dulu-design.md).

## Masalah

Setelah **Buang** di *Buang perubahan?*, halaman (atau bingkai menu
setelah *Ganti kasir*) masih terpasang sesaat selama ditutup. *Ganti
kasir* atau tombol ✕ jendela di sela itu menanyakan halaman yang sama
sekali lagi, padahal isiannya sudah dibuang; dialog kedua bahkan bisa
tertinggal di atas layar masuk.

## Aturan

1. Halaman yang rutenya, atau rute yang memuatnya (bingkai menu
   `ShellRoute`), sudah dilepas dari navigator tidak bertanya lagi:
   penjaganya langsung mengizinkan.
2. Halaman yang tertutup halaman lain (mis. Stok di bawah form pembelian)
   tetap aktif dan tetap bertanya.
3. Halaman yang sedang menyimpan tetap menolak tanpa bertanya selama masih
   aktif (aturan F1-12f); setelah dilepas, simpan sudah selesai atau
   isiannya sudah dibuang.

## Rancangan teknis

- `leave_guard.dart`: `isRouteClosing(context)` menelusuri
  `ModalRoute.of(context)` lalu rute navigator di atasnya
  (`route.navigator.context`) dan bernilai benar bila salah satunya
  `!isActive`. Halaman go_router yang dihapus dari daftar halaman sudah
  tidak aktif walau widget-nya belum dibuang; rute yang beranimasi keluar
  (`popping`) juga tidak aktif.
- `_confirmLeave` di lima halaman berpenjaga: `if (!mounted ||
  isRouteClosing(context)) return true;` sebelum cek lain.
- Review subagent: Important — bingkai menu yang sedang ditutup setelah
  *Ganti kasir* lalu ✕ jendela masih bertanya, karena rute form di
  navigator bersarang tetap aktif → penelusuran rute leluhur. Minor:
  komentar `purchases_view` dipindah, tes halaman tertutup ditambah.

## Tes

- Unit (`leave_guard_test.dart`): halaman aktif → tidak; tertutup halaman
  lain → tidak; sedang di-pop → ya.
- Alur produk desktop: **Batal** → **Buang** → *Ganti kasir* selagi form
  ditutup → langsung layar masuk tanpa dialog kedua; *Ganti kasir* →
  **Buang** → tutup jendela selagi bingkai ditutup → `exit` tanpa dialog.
  Keduanya gagal tanpa perbaikan (mutasi).
- Uji manual Xvfb: pengeluaran berisi → *Ganti kasir* → **Buang** →
  `WM_DELETE_WINDOW` 50 ms kemudian → aplikasi keluar tanpa dialog kedua.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Halaman yang sedang ditutup tidak ditanya lagi | — | Rilis v0.119.0 | Diuji manual (Linux). |
