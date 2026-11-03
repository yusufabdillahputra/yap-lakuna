# F1-12 · Pembelian & retur beli

- **Fase:** 1
- **Status:** Dirancang (v0.16.0)
- **Layar desain:** 1.19 *Pembelian & retur beli* dan 1.19b *Detail
  pembelian: HPP & saran harga jual* (terang + gelap) di kanvas
  [Desain UI Lakuna](https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525).
- **Acuan Storeku:** `docs/superpowers/specs/2026-11-02-f1-12-pembelian-design.md`
  (aturan v0.15.0 Storeku disalin di sini; perbedaan dicatat di bagian
  *Beda dengan Storeku*).

## Tujuan

Staf gudang mencatat barang masuk dari supplier. Stok bertambah lewat ledger,
HPP rata-rata ikut diperbarui, dan sisa yang belum dibayar menjadi hutang
supplier. Barang yang dikembalikan ke supplier dicatat sebagai retur beli.

## Lingkup v0.16.0

**Termasuk**
- Daftar pembelian dan retur pembelian (tab), dengan pencarian nomor atau
  supplier.
- Pembelian baru: simpan sebagai draf, atau terima barang.
- Item memakai satuan dasar atau satuan konversi, misalnya "dus (6)".
- Diskon faktur dan ongkos kirim.
- Bayar di muka dari kas toko, kas laci, atau rekening bank. Sisanya menjadi
  hutang dengan jatuh tempo.
- Detail pembelian (1.19b): HPP sebelum → sesudah, saran harga jual dengan
  tombol *Terapkan harga jual*, ringkasan, pembayaran, dan retur pembelian.
- Supplier minimal: pilih dari daftar, atau ketik nama baru yang otomatis
  dibuat.

**Tidak termasuk**
- Pelunasan hutang belakangan (*Bayar hutang*, F1-14). Tombolnya tampil
  nonaktif dengan catatan "menyusul".
- Master supplier lengkap (F1-14).
- Foto faktur, cetak/bagikan PDF pembelian, dan tautan kartu stok dari
  detail (lihat *Status & gap*).
- Pesanan pembelian (PO).

## Desain UI

### 1.19 Pembelian

**Kepala layar**
- Judul *Pembelian*, subjudul "Barang masuk dari supplier, termasuk retur
  pembelian", dan tombol *+ Pembelian baru*.

**Daftar**
- Tab *Pembelian* / *Retur pembelian*, lalu kolom cari "Cari nomor /
  supplier".
- Tabel Pembelian: Nomor (+ tanggal · draf), Supplier, Total, Status.
  Status: *Draf*, *Lunas*, *Hutang*.
- Tabel Retur pembelian: Nomor RB (+ tanggal), Supplier, Nilai (−),
  Pembelian asal.

**Panel form** (*Pembelian baru · PB-…* atau *Draf · PB-…*)
- Supplier (pilih atau ketik baru), No. faktur supplier, Tanggal, Masuk ke
  lokasi.
- Tabel Produk: Satuan, Qty, Harga beli, Subtotal, hapus baris.
- *+ Scan / cari produk*: barcode varian atau barcode satuan konversi
  langsung memilih satuannya.
- Bayar sekarang, Dari (Kas toko / Kas laci / Rekening bank), Jatuh tempo
  sisa.
- Kolom kanan: Subtotal, Diskon faktur (bisa diisi), Ongkos kirim (bisa
  diisi), Total, "Sisa jadi hutang".
- Tombol *Simpan draf* dan *Terima barang & simpan*, dengan catatan "Saat
  disimpan: stok <lokasi> bertambah (ledger), harga pokok rata-rata
  diperbarui, hutang supplier tercatat."
- Draf punya tombol *Hapus draf*.

**Tata letak**
- Lebar konten ≥ 1100 px: daftar di kiri, form di kanan.
- Lebih sempit: form dibuka sebagai halaman (`/pembelian/baru`,
  `/pembelian/:id` untuk draf).
- Detail pembelian yang sudah diterima selalu berupa halaman
  (`/pembelian/:id`).

### 1.19b Detail pembelian

- Breadcrumb *Pembelian › PB-…*, nomor, "Pembelian dari <supplier>", lencana
  status (*Lunas*, *Belum lunas · hutang*), dan tombol *Kembali*.
- Info: Supplier, No. faktur supplier, Tanggal, Masuk ke lokasi, Dibuat oleh
  (staf · perangkat).
- **Barang diterima**: Produk (nama, SKU · satuan), Qty, Harga beli,
  Subtotal, HPP rata-rata `lama → baru` per satuan dasar, Harga jual, Saran
  jual, lencana *Di bawah saran* / *Aman*, dan centang *Ubah harga*.
  - Tombol *Terapkan harga jual (N produk)*.
  - Catatan: "HPP memakai rata-rata tertimbang (moving average) dalam
    satuan dasar."
- **Ringkasan**: Subtotal, Diskon faktur, Ongkos kirim, Total, Sudah dibayar,
  Diretur (bila ada), Sisa hutang, dan kotak jatuh tempo ("8 hari lagi" /
  "lewat 2 hari").
- **Pembayaran**: baris bayar di muka (tanggal, keterangan, dari, jumlah) dan
  pengurang hutang dari retur. *Bayar hutang* nonaktif sampai F1-14.
- **Tindakan**: *Retur pembelian*, dengan catatan "Membuat dokumen RB-… yang
  mengurangi stok & hutang".
- **Retur pembelian** (dialog atau lembar):
  - jumlah per baris (sisa = qty − sudah diretur), dalam satuan baris;
  - catatan;
  - bila nilai retur melebihi sisa hutang, pilihan *Uang kembali ke* (Kas
    toko / Kas laci / Rekening bank);
  - tombol *Proses retur · Rp X*.
- Daftar retur yang sudah dibuat (nomor RB, tanggal, nilai).

## Keputusan (brainstorming 3 Nov 2026, mengikuti Storeku v0.15.0)

1. **Status** dokumen: `draft` dan `received`.
   - Draf mendapat nomor `PB-` saat pertama disimpan. Draf boleh diubah,
     atau dihapus lewat soft delete.
   - Dokumen yang sudah diterima tidak bisa diubah atau dihapus, hanya
     diretur.
   - Status tampilan: *Draf*, *Lunas* (sisa 0), *Hutang* (sisa > 0).
2. **Baris** terdiri dari varian, satuan (dasar atau `product_units`), qty
   dalam satuan itu, dan harga beli per satuan itu.
   - Salinan yang disimpan: nama produk dan varian, nama satuan, isi
     (`factor_milli`), dan harga pokok mendarat per satuan dasar
     (`landed_unit_cost`). Saat diterima juga disimpan `avg_cost_before` dan
     `avg_cost_after`, agar detail dan retur memakai angka saat transaksi.
   - Satu varian hanya boleh muncul sekali per satuan. Scan ulang menambah
     qty baris yang sama.
   - Qty boleh pecahan (mili).
3. **Landed cost**:
   - Diskon faktur dan ongkir dibagi ke baris secara proporsional subtotal
     baris (`allocateByWeight`).
   - Harga pokok per satuan dasar = nilai mendarat baris ÷ qty dasar,
     dibulatkan ke rupiah terdekat.
   - Total = subtotal − diskon + ongkir.
   - Diskon tidak boleh melebihi subtotal. Ongkir dan diskon tidak boleh
     negatif.
4. **Terima barang**:
   - Stok `purchase` masuk di lokasi terpilih (qty × isi) lewat
     `recordStockMovement`, sehingga rata-rata tertimbang per lokasi ikut
     diperbarui.
   - `cost_price` varian diperbarui ke harga pokok mendarat terakhir.
   - Minimal satu baris dengan qty > 0 dan harga ≥ 0.
5. **Bayar di muka** disimpan di `purchases.paid_amount` + `funding_source`
   (`storeCash` / `drawer` / `bank`).
   - Dibayar tidak boleh melebihi total.
   - Pelunasan belakangan memakai tabel pembayaran hutang di F1-14.
6. **Kas laci**:
   - Bayar dari laci menulis `cash_movements` keluar di sesi terbuka
     perangkat ini. `source = 'purchase'`, catatan = nomor dokumen.
   - Tanpa sesi terbuka → ditolak (`CashSessionNotOpen`).
   - Kas toko dan rekening bank cukup dicatat di dokumen (buku kas di
     F1-15/F1-16).
7. **Hutang** = total − dibayar − pengurang hutang dari retur.
   - Sisa > 0 wajib punya supplier dan jatuh tempo.
   - Jatuh tempo tidak boleh sebelum tanggal pembelian.
8. **Retur pembelian** `RB-`:
   - Per baris ≤ qty dibeli − sudah diretur, dalam satuan baris.
   - Stok keluar (qty × isi) dengan `landed_unit_cost` baris.
   - Stok di lokasi harus cukup (`PurchaseReturnInvalid(stock)`), walau
     pengaturan stok minus aktif. Barang yang tidak ada tidak bisa
     dikembalikan.
   - Nilai = bagian nilai mendarat baris (`returnAmount`, sisa ke retur
     terakhir).
   - Nilai retur otomatis mengurangi hutang lebih dulu. Kelebihannya dicatat
     sebagai uang kembali ke sumber yang dipilih (kas toko / laci / bank).
     Laci menulis `cash_movements` masuk di sesi terbuka.
   - Hanya pembelian `received` yang bisa diretur.
9. **Saran harga jual**:
   - Varian yang HPP-nya berubah ditawarkan dengan harga yang menjaga margin
     lama: `harga jual × HPP baru ÷ HPP lama`, dibulatkan ke atas ke
     Rp 100.
   - Bila HPP lama 0, saran = harga jual sekarang (tidak ada margin untuk
     dijaga).
   - Lencana *Di bawah saran* bila harga jual < saran; baris ini dicentang
     otomatis.
   - *Terapkan harga jual* mengubah `sell_price` varian (satuan dasar) lewat
     outbox. Tidak ada perubahan diam-diam.
   - Riwayat harga jual = baris outbox/HLC (laporan riwayat harga di Fase 3).
10. **Supplier minimal**:
    - Tabel `suppliers` (nama, telepon, catatan) per tenant.
    - Form memilih dari daftar, atau mengetik nama baru yang dibuat saat
      simpan. Nama unik per tenant, tanpa membedakan huruf besar/kecil.
11. **Izin**: `purchases:manage`, dicek di menu, layar, dan repositori
    aplikasi. Lapisan data memeriksa bahwa aktor adalah staf outlet ini
    (pola F1-08).
12. **Nomor**: `PB-PST-D01-261102-0003` dan `RB-…`, berurutan per perangkat
    per hari. Nomor draf tetap saat draf diterima.
13. Rute `/pembelian` dengan menu *Pembelian* (Inventori).

## Beda dengan Storeku

- Storeku menyimpan HPP hanya sebagai `cost_price`. Lakuna menyimpan juga
  `avg_cost_before/after` per baris untuk layar 1.19b.
- Supplier minimal ada di Lakuna sejak F1-12 (tabel `suppliers`). Storeku
  sudah punya tabel supplier dari fondasi.
- Satuan konversi sudah ada sejak F1-07 Lakuna, jadi tidak dibangun ulang.

## Data

**Tabel baru**
- `suppliers`: `name`, `phone?`, `note?`, kolom sync baku.
- `purchases`:
  - `tenant_id`, `outlet_id`, `device_id`, `stock_location_id`,
    `supplier_id?`, `staff_id`;
  - `number`, `invoice_no?`, `status`, `purchased_on` (tanggal lokal,
    disimpan sebagai `DateTime` UTC tengah malam);
  - `subtotal`, `discount`, `shipping`, `total`, `paid_amount`,
    `funding_source?`, `cash_session_id?`;
  - `due_on?`, `note?`, `received_at?`.
- `purchase_items`:
  - `purchase_id`, `variant_id`, `product_unit_id?`;
  - `product_name`, `variant_name`, `unit_name`, `factor_milli`;
  - `quantity_milli`, `unit_price`, `line_total`, `landed_unit_cost`;
  - `avg_cost_before?`, `avg_cost_after?`, `sort_order`.
- `purchase_returns`:
  - `purchase_id`, `outlet_id`, `device_id`, `staff_id`, `number`;
  - `amount`, `debt_reduction`, `refund_amount`, `refund_source?`,
    `cash_session_id?`;
  - `note?`, `returned_at`.
- `purchase_return_items`: `purchase_return_id`, `purchase_item_id`,
  `quantity_milli`, `amount`.

**Enum**: `PurchaseStatus` (`draft`, `received`), `FundingSource`
(`storeCash`, `drawer`, `bank`).

Semua tulis lewat `LakunaStore.write` + `SyncTx`. Migrasi `pembelian`.

## Pengujian

- **Domain**: landed cost (sisa pembulatan, diskon, ongkir), validasi
  pembelian, sisa hutang, saran harga jual (pembulatan ke atas Rp 100),
  nomor `PB-`/`RB-`.
- **Data**:
  - draf tidak menggerakkan stok; ubah dan hapus draf;
  - terima → stok, avg cost per lokasi, `cost_price`, `avg_cost_before/after`;
  - bayar dari laci → cash movement keluar, dan ditolak tanpa sesi;
  - hutang wajib jatuh tempo;
  - retur → stok keluar, hutang berkurang, kelebihan ke laci, batas sisa,
    stok kurang ditolak;
  - terapkan harga jual;
  - daftar dan cari;
  - supplier baru dibuat sekali.
- **Aplikasi**: repositori lokal (izin), view model form (hitung total,
  scan satuan, validasi), widget alur desktop (draf → terima → detail →
  terapkan harga → retur) dan ponsel 360 px.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Pembelian, draf, terima, landed cost, HPP, hutang, kas laci, retur beli, saran harga jual | 1.19, 1.19b | Belum | v0.16.0. |
| Bayar hutang belakangan | Tombol *Bayar hutang* | Nonaktif | F1-14. |
| Foto faktur | *Lihat foto faktur* | Belum | Pakai `media_files` (F1-18) di rilis berikutnya. |
| Kartu stok terkait, cetak/bagikan PDF | Tombol di 1.19b | Belum | Setelah F1-14. |
| Master supplier lengkap | 1.21 | Nama, telepon, catatan saja | F1-14. |

## Kriteria selesai

- Pembelian lunas dan berhutang tercatat; stok dan HPP benar.
- Retur beli tercatat dan mengurangi hutang.
- Kas laci terpengaruh bila dipakai.
- Layar jalan di desktop, tablet, dan ponsel 360 px tanpa luapan.
