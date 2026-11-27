# F1-12m · Beberapa foto per faktur pembelian

- **Fase:** 1
- **Status:** Rilis v0.160.0
- **Layar:** form *Pembelian baru* / *Draf* (1.19, lampiran *Foto faktur*),
  rincian pembelian (1.19b, kartu *Foto faktur*).
- **Acuan:** gap 23 di `GAP-FASE1.md` dan gap
  [F1-12b](2026-11-14-f1-12b-foto-faktur-design.md) *Lebih dari satu foto
  per faktur*. Storeku F1-12 menyimpan foto faktur di `media` tanpa batas
  jumlah lembar.

## Masalah

Faktur supplier sering lebih dari satu lembar (faktur grosir 2–3 halaman,
atau faktur + surat jalan). F1-12b hanya menyimpan satu foto per
pembelian, sehingga pemilik harus memotret beberapa lembar berdampingan
dalam satu foto yang hasilnya sulit dibaca.

## Aturan

1. Satu pembelian menyimpan **sampai 5 foto faktur**
   (`PurchaseLimits.invoicePhotoMaxCount`), urut sesuai urutan dilampirkan.
   Batas tiap foto tetap seperti F1-12b/F1-07l (pilih sampai 20 MB,
   dikecilkan ke JPEG 2.000 px, simpan maksimal 5 MB).
2. **Data**: foto pertama tetap di `purchases.invoice_media_id` (pembelian
   lama tidak perlu dipindah). Foto ke-2 dan seterusnya di tabel baru
   `purchase_invoice_pages` (`purchase_id`, `media_id`, `position` 2..5
   berurutan tanpa celah, kolom sync lengkap, hapus lunak). Migrasi
   `foto-faktur-lembar`. Menghapus foto pertama menaikkan foto kedua ke
   `invoice_media_id`; posisi lembar disusun ulang.
3. Semua perubahan foto ditulis **dalam satu transaksi** bersama dokumen
   pembelian (versi dokumen naik), tercatat di outbox. Lembar yang posisinya
   tidak berubah tidak ditulis ulang; lembar yang tidak dipakai lagi
   dihapus lunak.
4. Foto yang sama (hash sama) tidak tersimpan dua kali di satu pembelian:
   foto kembar diabaikan. Daftar foto yang tidak berubah tidak menulis ulang
   dokumen.
5. **Form 1.19**: *Foto faktur* menampilkan deretan gambar kecil (setiap
   gambar bisa diketuk untuk dilihat layar penuh dan punya tombol hapus),
   lalu *Tambah foto* (berkas) dan *Ambil foto* (kamera, Android/iOS)
   selama foto kurang dari 5, dan keterangan *2 dari 5 foto*. Foto
   tersimpan bersama *Simpan draf* / *Terima barang & simpan*. Foto draf
   yang berkasnya belum ada di perangkat ini tampil sebagai kotak *Belum
   ada di perangkat ini* yang tetap bisa dihapus.
6. **Detail 1.19b**: kartu *Foto faktur* menampilkan deretan gambar kecil
   (ketuk = layar penuh, keterangan *Foto 2 dari 3*), *Lihat foto faktur*
   membuka foto pertama, *Tambah foto* / *Ambil foto* selama kurang dari 5
   (staf `purchases:manage`). Setiap gambar punya tombol hapus dengan
   konfirmasi *Hapus foto faktur?*. Mengubah foto tidak mengubah stok, HPP,
   kas, atau hutang, jadi boleh untuk pembelian yang sudah diterima.
7. Foto ke-6 ditolak dengan pesan *Paling banyak 5 foto per faktur*
   (`PurchaseInvoicePhotoLimit`); foto yang sudah ada tetap.
8. Izin, cabang, dan tenant sama dengan F1-12b. Lembar milik pembelian
   cabang lain tidak pernah dimuat.
9. API F1-12b tetap: `PurchaseRequest.invoicePhoto` (ganti semua foto dengan
   satu foto), `removeInvoicePhoto` (kosongkan semua), `setPurchaseInvoicePhoto`
   (ganti semua dengan satu), `clearPurchaseInvoicePhoto` (kosongkan semua),
   `loadPurchaseInvoicePhoto` (isi foto pertama).

## Komponen

- Server model: `PurchaseInvoicePage` (`purchase_invoice_pages`), migrasi
  `foto-faktur-lembar`.
- Domain: `PurchaseLimits.invoicePhotoMaxCount = 5`.
- Data: `PurchaseInvoicePhotoSlot` (`KeepInvoicePhoto(mediaId)` /
  `AddInvoicePhoto(photo)`), `PurchaseRequest.invoicePhotos` (`null` = tidak
  diubah), `PurchaseDetail.invoiceMediaIds`, `addPurchaseInvoicePhoto`,
  `removePurchaseInvoicePhoto(mediaId)`, `loadPurchaseInvoicePhotos` →
  `PurchaseInvoicePhotoFile(mediaId, bytes?)`, `PurchaseInvoicePhotoLimit`.
- Flutter: `PurchasesRepository.invoicePhotos/addInvoicePhoto/
  removeInvoicePhoto`; `PurchaseFormViewModel.invoicePhotos` (daftar
  `InvoicePhotoDraft`), `pickInvoicePhoto`, `removeInvoicePhotoAt`;
  `PurchaseDetailViewModel.invoicePhotos`, `attachInvoicePhoto`,
  `removeInvoicePhoto(mediaId)`; widget `InvoicePhotoStrip`;
  `showPhotoViewer(title:)`.

## Pengujian

- Data: simpan draf dengan 3 foto (1 di dokumen + 2 lembar, outbox), ubah
  draf tanpa menyentuh foto, hapus foto pertama (lembar 2 naik, posisi
  rapat), foto kembar diabaikan, foto ke-6 ditolak, tambah/hapus pada
  pembelian diterima (versi naik), muat daftar (berkas hilang = `bytes`
  kosong), cabang lain tidak terlihat, API lama tetap (ganti satu =
  lembar dihapus lunak).
- Flutter: VM form (tambah 2 foto → request membawa slot, hapus salah
  satu, batas 5, draf dimuat dengan foto), VM detail (muat daftar, tambah,
  hapus per foto, batas), widget 1280/360 px.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Sampai 5 foto per faktur di form dan detail | — | Rilis v0.160.0 | Foto pertama di dokumen, lembar berikutnya di `purchase_invoice_pages`. |
| Ubah urutan foto | — | Belum | Urutan = urutan dilampirkan; hapus lalu lampirkan ulang untuk mengubah. |
| Lampirkan beberapa berkas sekaligus | — | Belum | Pemilih berkas memilih satu foto per kali, sama dengan foto lain di aplikasi. |
