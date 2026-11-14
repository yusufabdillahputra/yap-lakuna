# F1-01b · Produk pertama di onboarding

- **Fase:** 1
- **Status:** Rilis v0.52.0
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
   ditulis dalam satu `LakunaStore.write`. Draf diperiksa **sebelum**
   transaksi (`ProductInputInvalid`, toko juga tidak dibuat): aturan form
   produk, harga jual > 0, dan hal yang belum ada di toko baru (id produk
   lama, grup modifier, harga grup pelanggan) ditolak agar setup tidak gagal
   di tengah jalan.
4. **Import**: toko dibuat tanpa produk, lalu router membuka
   `/produk?impor=1` dan layar Produk membuka dialog import sekali (saat
   layar dibuat; query dibiarkan). Tujuan ini dipakai sekali: masuk
   berikutnya kembali ke Beranda. Batal import → daftar produk kosong
   dengan tombol tambah seperti biasa.
5. Pindah pilihan tidak menghapus isian yang sudah diketik; hanya pilihan
   pertama yang mengirim produk.
6. Kembali ke langkah 3 lalu maju lagi mempertahankan pilihan dan isian.
7. Stepper dan "Langkah 4 dari 4" tetap empat langkah.
8. Bila toko ternyata sudah ada (`SetupAlreadyDone`) sementara produk
   pertama diisi, pesan galat tetap tampil (produk tidak tersimpan diam-diam).

## Komponen

- Data: `setupStore(..., firstProduct: ProductDraft?)` memeriksa draf lalu
  menyimpan produk lewat `writeProductInTx` (internal, tidak diekspor dari
  barrel) di dalam transaksi setup.
- Flutter: `StoreRepository.setup(input, {ProductDraft? firstProduct})`;
  `OnboardingViewModel`: `FirstProductChoice` (`add/import/skip`),
  `firstProductChoice`, isian `productName/productSellPrice/
  productCostPrice/productUnit/productBarcode/productOpeningStock` dengan
  setter `set*`, `productKind`, `firstProductDraft`, `productError(field)`,
  `opensImport`, `onBeforeSetup`; `OnboardingScreen(onBeforeSetup:)`;
  router memegang `importAfterSetup` → `Routes.productsImport`;
  `ProductListScreen(openImport:)`.

## Pengujian

- Data: setup dengan produk (produk, varian, stok awal, outbox satu
  transaksi), draf tidak valid atau yang bisa gagal di tengah transaksi →
  tidak ada tenant, F&B menu tanpa stok.
- VM: bawaan *Tambah*, validasi memblokir finish, draf dibangun dari isian
  (barang vs menu), lewati/import tidak mengirim produk, isian bertahan saat
  pindah pilihan dan kembali, `onBeforeSetup` hanya saat setup berjalan.
- Widget: alur 4 langkah dengan produk pertama → Beranda dan produk ada di
  katalog (tablet dan ponsel 400 px), retail dengan harga beli dan stok
  awal, produk kosong menahan, lewati; pilihan import → dialog import
  terbuka.
- Uji manual Xvfb: setup baru dengan produk pertama (tampil di Produk
  dengan stok awal), dan setup baru dengan pilihan import.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Produk pertama di langkah 4 | "Produk pertama (atau import Excel)" | Rilis v0.52.0 | Satu produk, satu varian. |
| Import Excel dari onboarding | Sama | Rilis v0.52.0 | Membuka dialog import produk setelah toko dibuat. |
| Varian / satuan konversi di onboarding | — | Tidak direncanakan | Pakai form produk lengkap setelah setup. |
