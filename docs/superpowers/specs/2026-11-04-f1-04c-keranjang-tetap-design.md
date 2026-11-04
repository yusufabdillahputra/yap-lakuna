# F1-04c · Keranjang tetap saat pindah menu

- **Fase:** 1
- **Status:** Rilis v0.28.1
- **Layar desain:** 1.4 Kasir, 1.11 Kasir mobile (tanpa perubahan tampilan).
- **Acuan:** spec [F1-04 Kasir retail](2026-11-03-f1-04-kasir-retail-design.md),
  [F1-04b Diskon manual](2026-11-04-f1-04b-diskon-manual-design.md).

## Masalah

`CashierViewModel` dibuat dan dibuang bersama layar Kasir. Kasir yang
membuka menu lain (mis. cek stok atau Beranda) lalu kembali menemukan
keranjang kosong, padahal pelanggan masih menunggu.

## Aturan

1. Keranjang kasir retail (bukan mode bill F&B) **tetap ada** selama staf
   yang sama bertugas, walau layar Kasir ditutup lalu dibuka lagi.
2. Yang disimpan: baris (varian, satuan konversi, jumlah, diskon baris),
   diskon nota, dan penyetuju diskon (F1-04b). Persetujuan tetap diperiksa
   ulang oleh repositori saat bayar; bila kedaluwarsa, alur galat F1-04b
   berlaku.
3. Saat dibuka lagi, baris dipetakan ke katalog terbaru: harga, nama, dan
   grosir ikut katalog; varian/satuan yang sudah dihapus atau nonaktif
   dibuang diam-diam. Tahap kembali ke *pilih produk* (bukan bayar).
4. Draf **dikosongkan** saat staf berganti (*Ganti kasir*, logout), sama
   seperti persetujuan diskon dihapus. Keranjang yang sudah dibayar tidak
   meninggalkan draf.
5. Mode bill (`?bill=`) tidak membaca dan tidak menulis draf: router dan
   `CashierScreen` sama-sama tidak memberi draf ke rute itu (view model
   baru tahu mode bill setelah `load`).
6. Keranjang yang **sedang disimpan** saat layar ditutup tidak ditulis ke
   draf: bila berhasil, notanya sudah tercatat dan tidak boleh muncul lagi
   (bayar dua kali); bila gagal, keranjang baru ditulis ke draf.
7. Draf hanya ditimpa setelah view model membacanya (`load` pertama
   berhasil). Layar yang ditutup sebelum katalog termuat, atau yang gagal
   memuat, tidak menghapus draf.
8. Draf hanya di memori: menutup aplikasi tetap mengosongkan keranjang.

## Arsitektur

- `lib/ui/cashier/cart_draft.dart`: `CartDraft` (objek biasa, umur =
  router) dengan `lines`, `billDiscount`, `approver`. Mendengarkan
  `SessionRepository` dan mengosongkan diri bila id staf bertugas berubah.
- `createRouter` membuat satu `CartDraft` dan meneruskannya ke
  `CashierScreen` hanya untuk rute kasir tanpa `bill`.
- `CashierViewModel({CartDraft? draft})`: setelah `load` pertama berhasil
  dan keranjang kosong, memulihkan dari draf lalu mengosongkan draf; saat
  `dispose`, menulis keranjang saat itu ke draf (kosong bila sudah dibayar).

## Pengujian

- Unit `CashierViewModel`: keranjang + diskon + penyetuju dipulihkan;
  produk dan satuan yang hilang dibuang; setelah bayar draf kosong; layar
  ditutup saat menyimpan (berhasil → draf kosong, gagal → draf berisi);
  `load` gagal tidak menghapus draf.
- Unit `CartDraft`: kosong saat staf berganti/logout, tetap saat profil
  staf sama dimuat ulang, `save` setelah logout diabaikan.
- Widget: Kasir → Beranda → Kasir, baris masih ada; bayar open bill lalu
  kembali ke Kasir, keranjang retail utuh.
- Manual (Xvfb): skenario yang sama.

## Status & gap

| Topik | Desain | Kode | Catatan |
| --- | --- | --- | --- |
| Keranjang tetap saat pindah menu | 1.4 | v0.28.1 | Hanya memori, per staf; dikosongkan saat Ganti kasir |
