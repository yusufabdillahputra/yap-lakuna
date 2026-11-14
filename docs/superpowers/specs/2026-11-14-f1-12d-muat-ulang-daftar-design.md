# F1-12d · Daftar dimuat ulang setelah keluar dari detail lewat menu samping

- **Fase:** 1
- **Status:** Rilis v0.91.0
- **Layar:** 1.19 *Pembelian*, 1.20 *Pelanggan*, 1.21 *Supplier*, 1.10
  *Riwayat* (daftar dan detail yang dibuka di halaman sendiri).
- **Acuan:** gap [F1-08f](2026-11-14-f1-08f-buat-pembelian-macet-design.md)
  *Daftar Pembelian / Pelanggan / Supplier dimuat ulang setelah keluar dari
  detail lewat menu samping*. Storeku menampilkan detail di panel yang
  sama, jadi masalah ini khusus Lakuna.

## Masalah

Daftar Pembelian, Pelanggan, Supplier, dan Riwayat membuka detail (dan halaman
pembelian baru atau kuitansi) dengan `context.push`, lalu memuat ulang
daftar setelah halaman itu ditutup. Bila staf meninggalkan detail lewat
menu samping ke menu yang sama (mis. mengetuk *Pelanggan* saat detail
pelanggan terbuka), router membuang detail tanpa menyelesaikan `push`, dan
halaman daftar dipertahankan. Daftar tetap memperlihatkan data lama: status
pembelian yang baru diterima atau dihapus, piutang yang baru dibayar, hutang
supplier yang baru dilunasi, nota yang baru di-void atau dibuat kasir lain.

## Aturan

1. Saat halaman daftar kembali menjadi rute teratas lewat navigasi router
   sementara halaman yang dibukanya belum ditutup, daftar dimuat ulang.
   Pelanggan dan Supplier juga memuat ulang panel detail yang sedang
   terpilih (tata letak dua panel).
2. Alur normal tidak berubah: menutup halaman yang dibuka (Kembali, simpan,
   terima) tetap memuat ulang daftar seperti sebelumnya.
3. Saat halaman dibuka (push), daftar tidak dimuat ulang lebih awal.
4. Stok (F1-08f) memakai mekanisme yang sama; penjaga ketukan ganda
   *Buat pembelian* = tanda "sedang ditinggalkan".

## Rancangan teknis

- `lib/ui/core/route_return.dart`: `RouteReturnMixin` untuk `State`:
  - `whileAway(open)` menghitung halaman yang sedang terbuka sampai `open`
    selesai (ketukan ganda pada baris bisa membuka dua halaman; tanda baru
    lepas setelah keduanya ditutup);
  - `isAway` = hitungan > 0;
  - `didUpdateWidget` memanggil `onRouteReturn()` (lewat microtask, setelah
    frame) bila `isAway` dan `ModalRoute.isCurrentOf(context)`, lalu
    mengosongkan hitungan dan menaikkan epoch: future lama yang (mungkin)
    selesai belakangan tidak mengurangi hitungan halaman sesudahnya.
- `HistoryViewModel` tidak memberi tahu pendengar setelah dibuang (muat
  ulang yang masih berjalan saat staf pindah menu).
- `StockScreen` memakai mixin ini menggantikan `_restocking` /
  `_restockGen`.
- `PurchasesScreen` (`_open`, `_new`, `_received`), `CustomersScreen`
  (`_open`, `_received`), `SuppliersScreen` (`_open`, `_openPurchase`),
  `HistoryScreen` (`onOpenSale`) membungkus `push` dengan `whileAway`; `onRouteReturn` memuat ulang
  daftar (dan panel).

## Pengujian

- Widget: buka detail pembelian (1440 px), pelanggan, supplier, dan nota
  Riwayat (800 px); data berubah; ketuk menu samping yang sama → detail hilang dan
  daftar memuat data baru. Tes ini gagal sebelum perbaikan.
- Tes Stok F1-08f (keluar lewat menu, ketukan ganda) tetap lulus.
- Unit mixin (`test/ui/core/route_return_test.dart`, go_router nyata):
  tutup biasa tanpa `onRouteReturn`; kembali lewat `go` memanggilnya
  sekali; dua halaman terbuka; future lama setelah `go` tidak mengurangi
  hitungan halaman baru.
- Uji manual Xvfb: buka detail pelanggan di jendela sempit, kembali lewat
  menu samping.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Daftar dimuat ulang setelah keluar lewat menu samping | 1.10 / 1.19 / 1.20 / 1.21 | Rilis v0.91.0 | `RouteReturnMixin`, juga dipakai Stok. |
| Layar baru yang membuka halaman dengan `push` lalu memuat ulang | — | Aturan | Pakai `RouteReturnMixin` (`whileAway` + `onRouteReturn`). Produk (cetak label) tidak memuat ulang setelah `push`, jadi tidak perlu. |
