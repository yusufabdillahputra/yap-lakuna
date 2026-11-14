# F1-16 · Laporan & laba rugi

- **Fase:** 1
- **Status:** Rilis v0.20.0 (ringkasan, penjualan, produk terlaris, laba
  rugi, unduh PDF/Excel) dan v0.21.0 (stok, kas & sesi, piutang & hutang,
  retur)
- **Layar desain:** 1.23 *Laporan · desktop* (ringkasan), 1.24 *Laporan
  laba rugi · desktop*
- **Acuan Storeku:** `docs/superpowers/specs/2026-11-02-f1-16-laporan-design.md`

## Tujuan

Pemilik dan manajer melihat kinerja toko (penjualan, laba, beban) per
periode untuk cabang ini, lalu mengunduhnya sebagai PDF atau Excel, tanpa
koneksi internet.

## Lingkup

v0.20.0 (bagian ini):

- Menu **Laporan** (`/laporan`) menggantikan *Segera hadir*, untuk staf
  dengan `reports:view`.
- Tab **Ringkasan** (1.23): kartu Penjualan (N transaksi), Laba kotor
  ("Dari harga pokok saat jual", hanya dengan `reports:view_profit`),
  Rata-rata per nota, Piutang jatuh tempo (N pelanggan); *Penjualan per
  metode bayar* (batang + persen); *Produk terlaris* (5 teratas);
  *Laporan lengkap* (tautan ke tab dan ke layar Stok, Pelanggan, Supplier,
  Pengeluaran, Sesi kasir).
- Tab **Penjualan**: per produk, per kasir, per kategori.
- Tab **Produk terlaris**: 20 teratas menurut jumlah terjual bersih.
- Tab **Laba rugi** (1.24, hanya `reports:view_profit`): rincian laba rugi +
  panel samping (Laba bersih vs periode sebelumnya, Margin kotor,
  Beban / penjualan, *Cara hitung*).
- **Unduh PDF** dan **Unduh Excel** untuk tab yang aktif dengan periode yang
  aktif.

v0.21.0 (lanjutan modul ini): tab Stok (nilai stok, kartu stok ringkas),
Kas & sesi (rekap sesi, pemasukan & pengeluaran), Piutang & hutang, Retur.

Tidak termasuk: dashboard semua cabang (Fase 2), laporan gaji (Fase 3),
target margin toko (menunggu pengaturan, lihat gap).

## Desain UI

- Header: judul *Laporan*, subjudul `<periode> · <nama cabang>`; kanan:
  pilihan **Periode** (Hari ini, 7 hari terakhir, Bulan ini, lalu 12 bulan
  sebelumnya per nama bulan, mis. *Oktober 2026*), *Unduh PDF*, *Unduh
  Excel*. Satu pilihan periode berlaku untuk semua tab (desain 1.23 memakai
  pil Hari ini/7 hari/Bulan ini dan 1.24 memakai bulan; keduanya digabung).
- Tab di bawah header: Ringkasan, Penjualan, Produk terlaris, Laba rugi.
  Tab Laba rugi tidak tampil tanpa `reports:view_profit`.
- **Ringkasan** (1.23): 4 kartu KPI berjajar (2×2 di tablet, 1 kolom di
  360 px), dua kartu berdampingan (metode bayar, produk terlaris), lalu
  kartu *Laporan lengkap* berisi tombol-tombol tautan.
- **Penjualan**: segmen *Per produk / Per kasir / Per kategori*; tabel
  Nama, Jumlah (qty dalam satuan dasar; untuk kasir = jumlah nota),
  Penjualan bersih, Porsi %; baris total di bawah.
- **Produk terlaris**: peringkat, nama, jumlah, nilai.
- **Laba rugi** (1.24): kartu *Laba rugi · <periode>* / *<cabang> · semua
  kasir* dengan baris persis seperti di bawah; panel kanan (lebar konten ≥ 960 px, mis. layar 1280 px dengan sidebar)
  atau di bawah (lebih sempit).
- Periode tanpa transaksi menampilkan nol, bukan galat.

## Aturan hitung

Semua angka dihitung dari **dokumen** cabang ini (sales, sale_items,
sale_returns, sale_return_items, payments, expenses, stock_adjustments).
Rumus ada di `lakuna_domain` (`report.dart`, murni), pengumpulan data di
`lakuna_data` (`reports.dart`).

- Periode: tanggal lokal cabang (zona waktu outlet, lalu tenant).
  Penjualan masuk menurut `sold_at`, retur menurut `returned_at`,
  pengeluaran menurut `spent_on`, penyesuaian menurut `adjusted_at`.
- Nota yang dihitung: status `completed`, `partiallyReturned`, `returned`.
  `voided` dan `open` (open bill belum lunas) tidak dihitung.

Laba rugi:

```
Penjualan kotor          Σ sales.subtotal (harga daftar)
− Diskon                 Σ sales.tier_discount
+ Service charge         Σ sales.service_amount (baris tampil bila ≠ 0)
− Retur penjualan        Σ (sale_returns.amount − bagian PB1-nya)
= Penjualan bersih
− HPP                    Σ unit_cost × qty dasar baris nota
                         − Σ unit_cost × qty dasar baris retur yang di-restock
= Laba kotor · margin %  (laba kotor / penjualan bersih)
− Beban operasional      Σ expenses.amount per jenis (bukan batal), urut terbesar
= (Total beban operasional)
± Penyesuaian stok       Σ stock_adjustments.total_value (bertanda)
= Laba bersih
```

- **PB1 bukan pendapatan.** Nilai retur sudah memuat bagian service, PB1, dan
  potongan nota; bagian PB1 retur = `amount × tax_amount / total` nota
  (bulat setengah menjauhi nol). *PB1 dipungut* (Σ PB1 nota − Σ PB1 retur)
  tampil sebagai catatan di bawah laba rugi, tidak ikut dihitung.
- **HPP** memakai `sale_items.unit_cost` (biaya rata-rata per satuan dasar
  saat jual, dibekukan; open bill membekukannya saat lunas) ×
  `quantity × factor`. Retur yang tidak di-restock tidak mengurangi HPP
  (barangnya hilang). Berbeda dari Storeku yang membaca `stock_movements`:
  baris nota juga mencakup produk tanpa lacak stok (pakai harga pokok
  varian).
- **Penyesuaian stok**: semua dokumen penyesuaian (selisih opname, rusak,
  hilang, kedaluwarsa, lainnya), nilai bertanda; negatif = rugi. Storeku
  hanya rusak/hilang/kedaluwarsa; di Lakuna selisih opname rutin juga
  mengubah nilai stok sehingga ikut dihitung.
- **Harga pokok kosong**: baris nota dengan `unit_cost = 0` dihitung HPP 0
  dan laporan menampilkan peringatan *N produk terjual tanpa harga pokok*.
- **Perbandingan**: Laba bersih dibanding periode sebelumnya yang sama
  panjang (kemarin, 7 hari sebelumnya, bulan sebelumnya; *Bulan ini*
  dengan tanggal 1 s.d. tanggal yang sama bulan lalu). Persen hanya bila
  laba periode lalu > 0; selain itu tampil nominal periode lalu.
- **Beban / penjualan** = total beban operasional / penjualan bersih.
  Persen dalam basis poin (bilangan bulat), tanpa `double`.

Ringkasan dan penjualan:

- **Penjualan** (kartu) = penjualan bersih laba rugi; *N transaksi* = nota
  terhitung pada periode; *Rata-rata per nota* = penjualan bersih / N.
- **Laba kotor** (kartu) = laba kotor laba rugi.
- **Piutang jatuh tempo** = Σ sisa piutang nota kredit yang sudah lewat
  jatuh tempo (tenant, tidak tergantung periode), N pelanggan.
- **Metode bayar** (nota pada periode, sebelum retur): tunai = jumlah −
  kembalian, kartu, transfer, QRIS = jumlah; *Kredit* = total nota −
  dibayar saat jual. Jumlah semua = Σ total nota. Persen terhadap jumlah itu.
- **Per produk** (kolom *Nilai*, bukan penjualan bersih karena tanpa
  service): kunci varian; jumlah bersih = qty dasar terjual − qty
  dasar diretur (retur pada periode); nilai = `line_total` − nilai retur
  proporsional qty (`line_total × qty retur / qty baris`, bulat ke bawah).
  Satuan = satuan dasar produk saat ini. Nama = nama produk (+ varian) dari
  nota.
- **Per kategori**: per produk dikelompokkan kategori produk saat ini
  (*Tanpa kategori* bila kosong).
- **Per kasir**: kasir nota; jumlah nota dan penjualan bersih (bagian nota −
  retur nota itu tanpa PB1). Jumlah semua kasir = penjualan bersih.
- **Produk terlaris**: urut jumlah bersih menurun, lalu nilai, lalu nama.

## Izin

- `reports:view`: menu Laporan, tab Ringkasan (tanpa laba kotor), Penjualan,
  Produk terlaris.
- `reports:view_profit` (**baru**, `Permission.reportsViewProfit`): kartu
  Laba kotor, tab Laba rugi, angka HPP. Owner dan manager mendapatkannya
  (role bawaan dihitung dari kode, tanpa migrasi data); kasir tidak.
- Lapisan data memeriksa izin staf: tanpa `reports:view` →
  `ReportActorNotPermitted`; tanpa `reports:view_profit` angka laba
  (`profit`) tidak dihitung/dikembalikan.

## Ekspor

- Excel (`buildXlsx` yang sudah ada) dan PDF (paket `pdf` yang sudah dipakai
  struk/kuitansi, font yang dibundel), keduanya dibuat di perangkat.
- Nama berkas: `laporan-<tab>-<periode>-<yymmdd>.(xlsx|pdf)`, mis.
  `laporan-laba-rugi-2026-10-261104.pdf`.
- Isi berkas = tabel tab aktif: judul, periode, cabang, lalu baris tabel
  (laba rugi: label + nilai; ringkasan: KPI, metode bayar, produk terlaris).
- Desktop: disimpan ke folder dokumen Lakuna; Android/iOS: lembar berbagi.

## Data

Hanya baca; tidak ada tabel baru. Query memakai indeks yang ada
(`sales_outlet_sold_idx`, `stock_adjustments_outlet_idx`); baris nota,
retur, dan pembayaran dimuat per 500 id. Indeks tambahan dievaluasi bila
lambat pada data besar.

## Pengujian

- Domain: rumus laba rugi (diskon, service, PB1, retur dengan/ tanpa
  restock, beban, penyesuaian, margin, nol), per produk/kasir/kategori,
  metode bayar, perbandingan periode, rentang periode.
- Data: skenario jual → open bill F&B dengan PB1 → void → retur → pengeluaran
  (termasuk batal) → penyesuaian, dicocokkan dengan angka hitungan manual;
  izin.
- Flutter: view model (periode, tab, izin, ekspor), alur widget 1440 /
  800 / 360 px, ekspor menghasilkan nama berkas yang benar.

## Bagian kedua (v0.21.0): Stok, Kas & sesi, Piutang & hutang, Retur

Desain 1.24 hanya menampilkan nama tab ini; isinya mengikuti pola tab
v0.20.0 (kartu KPI di atas, tabel di bawah, kartu di 360 px) dan aturan
Storeku F1-16. Urutan tab: Ringkasan, Penjualan, Produk terlaris, Laba
rugi, **Stok**, **Kas & sesi**, **Piutang & hutang**, **Retur**. Data tab
ini dimuat saat tab dibuka (bukan saat layar dibuka) dan dimuat ulang saat
periode berganti. Semua butuh `reports:view`.

### Stok

- Cakupan: varian **barang** (`ProductType.goods`) yang belum dihapus, semua
  lokasi stok cabang ini dijumlahkan (transfer antarlokasi saling hapus).
- Kartu: *Nilai stok* (hanya `reports:view_profit`; Σ per lokasi stok saat
  ini × harga pokok rata-rata lokasi itu, atau harga beli bila rata-rata 0,
  sama dengan opname), *Produk barang* (jumlah varian), *Stok menipis* dan
  *Stok habis* (stok di lokasi bawaan dibanding minimum, sama dengan layar
  Stok 1.18).
- Tabel **pergerakan periode** (kartu stok ringkas) per varian yang punya
  stok atau pergerakan pada periode: Produk, Awal, Masuk, Keluar, Akhir
  (qty satuan dasar), Nilai akhir (hanya `reports:view_profit`).
  Awal = Σ pergerakan sebelum awal periode; Masuk = Σ pergerakan positif
  pada periode; Keluar = Σ |pergerakan negatif|; Akhir = Awal + Masuk −
  Keluar. Awal dihitung mundur dari stok saat ini dikurangi pergerakan
  sejak awal periode, jadi hanya pergerakan sejak awal periode yang dimuat.
  Nilai akhir = nilai stok saat ini varian itu bila Akhir = stok saat ini,
  selain itu proporsional (rata-rata tertimbang semua lokasi), sehingga di
  periode yang berakhir hari ini Σ nilai akhir = kartu *Nilai stok*.
  Urut nilai akhir menurun bila boleh melihat nilai, selain itu nama.
- Batas periode: `occurred_at` dalam zona waktu cabang, sama dengan nota.

### Kas & sesi

- Sesi kasir cabang ini yang **aktif** pada periode (dibuka sebelum akhir
  periode dan belum ditutup atau ditutup sesudah awal periode; sesi kemarin
  yang belum ditutup ikut tampil hari ini): Dibuka (tanggal jam),
  Kasir, Saldo awal, Seharusnya, Dihitung, Selisih. Sesi yang masih buka:
  Seharusnya dihitung saat ini (`cashDrawerFor`), Dihitung dan Selisih `–`,
  label *Masih buka*.
- Kartu: *Sesi* (N, M masih buka), *Total selisih* (bertanda, hanya sesi
  tutup), *Kas masuk lain*, *Kas keluar lain* (gerakan kas pada periode).
- Tabel **kas masuk & keluar**: gerakan kas (`cash_movements.created_at`
  pada periode) dikelompokkan sumber: Manual masuk, Manual keluar,
  Pengeluaran, Batal pengeluaran, Bayar hutang supplier, Bayar pembelian,
  Refund retur pembelian, Terima piutang; kolom Sumber, Catatan (jumlah
  baris), Jumlah bertanda (`+` masuk, `−` keluar). Di ekspor ditulis sebagai
  catatan di bawah tabel sesi.

### Piutang & hutang

- Posisi **hari ini**, tidak tergantung periode (subjudul tab menyebut
  tanggal). Data dari `listCustomers` dan `loadSuppliersOverview`. Cukup
  `reports:view` (katalog izin belum punya izin lihat pelanggan/supplier
  tersendiri); hutang supplier dan kas pembelian ikut terlihat.
- Kartu: *Piutang pelanggan* (total, N pelanggan), *Piutang jatuh tempo*
  (total, N pelanggan), *Hutang supplier* (total, N supplier), *Nota beli
  lewat tempo* (jumlah nota).
- Tabel piutang per pelanggan yang punya sisa: Pelanggan, Nota terbuka,
  Lewat tempo, Sisa; tabel hutang per supplier: Supplier, Nota terbuka,
  Lewat tempo, Jatuh tempo terdekat, Sisa. Urut sisa menurun.

### Retur

- Retur penjualan cabang ini dengan `returned_at` pada periode: Waktu, No
  retur, No nota, Petugas, Alasan, Kembali ke stok (Ya/Tidak), Cara refund
  (tunai, transfer, potong piutang; retur nota kredit yang sebagian
  memotong piutang ditulis *Tunai dari laci + potong piutang*), Nilai.
- Kartu: *Retur* (N), *Nilai retur* (Σ `amount`), *Kembali ke stok* (N),
  *Rusak/kedaluwarsa* (N).
- Ringkasan per alasan (jumlah dan nilai).

### Ekspor

Satu tabel per tab seperti v0.20.0; tab dengan dua tabel (Kas & sesi,
Piutang & hutang) menulis keduanya berurutan dengan baris judul bagian
tebal. Nama berkas: `laporan-stok-…`, `laporan-kas-sesi-…`,
`laporan-piutang-hutang-<yymmdd>` (tanpa periode), `laporan-retur-…`.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Tab Stok, Kas & sesi, Piutang & hutang, Retur | 1.24 (nama tab) | Rilis v0.21.0 | Isi dirancang di bagian kedua spec ini; desain rinci bisa ditambahkan ke kanvas. |
| Nilai stok historis | – | Nilai akhir periode lalu memakai harga pokok saat ini | Cukup untuk UMKM; simpan nilai per pergerakan bila dibutuhkan akurasi historis. |
| Target margin toko | "Target toko 25%" | Belum ada pengaturan | Tambah di F1-18 Pengaturan, lalu tampilkan di panel. |
| Rentang tanggal bebas | – | Rilis v0.67.0 | [F1-16b](2026-11-14-f1-16b-rentang-tanggal-laporan-design.md) |
| Filter per kasir | Subjudul "semua kasir" | Rincian per kasir di tab Penjualan | Filter kasir untuk seluruh laporan bila diminta. |
| Semua cabang | Pilihan cabang | Hanya cabang ini (data per perangkat) | Fase 2. |
| Pembulatan total (F1-18) | Baris tersendiri | Belum ada pembulatan | Tambah baris saat pembulatan dibangun. |
| Service charge di rincian | – | Per produk/kategori tanpa service, per kasir dengan service (catatan di tab) | Tambah baris *Service charge* di tabel per produk bila pemilik meminta total yang sama. |
| Indeks pergerakan stok per waktu | – | Tab Stok memuat pergerakan sejak awal periode tanpa indeks `occurred_at` | Tambah indeks `(outlet_id, occurred_at)` bila tab terasa lambat di data besar. |
| Biaya muat | – | Tiap ganti periode memuat periode + pembanding + piutang | Cukup untuk skala UMKM; simpan piutang jatuh tempo di cache bila terasa lambat. |

## Kriteria selesai

Ringkasan, Penjualan, Produk terlaris, dan Laba rugi tampil sesuai desain di
desktop/tablet/mobile; angka laba rugi cocok dengan hitungan manual pada
data uji; ekspor PDF/Excel berfungsi offline.
