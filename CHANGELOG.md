# Changelog

Semua perubahan penting Lakuna dicatat di sini. Format mengikuti
[Keep a Changelog](https://keepachangelog.com/id-ID/1.1.0/) dan versi
mengikuti [Semantic Versioning](https://semver.org/lang/id/). Selama versi
`0.x`, setiap rilis ditandai pre-release.

## [Unreleased]

## [0.19.0] - 2026-11-04

Pengeluaran (F1-15, layar 1.22, 1.3b, dan 1.17). Toko mencatat biaya
operasional di luar pembelian barang dagang per jenis, dari kas toko, kas
laci, atau rekening bank, dengan foto nota, supaya laporan laba rugi (F1-16)
nanti akurat. Pengeluaran tidak pernah diubah nilainya: koreksi dilakukan
dengan membatalkan lalu mencatat ulang.

### Ditambahkan

- Menu **Pengeluaran** (`/pengeluaran`, grup Keuangan) untuk staf dengan
  izin `expenses:manage`; sebelumnya halaman *segera hadir*.
- **Layar 1.22 Pengeluaran**:
  - cari keterangan, nomor, atau jenis; filter periode *30 hari terakhir*
    (bawaan), *Bulan ini*, *Bulan lalu* menurut tanggal cabang;
  - tabel Tanggal, Keterangan, Jenis, Sumber dana (mis. *Kas laci · sesi
    Sari*), Jumlah, Bukti (*Ada foto* / *Tanpa foto*); di kolom sempit
    menjadi daftar kartu;
  - kartu **Per jenis · periode** dengan total dan batang per jenis
    (pengeluaran batal tidak dihitung);
  - kartu **Catat pengeluaran** di kanan (≥ 1000 px) atau tombol *Catat
    pengeluaran* yang membuka dialog (layar lebih sempit): keterangan
    (wajib, ≤ 120), jenis, jumlah (> 0, ≤ Rp 1 miliar), sumber dana,
    tanggal (tidak boleh di masa depan; boleh mundur untuk kas toko dan
    bank), foto nota dari berkas atau kamera (≤ 5 MB);
  - nomor `EX-<OUTLET>-<PERANGKAT>-<yymmdd>-NNNN`;
  - dialog **Rincian pengeluaran**: nomor, tanggal, jenis, sumber dana,
    pencatat, foto nota (ketuk untuk membuka besar dan memperbesar), dan
    **Batalkan pengeluaran** dengan alasan wajib (≤ 200). Pengeluaran batal
    tetap tampil dengan lencana *Dibatalkan* dan jumlah dicoret;
  - **Ekspor Excel** daftar sesuai filter (Tanggal, Nomor, Keterangan,
    Jenis, Sumber dana, Jumlah, Bukti, Status).
- **Kas laci dari Pengeluaran**: wajib sesi kasir terbuka di perangkat ini
  dan izin `cash_movements:create`; menulis uang keluar *Pengeluaran* di
  sesi dalam transaksi yang sama. Membatalkan pengeluaran laci menulis uang
  masuk *Batal pengeluaran* di sesi yang sedang buka (ditolak bila tidak ada
  sesi terbuka).
- **Kas laci 1.3b**: saat *Uang keluar* dipilih, sakelar **Catat juga
  sebagai pengeluaran** (*Agar ikut laporan laba rugi*) dengan pilihan
  jenis dan foto nota; keterangan menjadi keterangan pengeluaran. Baris
  gerakan kas hasilnya berlencana *Pengeluaran · jenis*.
- **Master data › Jenis pengeluaran** (tab baru untuk staf
  `expenses:manage`): nama (wajib, ≤ 60, unik tanpa membedakan huruf
  besar/kecil), jumlah pengeluaran; tambah, ubah nama, hapus bila belum
  dipakai. Tujuh jenis bawaan dibuat sekali per toko: *Sewa tempat*,
  *Listrik & air*, *Gaji & upah*, *Transport*, *Plastik & kemasan*, *Bahan
  habis pakai*, *Lain-lain*.
- Model data: tabel `expense_categories` dan `expenses`, jenis media
  `expenseReceipt` (migrasi `expense`).

### Diubah

- Teks Beranda menyebut pengeluaran sudah bisa dipakai; tinggal laporan
  yang menyusul.

### Diperbaiki

Semua di bawah ini ditemukan sebelum rilis (tes, uji manual, dan review),
bukan bug di versi sebelumnya.

- Tombol *Simpan pengeluaran* tidak pernah memanggil penyegaran daftar
  karena hasil perintah dibaca dari nilai balik `execute()` (selalu kosong),
  bukan dari `result`.
- Batang *Per jenis* tidak terlihat: kotak warna tanpa anak berukuran tinggi
  0 di dalam `Row`. Kini memakai `FractionallySizedBox` di atas lintasan
  abu-abu.
- Baris pertama daftar kartu menggambar garis atas ganda dengan tepi kartu.
- Tanpa izin, kartu form di layar lebar memutar indikator muat tanpa henti;
  kini hanya pesan galat yang tampil.
- Tombol *Batalkan pengeluaran* dan *Simpan* jenis meluap di ponsel 360 px.
- Di kas laci, galat jenis kosong baru muncul setelah keterangan diisi;
  kini semua galat isian tampil sekaligus.
- Layar Pengeluaran yang terbuka melewati tengah malam membuat pengeluaran
  kas laci selalu ditolak (tanggal *hari ini* basi). Kini tanggal kas laci
  ditetapkan saat simpan menurut cabang, dan daftar memuat ulang hari ini
  serta status sesi kasir setiap disegarkan atau setelah simpan ditolak
  (temuan review).
- Keterangan uang keluar 121–200 karakter dengan sakelar pengeluaran aktif
  gagal sebagai galat umum; kini batas field ikut 120 dan galatnya tampil di
  field (temuan review).
- Galat memuat jenis pengeluaran di kas laci kini tampil, tidak lagi
  menyisakan pilihan jenis kosong tanpa penjelasan (temuan review).
- Pilihan sumber dana bertuliskan *Kas laci (sesi aktif)* walau tidak ada
  sesi terbuka; kini *Kas laci* (temuan review).

### Keamanan

- `expenses:manage` dicek di menu, layar, master jenis, repositori
  aplikasi, dan lapisan data untuk semua aksi tulis.
- Kas laci (catat **dan** batal) juga butuh `cash_movements:create` di
  repositori aplikasi dan lapisan data; tombol *Batalkan* disembunyikan
  untuk pengeluaran laci bila staf tidak punya izin itu (temuan review).
- Foto nota hanya dibaca untuk pengeluaran cabang ini (temuan review).

### Catatan teknis

- Domain `lakuna_domain/expense.dart`: `ExpenseLimits`, `validateExpense`,
  `validateExpenseCategoryName`, `validateExpenseVoidReason`,
  `defaultExpenseCategories`, `expenseNumber`, `ExpensePeriod` +
  `expensePeriodRange`, `DateRange`.
- Data `lakuna_data/expenses.dart`: `ensureExpenseCategories`,
  `saveExpenseCategory`, `deleteExpenseCategory`, `recordExpense`,
  `voidExpense`, `listExpenses`, `summarizeExpenses`, `loadExpense`,
  `loadExpenseReceipt`, `expenseLabelsForSession`. Pengeluaran dan gerakan
  kasnya masuk outbox sync dalam satu transaksi.
- Widget bersama `PhotoAttachField` (lampirkan / ambil foto, pratinjau,
  hapus) untuk foto nota.
- Migrasi `20261104010452347-expense`.
- Tes: domain, data (jenis, catat kas toko/bank/laci, outbox, foto, cabang
  lain, izin, ringkasan, batal laci), repositori lokal (izin catat/batal
  laci, label rekap sesi), VM, alur widget 1440/800/360 px, tab jenis, dan
  sakelar pengeluaran di kas laci.
- Gap tercatat di spec F1-15: tes data untuk peran khusus, hitung pakai per
  jenis dengan `GROUP BY`, jenis bawaan dan batal laci saat sinkronisasi
  Fase 2.
- Tes data supplier (F1-14) dan pembelian kadang gagal saat seluruh tes
  berjalan: `expect(() => futureGagal, throwsA(...))` tanpa `await` membuat
  langkah berikutnya (ganti nama, bayar hutang) berpacu dengan aksi yang
  seharusnya ditolak. Kini memakai `await expectLater`.

## [0.18.0] - 2026-11-04

Supplier dan hutang (F1-14, layar 1.21). Toko mencatat supplier dengan tempo
standar, melihat hutang per supplier dari pembelian yang belum lunas, lalu
membayarnya dari kas toko, kas laci, atau rekening bank dengan nomor dan foto
bukti. Sisa hutang selalu dihitung dari dokumen, tidak disimpan sebagai angka.

### Ditambahkan

- Menu **Supplier** (`/supplier`, grup Kontak) untuk staf dengan izin
  `suppliers:manage` **atau** `debts:manage`; sebelumnya halaman
  *segera hadir*.
- **Layar 1.21 Supplier & hutang**:
  - daftar supplier (nama, kategori, telepon, hutang), cari nama, kontak,
    kategori, atau nomor telepon; kartu *Total hutang* dengan jumlah
    supplier berhutang, pembelian terlambat, dan jatuh tempo terdekat;
  - di lebar ≥ 1000 px panel supplier tampil di kanan; di layar lebih
    sempit dibuka sebagai halaman `/supplier/:id` dengan tombol kembali;
  - panel: kontak, tempo standar, telepon, kategori; tabel pembelian
    belum lunas (nomor, tanggal, jatuh tempo, total, sisa, bayar) dengan
    lencana *Terlambat*;
  - **Bayar hutang**: jumlah (tombol *Lunasi semua*), sumber dana *Kas
    toko* / *Kas laci* / *Rekening bank*, no. bukti transfer (opsional),
    tanggal bayar (tidak boleh di masa depan), catatan, dan **foto bukti**
    dari berkas atau kamera (maks. 5 MB, pratinjau dan hapus);
  - **alokasi otomatis** ke pembelian dengan jatuh tempo terdekat dulu
    (pembelian tanpa jatuh tempo paling akhir), dengan ringkasan sisa
    hutang dan jatuh tempo berikutnya setelah disimpan; **alokasi manual**
    per pembelian yang wajib berjumlah sama dengan uang dibayar;
  - nomor pembayaran `BH-<OUTLET>-<PERANGKAT>-<yymmdd>-NNNN`;
  - riwayat pembayaran (nomor, tanggal, sumber, jumlah, no. bukti) dengan
    tombol lihat foto bukti;
  - dialog **Riwayat pembelian** (pembelian cabang ini, terbaru dulu) yang
    membuka detail pembelian;
  - form **tambah / ubah supplier**: nama (wajib, unik tanpa membedakan
    huruf besar/kecil), kontak, telepon (dinormalisasi), kategori barang,
    tempo standar 0–365 hari, alamat, catatan;
  - **hapus supplier** (ditolak selama masih berhutang; pembelian lama
    tetap menampilkan namanya).
- **Kas laci**: bayar hutang dari laci wajib sesi kasir terbuka di perangkat
  ini, tanggal bayar hari ini, dan izin `cash_movements:create`; tercatat
  sebagai uang keluar *Bayar hutang supplier* di rekap sesi.
- **Detail pembelian**: tombol **Bayar hutang** (bila masih berhutang dan
  staf punya `debts:manage`) membuka panel supplier; kartu *Pembayaran*
  menampilkan baris pembayaran hutang `BH-…`.
- Data: kolom `suppliers.contact_name`, `category`, `address`,
  `term_days` (bawaan 14), `debt_payments.reference`, `proof_media_id`,
  dan jenis media `paymentProof` (migrasi `supplier`).

### Diubah

- **Pembelian**: jatuh tempo bawaan = tanggal beli + tempo standar supplier
  terpilih (14 hari untuk supplier baru). Mengganti supplier ikut
  memperbarui jatuh tempo selama belum diubah manual; draf lama tanpa jatuh
  tempo juga memakai tempo supplier-nya.
- Hutang pembelian di daftar, detail, dan retur beli sekarang dikurangi
  pembayaran hutang supplier; retur setelah pembayaran hanya memotong sisa
  hutang, kelebihannya dikembalikan seperti biasa.
- Teks Beranda menyebut supplier & hutang sudah bisa dipakai.

### Diperbaiki

- Dialog form supplier: tombol *Simpan* / *Batal* sekarang menempel di
  bawah dialog. Sebelumnya di jendela 720 px tombol terpotong, dan klik di
  bagian yang terpotong mengenai latar sehingga dialog tertutup tanpa
  menyimpan (ditemukan saat uji manual).
- Panel supplier memuat ulang status sesi kasir setiap kali dimuat, jadi
  petunjuk kas laci tidak basi bila sesi dibuka/ditutup selama panel
  terbuka (temuan review).
- Bayar dari kas laci tanpa izin `cash_movements:create` ditolak di
  repositori aplikasi sebelum menyentuh data, dengan pesan izin yang jelas
  (temuan review).
- Riwayat pembelian supplier dibatasi cabang ini sehingga setiap baris bisa
  dibuka; sebelumnya pembelian cabang lain ikut tampil lalu gagal dibuka
  (temuan review).

### Keamanan

- Izin dicek di menu, layar, repositori aplikasi, dan lapisan data untuk
  semua aksi tulis: kelola supplier `suppliers:manage`, bayar hutang
  `debts:manage`, kas laci `cash_movements:create`.

### Catatan teknis

- Domain: `SupplierLimits`, `validateSupplier`, `PayableOrder` (urutan
  jatuh tempo terdekat), `supplierPaymentNumber`, `purchaseDebt(allocated:)`.
- Data: `suppliers.dart` (`loadSuppliersOverview`, `loadSupplierDetail`,
  `listSupplierPurchases`, `saveSupplier`, `deleteSupplier`,
  `paySupplierDebt`, `loadSupplierPaymentProof`); `purchaseDebtOf` dipakai
  bersama oleh daftar, detail, pembayaran, hapus, dan retur.
- Pembaruan supplier menaikkan `version`, `hlc`, dan `origin_device_id`
  (galat *SyncStampMismatch* saat pengembangan).
- Tes: domain, data (10 skenario termasuk alokasi ke pembelian supplier
  lain dan nama bentrok saat ubah), repositori lokal (izin per aksi), VM,
  dan alur widget 1440/1280/800/360 px.

## [0.17.0] - 2026-11-04

Pelanggan dan piutang (F1-13, layar 1.20, 1.20b, dan 1.5b). Toko mencatat
pelanggan tetap, menjual kredit dengan batas dan jatuh tempo, lalu menerima
pembayaran piutang yang dialokasikan ke nota dengan kuitansi A5 atau struk.
Saldo piutang selalu dihitung dari dokumen, tidak disimpan sebagai angka.

### Ditambahkan

- Menu **Pelanggan** (`/pelanggan`, grup Kontak) untuk staf dengan izin
  `customers:manage` **atau** `debts:manage`.
- **Layar 1.20 Pelanggan & piutang**:
  - daftar pelanggan (nama + HP, grup, piutang), cari nama atau HP, kartu
    *Total piutang* dengan jumlah pelanggan dan nota lewat jatuh tempo;
  - di lebar ≥ 1000 px panel pelanggan tampil di kanan; di layar lebih
    sempit dibuka sebagai halaman `/pelanggan/:id`;
  - panel: grup, pelanggan sejak, kontak, catatan, tiga petak *Limit
    kredit*, *Piutang*, *Sisa limit*; tabel nota belum lunas dengan
    jatuh tempo dan lencana *Terlambat*;
  - **Terima pembayaran**: jumlah (tombol *Lunasi semua*), metode Tunai /
    Transfer bank / QRIS statis, tanggal (tidak boleh di masa depan),
    catatan; alokasi otomatis ke nota terlama dulu atau *Atur alokasi
    manual* per nota (jumlah alokasi wajib sama dengan uang diterima);
    teks sisa piutang setelah bayar; *Simpan & cetak kuitansi*;
  - riwayat pembayaran bernomor `BP-<OUTLET>-<PERANGKAT>-<yymmdd>-NNNN`
    yang membuka kuitansi salinan;
  - *+ Pelanggan*, *Ubah data*, *Hapus pelanggan* (ditolak selama masih
    berpiutang).
- **Form pelanggan**: nama, no. HP (dinormalisasi, `+62`/`62` → `0`,
  8–15 digit, unik per toko), grup (pilih, tanpa grup, atau *+ Grup baru*),
  limit kredit (0 = tidak boleh kredit), alamat, catatan.
- **Import Excel**: CSV atau XLSX (maks. 2 MB, sheet pertama) dengan
  baris judul Indonesia (`nama`, `hp`, `alamat`, `grup`, `limit`,
  `catatan`) atau English. HP yang sudah ada memperbarui pelanggan itu
  (hanya kolom terisi), grup baru dibuat, baris salah dilewati dengan
  nomor baris dan alasannya.
- **Kuitansi 1.20b** (`/pelanggan/kuitansi/:id`): pratinjau A5 (nama toko,
  cabang, nomor, telah terima dari, terbilang miring, untuk pembayaran N
  nota, metode, tabel nota · sisa sebelum · dibayar, kota dan tanggal,
  kotak jumlah, nama kasir, sisa piutang) dan pratinjau struk 58/80 mm.
  Pilihan *Tampilkan rincian per nota*, *Tampilkan sisa piutang*, *Kota
  pada tanda tangan*. *Cetak* (A5 lewat dialog cetak sistem, struk lewat
  printer struk) dan *Bagikan PDF*. Cetak ulang diberi tanda *SALINAN*.
- **Kredit di Kasir 1.5b**: metode *Kredit / piutang* (butuh
  `debts:manage`, nota retail): cari dan pilih pelanggan (sisa limit,
  tempo), petak Limit / Piutang berjalan / Sisa limit, *Bayar sekarang
  (DP)* tunai, *Jatuh tempo* (bawaan hari ini + tempo grup, 14 hari tanpa
  grup), ringkasan *Jadi piutang* dan *Sisa limit setelah ini*, peringatan
  bila melebihi limit, tombol *Simpan sebagai piutang*. Layar berhasil
  menampilkan piutang pelanggan.
- **Grup pelanggan** di Master data (tab baru untuk staf
  `customers:manage`): nama, tempo standar (0–365 hari), jumlah
  pelanggan; tambah, ubah, hapus bila tidak dipakai.
- **Riwayat 1.14**: nota kredit yang masih bersisa berlencana *Belum
  lunas*; rincian menampilkan pelanggan, jatuh tempo, bagian kredit, dan
  sisa piutang.
- **Struk** nota kredit memuat pelanggan, *Piutang*, dan *Jatuh tempo*.
- **Rekap sesi kasir**: baris *Penjualan kredit (piutang)*; pembayaran
  piutang tunai saat sesi terbuka masuk laci sebagai kas masuk.
- Model data: tabel `customer_groups`, `customers`, `debt_payments`,
  `debt_payment_allocations`; kolom `sales.customer_id`, `sales.due_on`,
  `sale_returns.debt_reduction`; enum `DebtParty`, `DebtDocumentType`,
  `RefundMethod.debt` (migrasi `pelanggan`).

### Diubah

- **Retur nota kredit** memotong piutang nota itu dulu; sisanya
  dikembalikan tunai/transfer. Bila seluruh nilai retur memotong piutang,
  pilihan uang kembali disembunyikan dan sesi kasir tidak diperlukan.
- **Void nota kredit** ditolak bila nota sudah menerima pembayaran
  piutang; pesan menyarankan retur.
- Nomor HP yang kehilangan angka 0 di depan (mis. dari Excel, `8123…`)
  dikembalikan menjadi `08123…`.

### Diperbaiki

Semua di bawah ini ditemukan sebelum rilis (tes alur dan uji manual),
bukan bug di versi sebelumnya.

- Tombol *Simpan & cetak kuitansi* tidak pernah menyimpan: pemeriksaan
  "boleh simpan" ikut melihat perintah simpan yang sedang berjalan, jadi
  selalu gagal dari dalam perintah itu sendiri.
- Daftar pelanggan di panel kredit Kasir memeras nama hingga satu huruf
  per baris di ponsel 360 px; kini nominal sisa limit mengecil dan nama
  dipotong rapi.
- Pratinjau kuitansi A5 meluap di layar sempit; kini diperkecil seperti
  kertas, bukan ditata ulang.
- Label tombol (*Lunasi semua*, *Atur alokasi manual*, *Hapus pelanggan*,
  *Bagikan PDF*) meluap di panel sempit.
- Dialog grup pelanggan mengosongkan galat simpan saat sedang dibangun
  sehingga memicu galat framework.
- Font PDF kuitansi tampil sangat tipis karena paket `pdf` tidak mendukung
  font variabel; kini memakai potongan statis DM Sans dan Montserrat.
- Limit kredit dari import seperti `1500000.00` (ekspor akuntansi) terbaca
  100× lebih besar karena semua titik dibuang. Kini titik/koma hanya
  dianggap pemisah ribuan bila berpola ribuan; desimal nol diterima,
  pecahan rupiah ditolak.
- Kuitansi A5 untuk pelunasan puluhan nota terpotong di satu halaman; kini
  tabel berlanjut ke halaman berikutnya.
- Pembayaran tunai bertanggal mundur ikut masuk laci hari ini; kini dicatat
  sebagai kas toko, dan petunjuk di form ikut menyesuaikan.
- Struk kuitansi memakai jam simpan, sedangkan A5 memakai tanggal bayar;
  kini keduanya memakai tanggal bayar.
- Gerakan kas dari pembelian dan pembayaran piutang di rekap sesi tampil
  sebagai kode mentah (`purchase`, `debt_payment`); kini berlabel.
- Daftar pelanggan kredit di Kasir tidak dimuat ulang setelah ada
  pembayaran piutang atau retur; kini dimuat setiap masuk mode kredit dan
  diurutkan stabil per nama.
- Import di lapisan data kini memeriksa ulang setiap baris seperti form
  pelanggan.
- Kolom *Metode* di Riwayat dan kepala rincian nota kredit hanya menulis
  *Tunai* (uang muka); kini tertulis *Tunai + Kredit*.
- Nomor nota panjang di tabel piutang panel pelanggan terbungkus dua
  baris; kini satu baris dan mengecil bila perlu.

### Keamanan

- `customers:manage` (tambah/ubah/hapus/import/grup) dan `debts:manage`
  (terima pembayaran, jual kredit) dicek di menu, layar, repositori
  aplikasi, **dan** lapisan data: aktor wajib staf aktif outlet ini dengan
  izin yang cukup.

### Catatan teknis

- Aturan domain di `lakuna_domain` (`customer.dart`, `receivable.dart`,
  `customer_import.dart`): normalisasi/validasi pelanggan dan grup, cek
  limit kredit, piutang nota, alokasi FIFO dan validasi manual, terlambat,
  terbilang `rupiahInWords`, nomor `BP-`, parser import. Data di
  `lakuna_data/customers.dart`, semua tulis lewat `LakunaStore.write` +
  outbox.
- `debt_payments.balance_after` dan `debt_payment_allocations.balance_before`
  disimpan agar cetak ulang kuitansi sama dengan cetakan pertama. Tabel
  yang sama dipakai hutang supplier di F1-14.
- Pembaca XLSX ringan di `table_file.dart` (archive + xml, sharedStrings,
  inlineStr); PDF A5 di `kuitansi_pdf.dart` dengan font statis di
  `assets/fonts/pdf/`.
- Migrasi `20261103230815808-pelanggan`.
- Gap tercatat di spec F1-13: kredit open bill/split bill F&B, pilih
  pelanggan di kepala pesanan (1.4b), persetujuan PIN melewati limit,
  batal pembayaran piutang.

## [0.16.0] - 2026-11-03

Pembelian dan retur pembelian (F1-12, layar 1.19 dan 1.19b). Pemilik dan
staf gudang mencatat barang masuk dari supplier: stok bertambah, harga
pokok rata-rata diperbarui, hutang supplier tercatat, dan harga jual bisa
disesuaikan dari saran yang menjaga margin.

### Ditambahkan

- Menu **Pembelian** (`/pembelian`, grup Inventori) untuk staf dengan izin
  `purchases:manage`. Tab **Pembelian** dan **Retur pembelian**, kotak cari
  nomor/supplier, status *Draf*, *Lunas*, *Hutang*.
- Layar 1.19 dua panel di lebar ≥ 1000 px: daftar di kiri, form
  *Pembelian baru* di kanan. Di layar lebih sempit form dibuka sebagai
  halaman `/pembelian/baru`, dan daftar dimuat ulang saat kembali.
- **Form pembelian**:
  - supplier dari daftar, *Tanpa supplier*, atau *+ Supplier baru* (nama
    diketik dan dibuat saat disimpan; nama unik per tenant tanpa membedakan
    huruf besar/kecil);
  - no. faktur supplier, tanggal, lokasi stok tujuan;
  - scan barcode, SKU, atau nama produk dengan saran nama; barcode satuan
    konversi langsung memilih satuan itu (mis. barcode dus → *Dus (6)*);
  - baris: satuan (dasar atau konversi), qty (boleh pecahan), harga beli
    per satuan (bawaan = HPP × isi), subtotal; satu varian dengan dua
    satuan digabung;
  - diskon faktur dan ongkos kirim dibagi ke baris secara proporsional
    (harga pokok mendarat);
  - *Bayar sekarang* dengan tombol *Bayar lunas*, sumber dana **Kas toko**,
    **Kas laci** (sesi kasir terbuka di perangkat ini), atau **Rekening
    bank**;
  - sisa jadi hutang dengan **jatuh tempo** bawaan +14 hari dari tanggal
    pembelian (bisa diubah, tidak boleh sebelum tanggal pembelian);
  - catatan, *Simpan draf*, dan *Terima barang & simpan*.
- **Draf** mendapat nomor `PB-` saat pertama disimpan, bisa diubah atau
  dihapus, dan tidak menggerakkan stok. Nomor tetap saat draf diterima,
  mis. `PB-PST-K01-261104-0001`.
- **Terima barang**: stok masuk lewat ledger di lokasi terpilih (qty ×
  isi satuan), HPP rata-rata tertimbang per lokasi dan `cost_price` varian
  diperbarui, bayar dari laci menulis kas keluar di sesi terbuka.
- **Detail 1.19b** (`/pembelian/:id`): info dokumen, tabel *Barang
  diterima* dengan HPP sebelum → sesudah, harga jual, saran jual, dan
  lencana *Aman* / *Di bawah saran*; ringkasan (subtotal, diskon, ongkir,
  total, sudah dibayar, diretur, sisa hutang) dengan kotak jatuh tempo;
  daftar pembayaran (bayar di muka, pengurang hutang, uang kembali).
- **Saran harga jual** menjaga margin lama: `harga jual × HPP baru ÷ HPP
  lama`, dibulatkan ke atas ke Rp 100, satu saran per varian. Baris di
  bawah saran tercentang otomatis; *Terapkan harga jual (N produk)*
  mengubah harga jual lewat outbox.
- **Retur pembelian** `RB-`: qty per baris dibatasi sisa yang belum
  diretur dan stok di lokasi; nilai retur mengurangi hutang lebih dulu,
  kelebihannya menjadi uang kembali ke kas toko, laci, atau bank yang
  dipilih. Catatan retur opsional. Daftar retur tampil di detail dan di tab
  *Retur pembelian*.
- Kartu stok menampilkan pembelian dan retur pembelian dengan nomor PB/RB.
- Model data: tabel `suppliers`, `purchases`, `purchase_items`,
  `purchase_returns`, `purchase_return_items`; enum `PurchaseStatus`,
  `FundingSource` (migrasi `pembelian`).

### Diubah

- Teks Beranda menyebut Pembelian sudah bisa dipakai; Pelanggan, supplier,
  dan laporan menyusul.
- HPP rata-rata setelah **retur pembelian** kini dihitung ulang dari nilai
  persediaan (`(stok × HPP − qty retur × harga pokok baris) ÷ sisa stok`),
  bukan dibiarkan tetap. Keluar stok lain (penjualan, penyesuaian) tetap
  tidak mengubah HPP rata-rata. Aturan yang sama dipakai saat membangun
  ulang saldo stok.

### Diperbaiki

Semua di bawah ini ditemukan sebelum rilis (uji manual dan review kode),
bukan bug di versi sebelumnya.

- Saran harga jual bertambah terus setelah harga diterapkan, karena
  dasarnya harga jual terkini. Kini memakai salinan harga jual saat barang
  diterima (`purchase_items.sell_price_before`).
- Varian yang muncul di dua baris (dua satuan) mendapat dua saran harga.
- Produk nonaktif, terhapus, atau tanpa lacak stok bisa diterima.
- Lokasi stok yang tidak ada menampilkan pesan umum; kini *Lokasi stok
  tidak ditemukan*.
- Pesan "Draf tersimpan" tetap tampil setelah form diubah lagi.
- Jatuh tempo bawaan bisa bergeser sehari di zona dengan pergantian jam
  musim panas; kini dihitung dari tanggal kalender.
- Panjang catatan retur dihitung per unit UTF-16; kini per karakter.
- Harga beli "Rp 195.000" terpotong di kolom form 1280 px; daftar di panel
  kiri memotong lencana status. Daftar sempit kini memakai tiga kolom
  dengan supplier di bawah nomor.
- View model form dipakai setelah dibuang saat pindah dari dua panel ke
  satu panel.

### Keamanan

- `purchases:manage` dicek di menu, layar, repositori aplikasi, **dan**
  lapisan data: aktor wajib staf aktif outlet ini dengan izin yang cukup
  (`PurchaseActorNotPermitted`).
- Bayar dari laci atau uang kembali ke laci juga butuh
  `cash_movements:create`; pilihan *Kas laci* disembunyikan bagi staf
  tanpa izin itu.
- *Terapkan harga jual* juga butuh `products:manage`; kotak centang dan
  tombolnya disembunyikan bagi staf gudang.

### Catatan teknis

- Aturan domain di `lakuna_domain/purchase.dart` (`purchaseTotals`,
  `validatePurchase`, `purchaseDebt`, `suggestedSellPrice`,
  `purchaseReturnSplit`, `averageCostAfterReturn`, nomor `PB-`/`RB-`);
  data di `lakuna_data/purchases.dart`, semua tulis lewat
  `LakunaStore.write` + outbox. `levelAverageCost` di `stock.dart` dipakai
  bersama oleh penulisan stok dan `rebuildStockLevels`.
- Kolom baru `purchase_items.sell_price_before`; migrasi
  `20261103222601917-pembelian`.
- Gap tercatat di spec F1-12: bayar hutang belakangan (F1-14), foto
  faktur, kartu stok terkait dan PDF, master supplier lengkap (F1-14),
  status sesi kasir tidak diperbarui selama form terbuka, keunikan nama
  supplier belum dijaga indeks DB (sinkronisasi Fase 2).

## [0.15.0] - 2026-11-03

Riwayat transaksi, void & retur (F1-11, layar 1.14). Pemilik dan kasir bisa
mencari nota, meretur sebagian atau seluruh barang, membatalkan nota hari
ini dengan persetujuan PIN manajer, mencetak ulang struk, dan mengekspor
daftar ke Excel.

### Ditambahkan

- Menu **Riwayat** (`/riwayat`) aktif untuk staf dengan izin
  `sales:create` atau `reports:view`.
- Ringkasan "Hari ini · N transaksi · Rp X" (nilai bersih setelah retur) dan
  filter **Hari ini / Kemarin / 7 hari**, **Kasir**, **Metode**, dan
  **Status** (Semua, Selesai, Retur, Void).
- Daftar nota berupa tabel (Nota, Jam, Kasir, Metode, Total, Status) atau
  kartu di layar sempit. Rentang *Kemarin* dan *7 hari* menampilkan tanggal
  di bawah jam. Status: *Selesai*, *Retur sebagian*, *Diretur*, *Void*.
- **Panel rincian** di lebar ≥ 900 px; di tablet potret dan ponsel rincian
  dibuka sebagai halaman `/riwayat/:id` dan daftar dimuat ulang saat
  kembali. Rincian memuat total awal, sudah diretur, nilai bersih, item
  dengan sisa yang bisa diretur, dan daftar retur sebelumnya.
- **Retur** sebagian atau penuh: jumlah per item (tombol −/+ atau *Retur
  semua*), alasan *Barang rusak / Salah ambil / Kedaluwarsa / Lainnya*
  (catatan wajib untuk *Lainnya*), uang kembali **Tunai** (dari laci sesi
  aktif) atau **Transfer**, dan *Kembalikan barang ke stok* (bawaan aktif
  untuk *Salah ambil* dan *Lainnya*). Tombol *Proses retur · Rp X*. Nomor
  retur memuat outlet dan perangkat, mis. `RT-PST-K01-261103-0001`.
- Nilai retur proporsional terhadap total nota, jadi diskon tier, service,
  dan PB1 ikut dikembalikan sesuai porsi item. Retur terakhir sebuah item
  mengambil sisa nilai agar total retur tidak melebihi nilai nota.
- **Void** nota hari ini dari sesi kasir yang masih terbuka, dengan alasan
  wajib (maks. 120 karakter). Stok dikembalikan lewat entri baru; nota
  tetap tersimpan dengan status *Void*, penyetuju, waktu, dan alasan.
- Dialog **Persetujuan manajer**: bila staf aktif tidak punya izin
  `sales:void`, pilih staf lain yang berizin dan masukkan PIN-nya. Dipakai
  di Riwayat dan di tombol *Batalkan bill* layar Meja (pelayan kini bisa
  membatalkan bill dengan PIN manajer).
- **Cetak ulang struk** dengan baris "CETAK ULANG", baris "VOID" untuk nota
  void, serta nilai retur dan nilai bersih untuk nota yang diretur. Bisa
  dicetak atau disimpan/dibagikan sebagai PDF.
- **Ekspor Excel** (`.xlsx`) sesuai filter: nomor, tanggal, jam, kasir,
  metode, total, retur, bersih, status. Desktop menyimpan ke folder dokumen
  Lakuna dan menampilkan lokasinya; Android/iOS membuka lembar bagikan.
- Rekap sesi kasir: baris **Retur tunai**, dan petak *Void/retur* kini
  menghitung nota void dan retur di sesi itu.
- Kartu stok menampilkan retur sebagai "Retur penjualan RT-… (staf)" dan
  pembalikan void dengan catatan "Nota di-void".
- Model data: tabel `sale_returns`, `sale_return_items`; enum
  `SaleReturnReason`, `RefundMethod`; `SaleStatus` bertambah
  `partiallyReturned` dan `returned` (migrasi `riwayat`).

### Diubah

- Teks Beranda menyebut kasir F&B dan riwayat transaksi sudah bisa dipakai.
- Menu bisa mensyaratkan salah satu dari beberapa izin (`MenuEntry.orPermission`).
- Batalkan bill di layar Meja mencatat penyetuju sebagai `voided_by`.

### Diperbaiki

Semua di bawah ini ditemukan sebelum rilis (uji manual dan review kode),
bukan bug di versi sebelumnya.

- Open bill yang dibatalkan (nomor `OB-…`) sempat muncul di riwayat sebagai
  nota void. Bill yang tidak pernah dibayar kini disembunyikan dari daftar
  dan rincian.
- Petak *Void/retur* di rekap sesi selalu 0.
- Retur yang mengembalikan stok sempat memakai HPP terkini, bukan HPP baris
  nota saat dijual.
- Alasan void dihitung per unit UTF-16, sehingga emoji memakan dua
  karakter; kini dihitung per karakter.
- Pembagian nilai retur tidak menangani nota yang semua barisnya bernilai
  nol (mis. barang gratis dengan service); kini dibagi rata.
- Kolom catatan retur masih berisi teks lama setelah retur berhasil.
- Dialog persetujuan tidak mengosongkan PIN yang salah.
- Label status "Retur sebagian" terpotong dua baris di tabel 1280 px, dan
  warna baris terpilih menutupi lencana status.
- Lokasi berkas Excel dan PDF struk memakai satu variabel, sehingga pesan
  "tersimpan" bisa menunjuk berkas yang salah. Tombol ekspor kini juga
  nonaktif selama daftar dimuat.
- Kesalahan *penyetuju tidak berizin* di layar Meja tampil sebagai pesan
  umum.

### Keamanan

- Retur butuh `sales:return`, void butuh `sales:void`; dicek di layar,
  repositori aplikasi, dan lapisan data (`requireApprover`).
- Persetujuan manajer memakai kunci PIN yang sama dengan login (5 kali
  salah → terkunci 1 menit) dan antrean per staf, dan tidak mengganti sesi
  yang sedang berjalan.
- PIN yang benar mencatat persetujuan **sekali pakai** selama 2 menit.
  Repositori menolak `approverId` tanpa persetujuan itu, jadi id staf saja
  tidak cukup untuk void. Persetujuan dihapus setelah dipakai, saat ganti
  kasir, dan saat kedaluwarsa; void yang gagal validasi tidak
  menghabiskannya.
- Retur tunai butuh sesi kasir terbuka; jumlah retur dibatasi sisa per item
  dalam transaksi yang sama dengan penulisan.

### Catatan teknis

- Aturan domain di `lakuna_domain/sale_return.dart` (`ReturnLimits`,
  `lineShares`, `returnAmount`, `returnState`, `validateReturnNote`,
  `restockByDefault`); data di `lakuna_data/history.dart`
  (`listSalesHistory`, `loadSaleDetail`, `returnSale`, `voidSale`,
  `requireApprover`), semua tulis lewat `LakunaStore.write` + outbox.
- `SessionRepository.verifyApprover` berbagi `_checkPin` dengan login;
  persetujuan disimpan di memori (`hasApproval` / `consumeApproval`).
- XLSX ditulis sendiri di atas `archive` (`buildXlsx`, sel angka asli,
  lebar kolom), karena paket `excel` bentrok dengan `xml` 7 dari `pdf`.
  Berkas diperiksa dengan openpyxl.
- Dependensi baru: `archive`, `share_plus`.
- Gap tercatat di spec F1-11: retur ke piutang (F1-13), status sesi tidak
  diperbarui saat layar riwayat terbuka, belum ada peringatan retur tunai
  melebihi uang laci, konflik retur/void antarperangkat (Fase 2).

## [0.14.0] - 2026-11-03

Denah meja F&B (F1-10 bagian keempat, layar 1.7b–1.7d). Pemilik mengunggah
gambar denah per area lalu menata meja di atasnya; kasir dan pelayan memilih
meja langsung dari denah.

### Ditambahkan

- Layar **Atur denah** 1.7d (`/meja/denah?area=…`), dibuka dari tombol
  *Atur denah* di layar Meja atau ikon denah per area di Master data ›
  Meja & area. Pilihan area di header (plus tambah area), mode tata letak
  **Grid** / **Denah** per area.
- Panel **unggah denah** 1.7c: PNG, JPG, WebP, atau SVG maksimal 5 MB,
  dengan tips gambar. Di Android/iOS ada tombol **Ambil foto** (kamera).
  Tombol *Ganti gambar denah* mengganti gambar tanpa mengubah posisi meja.
- Kanvas denah (`vyuh_node_flow`): gambar denah terkunci di latar dengan
  pengatur transparansi, meja tanpa port yang bisa digeser dan diubah
  ukurannya (20–600), snap grid 20 px (bisa dimatikan), zoom 25–300 %,
  tombol zoom dan *pas layar*, peta mini.
- Palet **Tambah meja**: Bulat · 2 kursi, Kotak · 4, Panjang · 6,
  Panjang · 8, Kursi bar · 1. Nama otomatis melanjutkan nomor terakhir
  (M7, M8, …). Chip **Belum ditempatkan** untuk meja lama yang belum punya
  posisi; ketuk untuk menaruhnya di tengah tampilan.
- Panel meja terpilih: nama, kursi, bentuk (bulat, kotak, panjang, kursi
  bar), lebar & tinggi, orientasi mendatar/tegak, *Boleh digabung dengan
  meja sebelah*, *Hapus meja*. **Undo/redo**, catatan *ada perubahan yang
  belum disimpan*, dan konfirmasi buang perubahan saat kembali atau ganti
  area.
- Layar **Meja** 1.7b: pilihan **Grid / Denah** (bawaan Denah bila ada area
  denah), tab area denah, kanvas terkunci (geser & zoom saja) dengan warna
  status dan total bill yang sama dengan kartu grid, meja bulat berbentuk
  lingkaran, chip meja yang belum ditempatkan, dan tombol *Atur denah*
  bagi pemegang izin pengaturan.
- Model data: `dining_areas.layout_mode`, `dining_areas.floor_media_id`,
  `dining_tables.shape`, `pos_x`, `pos_y`, `width`, `height`, `can_merge`,
  jenis media `floorPlan` (migrasi `denah`).

### Diubah

- Memindah meja ke area lain di Master data mengosongkan posisinya; meja
  tampil sebagai *Belum ditempatkan* di denah area baru.
- Subjudul area di Master data menyebut *Denah* untuk area mode denah.
- Pemilih gambar menerima SVG (khusus denah) dan foto kamera di ponsel.

### Diperbaiki

Semua di bawah ini ditemukan sebelum rilis (uji manual dan review kode),
bukan bug di versi sebelumnya.

- Meja bulat sempat tergambar sebagai lingkaran kecil seukuran teks, dan
  peta mini tertutup warna biru oleh node gambar denah.
- Layar Meja: ketuk meja di denah terpicu saat jari turun, sehingga
  menggeser denah di atas meja langsung membuka dialog tamu. Ketuk kini
  dihitung saat jari naik tanpa bergeser, dan tidak tertahan pengenal
  ketuk ganda.
- Atur denah: memilih meja membuat ulang node-nya, sehingga geser pertama
  pada meja yang belum dipilih terputus. Node kini hanya dibuat ulang bila
  bentuknya berubah; nama, warna, dan tanda terpilih diperbarui di tempat.
- Atur denah: setelah kanvas dilepas dan dipasang lagi (ganti area, panel
  unggah), node meja area lain tertinggal tak terlihat dan pengendali vyuh
  memegang `context` editor lama. Pengendali vyuh kini dibuat setiap kali
  kanvas dipasang dan dibuang saat dilepas.
- Posisi atau ukuran di kanvas bisa berbeda dari draf yang disimpan bila
  hasil snap sama dengan nilai lama (mis. ubah ukuran beberapa piksel, geser
  melewati tepi kiri). Kanvas kini selalu dikembalikan ke draf.
- Di layar sentuh, geser meja/denah ke atas-bawah malah menggulir halaman.
  Gulir halaman dikunci selama jari ada di kanvas (layar Meja dan Atur denah
  di bawah 1100 px).
- Undo menggabungkan beberapa ketukan pilihan bentuk/orientasi/gabung jadi
  satu langkah; kini hanya ketikan yang digabung.
- Nama area duplikat di *+ Area* menampilkan pesan tentang nama meja.

### Keamanan

- Unggah denah dan simpan tata letak butuh `settings:manage`, dicek di
  layar dan di repositori. Gambar divalidasi dari isi berkas (bukan nama),
  ukuran maksimal 5 MB, dan posisi/ukuran meja divalidasi di lapisan data.
- Menghapus meja yang masih punya open bill ditolak.

### Catatan teknis

- Aturan denah di `lakuna_domain/floor_plan.dart` (`FloorLimits`,
  `floorWorldSize`, `TablePreset`, `nextTableName`, `snapTo`,
  `validateFloorTable`, `readFloorImageHeader` dengan SVG `viewBox`); data
  di `lakuna_data/floor_plan.dart` (`saveFloorImage`, `saveFloorLayout`
  dalam satu transaksi dengan outbox, `floorImages`).
- Koordinat dunia lebar 800, tinggi mengikuti rasio gambar (200–2000).
  Orientasi disimpan sebagai tukar lebar/tinggi, tanpa kolom rotasi.
- Kasir memakai `NodeFlowEditor` mode `preview` dengan node terkunci, bukan
  `NodeFlowViewer`, agar bentuk lingkaran tetap bisa dipakai.
- Dependensi baru: `vyuh_node_flow` 0.32, `flutter_svg`, `image_picker`
  (izin kamera iOS di `Info.plist`).
- `FloorScrollLock` membungkus daftar bergulir yang memuat kanvas; kanvas
  menaikkan hitungan jari lewat `Listener` (tetikus tidak dihitung).
- Gap tercatat di spec F1-10: tarik langsung dari palet, garis bantu dan
  `LodPlugin`, seret di layar sentuh belum diuji di perangkat, peta mini
  belum ikut mode gelap, pilihan Grid/Denah belum diingat lintas layar,
  keluar lewat sidebar tanpa konfirmasi, gambar denah lama belum dihapus.

## [0.13.0] - 2026-11-03

Split bill F&B (F1-10 bagian ketiga, layar 1.9). Satu meja bisa dibayar per
tamu: per item, bagi rata, atau nominal bebas. Bill tetap satu nota; setiap
bagian tamu dicatat sebagai pembayaran di nota yang sama, jadi laporan dan
stok tidak terpecah.

### Ditambahkan

- Layar **Split bill** 1.9 (`/meja/split/:bill`) untuk tablet dan ponsel:
  pilihan *Per item* / *Bagi rata* / *Nominal bebas*, jumlah tamu 2–8
  (label A–H), kartu tamu dengan tagihan, daftar porsi, dan status
  (*Belum bayar*, *Lunas · metode*, *QRIS statis · menunggu*), serta
  ringkasan total, sudah dibayar, menunggu, dan sisa tagihan.
- *Per item*: ketuk chip tamu untuk memberi satu porsi; item lebih dari 1
  dipecah per porsi (modifier ikut disalin), ketuk lagi untuk
  mengembalikan ke *belum dibagi*. Tamu terakhir yang belum bayar
  menanggung sisa agar jumlah bagian selalu sama dengan total.
- *Bagi rata* memakai metode sisa terbesar (Rp 100.000 untuk 3 tamu =
  33.334 / 33.333 / 33.333).
- *Nominal bebas*: tamu berikutnya mengetik nominal ≤ sisa; tamu ke-8 wajib
  melunasi sisa.
- Layar **Bayar bagian** (`/kasir?bill=…&guest=A` atau `&amount=…`): semua
  metode bayar layar 1.5, judul "Meja M2 · Bagian tamu A", rincian bill
  (porsi tamu di mode per item) dengan baris *Bagian tamu A*, tombol kembali *Kembali ke split*.
- QRIS bagian punya tombol **Simpan, tunggu konfirmasi**: bagian tersimpan
  sebagai menunggu dan dikonfirmasi (*Sudah Terbayar*) atau dibatalkan di
  layar split. Kasir tanpa izin `payments:confirm` tetap bisa menyimpan
  QRIS yang menunggu.
- Bagian terakhir yang melunasi bill (dari kasir atau dari *Sudah
  Terbayar* di layar split) langsung ke **Pembayaran selesai** dengan
  struk, cetak, dan cetak otomatis seperti *Tutup & bayar*.
- Panel bill (1.7): tombol **Split bill** aktif, status "Split · 1 dari 3
  tamu lunas", tombol bayar menjadi **Lanjutkan split · Rp X**, dan label
  tamu di baris porsi.
- Struk: porsi digabung kembali ke baris asal dan pembayaran tercatat per
  tamu ("Tamu A - Tunai"). Tiket dapur juga menggabung porsi yang dikirim
  bersamaan.
- Model data: `sales.split_mode`, `sales.split_guests`,
  `sale_items.guest_label`, `sale_items.split_from_item_id`,
  `payments.guest_label` (migrasi `split`).

### Diubah

- Bill yang sudah punya pembayaran bagian terkunci: tambah menu, ubah
  jumlah, ubah pembagian, dan *Tutup & bayar* biasa ditolak dengan pesan
  yang jelas. Pindah meja, kirim ke dapur, dan tandai disajikan tetap
  boleh.
- **Batalkan bill** tetap bisa pada bill yang terkunci (izin `sales:void`)
  agar sesi kasir bisa ditutup bila tamu pergi: bagian yang sudah lunas
  dikembalikan ke tamu (disebut di dialog), QRIS yang menunggu dihapus.
- Sesi kasir tidak bisa ditutup selama masih ada bill dengan pembayaran
  bagian yang belum lunas atau dibatalkan.
- *Tutup & bayar* dan bayar bagian memakai fungsi penyelesaian nota yang
  sama (nomor nota, stok, sesi kasir, service & PB1 beku).
- `sales.item_count` menghitung baris asal, bukan baris porsi.
- Tombol Android *kembali* di layar split kembali ke bill, bukan keluar
  aplikasi.

### Diperbaiki

- Tagihan sementara tamu saat masih ada porsi yang belum dibagi: tamu A
  dengan satu porsi Rp 3.500 sempat tampil menanggung seluruh total
  Rp 23.678. Porsi yang belum bertamu kini ikut sebagai bobot pembagian
  (ditemukan saat uji manual).
- `sales.paid_amount` bill F&B kembali sama dengan retail (= total nota);
  sempat berubah menjadi Σ uang diterima saat fungsi penyelesaian nota
  digabung.
- Kunci baris item di layar split memakai ID baris sehingga dua baris
  bernama sama (modifier berbeda) tidak bentrok.

### Keamanan

- Atur split, bagi porsi, dan batalkan bagian menunggu butuh
  `open_bills:manage` dan `sales:create`; *Sudah Terbayar* juga
  `payments:confirm`. Tombol *Split bill* nonaktif bagi pelayan tanpa izin
  penjualan.

### Catatan teknis

- Aturan pembagian di `lakuna_domain/split_bill.dart` (`SplitLimits`,
  `guestLabel`, `allocateByWeight`, `splitPortion`, `splitDues`); data di
  `lakuna_data/split_bill.dart` (`setBillSplit`, `assignPortion`,
  `paySplitPart`, `confirmSplitPayment`, `cancelSplitPayment`, `BillSplit`).
- Kembalian tunai dicatat per pembayaran (`payments.change_amount`).
- Gap tercatat di spec F1-10: tarif belum dibekukan saat bagian pertama
  dibayar, tunai bagian masuk sesi yang menyelesaikan nota, memindah baris
  satu porsi menyisipkan baris baru, retur bagian lunas menunggu F1-13.

## [0.12.0] - 2026-11-03

Modifier menu F&B (F1-10 bagian kedua, layar 1.8, 1.16b, 1.17b). Kafe dan
warung bisa membuat pilihan seperti ukuran, level pedas, atau topping,
memasangnya di menu, lalu memilihnya saat menambah pesanan di layar Meja.

### Ditambahkan

- **Master data › Modifier** (1.17b, izin `products:manage`):
  - Daftar grup dengan aturan ("Wajib · pilih 1", "Opsional · maks 2"),
    jumlah opsi, dan jumlah menu pemakai; urutkan naik/turun; hapus grup
    ditolak bila masih dipasang di menu.
  - Form grup (dialog): nama, saklar *Wajib dipilih*, minimal dan
    maksimal pilih (0–20), opsi 1–30 dengan nama, tambahan harga (boleh
    negatif, mis. "Tanpa gula −Rp 2.000"), *Bawaan*, dan *Tersedia/Habis*.
    Dialog tetap terbuka sampai simpan berhasil; kesalahan tampil di kolom
    terkait.
- **Form produk › tab Modifier** (1.16b): pasang grup dari master,
  urutkan naik/turun, lepas. Urutan ini dipakai di sheet 1.8. Disimpan
  bersama produk dalam satu transaksi.
- **Sheet *Pilih modifier*** (1.8) di layar Meja untuk menu yang punya
  grup modifier:
  - Label aturan per grup (amber bila wajib), opsi sebagai tombol pilihan
    dengan harga tambahan, opsi *Habis* dicoret dan tidak bisa dipilih,
    opsi *Bawaan* terpilih otomatis.
  - Pilih satu (radio) untuk maks 1, centang dengan batas untuk maks > 1.
  - *Catatan untuk dapur*, jumlah − / + (1–999), tombol *Tambah ke bill ·
    Rp X* yang aktif setelah semua grup wajib terpenuhi.
  - Menu tanpa modifier tetap langsung masuk bill seperti v0.11.0.
- Modifier tampil di **panel bill** ("+ Besar, Boba"), **tiket dapur**
  (`+ Besar` per baris sebelum catatan `*`), **ringkasan Bayar**, dan
  **struk** (`+ Besar 4.000`, potongan `+ Tanpa gula -2.000`, baris
  rincian `3 x 14.000` = harga + tambahan).

### Diubah

- Baris bill digabung hanya bila varian, satuan, catatan, set modifier,
  dan tambahan per satuan sama.
- Subtotal nota (harga daftar) kini termasuk tambahan modifier.

### Diperbaiki

Bug berikut ditemukan saat review kode dan uji layar sebelum rilis:

- Mengubah jumlah item dengan harga grosir + tambahan negatif bisa membuat
  harga satuan di bawah nol; kini ditolak `ModifierPriceInvalid`.
- Menambah item yang sama setelah harga opsi diubah di master menggabung
  ke baris lama dengan tambahan lama; kini menjadi baris baru.
- Menghapus item bill (jumlah 0) meninggalkan baris modifier yatim yang
  ikut tersinkron; kini ikut dihapus.
- Sheet modifier di ponsel 360 px meluap 38 px; judul grup dan tombol opsi
  kini membungkus.

### Keamanan

- Pilihan modifier divalidasi ulang di lapisan data: opsi harus milik grup
  yang terpasang di menu itu, tersedia, tidak dobel, dan jumlah per grup
  di antara minimal dan maksimal (`ModifierSelectionInvalid`), sehingga
  harga tidak bisa dimanipulasi dari UI.

### Catatan teknis

- Migrasi `modifier`: tabel `modifier_groups`, `modifiers`,
  `product_modifier_groups`, `sale_item_modifiers`; `sale_items` mendapat
  `modifier_delta` (bawaan 0) dan `modifier_key` (nullable). Diuji manual
  dengan membuka data v0.11.0.
- `sale_items.unit_price` tetap harga dasar (grosir berlaku di harga
  dasar); `line_total = (unit_price + modifier_delta) × jumlah`.
  `sale_item_modifiers` menyimpan salinan nama grup, nama opsi, dan harga
  sehingga nota lama tidak berubah saat master diubah.
- Aturan di `lakuna_domain/modifier.dart` (`validateModifierGroup`,
  `validateModifierSelection`, `modifierDelta`, `modifiedUnitPrice`,
  `modifierKey`); data di `lakuna_data/modifier_admin.dart` dan
  `open_bill.dart`. Kueri pemasangan dibatasi ke produk dan grup yang
  dipakai.
- Tes baru: domain (aturan grup, pilihan, harga, struk), data (master,
  pemasangan, bill, gabung, grosir, hapus), view model dan widget (tab
  Modifier, form produk, sheet di tablet dan ponsel 360 px, alur meja
  sampai struk).
- Rilis v0.9.0 dan v0.10.0 tidak terbit di GitHub Releases (job macOS
  batal sebelum `release.yml` diperbaiki di v0.11.0); isinya termasuk
  dalam v0.11.0 dan seterusnya.
- Tunda: modifier di kasir retail, toggle tiket dapur/catatan per menu,
  split bill (v0.13.0), denah (v0.14.0).

## [0.11.0] - 2026-11-03

Meja F&B dan open bill (F1-10 bagian pertama, layar 1.7 dan 1.7e). Warung
makan dan kafe bisa membuka meja, mencatat pesanan, mengirim tiket ke
dapur, lalu menutup dan membayar bill dengan service charge dan PB1.

### Ditambahkan

- **Menu Meja** (`/meja`, izin `open_bills:manage`) di kelompok
  *Penjualan* setelah Kasir:
  - Subjudul "Pelayan: {staf} · {n} dari {m} meja terisi", pilihan
    **Dine in / Take away**, legenda *Kosong / Terisi · open bill / Minta
    bill*, tab area (*Semua* + setiap area).
  - Kartu meja: nama, jumlah tamu, total bill, lama duduk, warna sesuai
    status. Membuka meja kosong menanyakan jumlah tamu (bawaan = kursi
    meja, 1–99).
  - **Take away** bernomor `TA-01`, `TA-02`, … per hari per perangkat,
    dengan nama pemesan opsional, badge *Baru / Di dapur / Siap ambil*,
    dan *Hapus bill kosong*. *Take away baru* memakai ulang take away
    kosong sehingga nomor tidak terbuang.
  - **Panel bill** (kanan 400 px di layar lebar, satu halaman dengan tombol
    kembali di ponsel): item dengan jumlah, catatan, badge *Baru / Di
    dapur / Disajikan*; item *Baru* bisa ditambah, dikurangi, dihapus;
    item di dapur bisa *Tandai disajikan*. Subtotal, *Service X% (dine
    in)*, *PB1 Y%*, Total.
  - **+ Menu**: lembar pilih menu dengan pencarian, chip kategori, dan
    catatan dapur untuk item berikutnya ("tanpa es").
  - **Kirim ke dapur (n item baru)**: menyimpan item, membuat tiket
    `K-0001` (urut per hari per perangkat), lalu menampilkan pratinjau
    *TIKET DAPUR* monospace tanpa harga dengan tombol *Cetak tiket* ke
    printer struk perangkat.
  - **Minta bill** / *Batal minta bill* (dine in), **Pindah meja** ke meja
    kosong, **Batalkan bill** dengan alasan wajib (izin `sales:void`).
  - **Tutup & bayar** membuka layar Bayar yang sama dengan kasir
    (`/kasir?bill=…`) dengan total bill. Semua metode bayar bisa dipakai.
    Setelah lunas ada tombol **Kembali ke meja**; *Kembali* dari tahap
    bayar mengembalikan ke bill yang masih terbuka.
- **Master data › Meja & area** (izin `settings:manage`): tambah, ganti
  nama, urutkan, dan hapus area (ditolak bila masih punya meja); tambah,
  ubah, urutkan, dan hapus meja (ditolak bila masih ada bill terbuka);
  **Tambah beberapa** membuat M1–M12 sekaligus dengan pratinjau nama.
- **Pengaturan › Pajak & service** per cabang: service charge 0–30% dan
  PB1 0–20% dengan kelipatan 0,5%, pratinjau contoh dine in Rp 100.000,
  dan tombol *Simpan tarif* yang aktif hanya bila ada perubahan sah.
- **Struk** open bill mencantumkan baris *Pesanan* (Meja M4 / TA-01),
  *Subtotal*, *Service 5%*, dan *PB1 10%*.

### Diubah

- Layar Kasir bisa dibuka dalam mode bill (`/kasir?bill=<id>`): langsung ke
  tahap Bayar dengan subjudul "Meja M4 · 2 item" dan rincian bill hanya
  baca (item, subtotal, service, PB1, total). Bill yang tidak ditemukan
  atau masih kosong menampilkan pesan dan tombol *Kembali ke meja*; tombol
  yang sama muncul bila sesi kasir belum dibuka.
- Inti penjualan (`sale_core.dart`) dipisah dari `sales.dart` agar kasir
  retail dan bayar open bill memakai jalur nomor nota, pembayaran, dan
  pergerakan stok yang sama.

### Diperbaiki

- Tombol *Tambah beberapa* dan *Tambah meja* meluap 228 px di ponsel 360 px
  saat berada di judul kartu; kini berada di bawah judul.
- Baris aksi item bill, pil mode, legenda, kartu take away, dan kartu menu
  tidak lagi meluap di 360 px (termasuk saat dialog beranimasi).
- Tes sidebar desktop menggulir daftar menu yang dibangun malas, sehingga
  menu baru tidak mendorong entri terakhir keluar dari pemeriksaan.
- Temuan review sebelum rilis:
  - *Take away baru* yang memakai ulang take away kosong kini menghapus
    nama pemesan lama bila pesanan baru tanpa nama (sebelumnya tiket dan
    struk tetap atas nama pemesan sebelumnya).
  - Panjang nama pemesan, catatan dapur, dan alasan batal dihitung per
    karakter (emoji tidak lagi ditolak padahal lolos di kolom isian).
  - Galat aksi bill lama tidak ikut tampil saat lembar *+ Menu* dibuka.
  - Pencarian meja dan varian saat memuat dan membayar bill dibatasi
    `tenant_id`.

### Keamanan

- Setiap aksi bill dicek di repositori: `open_bills:manage` untuk semua
  aksi, `sales:create` untuk bayar, `sales:void` untuk batal,
  `settings:manage` untuk meja, area, dan tarif. Pelayan tidak melihat
  tombol batal dan tombol bayar diganti catatan "Pembayaran oleh kasir".

### Catatan teknis

- Migrasi `meja`: tabel `dining_areas`, `dining_tables`, `kitchen_tickets`;
  `sales` mendapat `order_type`, `dining_table_id`, `bill_number`,
  `queue_number`, `customer_name`, `guest_count`, `opened_by`, `opened_at`,
  `bill_requested_at`, `service_bp`, `tax_bp`, `service_amount`,
  `tax_amount`, `void_reason`, `voided_by`, `voided_at`; `sale_items`
  mendapat `kitchen_status`, `kitchen_ticket_id`, `note`. Semua kolom baru
  nullable atau berbawaan. Diuji manual dengan membuka data v0.10.0.
- Open bill adalah baris `sales` berstatus `open` dengan nomor
  `OB-<outlet>-<perangkat>-<yymmdd>-<nnnn>`; saat lunas `number` diganti
  nomor nota biasa dan nomor bill tetap di `bill_number`. Stok keluar
  sekali saat lunas, tidak saat dikirim ke dapur.
- Aturan tarif di `lakuna_domain` (`fnbCharges`, `validateFnbRate`,
  `FnbLimits`): service = subtotal × tarif (hanya dine in), PB1 =
  (subtotal + service) × tarif, dibulatkan setengah ke atas ke rupiah.
  Tarif disimpan di `settings` (`fnb.service_bp`, `fnb.tax_bp`, basis
  poin) per cabang.
- Data di `lakuna_data/open_bill.dart` dan `dining_admin.dart`, semua tulis
  lewat `LakunaStore.write` + `SyncTx` sehingga masuk outbox sync.
- Tes baru: domain (tarif, nomor), data (open bill, meja & area), view
  model dan widget (alur meja tablet, bayar, pindah, batal, pelayan, take
  away 360/820 px, ponsel + tombol kembali sistem, tab Meja & area, Pajak
  & service).
- Tunda ke rilis berikutnya: modifier (v0.12.0), split bill (v0.13.0),
  denah `vyuh_node_flow` (v0.14.0).
- `release.yml`: GitHub Release tetap terbit bila installer Linux, Windows,
  dan Android berhasil walau runner macOS tidak didapat (rilis v0.9.0
  tertahan karena job macOS dua kali batal). Catatan rilis menyebut
  installer Apple yang belum tersedia.

## [0.10.0] - 2026-11-03

Master data (F1-09, layar 1.17). Pemilik merapikan kategori yang terbentuk
dari form produk, mengatur urutan dan warnanya di kasir, dan mengelola
satuan dari satu tempat.

### Ditambahkan

- **Menu Master data** (`/master`, izin `products:manage`) di kelompok
  *Produk & stok* setelah Stok. Tab vertikal di layar lebar, pil di ponsel:
  *Kategori*, *Satuan*, *Lokasi stok*, *Metode pembayaran*.
- **Kategori**:
  - Daftar terurut dengan titik warna, nama induk ("Minuman › Kopi"),
    jumlah produk, badge *Tidak di kasir* / *Nonaktif*, saklar *Aktif*,
    tombol naik/turun, dan *Ubah*.
  - Form *Kategori baru* / *Ubah kategori*: nama (wajib, maks 60 karakter,
    unik per tenant tanpa membedakan huruf), kategori induk (satu tingkat),
    8 pilihan warna atau tanpa warna, *Tampil di kasir*, *Aktif*.
  - Induk terkunci bila kategori itu sendiri punya subkategori; label induk
    yang namanya mirip dibedakan agar tidak kembar.
  - *Hapus kategori* dengan dialog konfirmasi; ditolak bila masih dipakai
    produk atau masih punya subkategori, dan pesannya menyebut jumlah
    keduanya.
  - Di ponsel baris menjadi kartu dan form dibuka di lembar bawah.
- **Satuan**: daftar satuan dengan jumlah produk yang memakai (satuan dasar
  maupun satuan konversi varian), tambah, ganti nama di tempat, hapus dengan
  konfirmasi (ditolak bila dipakai).
- **Lokasi stok** (baca) dengan tombol *Kelola di Stok* yang membuka Stok ›
  Lokasi stok langsung (`/stok?tab=locations`).
- **Metode pembayaran**: ringkasan metode aktif dengan tombol *Buka
  Pengaturan*.

### Diubah

- **Kasir** memakai urutan dari Master data, hanya menampilkan kategori
  aktif yang tampil di kasir dan dipakai produk (langsung atau lewat
  subkategori), dan menampilkan titik warna di chip. Memilih kategori induk
  ikut menampilkan produk subkategorinya.
- Form produk hanya menyarankan kategori aktif. Mengetik nama kategori
  nonaktif yang sudah ada memakai kategori itu (tidak membuat kembar).
- Kategori baru dari form produk mendapat urutan paling akhir (sebelumnya
  0, sehingga urutan bisa kembar).
- Layar Stok bisa dibuka langsung ke tab tertentu lewat `?tab=`.

### Diperbaiki

- Galat satuan (nama kembar, gagal simpan) kini tampil di baris yang
  bersangkutan, tidak tertelan.
- Menutup lembar form ponsel tanpa *Batal* keluar dari mode ubah, sehingga
  *+ Kategori* berikutnya tidak membuka form kategori lama.
- Galat naik/turun dan saklar aktif tampil di atas daftar, terpisah dari
  galat form.
- Tombol aksi dinonaktifkan selama daftar dimuat ulang.
- Chip kategori tanpa warna kembali memakai teks biasa sehingga label
  panjang membungkus dengan benar (luapan 30 px di pengaturan struk).

### Catatan teknis

- Migrasi `master`: kolom `parent_id` (relasi ke `categories`, Restrict),
  `color`, `show_in_cashier`, `is_active` di `categories`. Tidak ada tabel
  baru.
- Aturan bisnis di `lakuna_domain` (`validateCategory`, `validateUnitName`,
  `moveInOrder`, `categoryColors`); data di `lakuna_data/master_data.dart`.
  Urutan dinomori ulang 0..n dalam satu transaksi dan hanya baris yang
  nomornya berubah yang masuk outbox sync.
- Hapus kategori dan satuan berupa soft delete (`deleted_at`).
- Repositori `MasterDataRepository` mengecek `products:manage` di setiap
  aksi.
- Tes baru: domain (validasi, urutan), data (13 tes master), view model dan
  widget (alur kategori, satuan, ponsel, 360/820/1280 px tanpa luapan,
  tanpa izin).

## [0.9.0] - 2026-11-03

Stok (F1-08, layar 1.18). Pemilik dan staf gudang melihat stok per lokasi,
mencatat penyesuaian dengan alasan yang bisa diaudit, menelusuri setiap
pergerakan di kartu stok, dan melihat barang yang sudah di bawah minimum.

### Ditambahkan

- **Menu Stok** (`/stok`, izin `stock:adjust`) dengan lima tab: *Daftar
  produk*, *Penyesuaian*, *Kartu stok*, *Stok minimum*, *Lokasi stok*. Di
  layar lebar tab berupa bilah tab; di ponsel berupa pil.
- **Penyesuaian stok baru**:
  - Nomor dokumen `SA-<OUTLET>-<PERANGKAT>-<yymmdd>-<nnnn>` dan nama staf di
    kepala kartu; nomor urut per hari per perangkat (tanggal lokal cabang).
  - *Alasan umum* (Cek rutin, Rusak, Hilang, Kedaluwarsa, Lainnya), catatan
    dokumen (maks 200 karakter), dan alasan per baris (maks 60 karakter).
  - **Scan / tambah produk**: Enter menambah barang lewat barcode atau SKU
    persis, atau nama yang hanya cocok satu produk; saran nama muncul saat
    mengetik; fokus tetap di field agar pemindai bisa langsung memindai
    barang berikutnya. Kode tak dikenal: "Produk "…" tidak ditemukan."
    Barang yang dipindai ulang tidak menambah baris dan diberi tahu "Produk
    ini sudah ada di daftar penyesuaian."
  - Tabel Produk / Sistem / Fisik / Selisih / Alasan / Nilai (HPP) dan total
    nilai; selisih bertanda dan berwarna (merah berkurang, hijau bertambah).
    Di ponsel tiap baris menjadi kartu.
  - Baris yang fisiknya kosong tidak disimpan; baris dengan selisih 0
    disimpan sebagai bukti sudah dihitung tetapi tidak membuat pergerakan.
  - Selisih dihitung ulang dari stok **saat disimpan** di dalam transaksi
    tulis, jadi penjualan yang terjadi sambil mengisi tetap terhitung.
  - Nilai selisih = selisih × HPP rata-rata saat itu, atau harga modal bila
    rata-rata masih 0.
  - Ditolak dengan pesan jelas: tidak ada baris yang diisi, fisik minus,
    produk dua kali, jasa/menu, produk terhapus, lokasi cabang lain, atau
    semua selisih 0.
  - Daftar **Penyesuaian terakhir** (10 dokumen): nomor, waktu, alasan,
    jumlah produk, staf, lokasi, dan total nilai.
- **Kartu stok**: pilih produk; "Stok sekarang X · minimum Y"; tabel Waktu
  (zona waktu cabang), Keterangan (*Stok awal*, *Penjualan <nota>*,
  *Penyesuaian <nomor> · <alasan> (<staf>)*, catatan baris), Masuk/keluar,
  dan Saldo berjalan; 200 pergerakan terakhir dengan saldo sebelumnya.
- **Daftar produk** stok per lokasi: stok, minimum, nilai (stok × HPP), tanda
  *Di bawah minimum* / *Minus*, total nilai stok, cari nama/SKU/barcode.
  Mengetuk baris membuka kartu stoknya.
- **Stok minimum**: barang dengan stok ≤ minimum, paling kritis dulu,
  "stok / minimum"; mengetuk baris membuka kartu stoknya.
- **Lokasi stok**: daftar lokasi cabang (Etalase bawaan), tambah dan ganti
  nama (maks 40 karakter, unik per cabang tanpa membedakan huruf besar/kecil).
  Bila lokasi lebih dari satu, pilihan lokasi muncul di kepala layar.
- Tabel `stock_adjustments` dan `stock_adjustment_items` (migrasi `stock`),
  tercatat di outbox sinkronisasi.

### Diubah

- **Navigasi bawah ponsel** mengikuti kanvas 1.15m: *Beranda, Kasir,
  Produk, Riwayat, Lainnya*. *Lainnya* membuka lembar berisi menu lain yang
  boleh dibuka staf (mis. Sesi kasir, Stok, Pengaturan), dikelompokkan
  seperti sidebar. Sebelumnya menu di luar lima entri tetap tidak bisa
  dibuka di ponsel.
- Teks Beranda menyebut stok sudah bisa dipakai.
- Isian draf penyesuaian dan pilihan lokasi terkunci selama menyimpan agar
  ketikan tidak hilang saat draf dikosongkan.

### Diperbaiki

- Tombol berlabel panjang di layar sempit (mis. *Simpan penyesuaian* di
  ponsel 360 px) tidak lagi meluap; label menyusut.
- Baris lokasi stok di ponsel tidak lagi meluap: nama dan tanda *Bawaan*
  dibungkus, tombol ganti nama menjadi ikon pensil (ditemukan saat tes
  widget di 360 px).

- Ganti lokasi atau produk kartu stok dengan cepat tidak lagi menampilkan
  data campuran: hasil muat yang sudah usang dibuang dan lokasi terbaru
  dimuat ulang (ditemukan saat review).
- Pilihan produk di kartu stok tetap lengkap bila ada nama produk kembar
  (label ditambah SKU/barcode).
- Panjang alasan/catatan dihitung per karakter (emoji = 1), sama dengan
  penghitung field.

### Keamanan

- Simpan penyesuaian serta tambah/ganti nama lokasi butuh izin
  `stock:adjust`, dicek di layar (tombol hilang, catatan izin) dan di
  repositori (`NotPermitted`). Menu dan rute Stok butuh `stock:adjust`.

### Catatan teknis

- Stok tetap ledger: penyesuaian hanya menambah baris `stock_movements`
  lewat `recordStockMovement` (`source_type = adjustment`), cache
  `stock_levels` ikut diperbarui; pergerakan keluar dan masuk memakai HPP
  saat itu sehingga rata-rata tidak bergeser.
- Minimum stok berlaku di lokasi bawaan (tempat jual), sama dengan daftar
  produk F1-07; di lokasi lain kolom minimum kosong dan tidak ada tanda.
- Aturan baru di `lakuna_domain` (`stockDifference`, `adjustmentUnitCost`,
  `adjustmentValue`, `validateLocationName`) dan `lakuna_data`
  (`saveStockAdjustment`, `stockCard`, `stockList`, `belowMinimumStock`,
  lokasi), diuji di paket masing-masing.

## [0.8.0] - 2026-11-03

Struk dan printer (F1-06, layar 1.12 dan 1.26). Setelah bayar, kasir bisa
mencetak struk ke printer thermal Bluetooth (Android) atau jaringan (LAN),
lewat dialog cetak sistem, atau membagikan PDF-nya. Pemilik mengatur header,
footer, lebar kertas, dan cetak otomatis per cabang.

### Ditambahkan

- **Layar Pembayaran berhasil (1.12)**:
  - Struk tampil seperti kertas thermal (huruf DM Mono, 32 kolom untuk
    58 mm, 48 kolom untuk 80 mm), sama persis dengan yang dicetak.
  - Kartu **Printer struk** dengan nama printer, jenis, dan lebar kertas
    (mis. "RPP02N · Bluetooth · 58 mm"), atau "Belum ada printer".
  - Tombol **Cetak struk** dan **Bagikan PDF**. Di Android/iOS PDF dibuka di
    lembar bagikan; di desktop disimpan ke `Dokumen/Lakuna/Struk/<nota>.pdf`
    dan lokasinya ditampilkan.
  - Pesan galat yang jelas bila cetak gagal (Bluetooth mati, izin ditolak,
    printer tidak terjangkau, kirim gagal, tidak menjawab) dengan **Coba
    lagi**. Nota tetap tersimpan walau cetak gagal.
  - **Cetak otomatis** sekali per nota bila diaktifkan dan printer
    Bluetooth/LAN dipilih.
- **Pengaturan › Struk & printer (1.26)**, hanya untuk staf dengan izin
  `settings:manage`:
  - **Printer perangkat ini** (disimpan di perangkat saja): *Bluetooth*
    (Android, daftar printer yang sudah dipasangkan), *Jaringan (LAN)*
    dengan alamat IP/host dan port (bawaan 9100), atau *Dialog cetak
    sistem*. Tombol **Tes cetak** dan **Lupakan printer**.
  - **Struk cabang ini** (berlaku di semua perangkat cabang): lebar kertas
    58/80 mm, header (bawaan alamat dan telepon cabang), footer (bawaan
    "Terima kasih, sampai jumpa lagi!"), masing-masing maks 4 baris × 48
    karakter, dan sakelar *Cetak otomatis setelah bayar*.
  - **Pratinjau struk** langsung berubah saat isian diketik.
  - Tombol **Simpan** dan **Batal**; pesan "Pengaturan struk tersimpan".
- Struk memuat nama toko, cabang, header, nomor nota, tanggal (zona waktu
  cabang), kasir, barang (nama, qty × harga, subtotal; harga grosir sudah
  terhitung), total, setiap pembayaran, kembalian tunai, dan footer.

### Diubah

- Pratinjau struk lama di layar berhasil diganti mesin baris struk yang
  sama untuk layar, PDF, dan ESC/POS.
- Catatan "Cetak otomatis bisa diaktifkan di Pengaturan" hanya muncul bila
  cetak otomatis belum aktif.

### Diperbaiki

- PDF struk kadang kehilangan baris terakhir (footer): galat pembulatan
  membuat isi sedikit lebih tinggi dari halaman sehingga paket `pdf`
  membuang baris itu. Halaman kini diberi kelonggaran 2 pt; diuji 1 sampai
  80 baris di kedua lebar kertas (ditemukan saat uji manual).
- *Bagikan PDF* di Linux tanpa `xdg-user-dir` gagal karena folder Dokumen
  tidak dikenal; kini disimpan ke folder data aplikasi
  (`~/.local/share/id.lakuna.app/Struk`) (ditemukan saat uji manual).
- Cetak Bluetooth selalu gagal "kirim gagal": byte dikirim sebagai
  `Uint8List` yang tiba di plugin Android sebagai `byte[]`, padahal plugin
  membaca `List<Int>`. Kini dikirim sebagai `List<int>` biasa (ditemukan
  saat code review).
- Android 12+: dialog izin Bluetooth tidak pernah muncul dan *Cari printer*
  melapor "Bluetooth mati". Izin kini diminta lebih dulu; bila ditolak
  pesannya "Izin Bluetooth ditolak" (ditemukan saat code review).
- Galat cetak atau PDF nota sebelumnya tidak lagi muncul di layar berhasil
  nota berikutnya. *Transaksi baru* ditahan selama struk masih dicetak agar
  hasil cetak tidak tertukar antar nota (ditemukan saat code review).
- Struk di layar tidak lagi terpotong di kanan saat ukuran huruf sistem
  diperbesar (mis. 130% di Android) (ditemukan saat code review).
- Teks non-ASCII (emoji, "ß", aksen terurai) diratakan ke ASCII sebelum
  ditata sehingga satu karakter selalu satu kolom dan nominal tetap rata
  kanan; pratinjau sama persis dengan cetakan (ditemukan saat code review).
- Header yang dikembalikan sama dengan alamat cabang disimpan sebagai
  bawaan lagi, sehingga ikut berubah bila alamat atau telepon cabang diubah.
- Bagian Pengaturan struk di layar sekitar 750 px jatuh ke tata letak
  sempit dan baris status printer meluap di ponsel (ditemukan saat uji
  manual).

### Keamanan

- Pengaturan struk cabang hanya bisa disimpan staf dengan `settings:manage`,
  dicek di UI dan di `LocalReceiptSettingsRepository`.
- Header dan footer divalidasi (maks 4 baris × 48 karakter) di domain dan
  repositori. Karakter di luar ASCII diubah ke padanan ASCII (mis. "é" →
  "e", "—" → "-") atau "?" sebelum dikirim ke printer, sehingga byte kendali
  tidak bisa disisipkan lewat teks struk.

### Catatan teknis

- Domain: `receipt.dart` (`ReceiptPaper`, `ReceiptLine`, `ReceiptContent`,
  `wrapText`, `layoutPair`, `layoutReceipt`, `validateReceiptSettings`) dan
  `escpos.dart` (`receiptAscii`, `encodeEscPos`: `ESC @`, `ESC a`, `ESC E`,
  `ESC d 3`, `GS V 66 0`).
- Data: `ReceiptSettings` di tabel `settings` (`scope_key` =
  `outlet:<id>`, `key` = `receipt.settings`, nilai JSON) lewat outbox sync;
  pilihan printer di preferensi lokal `printer.selected` (tidak disinkron).
- Aplikasi: `ReceiptPrinter` (abstrak + palsu untuk tes) dan
  `PlatformReceiptPrinter`: Bluetooth lewat `print_bluetooth_thermal`, LAN
  lewat soket TCP mentah (batas waktu 5 detik), dialog cetak dan PDF lewat
  `printing` + `pdf`. `ReceiptSettingsRepository` (lokal + palsu).
- Dependensi baru: `pdf`, `printing`, `print_bluetooth_thermal`. Font DM
  Mono (OFL) dibundel di `assets/fonts/DM_Mono`.
- Uji manual memakai printer LAN tiruan (soket 9100 yang menyimpan byte)
  dan dekoder ESC/POS; struk 58 dan 80 mm terbaca benar.
- Printer Bluetooth belum diuji di perangkat fisik.

## [0.7.0] - 2026-11-03

QRIS statis dengan konfirmasi manual (F1-05, layar 1.6 dan 1.6m), split
payment (panel 1.5), dan pengaturan QRIS statis per cabang (F1-18, layar
1.26b). Pemilik mengunggah stiker QRIS utuh sekali; kasir menampilkannya
saat bayar dan menekan *Sudah Terbayar* setelah dana masuk.

### Ditambahkan

- **Pengaturan › Metode pembayaran › QRIS statis (1.26b)**, hanya untuk
  staf dengan izin `settings:manage`:
  - Pratinjau stiker QRIS utuh dengan rasio asli (tidak dipotong), nama file
    dan ukurannya.
  - *Pilih file* (PNG, JPG, atau WebP, maks 5 MB) lewat dialog berkas
    sistem.
  - **Hasil pemeriksaan**: rasio vertikal (mis. "1 : 1,41"), resolusi
    (disarankan ≥ 1000 px lebar), dan galat bila file bukan PNG/JPG/WebP atau
    lebih dari 5 MB. Format dicek dari isi file, bukan nama file.
  - Catatan "Unggah stiker utuh, bukan potongan QR".
  - **Data merchant**: nama merchant, NMID (huruf/angka, disimpan huruf
    besar), kode terminal, dan *Dana masuk ke* (petunjuk kasir saat cek
    mutasi).
  - Sakelar *QRIS statis aktif di kasir* (butuh gambar) dan *Wajib tekan
    "Sudah Terbayar"* (selalu aktif).
  - Tombol **Simpan** dan **Batal**; pesan "Pengaturan QRIS tersimpan".
- **Layar Pengaturan bernavigasi bagian**: kolom kiri di layar lebar, pil di
  ponsel. Bagian *Metode pembayaran* dan *Tampilan & bahasa*.
- **Bayar QRIS statis (1.6 tablet/desktop, 1.6m ponsel)**:
  - Pilihan metode *QRIS statis · Konfirmasi manual* muncul bila QRIS statis
    aktif dan gambarnya ada.
  - Stiker QRIS utuh, lencana *Menunggu konfirmasi kasir*, "Scan QRIS, ketik
    nominal persis" dengan nominal besar, nama merchant · NMID · kode
    terminal, *Dana masuk ke*, empat langkah, dan peringatan "Jangan
    konfirmasi dari tangkapan layar pelanggan saja".
  - *Perbesar gambar QRIS* (desktop/tablet) atau ketuk gambar (ponsel)
    membuka stiker layar penuh yang bisa di-zoom.
  - **Belum masuk** kembali ke *Tunai* tanpa menyimpan apa pun. **Sudah
    Terbayar** menyimpan nota dan mencatat siapa dan kapan konfirmasi
    (`confirmed_by`, `confirmed_at`). Di ponsel kedua tombol ada di bilah
    bawah.
  - Tanpa izin `payments:confirm` tombol *Sudah Terbayar* mati dengan
    petunjuk; penyimpanan juga menolak.
- **Split payment (Bagi beberapa metode)**:
  - Daftar bagian (metode, nominal, lencana *Diterima* / *Menunggu*, hapus),
    form tambah dengan pilihan Tunai / Kartu / Transfer / QRIS statis dan
    nominal yang terisi otomatis dengan sisa, lalu *Tambah metode*.
  - Baris **Sisa** dan **Kembalian** (bila tunai melebihi sisa).
  - Bagian QRIS masuk sebagai *Menunggu*; *Konfirmasi* membuka dialog
    stiker dengan nominal bagian itu. *Sudah Terbayar* mengubahnya jadi
    *Diterima*, *Belum masuk* menghapus bagian itu.
  - *Selesaikan pembayaran* aktif hanya bila sisa nol dan tidak ada QRIS
    yang menunggu.
- **Struk dan layar berhasil** menampilkan setiap pembayaran (mis. "Kartu
  debit / kredit 10.000", "QRIS statis 13.000") dan kembalian; ringkasan
  "Split · 2 metode Rp X".

### Diubah

- Satu nota bisa punya beberapa pembayaran. Kembalian hanya dari bagian
  tunai; non-tunai tidak boleh melebihi total.
- Kartu metode bayar di ponsel tersusun tiga per baris dengan tinggi sama.
- Layar Pengaturan dibuka di bagian *Metode pembayaran* untuk pemilik dan
  manajer; staf lain langsung melihat *Tampilan & bahasa*.

### Diperbaiki

- Label pembayaran panjang di pratinjau struk (mis. "QRIS statis") tidak
  lagi terpotong ke dua baris (ditemukan saat uji manual).
- Lencana *Diterima* dan catatan QRIS menunggu memakai warna status tetap
  agar terbaca di tema gelap (ditemukan saat uji manual).
- Dialog konfirmasi QRIS di split kini berbingkai padding (isi sempat
  menempel ke tepi dialog saat uji manual).
- Penjualan bertotal Rp 0 (barang harga 0) kembali bisa diselesaikan
  dengan tunai 0 atau kartu/transfer; sempat ditolak sebagai "uang kurang"
  oleh aturan pelunasan baru (ditemukan saat code review).
- Kasir tanpa izin `payments:confirm` tidak lagi ditawari QRIS sebagai
  bagian split yang tidak bisa ia konfirmasi.
- Menghapus bagian split kini juga menghapus pesan galat bayar sebelumnya.
- Checkout QRIS memeriksa baris gambar stiker masih ada, bukan hanya
  isiannya.
- Stiker yang sama diunggah di cabang lain kini mendapat baris media milik
  cabang itu (sebelumnya memakai baris cabang pertama).
- Baris pengaturan QRIS yang rusak (bukan objek JSON) tidak lagi membuat
  simpan gagal tanpa pesan; dibaca sebagai bawaan lalu ditimpa.

### Keamanan

- Konfirmasi QRIS diperiksa di dua lapis: UI (tombol mati) dan
  `LocalCashierRepository` (`NotPermitted(payments:confirm)`).
- Pengaturan QRIS hanya bisa dimuat dan disimpan staf dengan
  `settings:manage`, dicek di repositori juga.
- Gambar stiker diperiksa dari isi file (header PNG/JPEG/WebP) dan dibatasi
  5 MB; file lebih dari 5 MB tidak dibaca ke memori.
- macOS: hak `com.apple.security.files.user-selected.read-only` agar dialog
  berkas bisa membaca file pilihan pengguna di dalam sandbox.

### Catatan teknis

- Domain: `settleTender` (galat `empty`, `nonPositive`, `multipleCash`,
  `nonCashOver`, `short`), `readImageHeader` (PNG, JPEG SOF, WebP VP8 /
  VP8L / VP8X tanpa dekoder gambar), `checkQrisImage`,
  `validateQrisSettings`.
- Model baru `MediaFile` (tabel `media_files`, enum `MediaKind`) dan migrasi
  `qris`. Berkas disimpan di `<folder data>/media/<sha256>.<ext>`; berkas
  yang sama tidak disalin dua kali. Fase 2 bisa mengunggah dengan kunci yang
  sama ke object storage.
- Pengaturan QRIS disimpan di tabel `settings` (`scope_key` =
  `outlet:<id>`, `key` = `payments.qris_static`, nilai JSON) lewat outbox
  sync.
- `checkoutSale(payments: [...])` menggantikan `payment:`;
  `SalePaymentRequest.amount` menggantikan `received`, ditambah `confirmed`.
  `CheckoutResult.payments` menggantikan `payment`. Galat baru
  `SalePaymentInvalid` dan `SalePaymentUnconfirmed`.
- Aplikasi: `PaymentSettingsRepository` (lokal + palsu), `ImageFilePicker`
  di atas `file_selector`, `PayMode` dan `SplitPart` di view model kasir.
- Dependensi baru: `file_selector` (aplikasi), `crypto` (data).
- Spec baru F1-18 Pengaturan; spec F1-05 diperbarui dengan lingkup v0.7.0.
- Belum: referensi kartu/transfer per bagian split, PIN manajer untuk
  *Sudah Terbayar*, pembacaan QR otomatis (NMID), foto stiker dari kamera
  (dicatat sebagai gap di spec).

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

Ditemukan saat uji manual dan review kode, diperbaiki sebelum rilis:

- Kolom cari kasir kehilangan fokus saat produk atau tombol keranjang
  diklik dengan mouse, sehingga scan barcode berikutnya tidak masuk. Di
  desktop kolom kini tetap fokus, dan fokus kembali setelah dialog pilihan
  atau ubah jumlah ditutup. Di tablet/ponsel Android/iOS fokus otomatis
  sengaja tidak dipakai agar keyboard layar tidak menutupi kasir dan keypad.
- Tombol kembali sistem Android di tahap bayar bisa menutup aplikasi dan
  menghilangkan keranjang; kini kembali ke pesanan, dan di layar berhasil
  sama dengan *Transaksi baru*.
- Setelah bayar lalu ←, kolom cari kosong tetapi grid masih tersaring kata
  lama; kolom kini menampilkan kata cari yang sedang dipakai.
- Struk menentukan nama satuan dari isi satuan, sehingga satuan konversi
  berisi 1 tampil tanpa nama; kini dari ada/tidaknya satuan konversi.
- Galat izin saat menyimpan penjualan kini punya pesan sendiri, dan galat
  data toko yang tidak lengkap tidak lagi membuat layar kasir menunggu
  tanpa akhir.
- Lainnya:
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
  view model, dan 8 alur widget (desktop lebar tablet, desktop, kartu +
  galat, ponsel, tablet Android tanpa fokus otomatis, kata cari setelah
  kembali, tombol kembali sistem, tanpa sesi).
- Pencarian satuan ukur di `checkoutSale` kini juga dibatasi `tenant_id`.

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

[Unreleased]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.19.0...HEAD
[0.19.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.18.0...v0.19.0
[0.18.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.17.0...v0.18.0
[0.17.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.16.0...v0.17.0
[0.16.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.15.0...v0.16.0
[0.15.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.14.0...v0.15.0
[0.14.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.13.0...v0.14.0
[0.13.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.12.0...v0.13.0
[0.12.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.11.0...v0.12.0
[0.11.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.10.0...v0.11.0
[0.10.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.9.0...v0.10.0
[0.9.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.8.0...v0.9.0
[0.8.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/yusufabdillahputra/yap-lakuna/releases/tag/v0.1.0
