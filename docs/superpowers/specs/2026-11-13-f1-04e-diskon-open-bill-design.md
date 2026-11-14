# F1-04e · Diskon nota di open bill F&B

- **Fase:** 1
- **Status:** Rilis v0.32.0
- **Layar:** 1.7 Meja (panel bill), 1.5 Pembayaran, 1.2b Persetujuan PIN
  manajer
- **Acuan:** F1-04b (diskon manual retail; aturan hitung, izin, dialog),
  F1-10 (open bill), F1-10c (split bill)
- **Menutup gap:** F1-04b "Diskon di open bill F&B / split bill"

## Tujuan

Pelayan atau kasir bisa memberi diskon untuk seluruh bill meja atau take
away (mis. tamu langganan, komplain makanan) dengan aturan yang sama dengan
diskon nota di Kasir retail: persen atau rupiah, staf tanpa izin
`sales:discount` meminta PIN manajer.

## Aturan

1. **Diskon nota saja.** Tombol *Diskon* di blok total panel bill membuka
   dialog *Diskon nota* yang sama dengan Kasir (persen / rupiah, pratinjau,
   *Hapus diskon*). Diskon per baris di bill belum (gap).
2. **Izin** sama dengan F1-04b: staf dengan `sales:discount` langsung;
   staf tanpa izin dan sakelar *Diskon manual butuh PIN manajer* hidup
   meminta persetujuan PIN (penyetuju dicatat); sakelar mati = tombol
   tidak muncul. Lapisan data memeriksa ulang lewat `requireDiscountActor`.
   Menghapus diskon boleh untuk staf yang bisa mengubah bill.
3. **Tersimpan di bill** (baris `sales` berstatus open): persen di
   `discount_bp`, rupiah yang diminta di `discount_amount` (`discount_bp`
   0), penyetuju di `discount_approved_by`. Tidak ada kolom baru.
4. **Hitung:** dasar = Σ total baris (setelah grosir dan modifier).
   Potongan = `ManualDiscount.cut(dasar)`: persen dibulatkan setengah ke
   atas dan mengikuti perubahan item; rupiah dipangkas ke dasar bila item
   berkurang. **Service dan PB1 dihitung dari dasar − potongan** (praktik
   umum restoran: pajak dari harga yang dibayar), lalu pembulatan total.
   `FnbCharges` mendapat field `discount`; total = subtotal − diskon +
   service + PB1 (bila tidak termasuk) + pembulatan.
5. **Batas:** saat menerapkan, total setelah diskon dan pembulatan harus
   > 0 (`DiscountTooLarge`). Bila item berkurang sampai total habis,
   *Tutup & bayar* dan bayar bagian menolak dengan `DiscountTooLarge` dan
   panel menampilkan pesan sampai diskon diubah.
6. **Split bill:** diskon ikut terbagi karena tagihan tiap tamu
   dialokasikan dari total bill. Menerapkan atau menghapus diskon ditolak
   bila bill sudah punya pembayaran bagian (`SplitLocked`).
7. **Selesai:** `_completeBill` menyimpan potongan efektif ke
   `discount_amount`, `discount_bp`, dan penyetuju; struk, riwayat,
   laporan, dan retur memakai kolom yang sama dengan retail sehingga tidak
   perlu diubah.
8. Tiket dapur tidak berubah (diskon tidak tampil di dapur).

## Komponen

- Domain: `fnbCharges(..., discount: ManualDiscount?)`, `FnbCharges.discount`.
- Data: `setBillDiscount(store, scope, staffId:, billId:, discount:,
  approverId:)` → `OpenBill`; `_charges` membaca diskon dari baris bill;
  `_completeBill` menulis potongan efektif; `OpenBill.discount` (pilihan
  tersimpan) dan `discountApprovedByName`.
- Repositori meja: `setDiscount(billId, discount, approverId)`; palsu.
- UI: tombol *Diskon* dan baris *Diskon 10% · disetujui Rina* di panel
  bill (1.7) dan ringkasan pembayaran (1.5).

## Pengujian

- Domain: service/PB1 dari dasar setelah diskon, PB1 termasuk, pembulatan,
  rupiah dipangkas.
- Data: terapkan (berizin, penyetuju, tanpa izin ditolak), total habis
  ditolak, hapus, persen mengikuti item, bayar menulis kolom diskon,
  split equal membagi total setelah diskon, terkunci setelah bayar bagian.
- VM / widget: tombol diskon, alur PIN, baris total di 1280 dan 360 px.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Diskon nota di open bill F&B | 1.7, 1.5 | Rilis v0.32.0 | Termasuk split bill dan kredit *Tutup & bayar*. |
| Diskon per baris di open bill | 1.7 | Rilis v0.53.0 | [F1-04g](2026-11-14-f1-04g-diskon-baris-open-bill-design.md). |
| Persetujuan ulang bila dasar diskon rupiah mengecil | — | Belum | Sama dengan keranjang Kasir: diskon rupiah tetap tercatat disetujui walau item berkurang (persentasenya naik). |
| Pemberi diskon tercatat | — | Belum | Staf berizin yang menerapkan tidak dicatat (`discount_approved_by` kosong); nota memakai staf penutup bill. |
| Persetujuan PIN Kasir dan Meja terpisah | — | Belum | Persetujuan sesi dikunci (penyetuju, izin); persetujuan diskon di Meja ikut memakai persetujuan diskon Kasir yang belum terpakai. |
