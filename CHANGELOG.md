# Changelog

Semua perubahan penting Lakuna dicatat di sini. Format mengikuti
[Keep a Changelog](https://keepachangelog.com/id-ID/1.1.0/) dan versi
mengikuti [Semantic Versioning](https://semver.org/lang/id/). Selama versi
`0.x`, setiap rilis ditandai pre-release.

## [Unreleased]

## [0.6.0] - 2026-11-03

Kasir retail (F1-04, layar 1.4, 1.11, 1.11b) dan inti pembayaran (F1-05,
layar 1.5 dan 1.5c): kasir bisa menjual dengan scan atau ketuk produk, harga
grosir dan satuan konversi dihitung otomatis, lalu dibayar tunai, kartu,
atau transfer. Penjualan mengurangi stok lewat ledger dan masuk ke rekap
sesi kasir.

### Ditambahkan

- **Menu *Kasir*** (rute `/kasir`) di kelompok Penjualan dan navigasi bawah
  ponsel, untuk staf dengan izin `sales:create`.
- **Wajib sesi kasir terbuka**: tanpa sesi, kasir menampilkan "Buka sesi
  kasir dulu" dengan tombol ke *Sesi kasir*.
- **Kasir tablet/desktop (1.4)**:
  - Baris konteks "Toko · Cabang" dan "Kasir: nama · Sesi dibuka HH.mm".
  - Kolom cari dengan label *Scanner siap*: mengetik menyaring produk (nama,
    SKU, barcode). **Enter** dengan barcode/SKU varian atau barcode satuan
    konversi langsung memasukkan barang dan mengosongkan kolom. Kode yang
    tidak dikenal memunculkan pesan merah di bawah kolom.
  - Pilihan kategori (*Semua* + kategori yang punya produk aktif).
  - Grid produk: kotak inisial, nama, harga ("mulai Rp X" bila harga varian
    berbeda), stok (merah bila habis atau minus).
  - Produk dengan beberapa varian atau satuan konversi membuka dialog
    pilihan, mis. "2 L · botol", "2 L · Dus (6)", "1 L", masing-masing
    dengan harganya.
  - Panel **Pesanan**: baris item dengan "jumlah × harga · satuan", catatan
    "grosir ≥ N", tombol −/+, total baris. Ketuk angka jumlah untuk
    mengetik jumlah, termasuk pecahan "0,5". Di bawah: Subtotal, **Diskon
    grosir**, **Total**, *Kosongkan*, dan **Bayar Rp X**.
- **Kasir ponsel (1.11 / 1.11b)**: daftar produk satu kolom dengan tombol +,
  bilah bawah "N produk · M item" + total + *Bayar*, dan sheet bawah berisi
  pesanan lengkap.
- **Pembayaran (1.5)** sebagai tahap di layar kasir:
  - Judul "Pembayaran · Total Rp X" dan jumlah item, tombol ← kembali ke
    pesanan tanpa kehilangan isi keranjang.
  - Metode *Tunai* (hitung kembalian), *Kartu debit / kredit* (EDC
    terpisah), dan *Transfer bank*.
  - Tunai: *Uang diterima* berawalan Rp (bisa diketik atau lewat keypad
    1–9, 000, 0, ⌫), nominal cepat *Uang pas* lalu pecahan Rp 10.000 /
    50.000 / 100.000 terdekat, dan kotak **Kembalian** atau "Kurang Rp X".
    Di ponsel kotak kembalian menempel di atas tombol selesai.
  - Kartu: *No. approval kartu (opsional)*; transfer: *Referensi transfer
    (opsional)*; keduanya maksimal 40 karakter dan jumlah dibayar = total.
  - Galat simpan ditampilkan dengan pesan yang jelas (sesi sudah ditutup,
    produk tidak tersedia lagi, uang kurang) dan keranjang tetap utuh.
- **Pembayaran berhasil (1.5c)**: nomor nota di judul, "Tunai Rp X · HH.mm
  · kasir", **Kembalian** besar, peringatan **Stok jadi minus** per varian,
  pratinjau struk 58 mm (toko, cabang, no, tanggal, kasir, item, total,
  bayar, kembali), dan **Transaksi baru** yang memuat ulang stok terbaru.
- **Nomor nota** `CABANG-PERANGKAT-YYMMDD-NNNN` (mis.
  `PST-K01-261103-0001`), urut per perangkat per hari menurut zona waktu
  cabang, jadi tidak bentrok walau beberapa kasir offline.
- **Sesi kasir**: tutup sesi kini menampilkan jumlah transaksi dan total
  penjualan; *Seharusnya di laci* memuat penjualan tunai bersih
  (diterima − kembalian); kartu dan transfer tampil di baris non-tunai.
- Teks Beranda diperbarui sesuai modul yang sudah bisa dipakai.

### Diubah

- Menu *Kasir* tidak lagi membuka halaman "segera hadir".

### Diperbaiki

- Kolom cari kasir kehilangan fokus saat produk atau tombol keranjang
  diklik dengan mouse, sehingga scan barcode berikutnya tidak masuk. Di
  tablet/desktop kolom kini tetap fokus, dan fokus kembali setelah dialog
  pilihan atau ubah jumlah ditutup.
- Saat uji manual ditemukan dan diperbaiki sebelum rilis:
  - Dialog pilihan varian gagal tata letak karena baris harga memakai
    `Expanded` langsung di dalam tombol; isi tombol kini dibungkus agar
    lebar terbatas.
  - Teks tombol panjang (mis. "Bayar Rp 282.500") meluap di layar sempit;
    teks kini terpotong rapi dengan elipsis.
  - Baris nomor nota di pratinjau struk meluap; kolom kiri/kanan kini
    berbagi lebar.
  - "Kurang Rp X" tidak rata kanan di kotak kembalian.
  - Di ponsel kotak kembalian tersembunyi di bawah keypad; kini selalu
    terlihat di atas tombol selesai.
  - Varian tanpa satuan konversi tampil tanpa nama satuan di dialog
    sehingga sulit dibedakan; satuan dasar kini disebut untuk semua varian
    bila produk punya satuan konversi.

### Catatan teknis

- Domain (`lakuna_domain`): `priceSaleLine` (harga grosir hanya untuk
  satuan dasar, satuan konversi memakai harga satuannya atau harga varian ×
  isi), `SaleTotals`, `receiptPrefix`, `nextReceiptCounter`, `cashChange`,
  `quickCashAmounts`, `validatePaymentReference`, dan `outletLocalTime`.
- Model Serverpod baru `sales`, `sale_items`, `payments` (enum
  `SaleStatus`, `PaymentMethod`, `PaymentStatus` disimpan byName) dengan
  migrasi `penjualan`; nomor nota unik per tenant.
- `checkoutSale` (`lakuna_data`) menulis nota, item, pembayaran, dan
  gerakan stok sumber `sale` (biaya = HPP rata-rata atau harga beli) dalam
  satu transaksi lewat `LakunaStore.write`, sehingga semuanya tercatat di
  outbox sinkronisasi. Harga selalu dihitung ulang dari database, bukan
  dari layar.
- `CashierViewModel` memegang keranjang dan tahap bayar (`browse`, `pay`,
  `done`); bayar bukan rute terpisah agar keranjang tidak perlu dioper.
  Repositori aplikasi bernama `CashierRepository` karena Serverpod sudah
  membuat `SaleRepository`.
- Tes baru: 10 tes data penjualan, 4 tes repositori lokal kasir, 17 tes
  view model, dan 5 alur widget (tablet, desktop, kartu + galat, ponsel,
  tanpa sesi).

## [0.5.0] - 2026-11-03

Katalog produk (F1-07, layar 1.15, 1.15m, dan 1.16): pemilik atau manajer
mengisi produk dengan varian, satuan konversi, harga grosir bertingkat, dan
stok awal. Inti katalog ini dibangun lebih dulu daripada Kasir retail (F1-04)
karena kasir hanya bisa menjual barang yang ada di katalog.

### Ditambahkan

- **Menu *Produk*** (rute `/produk`) di kelompok Inventori dan navigasi bawah
  ponsel, untuk staf dengan izin `products:manage`.
- **Daftar produk & stok (1.15)**:
  - Ringkasan "N produk aktif · M di bawah stok minimum", kotak cari (nama,
    SKU, barcode varian atau satuan), dan pilihan kategori.
  - Tabel Produk / Kategori / Varian · satuan / Harga beli / Harga jual /
    Grosir / Stok. Produk satu varian menampilkan satuan konversinya
    ("botol · Dus (6)"); produk banyak varian menampilkan rentang harga.
  - Pil stok: biru muda (hijau di ponsel dan mode gelap) bila aman, kuning
    bila di bawah stok minimum, dan "—" untuk jasa dan menu yang tidak
    melacak stok. Di bawah 900 px kolom Kategori dan Harga
    beli disembunyikan.
  - Keadaan kosong dengan tombol *Tambah produk pertama*, dan pesan "tidak
    ada yang cocok" saat pencarian kosong.
- **Daftar produk ponsel (1.15m)**: kartu produk, chip *Semua* / *Di bawah
  minimum (N)* / per kategori, dan tombol tambah melayang.
- **Form produk (1.16)** (rute `/produk/baru` dan `/produk/:id`):
  - Kartu *Info dasar*: nama, kategori dan satuan dasar (isian dengan saran,
    kategori/satuan baru dibuat otomatis), jenis (Barang / Jasa / Menu),
    SKU induk, merek, *Dijual di kasir*, *Kena pajak*.
  - Tab *Varian*: nama, SKU, barcode, harga beli, harga jual, stok minimum,
    dan stok awal (hanya untuk varian baru).
  - Tab *Satuan & konversi*: baris satuan dasar, lalu satuan lain dengan
    isi, harga beli, harga jual (kosong = harga varian × isi), dan barcode.
  - Tab *Harga grosir*: tingkat "mulai jumlah" dan harga per satuan dasar.
  - Galat ditandai di field dan baris yang tepat, tab yang bermasalah diberi
    titik merah dan dibuka otomatis, termasuk SKU/barcode yang sudah dipakai
    produk lain ("Sudah dipakai <produk>").
  - Di layar sempit tabel berubah menjadi kartu per baris dan label tab
    dipendekkan (*Satuan*, *Grosir*).
- **Stok sebagai ledger**: stok awal dicatat sebagai pergerakan stok sumber
  *stok awal*; saldo dan harga pokok rata-rata disimpan di cache per lokasi
  yang diperbarui di transaksi yang sama.
- Format jumlah Indonesia (koma desimal, titik ribuan) untuk isi satuan dan
  stok, dengan pemformat input.

### Diubah

- Menu *Produk* tidak lagi membuka halaman "segera hadir".
- Galat repositori `NotPermitted` dan `StoreNotReady` dipindah ke berkas
  bersama agar dipakai semua repositori.

### Catatan teknis

- Aturan bisnis katalog di `lakuna_domain` (`catalog.dart`): validasi draf
  produk (panjang, wajib, tidak negatif, isi > 1, satuan ≠ satuan dasar,
  tingkat grosir ≥ 2 dan tidak kembar, SKU/barcode unik di draf),
  `unitPriceFor` (grosir), `conversionSellPrice`, `movingAverageCost`, serta
  `Qty.format` / `Qty.tryParse`.
- Model Serverpod baru di `lakuna_server/lib/src/catalog/`: `categories`,
  `units`, `products`, `product_variants`, `product_units`, `price_tiers`,
  `stock_movements`, dan cache klien `stock_levels`. Migrasi `produk`.
  Kelas model diberi nama `ProductCategory`, `MeasureUnit`, dan
  `ProductPriceTier` agar tidak bentrok dengan kelas `<Model>Repository`
  buatan Serverpod dan `Category` Flutter.
- `lakuna_data`: `saveProduct` menulis semua baris dalam satu transaksi
  sync (satu stempel HLC), mencocokkan varian/satuan/tingkat lama dengan id
  dan men-soft-delete yang dihapus, serta hanya memperbarui baris yang
  berubah. `recordStockMovement` dan `rebuildStockLevels` untuk ledger stok.
- Rute produk dibuat bersebelahan (bukan bersarang) agar daftar dimuat ulang
  setelah kembali dari form.
- Debug: kartu produk ponsel meluap 26 px di layar 320 px (diperbaiki
  dengan pembagian lebar kolom), harga grosir kosong sempat dilaporkan
  "harus lebih dari 0" alih-alih "wajib diisi" (urutan galat diperbaiki),
  dan tombol tambah baris tidak tertekan di tes karena kuncinya ada di
  pembungkus selebar kartu.
- Temuan review sebelum rilis yang sudah diperbaiki:
  - jumlah setengah diketik ("12," atau ",5") sempat terbaca nol sehingga
    stok awal hilang; `Qty.tryParse` kini menerimanya;
  - galat di beberapa tab kini membuka tab pertama menurut urutan form;
  - varian terpilih tidak lagi bergeser saat varian lain dihapus;
  - baris tidak bisa dihapus selama menyimpan;
  - judul baris dan petunjuk harga satuan ikut berubah saat diketik;
  - spanduk galat muncul untuk galat field mana pun;
  - pil stok ponsel menampilkan stok varian yang kurang.
- Tes baru: 28 tes domain, 19 tes data, 24 tes aplikasi (view model, alur
  widget desktop dan ponsel 320 px).

## [0.4.0] - 2026-11-03

Sesi kasir (F1-03, layar 1.3 dan 1.3b): kasir membuka laci dengan saldo
awal, mencatat uang masuk dan keluar, lalu menutup sesi dengan menghitung
uang fisik per pecahan dan melihat selisihnya.

### Ditambahkan

- **Menu *Sesi kasir*** (rute `/sesi-kasir`) di kelompok Penjualan dan di
  navigasi bawah ponsel, untuk staf dengan izin `cash_session:open`.
- **Buka sesi kasir**: kartu dengan baris konteks usaha · cabang · perangkat
  · staf, *Saldo awal laci* berawalan "Rp" (titik ribuan otomatis saat
  diketik), dan catatan opsional. Satu sesi terbuka per perangkat.
- **Kas laci (1.3b)**:
  - Kartu *Sesi aktif* "Dibuka HH.mm oleh <nama> · <perangkat>" (jam zona
    cabang) dengan *Perkiraan uang di laci*.
  - Tabel *Gerakan kas sesi ini* (Jam / Keterangan / Sumber / Jumlah): baris
    saldo awal tebal, uang masuk hijau dengan "+", uang keluar merah dengan
    "−". Di layar sempit kolom Sumber dilipat ke bawah Keterangan.
  - Formulir *Catat uang laci* dengan tab *Uang keluar* / *Uang masuk*,
    jumlah, keterangan wajib, dan tombol *Simpan* (butuh
    `cash_movements:create`). Formulir kosong lagi setelah tersimpan.
- **Tutup sesi (1.3)**:
  - Kartu *Transaksi*, *Penjualan*, *Void / retur* (masih 0 sampai modul
    penjualan ada).
  - *Rekap kas laci*: saldo awal, penjualan tunai, uang masuk lain, uang
    keluar, **Seharusnya di laci**, dan baris QRIS statis · kartu yang tidak
    masuk laci.
  - *Hitung uang fisik*: lembar Rp 100.000 sampai Rp 1.000 dengan subtotal,
    *Receh* sebagai nominal, *Uang dihitung*, dan pil *Selisih* (kuning bila
    ada selisih, hijau "Pas").
  - *Catatan selisih* wajib bila selisih tidak nol; tombol *Tutup sesi*
    (butuh `cash_session:close`).
  - Kartu hasil (seharusnya, dihitung, selisih, catatan) dengan tombol
    *Buka sesi baru*.
  - Masuk ke *Tutup sesi* memuat ulang rekap terbaru. Hitungan, catatan
    selisih, dan formulir uang laci selalu kosong setiap berpindah antara
    kas laci dan tutup sesi, sehingga tidak ada isian tak tampak yang ikut
    tersimpan.

### Diubah

- Navigasi bawah ponsel kini memuat *Sesi kasir* di antara Kasir dan
  Produk (item tetap disaring izin).

### Keamanan

- Izin dicek di UI dan di repositori aplikasi: buka sesi butuh
  `cash_session:open`, tutup `cash_session:close`, uang masuk/keluar
  `cash_movements:create`. Tanpa izin, repositori menolak dengan
  `NotPermitted` sebelum menulis.
- Semua query sesi kasir dibatasi `tenant_id`, `outlet_id`, dan
  `device_id`; sesi perangkat atau cabang lain tidak terbaca atau tertutup.

### Catatan teknis

- Model Serverpod baru `CashSession` (`cash_sessions`) dan `CashMovement`
  (`cash_movements`) dengan enum `CashSessionStatus` dan `CashDirection`
  (`inflow`/`outflow`, karena `in` kata kunci Dart). Migrasi
  `sesi-kasir` untuk server dan klien.
- `lakuna_domain`: `CashDrawer.expectedCash` (saldo awal + penjualan tunai −
  retur tunai + masuk − keluar), `CashDrawer.fromMovements`, `CashCount`
  (total pecahan + receh, JSON rincian), dan validasi saldo awal, uang laci,
  serta catatan selisih. Panjang catatan (maks. 200) dihitung per karakter
  yang tampak (paket `characters`), sama dengan penghitung field, sehingga
  emoji tidak membuat catatan ditolak diam-diam.
- `lakuna_data`: `openCashSession`, `findOpenCashSession`,
  `recordCashMovement`, `listCashMovements`, `cashDrawerFor`,
  `closeCashSession`. Semua tulis lewat `LakunaStore.write` dengan aktor
  staf sehingga tercatat di outbox. Pemeriksaan "masih terbuka" dan
  pembaruan sesi berada dalam satu transaksi, jadi menutup dua kali ditolak
  (`CashSessionNotOpen`) tanpa menimpa hasil pertama.
- Aplikasi: `CashDrawerRepository` (nama `CashSessionRepository` sudah
  dipakai kode generate Serverpod), `CashSessionViewModel`, formatter
  `RupiahInputFormatter`, dan `formatClock` (jam zona cabang).
- Sesi yang dibuka atau ditutup di layar lain memuat ulang layar dengan
  pesan, bukan galat diam.
- Baris nominal di rekap, hitung uang, dan kartu hasil tidak meluap di
  ponsel 320 px dengan nominal jutaan (diuji di tes widget).

## [0.3.0] - 2026-11-03

Login PIN & ganti kasir (F1-02, layar 1.2): beberapa staf bergantian memakai
satu perangkat dengan PIN 6 digit, dan menu mengikuti izin role.

### Ditambahkan

- **Layar "Siapa yang bertugas?" (1.2)** setiap kali aplikasi dibuka:
  - Baris konteks usaha · cabang · perangkat, lalu grid staf aktif di cabang
    ini (avatar inisial, nama, role). Pemilik di urutan pertama.
  - Kartu *Masukkan PIN* dengan 6 titik dan keypad 1–9 / Batal / 0 / ⌫
    (tombol 64 px). PIN langsung diperiksa setelah digit ke-6.
  - Keyboard fisik: angka, Backspace, dan Esc.
  - Staf tanpa PIN tampil nonaktif dengan keterangan "Belum punya PIN".
  - Tautan *Masuk dengan email & kata sandi (pemilik)*.
  - Mobile: daftar staf dulu, lalu kartu PIN dengan tombol *Pilih staf lain*.
- **Kunci sementara**: 5 kali PIN salah mengunci PIN staf itu 60 detik,
  dengan pesan sisa percobaan dan hitung mundur. Login email pemilik
  dibatasi dengan aturan yang sama per email.
- **Tombol *Ganti kasir*** di bilah atas beserta nama dan role staf yang
  bertugas (ikon saja di ponsel). Beranda menampilkan baris *Bertugas*.
- **Menu dan rute sesuai izin**: Kasir dan Riwayat butuh `sales:create`,
  Produk `products:manage`, Stok `stock:adjust`, Pembelian
  `purchases:manage`, Pelanggan `customers:manage`, Supplier
  `suppliers:manage`, Pengeluaran `expenses:manage`, Laporan `reports:view`,
  Pengguna `users:manage`. Membuka rute modul tanpa izin dialihkan ke
  Beranda.
- **Kolom *Ulangi kata sandi*** di langkah 3 setup toko (kanvas 1.1b),
  berdampingan dengan kata sandi, seperti *Ulangi PIN*.

### Diubah

- Setelah *Mulai jualan* di wizard setup, pemilik langsung bertugas tanpa
  mengetik PIN. Membuka ulang aplikasi selalu menampilkan layar login.
- Kolom ulangi (kata sandi dan PIN) yang kosong kini bergalat "Wajib diisi",
  bukan "tidak sama".
- Lencana offline di bilah atas tablet memakai bentuk ringkas agar nama staf
  dan tombol *Ganti kasir* muat.

### Diperbaiki

- Teks Inggris sisa percobaan memakai bentuk tunggal ("1 attempt left").
- Teks tombol panjang (tautan login pemilik, label keypad) tidak lagi
  meluap di layar sempit; tautan dibungkus dan label keypad diperkecil.
- Kartu staf terpilih tidak lagi bergeser 1 px karena bingkai 2 px.
- Angka keypad yang nonaktif (saat dikunci) kini tampak redup; sebelumnya
  gaya teks angka menimpa warna nonaktif tombol.

### Keamanan

- PIN dan kata sandi diverifikasi terhadap hash Argon2id di isolate
  terpisah; tidak ada PIN atau kata sandi asli yang disimpan.
- Email yang tidak terdaftar memberi pesan yang sama dengan kata sandi salah,
  sehingga daftar email pemilik tidak bocor.
- Selama dikunci, verifikasi tidak dijalankan sama sekali, termasuk untuk PIN
  yang benar. Kunci tetap tampil (keypad nonaktif + hitung mundur) setelah
  berpindah staf lalu kembali.
- Percobaan bersamaan untuk staf atau email yang sama diantrekan, sehingga
  tidak ada percobaan ke-6 yang lolos sebelum kunci tercatat.
- Email tak dikenal tetap menjalankan Argon2id terhadap hash tiruan, agar
  waktu respons tidak membedakan email terdaftar.

### Catatan teknis

- `lakuna_domain`: `PinGuard` (5 kali salah → kunci 60 detik, jam bisa
  disuntik), `permissionsForRole` (kunci tak dikenal → tanpa izin, pemilik
  selalu semua izin), `staffInitials`; `SetupInput.passwordConfirm` dan
  `SetupError.passwordMismatch`.
- `lakuna_data`: `OutletStaff`, `listOutletStaff`, `findStaffById`,
  `findOwnerByEmail` (dibatasi `tenant_id`/`outlet_id`). Tidak ada tabel atau
  migrasi baru; sesi hanya di memori.
- `lakuna_flutter`: `SessionRepository` (abstrak, lokal, palsu untuk tes)
  dengan galat bertipe `WrongPin`, `CredentialsLocked`, `WrongCredentials`,
  `StaffUnavailable`; `LoginViewModel`; rute `/masuk`; router mendengarkan
  toko dan sesi sekaligus; `MenuEntry.permission`, `visibleMenu`,
  `mobileMenu(permissions)`.
- Saat debug, kegagalan login dengan kata sandi yang benar di Xvfb ternyata
  akibat `xdotool` (Ctrl+A tidak memilih teks); diulang dengan Backspace dan
  berhasil. Tes repositori lokal memakai hash Argon2id sungguhan.
- Review subagent sebelum merge menemukan kunci yang hilang saat berganti
  staf (Important), plus antrean percobaan, kebocoran waktu email, satu query
  keanggotaan tanpa `tenant_id`, dan teks Inggris "1 attempts"; semuanya
  diperbaiki dengan tes.
- Tes: 49 domain, 25 data, 78 Flutter.

## [0.2.0] - 2026-11-03

Setup toko pertama (F1-01, layar 1.1): instal baru langsung punya toko siap
jualan dalam 4 langkah, tanpa internet.

### Ditambahkan

- **Wizard setup toko 4 langkah** yang terbuka otomatis saat database belum
  punya toko:
  1. Bahasa & tema (berlaku langsung).
  2. Jenis usaha (Retail, F&B, Campuran), nama usaha, cabang, kode cabang,
     kode perangkat, dan zona waktu (WIB/WITA/WIT), dengan pratinjau nomor
     nota (mis. `PST-K01-261103-0001`) yang berubah saat kode diketik.
  3. Akun pemilik: nama, email, kata sandi, dan PIN 6 digit.
  4. Ringkasan dan tombol *Mulai jualan*. Data baru ditulis saat tombol ini
     ditekan.
- Tata letak tablet/desktop dengan panel Sky dan stepper di kiri. Di ponsel
  panel diganti progress bar, dan tombol ditumpuk selebar layar. Sakelar
  bahasa ID/EN ada di setiap langkah.
- Setup menulis **dalam satu transaksi**: tenant, cabang, perangkat ini,
  lokasi stok "Etalase", pemilik (role `owner`), dan keanggotaannya di
  cabang. Semua baris tercatat di outbox sinkronisasi dengan aktor pemilik.
- Kata sandi dan PIN disimpan sebagai hash **Argon2id** (memori 19 MiB,
  2 iterasi, salt acak 16 byte), dihitung di isolate terpisah agar UI tidak
  macet.
- Beranda menampilkan toko aktif: usaha · cabang · kode perangkat.

### Diubah

- Router mengarahkan semua jalur ke `/setup` selama toko belum ada, dan
  menolak `/setup` setelah setup selesai.
- Pilihan tema dan bahasa di Pengaturan menjadi komponen bersama yang juga
  dipakai langkah 1 setup.

### Diperbaiki

- Panel samping wizard meluap di layar pendek (setinggi 800 px dengan teks
  besar). Ditemukan oleh tes widget; panel kini bisa digulir dan catatan
  tetap di bawah bila muat.
- Label tombol wizard terpotong di ponsel selebar 400 px. Ditemukan oleh tes
  widget; di ponsel tombol kini ditumpuk.
- Kode cabang dan perangkat tampil huruf kecil saat diketik di desktop,
  karena `textCapitalization` hanya berlaku di keyboard layar. Ditemukan saat
  uji manual di Xvfb; kini disaring ke huruf/angka dan langsung dijadikan
  huruf besar.
- Temuan review kode sebelum rilis:
  - Pesan "Toko gagal disimpan" tetap tampil setelah pengguna kembali dan
    mengubah isian. Kini hilang saat kembali ke langkah sebelumnya.
  - Tanggal pratinjau nomor nota memakai jam perangkat, bukan zona waktu
    yang dipilih. Pada 23.30 WIB, toko WIT sudah berganti tanggal. Kini
    mengikuti WIB/WITA/WIT yang dipilih.
  - Bila toko sudah ada tetapi konteksnya belum termuat, setup gagal terus
    dengan pesan umum. Kini setup memuat ulang toko yang ada. Bila datanya
    tidak lengkap, tampil pesan khusus (pulihkan dari backup), dan galat
    saat memuat toko ketika aplikasi dibuka dicatat di log.

### Keamanan

- PIN dan kata sandi tidak pernah disimpan dalam teks asli. Hash memakai
  format PHC sehingga parameter bisa dinaikkan nanti tanpa memutus hash
  lama.

### Catatan teknis

- Migrasi `onboarding` menambah kolom `staff_members.password_hash`.
- `lakuna_domain`: `SetupInput` (validasi per field dan per langkah),
  `CredentialHasher` (paket `hashlib`, murni Dart), `BusinessKind`, dan
  `setupTimezones`.
- `lakuna_data`: `setupStore()`, `loadStoreContext()`, `StoreContext`, serta
  `SetupAlreadyDone` dan `SetupInvalid`. Keduanya ditolak sebelum ada yang
  ditulis.
- Aplikasi: `StoreRepository` (`ChangeNotifier`, didengar router) dengan
  versi lokal dan palsu, `OnboardingViewModel`, dan `OnboardingScreen`.
- Metode bayar dan satuan bawaan dibuat oleh modulnya sendiri (F1-05 dan
  F1-07), bukan di onboarding seperti di Storeku.
- Produk pertama dan import Excel (langkah 4 di kanvas) dipindah ke modul
  Produk (F1-07).

## [0.1.1] - 2026-11-03

Keterbacaan mode gelap mengikuti aturan kontras kanvas "Desain UI Lakuna".

### Diubah

- **Tombol destructive** (hapus, batalkan) kini berisi warna penuh dengan
  teks putih: `#E7000B` di tema terang dan `#C10007` di tema gelap (6,2:1).
  Sebelumnya tema gelap memakai latar merah transparan dengan teks `#FF6467`.
- **Menu dan ikon aktif di tema gelap** (navigasi bawah ponsel, ikon di daftar
  Pengaturan) memakai Sky muda `#74D4FF` (11,9:1). Sebelumnya `#00598A`
  yang hanya sekitar 2,7:1 di latar gelap sehingga sulit dibaca.
- **Label tab tidak aktif di tema terang** memakai `#52525C` (7:1 di latar
  tab), menggantikan `#71717B` (4,4:1).
- Build lokal tanpa `--dart-define=LAKUNA_VERSION` menampilkan versi `dev`,
  bukan angka versi lama.

### Diperbaiki

- Ikon di dalam grup daftar (`FTileGroup`) tetap memakai biru gelap walau
  gaya tile sudah diganti, karena grup membawa gaya tile sendiri. Ditemukan
  saat uji manual mode gelap di Xvfb; grup tile dan item kini memakai warna
  yang sama.
- Ikon Material bawaan (di dialog, sheet, dan rute Material lain) memakai
  `#00598A` di tema gelap (2,6:1). Ditemukan saat review kode; kini memakai
  warna teks utama.

### Dihapus

- Workflow `deploy.yml` dan paket `serverpod_cloud_storage` bawaan template
  Serverpod. Lakuna tidak memakai Serverpod Cloud; server Fase 2 berjalan di
  VPS sendiri. Penyimpanan berkas server sementara memakai database.

### Catatan teknis

- Aturan kontras ada di `lakuna_flutter/lib/ui/core/theme/contrast.dart`;
  token warna dasar tetap hasil CLI Forui. `theme_contrast_test.dart`
  merender widget dan memeriksa warna serta rasio kontras (≥ 4,5:1): tombol
  destructive (kedua tema), isi tombol primary gelap yang tidak berubah,
  navigasi bawah (kedua tema), tab tidak aktif terang, ikon tile dan grup
  tile gelap, ikon Material bawaan, dan pasangan token teks utama.

## [0.1.0] - 2026-11-03

Fondasi Lakuna: monorepo Flutter + Serverpod, database lokal dengan outbox
sinkronisasi, dan kerangka aplikasi dengan tema Forui `conhcc`.

### Ditambahkan

- **Monorepo pub workspace** berisi `lakuna_flutter` (aplikasi),
  `lakuna_server` + `lakuna_client` (Serverpod 4.1),
  `packages/lakuna_domain`, dan `packages/lakuna_data`.
- **Aturan bisnis dasar** di `lakuna_domain`: `Money` (rupiah bulat, format
  `Rp 12.500`), `BasisPoints`, `Qty` (mili-satuan, konversi satuan),
  pembulatan setengah menjauhi nol, ID UUIDv7, katalog 21 izin dan 5 role
  bawaan (pemilik, manajer, kasir, pelayan, petugas gudang), nomor nota dan
  dokumen yang memuat kode outlet + perangkat
  (`PST-K01-261103-0001`), dan hybrid logical clock (HLC).
- **Model data fondasi** di Serverpod (`database: all`): tenants, outlets,
  stock_locations, devices, settings, staff_members, outlet_members, dengan
  kolom sinkronisasi standar (`created_at`, `updated_at`, `deleted_at`,
  `created_by`, `updated_by`, `version`, `hlc`, `origin_device_id`).
- **Tabel lokal perangkat** (`database: client`): sync_outbox,
  sync_state, local_preferences.
- **`LakunaStore` dan `SyncTx`**: membuka database SQLite di perangkat,
  menjalankan migrasi, membuat ID perangkat sekali, dan menulis setiap
  perubahan data bersama entri outbox sinkronisasi dalam satu transaksi.
  `SyncTx` menolak baris yang kolom `hlc`, `origin_device_id`, atau
  `created_by`/`updated_by`-nya tidak sesuai stempel transaksi, supaya
  sinkronisasi fase 2 tidak kehilangan perubahan.
- **Pengaturan bertingkat**: tabel `settings` memakai `scope_key`
  (`'tenant'` atau `'outlet:<id>'`) agar pengaturan tingkat tenant tidak bisa
  ganda.
- **Aplikasi Lakuna**:
  - Tema Forui preset `conhcc` (Zinc + Sky, Montserrat, DM Sans, ikon
    Tabler) dengan varian sentuh untuk Android/iOS.
  - Bahasa Indonesia (bawaan) dan Inggris.
  - Navigasi responsif: navigasi bawah di ponsel, sidebar di tablet dan
    desktop, dengan menu semua modul Fase 1.
  - Beranda yang menampilkan versi, ID perangkat, dan lokasi data.
  - Pengaturan tampilan (Terang / Gelap / Ikuti sistem) dan bahasa, tersimpan
    di perangkat.
  - Lencana "Offline" di bilah atas.
  - Halaman "segera hadir" untuk modul yang belum dibangun.
- **Aset offline**: font Montserrat dan DM Sans dibundel di aplikasi beserta
  lisensinya; tidak ada font atau gambar yang diunduh saat aplikasi jalan.
- **CI paralel** di runner GitHub-hosted: format, analyze, cek kode generate,
  tes domain, data, server, dan Flutter, serta build Linux, Windows, macOS,
  Android, dan iOS.
- **Rilis otomatis** setelah merge ke `main`: Windows `.exe` (Inno Setup) dan
  `.msi` (WiX), Linux `.deb`, macOS `.dmg`, Android `.apk` dan `.aab`, iOS
  `.ipa` tanpa tanda tangan, lalu tag dan GitHub Release dari CHANGELOG.
- **Dukungan pengembangan dengan AI**: `AGENTS.md`, `CLAUDE.md`, server MCP
  Serverpod dan Dart (`.mcp.json`), dan skill Serverpod/Flutter di
  `.claude/skills/`.
- Spec fondasi, indeks spec, dan rencana pengerjaan di `docs/superpowers/`.

### Diperbaiki

- Judul di bilah atas meluap (RenderFlex overflow) pada layar ponsel selebar
  400 px. Ditemukan oleh tes tata letak mobile; diperbaiki dengan lencana
  offline ringkas (ikon saja, tetap punya label aksesibilitas dan tooltip)
  dan judul yang dipotong dengan elipsis.

- Temuan review kode sebelum rilis:
  - Urutan teks HLC bisa salah bila counter melewati 9999 (mis. setelah jam
    perangkat sempat maju lalu dikoreksi). Sekarang HLC pindah ke milidetik
    berikutnya.
  - Indeks unik `settings` memakai `outlet_id` yang boleh kosong sehingga
    pengaturan tingkat tenant bisa tersimpan dua kali. Diganti `scope_key`.
  - CompanyName Windows masih nilai template dan menentukan folder data
    (`%APPDATA%`). Sekarang `Lakuna`, sebelum ada data pengguna.
  - `Money` bisa dibandingkan dengan angka mentah (`Comparable<num>`).
    Sekarang hanya dengan `Money`.
  - Nama installer WiX memakai `$(var.…)` eksplisit; workflow deploy
    Serverpod memakai Flutter 3.47.9.

### Keamanan

- `config/passwords.yaml` server tidak di-commit. CI memakai kata sandi
  khusus tes lewat variabel `SERVERPOD_PASSWORD_*`. `docker-compose.yaml`
  bawaan template masih memuat kata sandi Postgres pengembangan lokal (bukan
  rahasia produksi).
- Kunci rilis Android dibaca dari secret repo dan tidak pernah di-commit.

### Catatan teknis

- Satu skema model `.spy.yaml` menghasilkan database SQLite di perangkat
  (tabel `STRICT`, ID UUIDv7) dan PostgreSQL di server. Nama kolom ditulis
  eksplisit `snake_case` dengan `column=` karena bawaan Serverpod camelCase.
- Arsitektur aplikasi mengikuti panduan resmi Flutter: view model
  `ChangeNotifier`, repositori dengan versi palsu untuk tes, `Command` +
  `Result`, `provider`, dan `go_router`.
- HLC tetap naik walau jam perangkat mundur (diuji).
- Rollback transaksi membatalkan baris data dan entri outbox bersama-sama
  (diuji).
- ID aplikasi di semua platform: `id.lakuna.app`.
- Paket Android ditandatangani kunci rilis bila secret
  `ANDROID_KEYSTORE_*` sudah diisi. Tanpa secret, berkas diberi akhiran
  `-uji`, ditandatangani kunci debug, dan catatan rilis memperingatkan bahwa
  pembaruan ke versi berikut menghapus data. iOS belum ditandatangani.
- Installer Windows `.exe` dan `.msi` memasang ke folder yang sama; pakai
  salah satu saja.
- Tes integrasi server memakai PostgreSQL tertanam Serverpod dan berjalan di
  CI.

[Unreleased]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.6.0...HEAD
[0.6.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/yusufabdillahputra/yap-lakuna/releases/tag/v0.1.0
