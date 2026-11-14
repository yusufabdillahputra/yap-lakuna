# F1-10h · Tarif beku saat split bill dibayar

- **Fase:** 1
- **Status:** Rilis v0.54.0
- **Layar:** 1.9 Split bill, 1.7 Meja (panel bill), 1.26 Pajak & service
- **Acuan:** F1-10 (split bill, gap *Split bill: tarif beku*), F1-18
  (pembulatan total), F1-04e/F1-04g (diskon open bill).
- **Menutup gap:** F1-10 "Split bill: tarif beku".

## Tujuan

Setelah tamu pertama membayar bagiannya, tagihan tamu lain tidak boleh
bergeser karena pemilik mengubah service, PB1, *harga sudah termasuk
pajak*, atau pembulatan total di tengah jalan. Selama ini tarif dibaca ulang
setiap bayar bagian, sehingga selisihnya ditanggung tamu terakhir.

## Aturan

1. **Beku saat bagian pertama dicatat.** Ketika `paySplitPart` mencatat
   pembayaran bagian pertama (lunas atau QRIS *menunggu*), tarif cabang saat
   itu disalin ke bill: `sales.service_bp`, `tax_bp`, `tax_inclusive`, dan
   kolom baru `sales.rounding_step` (kelipatan pembulatan 1/100/500).
2. **Penanda beku** = `rounding_step > 0` (kelipatan yang tidak dikenal
   tetap beku, tanpa pembulatan). Bill terbuka dengan penanda itu
   memakai tarif tersimpan di semua perhitungan (panel bill, layar Bayar
   bagian, bayar bagian berikutnya, konfirmasi QRIS, nota lunas). Bill lain
   tetap memakai tarif cabang terkini.
3. **Lepas beku** bila semua pembayaran bagian dibatalkan (QRIS menunggu
   yang dibatalkan dan tidak ada pembayaran lain): `rounding_step` kembali 0
   dan bill memakai tarif terkini lagi, sama seperti bill yang belum
   dibayar.
4. Selama beku, isi bill sudah terkunci (`SplitLocked`, F1-10c), jadi
   subtotal dan diskon tidak berubah; hanya tarif yang dibekukan.
5. Nota lunas mencatat tarif yang dipakai (`service_bp`, `tax_bp`,
   `tax_inclusive` seperti sebelumnya) dan `rounding_step`, untuk semua
   nota F&B, beku atau tidak.
6. **Tampilan:** panel bill dan layar Bayar bagian memakai label tarif
   tersimpan (mis. *Service 5%*), jadi angka di layar sama dengan yang
   ditagih. Tidak ada teks baru: bill sudah menampilkan *Split terkunci*.
7. Bayar penuh (`payOpenBill`) tetap ditolak selama ada pembayaran bagian
   (aturan lama); tarif beku dipakai di semua jalur penyelesaian bagian.

## Komponen

- Model: `Sale.roundingStep` (`int`, bawaan 0, `column=rounding_step`),
  migrasi `tarif-beku`.
- Domain: `TotalRounding.byStep(int)`.
- Data: `billRates(Sale, FnbRates live)` (tarif tersimpan bila beku),
  dipakai `_bills`, `_refreshTotals`, `setBillDiscount`,
  `setBillItemDiscount`, `paySplitPart`, `confirmSplitPayment`,
  `payOpenBill`, `setOpenBillCustomer`; `paySplitPart` membekukan,
  `cancelSplitPayment` melepas; `_completeBill` mengisi `rounding_step`.

## Pengujian

- Domain: `TotalRounding.byStep`.
- Data: bayar bagian A, ubah service/PB1/termasuk pajak/pembulatan →
  bill, bagian B, dan nota lunas memakai tarif lama; bill lain memakai tarif
  baru; QRIS menunggu juga membekukan; batal QRIS satu-satunya melepas beku
  (tarif baru berlaku); nota lunas mencatat `rounding_step`.
- Flutter: tidak ada perubahan UI selain angka; tes widget split yang ada
  tetap lulus.
- Uji manual Xvfb: split rata dua tamu, bayar A, ubah service di
  Pengaturan, kembali ke bill: total dan tagihan B tidak berubah.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Tarif beku split bill | — | Rilis v0.54.0 | Kolom `sales.rounding_step`. |
| Tarif beku untuk bill yang belum dibayar | — | Tidak direncanakan | Bill tanpa pembayaran mengikuti tarif terkini (harga di menu juga begitu). |
| Bill split lama (bagian lunas sebelum v0.54.0) | — | Terbatas | Tarif bagian lama tidak tersimpan; bill membeku dengan tarif saat bagian berikutnya dibayar. |
| Sinkronisasi Fase 2 | — | Catatan | Pembekuan menulis ulang baris `sales`; desain sync harus mencegah edit lama dari perangkat lain menimpa tarif beku. |
