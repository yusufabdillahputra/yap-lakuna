# F1-08m — Supplier terakhir mengabaikan barang yang seluruhnya diretur

- **Fase:** 1
- **Status:** Rilis v0.114.0
- **Layar:** 1.18 *Stok* › *Stok minimum* › **Buat pembelian** → 1.19
  form pembelian baru.
- **Acuan:** gap [F1-08d](2026-11-14-f1-08d-supplier-terakhir-design.md)
  *Abaikan pembelian yang seluruh barangnya diretur*.

## Tujuan

**Buat pembelian** memilih supplier dari pembelian terakhir setiap barang
(F1-08d). Bila barang dari pembelian itu diretur semuanya ke supplier,
misalnya karena rusak, salah kirim, atau kedaluwarsa, toko sebenarnya
tidak jadi membeli barang itu dari sana. Sekarang supplier itu tetap
dipilih, sehingga staf harus menggantinya sendiri setiap kali.

## Aturan

1. Baris pembelian yang **seluruh jumlahnya sudah diretur** (jumlah retur
   `RB-` yang belum dihapus ≥ jumlah baris, dalam satuan baris) tidak
   dihitung saat mencari supplier terakhir barang itu.
2. Pembelian tetap dihitung untuk barang itu bila masih ada baris lain
   untuk barang yang sama yang belum diretur seluruhnya (mis. baris dus
   diretur penuh, baris pcs tidak).
3. Retur sebagian tidak mengubah apa pun: pembelian itu tetap pembelian
   terakhir.
4. Bila semua pembelian barang itu diretur penuh, barang dianggap belum
   punya riwayat supplier (tidak ikut dihitung pada pilihan supplier
   form, aturan 2 F1-08d).
5. Harga beli terakhir (F1-08e, F1-12g, F1-12h) **tidak** berubah: harga
   pada pembelian yang diretur tetap harga yang ditawarkan supplier itu.
   Saat supplier dipilih, harga diambil dari pembelian supplier tersebut
   (F1-12g), jadi supplier dan harga tetap sejalan. Bila supplier terpilih
   belum pernah menjual barang itu, harga jatuh ke harga terakhir dari
   semua supplier (F1-12g), yang bisa berasal dari pembelian yang diretur
   penuh.

## Rancangan teknis

- `lakuna_data` `lastSuppliersOf`: setelah membaca pembelian diterima,
  membaca returnya lewat `purchaseReturnsOf` (per 500 pembelian, retur
  terhapus dilewati, memakai indeks `purchase_returns_purchase_idx`) lalu
  `_returnedMilliOf` (jumlah `quantity_milli` per `purchase_item_id`),
  sama dengan yang dipakai `returnPurchase`. Baris yang jumlah returnya ≥
  `quantity_milli` baris dilewati.
- Tidak ada perubahan skema, UI, atau teks.

## Tes

- Data: pembelian gula terbaru dari *Toko Gula Jaya* diretur 2 dari 5 →
  supplier terakhir tetap *Toko Gula Jaya*; sisa 3 ikut diretur →
  kembali ke *CV Sumber Pangan*. Minyak (satu-satunya pembelian, 4 dus)
  diretur 4 dus → tidak ada di peta.
- Data: barang dengan dua baris di pembelian yang sama (dus diretur penuh,
  pcs tidak) → pembelian itu tetap dihitung.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Supplier terakhir tanpa barang yang diretur penuh | — | Rilis v0.114.0 | — |
| Abaikan harga dari baris yang diretur penuh | — | Belum | Sengaja tidak (aturan 5); ubah bila pemilik ingin harga retur tidak dipakai. |
