# F1-04g · Diskon per baris di open bill F&B

- **Fase:** 1
- **Status:** Rilis v0.53.0
- **Layar:** 1.7 Meja (panel bill), 1.2b Persetujuan PIN manajer
- **Acuan:** F1-04b (diskon baris Kasir retail: dialog, aturan hitung,
  kolom `sale_items.discount_*`), F1-04e (diskon nota open bill), F1-10c
  (split bill).
- **Menutup gap:** F1-04b/F1-04e "Diskon per baris di open bill".

## Tujuan

Pelayan atau kasir bisa memotong harga satu item di bill meja atau take
away (mis. menu terlambat keluar, promo satu menu) tanpa mendiskon seluruh
bill, dengan aturan dan izin yang sama dengan diskon baris di Kasir retail.

## Aturan

1. **Tombol** *Diskon* (`dining-item-discount-<item>`, ikon persen) di
   setiap baris panel bill, untuk staf yang boleh menawarkan diskon
   (`sales:discount`, atau PIN manajer bila sakelar *Diskon manual butuh
   PIN manajer* hidup). Membuka dialog *Diskon baris* yang sama dengan
   Kasir (persen / rupiah, pratinjau, *Hapus diskon*); dasar = total baris
   sebelum diskon baris (harga × jumlah + modifier, setelah grosir).
   Berlaku untuk item *Baru*, *Di dapur*, maupun *Disajikan* (diskon soal
   harga, bukan dapur).
2. **Tersimpan di item** (`sale_items`, tanpa kolom baru):
   `discount_bp` = persen (0 untuk rupiah), `discount_amount` = potongan
   efektif, `line_total` = total kotor − potongan (sama dengan Kasir retail,
   sehingga struk, riwayat, laporan, dan retur tidak berubah).
3. **Hitung ulang** setiap kali baris dihitung ulang (ubah jumlah, harga
   grup pelanggan, gabung meja dengan pelanggan): persen mengikuti total
   baris (dibulatkan setengah ke atas), rupiah tetap tetapi dipangkas ke
   total baris bila jumlah berkurang.
4. **Izin dan penyetuju:** `requireDiscountActor` seperti diskon nota.
   Penyetuju dicatat di `sales.discount_approved_by` bill (satu kolom untuk
   diskon nota dan baris, sama dengan Kasir retail). Menghapus diskon nota
   tidak menghapus penyetuju selama masih ada baris berdiskon. Menghapus
   diskon baris boleh untuk staf yang bisa mengubah bill.
5. **Batas:** potongan rupiah tidak boleh melebihi total baris
   (`DiscountTooLarge`); total bill setelah semua diskon harus > 0.
6. **Gabung baris:** item baru tidak digabung ke baris yang berdiskon
   (menambah menu yang sama membuat baris baru tanpa diskon).
7. **Split bill:**
   - Terkunci setelah ada pembayaran bagian (`SplitLocked`), sama dengan
     diskon nota.
   - Split per item: baris berdiskon persen bisa dibagi (tiap porsi
     memakai persen yang sama); baris berdiskon **rupiah** tidak bisa
     dibagi (`BillItemDiscounted`, pesan *Hapus atau ubah diskon rupiah
     item ini ke persen sebelum dibagi.*).
8. **Tampilan:** di bawah nama item tampil *Diskon 10%* / *Diskon* dengan
   potongan (−Rp…); harga kanan adalah total bersih.
9. Diskon nota (F1-04e) dihitung dari Σ total baris bersih.

## Komponen

- Data: `setBillItemDiscount(store, scope, staffId:, itemId:, discount:,
  approverId:)` → `OpenBill`; `billItemDiscountOf(SaleItem)`;
  `_netLine` (kotor → bersih + potongan) dipakai `addBillItem`,
  `_repriced`, dan pemecahan porsi split; `BillItemDiscounted`.
- Repositori meja: `setItemDiscount(itemId, discount, approverId)`; palsu.
- VM meja: `setItemDiscount` (`Command1`), `itemDiscountIssue(item, d)`.
- UI: tombol dan baris diskon di `_BillItemRow`, dialog `DiscountDialog`.

## Pengujian

- Data: terapkan persen/rupiah (line_total, kolom), terlalu besar ditolak,
  tanpa izin ditolak / PIN manajer, ubah jumlah (persen ikut, rupiah
  dipangkas), menu sama tidak digabung ke baris berdiskon, hapus diskon,
  penyetuju bertahan saat diskon nota dihapus, split persen dibagi /
  rupiah ditolak, terkunci setelah bayar bagian, bayar → nota memuat
  kolom diskon baris.
- VM/widget: tombol diskon baris, dialog, baris diskon tampil (1280 dan
  360 px), staf tanpa izin dan sakelar mati tidak melihat tombol.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Diskon per baris di open bill | 1.7 | Rilis v0.53.0 | Tombol persen di baris panel bill. |
| Bagi baris berdiskon rupiah per tamu | — | Belum | Ubah ke persen atau hapus diskon dulu. |
