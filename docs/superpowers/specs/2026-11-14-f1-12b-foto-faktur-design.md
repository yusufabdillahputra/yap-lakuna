# F1-12b · Foto faktur pembelian

- **Fase:** 1
- **Status:** Dalam pengerjaan (v0.50.0)
- **Layar:** 1.19 form pembelian (lampiran di bawah *No. faktur supplier*),
  1.19b detail pembelian (baris *Foto faktur* dengan *Lihat foto faktur*).
- **Acuan:** gap *Foto faktur* di F1-12 (tombol *Lihat foto faktur* di
  kanvas 1.19b) dan Storeku F1-12 ("foto faktur disimpan di `media`").
  Pola sama dengan foto nota pengeluaran (F1-15) dan foto produk (F1-07f).
- **Menutup gap:** F1-12 "Foto faktur".

## Tujuan

Pemilik menyimpan foto faktur supplier bersama pembelian, agar saat
mencocokkan hutang atau harga beli tidak perlu mencari kertas fakturnya.

## Aturan

1. **Satu foto per pembelian**: kolom baru `purchases.invoice_media_id` →
   `media_files` (`MediaKind.purchaseInvoice`, `outlet_id` = cabang
   pembelian). Migrasi `foto-faktur`.
2. **Berkas**: PNG, JPG, atau WebP sampai 5 MB
   (`PurchaseLimits.invoicePhotoMaxBytes`, sama dengan foto nota
   pengeluaran), diperiksa dari isi berkas (`readImageHeader`). Di
   Android/iOS ada *Ambil foto* dari kamera. Berkas disimpan di
   `media/<sha256>.<ext>`; berkas yang sama tidak disalin dua kali.
   Berkas tidak didukung atau terlalu besar → pesan *Foto harus PNG, JPG,
   atau WebP maksimal 5 MB* di bawah lampiran; isian lain tetap.
3. **Form 1.19** (pembelian baru dan draf): `PhotoAttachField` *Foto
   faktur* di bawah *No. faktur supplier* (pilih berkas, kamera,
   pratinjau, hapus). Foto ikut tersimpan **dalam transaksi yang sama**
   dengan *Simpan draf* atau *Terima barang & simpan*
   (`PurchaseRequest.invoicePhoto`). Draf yang sudah punya foto
   menampilkan pratinjaunya; menghapusnya lalu menyimpan mengosongkan
   kolom (`PurchaseRequest.removeInvoicePhoto`), tidak menyentuh foto =
   foto lama tetap.
4. **Detail 1.19b** (pembelian diterima): baris *Foto faktur* di kartu
   info.
   - Ada foto: gambar kecil yang bisa diketuk + tombol *Lihat foto faktur*
     membuka foto layar penuh yang bisa diperbesar.
   - Belum ada foto: teks *Belum ada foto faktur*.
   - Foto tercatat tetapi berkasnya belum ada di perangkat ini (mis. baru
     tersinkron): *Foto faktur belum ada di perangkat ini*.
   - Staf ber-izin `purchases:manage` bisa *Lampirkan foto* / *Ganti
     foto* (berkas atau kamera) dan *Hapus foto*. Mengubah foto tidak
     mengubah stok, HPP, kas, atau hutang, jadi boleh untuk pembelian
     yang sudah diterima (`setPurchaseInvoicePhoto`,
     `clearPurchaseInvoicePhoto`, versi dokumen naik, tercatat di outbox).
5. Retur beli, hapus draf, dan pembayaran hutang tidak mengubah foto.
   Backup sudah membawa folder `media/`.
6. Izin: membaca dan mengubah foto memakai izin layar pembelian
   (`purchases:manage`), dicek di repositori dan di data.

## Komponen

- Server model: `Purchase.invoiceMediaId`, `MediaKind.purchaseInvoice`;
  migrasi `foto-faktur`.
- Domain: `PurchaseLimits.invoicePhotoMaxBytes`.
- Data: `PurchaseInvoicePhoto` (bytes + nama), `PurchaseRequest.invoicePhoto`
  / `removeInvoicePhoto`, `PurchaseInvoicePhotoInvalid`,
  `setPurchaseInvoicePhoto`, `clearPurchaseInvoicePhoto`,
  `loadPurchaseInvoicePhoto`.
- Flutter: `PurchasesRepository.invoicePhoto/setInvoicePhoto/
  clearInvoicePhoto`; `PurchaseFormViewModel` (`pickInvoicePhoto`,
  `removeInvoicePhoto`, pratinjau draf); `PurchaseDetailViewModel`
  (`invoicePhoto`, `attachInvoicePhoto`, `removeInvoicePhoto`); router
  memberi `ImageFilePicker`.

## Pengujian

- Data: simpan draf dengan foto (baris media + outbox), ubah draf tanpa
  menyentuh foto (tetap), hapus foto lewat draf, terima dengan foto,
  berkas bukan gambar / terlalu besar → `PurchaseInvoicePhotoInvalid`,
  set/clear untuk pembelian diterima (versi naik), cabang lain →
  `PurchaseNotFound`, staf tanpa izin ditolak.
- Flutter: VM form (pilih → request membawa foto, hapus foto draf →
  `removeInvoicePhoto`, berkas ditolak), VM detail (muat foto, lampirkan,
  hapus, galat), widget 1280/360 px.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Foto faktur di form dan detail pembelian | *Lihat foto faktur* (1.19b) | Dalam pengerjaan | — |
| Lebih dari satu foto per faktur | — | Belum | Faktur berlembar banyak: satu foto dulu (bisa foto berdampingan). |
| Kecilkan foto ke WebP | Storeku F1-07 | Belum | Sama dengan foto produk; batas 5 MB + kamera 2.400 px. |
