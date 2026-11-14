# F1-07p · Templat import berbahasa Inggris

- **Fase:** 1
- **Status:** Rilis v0.85.0
- **Layar:** dialog import di 1.15 Produk, 1.20 Pelanggan, 1.21 Supplier:
  tombol *Download template*.
- **Acuan:** gap F1-07g "Templat berbahasa Inggris — judul Indonesia
  dikenali di kedua bahasa; templat EN bila diminta". Storeku belum punya
  templat; perbedaan dicatat di sini.

## Tujuan

Pengguna yang memakai aplikasi dalam bahasa Inggris mendapat templat
dengan judul kolom dan contoh berbahasa Inggris, bukan templat Indonesia.

## Aturan

1. **Bahasa templat mengikuti bahasa aplikasi** saat tombol ditekan:
   Indonesia = templat F1-07g tanpa perubahan; English = templat EN.
2. **Isi templat EN** (struktur dan urutan kolom sama dengan ID):
   - Produk: Name, Category, Type, Unit, SKU, Barcode, Cost price, Sell
     price, Opening stock, Min stock. Contoh: *Sample Sugar 1 kg*
     (goods, pcs) dan *Sample Iced Coffee* (menu, cup).
   - Pelanggan: Name, Phone, Address, Group, Credit limit, Note. Contoh:
     *Sample Ani Grocery* (grup Wholesale) dan *Sample Mr Budi*.
   - Supplier: Name, Contact, Phone, Category, Term (days), Address, Note.
     Contoh: *Sample Fresh Foods Ltd* dan *Sample Makmur Trading*.
   Angka contoh sama dengan templat ID; nomor telepon, SKU, dan barcode
   tetap berformat teks (`@`).
3. **Nama berkas EN:** `import-template-products.xlsx` / `-customers` /
   `-suppliers`, lembar *Products* / *Customers* / *Suppliers*.
4. **Baris contoh dilewati di kedua bahasa:** pembaca import melewati baris
   yang namanya sama dengan contoh templat ID **atau** EN (alasan
   *sample*), apa pun bahasa aplikasi saat import. Templat EN tetap bisa
   diimport saat aplikasi berbahasa Indonesia, dan sebaliknya.
5. Tidak ada izin baru; templat tidak memuat data toko.

## Komponen

- Domain: `productImportTemplateEn`, `customerImportTemplateEn`,
  `supplierImportTemplateEn`; pembaca memeriksa contoh kedua templat.
- Flutter: `ImportTemplateKind.fileNameFor/sheetNameFor/rowsFor/bytesFor
  (bahasa)`; `ImportFileActions` memakai bahasa dari `Localizations`;
  kolom teks juga dikenali dari judul *Phone*.

## Pengujian

- Domain: tiap templat EN terbaca utuh (judul dikenali, 2 baris dilewati
  sebagai contoh, nama diganti → 2 baris sah); contoh EN dilewati juga.
- Flutter: `.xlsx` EN terbaca kembali; kolom teks EN; tombol di dialog
  dengan bahasa Inggris menyimpan `import-template-…xlsx`.
- Uji manual Xvfb: aplikasi English, unduh templat supplier, import.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Templat import berbahasa Inggris | — | Rilis v0.85.0 | |
| Templat bahasa lain | — | Belum | Hanya ID dan EN, sama dengan bahasa aplikasi. |
