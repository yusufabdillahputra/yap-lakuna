# F1-04i — Pemberi diskon open bill tercatat

- **Fase:** 1
- **Status:** Rilis v0.73.0
- **Layar:** 1.7 panel bill (Meja), 1.5 ringkasan pembayaran, 1.14
  Riwayat (detail nota).
- **Acuan:** gap [F1-04e](2026-11-13-f1-04e-diskon-open-bill-design.md)
  *Pemberi diskon tercatat*.

## Tujuan

Di open bill F&B, beberapa staf bisa melayani satu meja: pelayan memberi
diskon, kasir lain menutup bill. Sekarang staf berizin yang memberi diskon
tidak dicatat (`discount_approved_by` kosong), jadi nota hanya menunjukkan
staf penutup. Pemilik tidak bisa tahu siapa yang memberi diskon. Modul ini
mencatat pemberi diskon dan menampilkannya di Riwayat.

## Aturan

1. **Open bill:** saat staf yang punya izin `sales:discount` menerapkan
   diskon nota atau diskon baris, staf itu dicatat sebagai pemberi diskon
   (`discount_approved_by`). Bila staf tanpa izin memakai persetujuan PIN,
   penyetuju yang dicatat (sama seperti sebelumnya).
2. Aturan simpan yang lain tetap: pemberi terakhir yang menerapkan diskon
   menggantikan yang lama; menghapus semua diskon mengosongkannya; diskon
   baris yang masih ada mempertahankan pemberi lama ketika diskon nota
   dihapus (F1-04g).
3. **Kasir retail tidak berubah:** staf nota adalah staf yang memberi
   diskon, jadi kolom tetap kosong bila kasir berizin, dan berisi
   penyetuju bila memakai PIN.
4. **Riwayat (1.14):** ringkasan nota menampilkan baris *Diskon manual*
   (diskon baris + diskon nota) bila ada. Bila pemberi/penyetuju tercatat,
   labelnya *Diskon manual · disetujui Nama*.
5. Bill dan nota lama tidak diubah.
6. **Label panel bill (1.7) dan ringkasan pembayaran (1.5)** ikut
   menampilkan pemberi berizin: *Diskon nota 10% · disetujui Dimas*.
   Kata *disetujui* sengaja dipertahankan untuk pemberi sendiri: satu
   label yang sama di bill, pembayaran, dan Riwayat, dan staf penutup bill
   langsung tahu siapa yang bertanggung jawab atas diskon.

## Rancangan teknis

- `open_bill.dart`: `setBillDiscount` dan `setBillItemDiscount` memakai
  `approvedBy ?? staffId` bila diskon diterapkan.
- `history.dart`: `SaleDetail.discountApprovedByName` (nama dari
  `_names`), `SaleDetail.manualDiscount` (`lineDiscountAmount +
  discountAmount`).
- `history_detail.dart`: baris `history-discount` di kartu ringkasan.
- l10n: `historyManualDiscount`, `historyManualDiscountBy(name)`.

## Tes

- Data: staf berizin (pemilik/pelayan) memberi diskon nota dan baris →
  tercatat; dibayar staf lain → nota tetap mencatat pemberi; PIN →
  penyetuju; hapus → kosong. Kasir retail berizin tetap kosong.
- Data: `loadSaleDetail` mengisi nama pemberi dan total diskon manual.
- Widget: detail Riwayat menampilkan baris diskon dengan nama (1280/360).

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Pemberi diskon open bill tercatat | — | Rilis v0.73.0 | Juga tampil di panel bill dan ringkasan pembayaran. |
| Pemberi berbeda untuk diskon nota dan diskon baris | — | Belum | Satu kolom per nota: pemberi terakhir yang dicatat. |
