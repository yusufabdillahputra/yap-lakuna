# F1-01b · Produk pertama di onboarding

- **Fase:** 1
- **Status:** Rencana v0.52.0
- **Layar:** 1.1 *Setup toko pertama*, langkah 4 "Produk pertama (atau
  import Excel)" di stepper kanvas.
- **Acuan:** gap F1-01 "Langkah 4 Produk pertama (atau import Excel)" dan
  gap F1-07 "Produk pertama di onboarding". Form produk 1.16 (F1-07) dan
  import produk (F1-07b) dipakai ulang.
- **Menutup gap:** F1-01 langkah 4, F1-07 "Produk pertama di onboarding".

## Tujuan

Pemilik yang baru memasang Lakuna bisa langsung berjualan: toko dan produk
pertamanya dibuat dalam satu langkah, atau ia langsung diarahkan ke import
Excel bila sudah punya daftar barang.

## Aturan

1. **Langkah 4** berjudul *Produk pertama, lalu mulai jualan* (stepper:
   "Produk pertama"). Tiga pilihan (`FSelectTileGroup`,
   `first-product-<pilihan>`) dan isiannya tampil paling atas, lalu kartu
   ringkasan toko yang lama di bawahnya:
   - **Tambah satu produk sekarang** (bawaan) → isian singkat muncul.
   - **Import dari Excel/CSV** → setelah toko dibuat, layar Produk terbuka
     dengan dialog import produk.
   - **Lewati, tambah nanti** → perilaku lama (Beranda).
2. **Isian singkat** (pilihan pertama):
   - *Nama produk* (wajib), *Harga jual* (wajib, rupiah > 0), *Harga beli*
     (opsional), *Satuan* (bawaan `pcs`; F&B `porsi`), *Barcode*
     (opsional), *Stok awal* (opsional, hanya untuk barang).
   - Jenis produk mengikuti jenis usaha: Retail/Campuran = *Barang* (lacak
     stok), F&B = *Menu* (tanpa stok, isian stok awal disembunyikan).
   - Kategori dan satuan memakai aturan form produk (dibuat bila belum
     ada); produk *Dijual di kasir* aktif.
   - Galat per isian memakai teks form produk (`productFieldError`);
     *Mulai jualan* tidak menulis apa pun selama ada galat.
3. **Satu transaksi**: toko, pemilik, perangkat, lokasi *Etalase*, dan
   produk pertama (beserta stok awal sebagai pergerakan stok `opening`)
   ditulis dalam satu `LakunaStore.write`. Produk tidak valid → toko juga
   tidak dibuat (`ProductInputInvalid`), pesan tampil di langkah 4.
4. **Import**: toko dibuat tanpa produk, lalu router membuka
   `/produk?impor=1`; layar Produk membuka dialog import sekali (query
   dibuang setelah dialog dibuka). Batal import → daftar produk kosong
   dengan tombol tambah seperti biasa.
5. Pindah pilihan tidak menghapus isian yang sudah diketik; hanya pilihan
   pertama yang mengirim produk.
6. Kembali ke langkah 3 lalu maju lagi mempertahankan pilihan dan isian.
7. Stepper dan "Langkah 4 dari 4" tetap empat langkah.

## Komponen

- Data: `setupStore(..., firstProduct: ProductDraft?)` memvalidasi draf
  sebelum menulis lalu menyimpan produk lewat `_ProductWriter` dalam
  transaksi setup.
- Flutter: `StoreRepository.setup(input, {ProductDraft? firstProduct})`;
  `OnboardingViewModel`: `firstProductChoice`
  (`FirstProductChoice.add/import/skip`), `firstProductValue`,
  `setFirstProduct`, `firstProductDraft`, `firstProductError(field)`,
  `landing` (`Routes.productsImport` bila import);
  `OnboardingScreen(onLanding:)`; router menyimpan tujuan setelah setup;
  `ProductListScreen(openImport:)`.

## Pengujian

- Data: setup dengan produk (produk, varian, stok awal, outbox satu
  transaksi), draf tidak valid → tidak ada tenant, F&B menu tanpa stok.
- VM: bawaan *Tambah*, validasi memblokir finish, draf dibangun dari isian
  (barang vs menu), lewati/import tidak mengirim produk, isian bertahan saat
  pindah pilihan dan kembali.
- Widget: alur 4 langkah dengan produk pertama → Beranda dan produk ada di
  katalog (1280 px dan 360 px); pilihan import → dialog import terbuka.
- Uji manual Xvfb: setup baru dengan produk pertama, lalu jual produk itu di
  Kasir.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Produk pertama di langkah 4 | "Produk pertama (atau import Excel)" | Rencana v0.52.0 | Satu produk, satu varian. |
| Import Excel dari onboarding | Sama | Rencana v0.52.0 | Membuka dialog import produk setelah toko dibuat. |
| Varian / satuan konversi di onboarding | — | Tidak direncanakan | Pakai form produk lengkap setelah setup. |
