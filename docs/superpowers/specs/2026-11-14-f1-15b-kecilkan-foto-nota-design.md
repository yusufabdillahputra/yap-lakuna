# F1-15b — Kecilkan foto nota pengeluaran dan bukti bayar supplier

- **Status:** Rilis v0.63.0
- **Layar:** 1.22 *Pengeluaran* (form, foto nota), 1.3b *Kas keluar*
  (catat sebagai pengeluaran + foto nota), 1.21 *Supplier* (bayar hutang,
  foto bukti).
- **Acuan:** gap [F1-07l](2026-11-14-f1-07l-kecilkan-foto-design.md)
  *Kecilkan foto nota pengeluaran / bukti bayar supplier*; spec
  [F1-15](2026-11-04-f1-15-pengeluaran-design.md) dan
  [F1-14](2026-11-04-f1-14-supplier-hutang-design.md).

## Tujuan

Foto nota belanja dan bukti transfer biasanya dipotret langsung dengan
kamera ponsel (3–10 MB). Sekarang foto di atas 5 MB ditolak. Lakuna
mengecilkannya otomatis seperti foto faktur pembelian (F1-07l), sehingga
foto kamera bisa langsung dipakai dan folder `media/` tetap kecil.

## Aturan

1. **Batas pilih 20 MB** untuk foto nota pengeluaran
   (`ExpenseLimits.receiptInputMaxBytes`) dan foto bukti bayar hutang
   supplier (`SupplierLimits.proofInputMaxBytes`). Berkas tetap harus PNG,
   JPG, atau WebP menurut isinya, paling banyak 50 MP menurut header.
2. **Ukuran simpan:** sisi terpanjang paling banyak **2.000 px**
   (`ExpenseLimits.receiptMaxSide`, `SupplierLimits.proofMaxSide`), sama
   dengan foto faktur agar angka dan tulisan tetap terbaca.
3. Format, orientasi EXIF, foto kecil dibiarkan, isolate terpisah, dan
   bingkai pertama animasi mengikuti `shrinkPhoto` F1-07l.
4. **Batas simpan tetap 5 MB** (`receiptMaxBytes`, `proofMaxBytes`).
   Gagal dekode, lebih dari 50 MP, atau hasil masih di atas 5 MB ditolak
   dengan pesan lama (`ExpenseReceiptInvalid`,
   `SupplierPaymentProofInvalid`).
5. Pratinjau foto di form (56 px) didekode kecil (`cacheWidth`) agar foto
   kamera 20 MB tidak memakan ratusan MB memori ponsel.
6. **Urutan:** isian dan izin diperiksa dulu, lalu foto dikecilkan, baru
   transaksi database dimulai. Foto tidak dikecilkan bila isian atau izin
   sudah gagal.
7. Berlaku juga untuk *Catat sebagai pengeluaran* di kas keluar sesi kasir
   (1.3b), yang memakai `recordExpense` yang sama.
8. Foto lama tidak diubah.

## Komponen

- `lakuna_domain`: `ExpenseLimits.receiptInputMaxBytes`,
  `ExpenseLimits.receiptMaxSide = 2000`,
  `SupplierLimits.proofInputMaxBytes`, `SupplierLimits.proofMaxSide = 2000`.
- `lakuna_data`: `recordExpense` dan `paySupplierDebt` memanggil
  `shrinkPhoto` sebelum `store.write`.
- Flutter: VM form pengeluaran, kas keluar sesi kasir, dan bayar hutang
  supplier memakai batas pilih 20 MB; teks galat id/en.

## Pengujian

- Data: nota 2400×4000 tersimpan 1200×2000 JPEG; bukti bayar sama; berkas
  di atas 20 MB atau > 50 MP ditolak; berkas rusak ditolak; foto kecil
  tersimpan apa adanya.
- Flutter: VM menerima foto 12 MB (di atas batas lama).
- Uji manual Xvfb: catat pengeluaran dengan foto kamera besar, cek ukuran
  di `media/`.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Kecilkan foto nota dan bukti bayar | 1.22, 1.3b, 1.21 | Rilis v0.63.0 | Selesai. |
| Kecilkan denah / QRIS / logo struk | — | Belum | Sengaja tidak: kode QR, garis denah, dan logo harus tajam. |
| Pesan khusus foto > 50 MP | — | Belum | Memakai pesan *maksimal 20 MB* / *bukan gambar*. |
