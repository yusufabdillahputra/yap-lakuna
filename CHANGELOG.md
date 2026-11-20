# Changelog

Semua perubahan penting Lakuna dicatat di sini. Format mengikuti
[Keep a Changelog](https://keepachangelog.com/id-ID/1.1.0/) dan versi
mengikuti [Semantic Versioning](https://semver.org/lang/id/). Selama versi
`0.x`, setiap rilis ditandai pre-release.

## [Unreleased]

## [0.119.0] - 2026-11-20

*Buang perubahan?* tidak lagi muncul dua kali untuk form yang baru saja
dibuang.

### Diperbaiki

- **Pembelian, rincian pembelian, produk, pengeluaran, stok:** setelah
  **Buang** lewat **Batal**/Kembali, menekan **Ganti kasir** atau tombol ✕
  jendela selagi halaman itu masih ditutup kini langsung lanjut.
  Sebelumnya form yang sudah dibuang ditanyakan sekali lagi.
- **Ganti kasir → Buang lalu ✕ jendela:** aplikasi langsung tertutup.
  Sebelumnya dialog *Buang perubahan?* kedua muncul dan bisa tertinggal di
  atas layar masuk, karena form di dalam bingkai menu yang sedang ditutup
  masih dianggap aktif.

### Catatan teknis

- `isRouteClosing(context)` (`lib/ui/core/leave_guard.dart`) menelusuri
  rute halaman dan rute leluhurnya (`route.navigator.context`); halaman
  dilewati bila salah satunya `!isActive` (sedang di-pop, atau halaman
  go_router yang sudah dihapus dari daftar halaman tetapi widget-nya belum
  dibuang). Lima `_confirmLeave` berpenjaga memakainya sebelum cek lain.
- Tes: `leave_guard_test.dart` (aktif, tertutup halaman lain, di-pop) dan
  alur produk desktop (Ganti kasir selagi form ditutup; tutup jendela
  selagi bingkai ditutup); mutasi diverifikasi. Uji manual Linux di Xvfb.
- Spec [F1-02e](docs/superpowers/specs/2026-11-20-f1-02e-halaman-ditutup-tidak-ditanya-lagi-design.md);
  gap F1-02b *Halaman yang sedang ditutup ditanya lagi* ditutup.

## [0.118.0] - 2026-11-20

Rincian nota di Riwayat kini menampilkan modifier pesanan F&B.

### Ditambahkan

- **Riwayat (1.14) › rincian nota:** baris barang bermodifier menampilkan
  modifiernya di bawah nama, mis. *+ Besar, Boba*. Sebelumnya nota yang
  ditemukan lewat nama modifier (v0.103.0) tidak menunjukkan modifier
  apa pun, dan dua baris *Teh Botol* dengan modifier berbeda tampak sama
  saat meretur. Tambahan harga modifier sudah termasuk di harga satuan;
  struk cetak tetap merincinya.

### Catatan teknis

- `history_detail.dart` membaca `detail.receipt.modifiersOf(item)` yang
  sudah dimuat `loadSaleDetail`; porsi split bill memakai modifier
  salinannya sendiri. Tanpa perubahan data atau l10n.
- Tes: `history_flow_test.dart` (modifier dan catatan di baris barangnya
  saja, 360 px dengan modifier panjang); repositori palsu menerima
  `modifiers`; mutasi diverifikasi. Uji manual Linux di Xvfb.
- Spec [F1-11h](docs/superpowers/specs/2026-11-20-f1-11h-modifier-di-rincian-nota-design.md);
  gap F1-11g *Modifier di rincian nota Riwayat* ditutup.

## [0.117.0] - 2026-11-20

Pesanan F&B kini bisa dicari di Riwayat lewat catatannya, mis. *tanpa es*.

### Ditambahkan

- **Riwayat (1.14) › Cari:** kata kunci kini juga dicocokkan dengan
  catatan barang pesanan F&B (*tanpa es*, *bungkus terpisah*), selain
  nomor nota, pelanggan, referensi, nama produk/varian, dan modifier.
  Beberapa kata boleh tersebar di nama barang, modifier, dan catatan
  barang yang sama (`kopi sedikit` untuk *Kopi* bercatatan *gula
  sedikit*), tetapi tidak di barang lain di nota yang sama.
- **Rincian nota di Riwayat:** catatan barang tampil di bawah jumlah ×
  harga (*Catatan: tanpa es*), sehingga terlihat mengapa nota cocok.
  Sebelumnya catatan hanya tercetak di tiket dapur.

### Catatan teknis

- `_searchSales` (`lakuna_data/lib/src/history.dart`): klausa per kata di
  subkueri `sale_items` ditambah `LOWER("note") LIKE LOWER(%kata%)`; cek
  ulang Dart `itemMatches` ikut membaca `SaleItem.note` sebelum modifier
  dimuat, jadi `%` dan `_` tetap literal.
- Kunci l10n baru `historyItemNote` (ID + EN).
- Tes: `history_test.dart` (catatan, huruf besar, kata tersebar, barang
  lain, wildcard, barang dihapus dari bill), `history_flow_test.dart`
  (cari lalu rincian); mutasi diverifikasi. Uji manual Linux di Xvfb.
- Spec [F1-11g](docs/superpowers/specs/2026-11-20-f1-11g-cari-catatan-barang-design.md);
  gap F1-11f *Cari catatan item* ditutup.

## [0.116.0] - 2026-11-20

Menutup jendela aplikasi kini juga bertanya bila dialog pelanggan,
supplier, data master, atau meja sedang diisi.

### Diperbaiki

- **Dialog pelanggan, supplier, grup pelanggan, modifier, jenis
  pengeluaran, area/meja/rentang meja (desktop):** tombol ✕ jendela,
  Alt+F4, atau Cmd+Q saat dialog berisi isian yang belum disimpan kini
  menampilkan *Buang perubahan?* dengan pesan dialog itu. Sebelumnya
  v0.115.0 hanya menanyakan halaman (pembelian, produk, pengeluaran, stok),
  sehingga isian dialog hilang tanpa peringatan. Dialog ditanya lebih dulu
  (teratas dulu), lalu halaman di bawahnya. **Batal** di pertanyaan mana
  pun membiarkan aplikasi terbuka dengan dialog dan isiannya utuh.
- Bila pertanyaan *Buang perubahan?* dialog sudah terbuka (dari Esc,
  Batal, atau ketukan di luar), ✕ jendela memakai pertanyaan itu, tidak
  membuka yang kedua.
- Selama dialog menyimpan, ✕ jendela diabaikan agar pertanyaan tidak
  tertutup oleh hasil simpan; tekan ✕ lagi setelah simpan selesai.

### Catatan teknis

- `DiscardChangesScope` (`lib/ui/core/confirm_discard.dart`) kini
  `StatefulWidget` yang mendaftar ke daftar statis dialog terbuka (dialog
  memakai navigator akar, di luar pohon `ExitGuard`).
  `DiscardChangesScope.canDiscardAll()` menanyai dialog berubah dari yang
  teratas, melewati dialog yang beranimasi keluar, dan menolak bila ada
  yang sibuk. Pertanyaan disimpan sebagai `Future<bool>` bersama untuk
  `PopScope` dan penutupan aplikasi.
- `router.dart`: `ExitGuard.canExit` = `canDiscardAll()` lalu
  `LeaveGuards.canLeaveAll()`.
- Tes: `confirm_discard_test.dart` (8 tes: tanpa perubahan, Batal/Buang,
  bertumpuk, dialog atas bersih, sibuk, pertanyaan Esc dipakai ulang,
  dialog yang sedang ditutup, dialog dilepas) dan alur pelanggan desktop
  dengan `handleRequestAppExit`; mutasi diverifikasi. Uji manual Linux
  dengan `WM_DELETE_WINDOW` di Xvfb.
- Spec [F1-02d](docs/superpowers/specs/2026-11-15-f1-02d-tutup-jendela-dialog-isian-design.md);
  gap F1-02c *Dialog berisi isian saat jendela ditutup* ditutup.
- Tes `local_customers_repository_test.dart` (*pembayaran piutang dan
  kuitansi*) gagal sejak 2026-11-18: `checkoutSale` memakai jam dinding,
  sedangkan jatuh tempo kredit di tes tetap 17-11-2026 sehingga ditolak
  `SaleCreditInvalid(dueOn)`. Jatuh tempo kini 14 hari dari hari tes
  dijalankan.

## [0.115.0] - 2026-11-15

Menutup jendela aplikasi di komputer kini bertanya dulu bila ada form yang
belum disimpan, sama seperti pindah menu dan **Ganti kasir**.

### Diperbaiki

- **Semua layar desktop (Windows, Linux, macOS):** tombol ✕ jendela,
  Alt+F4, atau Cmd+Q saat form pembelian, produk, pengeluaran, atau draf
  penyesuaian stok berubah kini menampilkan *Buang perubahan?*.
  Sebelumnya aplikasi langsung tertutup dan isian hilang tanpa
  peringatan. **Batal** membiarkan aplikasi terbuka dengan isian utuh;
  **Buang** menutup aplikasi. Form tanpa perubahan atau layar masuk tetap
  langsung tertutup. Menekan ✕ lagi selama dialog terbuka diabaikan.
- **macOS:** tombol ✕ kini bertanya selagi jendela masih tampil. Tanpa
  perubahan ini jendela tertutup lebih dulu, sehingga dialog akan muncul
  di jendela yang sudah hilang, dan klik kedua langsung menutup aplikasi.

### Catatan teknis

- `ExitGuard` (`lib/ui/core/exit_guard.dart`) memasang
  `AppLifecycleListener(onExitRequested:)` di bingkai `AppShell` dan
  memakai `LeaveGuards.canLeaveAll` (F1-02b). Permintaan selagi
  pemeriksaan berjalan ditolak.
- Linux (`delete-event`) dan Windows (`WM_CLOSE` lewat
  `HandleTopLevelWindowProc`) diteruskan embedder Flutter ke
  `System.requestAppExit` tanpa perubahan runner.
- macOS: `MainFlutterWindow.performClose` bertanya lewat kanal
  `lakuna/window` (`requestClose` → `bool`) sebelum `NSApp.terminate`;
  izinnya dipakai sekali oleh `onExitRequested` berikutnya.
- Tes: `exit_guard_test.dart` (izin, tolak, permintaan ganda, kanal
  macOS, dilepas), alur pembelian desktop; mutasi diverifikasi. Uji
  manual Linux dengan `WM_DELETE_WINDOW` di Xvfb.
- Gap tersisa: Cmd+Q kedua selama dialog di macOS, Windows dengan jendela
  kedua, dialog isian (pelanggan, supplier, master data, meja).
- Spec [F1-02c](docs/superpowers/specs/2026-11-15-f1-02c-tutup-jendela-tanya-dulu-design.md);
  gap F1-02b *Tutup aplikasi (jendela desktop) bertanya* ditutup.

## [0.114.0] - 2026-11-15

**Buat pembelian** dari Stok minimum tidak lagi memilih supplier yang
barangnya sudah Anda retur semua.

### Diperbaiki

- **Stok › Stok minimum › Buat pembelian (1.18 → 1.19):** supplier yang
  dipilih otomatis (F1-08d) kini mengabaikan baris pembelian yang seluruh
  jumlahnya sudah diretur ke supplier lewat **Retur pembelian** (`RB-`),
  mis. karena rusak atau salah kirim. Sebelumnya supplier itu tetap
  dianggap pemasok terakhir sehingga staf harus menggantinya sendiri;
  kini dipakai supplier pembelian sebelumnya, atau supplier dibiarkan
  kosong bila tidak ada riwayat lain. Retur sebagian tidak mengubah
  pilihan. Bila barang yang sama ada di dua baris pembelian (mis. dus dan
  botol), pembelian tetap dihitung selama salah satu barisnya belum
  diretur penuh.

### Catatan teknis

- `lastSuppliersOf` membaca retur lewat `purchaseReturnsOf` (per 500
  pembelian, berindeks `purchase_returns_purchase_idx`) dan
  `_returnedMilliOf`, lalu melewati baris dengan jumlah retur ≥ jumlah
  baris (satuan baris).
- Harga beli terakhir (F1-08e/F1-12g/F1-12h) sengaja tidak berubah:
  harga pada pembelian yang diretur tetap harga yang ditawarkan supplier.
- Tes data: retur sebagian lalu penuh, satu-satunya pembelian diretur
  penuh, dua baris barang yang sama; diverifikasi mutasi.
- Spec [F1-08m](docs/superpowers/specs/2026-11-15-f1-08m-supplier-terakhir-tanpa-retur-design.md);
  gap F1-08d *Abaikan pembelian yang seluruh barangnya diretur* ditutup.

## [0.113.0] - 2026-11-15

Nomor HP yang ditulis dengan garis miring, mis. `021/5551234` atau
`0812/3456/7890`, kini ditemukan di semua kolom cari.

### Diperbaiki

- **Cari nomor HP (1.14 Riwayat, 1.20 Pelanggan, 1.21 Supplier, 1.4b
  pilih pelanggan Kasir, 1.5b *Kredit*, bill Meja):** garis miring `/`
  diterima sebagai pemisah, sama seperti spasi dan `+ - ( ) .`.
  Sebelumnya `0813/2222` dianggap teks biasa sehingga pelanggan dengan HP
  `081322221010` tidak ditemukan. Garis miring Unicode yang bisa tersalin
  dari aplikasi lain (U+2215, U+FF0F) dianggap `/`. Aturan lain tidak
  berubah: minimal 3 angka, `+62` menjadi `0`, kata berhuruf tidak
  dicocokkan ke HP.
- **Pelanggan baru dari kolom cari (Kasir, *Kredit*, Meja):** kata
  pencarian berupa nomor dengan garis miring, garis miring / tanda hubung
  Unicode, atau salinan WhatsApp bertanda arah tak terlihat kini mengisi
  kolom **HP**, bukan **Nama**. Sebelumnya mengetik `021/5551234` lalu
  **Pelanggan baru** menyimpan nomor itu sebagai nama pelanggan.

### Catatan teknis

- `lakuna_domain` `phoneSearchKeys`: pola kata kunci HP
  `^[\d\s+\-()./]+$`; U+2215 / U+FF0F diganti `/` sebelum dicek.
- `customerDraftFromQuery` memakai `phoneSearchKeys(q).isNotEmpty` +
  minimal 6 digit, menggantikan pola sendiri.
- Tanggal yang diketik di kolom cari (`15/11`) kini juga menjadi kunci HP
  `1511`; kunci HP hanya menambah hasil, tidak menyembunyikan yang lain.
- Tes: domain (garis miring, Unicode, cocok palsu `+62/813`), Riwayat
  `0812/3456/7890`, view model Pelanggan `0857/1111`, draf pelanggan baru.
- Spec [F1-13f](docs/superpowers/specs/2026-11-15-f1-13f-garis-miring-hp-design.md);
  gap F1-13d *Garis miring dan pemisah lain* ditutup.

## [0.112.0] - 2026-11-15

Barang di bawah stok minimum kini menyebut berapa yang sudah dipesan di
draf, jadi tidak perlu membuka draf satu per satu untuk tahu apakah sudah
cukup.

### Diubah

- **Stok › Stok minimum (1.18):** keterangan **Sudah di draf** kini
  menyebut jumlah yang sudah dipesan dibandingkan saran beli ulang, mis.
  *Sudah di draf PB-PST-D01-261103-0001: 5 dari saran 38 pcs*. Jumlah
  dipesan dihitung dalam satuan dasar dari semua draf pembelian ke lokasi
  itu (2 dus isi 6 = 12; dua baris barang yang sama dijumlah). Bila barang
  ada di beberapa draf: *Sudah di 2 draf, a.l. PB-…: 10 dari saran 38
  pcs*. Saran sama dengan jumlah yang diisi **Buat pembelian**
  (`2 × minimum − stok`, dibulatkan ke atas). Teks dibungkus utuh di
  ponsel 360 px.

### Catatan teknis

- `RestockDraft.quantities` (satuan dasar per draf) diisi
  `restockDraftsOf` dengan `Qty(quantityMilli).toBaseUnit(factorMilli)`,
  pembulatan yang sama dengan saat barang diterima.
- `StockViewModel.draftMarkOf` (`DraftMark`: nomor draf pertama, banyaknya
  draf, jumlah dipesan) menggantikan `draftNumberOf`;
  `StockViewModel.suggestedOf` dipakai bersama oleh *Buat pembelian* dan
  keterangan.
- l10n: `stockMinimumInDraftQty`, `stockMinimumInDraftsQty`
  menggantikan `stockMinimumInDraft`.
- Tes: data (dus × isi, dua baris sama), VM (jumlah dari semua draf),
  widget 1280 / 360 px satu dan dua draf; diverifikasi mutasi. Uji manual
  Xvfb.

## [0.111.0] - 2026-11-15

Pesan "Nama sudah dipakai." kini tampil tepat di bawah kolom yang perlu
diubah, bukan di kotak merah di bawah dialog.

### Diubah

- **Master data › Meja & area (1.17):** galat simpan dialog area dan meja
  tampil di bawah isiannya: nama kembar / terlalu panjang di bawah
  **Nama**, kursi di luar batas di bawah **Kursi**. Di dialog *Rentang
  meja*, nama yang bentrok (mis. "Nama M7 sudah dipakai.") menggantikan
  baris pratinjau nama dengan warna merah, dan galat kursi tampil di bawah
  **Kursi**. Galat lain (mis. *Aksi gagal. Coba lagi.*) tetap di kotak
  merah di atas tombol. Pesan hilang begitu isian diubah.

### Diperbaiki

- Dialog area: pesan *Nama wajib diisi.* dari simpan sebelumnya tidak lagi
  tertinggal setelah nama diisi; galat diperiksa ulang setiap **Simpan**.

### Catatan teknis

- Mixin `_DialogSaving` menyimpan `saveFailure` (galat asli) di samping
  `saveError`; `errorIf(test)` memetakan galat ke isian dan
  `fieldError(local, saved)` menggabungkan galat isian dengan galat simpan.
  Hanya galat yang tidak terpetakan masuk `_frame(error:)`.
- Tes: pesan nama di bawah Nama (tambah dan ubah nama area, meja), kursi
  dari penyimpanan di bawah Kursi (meja, rentang), rentang kembar di
  pratinjau, galat lain di kotak merah, kosong lalu kembar; diverifikasi
  mutasi. Uji manual Xvfb.

## [0.110.0] - 2026-11-15

Sedang mengisi pembelian belasan baris lalu tak sengaja menekan *Ganti
kasir*? Kini aplikasi bertanya dulu sebelum isian hilang.

### Diperbaiki

- **Ganti kasir (1.2):** menekan **Ganti kasir** saat form pembelian
  (1.20), produk (1.15), pengeluaran (1.22), atau draf penyesuaian stok
  (1.18) berisi perubahan yang belum disimpan kini menampilkan **Buang
  perubahan?** dengan teks halaman itu, sama seperti pindah menu.
  **Batal** tetap di form dengan isian utuh dan staf tetap bertugas;
  **Buang** membuka layar masuk. Form tanpa perubahan langsung berganti
  seperti sebelumnya. Sebelumnya isian langsung hilang tanpa peringatan.
- Selama simpan / terima barang berjalan, *Ganti kasir* diabaikan sampai
  selesai (sama dengan menu samping).

### Catatan teknis

- `LeaveGuards.canLeaveAll()` menanyakan semua guard yang terpasang, mulai
  dari halaman teratas, dan berhenti pada jawaban `false`; pertanyaan yang
  sedang tampil dipakai ulang lewat `LeaveGuard.canLeave`.
- `AppShell.canSwitch` (diisi `leaveGuards.canLeaveAll` di router)
  dipanggil sebelum `session.logout()`. Setelah *Buang*, `onExit` semua
  halaman lewat tanpa bertanya karena staf bertugas sudah kosong.
- Keluar paksa (staf dihapus dari perangkat lain) tidak ditanyakan.
- Tes: unit `canLeaveAll` (urutan, berhenti pada Batal, guard dilepas
  dilewati, dialog dipakai ulang), widget pembelian desktop & ponsel dan
  pengeluaran desktop, produk desktop. Uji manual Xvfb: Pengeluaran berisi → Ganti kasir →
  Batal (isian utuh) → Buang (layar masuk).

## [0.109.0] - 2026-11-15

Membuat M1–M30 lalu ternyata M7 sudah ada? Dialog *Rentang meja* kini tetap
terbuka dengan isian utuh, jadi cukup ubah nomornya lalu simpan lagi.

### Diperbaiki

- **Master data › Meja & area (1.17):** simpan area, meja, atau rentang
  meja yang ditolak (nama kembar, nama terlalu panjang, salah satu nama
  rentang sudah dipakai) tidak lagi menutup dialog dan membuang isian.
  Pesan galat tampil di dialog (mis. "Nama M7 sudah dipakai.") dan hilang
  begitu isian diubah. Sebelumnya dialog tertutup dulu dan galat tampil di
  tab, sehingga isian harus diketik ulang.
- Selama simpan berjalan, tombol **Simpan** nonaktif dan dialog tidak bisa
  ditutup lewat ketukan di luar, Esc, Batal, atau tombol kembali.

### Diubah

- Peringatan merah di tab Meja & area kini hanya untuk galat hapus dan
  urut; galat simpan tampil di dialog.

### Catatan teknis

- Dialog menerima `onSave` (`Future<Exception?>`: `null` = berhasil) dan
  berbagi mixin `_DialogSaving` (`saving`, `saveError`, `edit`,
  `runSave`); `DiscardChangesScope(busy: saving)`. Dialog sendiri
  mengubah galat menjadi pesan (`diningSetupErrorMessage` dengan nama
  rentang dan batas nama area), karena tab bisa dibangun ulang saat lebar
  jendela melewati 900 px. Galat dialog: `FAlert`
  `dining-setup-dialog-error`.
- Galat yang bukan `Exception` (mis. `StateError`) ditangkap menjadi *Aksi
  gagal. Coba lagi.* agar dialog tidak terkunci; pesan galat hanya hilang
  bila teks isian benar-benar berubah (bukan saat kursor digeser).
- Tab menjalankan perintah VM lewat `_saveFromDialog` lalu `clearError()`
  agar peringatan tab tidak ikut tampil. Kolom `_lastNames` / `_nameMax`
  di tab dihapus.
- Repo palsu `FakeDiningAdminRepository` mendapat `gate` (`Completer`),
  `calls`, dan `throwNext` untuk menguji simpan yang berjalan, satu
  panggilan simpan, dan galat tak terduga. Diverifikasi mutasi (tanpa
  `clearError`, selalu menutup, `busy` mati, galat tidak hilang saat
  mengetik, pesan dari `context` tab, hanya menangkap `Exception`).

## [0.108.0] - 2026-11-15

*Rentang meja* bisa membuat puluhan meja sekaligus dengan awalan, nomor,
kursi, dan area yang sudah diatur. Dialognya kini tidak lagi hilang karena
ketukan yang tidak sengaja.

### Ditambahkan

- **Master data › Meja & area (1.17):** dialog **Area**, **Meja**, dan
  **Rentang meja** yang isiannya berubah menampilkan **Buang perubahan?**
  sebelum ditutup lewat ketukan di luar dialog, Esc, tombol kembali sistem,
  atau **Batal**. *Batal* kembali ke dialog; *Buang* menutup tanpa
  menyimpan. Dialog yang tidak berubah (termasuk rentang dengan nilai bawaan
  M, 1–12, 4 kursi, nama dengan spasi tepi saja, atau angka seperti "04"
  untuk 4) tertutup langsung.
- Ketiga dialog dan konfirmasi hapus area/meja tampil di navigator akar
  sehingga menutupi menu samping.
- Panduan *Meja & open bill* menjelaskan pertanyaan ini (ID + EN).

### Diubah

- Konfirmasi hapus area/meja: ketukan di luar dan Esc tetap berarti batal,
  kini lewat `maybePop`.

### Catatan teknis

- `_showDialog` di `dining_tables_tab.dart` memakai `useRootNavigator`,
  `barrierDismissible: false`, dan `TapOutsideToPop`; setiap dialog
  membungkus isinya dengan `DiscardChangesScope` dan menyimpan tanda tangan
  awal (`late final`): area = nama; meja = record nama, area, kursi,
  *Boleh digabung*; rentang = record awalan, dari, sampai, kursi, area.
  Isian memanggil `setState` saat berubah. Tombol Batal memanggil
  `maybePop` dengan kunci eksplisit (`dining-setup-area-cancel`,
  `-table-cancel`, `-range-cancel`).
- l10n baru: `diningAreaDiscardBody`, `diningTableDiscardBody`,
  `diningRangeDiscardBody`.
- Tes widget per isian meja dan rentang, tombol kembali sistem, dan
  konfirmasi hapus; diverifikasi mutasi (tanpa `dirty`, navigator cabang,
  Batal `pop`, nama tanpa `trim`, kursi sebagai teks, area tidak dihitung).

## [0.107.0] - 2026-11-15

Grup modifier bisa berisi belasan opsi dengan harga masing-masing. Dialognya
kini tidak lagi hilang karena ketukan yang tidak sengaja.

### Ditambahkan

- **Master data (1.17):** dialog **Grup modifier**, **Grup pelanggan**, dan
  **Jenis pengeluaran** yang isiannya berubah menampilkan **Buang
  perubahan?** sebelum ditutup lewat ketukan di luar dialog, Esc, tombol
  kembali sistem, atau **Batal**. *Batal* kembali ke dialog; *Buang*
  menutup tanpa menyimpan. Dialog yang tidak berubah (termasuk grup baru
  dengan satu opsi kosong, nama yang hanya berisi spasi, atau isian yang
  dikembalikan) tertutup langsung.
- Ketiga dialog tampil di navigator akar sehingga menutupi menu samping;
  selama *Simpan* berjalan dialog tidak bisa ditutup.
- Panduan *Modifier*, *Pengeluaran*, dan *Pelanggan & piutang* menjelaskan
  pertanyaan ini (ID + EN).

### Diperbaiki

- Dialog grup modifier kini dibangun ulang saat nama, minimal, maksimal,
  atau nama/harga opsi diketik (sebelumnya nilainya disimpan tanpa
  `setState`), sehingga keadaan "berubah" selalu terbaru.
- Esc kini bekerja di dialog yang memakai pertanyaan *Buang perubahan?*
  (termasuk dialog **Pelanggan** dan **Supplier** dari v0.100.0) walau tidak
  ada isian berfokus: setelah sakelar/kotak centang diklik, setelah isian
  dilepas fokusnya, atau setelah memilih *Batal* di pertanyaan. Sebelumnya
  Esc diam saja dalam keadaan itu karena fokus jatuh ke lingkup rute dialog,
  di atas aksi Esc yang dipasang ulang (ditemukan saat uji manual).
- Minimal/maksimal grup modifier dibandingkan sebagai angka, jadi mengetik
  "02" untuk maksimal 2 tidak dianggap perubahan.

### Catatan teknis

- Memakai ulang `TapOutsideToPop` dan `DiscardChangesScope` dari F1-13e;
  tanda tangan isian dihitung di `State` dialog (grup modifier:
  `listEquals` atas nama, wajib, min, maks, dan setiap opsi; grup
  pelanggan: record nama + tempo; jenis pengeluaran: nama). Tombol Batal
  memanggil `maybePop` dan diberi kunci `modifier-cancel`,
  `customer-group-cancel`, `expense-category-cancel`.
- l10n baru: `modifierDiscardBody`, `customerGroupDiscardBody`,
  `expenseCategoryDiscardBody`.
- `TapOutsideToPop` memasang `FocusScope(autofocus: true)` di bawah
  `Actions` Esc, sehingga fokus utama selalu berada di bawah aksi Esc
  (bukan pendengar `FocusManager` global, yang di desktop akan membuang
  fokus isian saat jendela berpindah).
- Tes widget baru per dialog, termasuk tabel per isian grup modifier, simpan
  gagal lalu Esc, dan Esc tanpa isian berfokus; diverifikasi mutasi (tanpa
  `dirty`, opsi tanpa nama/tersedia di tanda tangan, navigator cabang, Batal
  `pop`, nama tanpa `trim`, min/maks sebagai teks, tanpa lingkup fokus).

## [0.106.0] - 2026-11-15

Grosir biasanya dibeli per dus atau per pak. Form pembelian kini mengisi
harga dus dari harga dus yang dibayar terakhir.

### Ditambahkan

- **Pembelian (1.19):** baris dalam satuan konversi (mis. scan barcode
  dus) memakai harga per satuan itu pada pembelian diterima terakhir
  **dalam satuan yang sama**, apa adanya. Bila supplier dipilih, harga
  dari supplier itu didahulukan, lalu dari supplier mana pun, lalu HPP
  satuan (atau HPP dasar × isi). Harga botol tidak dikalikan isi, karena
  harga per dus biasanya berbeda.
- Mengganti satuan baris (botol ↔ dus) mengisi harga terakhir satuan
  baru tanpa membaca riwayat ulang; mengganti supplier menyegarkan baris
  dus juga. Harga yang diketik staf tetap tidak ditimpa.
- Panduan *Pembelian* menjelaskan harga satuan konversi (ID + EN).

### Diubah

- Baris satuan konversi kini ikut membaca riwayat harga (sebelumnya hanya
  satuan dasar); *Simpan draf* / *Terima* menunggu pengisiannya seperti
  satuan dasar.

### Catatan teknis

- `lastPurchasePriceSetOf(store, scope, ids, {supplierId})` →
  `(perBase, perUnit)` dari satu bacaan riwayat (penyaring cabang,
  status diterima, supplier, bonus Rp 0, urutan terbaru);
  `lastPurchasePricesOf` dan `lastPurchaseUnitPricesOf` memakainya.
  Harga dus hanya dipakai bila isi satuan di baris pembelian sama dengan
  isi satuan sekarang: dus isi 6 yang diubah menjadi isi 12 tidak memakai
  harga dus isi 6 lagi (ditemukan saat review).
- Repositori `lastPurchasePrices` kini mengembalikan
  `Map<UuidValue, LastPurchasePrice>` (`perBase`, `perUnit` tak bisa
  diubah) dalam satu panggilan; tembolok VM menyimpan
  `LastPurchasePrice?`, `_lastPriceFor(variant, unit, supplier)` memilih
  harga sesuai satuan. Syarat `unit.isBase` dihapus dari pengisian
  barang baru, ganti satuan, penyegaran supplier, dan stok minimum;
  `_fillLastPrice` memakai satuan baris saat harga tiba.
- Tes data, VM (8 baru), dan widget baru; diverifikasi mutasi (tanpa
  pengisian untuk satuan konversi saat scan / ganti satuan, harga dasar
  untuk semua satuan, penyegaran dan stok minimum hanya satuan dasar,
  `_fillLastPrice` dengan satuan dasar, tanpa cek isi satuan, tanpa
  penyaring status diterima).

## [0.105.0] - 2026-11-15

Barang yang sama sering dibeli dari beberapa supplier dengan harga
berbeda. Form pembelian kini mengisi harga dari supplier yang dipilih.

### Ditambahkan

- **Pembelian (1.19):** harga beli baris satuan dasar diambil dari
  pembelian diterima terakhir **dari supplier yang dipilih** di form.
  Barang yang belum pernah dibeli dari supplier itu memakai harga
  pembelian terakhir dari supplier mana pun, lalu harga modal.
- Mengganti supplier (memilih supplier lain, mengosongkan, atau mengetik
  supplier baru) menyegarkan harga semua baris yang harganya belum
  diketik staf.
- Panduan *Pembelian* menjelaskan asal harga per supplier (ID + EN).

### Diubah

- Form dari *Stok minimum* memilih supplier terakhir lebih dulu, lalu
  mengisi harga dari supplier itu (sebelumnya harga diisi sebelum
  supplier dipilih). *Buka draf* memakai supplier draf untuk barang yang
  ditambahkan.
- "Harga belum diubah staf" kini dicatat per baris (`autoPrice`), bukan
  ditebak dari harga yang sama dengan harga modal. Baris draf tersimpan
  dianggap sudah ditetapkan, jadi mengganti supplier draf tidak mengubah
  harganya.

### Catatan teknis

- `lastPurchasePricesOf(..., {supplierId})` menyaring
  `purchases.supplier_id`; repositori `lastPurchasePrices(ids,
  {supplierId})`.
- `PurchaseFormViewModel`: tembolok harga per supplier di samping
  tembolok semua supplier (`_ensureLastPrices`, `_lastPriceFor`),
  penyegaran `_refreshAutoPrices` dengan revisi `_priceRev` (hasil
  supplier lama dibuang) dan ditunggu simpan/terima lewat
  `_pendingFills`.
- Hasil harga yang datang terlambat dibuang bila supplier sudah
  berganti: penyegaran lama (`_priceRev`, naik juga saat form dikosongkan
  atau draf dimuat), harga barang baru (`_fillLastPrice`), dan harga
  baris stok minimum (`_applyRestockPrices`).
- `setUnitPrice` mengabaikan harga yang sama. Isian harga Forui memanggil
  `onChange` saat difokus atau seleksinya berubah; tanpa ini, baris yang
  hanya diketuk dianggap diketik staf dan tidak lagi ikut ganti supplier
  (ditemukan saat review).
- Tes data, VM, dan widget baru. Setiap penjaga diverifikasi mutasi:
  tanpa saringan supplier, tanpa penyegaran, urutan restock lama, tanpa
  revisi penyegaran, tanpa penjaga supplier di harga barang baru dan
  stok minimum, serta `setUnitPrice` tanpa cek harga sama.

## [0.104.0] - 2026-11-15

Stock opname puluhan produk tidak lagi hilang karena salah ketuk menu
atau lokasi.

### Ditambahkan

- **Stok › Penyesuaian (1.18):** bila draf penyesuaian sudah berisi
  produk (fisiknya terisi atau belum) atau catatan, meninggalkan layar
  Stok lewat menu samping / bawah atau tombol kembali sistem menampilkan
  **Buang perubahan?** ("Draf penyesuaian stok yang sedang diisi belum
  disimpan dan akan hilang.") dengan **Batal** dan **Buang**. Berlaku di
  tab mana pun.
- Mengganti **lokasi** di kepala layar Stok saat draf berisi juga
  bertanya dulu ("Draf penyesuaian untuk lokasi ini akan dikosongkan bila
  lokasi diganti."). **Batal** mempertahankan lokasi dan draf.
- Panduan *Penyesuaian & stok minimum* menjelaskan peringatan ini (ID +
  EN).

### Diubah

- Selama *Simpan penyesuaian* berjalan, keluar dari layar Stok ditahan
  sampai selesai. Setelah simpan atau *Batal*, layar ditinggalkan tanpa
  bertanya. *Alasan umum* saja tidak dihitung sebagai isian.

### Diperbaiki

- Form pembelian yang dibuka dari *Stok minimum* (**Buka draf** / **Buat
  pembelian**) bisa kehilangan penjaga keluarnya bila halaman Stok di
  bawahnya ikut dibangun ulang dalam frame yang sama: `LeaveGuards.of`
  membuang semua guard lain yang belum memasang `check`, termasuk guard
  form yang baru dibuat. Ditemukan saat halaman Stok diberi penjaga
  keluar; tes *Buka draf* F1-08g gagal karena *Kembali* tidak lagi
  bertanya.

### Catatan teknis

- `StockViewModel.hasUnsavedChanges` (baris atau catatan, hanya dengan
  izin `stock:adjust`) dan `busy`; `StockScreen` memasang
  `LeaveGuard.check` lewat `confirmDiscardChanges` (kunci
  `stock-discard`), rute `/stok` memakai `onExit: formExit`.
- `_LocationSelect` menjadi stateful: konfirmasi `stock-location-discard`,
  batal menaikkan revisi kunci `FSelect` agar kembali ke lokasi semula.
- `LeaveGuard` mencatat apakah `check` pernah dipasang; `LeaveGuards.of`
  hanya membuang guard yang sudah dipasang lalu dilepas. Tes unit baru
  `test/ui/core/leave_guard_test.dart`. Guard lama yang sudah dilepas
  dengan `pageKey` sama diganti baru, agar Stok yang dibuka lagi tidak
  kehilangan guard-nya dengan cara yang sama.
- Tes widget F1-08k (1280 px dan 360 px, termasuk draf yang tetap ada
  setelah membuka form pembelian dari *Stok minimum*) dan tes VM;
  diverifikasi mutasi (tanpa `onExit`, tanpa konfirmasi lokasi, tanpa
  penahan simpan, dan pembersihan guard lama).
- Temuan review subagent (semua Minor): guard lama dengan `pageKey` sama,
  cek `mounted` setelah dialog lokasi, tes aturan 5, dan baris gap dua
  dialog berturut-turut; diperbaiki.

## [0.103.0] - 2026-11-15

Pesanan F&B kini bisa dicari di Riwayat lewat modifier yang dipilih
tamu, seperti cara kasir mengingatnya: "kopi yang extra shot".

### Ditambahkan

- **Riwayat (1.14):** kolom **Cari** juga mencocokkan nama modifier
  barang (mis. *Extra Shot*, *Boba*). Setiap kata boleh ada di nama
  produk, nama varian, atau nama modifier **baris barang yang sama**,
  urutan bebas: `kopi extra shot` menemukan *Es Kopi Susu* + *Extra
  Shot*.
- Panduan *Retur & void* menyebut pencarian lewat modifier (ID + EN).

### Diubah

- Nama modifier dibaca dari salinan di nota, jadi mengubah nama opsi di
  master tidak mengubah hasil pencarian nota lama. Nama grup modifier
  (*Topping*, *Level*) tidak dicari. Kata yang tersebar di modifier satu
  barang dan nama barang lain di nota yang sama tidak dihitung cocok.

### Catatan teknis

- `_searchSales` (`lakuna_data/lib/src/history.dart`): klausa tiap kata
  di subkueri `sale_items` ditambah `"sale_items"."id" IN (SELECT
  "sale_item_id" FROM "sale_item_modifiers" … LOWER("name") LIKE …)`.
- Cek ulang Dart memakai `itemModifiers` (bersama open bill), hanya untuk
  baris barang di nota yang belum cocok lewat nama produk/varian.
- Temuan review subagent: tes barang bermodifier yang dihapus dari bill
  dan wildcard `_` ditambah (Important), helper dipakai ulang dan modifier
  dimuat lebih sedikit (Minor). Tes diverifikasi mutasi untuk klausa SQL
  dan cek ulang Dart.

## [0.102.0] - 2026-11-15

Tamu split bill kini bisa menerima tagihannya sendiri sebelum membayar,
bukan hanya mendengar nominalnya dibacakan dari layar.

### Ditambahkan

- **Split bill (1.9):** kartu tamu yang belum membayar di mode **Per
  item** dan **Bagi rata** punya tombol **Cetak tagihan**. Dialog
  *Tagihan tamu A · Meja M1* menampilkan pratinjau kertas dengan
  **Tutup**, **Bagikan PDF**, dan **Cetak tagihan** ke printer struk
  perangkat, sama seperti tagihan Meja (F1-10k).
- Isi tagihan tamu: banner **TAGIHAN TAMU A - BELUM DIBAYAR**, baris
  *Tamu: A dari 2*, lalu
  - **Per item:** porsi milik tamu (porsi dari baris yang sama digabung,
    modifier, diskon baris), *Subtotal*, *Bagian Diskon 10%, Service 5%,
    PB1 10%, Pembulatan* (hanya komponen yang ada; PB1 yang termasuk
    harga tidak disebut), dan **TAGIHAN TAMU A**;
  - **Bagi rata:** seluruh pesanan, rincian F&B, *TOTAL*, *Dibagi rata 2
    tamu*, dan **TAGIHAN TAMU A**;
  - rekening transfer dan footer struk.
- Nominal tagihan sama dengan kartu tamu, termasuk tamu terakhir yang
  menanggung sisa. Selisih tanpa komponen biaya berlabel *Penyesuaian
  bill*.
- Panduan *Split bill* menjelaskan tagihan per tamu (ID + EN).

### Diubah

- Di mode Per item tombol **Cetak tagihan** baru aktif setelah semua
  porsi punya tamu. Mode **Nominal bebas** tidak punya tagihan per tamu.
- Dialog tagihan menutup sendiri bila tagihannya tidak lagi berlaku (mis.
  tamu sudah membayar atau mode split diganti).

### Catatan teknis

- `guestBillReceiptContent` di `receipt_content.dart`; meta dan rincian
  F&B tagihan dipisah ke `_billMeta` / `_chargeLines` agar dipakai tagihan
  Meja dan tagihan tamu.
- `BillPrintJob` (`lib/ui/receipt/bill_print_job.dart`) menggantikan
  status cetak/PDF tagihan di `DiningViewModel` (API publik tetap) dan
  dipakai `SplitBillViewModel.partPrint`; generasi dialog mencegah hasil
  printer lambat tampil di dialog berikutnya, dan notifikasi setelah
  dispose diabaikan.
- `showBillPrintDialog` (`lib/ui/receipt/bill_print_dialog.dart`) dipakai
  bersama tagihan Meja (`dining-bill-*`) dan tagihan tamu
  (`split-bill-*`). Tutup otomatis memakai `pop` sinkron atau
  `removeRoute` agar tidak terjadi pop ganda yang ikut menutup layar di
  bawahnya.
- `SplitBillData` membawa nama usaha, cabang, kasir, zona waktu,
  pengaturan struk, dan printer perangkat.
- Temuan review subagent (semua Minor, diperbaiki): label cadangan
  *Bagian Pembulatan* yang menyesatkan, risiko pop ganda saat tutup
  otomatis, dan celah tes (sisa tamu terakhir, porsi turunan bermodifier,
  nama job lengkap, rute dialog benar-benar tertutup; diverifikasi mutasi).

## [0.101.0] - 2026-11-15

Pencarian nama barang di Riwayat kini memahami beberapa kata yang
tersebar di nama produk dan nama varian, seperti cara kasir menyebut
barang sehari-hari.

### Ditambahkan

- **Riwayat (1.14):** kolom **Cari** menemukan nota lewat beberapa kata
  nama barang dalam urutan bebas, mis. `beras 5 kg` untuk *Beras Premium*
  varian *5 kg*, atau `melati teh` untuk *Teh Celup · Melati*. Setiap kata
  harus ada di nama produk atau nama varian **satu baris barang** yang
  sama; kata yang tersebar di barang berbeda dalam satu nota tidak
  dihitung cocok.
- Panduan *Retur & void* menjelaskan contoh beberapa kata (ID + EN).

### Diubah

- Spasi ganda, tab, dan kata berulang di kata kunci diabaikan untuk
  pencarian nama barang. Nomor nota, nama/HP pelanggan, nama pemesan, dan
  referensi pembayaran tetap dicocokkan dengan kata kunci utuh.

### Catatan teknis

- `_searchSales` (`lakuna_data/lib/src/history.dart`): subkueri
  `sale_items` memakai `AND` per kata atas `(LOWER(product_name) LIKE …
  OR LOWER(variant_name) LIKE …)`, lalu dicek ulang di Dart
  (`words.every`) agar `%` dan `_` tetap literal.
- Kata dikirim ke SQL seperti diketik, bukan versi huruf kecil Dart,
  karena `LOWER` SQLite hanya melipat A–Z. Temuan review (Important):
  versi awal mengirim kata huruf kecil sehingga nama berhuruf besar
  non-ASCII (mis. `KOPI ÉSPRESSO` dicari `ÉSPRESSO`) hilang dari hasil;
  diperbaiki dan dites.
- Paling banyak 8 kata masuk SQL (`_maxSqlWords`); kata selebihnya hanya
  dicek di Dart, sehingga rantai `AND` tidak membengkak.
- Tes data baru: frasa terbalik dengan spasi ganda dan huruf besar, kata
  di barang berbeda, kata di nota berbeda, wildcard, nama pemesan tetap
  utuh, huruf besar non-ASCII, 12 kata berulang, dan lebih dari 8 kata;
  diverifikasi dengan mutasi (`every` → `any`, kata huruf kecil ke SQL).

## [0.100.0] - 2026-11-15

Dialog *Pelanggan* dan *Supplier* tidak lagi membuang isian karena salah
ketuk di luar dialog. Ini melengkapi rangkaian peringatan "Buang
perubahan?" untuk semua form isian panjang di Fase 1.

### Ditambahkan

- **Pelanggan (1.20) & Supplier (1.21):** menutup dialog *Pelanggan baru*
  / *Ubah pelanggan* atau *Supplier baru* / *Ubah supplier* yang isiannya
  berubah, lewat ketukan di luar dialog, Esc, tombol kembali sistem, atau
  tombol **Batal**, menampilkan **Buang perubahan?** ("Pelanggan / Supplier
  yang sedang diisi belum disimpan dan akan hilang.") dengan **Batal** dan
  **Buang**. Berlaku juga untuk *Pelanggan baru* dari Kasir dan panel
  *Kredit* (F1-04f); **Buang** hanya menutup form, pemilih pelanggan tetap
  terbuka.
- Panduan *Pelanggan & piutang* dan *Supplier & hutang* menjelaskan dialog
  ini (ID + EN).

### Diubah

- Dialog form pelanggan dan supplier kini menutupi menu samping / bawah:
  simpan atau tutup dialog dulu sebelum pindah menu.
- Isian awal dari kata pencarian Kasir bukan perubahan; nomor HP dibanding
  setelah dinormalisasi, jadi menulis ulang nomor yang sama dengan format
  lain tidak dihitung. Dialog yang tidak diubah tetap tertutup dengan satu
  ketukan.
- Selama simpan berjalan, dialog tidak bisa ditutup.

### Diperbaiki

- Membuka *Ubah pelanggan* untuk pelanggan yang punya grup memicu galat
  pada pilihan *Grup* (nilai awal di luar daftar) sebelum daftar grup
  selesai dimuat. Pilihan kini kosong sesaat lalu terisi setelah grup
  dimuat.

### Catatan teknis

- `CustomerFormViewModel` / `SupplierFormViewModel`: `hasUnsavedChanges`
  (daftar rata dibanding `listEquals` dengan salinan dari konstruktor;
  nama grup baru hanya selama *Grup baru* dipilih) dan `busy`.
- `DiscardChangesScope` (`PopScope`, `canPop: !dirty && !busy`) dan
  `TapOutsideToPop` di `lib/ui/core/confirm_discard.dart`. Penghalang
  bawaan Forui 0.27.7 memanggil `Navigator.pop` langsung sehingga
  melewati `PopScope`; dialog kini `barrierDismissible: false` dengan latar
  yang bisa diketuk (`maybePop`) di belakang `FDialog`. Karena rute
  dengan `barrierDismissible: false` mematikan aksi Esc bawaan
  (`_DismissModalAction`), Esc dipasang ulang lewat `DismissIntent`.
  Tombol **Batal** memanggil `maybePop`; simpan tetap `pop(hasil)`.
- `showCustomerForm` / `showSupplierForm` memakai `useRootNavigator: true`.
- Temuan review: tes jalur Kasir ditambah (Important). Minor diperbaiki:
  - tutup dan Buang hanya bekerja bila dialog masih rute teratas
    (`ModalRoute.isCurrent`), jadi tidak menutup rute lain;
  - latar diberi label semantik dan aksi ketuk;
  - urutan impor dirapikan;
  - tes ditambah untuk tombol kembali sistem, Esc di supplier, ketukan di
    tepi dalam dialog, dialog ubah tanpa perubahan, dan simpan gagal.

  Ketukan di area aman ponsel dan spasi di akhir isian dicatat sebagai gap
  yang diterima.
- Tes VM pelanggan dan supplier, serta tes widget daftar pelanggan,
  supplier, dan Kasir. Sudah diverifikasi dengan uji mutasi.

## [0.99.0] - 2026-11-15

Isian *Catat pengeluaran* kini ditanyakan sebelum hilang karena pindah
menu, melanjutkan peringatan yang sama di form pembelian dan produk.

### Ditambahkan

- **Pengeluaran (1.22):** meninggalkan layar Pengeluaran saat keterangan,
  jumlah, foto nota, atau tanggal selain hari ini sudah diisi tetapi belum
  disimpan menampilkan dialog **Buang perubahan?** ("Pengeluaran yang
  sedang diisi belum disimpan dan akan hilang.") dengan **Batal** dan
  **Buang**. Berlaku untuk menu samping / bawah dan tombol kembali sistem.
- Di layar sempit, isian dialog *Catat pengeluaran* yang ditutup dengan
  **Batal** tetap tersimpan, jadi pindah menu sesudahnya juga ditanyakan.
  Mengetuk menu bawah saat dialog form masih terbuka juga ditanyakan;
  **Buang** menutup dialog dan layar sekaligus.
- Panduan *Pengeluaran* menjelaskan dialog ini (ID + EN).

### Diubah

- Jenis dan sumber dana tidak dihitung sebagai isian karena tetap terpilih
  setelah simpan. Form kosong dan form yang baru disimpan tetap bisa
  ditinggalkan tanpa bertanya.
- Keluar saat simpan atau pilih foto nota masih berjalan ditahan sampai
  selesai. Ganti kasir tidak ditahan.

### Catatan teknis

- `ExpenseFormViewModel.hasUnsavedChanges` (keterangan tanpa spasi,
  jumlah bukan Rp0, foto, `spentOn != setup.today`) dan `busy`
  (`save.running || pickReceipt.running`).
- `/pengeluaran` memakai `GoRoute.onExit` + `LeaveGuards` (F1-12f);
  `ExpensesScreen` memasang `check` di `initState` / `didUpdateWidget`,
  melepasnya di `dispose`. View model form dimiliki layar, jadi satu
  penjaga mencakup form samping (layar lebar) dan dialog (layar sempit).
- Pengeluaran adalah rute menu tingkat atas: tombol kembali sistem tidak
  punya halaman untuk di-*pop*, tetapi go_router tetap memanggil `onExit`.
  Memilih **Buang** di sana menutup aplikasi, sama seperti sebelumnya.
- Temuan review (Minor, diperbaiki): `busy` kini ikut menahan selama foto
  nota dipilih (view model yang sudah dibuang tidak lagi menerima
  `notifyListeners`); tes ditambah untuk tombol kembali sistem, keluar
  saat simpan berjalan (`FakeExpensesRepository.recordGate`), dan menu
  bawah saat dialog form terbuka.
- Tes VM (kosong, jenis / sumber dana saja, keterangan spasi, jumlah,
  tanggal, foto, simpan, galat simpan, sibuk) dan widget 1440 px serta
  360 px; diverifikasi mutasi.

## [0.98.0] - 2026-11-15

Form produk kini bertanya sebelum isian yang belum disimpan dibuang, sama
seperti form pembelian di v0.97.0. Varian, satuan, dan harga grosir yang
sudah diketik tidak hilang karena salah ketuk **Batal** atau menu.

### Ditambahkan

- **Produk (1.16):** meninggalkan form *Produk baru* atau *Edit produk*
  yang isiannya belum disimpan menampilkan dialog **Buang perubahan?**
  dengan **Batal** dan **Buang**. Isinya "Perubahan produk {nama} belum
  disimpan dan akan hilang.", atau "Produk baru ini belum disimpan dan
  akan hilang." bila nama masih kosong. Berlaku untuk tombol **Batal** di
  form, *Kembali*, tombol kembali sistem (Android), dan menu samping /
  bawah.
- Foto produk yang baru dipilih atau dihapus ikut dihitung perubahan.
- Panduan *Menambah produk pertama* menjelaskan dialog ini (ID + EN).

### Diubah

- Form yang hanya dibuka tanpa diubah, form yang baru disimpan, dan produk
  yang baru diarsipkan tetap bisa ditinggalkan tanpa bertanya. Mengetik
  lalu mengembalikan isian ke semula tidak dihitung berubah.
- Keluar saat simpan atau arsip masih berjalan ditahan sampai selesai.
- Barcode yang diisi dari *Cetak label* pada form yang belum diubah
  dianggap tersimpan (tidak memunculkan dialog).

### Catatan teknis

- `ProductFormViewModel.hasUnsavedChanges` membandingkan dua ringkasan
  datar dengan `listEquals`: data (`_dataSignature`: nama, kategori, jenis,
  satuan, SKU induk, merek, sakelar, modifier, varian beserta harga / stok
  minimum / stok awal untuk varian baru, satuan konversi, harga grosir)
  dan foto (`_photoSignature`: foto baru, hapus foto tersimpan). Salinan
  diambil setelah muat, simpan, dan arsip.
- `/produk/baru` dan `/produk/:productId` memakai `GoRoute.onExit` +
  `LeaveGuards` yang sama dengan pembelian (F1-12f); `ProductFormScreen`
  menerima `LeaveGuard` dan memasang `check` di `initState` /
  `didUpdateWidget`, melepasnya di `dispose`. Tombol **Batal** di form
  memakai `context.go`, yang juga memanggil `onExit`, jadi ikut
  ditanyakan tanpa kode tambahan.
- Temuan review: bila produk tersimpan tetapi menyimpan foto gagal,
  salinan lama membuat form yang dimuat ulang terlihat berubah. Salinan
  kini dipisah: data diperbarui setelah muat ulang, foto tetap dihitung
  belum tersimpan sehingga staf masih diingatkan. Ringkasan juga diganti
  dari string bersambung ke daftar datar agar tidak ada tabrakan
  pemisah.
- Saat di-debug: tes ponsel menggantung karena go_router menunggu
  `onExit` di halaman tingkat akar sebelum `popRoute` selesai; tes kini
  menjawab dialog dulu baru menunggu `handlePopRoute`.
- Tes VM (form baru, edit, ketik lalu kembalikan, foto, simpan, arsip,
  galat foto, barcode) dan widget desktop (Batal, menu samping) serta
  ponsel (tombol kembali sistem); diverifikasi mutasi.

## [0.97.0] - 2026-11-14

Form pembelian kini bertanya sebelum isian yang belum disimpan dibuang,
sehingga baris yang sudah diketik satu per satu tidak hilang karena salah
ketuk menu.

### Ditambahkan

- **Pembelian (1.19):** meninggalkan form *Pembelian baru* atau *Draf* yang
  isiannya belum disimpan menampilkan dialog **Buang perubahan?**
  ("Perubahan pembelian {nomor} belum disimpan dan akan hilang.") dengan
  **Batal** dan **Buang**. Berlaku untuk tombol *Kembali*, tombol kembali
  sistem (Android), menu samping / bawah, serta memilih draf lain atau
  *Pembelian baru* saat form tampil di samping daftar (layar lebar).
- Draf yang dibuka dari *Stok minimum* dengan barang tambahan (F1-08i)
  dianggap berubah sampai *Simpan draf* ditekan.
- Panduan *Pembelian* menjelaskan dialog ini (ID + EN).

### Diubah

- Form yang tidak diubah, isian otomatis dari *Stok minimum* pada
  pembelian baru, serta form yang baru disimpan, diterima, atau draf yang
  dihapus tetap bisa ditinggalkan tanpa bertanya. Mengetik lalu
  mengembalikan isian ke semula juga tidak dihitung berubah.
- Ganti kasir tidak ditahan dialog (isian hilang seperti sebelumnya).

### Catatan teknis

- `PurchaseFormViewModel.hasUnsavedChanges` membandingkan ringkasan isian
  (`_signature`: supplier, faktur, tanggal, lokasi, baris, biaya, bayar,
  sumber dana, jatuh tempo, catatan, foto) dengan salinan setelah muat /
  simpan / hapus draf.
- `LeaveGuard` / `LeaveGuards` (`lib/ui/core/leave_guard.dart`): satu
  penjaga per `GoRouterState.pageKey`; `GoRoute.onExit` di `/pembelian`,
  `/pembelian/baru`, dan `/pembelian/:id`. go_router memanggil `onExit`
  untuk `pop`, tombol kembali sistem, dan `go`, jadi satu titik menutup
  semua jalan keluar. Halaman memasang `check` di `initState` dan
  melepasnya di `dispose`.
- Dialog *Buang perubahan?* editor denah dipindah ke
  `lib/ui/core/confirm_discard.dart` (`confirmDiscardChanges`) dan dipakai
  bersama.
- Saat di-debug: tes F1-08g yang kembali dari draf berisi tambahan stok
  minimum kini melewati dialog, sesuai aturan baru.
- Temuan review: dialog semula hanya menutupi area isi, jadi mengetuk menu
  samping lagi saat dialog terbuka membuka dialog kedua. Dialog kini
  memakai navigator akar (menutupi menu) dan `LeaveGuard` memakai ulang
  pertanyaan yang sedang tampil. Juga diperbaiki: keluar saat simpan /
  terima masih berjalan ditahan sampai selesai; ubahan staf selama harga
  atau foto dimuat tetap dihitung; supplier baru yang dibatalkan, sumber
  dana tanpa bayar, dan jatuh tempo tanpa hutang tidak dihitung berubah;
  form samping yang tersembunyi di layar sempit tidak ditanyakan; halaman
  memasang ulang penjaga di `didUpdateWidget`.
- Tes VM (form baru, ketik lalu kembalikan, stok minimum, draf + tambahan,
  simpan, terima, hapus, galat simpan) dan widget ponsel 360 px (Kembali,
  kembali sistem, menu bawah) serta desktop (menu samping, ganti form);
  diverifikasi mutasi.

## [0.96.0] - 2026-11-14

Jumlah saran dari Stok minimum kini ikut satuan: mengganti baris botol ke
dus tidak lagi membuat staf memesan enam kali lipat.

### Ditambahkan

- **Pembelian baru / Draf (1.19) dari Stok minimum:** baris yang terisi
  dari stok minimum mengingat jumlah sarannya dalam satuan dasar. Mengganti
  satuan baris mengonversi saran itu ke satuan baru, dibulatkan ke atas ke
  satuan utuh (38 botol → 7 dus isi 6, 36 botol → 6 dus); kembali ke
  satuan dasar mengembalikan 38. Berlaku juga untuk barang yang ditambahkan
  ke draf lewat *Buka draf*.
- Panduan *Stok* dan *Pembelian* menjelaskan konversi ini (ID + EN).

### Diubah

- Setelah staf mengetik jumlah sendiri atau menambah barang yang sama lewat
  scan (+1), saran dilupakan dan mengganti satuan kembali mempertahankan
  angka seperti sebelumnya. Barang yang ditambah manual tidak berubah.
- Bila satuan baru sudah punya baris kembar untuk varian yang sama, baris
  digabung dengan menambahkan saran yang sudah dikonversi (mis. 1 dus + 7
  dus = 8 dus, bukan 39 dus).

### Diperbaiki

- Mengganti satuan baris saran dari botol ke dus mempertahankan angka 38,
  sehingga baris menjadi 38 dus = 228 botol tanpa peringatan.

### Catatan teknis

- `PurchaseFormLine.suggested` (`Qty?`, satuan dasar) dan
  `suggestedIn(unit)` = ⌈saran ÷ faktor⌉; diisi oleh `_applyRestock`.
- `copyWith` kini melupakan saran setiap kali `quantity` diisi, kecuali
  pemanggil memberi `keepSuggested: true` (hanya `setUnit`), agar
  pemanggil baru tidak membawa saran basi (temuan review).
- `setQuantity` tidak berbuat apa-apa bila angkanya sama, jadi
  `onChange` isian yang tidak mengubah angka tidak melupakan saran.
- Tes VM (38 → 7 → 38, 36 → 6, ketik jumlah, isian sama, scan ulang,
  gabung baris kembar, barang manual) dan alur widget 1280 / 360 px; tes
  widget, gabung kembar, dan isian sama diverifikasi mutasi.

## [0.95.0] - 2026-11-14

*Buka draf* dari Stok minimum kini langsung menambahkan barang di bawah
minimum yang belum dipesan, sehingga staf tidak perlu mencarinya satu per
satu.

### Ditambahkan

- **Stok (1.18) › Stok minimum › Buat pembelian › Buka draf:** form draf
  (1.19) terbuka dengan barang di bawah minimum yang belum ada di draf itu
  maupun di draf lain ke lokasi yang sama ditambahkan di akhir, dengan
  jumlah saran dan harga beli terakhir (harga modal bila belum pernah
  dibeli). Catatan di atas form: "{n} barang ditambahkan ke draf ini, {m}
  barang sudah ada. Simpan draf agar tambahan tersimpan", atau "Semua
  barang di bawah minimum sudah ada di draf ini".
- Isi dialog *Sudah ada draf pembelian* menyebut bahwa barang yang belum
  ada akan ditambahkan.
- Panduan *Stok* diperbarui (ID + EN).

### Diubah

- Baris draf yang sudah ada, lokasi terima, supplier, dan isian lain draf
  tidak diubah saat dibuka dari Stok minimum; tambahan baru tersimpan saat
  *Simpan draf* / *Terima* ditekan, lalu catatannya hilang.

### Catatan teknis

- Rute `/pembelian/:id` meneruskan `extra` `PurchaseRestock` ke
  `PurchaseDetailScreen.restock` → `PurchaseFormPage`;
  `StockScreen.onOpenDraft` kini `(id, restock)`.
- `PurchaseFormViewModel._applyRestockToDraft` (setelah `_fill`) memakai
  `_applyRestock(keepLocation: true)` dan `_applyRestockPrices(keys)`.
  Harga terakhir kini hanya diterapkan ke baris sasaran, agar baris draf
  lama tidak tersentuh.
- Saat di-review: membuka draf A dengan seluruh isian stok minimum ikut
  menambahkan barang yang sudah dipesan di draf B (pesanan ganda yang
  justru dicegah F1-08g). Isian kini membuang varian draf lain sebelum
  dibuka; tes dua draf diverifikasi dengan mutasi.
- Tes VM (tambahan + baris lama tetap, semua sudah ada, simpan ke draf yang
  sama) dan alur widget 1280 / 360 px.

## [0.94.0] - 2026-11-14

Daftar Stok minimum kini menandai barang yang sudah ada di draf pembelian,
sehingga staf tahu mana yang sudah dipesan dan mana yang belum.

### Ditambahkan

- **Stok (1.18) › Stok minimum:** barang di bawah minimum yang sudah ada
  di draf pembelian ke lokasi yang sedang dilihat diberi keterangan biru
  **Sudah di draf {nomor}**. Bila barang ada di beberapa draf, nomor draf
  yang paling banyak memuat barang di bawah minimum (lalu yang terakhir
  diubah) yang ditampilkan. Keterangan ini juga tampil di panel *Stok
  minimum* tab *Penyesuaian* desktop.
- Hanya staf dengan izin *Kelola pembelian* yang melihat keterangan ini.
- Panduan *Stok* menjelaskan keterangan ini (ID + EN).

### Catatan teknis

- `RestockDraft` kini menyimpan `variantIds`; `matched` menjadi getter.
- `StockViewModel` menerima `restockDrafts` opsional dan menyusun
  `variantId → nomor draf` di `_loadOnce`, bersamaan dengan pembacaan
  penyesuaian terakhir (tidak menambah dua kueri berurutan). Galat baca
  diabaikan. Tanda selalu dipasang berpasangan dengan daftar minimum, jadi
  tidak tertinggal saat lokasi diganti di tengah muat.
- Saat di-debug di ponsel 360 px, nomor draf terpotong elipsis
  ("Sudah di draf PB-PS…") sehingga draf tidak bisa dibedakan; teks kini
  dibungkus utuh dan tes memeriksa `didExceedMaxLines`.
- Warna teks memakai biru muda `#74D4FF` di tema gelap (kontras 4.5:1).
- Tes VM (nomor draf pertama, galat, muat ulang), widget 1280 / 360 px,
  dan tes izin dengan penghitung kueri (diverifikasi mutasi). Tes alur
  F1-08g menyesuaikan karena nomor draf kini juga tampil di daftar.

## [0.93.0] - 2026-11-14

*Buat pembelian* di Stok minimum kini mengingatkan bila sudah ada draf
pembelian berisi barang yang sama, agar staf tidak memesan dua kali.

### Ditambahkan

- **Stok (1.18) › Stok minimum › Buat pembelian:** bila sudah ada draf
  pembelian ke lokasi yang sama yang memuat sebagian barang di bawah
  minimum, dialog *Sudah ada draf pembelian* menyebut nomor draf dan
  "berisi X dari Y barang di bawah minimum", dengan tombol **Buka draf**,
  **Buat draf baru**, dan **Batal**. Bila ada beberapa draf, yang paling
  banyak memuat barang yang sama dipilih (lalu yang terakhir diubah), dan
  dialog menyebut jumlah draf lainnya.
- Panduan *Stok* menjelaskan dialog ini (ID + EN).

### Diperbaiki

- Menyimpan draf dari stok minimum lalu mengetuk *Buat pembelian* lagi
  tidak lagi diam-diam membuat draf kedua berisi barang yang sama (gap
  F1-08c *Catatan isian setelah Simpan draf*).

### Catatan teknis

- `restockDraftsOf(store, scope, locationId, variantIds)` di
  `lakuna_data`: baca draf cabang ke lokasi itu dulu (biasanya sedikit),
  lalu item draf untuk varian yang diminta; diekspos sebagai
  `PurchasesRepository.restockDrafts` (izin *Kelola pembelian*).
- `StockScreen._restock` mencari draf di bawah bendera `_checkingDraft`
  sebelum masuk `whileAway`. Saat di-debug, mencari draf di dalam
  `whileAway` membuka celah: halaman Stok masih rute teratas selama
  kueri berjalan, sehingga pembangunan ulang router melepas penjaga ketukan
  ganda dan ketukan kedua membuka dialog kedua. Tes balapan memakai gerbang
  `restockDraftsGate` di repositori palsu dan gagal bila bendera dibuang.
- Dialog 360 px: label tombol forui dibungkus `Flexible` (baris isi tombol
  meluap 32 px tanpa itu); tombol ditumpuk dan isi bisa digulir.
- Galat baca draf diabaikan: form baru langsung terbuka.
- Tes data (urutan, draf dihapus, pembelian diterima, lokasi lain) dan alur
  widget 1280 / 360 px.

## [0.92.0] - 2026-11-14

Barang yang discan atau dicari di form pembelian kini langsung terisi
harga beli pada pembelian terakhirnya, sama dengan pembelian dari stok
minimum sejak v0.89.0.

### Ditambahkan

- **Pembelian (1.19) › + Scan / cari produk:** baris baru dalam satuan
  dasar terisi harga satuan pada pembelian **diterima** terbaru barang itu
  di cabang ini (per satuan dasar, baris bonus Rp 0 dilewati), bukan harga
  modal rata-rata. Barang yang belum pernah dibeli dan baris dalam satuan
  konversi (mis. scan barcode dus) tetap memakai harga modal.
- Mengganti satuan baris kembali ke satuan dasar memakai harga beli
  terakhir lagi.
- Panduan *Pembelian* menjelaskan asal harga (ID + EN).

### Catatan teknis

- `PurchaseFormViewModel._fillLastPrice`: dibaca lewat
  `PurchasesRepository.lastPurchasePrices` (F1-08e) tanpa menunggu,
  disimpan per varian di `_lastPrices` selama form terbuka (termasuk hasil
  baca draf stok minimum; dikosongkan untuk form baru). Harga hanya diganti
  bila baris masih satuan dasar dan masih memakai harga awal satuannya, dengan
  `priceRev` naik agar isian harga ikut berganti. Galat baca diabaikan.
- *Simpan draf* / *Terima* menunggu pengisian harga yang masih berjalan
  (`_pendingFills`) agar yang tersimpan sama dengan yang tampil.
- `_applyRestockPrices` hanya menyimpan varian yang diminta ke cache.
- Draf yang dibuka lagi tidak berubah harganya.
- Tes VM (harga terakhir / harga modal, ubah selama menunggu, ganti ke dus
  selama menunggu, kembali ke satuan dasar tanpa membaca ulang, galat baca,
  simpan sebelum riwayat terbaca, form baru, riwayat dari draf stok
  minimum, draf yang dibuka lagi) dan alur widget 1440 / 360 px.
- Gap F1-08e *Harga beli terakhir saat menambah barang manual* dan *Harga
  terakhir setelah ganti satuan* ditutup.

## [0.91.0] - 2026-11-14

Daftar Pembelian, Pelanggan, Supplier, dan Riwayat kini selalu segar
setelah staf meninggalkan halaman detail lewat menu samping.

### Diperbaiki

- **Pembelian (1.19), Pelanggan (1.20), Supplier (1.21), Riwayat (1.10):**
  bila halaman detail (atau pembelian baru, kuitansi, detail nota)
  ditinggalkan lewat menu samping ke menu yang sama, misalnya mengetuk
  *Pelanggan* saat kuitansi pembayaran piutang masih terbuka, daftar tetap
  menampilkan data lama: piutang yang baru dibayar, hutang yang baru
  dilunasi, pembelian yang baru diterima, atau nota yang baru di-void. Kini
  daftar (dan panel detail yang terpilih) dimuat ulang begitu tampil lagi.

### Catatan teknis

- Penyebab sama dengan F1-08f: halaman detail dibuka dengan
  `context.push` dan daftar baru dimuat ulang setelah future-nya selesai,
  sedangkan menu samping memakai `context.go` yang membuang halaman itu
  tanpa menyelesaikan future, sementara State daftar dipertahankan.
- `RouteReturnMixin` baru (`lib/ui/core/route_return.dart`):
  `whileAway(open)` menghitung halaman yang sedang dibuka (dua ketukan
  cepat pada baris bisa membuka dua), dan `didUpdateWidget` memanggil
  `onRouteReturn()` setelah frame bila masih ada halaman terbuka dan
  `ModalRoute.isCurrentOf(context)`. Epoch memastikan future lama yang
  selesai belakangan tidak mengurangi hitungan halaman sesudahnya.
- `HistoryViewModel` tidak lagi memberi tahu pendengar setelah dibuang.
- Dipakai `StockScreen` (menggantikan `_restocking` / `_restockGen`; tanda
  tetap menjadi penjaga ketukan ganda *Buat pembelian*),
  `PurchasesScreen`, `CustomersScreen`, `SuppliersScreen`, dan
  `HistoryScreen`.
- Tes alur widget: keluar dari detail lewat menu samping lalu daftar
  memuat data baru, untuk Pembelian (1440 px), Pelanggan, Supplier, dan
  Riwayat (800 px); tes unit mixin dengan go_router nyata.

## [0.90.0] - 2026-11-14

Tombol *Buat pembelian* di Stok tidak lagi macet setelah staf meninggalkan
form pembelian lewat menu samping.

### Diperbaiki

- **Stok (1.18) › Stok minimum › Buat pembelian:** bila form pembelian baru
  ditinggalkan lewat menu samping (mis. mengetuk *Stok* lagi) tanpa
  disimpan atau dibatalkan, tombol *Buat pembelian* tidak bereaksi lagi
  sampai aplikasi dibuka ulang, dan daftar stok tetap menampilkan angka
  lama. Kini saat halaman Stok tampil kembali, tombol langsung bisa dipakai
  dan daftar stok dimuat ulang.

### Catatan teknis

- Penyebab: form dibuka dengan `context.push`, dan penjaga ketukan ganda
  `_restocking` baru dilepas (lalu daftar dimuat ulang) setelah future
  `push` selesai. Menu samping memakai `context.go`, yang mengganti
  tumpukan tanpa pernah menyelesaikan future itu, sementara state halaman
  Stok di `ShellRoute` dipertahankan.
- Perbaikan: `_StockScreenState.didUpdateWidget` melepas penjaga dan
  memuat ulang daftar bila penjaga masih terpasang dan
  `ModalRoute.of(context)?.isCurrent` bernilai `true`. Saat push sendiri
  halaman Stok juga dibangun ulang tetapi bukan rute teratas, jadi
  ketukan ganda tetap hanya membuka satu form. Nomor generasi
  `_restockGen` memastikan `finally` dari form lama yang ditinggalkan
  tidak melepas penjaga form baru.
- Tes alur widget: buka *Buat pembelian*, stok berubah, ketuk menu
  *Stok*; form hilang, tab *Stok minimum* menampilkan data baru, dan
  *Buat pembelian* membuka form lagi; dua ketukan dalam satu frame hanya
  membuka satu form.

## [0.89.0] - 2026-11-14

Pembelian dari stok minimum kini mengisi harga tiap barang dengan harga
beli pada pembelian terakhir, sehingga staf tidak perlu mengetik ulang
harga faktur supplier.

### Ditambahkan

- **Stok (1.18) › Buat pembelian → Pembelian baru (1.19):** harga baris
  diisi dari harga satuan pada pembelian **diterima** terbaru barang itu
  di cabang ini (harga di faktur, sebelum ongkos kirim dan diskon nota),
  dihitung per satuan dasar. Contoh: pembelian terakhir Rp 185.000 per
  dus isi 6 menjadi Rp 30.833 per botol. Baris bonus Rp 0 dilewati.
  Barang yang belum pernah dibeli tetap memakai harga modal.
- Catatan di atas form menyebut *Harga diisi dari pembelian terakhir untuk
  n dari m barang.*
- Panduan *Penyesuaian & stok minimum* menjelaskan asal harga (ID + EN).

### Catatan teknis

- `lakuna_domain`: `perBaseUnitPrice(unitPrice, factor)` (bulat setengah
  menjauhi nol).
- `lakuna_data`: `lastPurchasePricesOf(store, scope, variantIds)`:
  pembelian diterima terbaru per varian (`received_at` atau tanggal beli,
  lalu nomor, lalu urutan baris), tanpa syarat supplier; draf dan
  pembelian terhapus diabaikan.
- Flutter: `PurchasesRepository.lastPurchasePrices`;
  `PurchaseFormViewModel` mengganti harga baris satuan dasar yang belum
  diubah staf selama riwayat dimuat (`restockPriceCount`) dan menaikkan
  `priceRev` agar isian harga yang sudah tampil ikut berganti; galat baca
  diabaikan (harga modal tetap).
- Tes domain (pembulatan, isi pecahan), data (terbaru menang, draf, tanpa
  supplier, dua satuan dalam satu pembelian, per dus, baris bonus Rp 0),
  VM (sebagian barang, `priceRev`, galat baca), dan alur widget 1280 /
  360 px.
- Gap F1-08d *Harga beli terakhir sebagai harga baris* ditutup.

## [0.88.0] - 2026-11-14

Bill meja dan take away kini memberi tahu bila grup pelanggannya diubah
saat bill masih terbuka, dan harga bisa disegarkan dengan satu tombol.

### Ditambahkan

- **Meja (1.7 / 1.8), panel bill:** bila grup pelanggan bill diubah di
  menu Pelanggan (mis. dari tanpa grup ke *Reseller*, dilepas dari grup,
  atau grupnya dihapus) setelah harga bill dihitung, di bawah baris
  *Pelanggan* tampil *Grup pelanggan berubah. Harga bill masih memakai
  grup lama.* dengan tombol **Segarkan harga**. Tombol ini menghitung ulang
  semua item (termasuk yang sudah di dapur) dengan grup baru dan harga menu
  terkini, lalu total, service, PB1, diskon, dan pembulatan ikut dihitung
  ulang. Peringatan tidak tampil saat bill di-split atau sudah ada bayar
  bagian.
- Memilih ulang pelanggan yang sama di pemilih pelanggan bill juga
  menyegarkan harga bila grupnya sudah berubah; bila grupnya sama, harga
  beku item tetap.
- Panduan *Meja & open bill* menjelaskan peringatan dan *Segarkan harga*
  (ID + EN).

### Diperbaiki

- Mengganti pelanggan bill kini membandingkan grup pelanggan baru dengan
  grup yang benar-benar dipakai harga bill. Sebelumnya yang dibandingkan
  grup pelanggan lama saat ini, sehingga bila grup pelanggan lama sudah
  diubah dan kebetulan sama dengan grup pelanggan baru, item tetap memakai
  harga grup lama. Gabung meja memakai aturan yang sama.

### Catatan teknis

- Kolom baru `sales.price_group_id` (`Sale.priceGroupId`, tanpa relasi):
  grup pelanggan saat harga open bill terakhir dihitung; migrasi
  `segarkan-harga-grup` (Postgres `ADD COLUMN`, SQLite `ADD COLUMN`).
  Diisi oleh `setOpenBillCustomer`, `mergeOpenBills`, dan item pertama
  `addBillItem` pada bill kosong.
- `OpenBill.priceGroupStale`: pelanggan masih ada, bill punya item, dan
  grup pelanggan ≠ `priceGroupId`. Bill tanpa pelanggan atau pelanggannya
  dihapus dianggap berharga umum (`_appliedGroup`), sehingga harga beku
  F1-10f aturan 4 tetap berlaku.
- Bill yang dibuka sebelum v0.88.0 dengan pelanggan bergrup belum punya
  grup harga, jadi peringatannya tampil sekali; *Segarkan harga*
  mencatatnya.
- Tes data (tanda grup lama, item baru, pilih ulang, harga beku, ganti
  pelanggan, gabung meja dua arah, bill kosong, data lama, pelanggan
  terhapus, outbox) dan alur widget 1280 / 360 px.
- Gap F1-10f *Segarkan harga saat grup pelanggan diubah di master* ditutup.

## [0.87.0] - 2026-11-14

Kasir kini bisa mencetak ulang rekap sesi yang sudah ditutup langsung dari
layar Sesi kasir, tanpa izin laporan.

### Ditambahkan

- **Sesi kasir (1.3):** saat belum ada sesi terbuka, kartu *Sesi
  sebelumnya* di bawah formulir *Buka sesi* menampilkan 5 sesi terakhir
  yang ditutup di perangkat ini: tanggal dan jam buka–tutup, nama pembuka,
  dan selisih kas (merah bila kurang, hijau bila lebih, *Pas* bila sama);
  tanggal tutup ikut tampil bila sesi ditutup di hari lain.
  Mengetuk sesi membuka dialog *Rekap sesi* yang sama dengan Laporan
  (pratinjau, *Cetak*, *Bagikan PDF*, baris *Dicetak ulang*).
- Sesi yang baru ditutup langsung masuk daftar setelah *Buka sesi baru*.
- Panduan *Sesi kasir* menjelaskan kartu *Sesi sebelumnya* (ID + EN).

### Diperbaiki

- Pemilik yang masuk lewat email di cabang tempat ia belum terdaftar
  sebagai anggota kini tetap dianggap pemilik saat memuat laporan dan rekap
  sesi. Sebelumnya izinnya terbaca kosong sehingga dialog *Rekap sesi* di
  Laporan gagal dimuat (`findActingStaff`).

### Keamanan

- Rekap sesi lama kini juga boleh dimuat dengan izin `cash_session:close`,
  tetapi **hanya untuk sesi yang dibuka di perangkat yang sama**. Sesi
  perangkat lain tetap butuh `reports:view` (dicek di lapisan data, izin
  dibaca ulang dari role staf di database).

### Catatan teknis

- `lakuna_data`: `listRecentClosedSessions` (sesi tertutup perangkat ini,
  urut waktu tutup terbaru, maks 5, waktu lokal cabang);
  `loadClosedSessionRecap` menerima `cash_session:close` untuk
  `scope.deviceId`.
- Flutter: `CashDrawerRepository.recentClosed` / `loadSessionRecap`;
  `SessionRecapDialogViewModel` dan `showSessionRecapDialog` menerima
  fungsi `loadRecap` (dipakai Laporan dan Sesi kasir);
  `CashSessionViewModel.previous` / `loadRecap`; widget `_PreviousSessions`.
- Tes data (urutan, batas 5, perangkat lain, izin), VM (dimuat, tanpa
  izin, setelah *Buka sesi baru*, galat), dan alur widget 1280 / 360 px
  sampai cetak.
- Gap F1-03e *Cetak ulang dari layar Sesi kasir* ditutup.

## [0.86.0] - 2026-11-14

Toko dengan beberapa rekening bank kini bisa menuliskannya terpisah, satu
rekening per baris, dan kasir menyalin rekening bank yang dipilih pembeli
saja.

### Ditambahkan

- **Pengaturan (1.26) › Penjualan & stok:** isian *Rekening transfer*
  menjadi beberapa baris: satu rekening per baris, maksimal 3 rekening,
  tiap baris maksimal 100 karakter. Lebih dari 3 rekening menampilkan
  *Maksimal 3 rekening.*, baris terlalu panjang menampilkan *Satu rekening
  maksimal 100 karakter.*, dan *Simpan* nonaktif sampai diperbaiki. Baris
  kosong dan spasi di ujung baris dibuang saat disimpan.
- **Pembayaran (1.5):** kotak *Transfer ke* (panel transfer dan baris
  transfer *Bagi beberapa metode*) menampilkan satu baris per rekening,
  masing-masing dengan tombol *Salin* sendiri; hanya tombol yang terakhir
  ditekan yang berubah menjadi *Disalin*. Tombol metode *Transfer bank* di
  layar lebar menampilkan semua rekening dipisah ` · `.
- **Struk (1.12) dan kuitansi (1.20b):** nota piutang, tagihan pre-bill,
  dan kuitansi thermal mencetak satu baris *Transfer ke: …* per rekening;
  isian *Transfer sisa ke* di kuitansi A5 memuat semua rekening, satu per
  baris.
- Panduan *Pengaturan toko* dan *Bayar* menjelaskan beberapa rekening
  (ID + EN).

### Diubah

- Baris baru di rekening transfer kini memisahkan rekening. Sebelumnya
  baris baru dianggap spasi dan semua teks dicetak dalam satu baris
  *Transfer ke*.
- Rekening tersimpan yang rusak (lebih dari 3 baris atau baris lebih dari
  100 karakter) dirapikan saat dimuat, agar simpan ulang aturan lain tidak
  gagal. Data lama satu baris terbaca sebagai satu rekening tanpa
  perubahan.

### Catatan teknis

- `lakuna_domain`: `ProfileLimits.transferAccountLines = 3`,
  `normalizeTransferAccounts`, `transferAccountIssue` →
  `TransferAccountIssue.tooMany` / `tooLong`, `SalesRules.transferAccounts`.
  Kunci JSON tetap `transferAccount` (baris dipisah `\n`), jadi cadangan
  lama tetap cocok.
- `lakuna_data`: `saveSalesRules` merapikan baris dan melempar
  `SalesRulesInvalid` untuk galat per baris; `ReceiptConfig.transferAccounts`.
- Flutter: `StoreSettingsViewModel.transferAccountIssue` / `canSaveRules`;
  `CashierViewModel.transferAccounts`; `TransferAccountBox(accounts:)`
  dengan tombol `payment-transfer-copy-<i>`; `receiptTransferLines`
  menggantikan `receiptTransferLine`.
- Tes domain, data, VM dan widget pengaturan, layar bayar 1280/360 px,
  *Bagi beberapa metode*, struk piutang, pre-bill, dan kuitansi.
- Cadangan dari versi ini yang dipulihkan di aplikasi versi lama
  menampilkan rekening dalam satu isian bergaris baru; struk versi lama
  tetap mencetaknya sebagai satu baris.
- Gap F1-05c *Beberapa rekening terpisah (pilih bank)* ditutup.

## [0.85.0] - 2026-11-14

Templat import produk, pelanggan, dan supplier kini tersedia dalam bahasa
Inggris untuk pengguna yang memakai aplikasi berbahasa Inggris.

### Ditambahkan

- **Dialog import (1.15 Produk, 1.20 Pelanggan, 1.21 Supplier):** *Download
  template* mengikuti bahasa aplikasi. Bahasa Inggris memberi
  `import-template-products.xlsx` / `-customers` / `-suppliers` (lembar
  *Products* / *Customers* / *Suppliers*) dengan judul kolom Inggris:
  - Produk: Name, Category, Type, Unit, SKU, Barcode, Cost price, Sell
    price, Opening stock, Min stock.
  - Pelanggan: Name, Phone, Address, Group, Credit limit, Note.
  - Supplier: Name, Contact, Phone, Category, Term (days), Address, Note.
- Dua baris contoh berbahasa Inggris (*Sample Sugar 1 kg*, *Sample Ani
  Grocery*, *Sample Fresh Foods Ltd*, …) dengan angka yang sama dengan
  templat Indonesia. Kolom Phone, SKU, dan Barcode berformat teks.
- Panduan *Produk pertama*, *Pelanggan & kredit*, dan *Supplier & hutang*
  menyebut templat mengikuti bahasa aplikasi (ID + EN).

### Diubah

- Pembaca import melewati baris contoh dari templat **kedua** bahasa,
  apa pun bahasa aplikasi saat import, jadi templat Inggris bisa diimport
  di aplikasi berbahasa Indonesia dan sebaliknya.

### Catatan teknis

- `lakuna_domain`: `productImportTemplateEn`, `customerImportTemplateEn`,
  `supplierImportTemplateEn`; pemeriksaan `isImportTemplateSample` untuk
  kedua templat di ketiga pembaca.
- Flutter: `ImportTemplateKind.fileNameFor` / `sheetNameFor` / `rowsFor` /
  `bytesFor(bahasa)` menggantikan `fileName` / `rows` / `bytes`;
  `ImportFileActions` membaca bahasa dari `Localizations` saat tombol
  ditekan; judul *Phone* masuk kolom teks.
- Tes domain (judul EN dikenali, contoh EN dilewati, nama diganti sah,
  contoh EN di bawah judul Indonesia), `.xlsx` EN terbaca kembali dan kolom
  teks, serta alur Supplier berbahasa Inggris.
- Gap F1-07g *Templat berbahasa Inggris* ditutup.

## [0.84.0] - 2026-11-14

Rekap sesi kasir yang sudah ditutup kini bisa dicetak ulang dari Laporan,
jadi kertas rekap yang hilang atau printer yang mati saat tutup tidak lagi
membuat rekap hilang.

### Ditambahkan

- **Laporan (1.23) › Kas & sesi:** baris sesi yang sudah ditutup bisa
  diketuk (ikon printer di ujung baris) dan membuka dialog *Rekap sesi*:
  pratinjau kertas struk, **Cetak rekap**, dan **Bagikan PDF**. Sesi yang
  masih buka tidak bisa diketuk. Kalimat petunjuk tampil di bawah tabel.
- Rekap cetak ulang memakai isi rekap F1-03b (lebar kertas, logo, dan
  printer dari *Pengaturan › Struk & printer*) dengan baris **Dicetak
  ulang** (tanggal jam cetak, zona waktu cabang). Perangkat = kode
  perangkat tempat sesi dibuka; *Ditutup oleh* = staf yang menutup sesi.
- Bila rincian kas laci yang dimuat ulang tidak lagi sama dengan
  *Seharusnya di laci* yang tersimpan saat tutup, rekap memuat catatan
  *Rincian mengikuti data saat ini; ada data sesi yang berubah setelah
  ditutup.*
- Galat printer memakai pesan yang sama dengan struk; PDF di desktop
  disimpan ke folder struk (`rekap-sesi-YYMMDD-HHMM.pdf`) dan lokasinya
  ditampilkan. Sesi tidak ditemukan / gagal dimuat menampilkan pesan.
- Panduan *Laporan* dan *Sesi kasir* menjelaskan cetak ulang rekap (ID +
  EN).

### Keamanan

- Rekap dimuat lewat `ReportsRepository` yang memeriksa ulang izin
  `reports:view` dari role staf di database; sesi cabang lain ditolak.

### Catatan teknis

- `lakuna_data`: `CashSessionLine.id`; `ClosedSessionRecap` dan
  `loadClosedSessionRecap` (sesi tenant + cabang, status tutup; gerakan
  kas, `sessionSalesSummary`, retur tunai, nama pembuka/penutup, kode
  perangkat; `changedSinceClose`); galat `CashSessionNotClosed`.
- Flutter: `ReportsRepository.loadSessionRecap`; `SessionRecap.fromClosed`
  dan `changedSinceClose`; `sessionRecapContent(reprintedAt:)`;
  `SessionRecapDialogViewModel` + `showSessionRecapDialog`
  (`lib/ui/reports/session_recap_dialog.dart`); `_Line.onTap` di tabel tab
  lanjutan (kolom ikon hanya bila ada baris yang bisa diketuk);
  `ReportsScreen` menerima `store`, `receiptSettings`, dan `printer` dari
  router.
- Tes data (isi rekap, berubah setelah tutup, sesi buka / cabang lain /
  tanpa izin), isi rekap cetak ulang (ID + EN), VM dialog (muat, cetak,
  galat printer, PDF, galat muat), dan alur Laporan 1280 / 360 px.
- Gap F1-03b *Cetak ulang rekap sesi lama* ditutup.

## [0.83.0] - 2026-11-14

Draf pembelian dari stok minimum kini langsung memilih supplier langganan,
jadi pemilik cukup memeriksa jumlah lalu menyimpan.

### Ditambahkan

- **Stok (1.18) › Stok minimum › Buat pembelian:** form *Pembelian baru*
  (1.19) langsung memilih supplier yang menjadi supplier pembelian
  diterima terakhir untuk paling banyak barang di draf. Bila seri, yang
  pembeliannya paling baru. Jatuh tempo ikut tempo supplier itu.
- Catatan di atas form mendapat kalimat *Supplier diisi dari pembelian
  terakhir: {supplier} ({n} dari {m} barang).*; kalimat ini hilang bila
  staf mengganti supplier.
- Panduan *Stok* menjelaskan supplier yang terisi otomatis (ID + EN).

### Catatan teknis

- `lakuna_domain`: `chooseRestockSupplier` (terbanyak, seri = terbaru).
- `lakuna_data`: `lastSuppliersOf` — pembelian diterima cabang ini,
  terbaru menurut `received_at` lalu nomor; draf, pembelian tanpa
  supplier, baris terhapus, dan supplier terhapus diabaikan.
- `PurchasesRepository.lastSuppliers`; `PurchaseFormViewModel` mengisi
  supplier hanya bila staf belum memilih, dan mengabaikan galat baca.
- Tes domain, data (draf, urutan, supplier terhapus), VM (terbanyak, ganti
  supplier, galat baca, supplier tidak ada lagi), dan alur Stok 1280 /
  360 px.
- Gap F1-08c *Supplier terakhir per barang* ditutup.

## [0.82.0] - 2026-11-14

Pemilik kini bisa melihat seberapa lama piutang pelanggan dan hutang ke
supplier tertunggak, untuk memutuskan mana yang ditagih atau dibayar dulu.

### Ditambahkan

- **Laporan (1.24) › Piutang & hutang:** tabel **Umur piutang** (sebelum
  daftar per pelanggan) dan **Umur hutang** (sebelum daftar per supplier).
  Sisa tiap nota dikelompokkan menurut hari lewat jatuh tempo: *Belum
  jatuh tempo* (termasuk tanpa jatuh tempo), *Lewat 1–30 hari*, *31–60*,
  *61–90*, dan *> 90 hari*, lengkap dengan jumlah nota dan baris Total.
  Di layar ponsel tabel tampil sebagai kartu.
- Unduhan PDF/Excel tab Piutang & hutang memuat bagian *Umur piutang* dan
  *Umur hutang*, serta catatan cara hitung umur.
- Panduan *Laporan* menjelaskan tabel umur (ID + EN).

### Diubah

- Kartu *Piutang jatuh tempo* di tab Piutang & hutang kini dihitung dari
  data yang sama dengan daftar dan tabel umur, sehingga selalu sama dengan
  jumlah kelompok *Lewat …*. Pelanggan yang sudah dihapus tidak lagi ikut
  terhitung di kartu ini.

### Catatan teknis

- `lakuna_domain`: `AgingBucket`, `agingBucketOf` (selisih tanggal
  kalender UTC, sama dengan `isOverdue`), dan `Aging` (nilai + jumlah nota
  per kelompok, `total`, `overdue`).
- `lakuna_data`: `customersWithReceivables` dan `suppliersWithPayables`
  mengembalikan daftar beserta nota bersisa dari satu pembacaan;
  `listCustomers` / `loadSuppliersOverview` memakainya. `loadDebtReport`
  kini membaca piutang sekali (sebelumnya dua kali) dan mengisi
  `receivableAging` / `payableAging`.
- Tes domain untuk batas 0/1/30/31/60/61/90/91 hari; tes data untuk
  kelompok, total = kartu, dan pelanggan terhapus; tes alur Laporan 1440,
  800, dan 360 px serta tabel ekspor.
- Gap F1-14 *Umur hutang* ditutup.

## [0.81.0] - 2026-11-14

Nota lama kini bisa ditemukan lewat nama barang yang dibeli, tanpa perlu
ingat nomor nota atau pelanggannya.

### Ditambahkan

- **Riwayat (1.14) › Cari:** kolom cari kini juga mencocokkan nama produk
  dan nama varian barang di nota (huruf besar/kecil diabaikan, potongan
  kata boleh, mis. `gula` atau `es teh`). Seperti pencarian lain, hasil
  menjangkau semua tanggal (100 nota terbaru) dan filter kasir, metode,
  serta status tetap berlaku.
- Panduan *Retur & void* menyebut pencarian nama barang (ID + EN).

### Diubah

- Petunjuk kolom cari Riwayat: *Cari no. nota, pelanggan, barang, atau
  referensi* / *Search receipt no., customer, item, or reference*.

### Catatan teknis

- `HistoryRepository` lokal menambahkan subkueri `id IN (SELECT sale_id
  FROM sale_items ...)` (nama produk atau varian, `LOWER ... LIKE`, tanpa
  baris terhapus) ke kueri nota, sehingga tidak ada batas jumlah barang dan
  filter cabang tetap dari kueri nota. Nota yang hanya cocok lewat barang
  dicek ulang per kelompok di Dart agar `%` dan `_` literal. Barang yang
  dihapus dari bill sebelum bayar tidak membuat nota cocok.
- Tes data baru untuk produk, varian, barang terhapus, `%`/`_` literal,
  serta filter status, metode, dan kasir;
  tes alur Riwayat 1280/360 px untuk petunjuk kolom cari.
- Gap F1-11b *Cari nama item* ditutup; kata kunci yang melintasi nama
  produk + varian (mis. `Beras 5 kg`) masih gap.

## [0.80.0] - 2026-11-14

Tamu restoran kini bisa menerima tagihan cetak sebelum membayar, lengkap
dengan service, PB1, dan rekening transfer toko.

### Ditambahkan

- **Meja & open bill (1.7) › Cetak tagihan:** aksi baru di panel bill
  Meja dan Take away. Dialog *Tagihan {meja/antrean}* menampilkan
  pratinjau kertas dan tombol *Cetak tagihan* (printer struk perangkat)
  serta *Bagikan PDF*. Galat printer, *Struk terkirim ke printer*, dan
  lokasi PDF tampil di dialog.
- Isi tagihan: kepala dan logo struk, banner *TAGIHAN - BELUM DIBAYAR*,
  nomor bill, waktu cetak, kasir, meja/antrean, pelanggan terdaftar,
  barang (modifier, diskon baris, porsi split digabung), Subtotal, diskon
  nota, service, PB1, pembulatan, TOTAL, *Sudah dibayar* dan *Sisa
  tagihan* bila sebagian split sudah lunas, *Menunggu konfirmasi* untuk
  QRIS bagian yang belum dikonfirmasi, dan *Transfer ke* bila rekening
  diisi (menutup gap F1-05e).
- Panduan *Meja & open bill* bagian *Cetak tagihan* (ID + EN).

### Catatan teknis

- `billReceiptContent` di `receipt_content.dart`; baris barang nota dan
  tagihan kini dari `_receiptItems` yang sama (perilaku struk nota tidak
  berubah).
- `DiningData.businessName/outletName`; `DiningViewModel.printBill`,
  `shareBill`, `billPrintFailure`, `billPrinted`, `billPdfPath`,
  `clearBillPrint()`.
- Mencetak tagihan tidak menulis data, tidak mengubah *Minta bill*, dan
  tidak memberi nomor nota baru. Waktu cetak diambil saat tombol ditekan;
  hasil cetak/PDF dari dialog yang sudah ditutup (printer jaringan lambat)
  diabaikan agar tidak muncul di tagihan meja lain.
- l10n `diningPrintBill`, `diningBillPreviewTitle`, `receiptBannerBill`,
  `receiptPaidSoFar`, `receiptBalanceDue`, `receiptPendingConfirm`,
  `diningBillShareFailed`. Tes unit isi tagihan (split lunas/menunggu,
  diskon persen/rupiah, take away, EN, 58 mm), VM (hasil basi, galat
  PDF), dan widget Meja 1280/360.

## [0.79.0] - 2026-11-14

Struk yang masih menyisakan piutang kini mencetak rekening transfer toko,
jadi pelanggan tahu ke mana melunasi sisanya tanpa kasir menulis tangan.

### Ditambahkan

- **Struk nota (1.12):** nota kredit yang masih menyisakan piutang
  mencetak *Transfer ke: {rekening}* setelah *Piutang* / *Jatuh tempo*,
  di struk baru maupun cetak ulang dari Riwayat (1.14). Rekening diambil
  dari Pengaturan › *Penjualan & stok* › *Rekening transfer* (F1-05c).
- **Kuitansi pembayaran piutang (1.20b):** bila *Sisa piutang* tercetak
  dan masih lebih dari 0, kuitansi thermal mencetak baris yang sama dan
  kuitansi A5 (PDF) menambah isian terakhir *Transfer sisa ke*. Label
  ini sengaja menyebut *sisa* agar tidak terbaca sebagai tujuan
  pembayaran tunai di kuitansi itu.
- Panduan *Penjualan kredit*, *Pelanggan & piutang*, dan *Pengaturan
  toko* (ID + EN).

### Diubah

- Rekening panjang (maks 100 karakter) dibungkus rata kiri tanpa nilai
  kanan, seperti referensi transfer F1-05b, agar tidak terbaca sebagai
  nominal di kertas 58 mm. Spasi dan baris baru di rekening dirapikan.

### Catatan teknis

- `ReceiptConfig.transferAccount` (`lakuna_data`) diisi
  `loadReceiptConfig` dari `loadSalesRules`, sehingga Kasir, Meja,
  Riwayat, dan Pelanggan mendapat rekening tanpa mengubah repositori.
- Helper `receiptTransferLine` di `receipt_content.dart`; l10n
  `receiptTransferTo` dan `kuitansiBalanceTransferTo`.
- Baris tidak dicetak untuk nota lunas, nota tanpa pelanggan, nota void
  atau diretur penuh,
  kuitansi batal, opsi *Tampilkan sisa piutang* mati, sisa 0, atau
  rekening kosong. Tes data, unit struk, dan unit kuitansi thermal/A5.

## [0.78.0] - 2026-11-14

Dialog *Produk diarsipkan* kini menunjukkan kapan tiap produk diarsipkan,
dan nyaman dibaca di ponsel.

### Ditambahkan

- **Daftar produk (1.15) › Diarsipkan:** tiap produk menampilkan
  *Diarsipkan {tanggal}* di zona waktu cabang, mis. *Sembako · Stok 24
  botol · Diarsipkan 14 November 2026*.
- Panduan *Menambah produk pertama* bagian *Mengarsipkan produk* (ID + EN).

### Diperbaiki

- **Ponsel:** di dialog *Produk diarsipkan* tombol *Pulihkan* di samping
  teks membuat nama produk terlipat per huruf (baris setinggi ±480 px) dan
  tombol *Tutup* bisa terdorong keluar layar. Kini tombol turun ke bawah
  teks pada dialog sempit dan daftar menyusut lalu digulir.

### Catatan teknis

- `CatalogRepository.archived()` mengembalikan `ArchivedCatalog`
  (`products` + `timezone` dari outlet, lalu tenant);
  `ArchivedProductsViewModel.timezone`; l10n `productsArchivedOn`.
- Tes VM (zona dimuat) dan widget 1280/360 (tanggal 20.00 UTC → 14 November
  WIB, tinggi baris < 200 px, tanpa overflow).

## [0.77.0] - 2026-11-14

Nomor HP pelanggan dan supplier kini bisa dicari seperti tertulis di
WhatsApp, misalnya `+62 812-3456-7890`, di semua kolom cari.

### Ditambahkan

- **Cari HP format apa pun** di Riwayat (1.14), Pelanggan (1.20),
  Supplier (1.21), pilih pelanggan di Kasir (1.4b), *Kredit* (1.5b), dan
  bill Meja. Spasi, tanda hubung, kurung, dan awalan `+62` diabaikan;
  potongan di tengah nomor (minimal 3 angka) tetap cocok. Nomor yang
  disalin dari WhatsApp (dengan tanda arah tak terlihat dan tanda hubung
  khusus) juga cocok.
- Panduan *Pelanggan & kredit* dan *Retur & void* (ID + EN).

### Diubah

- Kata kunci yang memuat huruf (nama, nomor nota) tidak lagi dicocokkan
  ke nomor HP, sehingga mis. `Toko 123` tidak memunculkan pelanggan yang
  HP-nya memuat `123`.
- Pilih pelanggan di Kasir, bill Meja, dan *Kredit* mencocokkan HP mulai 3
  angka (sebelumnya 1 karakter), sama dengan layar Pelanggan.
- Layar Pelanggan/Supplier: `62857` (tanpa `+`, kurang dari 10 angka)
  kini dianggap potongan tengah apa adanya, bukan `0857`; ketik
  `+62 857` atau `0857`.

### Diperbaiki

- Pilih pelanggan di Kasir dan bill Meja: `+62 812…` tidak menemukan
  pelanggan karena `62812…` dibandingkan dengan HP tersimpan `0812…`.
- *Kredit* (1.5b): nomor dengan spasi atau tanda hubung tidak menemukan
  pelanggan karena teks dibandingkan apa adanya.
- Riwayat: pencarian HP hanya cocok bila diketik persis seperti tersimpan.
- Layar Pelanggan/Supplier: potongan tengah nomor yang berawalan 8 (mis.
  `8194` dari `0819-4545`) tidak cocok karena kata kunci diberi nol di
  depan.

### Catatan teknis

- `lakuna_domain`: `phoneSearchKeys` (digit apa adanya, atau hanya `0…`
  untuk nomor internasional `+62…` / `62…` ≥ 10 digit; `62` di tengah
  tidak diubah; tanda arah U+200E/F, U+202A–E, U+2066–9, U+FEFF dibuang,
  tanda hubung U+2010–2015/U+2212 jadi `-`) dan `phoneMatchesQuery`;
  `phoneQueryMinDigits = 3`.
- Review sebelum rilis menemukan dan memperbaiki: nomor salinan WhatsApp
  tidak menghasilkan kunci, dan kunci `62…` mentah ikut dipakai untuk
  `+62…` sehingga cocok palsu di tengah nomor lain.
- `_searchSales` menambah `phone ilike` per kunci HP lalu mengecek ulang di
  Dart; view model Pelanggan, Supplier, Kasir (`customerCandidates`,
  `creditCandidates`), dan Meja memakai `phoneMatchesQuery`.
- Tes domain (format, potongan tengah, huruf, terlalu pendek, `62` di
  tengah), data Riwayat, dan view model untuk semua kolom cari.

## [0.76.0] - 2026-11-14

Pembeli yang membayar sebagian tunai dan sisanya transfer kini juga
melihat rekening toko, tanpa kasir perlu menghafal nomornya.

### Ditambahkan

- **Layar bayar (1.5) › Bagi beberapa metode:** saat metode *Transfer
  bank* dipilih untuk bagian baru dan *Rekening transfer* diisi di
  Pengaturan, kotak *Transfer ke* dengan tombol **Salin** tampil di antara
  isian *Nominal* dan *Referensi transfer*. Berlaku di Kasir, bill
  Meja/take away, dan bayar per bagian split bill.
- Panduan *Split payment* (ID + EN).

### Catatan teknis

- `SplitPanel` memakai ulang `TransferAccountBox` dari F1-05c; tidak ada
  perubahan data, view model, atau l10n.
- Tes widget alur kasir 1280 dan 360 px: kotak hanya untuk transfer, berisi
  rekening, hilang setelah bagian ditambah, tanpa overflow.

## [0.75.0] - 2026-11-14

Pemilik yang lupa menekan *Backup sekarang* tetap punya titik pulih: di
komputer kasir, Lakuna kini membuat backup sendiri sekali sehari dan
menyimpan tujuh backup terakhir.

### Ditambahkan

- **Backup otomatis harian (desktop: Windows, Linux, macOS).** Pemeriksaan
  pertama dua menit setelah aplikasi dibuka lalu setiap jam; backup dibuat
  bila backup otomatis terakhir lebih dari 24 jam lalu atau belum pernah.
  Berjalan tanpa staf masuk (juga di layar PIN). Berkas disimpan di
  `Dokumen/Lakuna/Backup/Otomatis/` dengan nama yang sama dengan backup
  manual; hanya 7 berkas terbaru di folder itu yang disimpan. Backup manual
  tidak pernah dihapus.
- **Pengaturan (1.13 / 1.26) › Data & backup:** kartu *Backup otomatis*
  dengan sakelar *Backup otomatis harian* (bawaan menyala, butuh izin
  *Backup & pulihkan*), lokasi folder, *Backup otomatis terakhir* (hari
  ini / N hari lalu / belum ada), dan peringatan bila percobaan terakhir
  gagal. Kartu tidak tampil di ponsel dan tablet.
- Panduan *Backup & pulihkan* bagian *Backup otomatis harian* (ID + EN).

### Diubah

- Backup otomatis yang berhasil juga mengisi *Backup terakhir*, sehingga
  pengingat Beranda (> 7 hari) tidak muncul selama backup otomatis jalan.
- Saat aplikasi ditutup, penutupan database menunggu backup otomatis yang
  sedang berjalan selesai.

### Keamanan

- Backup otomatis tidak dikunci kata sandi (kata sandi tidak disimpan di
  perangkat). Keterangan sakelar menyebut bahwa salinan ikut tersimpan di
  awan bila folder *Dokumen* disinkronkan (OneDrive, iCloud Drive), agar
  pemilik bisa mematikannya dan memakai backup terkunci.

### Catatan teknis

- `BackupRepository`: `autoBackup()`, `setAutoBackup(bool)`,
  `runAutoBackup(Directory)`; preferensi lokal `backup.auto`,
  `backup.autoLastAt`, `backup.autoFailed`. Backup dibuat di folder
  sementara khusus otomatis (salinan backup manual yang mungkin masih
  dibagikan tidak terhapus), disalin ke `<nama>.zip.part` lalu diganti
  nama, sehingga berkas setengah jadi (disk penuh, aplikasi ditutup) tidak
  pernah tampak sebagai backup sah. Pemangkasan berjalan hanya setelah
  berhasil dan mengurutkan menurut cap waktu di akhir nama, bukan nama
  penuh (kode cabang yang berganti tidak membuat backup baru terhapus).
- `AutoBackupScheduler` (`lib/data/services/auto_backup.dart`): tidak
  menumpuk bila pemeriksaan tumpang tindih; galat apa pun (termasuk
  `Error`) dicatat sebagai gagal, tidak lolos ke zona aplikasi; waktu
  terakhir di masa depan (jam perangkat dimundurkan) dianggap jatuh tempo;
  `dispose()` async menunggu backup yang sedang berjalan.
- Review menemukan dan memperbaiki sebelum rilis: salinan langsung ke nama
  akhir (berkas rusak bisa ikut dihitung 7 terakhir), pangkas urut nama
  penuh (kode cabang "ZZZ" lama mendahului backup baru), `close` tidak
  menunggu backup berjalan, dan hitungan hari negatif setelah jam
  dimundurkan.
- Tes baru: repositori dengan SQLite sungguhan (jalan tanpa staf, pangkas,
  pangkas lintas kode cabang, `.part` dibuang, gagal lalu pulih, izin
  sakelar), penjadwal (jatuh tempo, mati, gagal lalu ulang, tumpang tindih,
  jam mundur, `StateError`, `dispose` menunggu, Timer dengan waktu palsu),
  view model, dan widget 1440/360.
- Gap tercatat di spec F1-19d: backup otomatis di ponsel, backup otomatis
  terkunci, isolate terpisah untuk zip, preferensi ikut pulihkan.

## [0.74.0] - 2026-11-14

Kasir tidak perlu lagi menghafal nomor rekening toko: rekening transfer
diatur sekali di Pengaturan dan tampil di layar bayar, siap disalin untuk
pembeli.

### Ditambahkan

- **Pengaturan (1.26) › Penjualan & stok:** isian *Rekening transfer*
  (opsional, satu baris, maks 100 karakter, per cabang), mis.
  `BCA 123-456-7890 a.n. Warung Contoh`.
- **Layar bayar (1.5):** tombol *Transfer bank* menampilkan rekening
  menggantikan *Cek mutasi dulu* (layar lebar). Panel transfer menampilkan
  kotak *Transfer ke* dengan tombol **Salin**; label berubah menjadi
  *Disalin* setelah disalin. Berlaku di Kasir, bill Meja/take away, dan
  bayar per bagian split bill.
- Panduan *Pembayaran tunai* dan *Pengaturan toko* (ID + EN).

### Diubah

- Kunci pengaturan `sales.rules` kini menyimpan `transferAccount`. Data
  lama tanpa kunci ini dibaca sebagai kosong.

### Catatan teknis

- `SalesRules.transferAccount` (dipangkas; nilai tersimpan dibatasi 100
  karakter saat dibaca agar data lama/rusak tidak membuat simpan aturan
  lain gagal). `ProfileLimits.transferAccount = 100`.
- `saveSalesRules` memangkas dan menolak lebih dari 100 karakter dengan
  `SalesRulesInvalid` (sebuah `Exception`, jadi tampil sebagai galat
  simpan, bukan galat tak tertangkap).
- `StoreSettingsViewModel.setTransferAccount`; `rulesDirty` membandingkan
  teks yang sudah dipangkas; isian diisi ulang hanya bila teks dipangkas,
  sehingga isian kartu lain tidak kehilangan fokus.
- `TransferAccountBox` (`Clipboard.setData`) memakai `Wrap`, jadi di
  ponsel tombol salin turun ke baris berikutnya tanpa memotong rekening.
- Tes: domain (JSON lama, pangkas, batas), data (simpan/pangkas/tolak),
  VM dan widget Pengaturan, layar bayar Kasir 1280/360 (clipboard), dan
  bayar bill Meja lewat transfer.

## [0.73.0] - 2026-11-14

Di open bill F&B, staf yang memberi diskon kini tercatat walau bill ditutup
kasir lain, jadi pemilik bisa melihat siapa yang memberi potongan di
Riwayat.

### Ditambahkan

- **Riwayat (1.14):** rincian nota menampilkan baris *Diskon manual*
  (jumlah diskon baris + diskon nota). Bila pemberi atau penyetuju
  tercatat, labelnya *Diskon manual · disetujui Nama*.
- Panduan *Diskon* (ID + EN) menjelaskan pencatatan pemberi diskon.

### Diubah

- **Meja (1.7):** staf berizin *Diskon manual* yang menerapkan diskon nota
  atau diskon baris kini dicatat sebagai pemberi. Label di panel bill dan
  ringkasan pembayaran (1.5) menjadi mis. *Diskon nota 10% · disetujui
  Rina*. Persetujuan PIN manajer tetap mencatat penyetujunya.
- Kasir retail tidak berubah: staf nota adalah pemberi diskon.

### Diperbaiki

- Sebelumnya diskon dari pelayan/manajer berizin di open bill tidak
  meninggalkan jejak: `discount_approved_by` kosong dan nota hanya
  menunjukkan kasir penutup, sehingga diskon tampak diberikan kasir itu.

### Catatan teknis

- `open_bill.dart`: helper `_discountGiver` (`requireDiscountActor(...) ??
  staffId`) dipakai `setBillDiscount` dan `setBillItemDiscount`. Aturan
  lain tetap: pemberi terakhir menggantikan yang lama, hapus semua diskon
  mengosongkan kolom.
- `history.dart`: `SaleDetail.discountApprovedByName` dan
  `SaleDetail.manualDiscount`; `loadSaleDetail` ikut mencari nama
  `discount_approved_by`.
- Tes data: pemberi berizin tercatat walau bill ditutup staf lain, detail
  nota tanpa diskon; tes widget Riwayat 1280/360 (dengan dan tanpa
  pemberi) serta label pemberi sendiri di panel bill dan pembayaran.
- Palsu `FakeDiningRepository` mengikuti aturan baru (pemberi berizin
  dicatat, nama staf sesungguhnya).

## [0.72.0] - 2026-11-14

Foto dari kamera ponsel tidak lagi menyimpan lokasi GPS, waktu, atau model
ponsel di folder media Lakuna, jadi data itu tidak ikut ke backup atau ke
sinkronisasi Fase 2.

### Keamanan

- **Semua gambar yang disimpan dibersihkan dari metadata:** foto produk
  (1.16), foto faktur pembelian (1.19), foto nota pengeluaran, bukti bayar
  supplier, stiker QRIS dan logo struk (1.26), serta gambar denah (1.17c).
  Sebelumnya hanya foto yang dikecilkan (v0.62.0) yang bersih; foto kecil
  (≤ 512 KB), stiker QRIS, logo, dan denah disimpan apa adanya beserta
  Exif GPS-nya.
- Pembersihan memakai daftar izin per format, jadi metadata jenis baru
  ikut terbuang: Exif, XMP, IPTC/Photoshop, komentar JPEG, kredensial
  konten C2PA/JUMBF, telemetri GPS kamera aksi, chunk teks/waktu PNG,
  chunk privat vendor, serta gambar tambahan (peta kedalaman, gambar
  kedua) setelah akhir gambar.

### Diubah

- Gambar dibersihkan tanpa didekode ulang: kualitas foto, ketajaman kode
  QR, dan garis denah tidak berubah. Profil warna (ICC, sRGB, Adobe) dan
  animasi APNG/WebP tetap.
- Foto ponsel yang diputar tetap tegak: bila Exif asli menyatakan
  orientasi selain 1, berkas hasil membawa Exif minimal yang hanya berisi
  tag Orientation.
- Ukuran berkas di folder `media/` sedikit lebih kecil untuk foto kamera.
- Panduan *Pertanyaan umum* (ID + EN) menjelaskan bahwa lokasi foto tidak
  disimpan.

### Catatan teknis

- `stripImageMetadata` baru di `lakuna_domain` (murni Dart, tanpa
  dekode): JPEG (segmen APP0, APP2 ICC_PROFILE, APP14 Adobe, dan segmen
  non-APP saja; pindai data scan termasuk JPEG progresif, isian FF 00/FF FF,
  dan restart), PNG (chunk kritis, warna, transparansi, pHYs, APNG; CRC
  chunk `eXIf` minimal dihitung dengan `hashlib`), WebP (VP8X, ICCP, ANIM,
  ANMF, ALPH, VP8, VP8L; bit EXIF/XMP VP8X, bantalan chunk ganjil, ukuran
  RIFF). Berkas yang tidak bisa diurai sampai akhir dikembalikan apa
  adanya.
- Orientasi dibaca dengan aturan yang sama dengan `readImageHeader` (Exif
  sah pertama sebelum SOF) lewat `tiffOrientation` yang dipisahkan dari
  pembaca header, jadi lebar/tinggi yang tercatat tetap cocok dengan
  berkas.
- `storeMediaFile` membersihkan gambar sebelum menghitung SHA-256 dan
  ukuran; semua pemanggil (produk, pembelian, pengeluaran, supplier, QRIS,
  logo struk, denah) ikut terlindungi tanpa perubahan.
- Tes: domain (JPEG dengan Exif/XMP/IPTC/MPF/COM/C2PA/data setelah EOI,
  orientasi big/little-endian, Exif setelah SOF diabaikan, JPEG progresif,
  PNG teks/eXIf/C2PA/chunk privat, WebP EXIF/XMP/C2PA/chunk ganjil, berkas
  terpotong dan diacak tidak melempar galat) dan data (foto produk kecil
  ber-GPS tersimpan bersih dengan piksel sama, stiker QRIS berorientasi 6
  tetap terbaca 48 × 64).
- Gambar lama yang sudah tersimpan tidak diubah (dicatat sebagai gap).

## [0.71.0] - 2026-11-14

Import produk dengan sakelar *Perbarui harga produk yang sudah ada* kini
menampilkan daftar perubahan harga lebih dulu. Pemilik melihat harga lama
dan baru tiap produk, lalu baru menekan *Simpan*.

### Ditambahkan

- **Produk (1.15), dialog *Import produk*:** bila sakelar perbarui harga
  menyala, tombol utama menjadi **Lihat perubahan**. Tombol ini menjalankan
  import tanpa menyimpan apa pun dan menampilkan ringkasan *N produk baru ·
  M diperbarui · K tidak berubah · L dilewati*, daftar perubahan
  (*Nama (varian) · Rp lama → Rp baru*, dengan baris kecil untuk harga beli
  dan stok minimum beserta satuannya bila ikut berubah; paling banyak 30
  baris lalu *dan X perubahan lainnya*), serta nomor baris yang dilewati
  karena cocoknya ragu. Varian yang hanya berubah harga beli atau stok
  minimumnya ditampilkan tanpa panah harga jual.
- Setelah pratinjau, tombol utama menjadi **Simpan** dan menjalankan import
  sungguhan. Bila tidak ada yang berubah dan tidak ada produk baru, *Simpan*
  nonaktif.

### Diubah

- Mengganti berkas atau menyalakan/mematikan sakelar menghapus pratinjau,
  sehingga perubahan harus dilihat lagi sebelum disimpan.
- Selama berkas dipilih atau pratinjau dihitung, tombol pilih berkas,
  sakelar, dan tutup dialog nonaktif; berkas yang dipilih di tengah
  pratinjau tidak menggantikan hasilnya. Pratinjau yang gagal menampilkan
  pesan dan bisa diulang.
- Dengan sakelar mati, alur import tetap seperti sebelumnya (langsung
  *Import N produk*).
- Panduan *Produk pertama* (ID + EN) menjelaskan langkah *Lihat perubahan*
  lalu *Simpan*.

### Catatan teknis

- `importProducts(..., dryRun:)` di `lakuna_data` menjalankan aturan
  pencocokan F1-07k yang sama di dalam transaksi tanpa satu pun tulisan
  (tanpa cap HLC, tanpa outbox); produk baru hanya dihitung, tetapi nama,
  SKU, dan barcode-nya tetap dicatat agar baris kembar di berkas dilewati
  sama persis dengan import sungguhan.
- `ProductImportSummary.changes` (`List<ProductPriceChange>`): baris, nama
  produk, nama varian, harga jual lama/baru, serta harga beli dan stok
  minimum lama/baru hanya bila berubah, plus nama satuan dasar. Selisih kini dihitung di loop
  import; `_ProductWriter.updatePrices` diganti `updateVariant`.
- `CatalogRepository.importRows(..., dryRun:)` (lokal + palsu).
- `ProductImportViewModel.preview` (`Command0`), `previewed`,
  `needsPreview`, `canPreview`; `canRun` dengan sakelar menyala menunggu
  pratinjau yang punya perubahan.
- Kunci l10n baru (ID + EN): `productImportPreview`,
  `productImportPreviewSummary`, `productImportPreviewMore`,
  `productImportPreviewCost`, `productImportPreviewMinStock`,
  `productImportPreviewNone`, `productImportPreviewNote`,
  `productImportSave`.
- Tes: data (dry run tidak menulis produk, stok awal, outbox, maupun cap
  HLC; hitungan dan isi daftar perubahan sama dengan import sungguhan; dry
  run tanpa sakelar), repositori lokal, view model (pratinjau wajib,
  pratinjau dihapus oleh sakelar/berkas baru, terkunci selama berjalan,
  gagal lalu diulang, simpan nonaktif tanpa perubahan, plural EN), dan
  widget 1280/360 (pratinjau lalu simpan, galat pratinjau, stok minimum
  dengan satuan, daftar dipotong 30 baris).
- Batasan tercatat di spec: galat penulis produk baru (kategori, satuan,
  stok awal) baru terlihat saat *Simpan*, karena dry run tidak menjalankan
  penulis itu.

## [0.70.0] - 2026-11-14

Peringatan uang di laci tidak cukup (v0.69.0) kini juga muncul di dua
dialog yang mengurangi laci tanpa mengetik jumlah: void nota tunai dan
batal pembayaran piutang tunai.

### Ditambahkan

- **Riwayat (1.14), dialog *Void nota*:** bila uang tunai nota yang
  diterima di sesi yang sedang buka (dikurangi kembalian) lebih besar dari
  perkiraan uang di laci, dialog menampilkan peringatan. Nota QRIS/kartu
  tidak diperingatkan.
- **Pelanggan (1.20), dialog *Batal pembayaran*:** batal pembayaran piutang
  yang diterima tunai memberi peringatan bila jumlahnya melebihi perkiraan
  uang di laci. Batal bayar hutang supplier mengembalikan uang ke laci,
  jadi tanpa peringatan.
- Panduan *Sesi kasir & kas laci* (id/en) menyebut kedua dialog.

### Diubah

- Teks peringatan kini berakhir *"…pastikan uangnya ada sebelum
  melanjutkan."* (sebelumnya *sebelum menyimpan*) agar cocok di form dan
  dialog.
- Panel pelanggan memuat ulang status sesi kasir dan perkiraan uang laci
  setiap kali dimuat (setelah terima atau batal pembayaran); bila gagal,
  data lama dipakai.

### Catatan teknis

- `saleCashInSession(payments, sessionId, saleSessionId:)` di
  `lakuna_data`: tunai lunas bersih kembalian di sesi itu, pembayaran lama
  tanpa sesi ikut sesi nota, pembayaran terhapus diabaikan. Tes data
  memastikan penurunan *Kas seharusnya* saat void sama dengan nilainya.
- `HistoryData.openSessionId`, `HistoryViewModel.voidDrawerShortfall`,
  `SaleVoidDialog(drawerCash:, drawerShortfall:)`;
  `CustomersSetup.drawerCash`, `showDebtPaymentVoidDialog(drawerCash:)`.
- Tes VM (nota sesi ini/sesi lain/QRIS, muat ulang panel pelanggan) dan
  widget (dialog void nota, dialog batal piutang 1280 dan 360 px).

## [0.69.0] - 2026-11-14

Setiap uang yang keluar dari laci kini diperiksa terhadap perkiraan uang di
laci, sehingga kasir diperingatkan sebelum *Kas seharusnya* menjadi minus.

### Ditambahkan

- **Peringatan uang di laci tidak cukup** (ikon segitiga) bila jumlah yang
  keluar lebih besar dari *Kas seharusnya* sesi yang terbuka: *"Uang di
  laci diperkirakan Rp X. Jumlah ini lebih Rp Y dari perkiraan; pastikan
  uangnya ada sebelum menyimpan."* Muncul di:
  - **Sesi kasir (1.3):** tab *Uang keluar*;
  - **Riwayat (1.14):** retur dengan uang kembali *Tunai* (setelah
    potongan piutang);
  - **Pengeluaran (1.22):** sumber dana *Kas laci*;
  - **Supplier (1.21):** bayar hutang dari *Kas laci*;
  - **Pembelian (1.20):** dibayar dari *Kas laci* saat terima barang.
- Peringatan tidak memblokir simpan: isi laci nyata bisa berbeda dengan
  perkiraan, dan selisihnya terlihat saat tutup sesi.
- Panduan *Sesi kasir & kas laci* (id/en) menjelaskan peringatan ini.

### Diperbaiki

- Riwayat memuat ulang status sesi kasir dan perkiraan uang laci setelah
  retur, void, dan muat ulang, jadi retur kedua memakai saldo setelah
  retur pertama dan sesi yang baru ditutup tidak lagi menawarkan *Tunai*.

### Catatan teknis

- Domain `drawerShortfallOf(amount, drawerCash)`; data
  `openDrawerCash(store, scope)` = *Kas seharusnya* sesi terbuka atau
  `null`.
- `HistoryData`, `ExpensesSetup`, `SuppliersSetup`, `PurchaseSetup`
  mendapat `Money? drawerCash`; `hasOpenSession` kini diturunkan darinya.
- Widget bersama `DrawerShortfallNote` (`ui/core/drawer_shortfall_note.dart`,
  kunci `<prefix>-drawer-short`), kunci l10n `drawerShortfallWarning`.
- Tes domain, data (setelah uang keluar dan setelah penjualan + retur
  tunai), VM kelima layar, dan widget (Sesi kasir 360 px, retur,
  pengeluaran, supplier, pembelian).
- Belum diperingatkan (gap): void pembayaran piutang tunai dan void nota
  tunai sesi berjalan.

## [0.68.0] - 2026-11-14

Riwayat transaksi kini bisa difilter dengan rentang tanggal bebas, memakai
dialog yang sama dengan Laporan, sehingga semua nota satu tanggal lama atau
satu bulan bisa dilihat dan diekspor sekaligus.

### Ditambahkan

- **Riwayat (1.14):** pill keempat *Rentang tanggal…* setelah *7 hari*
  membuka dialog *Pilih rentang tanggal* (Dari / Sampai). Setelah
  *Terapkan*, pill menampilkan rentangnya (mis. *4 Nov 2026*) dan daftar
  memuat nota dengan tanggal lokal cabang di rentang itu.
- Validasi sama dengan Laporan: akhir tidak sebelum awal, tidak melewati
  hari ini, paling panjang 366 hari. Memilih rentang mengosongkan kolom
  cari; filter Kasir, Metode, Status tetap berlaku.
- Ringkasan *4 Nov 2026 · 9 transaksi · Rp …*, kolom Jam bertanggal, dan
  ekspor Excel `riwayat-<yyyymmdd>-<yyyymmdd>-<tanggal>.xlsx`.
- Panduan *Retur & void* (id/en) menyebut rentang tanggal.

### Diubah

- Dialog rentang tanggal Laporan (F1-16b) dipindah ke komponen bersama
  `ui/core/date_range_dialog.dart` (`showDateRangeDialog`, kunci widget
  ber-prefix). Perilaku Laporan tidak berubah.

### Catatan teknis

- `HistoryRange.custom`, `HistoryFilter.days` (tanggal kalender,
  inklusif) dan `historyRangeBounds(..., days:)`: awal hari lokal dihitung
  dari awal hari ini cabang dikurangi selisih tanggal.
- `HistoryViewModel.today`, `initialRange`, `setCustomRange`;
  `historyRangeLabel(..., days:)` memakai `reportRangeLabel`.
- Tes data (satu tanggal lama, dua hari melintasi tengah malam WIB,
  batas UTC, filter status), VM (rentang, cari dikosongkan, nama berkas),
  dan widget (batal, terapkan).

## [0.67.0] - 2026-11-14

Laporan kini bisa dibuka untuk rentang tanggal bebas, mis. 1–15 November
atau satu minggu promo, selain Hari ini, 7 hari terakhir, dan per bulan.

### Ditambahkan

- **Laporan (1.23 / 1.24):** entri *Rentang tanggal…* di pilihan Periode
  (setelah *Bulan ini*) membuka dialog *Pilih rentang tanggal* dengan
  kalender **Dari** dan **Sampai**, tombol *Batal* dan *Terapkan*.
- Validasi rentang: tanggal akhir tidak boleh sebelum tanggal awal, tidak
  boleh melewati hari ini (tanggal cabang), dan paling panjang 366 hari;
  *Terapkan* nonaktif selama ada galat.
- Label rentang ringkas di pilihan, subjudul, judul laba rugi, PDF, dan
  Excel: *5 Nov 2026*, *1–15 Nov 2026*, *28 Okt – 3 Nov 2026*,
  *28 Des 2025 – 3 Jan 2026* (en: *Nov 1–15, 2026*, dst.).
- Pembanding laba bersih dan KPI: jumlah hari yang sama tepat sebelum
  awal rentang (*14 hari sebelumnya*).
- Nama berkas unduhan memuat tanggal, mis.
  `laporan-laba-rugi-20261101-20261114-261114.pdf`.
- Panduan *Laporan* (id/en) menjelaskan rentang tanggal.

### Catatan teknis

- Domain: `ReportPeriodKind.custom`, `ReportPeriod.custom(from, to)`
  (jam diabaikan), `days`, `previousRange` = `days` hari sebelum `from`,
  `fileKey` `yyyymmdd-yyyymmdd`; `reportRangeError` →
  `ReportRangeError.endBeforeStart / future / tooLong`,
  `maxReportRangeDays` = 366. Lapisan data tidak berubah karena semua
  query sudah memakai `range` / `previousRange`.
- Flutter: `reportRangeLabel`, `showReportRangeDialog`
  (`FDateField.calendar`), `ReportsViewModel.periods` menyisipkan rentang
  aktif setelah *Bulan ini*, `ReportsViewModel.today`; pilihan Periode
  dibangun ulang setelah dialog ditutup agar *Batal* kembali ke periode
  aktif.
- Kunci l10n baru `reportsPeriodCustom`, `reportsRangeTitle`,
  `reportsRangeFrom`, `reportsRangeTo`, `reportsRangeCancel`,
  `reportsRangeApply`, `reportsRangeErrOrder`, `reportsRangeErrFuture`,
  `reportsRangeErrTooLong`, `reportsPrevDays` (id/en).
- Tes domain (rentang, pembanding lintas bulan/tahun, kesetaraan,
  validasi 366/367 hari), label id/en, VM, dan widget (pilih, galat,
  batal, terapkan). Tes widget mengabaikan luapan kepala kalender Forui
  yang hanya muncul dengan font uji selama kalender terbuka.

## [0.66.0] - 2026-11-14

Riwayat transaksi kini punya kolom cari. Nota bisa ditemukan lewat nomor,
nama pelanggan atau pemesan, nomor HP pelanggan, atau no. approval kartu /
referensi transfer, termasuk nota yang lebih lama dari 7 hari.

### Ditambahkan

- **Riwayat (1.14):** kolom *Cari no. nota, pelanggan, atau referensi* di
  atas filter tanggal. Pencarian tanpa beda huruf besar/kecil dan cocok
  bila kata kunci termuat di nomor nota, nama pelanggan di nota (termasuk
  nama pemesan bill F&B tanpa data pelanggan), nama atau HP data
  pelanggan, atau referensi pembayaran lunas (F1-05b).
- Selama mencari, semua tanggal dijangkau dan tidak ada pill tanggal yang
  terpilih; filter Kasir, Metode, dan Status tetap berlaku. Mengetuk pill
  tanggal mengosongkan kolom cari.
- Ringkasan *Hasil pencarian · N transaksi · Rp X*, kolom Jam selalu
  bertanggal, pesan *Tidak ada nota yang cocok dengan pencarian.*, dan
  catatan *Menampilkan 100 nota terbaru…* bila hasil lebih dari 100.
- Ekspor Excel hasil pencarian bernama `riwayat-cari-<tanggal>.xlsx`.
- Panduan *Retur & void* (id/en) menjelaskan pencarian nota.

### Diperbaiki

- Nama pemesan bill F&B yang tidak terhubung ke data pelanggan ikut
  dicari (ditemukan saat review).
- Kata kunci yang cocok dengan semua nota (mis. kode outlet `PST`) tidak
  lagi membaca seluruh nota cabang setiap ketikan: nota dibaca per
  kelompok 200 dan berhenti setelah 100 hasil (ditemukan saat review).
- Menambah spasi di ujung kata kunci tidak memuat ulang daftar, dan kolom
  tanggal mengikuti hasil yang sedang tampil saat daftar dimuat ulang.

### Catatan teknis

- `HistoryFilter.query` / `trimmedQuery` / `searching`,
  `HistoryPage.searching` / `truncated`, `historySearchLimit` (100), dan
  parameter `searchLimit` / `searchBatch` pada `listSalesHistory`.
- `_searchSales`: kandidat `customers.name/phone` dan `payments.reference`
  lewat `ilike` (SQLite `LIKE`), lalu nota cabang dengan
  `number`/`customer_name` `ilike` atau `customer_id`/`id` di kandidat,
  filter status dan kasir di SQL, urut `sold_at` turun, `limit`/`offset`
  per kelompok; semua dicek ulang di Dart agar `%`/`_` bukan wildcard.
- `HistoryViewModel.setQuery`, `setRange` (mengosongkan cari), dan
  `searchGeneration` sebagai kunci kolom cari.
- Kunci l10n baru `historySearchHint`, `historySearchSummary`,
  `historySearchTruncated`, `historySearchEmpty` (id/en).
- Tes data (nomor, pelanggan, HP, referensi, pemesan F&B, bill `OB-`,
  kasir, metode, status, wildcard, batas, kelompok kecil), VM, dan widget
  (desktop dan 360 px).

## [0.65.0] - 2026-11-14

Baris open bill berdiskon rupiah kini bisa dibagi ke beberapa tamu saat
split bill per item. Potongan dibagi sebanding jumlah sehingga total bill
dan total potongan tidak berubah.

### Diubah

- **Split bill per item (1.26):** baris berdiskon rupiah tidak lagi
  ditolak. Porsi yang pindah membawa potongan sebanding jumlahnya
  (dibulatkan setengah ke atas), sisanya tetap di baris asal. Contoh:
  Rp 1.000 untuk 3 porsi menjadi Rp 333 + Rp 334 + Rp 333; Es Teh ×3
  diskon Rp 1.000 dibagi dua tamu menjadi Rp 4.834 dan Rp 4.832.
- Potongan tiap porsi tidak pernah melebihi total porsinya dan tidak
  pernah negatif.
- Batal split dan memindahkan porsi kembali menggabungkan potongan ke
  baris asal, jadi diskon rupiah semula pulih utuh.
- Panduan *Diskon* (id/en) menjelaskan pembagian diskon rupiah.

### Diperbaiki

- Porsi diskon rupiah yang potongannya menjadi Rp 0 karena pembulatan
  (mis. Rp 1 untuk 3 porsi) tetap digabung kembali ke baris asal dan ke
  satu baris di struk/tiket, tidak tertinggal sebagai baris terpisah
  (ditemukan saat review).

### Dihapus

- Galat `BillItemDiscounted` dan pesan *Hapus atau ubah diskon rupiah
  item ini ke persen sebelum dibagi.* (kunci l10n
  `billSplitErrorItemDiscounted`).

### Catatan teknis

- `_moveQuantity` di `split_bill.dart` menghitung potongan sisa lewat
  `_rupiahLeftCut`: potongan pindah = `round(cut × moved / total)`,
  dipangkas ke total kotor porsi pindah; potongan sisa dipangkas ke
  [0, total kotor sisa]. Diskon persen tetap memakai `discount.cut` pada
  sisa.
- Aturan gabung porsi: diskon non-persen (rupiah atau tanpa diskon)
  dianggap sama satu sama lain; persen hanya sama dengan persen yang
  sama. `mergeSplitPortions` di struk mengelompokkan per
  `(akar baris, discount_bp)`.
- Tes data baru: bagi genap, ganjil (333/334/333), hampir 100%, potongan
  Rp 0 tetap tergabung, rupiah tidak bergabung dengan persen, bayar bagian
  memakai potongan porsi. Tes struk: porsi rupiah (termasuk Rp 0) jadi
  satu baris.

## [0.64.0] - 2026-11-14

Nomor approval kartu dan referensi transfer kini bisa dicatat per bagian di
split payment dan tercetak di struk, sehingga struk mudah dicocokkan
dengan slip EDC atau mutasi rekening.

### Ditambahkan

- **Split payment (1.5):** saat metode bagian baru *Kartu debit / kredit*
  atau *Transfer bank*, muncul isian opsional *No. approval kartu* /
  *Referensi transfer* (maks. 40 karakter). Referensi tampil di bawah nama
  metode pada daftar bagian dan ikut tersimpan di pembayaran nota.
- **Struk:** di bawah baris pembayaran kartu/transfer yang punya
  referensi tercetak baris menjorok *No. approval 004512* /
  *Ref. transfer TRF-…*. Berlaku untuk bayar tunggal, split payment,
  bagian split bill F&B, pratinjau, PDF, dan cetak ulang dari Riwayat.
- Panduan *Split payment* dan *Pembayaran* (id/en) menjelaskan isian dan
  baris struk baru.

### Diperbaiki

- Referensi panjang (sampai 40 karakter) di kertas 58 mm dicetak rata kiri
  menyambung ke baris berikutnya, tidak dipecah rata kanan sehingga tidak
  terbaca sebagai nominal (ditemukan saat review).
- Pesan *Maksimal 40 karakter* di split tetap tampil walau nominal belum
  diisi (ditemukan saat review).

### Catatan teknis

- `SplitPart.reference`, `CashierViewModel.draftReference` /
  `setDraftReference` / `draftReferenceRevision` / `draftTakesReference`,
  dan `SplitDraftError.referenceTooLong`. Tunai dan QRIS tidak pernah
  membawa referensi walau isian sempat diketik.
- `SplitPanel` memakai controller sendiri untuk isian referensi dan
  membacanya ulang saat VM mengosongkannya (revisi naik) atau VM berganti;
  `setDraftReference` tidak memberi tahu pendengar bila nilainya sama agar
  tidak terjadi notifikasi saat build.
- `saleReceiptContent` hanya mencetak referensi untuk metode kartu dan
  transfer. Lapisan data tidak berubah (`payments.reference` sudah ada).
- Kunci l10n baru `receiptApproval`, `receiptTransferRef` (id/en).
- Tes: VM (referensi terkirim, terlalu panjang, tunai/QRIS tanpa
  referensi, isian kosong setelah tambah), alur kasir split kartu +
  transfer, struk id/en, dan tata letak 58 mm referensi 40 karakter.
- Uji manual Xvfb: split kartu Rp 20.000 (approval 004512) + transfer
  Rp 15.000 (TRF-1411-0093), struk menampilkan kedua referensi.
- Spec [F1-05b](docs/superpowers/specs/2026-11-14-f1-05b-referensi-split-struk-design.md).

## [0.63.0] - 2026-11-14

Foto nota pengeluaran dan foto bukti bayar hutang supplier yang dipotret
langsung dengan kamera ponsel kini bisa dipakai tanpa dikecilkan dulu:
Lakuna mengecilkannya otomatis sebelum disimpan, sama seperti foto faktur
pembelian di v0.62.0.

### Diubah

- **Foto nota pengeluaran (1.22) dan kas keluar (1.3b):** batas pilih naik
  dari 5 MB ke **20 MB**. Foto disimpan dengan sisi terpanjang paling
  banyak **2.000 px** (JPEG kualitas 85, atau PNG bila transparan) agar
  angka di nota tetap terbaca. Foto kecil (≤ 512 KB dan dalam batas sisi)
  disimpan apa adanya. Orientasi kamera diterapkan dan data EXIF (lokasi
  GPS, model ponsel) dibuang dari foto yang dikecilkan.
- **Foto bukti bayar hutang supplier (1.21):** aturan yang sama, batas
  pilih 20 MB dan simpan 2.000 px.
- Pesan galat foto nota dan foto bukti menyebut batas baru 20 MB (id/en).
- Panduan *Pengeluaran* dan *Hutang supplier* (id/en) menjelaskan foto
  besar dikecilkan otomatis.

### Diperbaiki

- Pratinjau foto 56 px di form pengeluaran, kas keluar, pembelian, dan
  bayar hutang kini didekode kecil (`cacheWidth`). Sebelumnya foto kamera
  besar didekode penuh hanya untuk pratinjau, yang untuk foto 48 MP bisa
  memakan sekitar 190 MB memori dan menutup aplikasi di ponsel murah
  (ditemukan saat review).

### Keamanan

- Foto nota dan bukti di atas 50 MP menurut header ditolak sebelum
  dibuka, sehingga berkas kecil yang mengaku berukuran raksasa tidak
  menghabiskan memori.

### Catatan teknis

- `ExpenseLimits.receiptInputMaxBytes` / `receiptMaxSide` dan
  `SupplierLimits.proofInputMaxBytes` / `proofMaxSide` baru di
  `lakuna_domain`; batas simpan `receiptMaxBytes` / `proofMaxBytes` tetap
  5 MB.
- `recordExpense` dan `paySupplierDebt` memanggil `shrinkPhoto` (isolate
  terpisah) setelah isian dan izin diperiksa, sebelum transaksi database.
  Gagal dekode, > 50 MP, atau hasil > 5 MB menjadi
  `ExpenseReceiptInvalid` / `SupplierPaymentProofInvalid`.
- Tes data: nota 2400×4000 tersimpan 1200×2000 JPEG, bukti 4000×2400
  tersimpan 2000×1200, berkas > 20 MB / > 50 MP / rusak ditolak tanpa
  menulis outbox. Tes VM: foto 12 MB diterima di form pengeluaran dan bayar
  hutang.
- Uji manual Xvfb: foto kamera 4000×3000 berukuran 12,5 MB tersimpan
  sebagai JPEG 2000×1500 (849 KB) di `media/`.
- Spec [F1-15b](docs/superpowers/specs/2026-11-14-f1-15b-kecilkan-foto-nota-design.md).

## [0.62.0] - 2026-11-14

Foto produk dan foto faktur dari galeri atau kamera ponsel (3–10 MB) kini
bisa dipakai langsung: Lakuna mengecilkannya otomatis sebelum disimpan,
jadi folder data dan berkas backup tetap ringan.

### Ditambahkan

- **Foto dikecilkan otomatis (1.16, 1.19, F1-07l).** Foto produk disimpan
  dengan sisi terpanjang paling banyak 1.024 px, foto faktur 2.000 px
  (tulisan faktur tetap terbaca), sebagai JPEG kualitas 85. Contoh uji
  manual: foto 5,9 MB 4.000 × 3.000 px tersimpan 180 KB 1.024 × 768 px.
  Gambar dengan latar transparan tetap PNG.
- Orientasi foto kamera (EXIF) diterapkan ke gambar, jadi foto tegak
  tetap tegak setelah dikecilkan.

### Diubah

- Batas pilih foto produk naik dari 2 MB ke **20 MB**, foto faktur dari
  5 MB ke **20 MB**. Teks petunjuk dan pesan galat di form ikut berubah.
  Batas berkas yang disimpan tetap 2 MB / 5 MB.
- Foto kecil (≤ 512 KB dan sudah di dalam batas sisi) disimpan apa adanya
  seperti sebelumnya.
- Panduan *Pembelian* (ID/EN): batas 20 MB dan pengecilan otomatis.

### Keamanan

- Foto yang dikecilkan tidak lagi membawa data EXIF (lokasi GPS, model
  ponsel).
- Gambar yang menyatakan lebih dari 50 MP ditolak sebelum didekode, agar
  berkas kecil berukuran piksel raksasa tidak menghabiskan memori ponsel.

### Catatan teknis

- Paket `image` (pure Dart, sudah ada di `pubspec.lock`) menjadi dependensi
  langsung `lakuna_data`. `shrinkPhoto` berjalan di `Isolate.run` sebelum
  transaksi database; animasi hanya bingkai pertama; galat apa pun di
  isolate dilaporkan sebagai *bukan gambar*.
- Review menemukan dan memperbaiki: tanpa batas piksel sebuah PNG 291 KB
  berukuran 10.000 × 10.000 menaikkan memori proses ke ±940 MB; APNG
  beranimasi mendekode semua bingkai; gambar 1 × 5.000 px menghasilkan
  lebar 0 dan galat yang lolos sebagai pesan umum; PNG transparan yang
  masih melebihi batas kini jatuh ke JPEG berlatar putih; izin pembelian
  diperiksa sebelum foto didekode.
- Belum: simpan WebP (belum ada encoder WebP pure Dart), dan JPEG
  aritmetika / 12-bit yang perlu dikecilkan ditolak.

## [0.61.0] - 2026-11-14

Kafe yang punya dapur dan bar kini bisa memasang printer bar: satu kali
*Kirim ke dapur* mencetak minuman di bar dan makanan di dapur, tanpa
pelayan memisahkan pesanan.

### Ditambahkan

- **Printer bar per kategori (1.26, F1-10j).** Kartu baru *Printer bar*
  di Pengaturan › Struk & printer, di bawah *Printer dapur*: *Tidak
  dipakai* (bawaan), *Jaringan (LAN)*, atau *Bluetooth* (Android), lebar
  kertas 58 / 80 mm, *Tes cetak tiket bar* (tiket contoh berjudul *TIKET
  BAR*), dan *Lupakan printer bar*. Disimpan per perangkat, butuh izin
  `settings:manage`.
- **Kategori ke bar.** Chip kategori menu induk (aktif, urut seperti di
  Produk); sub-kategori ikut induknya. Chip langsung tersimpan bila
  printer bar sudah dipilih, atau dipakai saat printer dipilih. Tanpa
  kategori tampil *Pilih minimal satu kategori; sampai itu semua tiket
  tetap ke dapur.*
- **Kirim ke dapur membagi tiket (1.7e).** Item dari kategori bar dicetak
  otomatis sekali di printer bar dengan judul *TIKET BAR*; item lain tetap
  ke tiket dapur seperti sebelumnya. Satu nomor tiket (`K-0012`) untuk
  keduanya. Bila semua item ke bar, tiket dapur tidak dicetak.
- **Modal tiket dua bagian.** Pratinjau *Dapur* dan *Bar* dengan status
  cetak masing-masing (*Mencetak di printer bar…*, *Tiket dicetak di
  printer bar.*, atau alasan galat) dan tombol *Cetak ulang tiket bar*.
  Galat printer bar tidak menghalangi tiket dapur, dan sebaliknya.
- Panduan *Struk & printer* (ID/EN): bagian *Printer bar*.

### Diperbaiki

- Cetak langsung ke printer jaringan dan Bluetooth kini dikirim satu per
  satu. Sebelumnya dua cetak bersamaan bisa saling memutus sambungan
  Bluetooth (plugin hanya punya satu sambungan), sehingga byte tiket bisa
  masuk ke printer yang salah atau gagal *tidak tersambung*.
- Tiket dapur yang menunggu cetak sebelumnya (printer lambat) tetap
  dicetak walau modalnya sudah ditutup; sebelumnya tiket itu dilewati
  tanpa pesan bila pelayan menutup modal kedua sebelum printer selesai.

### Catatan teknis

- Preferensi lokal baru `printer.bar` (JSON printer, kertas, `categories`).
  `printer.kitchen` tidak berubah: kategori dibuang saat memuat printer
  dapur, dan JSON lama tanpa `categories` dimuat dengan kategori kosong.
- `splitBarItems` di `lakuna_data` membagi item menurut kategori produk
  atau induknya (naik maksimal 8 tingkat); varian tidak dikenal dan produk
  tanpa kategori ke dapur.
- `KitchenPrinterViewModel(station: PrinterStation.bar)` dan
  `KitchenPrinterCard` dipakai ulang untuk stasiun bar; `DiningViewModel`
  mendapat `kitchenTicket` / `barTicket`, `autoPrintBar`, `printBarTicket`.
  `kitchenTicketLines(heading:)` untuk judul *TIKET BAR*.
- Review menemukan dan memperbaiki: chip kategori yang diketuk selagi
  menyimpan sempat hilang, id kategori yang sudah dihapus tetap dihitung
  terpilih, dan kategori tetap terbawa setelah printer bar dilupakan.
- Uji manual Xvfb: dua printer jaringan tiruan (port 9101 dapur, 9102 bar)
  menerima *TIKET DAPUR* berisi makanan dan *TIKET BAR* berisi minuman dari
  satu kiriman.

## [0.60.0] - 2026-11-14

Backup kini bisa dikunci dengan kata sandi, sehingga berkas yang disimpan
di Google Drive, WhatsApp, atau flashdisk tidak bisa dibaca atau dipulihkan
orang lain.

### Ditambahkan

- **Kunci backup dengan kata sandi (1.13, F1-19c).** Bagian *Data &
  backup* di Pengaturan punya sakelar *Kunci dengan kata sandi* (mati
  secara bawaan). Saat dinyalakan tampil isian *Kata sandi backup* dan
  *Ulangi kata sandi*; *Backup sekarang* aktif setelah kata sandi 8–128
  karakter (emoji dihitung satu) dan isian ulangi sama persis. Pesan
  *Minimal 8 karakter* / *Kata sandi tidak sama* tampil di bawah isian.
  Kata sandi tidak disimpan di perangkat; isian dikosongkan setelah backup
  dibagikan atau disimpan, dan pesan hasil menyebut *Backup terkunci kata
  sandi*.
- **Pulihkan backup terkunci** dari Pengaturan maupun dari wizard
  onboarding (*Pulihkan dari backup*). Setelah berkas dipilih, panel
  *Backup ini terkunci kata sandi* meminta kata sandi dan tombol *Buka*.
  Kata sandi salah menampilkan *Kata sandi salah. Coba lagi.* tanpa
  memilih ulang berkas; setelah terbuka alurnya sama (ringkasan, ketik
  nama toko, pulihkan) dan kata sandi yang sama dipakai untuk mengekstrak.
- Panduan *Backup & pulihkan* (ID/EN): bagian *Mengunci backup dengan kata
  sandi* dan langkah *Buka* saat memulihkan.

### Keamanan

- Isi zip (`manifest.json`, `lakuna.sqlite`, `media/…`) dienkripsi
  AES-256 gaya WinZip (AE-1, dengan MAC per entri) oleh paket `archive`.
  Karena AE-1 tetap mencatat CRC32 isi asli, manifest backup terkunci
  memuat `nonce` acak agar CRC-nya tidak bisa dipakai menebak isinya.
  Kata sandi zip bukan kata sandi pengguna, melainkan kunci turunan
  PBKDF2-HMAC-SHA256 (salt acak 16 byte, 310.000 iterasi) yang dihitung di
  isolate terpisah. Parameternya ada di komentar zip
  (`lakuna-kunci:1:pbkdf2-sha256:<iterasi>:<salt>`), jadi iterasi bisa
  dinaikkan nanti tanpa memecah backup lama; nilai di luar
  10.000–2.000.000 ditolak agar berkas rusak tidak membuat aplikasi macet.
- Backup terkunci menolak entri tanpa enkripsi (manifest, database,
  gambar): entri biasa bisa disisipkan siapa saja tanpa kata sandi,
  misalnya untuk mengganti gambar stiker QRIS. Komentar kunci palsu di zip
  biasa ikut ditolak.
- Nama toko dan isi database tidak lagi terbaca sebagai teks biasa di
  berkas backup terkunci. Data terenkripsi yang diubah (MAC tidak cocok)
  ditolak sebagai backup tidak sah tanpa mengubah data aktif, dan tidak
  dilaporkan sebagai *kata sandi salah*.

### Diperbaiki

- Pulihkan (semua backup) hanya mengekstrak gambar yang tercantum di
  manifest; entri `media/` tambahan diabaikan.

### Catatan teknis

- `lakuna_domain`: `backupPasswordProblem(password, retype)` →
  `BackupPasswordProblem {tooShort, tooLong, mismatch}`.
- `lakuna_data`: `backup_crypto.dart` (`pbkdf2Sha256` di atas
  `package:crypto` tanpa dependensi baru, diuji dengan vektor RFC 7914;
  `BackupLock`; `readZipComment`). `createBackup` menulis lewat
  `ZipEncoder(password:, streamed: true)` agar komentar zip bisa ditulis;
  entri tetap ditulis dan dibaca bertahap (diuji dengan berkas 80 MB,
  memori puncak sama dengan backup tanpa kunci). `inspectBackup` dan
  `stageRestore` menerima `password:`; galat baru `BackupLocked` dan
  `BackupWrongPassword`. Format manifest tetap 1: versi lama melihat
  backup terkunci sebagai bukan backup Lakuna dan tidak mengubah data.
- `BackupRepository.createBackup/inspect/stageRestore` (dan versi
  onboarding) menerima `password`; `CreatedBackup.locked`.
- `BackupViewModel` dan `SetupRestoreViewModel`: sakelar kunci, isian
  kata sandi + ulangi, perintah `unlock`; kata sandi dibuang saat batal
  atau memilih berkas lain. Hasil buka kunci yang tertinggal (batal atau
  berkas lain dipilih selagi PBKDF2 berjalan) diabaikan lewat nomor
  revisi, dan tombol Pulihkan/Backup nonaktif selama kunci dibuka.
- Kunci turunan terakhir di-cache di memori agar buka kunci lalu pulihkan
  berkas yang sama hanya menghitung PBKDF2 sekali.
- Ditinjau subagent baru: dua temuan Important (balapan buka kunci, entri
  tanpa enkripsi di backup terkunci) dan temuan Minor (AE-1, MAC vs kata
  sandi salah, isian tidak dikosongkan, PBKDF2 ganda) diperbaiki.

## [0.59.0] - 2026-11-14

Harga produk yang sudah ada kini bisa diperbarui sekaligus lewat import
Excel/CSV, misalnya setelah harga pemasok naik.

### Ditambahkan

- **Perbarui harga lewat import (1.15, F1-07k).** Dialog *Import Excel*
  punya sakelar *Perbarui harga produk yang sudah ada* (mati secara bawaan).
  Bila dinyalakan, baris yang cocok dengan varian yang ada lewat SKU atau
  barcode (UPC-A 13 digit ikut cocok), atau lewat nama bila baris tanpa
  kode dan produknya satu varian, memperbarui harga jual, harga beli, dan
  stok minimum. Sel kosong tidak mengubah nilai lama, stok awal diabaikan,
  dan nama/kategori/kode/grosir tidak diubah.
- Kecocokan yang ragu dilewati: SKU dan barcode menunjuk varian berbeda,
  kode lain di baris bertentangan dengan kode varian (mis. salah ketik),
  kode yang dimiliki lebih dari satu varian di data lama, barcode milik
  satuan konversi, nama produk dengan beberapa varian, kode yang tidak
  cocok tetapi namanya sudah dipakai, atau varian yang sudah diperbarui
  baris lain di berkas yang sama. Baris jenis jasa/menu tidak menimpa stok
  minimum barang (temuan review).
- Ringkasan import menyebut produk baru, harga diperbarui, tidak berubah,
  dan dilewati. Panduan *Produk pertama* (ID + EN) diperbarui.

### Catatan teknis

- `ProductImportRow.hasCost` / `hasMinStock` (sel terisi) di
  `lakuna_domain`.
- `importProducts(..., updateExisting:)` dan `ProductImportSummary.updated`
  / `unchanged` di `lakuna_data`; varian diperbarui lewat
  `_ProductWriter.updatePrices` (cap versi/HLC, outbox) dalam transaksi yang
  sama dengan produk baru. Varian yang nilainya sama tidak ditulis.
- `CatalogRepository.importRows(rows, {updateExisting})`.
- Kunci l10n baru: `productImportUpdate`, `productImportUpdateNote`,
  `productImportDoneUpdate` (jamak di EN), `productImportSkippedUnclear`.

## [0.58.0] - 2026-11-14

Barcode toko kini bisa dibuat untuk banyak produk sekaligus dari layar Cetak
label, tanpa membuka form produk satu per satu.

### Ditambahkan

- **Buat barcode massal (1.15b, F1-07j).** Tombol *Buat barcode untuk N
  produk tanpa kode* di layar Cetak label membuat barcode EAN-13 toko
  (awalan 20) untuk semua varian tanpa SKU dan barcode, setelah dialog
  konfirmasi. Barcode disimpan ke produk (validasi, cek kode kembar, dan
  outbox sinkronisasi sama dengan form produk), lalu barisnya langsung
  dipilih untuk dicetak.
- Peringatan kode terlalu panjang (F1-07i) kini punya tombol *Ganti dengan
  barcode EAN-13* untuk produk terpilih yang masih memakai SKU. SKU tidak
  diubah dan jumlah label tetap.
- Panduan *Produk pertama* (ID + EN) menjelaskan kedua tombol.

### Catatan teknis

- `assignStoreBarcodes(products, variantIds, random)` membuat draft per
  produk; kode dijamin tidak sama dengan SKU atau barcode varian/satuan
  lain di katalog maupun satu sama lain. Satuan konversi tidak diberi kode.
- `CatalogProduct.toDraft({barcodes})` di `lakuna_data`; `LabelRow` punya
  `hasBarcode`, `isUnit`, `variantId`.
- Katalog dimuat ulang tepat sebelum barcode dibuat, agar perubahan produk
  dari tempat lain tidak tertimpa. Penyimpanan berurutan per produk; produk
  yang gagal dilewati dan disebut namanya (`BarcodeGenerateSummary`).
- Form produk mengisi field barcode yang masih kosong dari data tersimpan
  setelah kembali dari Cetak label (`refreshBarcodes`), sehingga *Simpan*
  di form tidak menghapus barcode yang baru dibuat (temuan review).
- Kunci l10n baru: `labelsGenerateMissing`, `labelsGenerateDense`,
  `labelsGenerateTitle`, `labelsGenerateBody`, `labelsGenerateConfirm`,
  `labelsGenerateCancel`, `labelsGenerated`, `labelsGenerateFailed` (jamak
  di EN).

## [0.57.0] - 2026-11-14

Layar Cetak label kini memperingatkan bila kode produk terlalu panjang
untuk kertas yang dipilih, sebelum label yang tidak bisa dipindai tercetak.

### Ditambahkan

- **Peringatan kode label terlalu panjang (1.15b, F1-07i).** Bila produk
  terpilih memakai kode yang garis barcode-nya lebih tipis dari 0,25 mm
  (2 titik printer termal 203 dpi) di kertas yang dipilih, muncul
  peringatan berisi jumlah dan nama produknya (maks. 3 nama), dengan saran memakai kertas
  lebih lebar, SKU lebih pendek, atau *Buat barcode*. Contoh: SKU 14
  karakter aman di A4 tetapi terlalu rapat di 50 × 30 dan 38 × 25 mm.
  Peringatan tidak memblokir cetak.
- Panduan *Produk pertama* (ID + EN) menjelaskan peringatan ini.

### Diperbaiki

- Spec F1-07g: baris *Share sheet di iPad* dikoreksi menjadi catatan.
  `share_plus` 13.3 sudah memakai titik asal di tengah layar bila
  `sharePositionOrigin` kosong, jadi tidak ada perubahan kode.

### Catatan teknis

- `lakuna_domain`: `barcodeTooDense(modules, widthMm)` dan konstanta
  `minBarcodeModuleMm`.
- `barcodeModules` menghitung modul dari hasil gambar paket `barcode` yang
  sama dengan pencetak label (Code 128 memadatkan deret angka ke set C),
  bukan dari panjang kode. Rumus perkiraan awal meleset untuk SKU yang
  memuat deret angka (mis. `MYK-2L-12345678` 167 modul, bukan 200).
- `BarcodeLabelPaper.labelWidthMm` / `barcodeWidthMm` (A4 58 mm, 50 × 30
  42 mm, 38 × 25 32 mm area barcode) dan `BarcodeLabelViewModel.denseRows`.
- Kunci l10n baru: `labelsTooDense` (jamak di EN), `labelsTooDenseHint`,
  `labelsTooDenseMore`. Jumlah modul di-cache per kode agar layar tetap
  ringan saat ratusan produk dipilih (temuan review).

## [0.56.0] - 2026-11-14

Uang bagian split bill kini langsung masuk rekap laci sesi kasir yang
menerimanya, tanpa menunggu bill lunas.

### Diubah

- **Kas bagian split bill per sesi (1.3, 1.9, F1-10i).** Setiap pembayaran
  mencatat sesi kasir yang menerimanya: Kasir retail, bayar penuh open bill,
  bayar bagian split, dan QRIS bagian (sesi yang menekan *Sudah terbayar*).
  Rekap laci 1.3 (tunai dan non-tunai penjualan, *tunai seharusnya*, tutup
  sesi) menjumlahkan pembayaran per sesi. Jumlah nota dan total penjualan
  tetap dihitung di sesi yang menutup nota.
- Tutup sesi hanya ditahan bila bill split yang belum lunas punya bagian
  yang dibayar atau menunggu di sesi itu. Sesi perangkat lain di cabang yang
  sama tetap bisa ditutup.
- Void nota hanya bisa dilakukan bila semua pembayarannya diterima di sesi
  kasir perangkat ini yang masih buka. Selain itu pakai *Retur*. Pesan tutup
  sesi dan pesan void disesuaikan.
- Panduan *Split bill* (ID/EN) menjelaskan laci per bagian.

### Diperbaiki

- Tunai bagian split yang sudah dibayar belum terhitung di *tunai seharusnya*
  sampai bill lunas, sehingga rekap laci di tengah sesi tampak kurang.
- Bila tamu membayar di dua perangkat, seluruh tunai tercatat di laci
  perangkat yang menutup bill. Laci perangkat lain jadi lebih dan laci
  penutup jadi kurang.

### Catatan teknis

- Kolom baru `payments.cash_session_id` (nullable, relasi `cash_sessions`,
  indeks `payments_cash_session_idx`), migrasi `kas-per-pembayaran`.
  Pembayaran lama tanpa sesi tetap dihitung di sesi notanya.
- Data: `insertPayments(cashSessionId:)`; `sessionSalesSummary` membaca
  pembayaran per sesi (tanpa nota batal atau bill terhapus);
  `closeCashSession` membatasi cek split ke sesi itu; `_voidBlock` memakai
  `paidInSession`. Batal bill split yang belum lunas tetap boleh dari
  perangkat mana pun: tiap bagian keluar dari laci sesi penerimanya.
- Tes: 8 tes data baru (`split_cash_session_test`).
- Uji manual Xvfb: meja M4 Rp 11.000 dibagi rata empat tamu, tamu A bayar
  tunai Rp 10.000. *Tunai seharusnya di laci* naik dari Rp 177.000 ke
  Rp 179.750 sebelum bill lunas.

## [0.55.0] - 2026-11-14

Barang tanpa barcode pabrik kini bisa diberi barcode toko dengan satu
ketukan, dan barcode UPC-A tetap ditemukan walau pemindai membacanya
13 digit.

### Ditambahkan

- **Buat barcode (1.16, F1-07h).** Field *Barcode* varian di form produk
  punya tombol tongkat *Buat barcode* selama field kosong. Kode yang dibuat
  adalah EAN-13 toko berawalan `20` (rentang GS1 untuk pemakaian internal)
  dengan digit periksa benar, tidak sama dengan barcode atau SKU produk
  lain maupun baris lain di form. Label 1.15b langsung mencetaknya sebagai
  EAN-13.
- Panduan *Menambah produk pertama* (ID/EN): bagian *Barang tanpa barcode*.

### Diubah

- Barcode `0` + UPC-A (13 digit, digit periksa benar) dianggap sama dengan
  UPC-A 12 digit saat memeriksa kode kembar: di form produk, saat simpan,
  saat pulihkan produk arsip, dan saat import Excel/CSV.

### Diperbaiki

- Kasir, Stok (cari dan *Scan / tambah produk*), Pembelian (*Scan / cari
  produk*), pencarian daftar produk, dan Cetak label tidak menemukan barang
  impor berbarcode UPC-A bila pemindai mengirim 13 digit berawalan `0`
  (atau sebaliknya, kode tersimpan 13 digit dan pemindai mengirim 12).

### Catatan teknis

- Domain (`barcode.dart`): `barcodeKey`, `sameBarcode`,
  `generateStoreEan13(Random, {isTaken, maxAttempts})`;
  `ProductDraft.barcodes`, `validateProductDraft`, dan `productImportRows`
  memakai `barcodeKey`. Data: `_checkCodes` dan `importProducts` memakai
  `barcodeKey` untuk barcode (SKU tetap `normalizeCode`).
- Flutter: `ProductFormViewModel.generateBarcode` (+ `random` yang bisa
  disuntik), `EditableVariant.barcodeRevision` membuat ulang field saat kode
  diisi dari tombol; `_TextInput` mendapat `suffix`. Kunci l10n baru
  `productGenerateBarcode`.
- Data lama yang menyimpan UPC-A dan `0` + UPC-A di dua produk kini
  dianggap kembar: menyimpan salah satunya ditolak *Sudah dipakai* sampai
  salah satu kode diubah.
- Tes: 6 tes domain, 1 tes data, 7 tes view model, 3 tes widget (form
  1280 dan 360 px).
- Uji manual Xvfb: *Buat barcode* di produk *Kue Lapis Legit* menghasilkan
  `2042063624845`, label 1.15b menampilkan EAN-13, scan di Kasir menambah
  barang; barcode Kopi diubah ke UPC-A `036000291452`, scan
  `0036000291452` di Kasir menambah Kopi.

## [0.54.0] - 2026-11-14

Tagihan tamu split bill tidak lagi bergeser bila tarif service, PB1, atau
pembulatan diubah setelah tamu pertama membayar.

### Diubah

- **Tarif beku saat split bill dibayar (1.9, F1-10h).** Saat bagian split
  pertama dicatat (lunas atau QRIS *menunggu*), service, PB1, *Harga sudah
  termasuk pajak*, dan pembulatan total cabang disalin ke bill. Panel bill,
  layar Split bill, layar Bayar bagian, konfirmasi QRIS, dan nota lunas
  memakai tarif itu walau pengaturan diubah di tengah split; bill lain tetap
  memakai tarif terbaru.
- Bila semua bagian QRIS yang menunggu dibatalkan (tidak ada pembayaran lagi),
  bill kembali mengikuti tarif terbaru.
- Panduan *Split bill* (ID/EN) menjelaskan tarif yang dikunci.

### Diperbaiki

- Mengubah service, PB1, *termasuk pajak*, atau pembulatan di tengah split
  bill membuat tamu terakhir menanggung selisih (tagihannya = total baru
  dikurangi bagian yang sudah dibayar dengan tarif lama).

### Catatan teknis

- Kolom baru `sales.rounding_step` (kelipatan pembulatan 1/100/500, bawaan
  0), migrasi `tarif-beku`. Pada bill terbuka, nilai > 0 menandai tarif beku
  (`service_bp`, `tax_bp`, `tax_inclusive` tersimpan); nota lunas F&B
  mencatat kelipatan yang dipakai.
- Domain: `TotalRounding.byStep`. Data: `billRates(Sale, FnbRates)` dan
  `_ratesOf` menggantikan pembacaan tarif cabang di semua perhitungan bill;
  `paySplitPart` membekukan, `cancelSplitPayment` melepas.
- Bill lama yang sudah punya bagian lunas sebelum versi ini membeku saat
  bagian berikutnya dibayar (tarif bagian lama tidak tersimpan, jadi tidak
  bisa dipulihkan). `rounding_step` yang tidak dikenal tetap dianggap beku
  tanpa pembulatan.
- Tes: 4 tes data baru (`split_frozen_rates_test`) dan 1 tes domain.
- Uji manual Xvfb: split rata meja M3 (Rp 14.000, termasuk pajak, bulat
  Rp 500), bayar tamu A, ubah service 5% → 10%: bill M3 tetap Rp 14.000
  sementara meja lain naik; tamu B membayar Rp 7.000 dan nota tercatat
  `service_bp` 500, `rounding_step` 500.

## [0.53.0] - 2026-11-14

Pelayan dan kasir kini bisa memotong harga satu menu di bill meja atau take
away tanpa mendiskon seluruh bill, dengan aturan dan izin yang sama dengan
diskon baris di Kasir retail.

### Ditambahkan

- **Diskon per baris di open bill F&B (1.7, F1-04g).** Setiap baris panel
  bill punya tombol persen (`dining-item-discount-<item>`) yang membuka
  dialog *Diskon baris* yang sama dengan Kasir: persen atau rupiah,
  pratinjau potongan, dan *Hapus diskon*. Dasarnya total baris sebelum
  diskon baris (harga × jumlah + modifier, setelah harga grosir/grup).
  - Berlaku untuk item *Baru*, *Di dapur*, maupun *Disajikan*.
  - Di bawah nama item tampil *Diskon 10% · − Rp 2.400* (atau *Diskon* untuk
    rupiah); harga di kanan sudah bersih.
  - Tombol tampil untuk staf berizin *Diskon manual*, atau bila sakelar
    *Diskon manual butuh PIN manajer* hidup (staf lain diminta PIN manajer
    setelah *Terapkan*, sekali pakai).
- Panduan *Diskon manual* (ID/EN) mendapat bagian *Diskon di bill meja dan
  take away*.

### Diubah

- Diskon nota, service, dan PB1 bill dihitung dari total baris setelah
  diskon baris.
- Menambah menu yang sama ke bill tidak lagi menggabungkannya ke baris yang
  berdiskon; baris baru tanpa diskon dibuat.
- Mengubah jumlah item atau harga grup pelanggan (pilih pelanggan, gabung
  meja) menghitung ulang potongan: persen mengikuti total baris, rupiah tetap
  tetapi dipangkas ke total baris.
- Split bill per item: baris berdiskon persen dibagi dengan persen yang
  sama di setiap porsi. Baris berdiskon rupiah tidak bisa dibagi
  (*Hapus atau ubah diskon rupiah item ini ke persen sebelum dibagi.*); bila
  hanya satu porsi, baris pindah utuh.
- Menghapus diskon nota tidak lagi menghapus nama penyetuju selama masih ada
  baris berdiskon; gabung meja membawa penyetuju diskon baris bill sumber.
- Bill yang totalnya habis karena diskon baris (jumlah item berkurang
  setelah diskon rupiah) tidak bisa dibayar sampai diskonnya diubah, sama
  dengan diskon nota.
- Membagi baris berdiskon persen ke tamu tidak mengubah total bill:
  potongan sisa dihitung dari persennya dan porsi yang pindah membawa
  selisihnya (pembulatan per porsi bisa menggeser Rp 1).
- Nama penyetuju diskon dihapus otomatis bila bill tidak lagi punya diskon
  (mis. item berdiskon dihapus), agar tidak tercatat di nota yang diskon
  berikutnya diberikan staf berizin.
- Menghapus diskon baris tidak butuh PIN manajer, dan persetujuan PIN tidak
  terpakai saat diskon (nota atau baris) dihapus.

### Diperbaiki

- Struk dan tiket bill split: porsi yang digabung kembali ke baris asal kini
  menjumlahkan potongan diskon barisnya; porsi dengan diskon berbeda tampil
  di baris sendiri (ditemukan saat review: struk menampilkan potongan satu
  porsi saja).

### Catatan teknis

- Tanpa kolom atau migrasi baru: diskon baris disimpan di
  `sale_items.discount_bp` (persen) dan `discount_amount` (potongan
  efektif), dengan `line_total` = total kotor − potongan, sama dengan Kasir
  retail. Struk, riwayat, retur, dan laporan tidak berubah.
- Bill terbuka dan nota lunasnya kini mengisi `sales.line_discount_amount`
  (Σ potongan baris), dan `tier_discount` dihitung dari total kotor
  sehingga potongan baris tidak tercatat sebagai diskon grosir.
- Data: `setBillItemDiscount`, `billItemDiscountOf`, `BillItemDiscounted`;
  `_withGross` dipakai saat harga dihitung ulang dan saat porsi split
  dipecah atau digabung (hanya digabung bila diskonnya sama).
- Flutter: `DiningRepository.setItemDiscount`,
  `DiningViewModel.setItemDiscount` / `itemDiscountIssue`;
  `discountBlocksPay` ikut memeriksa diskon baris.
- Tes: 11 tes data baru (`bill_item_discount_test`, termasuk pembulatan
  split dan penyetuju), 4 tes view model, 3 tes widget (1280 px setelah
  dapur, 360 px pelayan + PIN manajer, tanpa izin dengan sakelar mati), dan
  1 tes struk untuk porsi berdiskon.
- Uji manual Xvfb: diskon 10% di meja berpelanggan grup, bayar tunai, struk
  memuat *Diskon 10%*; nota tersimpan dengan `line_discount_amount` 4.950
  dan `tier_discount` 3.000.

## [0.52.0] - 2026-11-14

Pemilik yang baru memasang Lakuna kini bisa langsung punya produk untuk
dijual: langkah terakhir setup toko menawarkan produk pertama atau import
Excel.

### Ditambahkan

- **Produk pertama di setup toko (1.1 langkah 4, F1-01b).** Langkah 4
  kini berjudul *Produk pertama, lalu mulai jualan* dengan tiga pilihan:
  - **Tambah satu produk sekarang** (bawaan): nama, harga jual, dan bila
    perlu harga beli, satuan (bawaan `pcs`, F&B `porsi`), barcode, dan
    stok awal. Toko Retail/Campuran mencatat *Barang*; toko F&B mencatat
    *Menu* tanpa stok. Produk ditulis dalam **satu transaksi** dengan
    toko, jadi tidak ada toko setengah jadi bila ada galat.
  - **Import dari Excel/CSV**: setelah toko dibuat, layar Produk terbuka
    dengan dialog import produk.
  - **Lewati, tambah nanti**: perilaku lama.
  Ringkasan toko tetap tampil di bawah pilihan. Isian kosong atau tidak sah
  menahan *Mulai jualan* dengan pesan *Periksa isian produk pertama.*
- Panduan *Instalasi & akun pemilik* dan *Menambah produk pertama* menjelaskan
  langkah 4 yang baru (ID + EN).

### Diubah

- Label langkah 4 di stepper menjadi *Produk pertama*, tombol langkah 3
  menjadi *Lanjut: produk*.

### Diperbaiki (temuan review sebelum rilis)

- Draf yang bisa gagal di tengah transaksi (id produk lama, grup modifier,
  harga grup pelanggan) dan harga jual nol ditolak sebelum toko ditulis.
- Tujuan *import setelah setup* dipakai sekali; masuk berikutnya kembali
  ke Beranda.
- Bila toko ternyata sudah ada saat setup ulang, produk pertama yang
  diketik tidak hilang diam-diam: pesan galat tetap tampil.

### Catatan teknis

- Data: `setupStore(firstProduct:)` memakai `writeProductInTx` (internal,
  disembunyikan dari barrel `lakuna_data`).
- Flutter: `StoreRepository.setup(input, {firstProduct})`;
  `OnboardingViewModel` (`FirstProductChoice`, isian produk,
  `productError`, `opensImport`, `onBeforeSetup`); router
  `importAfterSetup` → `Routes.productsImport` (`/produk?impor=1`);
  `ProductListScreen(openImport:)`.
- Tes: 4 tes data (produk + stok awal satu transaksi, menu F&B, draf tidak
  valid, draf yang bisa gagal di tengah transaksi), 5 tes view model, 4 tes
  widget (alur lengkap tablet/ponsel, retail dengan stok awal, produk
  kosong + lewati, import membuka dialog).
- Uji manual Xvfb: setup baru dengan produk pertama (tampil di Produk
  dengan stok 24) dan setup baru dengan pilihan import.

## [0.51.0] - 2026-11-14

Bukti pembelian kini bisa dicetak atau dibagikan sebagai PDF ke supplier
atau rekan, dan pergerakan stok barang yang baru diterima bisa ditelusuri
langsung dari detail pembelian.

### Ditambahkan

- **Cetak / bagikan PDF pembelian (1.19b, F1-12c).** Tombol baru di kartu
  *Tindakan* detail pembelian. Di desktop PDF disimpan di folder dokumen
  Lakuna (*PDF pembelian disimpan di …*); di Android/iOS lembar bagikan
  sistem terbuka (WhatsApp, email, dll.). PDF A4 berisi supplier, no.
  faktur, tanggal, lokasi, staf, perangkat; tabel barang (nama + varian,
  SKU, qty dengan isi satuan beli mis. `4 dus (@ 6 btl)`, harga beli,
  subtotal); ringkasan Subtotal, Diskon faktur, Ongkos kirim, **Total**,
  Dibayar di muka, Bayar hutang, Retur memotong hutang, **Sisa hutang**;
  serta catatan jatuh tempo, catatan pembelian, daftar retur, uang kembali
  dari retur, dan siapa yang mencetak. Nama berkas
  `pembelian-<nomor>.pdf`; mencetak ulang menimpa berkas lama.
- **Tautan kartu stok dari detail pembelian.** Nama produk yang melacak
  stok di *Barang diterima* membuka layar Stok tab *Kartu stok* untuk
  produk itu di lokasi terima pembelian. Hanya untuk staf dengan izin
  Stok; barang jasa tidak bertautan.
- Layar Stok bisa dibuka langsung ke kartu stok produk dan lokasi tertentu
  (`/stok?tab=card&varian=…&lokasi=…`). Bila produk atau lokasinya tidak
  ada lagi, kartu stok bawaan tampil dengan pemberitahuan.
- Panduan *Mencatat pembelian* menjelaskan cetak PDF dan tautan kartu stok
  (ID + EN).

### Diperbaiki (temuan review sebelum rilis)

- Qty satuan beli di PDF ditulis `4 dus (@ 6 btl)` agar tidak terbaca
  sebagai total 6 botol.
- Ringkasan PDF kini tertutup secara hitungan: baris retur hanya memuat
  bagian yang memotong hutang, sedangkan uang kembali dari retur dicatat di
  bawah tabel. Diskon faktur dicetak positif seperti di layar.
- Pesan *PDF tersimpan/gagal* hilang setelah detail dimuat ulang, dan
  tombol cetak mati selama detail dimuat.
- Nama staf yang kosong tidak meninggalkan pemisah ganda di subjudul PDF.
- Teks bahasa Inggris *Debt payments* dan *Balance due …* diseragamkan.

### Catatan teknis

- `lib/ui/purchases/purchase_print.dart`: `purchasePrintTable` (→
  `ReportTable` untuk `reportPdf`) dan `purchasePrintFileName`.
- `PurchaseDetailViewModel(exporter:)`: `printPdf`, `printPath`,
  `canPrint`; `PurchaseSetup.staffName` untuk baris *Dicetak oleh*.
- `PurchaseDetailView(onOpenStockCard:)`, `Routes.stockCard`,
  `StockScreen(initialVariantId:, initialLocationId:)`,
  `StockViewModel.focusCard` dan `cardFocusMissing`.
- Tes baru: isi tabel cetak (lunas, berhutang + retur campuran, retur uang
  kembali, bahasa Inggris), VM cetak (simpan, lembar bagikan, galat, muat
  ulang), VM stok (fokus, lokasi/produk hilang), dan widget 1440/360 px
  (cetak, tautan kartu stok, tanpa izin Stok, produk hilang).

## [0.50.0] - 2026-11-14

Foto faktur supplier kini tersimpan bersama pembelian, jadi saat mencocokkan
hutang atau harga beli tidak perlu mencari kertas fakturnya.

### Ditambahkan

- **Foto faktur di form pembelian (1.19, F1-12b).** Bagian *Foto faktur* di
  bawah isian supplier: **Lampirkan foto faktur** (PNG, JPG, atau WebP
  sampai 5 MB), **Ambil foto faktur** dari kamera di Android/iOS,
  pratinjau, dan hapus. Foto tersimpan dalam transaksi yang sama dengan
  *Simpan draf* atau *Terima barang & simpan*. Draf yang dibuka lagi
  menampilkan fotonya; menyimpan draf tanpa menyentuh foto tidak mengubah
  foto.
- **Kartu *Foto faktur* di detail pembelian (1.19b).** Gambar kecil yang
  bisa diketuk, **Lihat foto faktur** (layar penuh, bisa diperbesar),
  **Ganti foto** / **Lampirkan foto faktur**, dan **Hapus foto** dengan
  konfirmasi. Mengubah foto pembelian yang sudah diterima tidak mengubah
  stok, HPP, kas, atau hutang. Foto yang tercatat tetapi berkasnya belum
  ada di perangkat ini diberi keterangan.
- Panduan *Mencatat pembelian* menjelaskan foto faktur (ID + EN).

### Diubah

- Penampil foto layar penuh dipakai bersama oleh foto nota pengeluaran dan
  foto faktur (`showPhotoViewer`).

### Diperbaiki (temuan review sebelum rilis)

- Pesan galat foto lama tidak lagi tertinggal setelah aksi berikutnya
  berhasil; galat repositori memakai pesan yang sesuai, dan pesan "periksa
  izin kamera" hanya untuk galat kamera/berkas.
- Memilih atau menghapus foto setelah *Draf disimpan* menghapus pesan
  tersimpan, karena ada perubahan yang belum disimpan.
- Galat membaca foto draf tidak lagi ditampilkan sebagai "belum ada di
  perangkat ini".
- Mengosongkan foto yang sudah kosong atau memasang foto yang sama tidak
  menaikkan versi dokumen dan tidak menambah antrean sinkronisasi.
- `PurchaseInvoicePhotoInvalid` punya pesan sendiri di form pembelian.

### Catatan teknis

- Model: `Purchase.invoiceMediaId` (`purchases.invoice_media_id` →
  `media_files`), `MediaKind.purchaseInvoice`; migrasi
  `20261114003906842-foto-faktur`.
- Domain: `PurchaseLimits.invoicePhotoMaxBytes` (5 MB).
- Data: `PurchaseInvoicePhoto`, `PurchaseRequest.invoicePhoto` /
  `removeInvoicePhoto`, `setPurchaseInvoicePhoto`,
  `clearPurchaseInvoicePhoto`, `loadPurchaseInvoicePhoto`,
  `PurchaseDetail.hasInvoicePhoto`, `PurchaseInvoicePhotoInvalid`. Berkas
  disimpan di `media/<sha256>.<ext>` lewat `storeMediaFile` (cabang
  pembelian).
- `PurchasesRepository.invoicePhoto/setInvoicePhoto/clearInvoicePhoto`;
  `PurchaseFormViewModel(picker:)` dan `PurchaseDetailViewModel(picker:)`;
  router meneruskan `ImageFilePicker` ke layar Pembelian.
- Tes: 7 tes data foto faktur, 11 tes view model, 2 tes alur widget
  (1440 px dan ponsel 360 px dengan kamera).
- Uji manual Xvfb: lampirkan `faktur.png` di form → terima barang →
  detail menampilkan gambar kecil, *Lihat foto faktur* membuka foto penuh,
  *Hapus foto* dengan konfirmasi → "Belum ada foto faktur."

## [0.49.0] - 2026-11-14

Barang yang menipis bisa langsung dipesan ulang: satu ketukan dari daftar
stok minimum membuka form pembelian yang sudah terisi.

### Ditambahkan

- **Buat pembelian dari stok minimum (1.18 → 1.19, F1-08c).** Tombol
  **Buat pembelian** di bawah daftar *Di bawah stok minimum* (tab *Stok
  minimum* dan panel di tab *Penyesuaian*) membuka *Pembelian baru* dengan:
  - lokasi terima = lokasi stok yang sedang dilihat;
  - satu baris per barang di bawah minimum, satuan dasar, harga modal
    terakhir, dan jumlah saran **2 × minimum − stok** (stok minus dihitung
    0), dibulatkan ke atas ke satuan utuh, minimal 1;
  - catatan "Diisi dari stok minimum <lokasi>: N barang. Periksa jumlah dan
    harga sebelum menyimpan.", plus jumlah barang yang dilewati bila produk
    sudah diarsip atau bukan barang.
  Supplier dan pembayaran dipilih seperti biasa; draf baru tersimpan hanya
  saat *Simpan draf* / *Terima barang* ditekan.
- Tombol hanya tampil untuk staf dengan izin *Kelola pembelian*
  (`purchases:manage`) dan mati selama data lokasi baru dimuat.
- Kembali ke Stok setelah form ditutup memuat ulang daftar, jadi barang
  yang baru diterima tidak dipesan dua kali; pembelian yang diterima
  membuka detailnya dulu. Ketukan ganda tidak membuka dua form (temuan
  review).
- Panduan *Penyesuaian & stok minimum* menjelaskan tombol dan rumus jumlah
  saran (ID + EN).

### Dihapus

- Teks "Pesanan pembelian dari daftar ini menyusul bersama modul
  Pembelian." di panel stok minimum.

### Catatan teknis

- Domain: `restockQuantity(stock, minimum)` di `stock.dart`.
- `PurchaseRestock` (lokasi, nama lokasi, varian + jumlah) dikirim lewat
  `extra` rute `/pembelian/baru`; `PurchaseFormViewModel(restock:)`
  memakainya sekali setelah form kosong dibuat, dan `startNew` (setelah
  terima barang) kembali ke form kosong.
- `StockViewModel.restock` hanya terisi bila baris di bawah minimum milik
  lokasi terpilih (selaras dengan pengaman *Cetak stok* v0.48.0).
- `FakeStockRepository.belowMinimum`/`card` memakai baris per lokasi,
  seperti data asli (minimum hanya di lokasi bawaan).
- Anotasi `@immutable` dan dok `PurchaseSetup` dikembalikan ke kelasnya
  (temuan review).
- Uji manual Xvfb: Stok › Stok minimum (Keripik 0,5/5, Minyak 5/6) ›
  *Buat pembelian* → form berisi 10 bungkus dan 7 botol, lokasi Etalase.

## [0.48.0] - 2026-11-14

Daftar stok bisa dicetak untuk stock opname manual: hitung di rak, tulis
di kertas, lalu masukkan selisihnya di tab Penyesuaian.

### Ditambahkan

- **Cetak stok (1.18, F1-08b).** Tombol **Cetak stok** di kepala layar
  Stok (semua tab, di samping pilihan lokasi) membuat PDF A4 tegak:
  - judul `Daftar stok · <lokasi>`, subjudul cabang, tanggal & jam cetak
    (zona waktu cabang), dan nama staf;
  - kolom Produk, SKU / Barcode, Stok (dengan satuan), Minimum (kosong bila
    tidak diisi), Nilai (HPP), dan **Fisik** yang kosong untuk ditulis
    tangan; baris Total nilai;
  - catatan jumlah item, di bawah minimum, dan stok minus, plus petunjuk
    mencatat selisih di tab Penyesuaian;
  - semua barang di lokasi terpilih tercetak; kata pencarian tidak
    menyaring cetakan.
- Desktop menyimpan PDF ke folder dokumen Lakuna
  (`stok-<lokasi>-<yymmdd>-<HHmm>.pdf`) dan menampilkan lokasinya;
  Android/iOS membuka share sheet. Galat tampil sebagai pesan merah, tombol
  aktif lagi. Pesan hilang saat pindah tab atau ganti lokasi.
- Panduan *Penyesuaian & stok minimum* punya bagian **Cetak daftar stok
  untuk opname** (ID + EN).

### Diubah

- Kepala layar Stok kini memuat tombol *Cetak stok* bersama pilihan lokasi
  (ponsel: bertumpuk selebar layar).

### Diperbaiki

- PDF laporan dan cetak stok lebih dari 20 halaman (± 700 baris) gagal
  dibuat di build debug karena batas bawaan paket `pdf`; kini batasnya
  1000 halaman (temuan review).

### Catatan teknis

- Tombol *Cetak stok* mati selama lokasi baru dimuat dan bila muat lokasi
  gagal (`printRows` / `printLocationName` mengikuti lokasi milik baris
  yang termuat), sehingga baris lokasi lama tidak pernah tercetak dengan
  judul lokasi baru (temuan review, diuji dengan `stockGate`).
- Galat non-`Exception` dari pembuat PDF dilaporkan lewat
  `FlutterError.reportError` sebelum pesan gagal ditampilkan.
- `stockPrintCounts` bahasa Inggris memakai bentuk jamak ICU (`1 item`).
- `stockPrintTable` / `stockPrintFileName` (`ui/stock/stock_print.dart`)
  memakai mesin `reportPdf` laporan (F1-16).
- `StockViewModel.printList` (`Command1`) menerima pembuat PDF dan nama
  berkas sehingga tombol mati sejak PDF dibuat sampai tersimpan; hasil
  dihapus saat ganti lokasi. `StockScreen` menerima `exporter` dari router.
- `XlsxNumber` punya kesetaraan nilai (`==`/`hashCode`) untuk tes.
- Teks cetakan tidak memakai karakter `›` karena tidak ada di font PDF
  DM Sans (ditemukan saat uji manual).
- Uji manual Xvfb: cetak stok Etalase (13 item), PDF dibuka dengan
  `pdftoppm`.

## [0.47.0] - 2026-11-14

Pemilik yang baru pertama kali import tidak perlu menebak judul kolom lagi:
templat Excel bisa diunduh langsung dari dialog import.

### Ditambahkan

- **Templat berkas import (1.15, 1.20, 1.21, F1-07g).** Dialog *Import
  Excel* di Produk, Pelanggan, dan Supplier punya tombol **Unduh templat**
  di samping *Pilih berkas*:
  - berkas `templat-import-produk.xlsx`, `templat-import-pelanggan.xlsx`,
    atau `templat-import-supplier.xlsx`, satu lembar dengan baris judul
    tebal dan dibekukan;
  - kolom produk: Nama, Kategori, Jenis, Satuan, SKU, Barcode, Harga beli,
    Harga jual, Stok awal, Stok minimum; pelanggan: Nama, HP, Alamat, Grup,
    Limit, Catatan; supplier: Nama, Kontak, Telepon, Kategori, Tempo (hari),
    Alamat, Catatan;
  - dua baris contoh fiktif ("Contoh …") untuk ditimpa. Baris contoh
    yang lupa dihapus **dilewati** saat import dengan alasan *baris contoh
    dari templat, ganti atau hapus*, sehingga stok awal, grup "Grosir",
    atau limit kredit fiktif tidak ikut tersimpan;
  - kolom HP/Telepon, SKU, dan Barcode berformat teks, jadi nomor telepon
    rumah `021…` atau barcode berawalan `0` yang diketik di Excel tidak
    kehilangan nol di depan; angka contoh (harga, stok, limit, tempo)
    ditulis sebagai angka sehingga Excel tidak menandainya "angka disimpan
    sebagai teks";
  - desktop menyimpan ke folder dokumen Lakuna dan menampilkan lokasinya di
    bawah tombol; Android/iOS membuka share sheet. Galat simpan tampil di
    tempat yang sama.
- Panduan *Menambah produk pertama* punya bagian baru **Banyak produk
  sekaligus**; panduan Pelanggan dan Supplier menyebut tombol templat
  (ID + EN).

### Diubah

- Baris tombol dialog import kini satu komponen bersama
  (`ImportFileActions`), sehingga pesan simpan templat tidak menggeser
  tombol *Pilih berkas* ke baris baru di layar sempit.

### Diperbaiki

- Galat apa pun saat menyimpan templat (termasuk `Error` dari share
  sheet) kini tertangkap: pesan *gagal disimpan* tampil dan tombol tidak
  terkunci sampai dialog dibuka ulang (temuan review).

### Catatan teknis

- `buildXlsx` menerima `textColumns` (gaya sel 3 = format teks
  `numFmtId 49`, dipasang di `<col>` dan di sel teks kolom itu).
- Alasan tolak baru `sample` di `ImportRejectReason`,
  `ProductImportRejectReason`, dan `SupplierImportRejectReason`, dicek
  lewat `isImportTemplateSample` sebelum validasi lain.
- `FakeSpreadsheetExporter.error` untuk menguji galat simpan; tes widget
  baru: galat simpan, share sheet (lokasi `null`), templat pelanggan
  360 px.
- Templat dibuat di `lakuna_domain` (`productImportTemplate`,
  `customerImportTemplate`, `supplierImportTemplate`) bersama pembaca
  import. Fungsi baru `productImportKnownHeader` /
  `customerImportKnownHeader` / `supplierImportKnownHeader` dipakai tes
  untuk memastikan tidak ada judul templat yang tidak dikenali.
- Tes Flutter membaca .xlsx hasil `buildXlsx` lewat `readTableFile` lalu
  pembaca import: 2 baris contoh dilewati untuk tiap jenis; dengan nama
  diganti, 2 baris sah dan 0 ditolak.
- `exporter` (`SpreadsheetExporter`) diteruskan dari router ke layar
  Produk, Pelanggan, dan Supplier.
- Uji manual Xvfb: unduh templat supplier (dibuka juga dengan openpyxl:
  kolom Telepon berformat `@`, tempo berupa angka), ganti satu nama
  contoh, import → "1 baris siap", baris contoh lain dilewati, selesai
  1 supplier baru.
- Gap tercatat: share sheet di iPad belum memberi `sharePositionOrigin`
  (berlaku juga untuk ekspor lain).

## [0.46.0] - 2026-11-14

Pindah ke perangkat baru tidak perlu lagi membuat toko palsu dulu: backup
bisa dipasang langsung dari wizard setup.

### Ditambahkan

- **Pulihkan dari backup di onboarding (1.1, F1-19b).** Langkah pertama
  wizard *Siapkan toko Anda* menampilkan kartu "Pindah perangkat atau HP
  rusak?" dengan tombol **Pulihkan dari backup**:
  - pilih berkas `.zip` backup Lakuna; ringkasan toko, cabang, perangkat,
    tanggal, jumlah transaksi dan produk;
  - ketik nama toko pada backup (tidak peka huruf besar/kecil), lalu
    **Pulihkan & muat ulang**;
  - pemasangan, folder `sebelum-pulihkan-…`, migrasi backup lama, dan
    pengembalian data bila backup gagal dibuka sama dengan pulihkan di
    Pengaturan (F1-19); aplikasi lalu membuka layar masuk dengan staf dan
    preferensi dari backup;
  - galat berkas rusak, backup dari versi lebih baru, atau gagal disiapkan
    tampil di dialog; dialog hanya ditutup lewat *Batal* dan terkunci
    selama backup disiapkan;
  - bila backup gagal dibuka setelah dipasang, wizard menampilkan pesan
    *Pulihkan gagal* (sebelumnya pesan ini hanya ada di Beranda, yang tidak
    terlihat karena perangkat kembali kosong).
- Panduan *Backup & pulihkan* (ID/EN): bagian *Pindah ke perangkat baru*.

### Keamanan

- Pulihkan dari onboarding tidak butuh login (belum ada staf), jadi
  repositori menolaknya (`StoreAlreadySetUp`) bila toko sudah dibuat di
  perangkat ini, termasuk bila konteks toko belum termuat (dibaca ulang
  dari database) atau masih ada tenant walau data perangkatnya tidak
  lengkap (cek yang sama dengan setup toko). Pulihkan untuk toko yang sudah ada tetap lewat
  Pengaturan dengan izin `backup:manage`.

### Catatan teknis

- `BackupRepository.inspectForSetup` / `stageRestoreForSetup`,
  `SetupRestoreViewModel`, `setup_restore_dialog.dart`;
  `OnboardingScreen` menerima `BackupRepository` dan `BackupFiles` dari
  router dan memanggil `AppRestart`.
- Pesan galat pulihkan dipakai bersama Pengaturan dan onboarding
  (`backupRestoreError`). Tanpa `AppRestart`, dialog meminta pengguna
  membuka ulang aplikasi alih-alih diam.
- View model sengaja tidak membuang `Command`-nya: perintah *Pulihkan*
  masih menunggu muat ulang aplikasi saat dialog dilepas (galat "Command
  used after being disposed" ditemukan saat uji manual, sudah ada tesnya).
- Tes repositori (ditolak bila toko ada, berhasil di perangkat kosong),
  view model, widget 1280/360 px; uji manual Linux (Xvfb): perangkat
  kosong → pulihkan backup 4 Nov (skema lama, migrasi otomatis) → masuk
  dengan PIN dari backup.

## [0.45.0] - 2026-11-14

Toko yang pindah dari buku atau aplikasi lain bisa memasukkan daftar
supplier sekaligus dari Excel/CSV.

### Ditambahkan

- **Import supplier (1.21, F1-14b).** Tombol **Import Excel** di samping
  *Supplier* membuka dialog yang sama polanya dengan import pelanggan:
  - berkas .xlsx atau .csv (pemisah koma atau titik koma, maks. 2 MB);
    kolom *Nama* (wajib), *Kontak*, *Telepon/HP*, *Kategori*,
    *Tempo/Tempo (hari)*, *Alamat*, *Catatan*, judul Indonesia atau
    English, kolom lain diabaikan;
  - pratinjau jumlah baris siap import dan baris yang dilewati dengan
    nomor baris dan alasannya: nama kosong/terlalu panjang, telepon tidak
    sah, tempo di luar 0–365 hari, teks terlalu panjang, atau nama dobel
    di berkas;
  - tempo boleh ditulis `30`, `30 hari`, `7 days`, atau `14.0`;
  - nama yang sudah terdaftar (tanpa beda huruf besar/kecil) memperbarui
    supplier itu, hanya kolom yang terisi; supplier baru tanpa tempo
    memakai tempo standar 14 hari;
  - ringkasan *N supplier baru, M diperbarui, K baris dilewati*; daftar
    dan panel supplier dimuat ulang setelah dialog ditutup;
  - import ulang berkas yang sama tidak menulis ulang (dan tidak
    menyinkronkan) supplier yang datanya tidak berubah.
- Judul kolom telepon lain dikenali di import supplier **dan** pelanggan:
  *Telp*, *No. Telp*, *No. Telepon*, *Nomor HP*, *Nomor Telepon*,
  *WhatsApp*, *WA*.
- Panduan *Supplier & hutang* (ID/EN) menjelaskan import supplier.

### Diperbaiki

- Import pelanggan, produk, dan supplier: bila dialog ditutup dengan
  mengetuk latar atau tombol kembali setelah import tersimpan, atau setelah
  memilih berkas lain, daftar tidak dimuat ulang sehingga data baru baru
  tampil setelah pindah menu. Sekarang dialog melaporkan import yang
  tersimpan lewat callback, bukan dari nilai tutup dialog (temuan review).

### Keamanan

- Import butuh izin `suppliers:manage` di layar (tombol hanya tampil untuk
  yang berhak) dan di lapisan data.

### Catatan teknis

- Domain: `supplier_import.dart` (`supplierImportRows`,
  `parseImportTermDays`, `SupplierImportRow`, `SupplierImportRejected`,
  `SupplierImportRejectReason`), memakai `validateSupplier` yang sama
  dengan form.
- Data: `importSuppliers` menulis semua baris dalam satu `LakunaStore.write`
  (tercatat di outbox) dan memeriksa ulang setiap baris; satu baris salah
  membatalkan seluruh import. Supplier terhapus tidak diperbarui, namanya
  boleh dipakai lagi.
- Flutter: `SuppliersRepository.importRows`, `SupplierImportViewModel`,
  `supplier_import_dialog.dart`; `SuppliersScreen` menerima
  `TableFilePicker`. Tes domain, data, repositori lokal, VM, dan widget
  1280/360 px; uji manual di Linux (Xvfb) dengan berkas CSV.

## [0.44.0] - 2026-11-13

Pembayaran piutang pelanggan dan hutang supplier yang salah catat sekarang
bisa dibatalkan dengan jejak, lalu dicatat ulang dengan benar.

### Ditambahkan

- **Batal pembayaran piutang (1.20, F1-13c).** Ikon *Batalkan pembayaran*
  di setiap baris riwayat pembayaran pelanggan membuka dialog dengan
  nominal, penjelasan dampaknya, dan **Alasan batal** wajib (1–200
  karakter). Setelah dibatalkan:
  - alokasi pembayaran ke setiap nota dihapus (soft delete), sehingga sisa
    piutang nota, status lunas, ringkasan pelanggan, dan laporan piutang
    kembali seperti sebelum pembayaran; nota yang tadinya terkunci karena
    sudah dibayar bisa di-void lagi;
  - pembayaran tunai yang dulu masuk laci dijurnal balik sebagai kas keluar
    di sesi kasir yang sedang buka (sumber *Batal bayar piutang*);
  - baris riwayat tetap tampil dengan nominal dicoret, label *Batal*, dan
    alasannya;
  - kuitansi A5 dan thermal pembayaran itu bercap **BATAL** dan memuat
    alasan batal, rinciannya tetap lengkap; sisa piutang setelah
    pembayaran tidak dicetak lagi karena sudah tidak berlaku.
- **Batal pembayaran hutang (1.21, F1-13c).** Ikon yang sama di riwayat
  bayar supplier: alokasi ke pembelian dihapus sehingga sisa hutang
  kembali, dan pembayaran dari kas laci dikembalikan sebagai kas masuk di
  sesi kasir yang sedang buka (sumber *Batal bayar hutang*).
- Sumber kas *Batal bayar piutang* dan *Batal bayar hutang* di daftar gerak
  kas sesi kasir (1.3) dan tab *Kas & sesi* Laporan.
- Panduan *Pelanggan & piutang* dan *Supplier & hutang* (ID + EN) punya
  bagian baru tentang membatalkan pembayaran.

### Diubah

- Di layar sempit (di bawah 420 px) nominal baris riwayat pembayaran
  pelanggan dan supplier pindah ke bawah nomor agar tombol aksinya muat;
  nomor pembayaran tetap satu baris.

### Keamanan

- Batal pembayaran butuh izin `debts:manage`; bila ada jurnal balik laci
  juga `cash_movements:create`. Izin dicek di repositori aplikasi dan di
  lapisan data. Pembayaran yang dicatat di cabang lain tidak bisa
  dibatalkan dari cabang ini (ditolak sebagai tidak ditemukan), karena
  jurnal balik kas memakai sesi kasir cabang aktif. Pembayaran milik
  pelanggan/supplier yang sudah dihapus juga ditolak agar saldo pihak
  terhapus tidak hidup lagi.

### Catatan teknis

- Model `debt_payments` mendapat kolom `voided_at`, `voided_by`,
  `void_reason`, dan `void_cash_movement_id` (relasi ke `cash_movements`),
  migrasi `batal-bayar-utang` untuk Postgres dan SQLite klien.
- `voidDebtPayment(store, scope, staffId:, paymentId:, reason:)` di
  `lakuna_data` (berkas baru `debt_payment_void.dart`) menulis pembayaran,
  alokasi, dan gerakan kas dalam satu transaksi outbox. Galat baru:
  `DebtPaymentAlreadyVoided`, `DebtPaymentVoidReasonInvalid`; tanpa sesi
  terbuka untuk pembayaran laci gagal dengan `CashSessionNotOpen`.
- `validateDebtPaymentVoidReason` dan `debtPaymentVoidReasonMax` (200) di
  `lakuna_domain`; `debtPaymentTouchesDrawer` menentukan perlu tidaknya
  jurnal balik laci.
- `CashSourceKind.debtPaymentVoid` / `supplierPaymentVoid` dan konstanta
  sumber `debt_payment_void` / `supplier_payment_void`.
- `loadDebtPaymentReceipt` tetap memuat alokasi pembayaran yang dibatalkan
  agar kuitansi batal menampilkan rincian.
- `CustomersRepository.voidPayment` dan `SuppliersRepository.voidPayment`;
  `CustomersSetup.outletId` / `SuppliersSetup.outletId`; dialog bersama
  `debt_payment_void_dialog.dart`.
- Tombol *Kembali* di dialog batal nonaktif selama proses agar ringkasan
  daftar tetap dimuat ulang setelah batal berhasil.
- Tes baru: `debt_payment_void_test.dart` (data, 9 tes), tes view model
  panel pelanggan/supplier dan kuitansi batal, serta tes widget batal di
  1280 dan 360 px.

## [0.43.0] - 2026-11-13

Menu yang tidak dimasak tidak lagi mengisi tiket dapur, dan menu yang tidak
bisa diubah tidak menerima catatan bebas.

### Ditambahkan

- **Sakelar dapur per menu (1.16b, F1-10g).** Bagian *Dapur* baru di tab
  *Modifier* form produk:
  - **Kirim ke tiket dapur** (bawaan aktif). Bila dimatikan, item menu itu
    tidak tercetak di tiket saat *Kirim ke dapur* dan statusnya langsung
    *Disajikan*. Bila semua item baru bukan menu dapur, tiket tidak dibuat,
    nomor tiket harian tidak terpakai, modal tiket tidak muncul, dan
    printer dapur tidak mencetak; panel bill menampilkan *N item tanpa
    tiket dapur langsung ditandai disajikan*.
  - **Bisa catatan bebas** (bawaan aktif). Bila dimatikan, catatan dapur
    untuk menu itu diabaikan. Di lembar menu, catatan yang sudah diketik
    tetap tersimpan untuk menu berikutnya; lembar modifier 1.8 tidak
    menampilkan isian catatan.
- Panduan *Modifier menu* dan *Meja & open bill* (ID + EN) menjelaskan
  kedua sakelar.

### Diubah

- Modal tiket dapur menyebut jumlah item yang langsung disajikan tanpa
  tiket bila kiriman berisi campuran menu dapur dan non-dapur.
- Status *Ditambahkan* di lembar menu dibatasi dua baris agar tidak
  menggeser daftar menu di ponsel.

### Catatan teknis

- Kolom baru `products.send_to_kitchen` dan `products.allow_note`
  (`bool`, bawaan `true`), migrasi `20261113153626691-menu-dapur` untuk
  Postgres dan SQLite klien; produk lama tetap ikut tiket dan boleh
  catatan.
- `ProductDraft` / `CatalogProduct` `sendToKitchen`, `allowNote`.
- `KitchenSendResult.ticket` kini boleh `null`, dan `served` berisi item
  non-dapur. Sakelar dibaca saat kirim, bukan saat item ditambahkan.
- `DiningViewModel.servedWithoutTicket`; `lastTicket` hanya hasil kirim
  yang punya tiket.
- Review subagent tidak menemukan temuan Critical/Important. Temuan minor
  yang diperbaiki:
  - Catatan untuk menu tanpa catatan bebas tidak lagi diperiksa panjangnya
    sebelum diabaikan.
  - Pesan *tanpa tiket* hilang saat pilihan bill atau mode berubah.
  - Tes outbox (sakelar produk dan item yang langsung disajikan).
  - Tes lembar modifier tanpa isian catatan di 360 px.
- Uji manual di aplikasi Linux (Xvfb) dengan printer dapur tiruan (port
  9101):
  - Air Mineral 600 ml diatur tanpa tiket dan tanpa catatan.
  - Di M4: catatan "pedas" diketik, lalu Air Mineral ditambahkan →
    catatan tetap tersimpan. Mi Instan Goreng ditambahkan → memakai
    "pedas".
  - *Kirim ke dapur* → tiket K-0004 berisi hanya Mi Instan Goreng
    (dicek dari byte ESC/POS), dan Air Mineral langsung *Disajikan*.
  - Air Mineral kedua dikirim sendiri → tanpa modal dan tanpa cetak,
    pesan tampil di panel.

## [0.42.0] - 2026-11-13

Open bill F&B kini bisa diberi pelanggan, sehingga harga grosir grup
pelanggan berlaku juga di meja.

### Ditambahkan

- **Pelanggan di open bill (1.7 / 1.8, F1-10f).** Baris *Pelanggan* di
  bawah judul bill dengan tombol **Pilih pelanggan** / **Ganti** dan
  **×** untuk melepas. Dialog pemilih mencari nama atau nomor HP dan
  menampilkan grup pelanggan.
  - Semua item bill langsung dihitung ulang dengan harga grup pelanggan
    (F1-07c), termasuk item yang sudah dikirim ke dapur dan item yang
    ditambahkan atau diubah jumlahnya kemudian. Melepas pelanggan
    mengembalikan harga normal.
  - Nama pemesan bill yang masih kosong diisi nama pelanggan.
  - *Tutup & bayar* dengan *Kredit / piutang* otomatis memilih pelanggan
    bill.
- Panduan *Meja & open bill* (ID + EN): bagian *Pelanggan di bill*.

### Diubah

- Baris pelanggan kosong menampilkan *Pelanggan umum*, sama dengan Kasir.
- *Gabung meja* tidak menawarkan bill dengan pelanggan berbeda; bila
  hanya satu bill berpelanggan, hasil gabung memakai pelanggan itu dan
  harganya dihitung ulang. Pesan *Belum ada meja lain yang bisa
  digabung* kini menyebut split, diskon nota, dan pelanggan berbeda.
- Pelanggan bill tidak bisa diubah setelah bill di-split atau ada bayar
  bagian.

### Diperbaiki

- Kredit open bill untuk pelanggan selain pelanggan bill kini ditolak
  dengan pesan jelas, agar piutang tidak tercatat atas nama yang salah
  sementara harga memakai grup pelanggan lain.

### Catatan teknis

- `setOpenBillCustomer`, `OpenBill.customer` (`BillCustomer{id, name,
  groupId, groupName}`), `BillCustomerBlocked`, `BillCustomerMismatch`,
  `BillMergeReason.customer` di `lakuna_data`; harga ulang lewat
  `_repriceBill` memakai aturan harga F1-07c dan hanya menulis item yang
  berubah (tercatat di outbox sync).
- `addBillItem` / `setBillItemQuantity` memakai grup pelanggan bill.
- `DiningRepository.customers()` / `setBillCustomer`;
  `DiningViewModel.customers`, `setCustomer`, `customerCandidates`,
  `canSetCustomer`; `mergeSources` menyaring pelanggan berbeda.
- Tes widget panel bill kini menggulir ke aksi tambahan yang belum
  dibangun oleh `ListView` di ponsel; teks *Belum ada meja lain yang bisa
  digabung* kini bisa digulir agar tidak meluap di ponsel.
- Temuan review yang diperbaiki sebelum rilis: harga hanya dihitung ulang
  bila grup harga bill berubah (sebelumnya memasang pelanggan tanpa grup
  ikut menaikkan harga beku ke harga menu terbaru); harga dihitung per
  baris dan item yang produknya sudah nonaktif tetap memakai harga beku
  (sebelumnya bill terkunci dengan `SaleItemUnavailable`); pelanggan bill
  yang sudah dihapus dianggap tanpa pelanggan saat gabung dan bayar kredit
  (sebelumnya kredit ditolak walau panel menampilkan *Pelanggan umum*);
  nama pelanggan dipotong ke 40 karakter nama pemesan; diskon nota rupiah
  yang menghabiskan total setelah harga grup kini ditolak saat memilih
  pelanggan, bukan baru saat bayar. Gabung meja hanya menghitung ulang item
  bill yang grupnya berbeda.
- Uji manual di aplikasi Linux (Xvfb): M1 dengan 2 × Gula Pasir 1 kg
  (Rp 17.500) → pilih *Toko Bu Ani · Grosir* → Rp 16.500 per item; tambah
  jumlah tetap harga grup; lepas pelanggan → harga normal; *Tutup & bayar*
  → *Kredit / piutang* memilih Toko Bu Ani; M2 berpelanggan Siti Rahma
  tidak bisa digabung dengan M1.

## [0.41.0] - 2026-11-13

Tiket dapur kini bisa keluar langsung di printer dapur, terpisah dari
printer struk di kasir.

### Ditambahkan

- **Printer dapur (1.26, F1-10e).** Kartu baru *Printer dapur* di
  *Pengaturan › Struk & printer*, disimpan di perangkat ini saja:
  - *Sama dengan printer struk* (bawaan, perilaku lama), *Jaringan (LAN)*
    dengan alamat `host[:port]` (port bawaan 9100), atau *Bluetooth*
    (Android) dari printer yang sudah dipasangkan;
  - lebar kertas tiket 58 / 80 mm, terpisah dari kertas struk;
  - *Tes cetak tiket* mengirim tiket contoh ke printer dapur;
  - *Lupakan printer dapur* kembali ke printer struk.
- **Tiket otomatis saat *Kirim ke dapur* (1.7e).** Bila printer dapur
  terpasang, tiket langsung dicetak sekali ke printer itu dengan kertas
  dapur. Modal tiket menampilkan *Tiket dicetak di printer dapur*, atau
  alasan galat printer (mis. printer tidak bisa dihubungi) dengan tombol
  *Cetak ulang*. Item tetap berstatus *Di dapur* walau cetak gagal.

- Panduan *Struk & printer* dan *Meja & open bill* (ID + EN) menjelaskan
  printer dapur.

### Diubah

- Modal tiket dapur kini bisa digulir utuh, sehingga pesan status dan
  tombol tetap terjangkau di ponsel layar pendek.
- Galat cetak tiket menampilkan alasan dari printer bila diketahui.

### Catatan teknis

- `KitchenPrinter{printer, paper}`, `kitchenPrinterKey`
  (`printer.kitchen`), `loadKitchenPrinter` / `saveKitchenPrinter` di
  `lakuna_data` (hanya printer langsung; isi rusak atau dialog sistem →
  `null`).
- `ReceiptSettingsRepository.loadKitchenPrinter / saveKitchenPrinter`
  (`settings:manage` untuk mengubah); `DiningData.kitchenPrinter` (ikut
  disalin `withOverview`).
- `KitchenPrinterViewModel` + `KitchenPrinterCard`; baris printer
  Bluetooth dipindah ke `PrinterDeviceRow` bersama.
- `DiningViewModel.ticketToKitchen`, `ticketPaper`,
  `shouldAutoPrintTicket`, `autoPrintTicket(lines)`.
- Temuan review yang diperbaiki sebelum rilis: tiket baru yang dikirim
  selagi cetak tiket sebelumnya masih berjalan kini menunggu lalu dicetak
  (sebelumnya terlewat dan modalnya bisa salah menampilkan *dicetak*);
  status cetak hanya milik tiket yang tampil; memilih *Sama dengan printer
  struk* kini benar-benar melupakan printer dapur; mengganti kertas saat
  jenis lain sedang dipilih tidak lagi menyimpan ulang printer lama; galat
  tes cetak / cari Bluetooth yang tak dikenal kini tampil; printer dapur
  tanpa alamat dianggap tidak ada.
- Uji manual di aplikasi Linux (Xvfb) dengan dua printer jaringan tiruan
  (struk 9100, dapur 9101): tes cetak tiket 32 kolom ke dapur; kertas
  dapur 80 mm; *Kirim ke dapur* M3 mencetak tiket 48 kolom hanya ke
  printer dapur; printer dapur dimatikan → modal menampilkan *printer
  tidak bisa dihubungi* dan item tetap di dapur; printer dinyalakan lalu
  *Cetak ulang* berhasil.

## [0.40.0] - 2026-11-13

Dua meja kini bisa digabung menjadi satu tagihan.

### Ditambahkan

- **Gabung meja (1.7 / 1.8, F1-10d).** Panel bill dine in di meja *Boleh
  digabung* punya aksi *Gabung meja*. Dialog menampilkan meja lain yang
  berisi pesanan dan juga *Boleh digabung*; memilih satu meja memindahkan
  seluruh isinya ke bill ini:
  - item apa adanya (status dapur, catatan, modifier, harga), diurutkan
    setelah item bill ini;
  - tiket dapur ikut pindah;
  - jumlah tamu dijumlah (maks 99); nama pemesan diambil dari meja yang
    digabung bila bill ini belum punya;
  - diskon nota bill ini tetap berlaku; total, service, PB1, dan pembulatan
    dihitung ulang;
  - meja yang digabung menjadi kosong dan bisa dibuka lagi.
- Ditolak dengan pesan yang jelas bila salah satu bill sedang di-split
  atau punya pembayaran bagian, bill meja yang digabung punya diskon nota,
  jumlah tamu gabungan lebih dari 99, atau meja tidak *Boleh digabung*.
- Sakelar *Boleh digabung dengan meja sebelah* kini juga ada di form meja
  *Data master › Meja & area*, sehingga toko tanpa denah bisa memakainya.
  Daftar meja menandai meja yang *Boleh digabung*.

### Catatan teknis

- `mergeOpenBills` + `BillMergeBlocked(BillMergeReason)` di
  `lakuna_data` (satu transaksi: item, tiket, bill sumber soft delete,
  total tujuan dihitung ulang); `DiningTableDraft.canMerge` (`null` =
  tidak berubah).
- `DiningRepository.mergeBill`; `DiningViewModel.merge`,
  `canMergeInto`, `mergeSources`.
- Temuan review yang diperbaiki sebelum rilis: dialog tidak lagi
  menawarkan bill yang pasti ditolak (di-split, ada pembayaran bagian,
  atau berdiskon nota) dan aksi nonaktif selama bill ini di-split; bill
  sumber langsung hilang dari layar walau muat ulang ringkasan gagal; tes
  outbox sinkronisasi; spec dirapikan (cabang lain = bill tidak
  ditemukan, jejak gabung dicatat sebagai gap).
- Uji manual di aplikasi Linux (Xvfb): M1 diatur *Boleh digabung* dari
  denah dan M2 dari form meja; M2 (3 tamu, 2 item sudah di dapur) digabung
  ke M1 (2 tamu, 2 item baru) → M1 5 tamu, 4 item dengan status dapur
  tetap, total Rp 25.000; M2 kosong; bill gabungan dibayar tunai dan struk
  memuat keempat item.

## [0.39.0] - 2026-11-13

Struk kini bisa memuat logo toko, di printer thermal maupun PDF.

### Ditambahkan

- **Logo di struk (1.26, F1-06b).** *Pengaturan › Struk & printer* punya
  bagian *Logo struk*: kotak pratinjau, *Pilih logo* / *Ganti logo*,
  *Hapus logo*, dan sakelar *Tampilkan logo di struk*.
  - Berkas PNG atau JPG sampai 1 MB, diperiksa dari isi berkas. Berkas
    tidak didukung atau terlalu besar menampilkan pesan di bawah kotak.
  - Logo disimpan per cabang bersama pengaturan struk saat *Simpan*.
    Memilih logo baru otomatis menyalakan sakelar; sakelar nonaktif bila
    belum ada logo.
  - Logo dicetak di tengah di atas nama toko pada struk penjualan, cetak
    ulang dari riwayat, kuitansi pelanggan, tes cetak, dan rekap sesi
    kasir. Tiket dapur dan cek pesanan meja tetap tanpa logo.
  - **Printer thermal (ESC/POS)**: logo diperkecil ke lebar maks 256 titik
    (58 mm) / 384 titik (80 mm) dan tinggi maks 160 titik, diubah ke
    hitam putih (transparan = putih, dithering Floyd–Steinberg), lalu
    dikirim sebagai gambar raster `GS v 0` selebar area cetak dengan logo
    di tengahnya, sehingga tetap di tengah pada printer yang mengabaikan
    perintah rata tengah untuk gambar.
  - **PDF / dialog cetak**: gambar asli, lebar maks 60 % area cetak dan
    tinggi maks 20 mm; tinggi halaman ikut bertambah.
  - **Pratinjau layar** (pengaturan, layar sukses kasir, cetak ulang,
    kuitansi) menampilkan logo di atas kertas struk.
  - Logo yang gagal dibaca atau didekode dilewati; struk tetap dicetak.
  - Dialog pilih logo hanya menawarkan PNG dan JPG.

### Catatan teknis

- `MediaKind.receiptLogo` (enum disimpan sebagai nama, tanpa migrasi).
- `lakuna_domain`: `checkReceiptLogo`, `maxReceiptLogoBytes`,
  `receiptLogoMaxDots`, `MonoBitmap`, `monoBitmapFromRgba` (luminans
  bilangan bulat, dithering), `encodeEscPos(..., logo:)`.
- `lakuna_data`: `ReceiptSettings.logoMediaId` / `showLogo`,
  `saveReceiptSettings(..., logo:, removeLogo:)` menyimpan berkas lewat
  `media_files` cabang, `ReceiptConfig.logoBytes` hanya bila logo tampil
  dan berkasnya ada, `ReceiptLogoInvalid`.
- `lakuna_flutter`: `receiptLogoBitmap` (dekode `dart:ui` ke RGBA),
  `buildReceiptPdf(..., logo:)`, `receiptPageFormat(..., extraPt:)`,
  `ReceiptPrinter.print/sharePdf(..., logo:)`, `ReceiptPaperView(logo:)`.
- Temuan review yang diperbaiki sebelum rilis:
  - Logo baru yang sakelarnya dimatikan sebelum *Simpan* menyala lagi
    setelah disimpan; kini sakelar mengikuti pilihan pemilik.
  - Berkas PNG/JPG dengan header sah tetapi isi rusak membuat semua cetak
    PDF dan *Bagikan PDF* gagal; kini PDF dibuat ulang tanpa logo.
  - Piksel semi-transparan dihitung dua kali alfanya (warna premultiplied)
    sehingga tercetak terlalu gelap; kini memakai RGBA lurus.
  - Pencarian berkas logo kini dibatasi cabang dan jenis media
    `receiptLogo`; id logo dipertahankan saat baris medianya belum ada di
    perangkat (siap sinkronisasi Fase 2).
  - *Pilih logo* dan *Hapus logo* nonaktif selama menyimpan.
- Uji manual di aplikasi Linux (Xvfb): logo PNG 400×160 dipilih dan
  disimpan; tes cetak ke printer jaringan tiruan menerima `ESC @`,
  `ESC a 1`, `GS v 0` 384×154 titik (80 mm) yang terbaca "KOPI", lalu
  nama toko; PDF cetak ulang memuat gambar logo selebar 43 mm; sakelar
  dimatikan → pratinjau dan byte cetak tanpa logo.

## [0.38.0] - 2026-11-13

Rekap kas laci kini bisa dicetak saat menutup sesi kasir.

### Ditambahkan

- **Cetak rekap sesi kasir (1.3, F1-03b).** Bila perangkat punya printer
  struk langsung (Bluetooth atau jaringan), tombol di form tutup sesi
  menjadi *Tutup sesi & cetak rekap* dan rekap langsung dicetak sekali
  setelah sesi tertutup.
  - Kartu hasil kini punya tombol *Cetak rekap* (printer terpilih, atau
    dialog cetak sistem bila belum ada printer) dan *Bagikan PDF* (share
    sheet di ponsel, folder struk di desktop). Cetak gagal menampilkan
    pesan printer yang sama dengan struk; sesi tetap tertutup dan rekap
    bisa dicetak ulang.
  - Isi rekap: nama toko dan cabang, judul *REKAP SESI KASIR*, perangkat,
    jam buka/tutup dan nama staf; transaksi, penjualan, tunai, non-tunai,
    kredit, void/retur; saldo awal, penjualan tunai, retur tunai, uang
    masuk/keluar; daftar gerakan kas; rincian pecahan yang dihitung; lalu
    seharusnya di laci, uang dihitung, selisih, dan catatan selisih.
  - Lebar kertas 58/80 mm mengikuti *Pengaturan › Struk & printer*; jam
    memakai zona waktu cabang.

### Diubah

- Jam di kartu *Sesi kasir ditutup* memakai zona waktu usaha bila cabang
  belum punya zona waktu sendiri, sama dengan struk.

### Catatan teknis

- `ReceiptContent.sections` di `lakuna_domain`: blok pasangan label–nilai
  setelah info nota, masing-masing dipisah garis.
- `sessionRecapContent` + `SessionRecap` di
  `lib/ui/cash_session/session_recap_content.dart`.
- `CashSessionViewModel` menerima `ReceiptSettingsRepository`,
  `ReceiptPrinter`, nama staf, dan zona waktu; command `printRecap` /
  `shareRecap`, `autoPrintRecap` sekali per sesi. Nama berkas
  `rekap-sesi-<yymmdd>-<HHmm>.pdf` (jam cabang).
- Temuan review dan uji manual yang diperbaiki sebelum rilis:
  - Pesan *Struk gagal dicetak* tetap tampil setelah *Bagikan PDF*
    berhasil; kini hanya hasil aksi terakhir yang tampil.
  - Hasil cetak/PDF sesi sebelumnya terbawa ke kartu sesi berikutnya.
  - Printer *Dialog cetak sistem* membuka dialog cetak sendiri setelah
    tutup; kini cetak otomatis hanya untuk printer langsung.
  - Rekap kini memakai data sesi yang dimuat ulang tepat sebelum tutup
    agar barisnya selalu cocok dengan seharusnya di laci.
  - Nama berkas PDF memakai jam perangkat, bukan jam cabang.
- Uji manual di aplikasi Linux (Xvfb): sesi dengan 20 transaksi dan 5
  gerakan kas ditutup pas (Rp 728.403); printer jaringan yang tidak
  terjangkau menampilkan pesan, lalu *Bagikan PDF* menyimpan rekap 80 mm
  yang isinya diperiksa baris per baris.

## [0.37.0] - 2026-11-13

Produk kini bisa diberi foto agar kasir lebih cepat mengenali barang.

### Ditambahkan

- **Foto produk (1.16, F1-07f).** Kotak foto di kiri atas *Info dasar*
  form produk dengan tombol *Pilih foto* / *Ganti foto*, *Ambil foto*
  (kamera, hanya Android/iOS), dan *Hapus foto*.
  - Satu foto per produk (bukan per varian). PNG, JPG, atau WebP sampai
    2 MB, diperiksa dari isi berkas, bukan dari nama. Foto kamera
    dikecilkan ke lebar 1.600 px.
  - Foto baru langsung tampil sebagai pratinjau, tetapi baru tersimpan saat
    *Simpan* (produk baru: setelah produknya tersimpan). Berkas tidak
    didukung, terlalu besar, atau kamera yang tidak bisa dibuka
    menampilkan pesan di bawah kotak tanpa mengganggu isian lain.
  - Bila produk tersimpan tetapi fotonya gagal, form tetap terbuka dengan
    pesan *Produk tersimpan, foto gagal disimpan*; *Simpan* lagi hanya
    mengubah produk itu.
- Foto tampil di **Daftar produk 1.15** (tabel dan kartu ponsel), kartu
  produk **Kasir 1.4**, dan daftar menu meja F&B. Produk tanpa foto, atau
  yang berkas fotonya belum ada di perangkat atau rusak, tetap memakai
  kotak inisial.

### Diubah

- Arsip, pulihkan, simpan ulang, dan import produk tidak mengubah foto.
  Backup sudah membawa folder `media/`, jadi foto ikut dipulihkan.

### Catatan teknis

- Kolom baru `products.photo_media_id` → `media_files`
  (`MediaKind.productPhoto`, `outlet_id` kosong karena produk berlaku untuk
  semua cabang); migrasi `foto-produk`.
- `setProductPhoto` / `clearProductPhoto` di `lakuna_data`
  (`LakunaStore.write` + `SyncTx`, versi produk naik, izin
  `products:manage`); berkas disimpan sekali di `media/<sha256>.<ext>`.
  `ProductPhotoInvalid` untuk berkas bukan gambar atau lebih dari
  `ProductLimits.photoMaxBytes`.
- `CatalogProduct.photoMediaId` / `photoPath`; `ProductThumb` mendekode
  gambar seukuran tampilan (`cacheWidth`) dengan cadangan inisial.
- `CatalogRepository.setPhoto` / `clearPhoto`; `ImageFilePicker.takePhoto`
  menerima `maxWidth`.
- Temuan review yang diperbaiki sebelum rilis:
  - Menyimpan ulang produk baru setelah fotonya gagal membuat varian baru
    dan mencatat stok awal dua kali. Kini form diisi ulang dari produk yang
    sudah tersimpan (ID varian, tanpa stok awal) dan judulnya menjadi
    *Edit produk*.
  - Foto yang berkasnya belum ada di perangkat tidak bisa dihapus; kini
    tombol *Hapus foto* mengikuti data foto, bukan berkasnya.
  - Galat kamera (mis. izin ditolak) tidak ditangkap; kini tampil sebagai
    pesan.
  - Foto kamera 2.400 px bisa melewati batas 2 MB; foto produk kini
    1.600 px.
  - Foto melebar terlihat buram di kartu Kasir; gambar kini didekode dua
    kali lebar kotak.
- Uji manual di aplikasi Linux (Xvfb): foto PNG dipilih di form Kopi
  Sachet, tampil sebagai pratinjau, tersimpan, lalu muncul di daftar produk
  dan kartu Kasir; *Hapus foto* + *Simpan* mengembalikan kotak inisial;
  form dan kartu daftar di lebar ponsel 360 px.

## [0.36.0] - 2026-11-13

Label harga + barcode kini bisa dicetak untuk ditempel di rak atau barang.

### Ditambahkan

- **Cetak label barcode (1.15b, F1-07e).** Halaman baru dari tombol *Cetak
  label* di Produk & stok (ikon barcode di ponsel) atau dari form produk.
  - Satu baris per varian, plus satu baris per satuan konversi yang punya
    barcode sendiri (mis. *dus*, dengan harga satuannya). Kode yang dicetak
    adalah barcode, atau SKU bila barcode kosong; baris tanpa keduanya
    nonaktif dengan keterangan *Tanpa barcode/SKU*.
  - Centang baris, atur jumlah 1–999 (− / + atau ketik), *Isi sesuai stok*,
    cari nama/SKU/barcode, saklar *Hanya yang dipilih*. Dibuka dari form
    produk, baris produk itu sudah dicentang dan saklar langsung aktif.
  - Kertas: *A4 · 24 label (3 × 8)* untuk kertas stiker, dengan *Lewati
    label pertama* untuk lembar yang sebagian sudah terpakai; *Label
    50 × 30 mm* dan *38 × 25 mm* untuk printer label (satu label per
    halaman).
  - Isi label: nama (maks. 2 baris), harga (bisa disembunyikan), barcode
    dengan teks kode. Pratinjau satu label di layar, jumlah label dan
    halaman, batas 2.000 label per cetak.
  - *Cetak* membuka dialog cetak sistem dengan ukuran kertas label yang
    dipilih; *Simpan PDF* membagikan PDF di ponsel atau menyimpannya di
    folder Dokumen di desktop.
- Aturan simbologi di `lakuna_domain` (`labelSymbology`, `eanCheckDigit`):
  13/8/12 digit dengan digit periksa benar dicetak sebagai EAN-13 / EAN-8 /
  UPC-A, kode lain sebagai Code 128; kode di luar ASCII cetak tidak bisa
  dicetak.

### Diubah

- Tombol di kepala halaman (mis. Produk & stok) kini turun baris bila tidak
  muat, alih-alih meluap ke kanan di tablet.

### Catatan teknis

- `BarcodeLabelPaper`, `BarcodeLabel`, `BarcodeLabelSheet`,
  `buildBarcodeLabelPdf` (paket `pdf`, `BarcodeWidget`, font PDF yang sama
  dengan kuitansi). Pratinjau layar memakai SVG dari paket `barcode` lewat
  `flutter_svg`, tanpa aset jaringan.
- `BarcodeLabelViewModel` + `labelRows`; rute `/produk/label` (dengan
  `?produk=<id>`), dijaga izin `products:manage` seperti layar produk lain.
- `ReceiptPrinter.printDocument` menerima `format` (bawaan A5 untuk
  kuitansi).
- `PageHeader` membatasi lebar tombol aksi 60 % agar `Wrap` turun baris.
- Temuan review yang diperbaiki sebelum rilis:
  - Dialog cetak sebelumnya selalu dibuka dengan kertas A5, sehingga lembar
    A4 dan label kecil tercetak salah ukuran.
  - Galat cetak tetap tampil setelah *Simpan PDF* berhasil; kini hanya hasil
    aksi terakhir yang ditampilkan.
  - Kolom jumlah 0 dan *Lewati* > 23 kini langsung dibetulkan di kolomnya;
    tombol − / + tidak lagi membuat kolom jumlah baris lain kehilangan
    fokus.
  - Pencarian SKU kini juga menemukan varian yang barcodenya terisi.
- Uji manual di aplikasi Linux (Xvfb): Air Mineral dan Beras Premium 5 kg
  dipilih, *Isi sesuai stok* menjadi 51 + 6 = 57 label · 3 halaman, PDF A4
  tersimpan 3 halaman; dari form Kopi Sachet baris produk itu langsung
  terpilih.

## [0.35.0] - 2026-11-13

Produk yang tidak dijual lagi kini bisa diarsipkan dan dipulihkan.

### Ditambahkan

- **Arsipkan produk (1.16, F1-07d).** Tombol *Arsipkan produk* ada di bawah
  form ubah produk. Dialog konfirmasi menjelaskan bahwa produk hilang dari
  Kasir, daftar produk, stok, dan pembelian, sedangkan riwayat penjualan
  dan pembelian tetap tersimpan. Bila produk masih punya stok, dialog
  menambahkan peringatan *Stok tersisa 24 botol tidak dihitung lagi di stok
  dan nilai stok*.
- **Produk diarsipkan (1.15).** Tombol *Diarsipkan (n)* tampil di daftar
  produk bila ada arsip (ikon di ponsel). Dialognya memuat produk
  diarsipkan beserta kategori dan stok terakhir, dengan tombol *Pulihkan*
  per produk.
- Pulihkan memeriksa ulang SKU dan barcode. Bila kodenya sudah dipakai
  produk lain, pemulihan ditolak dengan pesan yang menyebut produk
  pemakainya.

### Diubah

- Barcode dan SKU produk diarsipkan boleh dipakai produk baru, karena
  pemeriksaan kode kembar hanya melihat produk aktif.

### Keamanan

- Arsip dan pulihkan butuh izin `products:manage`, dicek di repositori
  seperti simpan produk.

### Catatan teknis

- Arsip = hapus lunak `products.deleted_at` lewat `SyncTx.update` (versi
  naik, tercatat di outbox). Varian, satuan, dan tingkat grosir tidak
  diubah, sehingga nota, pembelian, dan ledger stok lama tetap menunjuk
  varian yang sama. Semua kueri katalog, Kasir, stok, dan pembelian yang
  sudah menyaring `deleted_at` otomatis menyembunyikannya.
- `archiveProduct`, `restoreProduct`, `listArchivedProducts`,
  `countArchivedProducts`, `CatalogProduct.archivedAt`,
  `ProductCatalog.archivedCount`, `CatalogRepository.archive / archived /
  restore`, `ArchivedProductsViewModel`.
- Dialog konfirmasi arsip bisa digulir; tanpa itu tombolnya keluar layar di
  ponsel 360 px (ditemukan oleh tes widget).
- Temuan review yang diperbaiki sebelum rilis:
  - Daftar produk dimuat ulang setiap kali dialog *Produk diarsipkan*
    ditutup, termasuk lewat latar atau Esc, sehingga produk yang dipulihkan
    langsung tampil. Tombol *Tutup* nonaktif selama pemulihan berjalan.
  - Satuan yang dipakai produk diarsipkan tidak bisa dihapus di Master
    data. Kategori yang terhapus selama produk diarsipkan dilepas saat
    pemulihan, sehingga produk kembali tanpa kategori, bukan menunjuk
    kategori terhapus.
  - Tombol *Simpan* nonaktif selama produk diarsipkan.
- Uji manual di aplikasi Linux (Xvfb): Kopi Sachet diarsipkan dengan
  peringatan stok tersisa 33 sachet, hilang dari daftar (11 produk aktif,
  tombol *Diarsipkan (1)*), tampil di dialog dengan kategori dan stok
  terakhir, lalu dipulihkan kembali menjadi 12 produk.

## [0.34.0] - 2026-11-13

Harga grosir kini bisa dikhususkan untuk grup pelanggan.

### Ditambahkan

- **Harga grosir per grup pelanggan (1.16, 1.4, F1-07c).** Kolom *Berlaku
  untuk* di tab *Harga grosir* form produk kini bisa dipilih: *Semua
  pelanggan* atau salah satu grup pelanggan (mis. *Reseller*). Harga grup
  boleh berlaku sejak 1 satuan, jadi bisa dipakai sebagai harga reseller.
- Kasir menghitung ulang harga keranjang saat pelanggan dipilih, diganti,
  dihapus, dibuat baru, atau dipilih dari panel kredit. Bila tingkat umum
  dan tingkat grup sama-sama berlaku, harga yang **lebih murah** dipakai.
  Potongannya tampil sebagai *Diskon grosir* seperti biasa.
- Nota tersimpan dan draf keranjang membawa grup pelanggan, sehingga harga
  tetap sama saat nota dilanjutkan.

### Diubah

- Jumlah mulai yang sama kini boleh dipakai di grup berbeda (mis. ≥5 untuk
  semua pelanggan dan ≥5 untuk Reseller). Dalam satu grup tetap tidak
  boleh kembar.
- Teks bantuan tab *Harga grosir* menjelaskan harga grup.
- Grup pelanggan yang masih dipakai harga grosir produk tidak bisa
  dihapus; pesannya meminta mengubah harga grosir dulu.

### Catatan teknis

- Kolom baru `price_tiers.customer_group_id` (nullable, relasi ke
  `customer_groups`), migrasi `grosir-grup`. `null` = semua pelanggan,
  jadi data lama tidak berubah.
- Domain: `PriceTier.groupId`, `tierFor(..., groupId:)`,
  `priceSaleLine(..., customerGroupId:)`; validasi kembar dihitung per
  grup, dan tingkat grup cukup mulai > 0.
- Data: `checkoutSale` dan `parkSale` menghitung harga dengan grup
  pelanggan nota (pelanggan kredit atau pelanggan terpilih), sehingga total
  di Kasir sama dengan yang disimpan. `ParkedSale.customerGroupId`,
  `ProductCatalog.customerGroups`, galat baru `PriceTierGroupNotFound` dan
  `CustomerGroupHasPrices`.
- Harga grup belum dipakai di open bill F&B (bill belum berpelanggan saat
  item ditambahkan) dan di satuan konversi (grosir hanya untuk satuan
  dasar); keduanya dicatat sebagai gap di spec F1-07c.
- Temuan review yang diperbaiki sebelum rilis:
  - Tingkat grosir yang harganya tidak lebih murah dari harga jual kini
    diabaikan. Sebelumnya, bila harga jual diturunkan di bawah harga
    reseller, pelanggan grup justru membayar lebih mahal dan *Diskon
    grosir* tersimpan negatif.
  - Draf keranjang yang dipulihkan memakai grup pelanggan terbaru. Bila
    grup pelanggan diubah di menu Pelanggan saat keranjang masih terisi,
    harga Kasir kini tetap sama dengan total yang disimpan.
  - Kolom grosir di daftar produk 1.15 hanya menampilkan tingkat umum, dan
    catatan baris Kasir menulis *harga grup ≥ 1* untuk harga grup.
- Uji manual Xvfb: Gula Pasir 1 kg diberi harga Grosir Rp16.500 mulai 1
  pak. Kasir tanpa pelanggan Rp35.000 untuk 2 pak; setelah Toko Bu Ani
  (grup Grosir) dipilih, Rp33.000 dengan *Diskon grosir* Rp2.000. Nota
  tunai tersimpan dengan total Rp33.000.

## [0.33.0] - 2026-11-13

Pelanggan baru bisa dibuat langsung dari Kasir.

### Ditambahkan

- **Tombol *Pelanggan baru* di Kasir (1.4b, 1.5b, F1-04f).** Tombol ini
  ada di dialog *Pilih pelanggan* dan di panel *Kredit / piutang*. Form
  yang dibuka sama dengan menu Pelanggan 1.20: nama, HP, grup atau grup
  baru, limit kredit, alamat, dan catatan.
- Kata pencarian menjadi isian awal form. Huruf masuk ke nama, sedangkan
  angka (boleh dengan `+`, spasi, atau `-`) masuk ke nomor HP.
- Setelah disimpan, pelanggan baru langsung dipasang di nota. Dari panel
  kredit, pelanggan baru langsung terpilih dengan jatuh tempo dari tempo
  grupnya. Keranjang dan pilihan bayar tidak berubah.

### Keamanan

- Tombol hanya tampil untuk staf dengan izin `customers:manage`.
  Repositori pelanggan tetap memeriksa izin saat menyimpan.

### Catatan teknis

- `CashierData.canAddCustomer`, `CashierViewModel.useNewCustomer` /
  `useNewCreditCustomer`, `CustomerFormScope` (repositori pelanggan dari
  router ke `CashierScreen`, diteruskan ke sheet pesanan ponsel), dan
  `showCustomerForm(initialName:, initialPhone:)`.
- Temuan review yang diperbaiki sebelum rilis:
  - Nomor HP dari kata pencarian kini dinormalisasi lebih dulu, sehingga
    `0812-3456-7890` tidak tampil sebagai `0812--3456--7890`. Nomor
    minimal 6 digit; teks yang lebih pendek dianggap nama.
  - Bila daftar kredit gagal dimuat ulang setelah pelanggan baru disimpan,
    pelanggan nota tidak berubah dan galat muat tampil.
- Uji manual Xvfb:
  - Dari pencarian "Siti Rahma": *Pelanggan baru*, isi HP, simpan, lalu
    nota langsung atas nama Siti Rahma.
  - Dari panel kredit: "Warung Sari" dengan limit Rp500.000 langsung
    terpilih, jatuh tempo +14 hari.

## [0.32.0] - 2026-11-13

Bill meja dan take away F&B kini bisa diberi diskon nota.

### Ditambahkan

- **Diskon nota di open bill F&B (1.7, F1-04e).** Tombol *Diskon* di panel
  bill membuka dialog *Diskon nota* yang sama dengan Kasir: persen atau
  rupiah, pratinjau potongan, dan *Hapus diskon*. Baris *Diskon nota 10%
  · disetujui Rina* tampil di blok total panel bill (ketuk untuk mengubah)
  dan di ringkasan bill tahap pembayaran 1.5.
- Service dan PB1 dihitung dari subtotal setelah diskon, lalu pembulatan
  total. Diskon persen mengikuti perubahan item; diskon rupiah dipangkas
  ke subtotal bila item berkurang.
- Split bill membagi total setelah diskon. Diskon juga berlaku saat bill
  ditutup sebagai kredit.
- Struk, riwayat, laporan, dan retur memakai potongan efektif yang
  tersimpan di nota, sama dengan diskon nota retail.

### Diubah

- Bila item berkurang sampai diskon menghabiskan total bill, *Tutup &
  bayar* dan *Split bill* dimatikan dan panel menampilkan pesan sampai
  diskon diubah.

### Keamanan

- Aturan izin sama dengan diskon Kasir (F1-04b). Staf dengan
  `sales:discount` langsung menerapkan. Staf lain meminta PIN manajer bila
  sakelar *Diskon manual butuh PIN manajer* hidup, dan penyetuju dicatat.
  Bila sakelar mati, tombol tidak muncul. Repositori memeriksa ulang PIN
  yang baru dimasukkan (sekali pakai), dan lapisan data memeriksa ulang
  izin lewat `requireDiscountActor`.
- Diskon tidak bisa diubah setelah ada pembayaran bagian split
  (`SplitLocked`). Lapisan data juga menolak diskon yang menghabiskan
  total (`DiscountTooLarge`), baik saat diterapkan maupun saat dibayar.

### Catatan teknis

- `fnbCharges(..., discount:)` dan `FnbCharges.discount`: total =
  subtotal − diskon + service + PB1 (bila tidak termasuk) + pembulatan.
- `setBillDiscount` menyimpan pilihan di baris `sales` yang masih open:
  persen di `discount_bp`, rupiah di `discount_amount`, penyetuju di
  `discount_approved_by`. Tidak ada kolom atau migrasi baru. Saat bill
  selesai, `_completeBill` menulis potongan efektif ke `discount_amount`.
- `DiningRepository.setDiscount` (lokal dan palsu),
  `DiningViewModel.setDiscount`, `billDiscountIssue`, `discountBlocksPay`.
  Label baris diskon dipakai bersama Kasir, panel bill, dan pembayaran
  (`billDiscountRowLabel`).
- Temuan review yang diperbaiki sebelum rilis: layar split menampilkan
  pesan diskon (bukan galat umum) bila diskon menghabiskan total, tombol
  bayar bill di Kasir ikut mati dalam keadaan itu, dan diskon tetap bisa
  dihapus dari bill yang itemnya sudah habis.
- Uji manual Xvfb: bill M2 Rp5.500 diskon 10% → service 248, PB1
  termasuk 473, pembulatan −198, total Rp5.000; split rata 3 tamu
  (1.667 / 1.667 / 1.666); tombol *Diskon* hilang setelah bagian pertama
  dibayar; struk mencetak *Discount 10% −550*.
- Pengembangan dilanjutkan lagi pada 2026-11-13 setelah jeda.
  `docs/superpowers/STATUS-JEDA.md` kini mencatat titik lanjut.

## [0.31.0] - 2026-11-04

Daftar barang dari Excel kini bisa dimasukkan sekaligus.

### Ditambahkan

- **Import Excel / CSV di Produk 1.15 (F1-07b).** Tombol *Import Excel* di
  header daftar produk (ikon di ponsel) dan di daftar kosong membuka dialog
  pratinjau. Satu baris = satu produk satu varian dengan kolom Nama dan
  Harga jual (wajib), Kategori, Jenis (barang/jasa/menu), Satuan (bawaan
  `pcs`), SKU, Barcode, Harga beli (juga dikenali sebagai HPP/harga pokok),
  Stok awal, dan Stok minimum; judul kolom boleh Indonesia atau English.
  Baris yang salah ditolak dengan nomor baris dan alasannya sebelum
  disimpan. Stok awal masuk ledger sebagai *stok awal*, kategori dan satuan
  baru dibuat otomatis.
- Produk yang nama, SKU, atau barcode-nya sudah ada **dilewati, bukan
  ditimpa**, sehingga import ulang berkas yang sama tidak menggandakan
  produk atau stok; ringkasan menyebut baris yang dilewati.

### Diperbaiki

- Sel angka berpecahan dari XLSX (mis. `2.375`) kini dibaca dengan koma
  desimal, sehingga tidak terbaca 2.375 ribu.
- Tombol di dialog import pelanggan tidak lagi meluap di layar 360 px.

### Keamanan

- Import butuh izin `products:manage`, dicek di repositori; semua baris
  diperiksa ulang di lapisan data dan disimpan dalam satu transaksi.

### Catatan teknis

- `productImportRows` (domain) dan `importProducts` (data) memakai
  `_ProductWriter` yang sama dengan form produk dalam satu `LakunaStore.write`;
  cek kode kembar sekali untuk seluruh berkas, lokasi stok dan kategori
  di-cache, tautan modifier tidak dikueri untuk produk baru.
- Jumlah stok `1,500` ditolak karena ambigu (ribuan Inggris atau 1,5).
- Dialog import (produk dan pelanggan) tidak bisa ditutup selama
  menyimpan.
- Uji manual Xvfb: CSV 6 baris → 3 produk baru, 1 dilewati karena sudah
  ada, 2 ditolak (jenis tidak dikenal, harga kosong).
- Pengembangan dijeda setelah rilis ini atas permintaan pemilik; titik
  berhenti dan gap berikutnya dicatat di `docs/superpowers/STATUS-JEDA.md`.

## [0.30.0] - 2026-11-04

Meja dan pesanan take away F&B kini bisa ditutup sebagai nota kredit.

### Ditambahkan

- **Kredit / piutang saat *Tutup & bayar* open bill (1.5b, F1-13b).**
  Metode *Kredit / piutang* yang sebelumnya hanya ada di kasir retail kini
  muncul juga saat menutup bill meja atau take away. Kasir memilih
  pelanggan, mengisi DP (boleh 0, masuk laci tunai sesi kasir) dan jatuh
  tempo; sisa total bill (termasuk service, PB1, dan pembulatan) menjadi
  piutang pelanggan. Nota muncul di Riwayat *Belum lunas*, di daftar
  piutang Pelanggan 1.20, dan di rekap sesi kasir sebagai *Penjualan
  kredit*. Struk mencetak *Tunai* (DP), *Piutang*, dan *Jatuh tempo*.

### Diubah

- Nama pelanggan kredit menggantikan nama take away pada nota yang
  dibayar kredit, agar nota tercatat atas nama pelanggan yang berutang.

### Keamanan

- Kredit open bill butuh izin `debts:manage`, diperiksa di repositori dan
  lagi di lapisan data; limit kredit dan DP diperiksa ulang di dalam
  transaksi tulis.

### Catatan teknis

- `payOpenBill(..., credit:)` memakai `checkSaleCredit` yang sama dengan
  kasir retail; bila `credit` diisi, `payments` harus kosong (DP dicatat
  sebagai pembayaran tunai tanpa kembalian). `_completeBill` menyimpan
  `paidAmount`, pelanggan, dan `dueOn` dari kredit.
- Kredit tidak tersedia untuk bagian split bill atau bill yang sudah punya
  pembayaran bagian: view model menyembunyikan metode itu, dan lapisan
  data menolak lewat `SplitLocked`.
- Tes baru: data (DP, limit, izin, dine-in dengan service/PB1/pembulatan,
  ringkasan sesi, bill split terkunci), view model, dan widget 1280 / 360
  px. Uji manual Xvfb: meja M1 Rp18.500, DP Rp5.000, piutang Rp13.500.

## [0.29.1] - 2026-11-04

Foto ponsel vertikal tidak lagi dianggap mendatar saat diunggah.

### Diperbaiki

- **Peringatan "tidak vertikal" palsu untuk foto ponsel.** Ponsel sering
  menyimpan foto vertikal sebagai gambar mendatar plus tag EXIF "putar
  90°". Lakuna membaca lebar/tinggi dari header JPEG sebelum rotasi itu,
  sehingga stiker QRIS hasil foto ponsel (1.6 / 1.26b) diberi peringatan
  bentuk yang keliru. Kini tag Orientation EXIF dibaca dan, untuk
  orientasi 5–8 (diputar 90°/270°), lebar dan tinggi ditukar sesuai
  tampilan sebenarnya.

### Catatan teknis

- `readImageHeader` (`packages/lakuna_domain/lib/src/image_header.dart`)
  membaca segmen APP1 `Exif`, header TIFF big-endian (`MM`) maupun
  little-endian (`II`), dan tag 0x0112 di IFD0 (SHORT atau LONG). Segmen
  Exif pertama yang sah menang, seperti dekoder Skia. EXIF yang rusak atau
  terpotong diabaikan sehingga ukuran SOF tetap dipakai.
- Tes baru di `packages/lakuna_domain/test/qris_test.dart`: orientasi 1–8,
  tipe LONG, XMP sesudah Exif,
  urutan byte `II`, dan offset IFD rusak.
- Gap *Orientasi EXIF JPEG* di spec F1-18 ditutup.

## [0.29.0] - 2026-11-04

Pelanggan di nota dan **nota tersimpan** di Kasir retail (F1-04d, layar
1.4b; di HP lewat lembar pesanan 1.11).

### Ditambahkan

- **Pelanggan di nota.** Kepala panel Pesanan kini berisi kolom
  *Pelanggan umum*. Ketuk untuk membuka dialog **Pilih pelanggan**: cari
  nama atau nomor HP, tiap baris menampilkan HP · grup, *Sisa limit* (bila
  pelanggan punya limit kredit), dan lencana *Lewat tempo*. Tombol **×**
  mengembalikan nota ke pelanggan umum.
- Pelanggan terpilih ikut tersimpan di nota tunai, kartu, transfer, QRIS,
  dan split (bukan hanya kredit) dan tercetak di struk. Nota non-kredit
  tetap lunas, tidak menjadi piutang. Mode *Kredit* di layar Bayar memakai
  pelanggan ini sebagai pilihan awal.
- **Simpan nota (parkir).** Tombol **Simpan** di samping *Bayar* menyimpan
  keranjang yang belum dibayar, lengkap dengan diskon baris/nota dan
  pelanggan. Tanpa pelanggan, kasir bisa menambah *Catatan* (mis. "Meja
  depan", maks. 40 karakter). Stok **belum** berkurang dan tidak ada
  pembayaran yang tercatat.
- **Nota tersimpan (N)** di bilah atas Kasir (di HP: ikon + jumlah)
  membuka daftar nota tersimpan cabang: nama atau catatan, jumlah item,
  jam disimpan, kasir, dan total, dengan tombol **Lanjutkan** dan
  **Hapus** (dengan konfirmasi).
- *Lanjutkan* memuat nota ke keranjang dengan harga katalog terbaru dan
  hanya aktif saat keranjang kosong ("Simpan atau kosongkan keranjang
  dulu"). Barang yang produknya sudah dihapus dibuang dan diberi tahu.
  Nota tersimpan hilang dari daftar setelah dibayar; menyimpan lagi
  menggantikan nota lama.
- Artikel Panduan *Transaksi & harga grosir* (ID + EN) menjelaskan
  pelanggan di nota dan nota tersimpan.

### Diubah

- Tombol *Kosongkan* di bawah pesanan menjadi ikon tempat sampah agar
  *Simpan* muat. Nominal di tombol *Bayar* mengecil, tidak terpotong, di
  panel sempit.
- Pemilih pelanggan kredit (1.5b) memakai avatar inisial yang sama dengan
  pemilih pelanggan Kasir.

### Diperbaiki

- (Temuan review sebelum rilis) Menghapus baris terakhir satu per satu
  pada nota yang dilanjutkan kini melepas nota tersimpan asal dan
  pelanggannya. Sebelumnya penjualan berikutnya bisa tercatat atas nama
  pelanggan itu dan ikut menghapus nota tersimpannya yang belum dibayar.
- (Temuan review) Nota tersimpan berdiskon yang dilanjutkan kasir tanpa
  izin diskon: *Bayar* kini meminta PIN manajer dulu. Bila diskon manual
  tidak diizinkan sama sekali (tanpa izin dan sakelar PIN mati), diskon
  dilepas saat dilanjutkan dan kasir diberi tahu, alih-alih pembayaran
  gagal tanpa jalan keluar.
- (Temuan review) Bila nota tersimpan asal sudah dibayar atau dihapus di
  tempat lain, pembayaran menampilkan pesan khusus dan percobaan
  berikutnya tercatat sebagai penjualan biasa.

### Keamanan

- Menyimpan, melanjutkan, dan menghapus nota tersimpan memakai izin
  `sales:create`, diperiksa di repositori. Pelanggan diperiksa milik
  tenant dan belum dihapus.
- Membayar nota tersimpan menghapusnya (soft delete) dalam transaksi yang
  sama dengan penjualan, jadi nota yang sama tidak bisa dibayar dua kali.

### Catatan teknis

- Nota tersimpan = baris `sales` berstatus `open`, `order_type = retail`,
  tanpa meja, nomor dari urutan open bill (`OB-…`, kini `nextBillNumber`
  publik di `open_bill.dart`), beserta `sale_items` (`unit_cost` 0).
  Tanpa migrasi skema. Penghapusan ikut men-soft-delete `sale_items`-nya
  agar tidak tersinkron sebagai baris yatim.
- `packages/lakuna_data/lib/src/parked_sales.dart`: `parkSale`,
  `listParkedSales`, `loadParkedSale`, `deleteParkedSale`,
  `removeParkedSale`. Penetapan harga keranjang dipisah ke
  `priceSaleLines` di `sales.dart` dan dipakai bersama `checkoutSale`,
  yang kini menerima `customerId` dan `parkedSaleId`. `saleCustomer` di
  `customers.dart`.
- Nota tersimpan tidak muncul di Meja F&B (sudah menyaring
  `order_type != retail`), Riwayat, laporan, atau piutang (status `open`),
  dan tidak menahan tutup sesi kasir (tanpa pembayaran).
- `CashierViewModel`: `customer`, `parkedId`, `parkedNote`, command
  `customers` / `park` / `parked` / `resumeParked` / `deleteParked`,
  `discountAwaitsApproval`, `resumeDiscountDropped`. `CartDraft` membawa
  pelanggan dan nota asal. UI baru: `customer_picker.dart`,
  `parked_sales_sheet.dart`.
- Tes: 8 tes data nota tersimpan, 15 tes view model, 6 tes widget (1280 px
  dan 360 px). Total 696 tes Flutter dan 285 tes data lulus.
- Spec `2026-11-04-f1-04d-pelanggan-nota-tersimpan-design.md` dan rencana
  `2026-11-04-f1-04d-pelanggan-nota-tersimpan.md`.

## [0.28.1] - 2026-11-04

Keranjang kasir tidak lagi hilang saat kasir membuka menu lain (F1-04c,
layar 1.4 / 1.11).

### Diperbaiki

- **Keranjang Kasir hilang saat pindah menu.** Kasir yang membuka Beranda,
  Stok, atau menu lain lalu kembali ke Kasir kini menemukan keranjangnya
  utuh: baris, jumlah, satuan, diskon baris, diskon nota, dan penyetuju
  diskon. Penyebabnya, keranjang hidup di view model layar Kasir yang
  dibuang setiap kali layar ditutup.
- Saat dipulihkan, harga dan nama mengikuti katalog terbaru. Produk,
  varian, atau satuan konversi yang sudah dihapus atau dinonaktifkan
  dibuang dari keranjang.

### Keamanan

- Keranjang dikosongkan saat staf berganti (*Ganti kasir* atau logout),
  jadi tidak berpindah ke staf lain. Persetujuan diskon tetap diperiksa
  ulang saat bayar.
- Keranjang yang sedang disimpan saat layar ditutup **tidak** dipulihkan
  setelah notanya tercatat, sehingga tidak bisa terbayar dua kali. Bila
  penyimpanan gagal, keranjang tetap dibawa.

### Catatan teknis

- `CartDraft` (`lib/ui/cashier/cart_draft.dart`) dibuat sekali di
  `createRouter`, hanya di memori, dan mendengarkan `SessionRepository`.
  Rute kasir tanpa `?bill=` memberikannya ke `CashierScreen`.
- `CashierViewModel` memulihkan draf setelah `load` pertama berhasil, lalu
  menulis keranjang ke draf saat `dispose`. Draf tidak ditimpa sebelum
  dibaca (layar ditutup saat katalog belum termuat atau gagal dimuat).
- Mode bill (open bill, bagian split, struk lunas) tidak membaca dan tidak
  menulis draf.
- Tes baru: unit `CartDraft`, 9 tes draf di `cashier_view_model_test`,
  dan alur widget Kasir → Beranda → Kasir serta bayar open bill → Kasir.

## [0.28.0] - 2026-11-04

Persiapan rilis ke store dan distribusi (F1-22): ikon aplikasi Lakuna,
halaman Tentang Lakuna, pengaman nomor build, dan dokumen untuk Google Play
dan App Store.

### Ditambahkan

- **Ikon aplikasi Lakuna** di semua platform, menggantikan ikon bawaan
  Flutter: mark Etalase (etalase toko) putih di kotak gradien Sky. Android
  memakai ikon adaptive (termasuk ikon bertema Android 13), iOS kotak penuh,
  macOS mengikuti grid ikon Apple, Windows `.ico` 16–256 px, ikon `.deb`
  Linux, dan ikon web.
- **Pengaturan › Tentang Lakuna** (semua staf, termasuk kasir): versi
  aplikasi, ringkasan privasi data (data di perangkat ini; versi hosted
  belum tersedia; jaga file backup), tombol **Buka Panduan**, dan
  **Lisensi open source** yang bisa dibuka per paket. Teks lisensi tampil
  di kotak bergulir dan dirender bertahap, jadi lisensi Flutter yang
  berisi ribuan paragraf tidak membuat layar macet.
- Lisensi font bundel (Montserrat, DM Sans, DM Mono; SIL OFL 1.1) dan
  Bootstrap Icons (MIT, mark logo) ikut tampil di daftar lisensi dan dicatat
  di `NOTICE.md`.
- Dokumen pemilik di `docs/rilis/`: langkah membuat kunci Android permanen
  dan mengisi secret, Google Play Console (listing, Data safety, jalur
  internal → produksi), App Store/TestFlight, tanda tangan desktop;
  **kebijakan privasi** ID + EN untuk URL store (versi hosted ditulis
  belum tersedia; kebijakan diperbarui sebelum versi itu rilis); **teks
  listing** ID + EN dalam batas karakter Play dan App Store.
- Aset store di `docs/rilis/aset/`: ikon 512 px, feature graphic
  1024×500, dan 18 tangkapan layar asli (HP 864×1728 dan tablet 2560×1600,
  Bahasa Indonesia dan English).

### Diubah

- Cek versi rilis dipindah ke `tools/release/check-version.sh` dan juga
  dijalankan di CI setiap PR: versi baru wajib punya bagian CHANGELOG dan
  **nomor build (`+N`) wajib lebih besar** dari rilis terakhir, karena Play
  Console dan App Store menolak versionCode yang tidak naik.
- README menautkan dokumen rilis store dan menjelaskan `SHA256SUMS.txt`.

### Diperbaiki

- iOS: menambah alasan izin **Bluetooth** (cetak struk) dan **galeri
  foto** (foto produk, stiker QRIS, nota, denah) di `Info.plist`. Tanpa
  keduanya App Store menolak build dan aplikasi bisa tertutup saat
  meminta izin. Teks izin kamera diperjelas (nota, bukti bayar, denah).

### Keamanan

- Setiap GitHub Release menyertakan **`SHA256SUMS.txt`** agar unduhan
  bisa diperiksa (`sha256sum -c SHA256SUMS.txt --ignore-missing`).
- Skrip cek versi gagal dengan jelas bila tag di origin tidak bisa dibaca,
  alih-alih menganggap versi belum dirilis.

### Catatan teknis

- `registerBundledLicenses()` (`lib/config/bundled_licenses.dart`)
  dipanggil di `main()`; teks lisensi dibaca dari aset saat daftar lisensi
  pertama kali dibuka.
- `AboutViewModel` mengelompokkan `LicenseRegistry.licenses` per paket
  (urut abjad) dan menyimpan `LicenseEntry` apa adanya; paragraf baru
  diurai saat satu paket dibuka (`ListView.builder`, indentasi
  `LicenseParagraph` dihormati seperti `LicensePage`). Sumber lisensi bisa
  diganti di tes; galat apa pun menjadi `load.error`.
- Job CI baru **Versi & nomor build** menjalankan
  `tools/release/check-version.sh` di setiap PR.
- `SettingsSection.about` (`?bagian=about`) selalu ada di akhir daftar
  bagian Pengaturan.
- Ikon dibuat ulang dengan `node tools/brand/render.mjs <dir>` (Chromium
  lewat Playwright, font dibundel) lalu `python3 tools/brand/make_icons.py
  <dir>`.

## [0.27.0] - 2026-11-04

Menu **Panduan** (F1-21, layar 1.27): panduan pengguna lengkap di dalam
aplikasi, Bahasa Indonesia dan English, tetap bisa dibaca tanpa internet.

### Ditambahkan

- Layar **Panduan** di menu Sistem dan rute `/panduan` (`?artikel=<slug>`
  membuka artikel tertentu). Semua staf bisa membukanya, termasuk kasir.
- **27 artikel** dalam 7 bagian: Mulai (instalasi & akun pemilik, masuk
  dengan PIN, produk pertama, sesi kasir), Kasir (transaksi & grosir,
  diskon, tunai, QRIS statis, split payment, kredit, struk & printer,
  retur & void), F&B (meja & open bill, modifier, split bill, denah),
  Inventori (pembelian, stok, hutang supplier), Keuangan (pelanggan &
  piutang, pengeluaran, laporan), Admin (pengguna & role, pengaturan toko),
  dan Data (backup & pulihkan, versi hosted, FAQ).
- **Tangkapan layar WebP** asli aplikasi di 19 artikel, terpisah untuk
  Bahasa Indonesia dan English (960 px, total sekitar 800 KB).
- **Daftar isi** di samping artikel pada layar lebar (≥ 900 px); di HP
  daftar isi dan artikel tampil bergantian dengan tombol kembali.
- **Cari** di judul dan isi semua artikel; judul yang cocok tampil lebih
  dulu, lengkap dengan nama bagiannya.
- Tombol **ID / EN** untuk mengganti bahasa panduan tanpa mengubah bahasa
  aplikasi; bawaan mengikuti bahasa aplikasi.
- Artikel memuat breadcrumb, catatan (biru) dan peringatan (kuning) yang
  terbaca di mode gelap, tautan antar-artikel, serta tautan *sebelumnya /
  berikutnya*.
- Lencana **Tersedia offline**.

### Diubah

- Menu Panduan tidak lagi menampilkan layar "segera hadir".

### Diperbaiki

Ditemukan saat review sebelum rilis:

- Di HP (layar di bawah 900 px), mengetuk hasil pencarian kini membuka
  artikelnya; tombol kembali menampilkan hasil lagi, dan mengetik di kolom
  cari saat artikel terbuka langsung menampilkan hasil.
- Teks pencarian tidak hilang saat lebar jendela melewati 900 px (tablet
  diputar atau jendela desktop diubah ukurannya).
- Pencarian yang diketik sebelum artikel selesai dimuat diulang setelah
  pemuatan selesai, jadi tidak lagi menampilkan "tidak ada hasil" palsu.
- Meninggalkan Panduan saat artikel masih dimuat tidak memicu galat.
- Tombol ID / EN nonaktif selama daftar isi dimuat, agar bahasa tombol dan
  isi artikel tidak berbeda.
- Artikel yang gagal dimuat menampilkan pesan dengan tombol coba lagi,
  bukan panel kosong.
- Pembaca layar: tombol bahasa menyebut mana yang terpilih, dan kolom cari
  berlabel di HP juga.
- Daftar isi di HP tidak lagi memakai garis tepi dan latar panel samping.
- Artikel QRIS menyebut tombol **Perbesar gambar QRIS** yang sebenarnya.
- Parser menolak judul `###` dan dua kotak catatan tanpa baris kosong,
  agar kesalahan penulisan tertangkap tes konten.

### Catatan teknis

- Konten di `lakuna_flutter/assets/guide/`: `toc.json` (bagian dan urutan
  slug), `id/<slug>.md`, `en/<slug>.md`, `img/{id,en}/<nama>.webp`.
- `guide_markdown.dart`: parser Markdown kecil (judul `#`/`##`, paragraf,
  daftar bernomor dan berpoin termasuk poin bertingkat, `> [!note]` /
  `> [!warning]`, gambar `![keterangan](nama)`, **tebal**, *miring*,
  `[teks](slug)`), tanpa paket tambahan.
- `GuideRepository` + `AssetGuideRepository` (cache daftar isi dan
  artikel; artikel EN yang hilang jatuh ke ID), `GuideViewModel`
  (`load`, `setLanguage`, `open`, `search`).
- Tes konten memeriksa setiap slug ada di kedua bahasa dan bisa diurai,
  semua tautan artikel valid, gambar berformat WebP ≤ 150 KB, tidak ada
  berkas yatim, dan aset terdaftar di `pubspec.yaml`.

## [0.26.0] - 2026-11-04

Beranda baru (F1-20, layar 1.10): angka hari ini, akses cepat ke modul, dan
hal yang perlu ditindak, di HP maupun desktop.

### Ditambahkan

- **Sapaan** "Selamat pagi / siang / sore / malam, <nama>" menurut jam
  cabang, dengan nama toko dan cabang.
- Kartu **Penjualan hari ini** (staf dengan `reports:view`): penjualan
  bersih, jumlah transaksi, dan rata-rata per transaksi, dari laporan
  periode *Hari ini*.
- **Grid modul**: Kasir, Meja (usaha F&B / campuran), Riwayat, Produk, Stok,
  Pembelian, Pengeluaran, Pelanggan, Laporan; hanya modul yang diizinkan.
  Empat kolom di HP, enam di layar lebar.
- Kartu **Perlu perhatian** dengan tautan *Lihat*: jumlah produk di bawah
  stok minimum (ke Stok), pembayaran QRIS split bill yang menunggu
  konfirmasi (ke Meja), dan backup terakhir (hari ini / kemarin / N hari
  lalu / belum pernah; merah bila lebih dari 7 hari, ke Data & backup).
  Bila tidak ada yang perlu ditindak: "Semua beres".
- Kartu **Info perangkat** (toko, staf bertugas, versi, ID perangkat, lokasi
  data) tetap ada di bawah.
- Beranda dimuat ulang saat aplikasi kembali aktif.

### Diubah

- Kartu pengingat backup v0.25.0 di Beranda digantikan baris backup di
  *Perlu perhatian*.
- Teks sambutan lama ("Selamat datang di Lakuna") dihapus.

### Diperbaiki

Ditemukan saat review sebelum rilis:

- Galat tak terduga dari salah satu sumber data hanya menyembunyikan
  barisnya, tidak menggagalkan seluruh Beranda; setiap bagian tampil begitu
  datanya siap.
- Ubin Meja dan hitungan QRIS tidak tampil untuk usaha retail.
- Label modul yang panjang (mis. Pengeluaran) boleh dua baris di HP 360 px.
- Pembaca layar: label ubin modul tidak dibaca dua kali, dan setiap tombol
  *Lihat* menyebut barisnya.
- Jumlah hari sejak backup tidak negatif bila jam perangkat mundur.

### Catatan teknis

- `lakuna_data`: `pendingQrisCount` (pembayaran `pending` pada bill terbuka
  cabang). `DiningRepository.pendingQrisCount`.
- `HomeViewModel` memuat laporan, stok minimum, QRIS menunggu, dan backup
  secara paralel sesuai izin staf.
- `sampleStoreContext` di tes menerima `timezone` dan `businessType`.

## [0.25.0] - 2026-11-04

Data & backup (F1-19, layar 1.13): pemilik membuat backup seluruh data
perangkat ke satu berkas `.zip` dan memulihkannya ke perangkat ini atau
perangkat pengganti.

### Ditambahkan

- Bagian **Data & backup** di Pengaturan (khusus pemilik, izin
  `backup:manage`): mode *Gratis · offline*, jumlah transaksi, produk, dan
  ukuran data, serta *Backup terakhir* (hari ini / N hari lalu / belum
  pernah).
- **Backup sekarang**: membuat `lakuna-backup-<KODECABANG>-<YYMMDD-HHMM>.zip`
  berisi `manifest.json`, salinan database yang konsisten (`VACUUM INTO`,
  kasir tetap bisa jalan), dan semua gambar. Di desktop berkas disimpan ke
  folder `Dokumen/Lakuna/Backup` dan lokasinya ditampilkan; di Android/iOS
  lewat menu bagikan. Bila menu bagikan ditutup tanpa memilih, waktu backup
  tidak dicatat.
- **Pulihkan**: pilih berkas `.zip`, lihat ringkasan isi backup (toko,
  cabang, perangkat, tanggal, jumlah transaksi dan produk), ketik nama toko
  untuk konfirmasi, lalu aplikasi dimuat ulang dan kembali ke layar masuk.
  Data lama tidak dihapus: dipindah ke folder `sebelum-pulihkan-…` di
  lokasi data.
- **Pengingat backup** di Beranda untuk pemilik bila belum pernah backup
  atau backup terakhir lebih dari 7 hari lalu, dengan tombol ke *Data &
  backup*.
- **Layar gagal mulai**: bila database tidak bisa dibuka, aplikasi
  menampilkan pesan galat dan lokasi data yang bisa disalin, bukan tertutup
  tanpa pesan.
- Kartu *Aktifkan versi hosting* (alamat server, kode aktivasi) tampil
  nonaktif dengan keterangan Fase 2.

### Diubah

- Menu bagian Pengaturan di layar lebar kini bisa digulir bila tidak muat.

### Diperbaiki

Ditemukan saat pengujian dan review sebelum rilis:

- Pemasangan backup aman bila aplikasi mati di tengah jalan: langkah yang
  sudah selesai tidak diulang, sehingga data hasil pulihkan tidak ikut
  dipindah dan aplikasi tetap bisa dibuka.
- Bila database dari backup gagal dibuka, data lama dikembalikan otomatis
  dan Beranda menampilkan *Pulihkan gagal* (backup yang gagal disimpan di
  folder `pulihkan-gagal-…`).
- Berkas zip ditutup setelah diperiksa, jadi di Windows berkas backup bisa
  dipindah atau dihapus tanpa menutup aplikasi.
- Database backup diekstrak dan diperiksa checksum-nya langsung dari
  berkas, tidak ditampung di memori (aman untuk data besar di HP).
- Salinan sementara backup dihapus saat backup berikutnya dibuat.
- Dua backup di menit yang sama tidak saling menimpa (akhiran `-2`).
- *Backup terakhir* setelah pulihkan memakai waktu backup yang dipasang,
  bukan nilai lama di dalam backup.

### Keamanan

- Hanya `lakuna.sqlite` dan `media/<nama>` yang diekstrak dari backup;
  entri dengan folder, `..`, `\`, atau `:` diabaikan (zip-slip).
- Repositori menolak backup dan pulihkan tanpa izin `backup:manage`.

### Catatan teknis

- `lakuna_data`: `createBackup`, `inspectBackup`, `stageRestore`,
  `applyPendingRestore` (penanda `restore/ready` dan `restore/applying`),
  `undoRestore`, `finishRestore`, `BackupManifest` (format 1),
  `BackupInvalid`, `BackupTooNew` (versi skema backup tidak dikenal).
  Dependensi baru `archive`.
- Aplikasi: `bootstrap.dart` (merangkai repositori) dan `LakunaRoot` +
  `AppRestart` (memasang backup sebelum database dibuka, memuat ulang
  aplikasi dengan pohon widget baru). `main.dart` kini hanya
  `runApp(const LakunaRoot())`.
- `BackupRepository` / `LocalBackupRepository`, `BackupFiles`
  (`share_plus` di ponsel, salin ke folder di desktop, `file_selector` untuk
  memilih berkas), `BackupViewModel`. Waktu backup terakhir di
  `local_preferences` (`backup.last_at`).
- Rute `/pengaturan?bagian=backup` membuka bagian *Data & backup*
  langsung.
- Gap: enkripsi backup, pulihkan dari onboarding, perangkat tambahan vs
  pengganti (identitas perangkat ikut backup), dicatat di spec F1-19.

## [0.24.0] - 2026-11-04

Diskon manual di Kasir retail (F1-04b, layar 1.4b): kasir memberi diskon
per baris atau per nota, dalam persen atau rupiah. Staf tanpa izin
`sales:discount` meminta persetujuan PIN manajer di tempat (1.2b).

### Ditambahkan

- **Diskon baris**: tekan lama (atau klik kanan) baris keranjang membuka
  dialog *Diskon baris*. Dasar potongan adalah total baris setelah harga
  grosir. Baris menampilkan sub-baris "Diskon 10% · − Rp 400" dan total
  baris bersih.
- **Diskon nota**: tombol diskon (ikon) di samping *Kosongkan* membuka
  dialog *Diskon nota*. Dasarnya jumlah total baris setelah diskon baris,
  dihitung sebelum pembulatan total.
- Dialog diskon: pilihan % / Rp, isian nilai (persen boleh desimal, mis.
  2,5), keterangan dasar, pratinjau potongan, *Hapus diskon*, *Batal*,
  *Terapkan*. Diskon yang menghabiskan total ditolak dengan pesan.
- Blok total Kasir: baris *Diskon baris* dan *Diskon nota 5% · disetujui
  Rina* (ketuk untuk mengubah), sebelum *Pembulatan*. Bila hanya ada diskon
  baris, nama penyetuju ditulis di baris *Diskon baris*.
- **Persetujuan PIN manajer** untuk diskon: staf tanpa `sales:discount`
  memasukkan PIN staf berizin setelah *Terapkan*. Satu persetujuan berlaku
  untuk semua diskon di keranjang itu (maks. 30 menit) dan hangus saat
  keranjang dikosongkan atau nota tersimpan.
- Sakelar **Diskon manual butuh PIN manajer** di *Pengaturan → Penjualan &
  stok* (bawaan hidup). Bila mati, staf tanpa izin tidak melihat menu
  diskon.
- Struk dan detail riwayat: baris "Diskon 10%  -1.000" di bawah item dan
  baris diskon nota di blok total; *Subtotal* tampil bila ada diskon nota.
- Laporan laba rugi: *Diskon* = diskon grosir + diskon manual (baris dan
  nota).

### Diubah

- Penjualan per produk memakai total baris bersih (sudah dipotong diskon
  baris). Diskon nota tidak dibagi ke produk, sama seperti pembulatan.
- Nilai retur dibagi dari total nota, jadi diskon nota ikut terbagi ke
  setiap baris yang diretur.

### Diperbaiki

Ditemukan saat pengujian dan review sebelum rilis:

- Dialog persetujuan PIN kini juga bisa dibuka dari sheet *Pesanan* di
  ponsel. Sebelumnya sheet berada di luar cakupan persetujuan sehingga
  dialog tidak muncul.
- Keranjang tidak lagi macet bila persetujuan diskon kedaluwarsa (lebih
  dari 30 menit): penyetuju dihapus dan PIN diminta lagi, dan penyetuju
  tidak dikirim bila semua diskon sudah dihapus.
- Diskon yang menghabiskan total (mis. jumlah baris dikurangi setelah
  diskon diberikan) kini menahan tombol *Bayar* dengan pesan, bukan gagal
  di layar bayar. Dialog diskon baris juga menolak diskon yang membuat
  total nota nol.
- Nota berdiskon yang totalnya menjadi Rp 0 setelah pembulatan ditolak.
- Isian dialog diskon tidak lagi kembali ke nilai awal saat tema atau
  bahasa berubah.

### Keamanan

- Lapisan data menolak diskon dari staf tanpa `sales:discount` kecuali
  penyetujunya staf aktif cabang yang berizin dan sakelar PIN hidup
  (`DiscountNotPermitted`). Repositori aplikasi juga memeriksa bahwa
  penyetuju benar-benar lolos PIN di sesi ini, lalu menghabiskan
  persetujuannya setelah nota tersimpan.

### Catatan teknis

- Migrasi `manual-discount`: `sale_items.discount_amount`,
  `sale_items.discount_bp`, `sales.discount_amount`, `sales.discount_bp`,
  `sales.line_discount_amount`, `sales.discount_approved_by`.
- Domain: `ManualDiscount` (persen dalam basis poin, dibulatkan setengah ke
  atas; rupiah dibatasi dasar), `parseDiscountValue`,
  `SalesRules.discountNeedsPin`, `ReportSale.manualDiscount`.
- `checkoutSale(discount:, discountApproverId:)` dan
  `SaleLineRequest.discount`; `SessionRepository` memberi masa berlaku
  persetujuan diskon 30 menit (void tetap 2 menit).
- Gap: diskon di bill F&B dan split bill, serta batas diskon per role,
  dicatat di spec F1-04b.

## [0.23.0] - 2026-11-04

Pengaturan toko bagian kedua (F1-18): pemilik bisa mengubah profil toko dan
data cabang, mengatur stok minus dan pembulatan total, memilih harga menu
yang sudah termasuk PB1, dan memperbesar tampilan. Layar Pengaturan kini
punya semua bagian desain 1.26 kecuali *Data & backup* (F1-19).

### Ditambahkan

- Bagian **Profil toko** (`settings:manage`): ubah *Nama usaha*; *Jenis
  usaha* dan *Zona waktu* tampil sebagai info (tidak bisa diubah karena
  menentukan menu dan tanggal nomor nota).
- Bagian **Cabang ini**: ubah *Nama cabang*, *Alamat*, *Telepon*; *Kode
  cabang* dan *Kode perangkat* tampil sebagai info. Alamat dan telepon
  langsung menjadi kepala struk bawaan; nama baru langsung dipakai di
  kepala aplikasi, login, dan Kasir.
- Bagian **Penjualan & stok**:
  - *Izinkan stok minus* (bawaan hidup). Bila dimatikan, nota retail dan
    pelunasan bill F&B ditolak bila stok produk akan minus, dan bill F&B
    menolak menambah item melebihi stok, dengan pesan berisi nama produk.
  - *Wajib buka sesi kasir* tampil terkunci hidup.
  - *Pembulatan total*: Tidak ada / Ke Rp 100 / Ke Rp 500 terdekat (tepat
    setengah ke atas). Berlaku untuk semua metode bayar, nota kredit, bill
    F&B, dan split bill.
- Baris **Pembulatan** di keranjang Kasir, ringkasan bill F&B, pembayaran,
  struk, dan laporan laba rugi.
- **Harga sudah termasuk pajak** di *Pajak & service* (F&B): PB1 dipisahkan
  dari harga menu dan tidak ditambahkan ke total; struk menulis "PB1 10%
  (termasuk)".
- **Ukuran tampilan** Normal / Besar di *Tampilan & bahasa* (skala teks
  1,15 di perangkat ini).

### Diubah

- Pengaturan dibuka di *Profil toko* untuk pengguna dengan
  `settings:manage`; urutan bagian mengikuti desain 1.26.
- Laba rugi: penjualan bersih kini dikurangi PB1 yang termasuk harga dan
  ditambah selisih pembulatan (baris *PB1 termasuk harga* dan *Pembulatan
  total* muncul bila ada).

### Diperbaiki

Ditemukan sebelum rilis (review kode dan uji manual), bukan bug versi
sebelumnya, kecuali butir terakhir:

- Struk nota retail yang dibulatkan tidak punya baris *Pembulatan*, jadi
  total baris dan TOTAL tampak tidak cocok (terlihat di uji manual:
  Rp 9.240 tercetak TOTAL Rp 9.000). Kini struk menampilkan *Subtotal* dan
  *Pembulatan* setiap kali ada pembulatan.
- Menaikkan jumlah item bill F&B (tombol + atau ketik jumlah) tidak dicek
  terhadap stok saat stok minus dimatikan; kini ditolak seperti menambah
  item.
- Menyimpan *Profil toko* menghapus isian *Cabang ini* yang belum disimpan
  (dan sebaliknya); kini hanya bagian yang disimpan yang diisi ulang.
- Contoh hitungan di *Pajak & service* belum memakai pembulatan total; kini
  sama dengan yang tampil di bill.
- Judul split bill menulis "PB1 10%" walau harga sudah termasuk pajak; kini
  "PB1 10% (termasuk)".
- Tes data pengguna & role kadang gagal karena pemeriksaan galat async
  tidak ditunggu (`expect` tanpa `await`), sehingga berjalan setelah
  langkah berikutnya mengubah data.

### Keamanan

- Simpan profil, cabang, dan aturan penjualan butuh `settings:manage` di
  repositori, bukan hanya di menu.
- Aturan stok minus dicek di lapisan data di dalam transaksi tulis, jadi
  nota yang ditolak tidak meninggalkan stok, pembayaran, atau outbox.

### Catatan teknis

- Kolom baru `sales.rounding_amount` (int, boleh negatif) dan
  `sales.tax_inclusive` (bool), migrasi `sale-rounding`.
- Domain `store_settings.dart`: `TotalRounding`, `roundTotal`,
  `SalesRules` (JSON kunci `sales.rules`), `storeNameIssue`,
  `outletProfileIssues`; `fnbCharges(taxInclusive:, rounding:)`;
  `ReportSale.includedTax`, `ProfitAndLoss.includedTax/rounding`.
- Data `store_settings.dart`: `loadSalesRules`, `saveSalesRules`,
  `writeOutletSetting`, `enforceStockRule`, `SaleStockShort`,
  `saveStoreProfile`, `saveOutletProfile`; `FnbRates.taxInclusive` (kunci
  `fnb.tax_inclusive`) dan `FnbRates.rounding` (dibaca dari aturan
  penjualan).
- Aplikasi: `StoreSettingsRepository` + `LocalStoreSettingsRepository`,
  `StoreSettingsViewModel`, `StoreSettingsSection`; preferensi perangkat
  `ui.text_size`.
- Tes: domain (pembulatan, aturan, pajak termasuk, profil, laba rugi), data
  (aturan + outbox, pembulatan Rp 100/500, stok minus retail dan F&B, pajak
  termasuk di bill, profil dan cabang), VM + widget 1440 / 360, kasir, struk,
  laba rugi.

## [0.22.0] - 2026-11-04

Pengguna & role (F1-17): pemilik bisa menambah staf PIN, mereset dan membuka
kunci PIN, menonaktifkan staf, mengatur izin per role lewat matriks, dan
membuat role custom. Setiap pengguna punya halaman *Akun saya* untuk
mengganti PIN dan kata sandinya sendiri. Semua isian PIN dan kata sandi
baru selalu punya kolom ulangi.

### Ditambahkan

- Menu **Sistem → Pengguna & role** (`users:manage`), layar 1.25:
  - tab **Pengguna**: tabel (≥ 720 px) atau kartu berisi nama, email atau
    *PIN saja* / *Belum punya PIN*, role, cabang, status Aktif/Nonaktif;
    subjudul jumlah pengguna aktif;
  - badge **PIN dikunci N dtk** dengan hitung mundur per detik dan tombol
    **Buka kunci** langsung di baris staf;
  - dialog **Tambah pengguna** (1.25b): nama, role, PIN 6 angka + **ulangi
    PIN**, status aktif; dialog **Ubah pengguna** dengan bagian **Reset
    PIN** (PIN baru + ulangi, tanpa PIN lama) yang sekaligus membuka kunci;
  - tab **Role & izin**: matriks 22 izin × role (label manusia dan kunci
    `resource:action`), kolom pemilik terkunci, bisa digulir mendatar di
    layar sempit, tombol *Batalkan* / *Simpan perubahan*;
  - **Role custom**: buat (Enter langsung menyimpan), ganti nama, hapus
    dengan konfirmasi; role yang masih dipakai staf tidak bisa dihapus.
- Menu **Sistem → Akun saya** untuk semua pengguna (1.25b): kartu **Ganti
  PIN** (PIN saat ini, PIN baru, ulangi) dan **Ganti kata sandi** (kata
  sandi saat ini, baru minimal 8 karakter, ulangi). Staf tanpa kata sandi
  melihat keterangan bahwa mereka masuk dengan PIN saja.
- Izin role tersimpan di tabel baru `roles` dan dipakai saat login, di menu,
  dan di setiap repositori.

### Diubah

- Nama role di login, beranda, dan kepala aplikasi memakai nama role custom
  bila ada.
- Teks sambutan beranda menyebut pengguna & role sudah bisa dipakai.
- Mengubah staf, matriks, atau nama role menyegarkan izin sesi yang sedang
  masuk; staf yang dinonaktifkan dikeluarkan saat sesinya disegarkan.

### Diperbaiki

Ditemukan sebelum rilis (review kode dan uji manual), bukan bug versi
sebelumnya:

- Manajer dengan `users:manage` bisa membuka kunci PIN pemilik; kini
  ditolak di repositori dan tombolnya tidak tampil.
- `id` baris role dibuat acak sehingga dua perangkat yang mengubah role yang
  sama akan bentrok di indeks unik saat sinkronisasi; kini deterministik
  dari tenant + kunci role.
- Staf dengan role yang tidak dikenali tidak bisa diubah sama sekali; kini
  pemilik tetap bisa mengubahnya selama role tidak diganti.
- Pilihan role di dialog non-pemilik menampilkan role yang izinnya di luar
  milik aktor; kini disaring. Baris pemilik dan baris diri sendiri tidak
  bisa dibuka oleh non-pemilik.
- Badge kunci PIN tidak berkurang sampai daftar dimuat ulang; kini dihitung
  mundur per detik.
- Role custom bisa memakai nama role bawaan (mis. "Kasir"); kini ditolak.
- Hapus role custom tanpa konfirmasi; kini lewat dialog.
- Staf tanpa PIN tertulis *PIN saja* di daftar; kini *Belum punya PIN*.
- Pesan galat untuk staf tidak ditemukan dan akun tanpa kata sandi.

### Keamanan

- Non-pemilik tidak bisa memberi izin yang tidak ia miliki, tidak bisa
  mengubah dirinya atau role-nya sendiri, dan tidak bisa mengubah pemilik.
  Aturan ini dicek di lapisan data, bukan hanya di UI.
- Ganti PIN / kata sandi sendiri wajib memasukkan nilai saat ini; salah 5
  kali memakai kunci login yang sama (60 detik).
- PIN dan kata sandi di-hash Argon2id di isolate; staf nonaktif tidak
  muncul di login.

### Catatan teknis

- Model `StaffRole` (`lakuna_server/lib/src/organization/staff_role.spy.yaml`,
  tabel `roles`, indeks unik `(tenant_id, role_key)`), migrasi
  `staff-role`. Role bawaan tidak di-seed; barisnya dibuat saat matriks
  pertama kali diubah. Role `owner` tidak pernah disimpan.
- Domain `staff.dart`: `StaffIssue`, `validatePinPair`,
  `validatePasswordPair`, `roleKeyFor`, `encodePermissions` /
  `decodePermissions`, `effectivePermissions`, `grantIssue`; `ids.dart`:
  `stableId` (UUIDv5).
- Data `users.dart`: `listStaffAccounts`, `listRoles`, `createStaff`,
  `updateStaff`, `resetStaffPin`, `changeOwnPin`, `changeOwnPassword`,
  `saveRoleMatrix`, `createCustomRole`, `renameCustomRole`,
  `deleteCustomRole`, `requireStaffManageable`; semua tulis lewat
  `LakunaStore.write` + outbox sync.
- Aplikasi: `UsersRepository` + `LocalUsersRepository`;
  `SessionRepository` mendapat `unlockPin`, `refreshCurrent`,
  `verifyCurrentPin`, `verifyCurrentPassword`; rute `/pengguna` dan `/akun`.
- Tes: domain (16), data (23), repositori lokal dengan database sungguhan
  (6), view model (14), alur widget 1440 / 800 / 360 px, menu.

## [0.21.0] - 2026-11-04

Laporan bagian kedua (F1-16): empat tab baru di layar Laporan untuk melihat
stok, kas laci, piutang & hutang, dan retur cabang ini, masing-masing bisa
diunduh sebagai PDF atau Excel. Semua angka dihitung dari dokumen (kartu
stok, sesi kasir, gerakan kas, nota kredit, pembelian, retur).

### Ditambahkan

- Tab **Stok**:
  - kartu *Nilai stok* (hanya dengan `reports:view_profit`; stok saat ini ×
    harga pokok rata-rata), *Produk barang*, *Stok menipis*, *Stok habis*;
  - tabel *Pergerakan stok* per varian barang: Awal, Masuk, Keluar, Akhir
    (satuan dasar, semua lokasi stok cabang) dan Nilai akhir.
- Tab **Kas & sesi**:
  - kartu jumlah sesi (berapa yang masih buka), *Total selisih* sesi yang
    sudah ditutup, *Kas masuk lain*, *Kas keluar*;
  - tabel sesi kasir yang aktif pada periode (dibuka, kasir, saldo awal,
    seharusnya, dihitung, selisih; sesi yang masih buka dihitung sampai
    sekarang dan ditandai *Masih buka*);
  - tabel *Kas masuk & keluar* per sumber: manual, pengeluaran, batal
    pengeluaran, bayar hutang supplier, bayar pembelian, terima piutang.
- Tab **Piutang & hutang** (posisi hari ini): kartu piutang pelanggan,
  piutang jatuh tempo, hutang supplier, nota beli lewat tempo; tabel per
  pelanggan dan per supplier (nota terbuka, lewat tempo, jatuh tempo
  terdekat, sisa).
- Tab **Retur**: kartu jumlah retur, nilai retur, kembali ke stok, rusak /
  kedaluwarsa; ringkasan per alasan; daftar retur (waktu, no retur, no
  nota, petugas, alasan, ke stok, cara refund, nilai).
- Unduh PDF/Excel untuk keempat tab: `laporan-stok-…`, `laporan-kas-sesi-…`,
  `laporan-piutang-hutang-<yymmdd>` (tanpa periode), `laporan-retur-…`.

### Diubah

- Data tab baru dimuat saat tab dibuka dan dimuat ulang saat periode
  berganti; selama dimuat tombol unduh mati sehingga berkas tidak berisi
  data periode lain.
- Repositori laporan membaca ulang izin staf dari role di database untuk
  setiap muatan, bukan dari sesi masuk.

### Diperbaiki

Ditemukan sebelum rilis (uji manual), bukan bug versi sebelumnya:

- Sesi kasir yang dibuka kemarin dan belum ditutup tidak tampil di laporan
  *Hari ini* walau gerakan kasnya tampil; kini tab menampilkan sesi yang
  aktif pada periode, bukan hanya yang dibuka pada periode.
- Temuan review kode:
  - Kartu *Nilai stok* dan total *Nilai akhir* bisa berbeda untuk hari yang
    sama bila stok ada di lokasi lain (mis. Gudang) dengan harga pokok
    berbeda; kini nilai per varian memakai rata-rata tertimbang semua
    lokasi dan totalnya sama dengan kartu.
  - Tab Stok memuat seluruh riwayat pergerakan setiap dibuka; kini hanya
    pergerakan sejak awal periode, stok awal dihitung mundur dari stok saat
    ini.
  - Uang kembali retur pembelian tampil sebagai *Bayar pembelian* bertanda
    `+`; kini *Refund retur pembelian*.
  - *Stok menipis* / *Stok habis* kini memakai stok lokasi bawaan seperti
    layar Stok.
  - Retur nota kredit yang sebagian memotong piutang kini tertulis *Tunai
    dari laci + potong piutang*.
  - Ekspor: kolom *Jatuh tempo terdekat* supplier ikut; sesi yang masih buka
    tidak lagi membuat kolom angka PDF rata kiri.
  - Tabel daftar retur menjadi kartu di bawah 900 px agar tidak berdesakan;
    urutan nama stok tidak membedakan huruf besar.
  - Ganti periode di tab Piutang & hutang tidak lagi memuat ulang tab itu.

### Keamanan

- Tanpa `reports:view_profit`, lapisan data tidak mengirim harga pokok:
  kartu *Nilai stok* dan kolom *Nilai akhir* tidak dihitung.

### Catatan teknis

- Domain: `StockMove`, `StockMovementRow`, `stockMovementRows` (awal
  dihitung mundur dari stok saat ini, masuk / keluar / akhir per periode),
  `stockValueOf`, `groupTotals`.
- Data `lakuna_data/reports_extra.dart` (bagian dari `reports.dart`):
  `loadStockReport`, `loadCashReport` (`CashSourceKind` dari kolom
  `source`), `loadDebtReport` (memakai `listCustomers` dan
  `loadSuppliersOverview`), `loadReturnsReport`. Tidak ada perubahan skema.
- Tabel ekspor: `ReportTable.flex` untuk lebar kolom PDF per tab.
- Tes: domain (pergerakan stok, kelompok total), data (stok semua lokasi dan
  izin, sesi tutup/buka dan sesi lintas hari, piutang + hutang lewat tempo,
  retur per alasan), VM (muat per tab, periode, galat), tabel ekspor, alur
  widget 1440 / 800 / 360 px.

## [0.20.0] - 2026-11-04

Laporan & laba rugi bagian pertama (F1-16, layar 1.23 dan 1.24). Pemilik dan
manajer melihat penjualan, produk terlaris, dan laba rugi cabang ini per
periode, lalu mengunduhnya sebagai PDF atau Excel tanpa internet. Semua angka
dihitung ulang dari dokumen (nota, retur, pembayaran, pengeluaran,
penyesuaian stok), bukan dari kolom ringkasan.

### Ditambahkan

- Menu **Laporan** (`/laporan`, grup Keuangan) untuk staf dengan
  `reports:view`; sebelumnya halaman *segera hadir*.
- Pilihan **Periode** di kepala layar, berlaku untuk semua tab: *Hari ini*,
  *7 hari terakhir*, *Bulan ini*, dan 12 bulan sebelumnya (mis. *Oktober
  2026*), menurut tanggal dan zona waktu cabang.
- Tab **Ringkasan** (1.23):
  - kartu *Penjualan* (penjualan bersih, N transaksi), *Laba kotor* (dari
    harga pokok saat jual), *Rata-rata per nota*, *Piutang jatuh tempo*
    (N pelanggan);
  - *Penjualan per metode bayar* dengan batang dan persen (tunai bersih
    kembalian, kartu, transfer, QRIS, dan bagian kredit/piutang);
  - *Produk terlaris* 5 teratas;
  - *Laporan lengkap*: tautan ke tab penjualan per produk/kasir/kategori dan
    laba rugi, serta ke layar Stok, Pelanggan, Riwayat (retur),
    Pengeluaran, dan Sesi kasir sesuai izin staf.
- Tab **Penjualan**: *Per produk* (jumlah bersih dalam satuan dasar dan
  nilai), *Per kasir* (jumlah nota dan penjualan bersih), *Per kategori*,
  dengan porsi persen dan baris total. Di 360 px menjadi daftar kartu.
- Tab **Produk terlaris**: 20 teratas menurut jumlah bersih.
- Tab **Laba rugi** (1.24): Penjualan kotor, Diskon, Service charge (bila
  ada), Retur penjualan, **Penjualan bersih**, HPP, **Laba kotor · margin**,
  beban operasional per jenis dari Pengeluaran, Total beban, Penyesuaian
  stok, **Laba bersih**. Panel samping: Laba bersih dibanding periode
  sebelumnya (kemarin, 7 hari sebelumnya, tanggal yang sama bulan lalu
  untuk *Bulan ini*, atau bulan sebelumnya), Margin kotor,
  Beban / penjualan, dan *Cara hitung*. Catatan *PB1 dipungut* dan
  peringatan produk terjual tanpa harga pokok.
- **Unduh PDF** (A4, font bawaan aplikasi) dan **Unduh Excel** untuk tab
  aktif, nama berkas `laporan-<tab>-<periode>-<yymmdd>`. Desktop menyimpan
  ke folder dokumen Lakuna; Android/iOS membuka lembar berbagi.
- Izin baru **`reports:view_profit`** (owner dan manajer): kartu Laba kotor,
  tab Laba rugi, dan angka HPP. Kasir tidak mendapatkannya.

### Diubah

- Teks Beranda: laporan sudah bisa dipakai; tinggal pengguna & role.
- Lembar berbagi ekspor memakai tipe PDF untuk berkas `.pdf`.

### Diperbaiki

Semua di bawah ini ditemukan sebelum rilis (tes widget dan uji manual),
bukan bug di versi sebelumnya.

- Tombol tautan *Laporan lengkap*, pilihan *Per produk/kasir/kategori*, dan
  baris produk terlaris meluap di ponsel 360 px.
- Kartu ringkasan berdampingan memakai `IntrinsicHeight` di atas daftar
  yang memakai `LayoutBuilder` sehingga layar gagal digambar; tinggi kini
  hanya disamakan untuk kartu angka.
- Baris laba rugi bernilai nol tampil `− Rp 0`.
- Kolom per produk/kategori berjudul *Penjualan bersih* padahal nilainya
  tanpa service; kini *Nilai*, dan catatan menjelaskan bedanya dengan per
  kasir.
- Temuan review kode:
  - Saat ganti periode, angka periode lama masih tampil di bawah label
    periode baru sampai data baru selesai dimuat, dan *Unduh* saat itu
    menyimpan angka lama dengan nama berkas periode baru. Kini layar
    menampilkan pemuat dan tombol unduh mati sampai data periode itu siap.
  - *Bulan ini* dibandingkan dengan bulan lalu penuh (4 hari vs 31 hari
    tampil −85%); kini dengan tanggal 1 sampai tanggal yang sama bulan lalu
    (mis. *1–4 Oktober 2026*).
  - Ketukan ganda *Unduh PDF* bisa menyimpan dua berkas karena tombol baru
    mati setelah font PDF dimuat.
  - Jumlah per kategori menjumlahkan satuan dasar yang berbeda (pcs + kg);
    kini `–`.
  - PDF *Produk terlaris*: kolom peringkat selebar nama produk dan kolom
    jumlah rata kiri; lebar dan perataan kolom kini per tabel.
  - Nama lembar Excel terpotong di tengah kata (*… · Septem*); kini memakai
    nama tab saja bila terlalu panjang.
  - Beban yang jenisnya sudah dihapus tampil tanpa nama; kini *Tanpa
    kategori*.

### Keamanan

- `reports:view` dicek di menu, rute, repositori aplikasi, dan lapisan
  data. Tanpa `reports:view_profit`, lapisan data tidak menghitung laba dan
  tidak mengirim harga pokok baris nota ke layar.

### Catatan teknis

- Domain `lakuna_domain/report.dart` (murni): `ReportPeriod` + rentang dan
  periode pembanding, `ProfitAndLoss.compute`, `salesByProduct`,
  `salesByCategory`, `salesByStaff`, `topProducts`, `paymentMix`,
  `returnTaxShare`, `ratioBp`, `changeBp`, `formatPercentBp`.
- Data `lakuna_data/reports.dart`: `loadReport` (izin dari role staf) dan
  `buildReport` (izin yang sudah diketahui) memuat nota, baris,
  pembayaran, retur (termasuk nota asal di luar periode), pengeluaran, dan
  penyesuaian per 500 id; `overdueReceivables` di `customers.dart`.
- HPP memakai `sale_items.unit_cost` (rata-rata tertimbang yang dibekukan
  saat jual) sehingga produk tanpa lacak stok ikut terhitung; retur yang
  di-restock mengurangi HPP. PB1 tidak dihitung sebagai pendapatan.
- Tabel ekspor bersama `ReportTable` → `reportXlsx` / `reportPdf`.
- Tidak ada perubahan skema database.
- Tes: domain (rumus, periode, rincian, metode bayar), data (skenario jual →
  void → retur → open bill PB1 → pengeluaran batal → opname dicocokkan
  manual, zona waktu, izin, tanpa izin laba harga pokok nol, retur hari ini
  atas nota kemarin), service makan di tempat, VM (jawaban periode usang
  diabaikan), label/tabel ekspor, alur widget 1440 / 800 / 360 px, PDF
  terbentuk.
- Lanjutan modul ini di v0.21.0: tab Stok, Kas & sesi, Piutang & hutang,
  Retur.

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

[Unreleased]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.119.0...HEAD
[0.119.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.118.0...v0.119.0
[0.118.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.117.0...v0.118.0
[0.117.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.116.0...v0.117.0
[0.116.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.115.0...v0.116.0
[0.115.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.114.0...v0.115.0
[0.114.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.113.0...v0.114.0
[0.113.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.112.0...v0.113.0
[0.112.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.111.0...v0.112.0
[0.111.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.110.0...v0.111.0
[0.110.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.109.0...v0.110.0
[0.109.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.108.0...v0.109.0
[0.108.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.107.0...v0.108.0
[0.107.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.106.0...v0.107.0
[0.106.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.105.0...v0.106.0
[0.105.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.104.0...v0.105.0
[0.104.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.103.0...v0.104.0
[0.103.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.102.0...v0.103.0
[0.102.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.101.0...v0.102.0
[0.101.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.100.0...v0.101.0
[0.100.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.99.0...v0.100.0
[0.99.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.98.0...v0.99.0
[0.98.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.97.0...v0.98.0
[0.97.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.96.0...v0.97.0
[0.96.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.95.0...v0.96.0
[0.95.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.94.0...v0.95.0
[0.94.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.93.0...v0.94.0
[0.93.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.92.0...v0.93.0
[0.92.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.91.0...v0.92.0
[0.91.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.90.0...v0.91.0
[0.90.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.89.0...v0.90.0
[0.89.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.88.0...v0.89.0
[0.88.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.87.0...v0.88.0
[0.87.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.86.0...v0.87.0
[0.86.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.85.0...v0.86.0
[0.85.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.84.0...v0.85.0
[0.84.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.83.0...v0.84.0
[0.83.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.82.0...v0.83.0
[0.82.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.81.0...v0.82.0
[0.81.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.80.0...v0.81.0
[0.80.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.79.0...v0.80.0
[0.79.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.78.0...v0.79.0
[0.78.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.77.0...v0.78.0
[0.77.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.76.0...v0.77.0
[0.76.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.75.0...v0.76.0
[0.75.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.74.0...v0.75.0
[0.74.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.73.0...v0.74.0
[0.73.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.72.0...v0.73.0
[0.72.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.71.0...v0.72.0
[0.71.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.70.0...v0.71.0
[0.70.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.69.0...v0.70.0
[0.69.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.68.0...v0.69.0
[0.68.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.67.0...v0.68.0
[0.67.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.66.0...v0.67.0
[0.66.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.65.0...v0.66.0
[0.65.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.64.0...v0.65.0
[0.64.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.63.0...v0.64.0
[0.63.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.62.0...v0.63.0
[0.62.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.61.0...v0.62.0
[0.61.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.60.0...v0.61.0
[0.60.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.59.0...v0.60.0
[0.59.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.58.0...v0.59.0
[0.58.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.57.0...v0.58.0
[0.57.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.56.0...v0.57.0
[0.56.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.55.0...v0.56.0
[0.55.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.54.0...v0.55.0
[0.54.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.53.0...v0.54.0
[0.53.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.52.0...v0.53.0
[0.52.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.51.0...v0.52.0
[0.51.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.50.0...v0.51.0
[0.50.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.49.0...v0.50.0
[0.49.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.48.0...v0.49.0
[0.48.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.47.0...v0.48.0
[0.47.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.46.0...v0.47.0
[0.46.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.45.0...v0.46.0
[0.45.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.44.0...v0.45.0
[0.44.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.43.0...v0.44.0
[0.43.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.42.0...v0.43.0
[0.42.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.41.0...v0.42.0
[0.41.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.40.0...v0.41.0
[0.40.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.39.0...v0.40.0
[0.39.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.38.0...v0.39.0
[0.38.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.37.0...v0.38.0
[0.37.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.36.0...v0.37.0
[0.36.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.35.0...v0.36.0
[0.35.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.34.0...v0.35.0
[0.34.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.33.0...v0.34.0
[0.33.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.32.0...v0.33.0
[0.32.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.31.0...v0.32.0
[0.31.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.30.0...v0.31.0
[0.30.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.29.1...v0.30.0
[0.29.1]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.29.0...v0.29.1
[0.29.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.28.1...v0.29.0
[0.28.1]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.28.0...v0.28.1
[0.28.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.27.0...v0.28.0
[0.27.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.26.0...v0.27.0
[0.26.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.25.0...v0.26.0
[0.25.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.24.0...v0.25.0
[0.24.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.23.0...v0.24.0
[0.23.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.22.0...v0.23.0
[0.22.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.21.0...v0.22.0
[0.21.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.20.0...v0.21.0
[0.20.0]: https://github.com/yusufabdillahputra/yap-lakuna/compare/v0.19.0...v0.20.0
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
