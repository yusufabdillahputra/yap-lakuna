# Rencana F1-04g · Diskon per baris di open bill F&B

Spec: `docs/superpowers/specs/2026-11-14-f1-04g-diskon-baris-open-bill-design.md`

## Langkah

- [x] Data: tes `bill_item_discount_test` (persen/rupiah, terlalu besar,
  izin + PIN manajer, penyetuju bertahan, ubah jumlah, tidak digabung,
  split persen / rupiah ditolak, porsi rupiah utuh, terkunci, bayar).
- [x] Data: `setBillItemDiscount`, `billItemDiscountOf`, `_withGross`
  dipakai `_repriced` dan porsi split, `BillItemDiscounted`, `addBillItem`
  tidak menggabung baris berdiskon, `sales.line_discount_amount` dan
  `tier_discount` dari total kotor, `_assertPayable` ikut diskon baris,
  penyetuju di `setBillDiscount` dan `mergeOpenBills`.
- [x] Repositori: `DiningRepository.setItemDiscount` (lokal + palsu).
- [x] VM: tes lalu `setItemDiscount`, `itemDiscountIssue`,
  `discountBlocksPay` ikut diskon baris.
- [x] View: tombol `dining-item-discount-*`, baris
  `dining-item-discount-line-*`, dialog `DiscountDialog` + PIN manajer,
  pesan `BillItemDiscounted` di split bill.
- [x] Tes widget 1280 px (setelah dapur, bayar, hapus), 360 px (pelayan +
  PIN), tanpa izin dan sakelar mati.
- [x] Uji penuh (format, analyze, domain/data/flutter).
- [x] Uji manual Xvfb: diskon baris 10% di meja M1 (pelanggan grup), bayar
  tunai, struk memuat *Discount 10% −4,950*, nota tersimpan dengan
  `line_discount_amount` 4.950 dan `tier_discount` 3.000.
- [x] Review subagent, perbaikan temuan (struk porsi split berdiskon,
  pembulatan saat dibagi, penyetuju usang, hapus tanpa PIN, persetujuan
  tidak terpakai saat hapus).
- [x] Dokumen rilis: spec status, README spec, STATUS-JEDA, spec F1-04b
  dan F1-04e gap, panduan, CHANGELOG 0.53.0, pubspec.
