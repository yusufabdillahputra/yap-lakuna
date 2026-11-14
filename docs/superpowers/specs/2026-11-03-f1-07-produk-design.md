# F1-07 · Produk, varian, satuan, grosir

- **Fase:** 1
- **Status:** Rilis v0.5.0 (inti katalog), ada gap
- **Layar desain:** 1.15 *Daftar produk & stok · desktop*, 1.15m *Produk &
  stok · mobile* (terang dan gelap), 1.16 *Form produk (varian, satuan,
  grosir) · desktop*, kanvas
  [Desain UI Lakuna](https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525)
- **Acuan Storeku:** `docs/superpowers/specs/2026-11-02-f1-07-produk-design.md`

## Tujuan

Pemilik atau manajer mengisi katalog: produk dengan varian, satuan konversi
(botol/dus, sachet/renceng), harga grosir bertingkat, dan stok awal. Katalog
ini syarat Kasir retail (F1-04): kasir hanya bisa menjual barang yang ada di
katalog.

## Urutan pengerjaan

Indeks spec mengurutkan Kasir retail (4) sebelum Produk (7), sama dengan
Storeku. Di Storeku kasir dibangun lebih dulu karena contoh produk diisi
lewat skrip. Lakuna belum punya tabel katalog sama sekali, jadi **inti F1-07
dibangun lebih dulu** (v0.5.0), lalu F1-04 dan F1-05. Ini urutan kerja, bukan
perubahan tujuan produk.

## Lingkup

Termasuk (v0.5.0):

- **Daftar produk 1.15 / 1.15m:**
  - Ringkasan "N produk aktif · M di bawah stok minimum".
  - Cari nama, SKU, atau barcode.
  - Filter kategori. Di ponsel berupa chip, ditambah chip *Di bawah minimum
    (M)*.
  - Tabel di layar lebar: Produk (nama + SKU), Kategori, Varian / satuan,
    Harga beli, Harga jual, Grosir, Stok (pil).
  - Daftar kartu di ponsel.
  - Tombol *+ Produk baru* (tombol mengambang di ponsel).
- **Form produk 1.16** (tambah dan ubah):
  - Kartu *Info dasar*: nama, kategori, jenis, satuan dasar, SKU induk,
    merek, sakelar *Dijual di kasir*, sakelar *Kena pajak (PB1/PPN)*.
  - Tab *Varian*: nama varian, SKU, barcode, harga beli, harga jual, stok
    min, dan stok awal (hanya untuk varian baru).
  - Tab *Satuan & konversi*: per varian, satuan dasar (baris tetap) dan
    satuan konversi (nama, isi dalam satuan dasar, harga beli, harga jual,
    barcode).
  - Tab *Harga grosir*: per varian, mulai jumlah (dalam satuan dasar) dan
    harga per satuan dasar.
  - Kategori dan satuan diketik bebas. Nama baru otomatis dibuat (tanpa
    membedakan huruf besar/kecil), nama yang sudah ada dipakai ulang.
- **Stok awal** dicatat sebagai pergerakan stok (`stock_movements`,
  sumber `opening`) di lokasi bawaan *Etalase*. Saldo dibaca dari cache
  `stock_levels` di perangkat.
- Menu *Produk* (kelompok Persediaan, navigasi bawah ponsel) untuk staf
  dengan `products:manage`.

Tidak termasuk (lihat gap): foto produk, tab *Modifier* (F1-10), tab
*Barcode & label* dan cetak label, *Import Excel*, filter lokasi stok, grosir
per grup pelanggan, kartu stok (F1-08), arsip produk.

## Desain UI (baseline)

### 1.15 Daftar produk · layar lebar (≥ 600 px)

- **Kepala:** judul "Produk & stok", subjudul ringkasan, tombol primary
  *+ Produk baru*. Tombol *Import Excel* dan *Cetak label barcode* belum
  ditampilkan (gap).
- **Filter:** kolom cari ("Cari nama, SKU, atau barcode") dan pilihan
  *Kategori* (Semua + daftar kategori).
- **Tabel:** satu baris per produk.
  - *Produk*: kotak inisial 36 px (pengganti foto), nama tebal, SKU di
    bawahnya (abu). SKU yang tampil: SKU induk, atau SKU varian pertama.
  - *Varian / satuan*: produk satu varian → "satuan dasar · konversi (isi)",
    mis. "botol · dus (6)". Lebih dari satu varian → "2 varian · botol".
  - *Harga beli*, *Harga jual* (tebal) dari varian pertama; produk dengan
    beberapa harga menampilkan rentang "Rp 18.500–36.000".
  - *Grosir*: tingkat pertama varian pertama, mis. "≥6: Rp 35.000", atau "—".
  - *Stok*: pil jumlah total semua varian dalam satuan dasar (mis. "12,5
    kg"). Kuning (#FEF3C6/#973C00) bila ada varian di bawah atau sama dengan
    stok min (stok min > 0), selain itu biru langit (#DFF2FE/#016630).
    Jasa dan menu menampilkan "—".
  - Klik baris membuka form ubah.
- **Catatan kaki:** "Stok dihitung dari riwayat pergerakan (stok awal,
  pembelian, penjualan, retur, penyesuaian)."
- **Kosong:** kartu "Belum ada produk" dengan tombol *+ Produk baru*.

### 1.15m Daftar produk · ponsel (< 600 px)

- Judul "Produk", subjudul "N aktif · M di bawah minimum".
- Kolom cari, lalu baris chip yang bisa digulir: *Semua*, *Di bawah minimum
  (M)*, lalu kategori.
- Kartu per produk: kotak inisial 52 px, nama, subjudul abu "Kategori ·
  satuan · konversi (isi)", harga jual di kanan, pil stok di bawahnya ("Stok
  3 / min 5" bila di bawah minimum). Warna pil OK di ponsel hijau
  (#DCFCE7/#016630) sesuai kanvas 1.15m.
- Tombol mengambang *Produk baru* 56 px di kanan bawah.

### 1.16 Form produk

- **Kepala:** "Produk baru" atau "Edit produk · <nama>", jejak "Produk &
  stok › <nama>", tombol *Batal* (outline) dan *Simpan* (primary).
- **Kiri, kartu *Info dasar*** (lebar ~360 px):
  - *Nama produk* (wajib, ≤ 120 karakter).
  - *Kategori* (opsional) dan *Jenis*: Barang (lacak stok) / Jasa (tanpa
    stok) / Menu F&B. Menu F&B untuk sementara tidak melacak stok (resep di
    F1-10).
  - *Satuan dasar* (wajib, mis. pcs, botol, kg) dan *SKU induk*.
  - *Merek*.
  - Sakelar *Dijual di kasir* (bawaan nyala) dan *Kena pajak (PB1/PPN)*
    (bawaan mati, sublabel "Mengikuti pengaturan pajak toko").
  - Foto belum ada; tempatnya diisi kotak inisial (gap).
- **Kanan, kartu tab** (`FTabs`): *Varian* | *Satuan & konversi* | *Harga
  grosir*.
  - **Varian:** satu baris per varian dengan kolom Varian (nama, boleh
    kosong bila hanya satu varian), SKU, Barcode, Harga beli, Harga jual,
    Stok min, dan Stok awal (hanya varian baru dan jenis Barang). Tombol
    garis putus *+ Tambah varian* dan ikon hapus per baris (minimal satu
    varian).
  - **Satuan & konversi:** pilihan varian (bila lebih dari satu), baris
    satuan dasar (isi 1, harga varian, barcode varian, tidak bisa diubah di
    sini), lalu baris satuan konversi: Satuan, Isi (satuan dasar), Harga
    beli, Harga jual, Barcode. Tombol *+ Tambah satuan*. Teks bantu: "Stok
    selalu disimpan dalam satuan dasar (<satuan>). Jual 1 <konversi> =
    keluar <isi> <satuan> dari kartu stok."
  - **Harga grosir:** pilihan varian, baris Mulai jumlah (satuan dasar) dan
    Harga per <satuan dasar>, tombol *+ Tambah tingkat harga*. Kolom
    *Berlaku untuk* menampilkan "Semua pelanggan" (grup pelanggan adalah
    gap).
- **Ponsel:** kartu Info dasar di atas, kartu tab di bawah. Setiap baris
  tabel ditumpuk menjadi kartu kecil berisi field berlabel.
- Galat ditampilkan di field-nya. Galat di tab lain ditandai titik merah di
  label tab, dan tab pertama yang bermasalah dibuka saat *Simpan* gagal.

## Aturan bisnis (`lakuna_domain`)

- **Satuan dasar.** Stok, stok min, stok awal, isi konversi, dan jumlah
  grosir selalu dalam satuan dasar produk. Jual 1 dus (isi 6) = keluar 6
  botol (`Qty.toBaseUnit(factorMilli)`).
- **Harga satuan konversi** boleh diisi sendiri (dus Rp 210.000). Bila
  kosong = harga jual varian × isi (dibulatkan ke rupiah).
- **Harga grosir** (`unitPriceFor`): tingkat dengan *mulai jumlah* terbesar
  yang ≤ jumlah beli (dalam satuan dasar) menang. Di bawah tingkat pertama
  dipakai harga jual varian.
- **Validasi produk** (`validateProductDraft`, mengembalikan semua masalah
  sekaligus, tiap masalah menunjuk field):
  - Nama wajib, ≤ 120 grapheme. Satuan dasar wajib, ≤ 30.
  - Kategori, merek ≤ 60; SKU ≤ 40; barcode ≤ 64; nama varian ≤ 60.
  - Minimal satu varian. Nama varian unik dalam produk (tanpa membedakan
    huruf besar/kecil). Bila lebih dari satu varian, nama varian wajib.
  - Harga beli dan jual ≥ 0. Stok min dan stok awal ≥ 0.
  - Satuan konversi: nama wajib, berbeda dari satuan dasar dan unik per
    varian; isi > 1 satuan dasar; harga (bila diisi) ≥ 0.
  - Tingkat grosir: mulai jumlah > 1 satuan dasar (jumlah 1 sama dengan
    harga normal); unik per varian; harga > 0.
  - SKU dan barcode (varian dan satuan konversi) tidak boleh kembar di
    dalam produk yang sama.
  - Jenis Jasa/Menu: stok awal diabaikan (tidak melacak stok).
- **Kode unik per tenant.** SKU varian dan semua barcode (varian dan satuan
  konversi) unik per tenant, dibandingkan setelah `trim` dan huruf besar,
  terhadap produk lain yang belum dihapus. Disimpan apa adanya (setelah
  `trim`).
- **Stok sebagai ledger.** Stok awal = satu `stock_movements` sumber
  `opening` per varian baru dengan stok awal > 0, biaya satuan = harga beli.
  Mengubah produk tidak pernah mengubah stok; koreksi stok lewat penyesuaian
  F1-08.
- **Rata-rata biaya** di cache `stock_levels` hanya berubah oleh barang
  masuk (sama dengan Storeku).

## Data

Migrasi `produk`. Model di `lakuna_server/lib/src/catalog/`, semua
`database: all` kecuali `stock_levels`, kolom sync standar (F0).

- **`categories`**: `tenant_id`, `name`, `sort_order`.
- **`units`**: `tenant_id`, `name`.
- **`products`**: `tenant_id`, `category_id?`, `base_unit_id`, `name`,
  `type` (`goods`/`service`/`menu`), `sku?`, `brand?`, `is_active`,
  `is_taxable`.
- **`product_variants`**: `tenant_id`, `product_id`, `name` (boleh ''),
  `sku?`, `barcode?`, `cost_price`, `sell_price`, `min_stock_milli`,
  `sort_order`.
- **`product_units`**: `tenant_id`, `variant_id`, `unit_id`,
  `factor_milli`, `barcode?`, `cost_price?`, `sell_price?`.
- **`price_tiers`**: `tenant_id`, `variant_id`, `min_qty_milli`, `price`.
- **`stock_movements`**: `tenant_id`, `outlet_id`, `stock_location_id`,
  `variant_id`, `quantity_milli` (≠ 0, positif = masuk), `unit_cost`,
  `source_type` (`opening`/`adjustment`/`sale`/`sale_return`/`purchase`/
  `purchase_return`/`transfer`), `source_id?`, `occurred_at`, `note?`.
  Nilai enum disimpan dengan nama Dart (`saleReturn`, `purchaseReturn`),
  bukan snake_case, karena Serverpod menyimpan enum `byName`.
- **`stock_levels`** (`database: client`, tidak disinkronkan): cache
  `stock_location_id`, `variant_id`, `quantity_milli`, `avg_cost`, unik per
  (lokasi, varian). Diperbarui di transaksi yang sama dengan
  `stock_movements`, dan bisa dibangun ulang dari ledger
  (`rebuildStockLevels`, dipakai setelah sync tarik di Fase 2).
- **Penulisan:** `saveProduct` dalam satu `LakunaStore.write`: cek kode unik,
  pastikan kategori/satuan, sisipkan atau perbarui produk, varian, satuan,
  dan tingkat; varian/satuan/tingkat yang dihapus di form di-soft-delete;
  stok awal varian baru dicatat sebagai pergerakan.
- **Nama kelas model:** `ProductCategory` (tabel `categories`),
  `MeasureUnit` (`units`), `ProductPriceTier` (`price_tiers`), agar tidak
  bentrok dengan `PriceTier` domain, `Category` Flutter, dan kelas
  `<Model>Repository` buatan Serverpod. Repositori aplikasi bernama
  `CatalogRepository`.
- **Perbedaan dengan Storeku:**
  - `price_tiers` hanya menyimpan harga (Storeku juga `discount_bp`), karena
    form hanya mengisi harga.
  - `product_units` menyimpan `cost_price` (kanvas punya kolom Harga beli).
  - `products.sku`, `brand`, `is_taxable` langsung ada (gap di Storeku).
  - Sumber `opening` untuk stok awal (Storeku memakai `adjustment`).

## Izin

| Aksi | Izin |
| --- | --- |
| Lihat daftar, tambah, ubah produk | `products:manage` |

Dicek di menu/rute dan di repositori aplikasi `ProductRepository`
(`NotPermitted`).

## Kasus tepi

- **SKU/barcode sudah dipakai produk lain** → galat di field-nya ("Sudah
  dipakai <nama produk>"), tidak ada yang ditulis.
- **Kategori/satuan diketik beda huruf** ("sembako" vs "Sembako") → memakai
  yang sudah ada.
- **Varian dihapus di form** → di-soft-delete bersama satuan dan tingkatnya;
  stoknya tetap ada di ledger.
- **Ubah jenis Barang → Jasa** → stok lama tetap di ledger, tidak tampil di
  daftar.
- **Ubah satuan dasar** setelah ada stok → diizinkan (nama satuan saja yang
  berubah; jumlah di ledger tetap). Teks bantu memperingatkan.
- **Input uang** memakai `RupiahInputFormatter` (≤ 15 digit). Input jumlah
  menerima pecahan dengan koma ("12,5") sampai 3 desimal.
- **Produk banyak** (ratusan): daftar memakai `ListView.builder`, pencarian
  di memori.

## Pengujian (TDD)

- **`lakuna_domain`:** `unitPriceFor` (tanpa tingkat, di bawah, tepat di,
  dan di atas tingkat, urutan acak), harga satuan konversi, `parseQty` /
  format jumlah, validasi draf (semua aturan di atas).
- **`lakuna_data`:** simpan produk baru (baris, outbox, stok awal +
  `stock_levels`), kategori/satuan dipakai ulang tanpa beda huruf, kode
  kembar antar produk ditolak, ubah produk (varian/satuan/tingkat ditambah
  dan dihapus, versi naik), daftar produk dengan stok, tenant lain tidak
  terbaca, `recordStockMovement` + rata-rata biaya, `rebuildStockLevels`.
- **`lakuna_flutter`:** repositori lokal dengan izin, view model daftar
  (cari, filter, ringkasan) dan form (galat per field, tab bermasalah),
  alur widget tablet dan ponsel, menu.
- **Uji manual Xvfb:** daftar kosong, tambah produk satu varian dengan
  satuan konversi dan grosir, tambah produk dua varian, ubah, galat barcode
  kembar, daftar terisi di desktop dan ponsel gelap.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Foto produk | *Ganti foto*, thumbnail | Rilis v0.37.0 | [F1-07f](2026-11-13-f1-07f-foto-produk-design.md): satu foto per produk di form, daftar, dan Kasir; kecilkan ke WebP masih gap |
| Tab Modifier | Hanya Menu F&B | Belum | F1-10 |
| Tab Barcode & label, *Cetak label barcode* | Ada | Rilis v0.36.0 | [F1-07e](2026-11-13-f1-07e-label-barcode-design.md): halaman 1.15b, A4 3×8 dan printer label (PDF); tombol *Cetak label* di form menggantikan tab |
| *Import Excel* | Tombol di 1.15 | Rilis v0.31.0 | Lihat [F1-07b](2026-11-04-f1-07b-import-produk-design.md): produk baru satu varian, yang sudah ada dilewati. |
| Filter *Lokasi stok* | Etalase/Gudang | Hanya Etalase | Saat F1-09 menambah lokasi kedua |
| Grosir *Berlaku untuk* grup pelanggan | "Grup pelanggan: Grosir" | Rilis v0.34.0 | [F1-07c](2026-11-13-f1-07c-grosir-grup-pelanggan-design.md) (`price_tiers.customer_group_id`) |
| Klik produk → kartu stok | Catatan kaki 1.15 | Klik membuka form | Tautan ke kartu stok F1-08 |
| Arsip produk | "Hapus = arsip" | Rilis v0.35.0 | [F1-07d](2026-11-13-f1-07d-arsip-produk-design.md): arsip dari form, pulihkan dari 1.15 |
| Produk pertama di onboarding | Langkah 4 F1-01 | Selesai v0.52.0 | [F1-01b](2026-11-14-f1-01b-produk-pertama-onboarding-design.md): satu produk atau import Excel di langkah 4 |
| Form dua kolom | Info dasar di kiri, tab di kanan | Satu kolom; dua kolom hanya bila konten ≥ 1000 px | Cukup; layar 1280 px dengan sidebar memakai satu kolom agar tabel varian lega |
| Label tab di ponsel | "Satuan & konversi", "Harga grosir" | "Satuan", "Grosir" di bawah 600 px | Label penuh terpotong di 400 px |
| Daftar ponsel saat 2+ varian | Satu baris satuan | "2 varian · botol" | Cukup |

## Kriteria selesai

Inti v0.5.0: daftar dan form bekerja di desktop dan ponsel, stok awal masuk
ledger, kode unik dijaga, semua tes lulus, uji manual dengan tangkapan layar.
Modul selesai penuh setelah semua baris gap selesai.

Terpenuhi di v0.5.0: uji manual di Xvfb 1280x800 (produk baru dengan varian,
satuan Dus isi 6, grosir ≥6, stok awal 24; ubah produk menambah varian 1 L;
galat barcode kembar; daftar memperlihatkan stok 36) dan ponsel 400x800 mode
gelap. Tangkapan layar `v0.5.0-*.png`.
