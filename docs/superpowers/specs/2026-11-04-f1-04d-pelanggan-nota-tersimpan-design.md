# F1-04d · Pelanggan & nota tersimpan di Kasir

- **Fase:** 1
- **Status:** Rilis v0.29.0
- **Layar desain:** 1.4b *Kasir: pelanggan, diskon manual, nota tersimpan*
  (tablet), 1.11 / 1.11b (mobile, tanpa layar baru).
- **Acuan Storeku:** `2026-11-02-f1-04-kasir-retail-design.md` (tombol
  *+ Pelanggan*, *Simpan (parkir)*: `sales` berstatus `open` tanpa meja,
  stok bergerak saat dibayar, harga dihitung ulang saat dilanjutkan).
- **Menutup gap:** F1-04 "Pilih pelanggan di kepala Kasir, nota
  tersimpan"; F1-04b dan F1-13 baris yang sama.

## Tujuan

Kasir bisa (1) memilih pelanggan untuk nota yang sedang dibuat, dan
(2) menyimpan nota yang belum dibayar agar bisa melayani pelanggan lain,
lalu melanjutkannya nanti.

## Aturan

### Pelanggan di kepala Pesanan

1. Kepala panel Pesanan menampilkan *Pelanggan umum* atau nama pelanggan
   terpilih, dengan tombol *+ Pelanggan* / *Ganti* dan *×* untuk kembali
   ke pelanggan umum.
2. Dialog *Pilih pelanggan*: cari nama atau HP; baris berisi nama, HP ·
   grup, *Sisa limit Rp …* (bila punya limit), lencana *Lewat tempo*.
   Data sama dengan pemilih kredit 1.5b.
3. Pelanggan terpilih ikut tersimpan di nota (`sales.customer_id` +
   `customer_name`) juga untuk nota tunai/non-kredit; struk menampilkan
   nama pelanggan. Nota non-kredit tidak menjadi piutang (dibayar penuh).
4. Mode *Kredit* di layar Bayar memakai pelanggan terpilih sebagai pilihan
   awal; memilih pelanggan di layar kredit juga mengganti pelanggan nota.
5. Lapisan data memeriksa pelanggan milik tenant dan belum dihapus.

### Nota tersimpan (parkir)

6. Tombol **Simpan** di samping *Bayar* (keranjang tidak kosong, bukan
   mode bill). Dialog *Simpan nota* dengan *Catatan* opsional (mis. "Meja
   depan"), terisi nama pelanggan bila ada.
7. Disimpan sebagai `sales` berstatus `open`, `order_type = retail`, tanpa
   meja, nomor bill `OB-…` (urutan yang sama dengan open bill F&B), beserta
   `sale_items` (harga saat disimpan), diskon baris dan nota, dan
   pelanggan. **Stok tidak bergerak** dan tidak ada pembayaran. Penyetuju
   diskon tidak ikut disimpan: saat dibayar, persetujuan diminta lagi bila
   staf tidak berizin.
8. Bilah atas Kasir: tombol **Nota tersimpan (N)** (N = nota tersimpan
   cabang ini). Membuka daftar: judul (pelanggan, catatan, atau *Tanpa
   nama*), "N item · disimpan HH.MM oleh X", total, **Lanjutkan**, dan
   **Hapus** (konfirmasi).
9. *Lanjutkan* memuat nota ke keranjang dengan harga dari katalog terbaru
   (barang yang sudah dihapus dibuang, ditandai di pesan). Hanya bisa bila
   keranjang kosong; bila tidak, tombol mati dengan petunjuk "Simpan atau
   kosongkan keranjang dulu".
10. Nota tersimpan **tetap ada** sampai dibayar: checkout dengan
    `parkedSaleId` menghapus (soft delete) nota tersimpan itu dalam
    transaksi yang sama. Menyimpan lagi keranjang yang berasal dari nota
    tersimpan menggantikan nota itu. Mengosongkan keranjang tidak menghapus
    nota tersimpan.
11. Nota tersimpan tidak muncul di Meja F&B, Riwayat, atau laporan, dan
    tidak menahan tutup sesi kasir (tanpa pembayaran).
12. Izin: `sales:create` untuk menyimpan, melanjutkan, dan menghapus.

## Arsitektur

- Data (`packages/lakuna_data/lib/src/parked_sales.dart`):
  `parkSale`, `listParkedSales`, `loadParkedSale`, `deleteParkedSale`;
  `checkoutSale(..., customerId, parkedSaleId)`.
- `CashierRepository`: `parkSale`, `parkedSales`, `loadParked`,
  `deleteParked`; `checkout` menerima `customerId` dan `parkedSaleId`.
- `CashierViewModel`: `customer` (+ `selectCustomer`/`clearCustomer`),
  `parkedId`, `park` (Command1 catatan), `parked` (Command0 daftar),
  `resumeParked` (Command1), `deleteParked` (Command1). `CartDraft` ikut
  menyimpan pelanggan dan `parkedId`.
- UI: `customer_picker.dart` (dialog), `parked_sales_sheet.dart`, tombol
  di `cashier_view.dart` (tablet) dan sheet keranjang mobile.

## Pengujian

- Data: simpan → stok tetap, nota `open` retail, tidak terlihat di open
  bill F&B; daftar; lanjutkan memuat baris; checkout dengan `parkedSaleId`
  menghapus nota tersimpan sekali saja; simpan ulang menggantikan; hapus;
  pelanggan di nota tunai (bukan piutang); pelanggan tenant lain ditolak.
- View model: pilih pelanggan → checkout membawa id; kredit memakai
  pelanggan terpilih; simpan → keranjang kosong; lanjutkan → keranjang
  terisi, checkout membawa `parkedSaleId`; draf membawa pelanggan.
- Widget: tablet dan 360 px: pilih pelanggan, simpan, buka daftar,
  lanjutkan, bayar.
- Manual (Xvfb) ID + EN.

## Status & gap

| Topik | Desain | Kode | Catatan |
| --- | --- | --- | --- |
| Pilih pelanggan di kepala Pesanan | 1.4b | Rilis v0.29.0 | Juga di nota non-kredit dan struk |
| Nota tersimpan (simpan, daftar, lanjutkan, hapus) | 1.4b | Rilis v0.29.0 | Diskon tanpa penyetuju: PIN saat Bayar, atau dilepas bila staf tak boleh diskon |
| *Pelanggan baru* dari pemilih Kasir | 1.4b | Belum | Tambah lewat menu Pelanggan |
| Harga grosir per grup pelanggan | 1.4b | Belum | Grup belum punya harga (butuh model harga per grup) |
