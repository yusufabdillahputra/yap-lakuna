# F1-14b · Import supplier dari Excel/CSV

- **Fase:** 1
- **Status:** Dikerjakan
- **Layar:** 1.21 Supplier & hutang (tombol *Import Excel* di samping
  *Supplier*, pola dialog import pelanggan 1.20).
- **Acuan:** spec F1-14 (gap "Import supplier: pola import pelanggan"),
  F1-13 (import pelanggan CSV/XLSX), F1-07b (import produk). Storeku belum
  punya import supplier; perbedaan dicatat di sini.

## Tujuan

Toko yang pindah dari buku/aplikasi lain bisa memasukkan daftar pemasok
sekaligus dari berkas .xlsx atau .csv, lalu memperbaruinya lagi dengan
berkas yang sama tanpa membuat supplier ganda.

## Aturan

1. **Berkas:** .xlsx atau .csv (pemisah koma/titik koma), batas ukuran dan
   pembaca sama dengan import pelanggan (`TableFilePicker`, `parseCsv`,
   pembaca XLSX yang sudah ada).
2. **Kolom** (judul tidak peka huruf, ID atau EN): *Nama/Name* (wajib),
   *Kontak/Contact*, *Telepon/HP/Phone*, *Kategori/Category*,
   *Tempo/Tempo (hari)/Term/Term days*, *Alamat/Address*,
   *Catatan/Note*. Kolom lain diabaikan. Tanpa kolom nama seluruh berkas
   ditolak.
3. **Validasi per baris** sama dengan form supplier (`validateSupplier`):
   nama 1–80, telepon 8–15 digit, tempo bilangan bulat 0–365 hari, panjang
   teks. Baris salah dilewati dengan alasan (nama, telepon, tempo, teks,
   nama ganda di berkas) dan nomor barisnya ditampilkan di pratinjau.
4. **Kunci = nama** (tanpa beda huruf, spasi tepi dibuang), karena nama
   supplier unik per tenant. Nama yang sudah ada memperbarui supplier itu,
   hanya kolom yang terisi; kolom kosong mempertahankan data lama. Nama
   baru membuat supplier dengan tempo standar 14 hari bila kolom tempo
   kosong.
5. **Satu transaksi**: semua baris sah disimpan bersama lewat outbox;
   lapisan data memeriksa ulang setiap baris (satu baris salah membatalkan
   seluruh import).
6. **Izin** `suppliers:manage` (UI dan lapisan data).
7. **Hasil:** ringkasan *N supplier baru, M diperbarui, K baris dilewati*.

## Komponen

- Domain: `supplier_import.dart` — `supplierImportRows(table)` →
  `SupplierImportResult(rows, rejected, missingName)`,
  `SupplierImportRow`, `SupplierImportRejectReason`, `parseImportTermDays`.
- Data: `importSuppliers(store, scope, staffId:, rows:)` →
  `SupplierImportSummary(created, updated)`.
- Flutter: `SuppliersRepository.importRows`, `SupplierImportViewModel`,
  `supplier_import_dialog.dart` (pratinjau baris sah + ditolak, lalu
  simpan), tombol *Import Excel* di layar Supplier.

## Pengujian

- Domain: judul ID/EN, kolom wajib, tempo (kosong, angka, `14 hari`,
  negatif, > 365, teks), telepon, nama ganda di berkas, baris kosong.
- Data: buat baru, perbarui per nama tanpa beda huruf (kolom kosong
  dipertahankan), tempo bawaan, izin, validasi ulang, outbox.
- Flutter: VM dialog (pilih berkas, pratinjau, simpan, galat), widget
  1280 / 360 px.
- Uji manual Xvfb dengan berkas CSV.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Import supplier CSV/XLSX | — | Dikerjakan | |
| Templat berkas untuk diunduh | — | Belum | Judul kolom dijelaskan di dialog, sama dengan import pelanggan. |
