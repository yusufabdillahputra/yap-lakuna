# F1-10 · Meja F&B, open bill, modifier, split bill

- **Fase:** 1
- **Status:** Dirilis: v0.11.0 (grid, open bill, take away, pajak & service), v0.12.0 (modifier), v0.13.0 (split bill), v0.14.0 (denah)
- **Layar desain:** 1.7 *Meja & open bill · mode grid* (`Meja-FnB-Tablet`),
  1.7b *Mode denah* (`F1-Meja-Denah`), 1.7c *Unggah denah*
  (`F1-Upload-Denah`), 1.7d *Atur denah* (`F1-Atur-Denah`), 1.7e *Tiket
  dapur & take away* (`F1-Tiket-Dapur`), 1.8 *Pilih modifier*
  (`F1-Modifier`), 1.9 *Split bill* (`F1-Split-Bill`), 1.16b/1.17b
  modifier di produk dan master. Kanvas
  [Desain UI Lakuna](https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525).
- **Acuan Storeku:** `docs/superpowers/specs/2026-11-02-f1-10-meja-fnb-design.md`

## Tujuan

Warung makan dan kafe bisa melayani meja dan take away: buka bill, tambah
menu (dengan modifier), kirim ke dapur, tandai disajikan, lalu tutup dan
bayar, termasuk membagi tagihan per tamu.

## Pembagian rilis

Sama dengan Storeku, modul terlalu besar untuk satu rilis. Setiap rilis
bisa dipakai sendiri:

1. **v0.11.0 · Meja & open bill (mode Grid)**: area & meja di Master data,
   *Pajak & service* di Pengaturan, layar Meja 1.7 + 1.7e (dine in, take
   away bernomor, status item, tiket dapur, minta bill, pindah meja,
   batalkan bill, tutup & bayar lewat layar Bayar yang sama).
2. **v0.12.0 · Modifier** (1.8, 1.16b, 1.17b).
3. **v0.13.0 · Split bill** (1.9).
4. **v0.14.0 · Denah** (1.7b–d) dengan `vyuh_node_flow`.

Bagian berikut merinci v0.11.0. Rilis berikutnya mengikuti keputusan
Storeku (bagian *Rilis berikutnya*) dan dirinci di brainstorming masing-
masing.

## Lingkup v0.11.0

### Layar Meja `/meja` (1.7 + 1.7e)

- Menu **Meja** di kelompok *Penjualan* setelah Kasir, izin
  `open_bills:manage`. Di ponsel dibuka dari *Lainnya*.
- Header: "Meja", subjudul "Pelayan: {staf} · {n} dari {m} meja terisi",
  pilihan **Dine in / Take away**.
- **Dine in**: legenda (Kosong, Terisi · open bill, Minta bill), tab area
  bila ada lebih dari satu area (plus *Tanpa area* bila ada meja tanpa
  area), grid kartu meja: nama, kursi, total bill, info ("20 mnt" atau
  "Minta bill"), warna sesuai status. Grid 4 kolom di tablet, 2 di ponsel.
- **Take away**: daftar bill take away hari ini yang masih terbuka:
  "TA-07 · Budi", jumlah item · jam, badge status (Baru / Di dapur / Siap
  ambil), *Hapus bill kosong* untuk bill tanpa item; tombol *Take away
  baru* (memakai ulang take away kosong, tidak membuat nomor baru).
- **Panel bill** (kanan 400 px di layar ≥ 900 px; di layar sempit halaman
  bill menggantikan grid dengan tombol kembali):
  - Judul "Meja M4 · Open bill" / "TA-07 · Take away", "{tamu} tamu ·
    dibuka 12.10 · 35 menit · Pelayan Dimas".
  - Membuka meja kosong menanyakan jumlah tamu (bawaan = kursi meja).
    Take away boleh diberi nama pemesan (opsional, maks 40 karakter).
  - *+ Menu*: lembar pilih menu (cari + chip kategori, kartu produk seperti
    kasir; varian/satuan dipilih lewat pilihan yang sama dengan kasir).
  - Baris item: jumlah ×, nama, catatan, badge status (**Baru** amber,
    **Di dapur** sky, **Disajikan** hijau), total baris. Item *Baru* punya
    − / + dan hapus; item *Di dapur* punya *Tandai disajikan*.
  - Subtotal, **Service X% (dine in)**, **PB1 Y%**, **Total** (baris yang
    tarifnya 0 disembunyikan).
  - Tombol: **Kirim ke dapur (n item baru)** (primer), **Minta bill** /
    *Batal minta bill*; baris aksi teks: *Pindah meja* (dine in), *Split
    bill* (nonaktif, "segera" sampai v0.13.0), *Batalkan bill*; tombol
    besar **Tutup & bayar**.
- **Tiket dapur** (1.7e): dialog pratinjau monospace (TIKET DAPUR, "Meja M4
  · Dine in" / "TA-07 · Take away", No `K-0012`, Jam, Pelayan, item baru
  dengan catatan berawalan `*`, "Item baru saja · tanpa harga"), tombol
  *Cetak tiket* (printer perangkat, kertas struk cabang) dan *Tutup*.
  Kirim ke dapur menyimpan dulu, lalu dialog muncul; menutup dialog tidak
  membatalkan kiriman. Tiket bisa dicetak ulang dari dialog yang sama
  selama dibuka.

### Master data › Meja & area

Tab baru di Master data (izin `settings:manage`; tanpa izin tab tidak
tampil):

- **Area**: tambah, ganti nama, urutkan naik/turun, hapus (ditolak bila
  masih punya meja). Nama wajib, maks 40, unik per cabang.
- **Meja**: tambah (nama, area opsional, kursi 1–99), ubah, urutkan, hapus
  (soft delete, ditolak bila meja punya bill terbuka). Nama wajib, maks 20,
  unik per cabang tanpa membedakan huruf. *Tambah beberapa*: "M1–M12"
  sekaligus (awalan, mulai, sampai, kursi) agar setup cepat.

### Pengaturan › Pajak & service

Kartu baru di Pengaturan (izin `settings:manage`), per cabang:
*Service charge* (0–30%, langkah 0,5%) dan *PB1 / pajak restoran* (0–20%,
langkah 0,5%), keterangan "Service hanya untuk dine in. PB1 dihitung dari
subtotal + service." Disimpan di `settings` (`scope = outlet:<id>`,
kunci `fnb.service_bp` dan `fnb.tax_bp`, basis poin, bawaan 0).

### Tutup & bayar

Membuka kasir dalam **mode bill** (`/kasir?bill=<id>`): langsung tahap
Bayar dengan total bill (subtotal + service + PB1), semua metode bayar
yang sudah ada (tunai, kartu, transfer, QRIS statis, split metode).
Ringkasan di kiri menampilkan item bill (hanya baca). Setelah lunas: layar
berhasil + struk (dengan baris service dan PB1) dan tombol **Kembali ke
meja**. *Kembali* dari tahap bayar kembali ke layar Meja, bill tetap
terbuka.

## Aturan bisnis

- **Open bill = `sales` berstatus `open`** dengan `order_type` `dine_in`
  (`dining_table_id` terisi) atau `take_away`. Nomor bill
  `OB-<OUTLET>-<PERANGKAT>-<yymmdd>-<nnnn>` diberikan saat dibuka
  (unik, karena kolom `number` wajib dan unik). Saat lunas, `number`
  diganti nomor nota biasa (`PST-K01-…`); nomor bill tetap tersimpan di
  `bill_number`. Bill yang dibatalkan memakai nomor bill.
- **Satu bill terbuka per meja.** Membuka meja yang sudah terisi membuka
  bill yang ada. Dicek di transaksi tulis (`TableOccupied`).
- **Status meja dihitung**, tidak disimpan: *Kosong* (tidak ada bill
  open), *Terisi*, *Minta bill* (`bill_requested_at` terisi).
- **Harga dibekukan saat item ditambahkan** (`unit_price`, `list_price`
  di `sale_items`). Grosir berlaku pada jumlah baris saat ditambah/diubah
  (dihitung ulang dari database selama item masih *Baru*).
- **Status item dapur** `kitchen_status`: `pending` (Baru) → `sent` (Di
  dapur) → `served` (Disajikan). Item yang sama digabung hanya bila baris
  lama masih *Baru*; setelah dikirim, tambahan menjadi baris baru.
- Item *Baru* boleh diubah jumlahnya atau dihapus (soft delete). Item *Di
  dapur*/*Disajikan* tidak bisa diubah atau dihapus kecuali lewat
  *Batalkan bill*, agar dapur tidak kehilangan jejak.
- **Kirim ke dapur** membuat `kitchen_tickets` (nomor `K-<nnnn>` urut per
  hari per perangkat, staf, waktu) dan menandai semua item *Baru* →
  *Di dapur* dengan `kitchen_ticket_id`. Tanpa item baru → ditolak
  (`NothingToSend`).
- **Take away**: nomor `TA-<nn>` urut per hari per perangkat
  (`queue_number`); badge daftar: *Baru* bila ada item belum dikirim,
  *Di dapur* bila ada item di dapur, *Siap ambil* bila semua disajikan.
  *Take away baru* memakai ulang take away kosong milik perangkat ini hari
  ini. *Hapus bill kosong* menghapus (soft delete) bill tanpa item, tanpa
  izin batal.
- **Pajak & service**: service = subtotal (setelah grosir) × tarif service
  (hanya dine in); PB1 = (subtotal + service) × tarif PB1; masing-masing
  dibulatkan setengah ke atas ke rupiah. Bill terbuka selalu memakai tarif
  terkini; angka dibekukan di `sales.service_amount`, `tax_amount`,
  `service_bp`, `tax_bp` saat lunas. Penjualan retail tetap tanpa pajak.
- **Tutup & bayar** butuh `sales:create`, sesi kasir terbuka di perangkat
  ini, dan minimal satu item. Item *Baru* yang belum dikirim tetap ikut
  dibayar (minuman yang langsung dibuat kasir). Satu transaksi: nomor nota,
  `status = completed`, `cash_session_id`, `staff_id` = kasir penerima
  bayar (pembuka bill tetap di `opened_by`), pergerakan stok (sekali),
  pembayaran, total dibekukan.
- **Minta bill** menandai `bill_requested_at` (bisa dibatalkan).
- **Pindah meja** hanya ke meja kosong di cabang yang sama.
- **Batalkan bill** butuh `sales:void` dan alasan (wajib, maks 120):
  `status = voided`, `void_reason`, `voided_by`, `voided_at`; stok tidak
  bergerak (belum pernah keluar). Bill kosong cukup *Hapus bill kosong*.
- Izin dicek di UI **dan** di lapisan data (`open_bills:manage` untuk
  semua aksi bill, `sales:create` untuk bayar, `sales:void` untuk batal,
  `settings:manage` untuk meja/area/tarif).

## Data (migrasi `meja`)

Enum baru: `OrderType` (`retail`, `dineIn`, `takeAway`), `KitchenStatus`
(`pending`, `sent`, `served`).

- Tabel baru `dining_areas`: `tenant_id`, `outlet_id`, `name`,
  `sort_order` + kolom standar.
- Tabel baru `dining_tables`: `tenant_id`, `outlet_id`, `dining_area_id`
  (nullable), `name`, `seats`, `sort_order` + kolom standar. Kolom posisi
  denah ditambah di v0.14.0.
- Tabel baru `kitchen_tickets`: `tenant_id`, `outlet_id`, `device_id`,
  `sale_id`, `number` (int harian), `staff_id`, `sent_at` + kolom standar.
- `sales` tambah: `order_type` (bawaan `retail`), `dining_table_id`,
  `bill_number`, `queue_number`, `customer_name`, `guest_count`,
  `opened_by`, `opened_at`, `bill_requested_at`, `service_bp`, `tax_bp`,
  `service_amount`, `tax_amount` (bawaan 0), `void_reason`, `voided_by`,
  `voided_at`.
- `sale_items` tambah: `kitchen_status` (nullable; null = retail),
  `kitchen_ticket_id`, `note`.

Kolom baru semuanya nullable atau punya bawaan. Karena ada FK baru,
migrasi SQLite membangun ulang `sales` dan `sale_items` (Serverpod
mematikan `foreign_keys` selama migrasi); diuji pada data v0.10.0.
`sales.total` untuk bill = subtotal setelah grosir + service + PB1.

## Kasus tepi

- Aplikasi tertutup saat bill terbuka: semua tersimpan karena bill adalah
  baris database.
- Produk dinonaktifkan setelah masuk bill: baris tetap dan dibayar dengan
  harga beku; menambah lagi ditolak (`SaleItemUnavailable`).
- Hapus meja yang punya bill terbuka ditolak (`MasterInUse`).
- Dua perangkat membuka meja yang sama sebelum sync: diterima di lokal
  (dicek per perangkat); kunci per meja di Fase 2.
- Sesi kasir tertutup saat *Tutup & bayar*: pesan sama dengan kasir
  (`CashSessionNotOpen`), bill tetap terbuka.
- Bill hari kemarin yang masih terbuka tetap tampil (durasi dihitung dari
  `opened_at`).

## Pengujian (TDD)

- Domain: `fnbCharges` (service hanya dine in, PB1 dari subtotal +
  service, pembulatan, tarif 0), validasi nama meja/area, nomor `TA-07` /
  `K-0012`, status take away.
- Data: buka bill (nomor OB, satu per meja), tambah item (gabung hanya bila
  *Baru*, harga beku), ubah/hapus item baru (item terkirim ditolak), kirim
  ke dapur (tiket + status, kosong ditolak), disajikan, minta bill, pindah
  meja (ke meja terisi ditolak), batalkan (izin + alasan), hapus bill
  kosong, take away bernomor dan dipakai ulang, bayar (nomor nota, stok
  sekali, tarif dibekukan, sesi kasir wajib), meja/area CRUD, tarif.
- View model + widget: alur meja → menu → kirim → disajikan → bayar,
  take away, batal, pindah, tanpa izin, ponsel 360/820/1280 tanpa luapan.

## Lingkup v0.12.0 · Modifier (brainstorming 3 Nov 2026)

Kanvas Lakuna 1.8 *Pilih modifier menu* (`F1-Modifier`), 1.16b *Form menu
F&B · Modifier* (`F1-Produk-Modifier`), 1.17b *Master grup modifier*
(`F1-Master-Modifier`) dan keputusan Storeku v0.11.0 menjawab hampir semua
pertanyaan. Perbedaan dari Storeku: harga tambahan **boleh negatif**
(potongan, mis. "Tanpa nasi −Rp 3.000"), opsi bisa ditandai **Habis**
(tidak dihapus), opsi **Bawaan** terpilih otomatis, dan urutan grup diatur
**per menu**.

### Master data › Grup modifier (1.17b)

Tab baru di Master data, izin `products:manage` (sama dengan form produk):

- Daftar grup: nama, aturan ("Wajib · pilih 1", "Opsional · maks 2"),
  jumlah opsi, "dipakai n menu"; urutkan naik/turun; *+ Grup modifier*.
- Form grup (panel kanan di layar lebar, lembar bawah di ponsel): *Nama
  grup* (wajib, maks 40, unik per tenant tanpa membedakan huruf), *Wajib
  dipilih* (saklar), *Minimal pilih* dan *Maksimal pilih* (0–20; wajib ⇒
  min ≥ 1; min ≤ maks; maks ≥ 1). Maks 1 tampil sebagai pilihan tunggal.
- Opsi (1–30 per grup): *Nama opsi* (wajib, maks 40, unik per grup),
  *Tambahan harga* (−Rp 1.000.000 s.d. Rp 1.000.000, boleh negatif),
  *Bawaan* (terpilih otomatis di 1.8; jumlah bawaan ≤ maks), *Status*
  Tersedia / Habis. Hapus opsi = soft delete (nota lama menyimpan salinan).
- Catatan: "Perubahan berlaku untuk pesanan baru; nota lama menyimpan
  salinan nama & harga modifier." *Hapus grup* ditolak bila masih dipasang
  di menu (menyebut jumlah menu).

### Form produk › Modifier (1.16b)

Tab *Modifier* di form produk (semua jenis produk): daftar grup terpasang
berurutan dengan opsi dan harga tambahan, tombol naik/turun dan lepas,
*Tambah grup* (pilih dari grup yang belum terpasang). Urutan = urutan di
1.8. Disimpan bersama produk ke `product_modifier_groups` dalam transaksi
yang sama. Toggle *Kirim ke tiket dapur* / *Bisa catatan bebas* di kanvas
dirilis di v0.43.0 (spec F1-10g).

### Sheet 1.8 di layar Meja

- Menu yang punya grup modifier membuka sheet: nama, deskripsi varian,
  harga; setiap grup dengan label aturan (amber bila wajib); opsi sebagai
  tombol pilihan dengan harga tambahan; opsi *Habis* dicoret dan tidak
  bisa dipilih; opsi *Bawaan* yang tersedia sudah terpilih.
- Maks 1 = pilihan tunggal (mengetuk opsi lain memindah pilihan; mengetuk
  opsi terpilih di grup opsional mengosongkan). Maks > 1 = centang dengan
  batas; opsi lain nonaktif setelah batas tercapai.
- *Catatan untuk dapur* (maks 120), jumlah − / + (1–999), tombol *Tambah
  ke bill · Rp X* = (harga + Σ tambahan) × jumlah; nonaktif sampai semua
  grup memenuhi minimal.
- Menu tanpa grup modifier langsung masuk bill seperti v0.11.0 (catatan
  dari kolom catatan lembar menu).

### Aturan bisnis modifier

- Validasi di `lakuna_domain` (`validateModifierGroup`,
  `validateModifierSelection`) dan diulang di `lakuna_data` saat menambah
  item: setiap opsi milik grup yang terpasang di produk, tersedia, tidak
  dobel; jumlah per grup di antara min dan maks → `ModifierSelectionInvalid`.
- **Harga**: `sale_items.unit_price` tetap harga dasar (grosir berlaku pada
  harga dasar); kolom baru `modifier_delta` = Σ tambahan per satuan baris;
  `line_total = (unit_price + modifier_delta) × jumlah`, minimal 0 per
  satuan (Σ tambahan < −harga ditolak `ModifierPriceInvalid`).
  `sale_item_modifiers` menyimpan nama grup, nama opsi, dan
  `price_delta` beku.
- **Gabung baris** hanya bila varian, satuan, catatan, **set
  modifier** (kolom `modifier_key` = id opsi terurut), dan **tambahan per
  satuan** sama (harga opsi yang diubah di master membuat baris baru), dan
  baris masih *Baru*.
- Mengubah jumlah memeriksa ulang harga: grosir + tambahan negatif yang
  membuat harga satuan di bawah 0 ditolak `ModifierPriceInvalid`. Menghapus
  item ikut menghapus (soft delete) baris `sale_item_modifiers`-nya.
- **Tiket dapur & struk**: modifier tampil di bawah nama item (`  + Besar`,
  `  + Tanpa nasi -3.000` di struk), catatan berawalan `*`. Baris panel
  bill menampilkan modifier sebagai teks kecil.
- Stok tidak dipengaruhi modifier (resep di Fase 3). Kasir retail belum
  memakai modifier (gap; toko F&B memakai layar Meja / Take away).

### Data (migrasi `modifier`)

- `modifier_groups`: `tenant_id`, `name`, `min_select`, `max_select`,
  `sort_order` + kolom standar.
- `modifiers`: `tenant_id`, `modifier_group_id`, `name`, `price_delta`,
  `is_default`, `is_available`, `sort_order` + kolom standar.
- `product_modifier_groups`: `tenant_id`, `product_id`,
  `modifier_group_id`, `sort_order` + kolom standar (soft delete saat
  dilepas).
- `sale_item_modifiers`: `tenant_id`, `sale_item_id`, `modifier_id`,
  `group_name`, `name`, `price_delta`, `sort_order` + kolom standar.
- `sale_items` tambah `modifier_delta` (bawaan 0) dan `modifier_key`
  (nullable).

### Kriteria selesai v0.12.0

Di tablet: buat grup Ukuran (wajib, Reguler / Besar +4.000) dan Topping
(opsional, maks 2, Keju habis) → pasang di Kopi Susu Aren → di Meja pilih
Besar + Boba, catatan, jumlah 2 → bill "2 × Kopi Susu Aren + Besar, Boba"
Rp 66.000 → tiket dapur dan struk menampilkan modifier → bayar.

## Lingkup v0.13.0 · Split bill (brainstorming 3 Nov 2026)

Kanvas Lakuna 1.9 *Split bill* (`F1-Split-Bill`) dan keputusan Storeku
v0.12.0 menjawab semua pertanyaan utama: bill tetap **satu nota**, setiap
bagian tamu dicatat sebagai **pembayaran** di nota yang sama dengan label
tamu, sehingga laporan dan stok tidak terpecah. Perbedaan dari Storeku:
kembalian tunai dicatat **per pembayaran** (kolom `payments.change_amount`
sudah ada), dan aturan dibagi ke `lakuna_domain` (`split_bill.dart`) serta
`lakuna_data` (`split_bill.dart`).

### Layar 1.9 `/meja/split/:bill`

- Masuk dari panel bill (1.7): tombol *Split bill* (sebelumnya "segera")
  aktif bila bill berisi item (item *Baru* boleh). Izin `sales:create` +
  `open_bills:manage`.
- Kepala: "Split bill · Meja M1 · 3 tamu", catatan tarif ("Service 5% ·
  PB1 10%" atau "Pajak & service: tidak aktif"), tombol kembali.
- **Jumlah tamu** 2–8 (label A–H), − / +; bawaan = jumlah tamu bill
  (dibatasi 2–8).
- **Mode** (tab): *Per item* / *Bagi rata* / *Nominal bebas*.
- **Per item**: setiap baris item (porsi) menampilkan "2× Nasi Goreng" +
  modifier + "Rp 28.000 / porsi" dan chip tamu A…H. Mengetuk chip tamu
  memindah **satu porsi** dari baris itu ke tamu tersebut; jumlah pecahan
  atau ≤ 1 dipindah utuh. Mengetuk chip tamu yang sudah dipilih pada baris
  satu porsi mengembalikannya ke *belum dibagi*. Petunjuk: "Ketuk tamu
  untuk memberi satu porsi. Item lebih dari 1 dibagi per porsi."
- **Kartu tamu** (kanan di layar lebar, di bawah di ponsel): huruf, "Tamu
  A", daftar porsi (mode item), tagihan, status *Belum bayar* / *Lunas ·
  Tunai* / *QRIS statis · menunggu* + *Sudah Terbayar* + *Batalkan*, tombol
  *Bayar bagian A*.
- **Nominal bebas**: satu kartu "Tamu berikutnya" dengan kolom nominal
  (≤ sisa tagihan) dan *Bayar*; tamu yang sudah bayar tampil sebagai kartu
  berlabel A, B, C… berurutan.
- **Ringkasan**: Total bill, Sudah dibayar (A, C), Menunggu konfirmasi
  (B), Sisa tagihan, catatan "Bill tetap terbuka sampai semua bagian lunas.
  Tiap bagian dicatat sebagai pembayaran di nota yang sama, jadi laporan &
  stok tidak terpecah."
- *Bayar bagian X* membuka layar Bayar yang sama (keypad, tunai, kartu,
  transfer, QRIS, beberapa metode) dengan judul "Bayar bagian A · Rp X".
  QRIS punya tombol tambahan *Tunggu konfirmasi* yang menyimpan bagian
  sebagai pembayaran **menunggu**. Setelah berhasil kembali ke layar split;
  bila bagian terakhir membuat bill lunas, tampil layar *Pembayaran
  selesai* + struk seperti *Tutup & bayar*.

### Aturan bisnis split

- **Domain** (`lakuna_domain/split_bill.dart`):
  - `SplitLimits` (tamu 2–8), `guestLabel(i)` A–H.
  - `allocateByWeight(total, weights)` membagi total dengan sisa terbesar
    (jumlah selalu sama dengan total; bobot nol → 0; urutan stabil).
  - `splitDues(mode, total, guests, guestSubtotals, unassigned)` →
    tagihan per tamu: *item* = proporsional terhadap Σ `line_total` porsi
    tamu (porsi yang belum bertamu ikut sebagai bobot agar tagihan
    sementara tidak membengkak), *rata* = bobot sama, *nominal* = kosong
    (nominal diketik kasir).
  - `splitPortion(quantity)` → jumlah satu porsi (1 satuan bila jumlah
    ≥ 2 satuan bulat, selain itu utuh).
- **Data** (`lakuna_data/split_bill.dart`):
  - `setBillSplit(bill, mode, guests)` menyimpan `sales.split_mode` dan
    `sales.split_guests`. Mengurangi jumlah tamu mengembalikan porsi tamu
    yang hilang ke *belum dibagi*.
  - `assignPortion(item, guest | null)` memecah baris: baris asal dikurangi
    satu porsi, baris baru (atau baris tamu yang sama dari asal yang sama)
    bertambah; `split_from_item_id` = baris asal, modifier disalin. Baris
    dengan jumlah 0 dihapus (soft delete, beserta modifier). Total baris
    dihitung ulang dengan harga satuan beku baris (grosir tidak dihitung
    ulang saat memecah, agar total bill tidak berubah).
  - `paySplitPart(bill, guest, payments, {pending})` → bagian tamu: cek
    sesi kasir terbuka, mode item mewajibkan semua porsi sudah punya tamu,
    tagihan tamu dihitung ulang dari data, pembayaran harus ≥ tagihan
    (kembalian tunai di pembayaran itu). Disimpan di `payments` nota yang
    sama dengan `guest_label`, status `paid` atau `pending` (hanya QRIS).
    Tamu yang sudah punya pembayaran (lunas atau menunggu) ditolak
    (`SplitPartPaid`).
  - `confirmSplitPayment` (*Sudah Terbayar*, izin `payments:confirm`) dan
    `cancelSplitPayment` (hapus pembayaran menunggu).
  - **Kunci**: begitu ada pembayaran bagian (menunggu atau lunas), ubah
    mode, jumlah tamu, pembagian porsi, tambah/ubah/hapus item, dan
    *Tutup & bayar* biasa ditolak (`SplitLocked`); pindah meja, kirim ke
    dapur, dan tandai disajikan tetap boleh. Batalkan bagian QRIS yang
    menunggu dulu bila bill perlu diubah.
  - **Batalkan bill** (izin `sales:void`) tetap boleh walau terkunci, agar
    sesi kasir bisa ditutup bila tamu pergi: bagian lunas tetap tercatat
    di bill batal (uangnya dikembalikan ke tamu; belum masuk sesi kasir
    karena `cash_session_id` baru diisi saat nota selesai), QRIS yang
    menunggu dihapus. Dialog batal menyebut jumlah yang dikembalikan.
  - **Lunas**: saat Σ (jumlah − kembalian) pembayaran `paid` = total bill,
    nota diselesaikan sekali dalam transaksi yang sama: nomor nota, stok,
    sesi kasir, service & PB1 beku, status `paid` (fungsi bersama dengan
    *Tutup & bayar*). `sales.paid_amount` = total nota (sama dengan
    retail), `sales.change_amount` = Σ kembalian, `item_count` = jumlah
    baris asal (porsi tidak dihitung terpisah).
  - Sesi kasir tidak bisa ditutup selama ada bill split dengan pembayaran
    di sesi itu yang belum lunas (`CashSessionHasOpenSplit`).
- **Struk** menggabung porsi kembali per produk (asal yang sama) dan
  mencantumkan pembayaran per tamu ("Tamu A · Tunai 62.000").
- **Tiket dapur**: memecah porsi tidak mengubah status dapur (baris baru
  menyalin `kitchen_status` dan `kitchen_ticket_id`); porsi yang dikirim
  bersamaan digabung kembali di tiket.
- **Izin**: atur split, bagi porsi, dan batalkan bagian menunggu butuh
  `open_bills:manage` + `sales:create`; *Sudah Terbayar* juga
  `payments:confirm`; bayar bagian lewat kasir butuh `sales:create`
  (QRIS lunas langsung juga `payments:confirm`, QRIS menunggu tidak).
- **Lunas di layar split** (*Sudah Terbayar* bagian terakhir): langsung ke
  layar *Pembayaran selesai* kasir dengan struk, cetak, dan cetak otomatis
  seperti *Tutup & bayar*.

### Data (migrasi `split`)

- `sales` tambah `split_mode` (enum `SplitMode`: `item`, `equal`, `amount`;
  nullable) dan `split_guests` (int, nullable).
- `sale_items` tambah `guest_label` (String?, `A`–`H`) dan
  `split_from_item_id` (UuidValue?).
- `payments` tambah `guest_label` (String?).
- `payments` untuk bill terbuka boleh ada (status `pending`/`paid`);
  laporan hanya menghitung nota `paid`.

### Kriteria selesai v0.13.0

Di tablet: meja M1, 3 tamu, 2× Nasi Goreng, 3× Es Teh, 1× Ayam Bakar →
Split bill per item → A bayar tunai (kembalian), B QRIS menunggu lalu
*Sudah Terbayar*, C kartu → bill lunas, struk menampilkan pembayaran per
tamu, meja kosong. Bagi rata Rp 100.000 untuk 3 tamu = 33.334 / 33.333 /
33.333. Nominal bebas: 50.000 + sisa.

## Lingkup v0.14.0 · Denah (brainstorming 3 Nov 2026)

Mengikuti keputusan Storeku v0.13.0 (*Keputusan v0.13.0 · Denah meja*),
dengan perbedaan karena Lakuna memakai `vyuh_node_flow` 0.32. Spike
(widget test) memastikan: `NodeFlowViewer` menggambar node kustom,
`onNodeTap` jalan, node `locked: true` tidak bisa digeser, `SnapPlugin` +
`GridSnapDelegate(20)` memberi `visualPosition` tersnap saat drag, dan
akhir drag/resize terbaca lewat plugin (`NodeDragEnded`, `ResizeEnded`).

### Model tata letak

- **Mode per area** `dining_areas.layout_mode` (`grid` / `floor`, bawaan
  `grid`). Meja tanpa area hanya tampil di Grid.
- **Kolom per meja**, bukan `layout_json` per area: konflik sinkronisasi
  Fase 2 cukup per baris meja. `dining_tables` tambah `shape`
  (`round` / `square` / `long` / `bar`, bawaan `square`), `pos_x`,
  `pos_y` (null = belum ditempatkan), `width`, `height` (bawaan 80),
  `can_merge` (bawaan false). **Tanpa kolom rotasi**: Orientasi 0°/90°
  menukar lebar dan tinggi.
- **Koordinat dunia**: lebar denah selalu 800 satuan, tinggi mengikuti
  rasio gambar (200–2000); tanpa gambar 800 × 560. Posisi dan ukuran
  bilangan bulat dalam satuan ini, jadi mengganti gambar dengan resolusi
  lain tidak menggeser meja.
- **Gambar denah** (1.7c): PNG/JPG/WebP/SVG ≤ 5 MB, disimpan seperti
  stiker QRIS (`media_files`, jenis baru `floorPlan`) lalu
  `dining_areas.floor_media_id`. Ukuran SVG dibaca dari `viewBox` atau
  `width`/`height`; bila tak terbaca dipakai 800 × 560. SVG digambar
  dengan `flutter_svg`. Mengunggah gambar langsung tersimpan (transaksi
  sendiri) dan mengubah area ke mode `floor`.
- *Ambil foto* hanya di Android/iOS (kamera lewat `image_picker`); di
  desktop tombolnya tidak tampil.

### Layar Meja (1.7b)

- Pilihan **Grid / Denah** di header tampil bila ada area mode denah;
  bawaan Denah bila ada (pilihan diingat selama aplikasi terbuka).
- Mode Denah: tab hanya area denah, legenda sama, kanvas
  `NodeFlowEditor` ber-`behavior: preview` (bukan `NodeFlowViewer`, agar
  `nodeShapeBuilder` untuk meja bulat tetap tersedia) dengan meja terkunci (geser & zoom saja, keterangan
  "Posisi terkunci · geser & zoom saja"), tombol zoom, minimap. Warna meja
  sama dengan kartu grid (kosong / terisi / minta bill), nama dan total
  bill tampil di meja; meja bulat memakai `CircleShape`. Ketuk meja =
  pilih meja seperti di grid (panel bill sama).
- Meja area itu yang belum ditempatkan tampil sebagai chip *Belum
  ditempatkan* di bawah kanvas agar tetap bisa dibuka.
- Tombol **Atur denah** (`settings:manage`) di header layar Meja dan di
  Master › Meja & area.

### Atur denah (1.7d) `/meja/denah?area=<id>`

- Izin `settings:manage` (UI dan repositori). Tab area + *+ Area*.
- Panel kanan: **Mode tata letak** Grid / Denah. Denah tanpa gambar
  menampilkan panel unggah 1.7c (dengan *Tips gambar*) di tempat kanvas.
- Panel kiri: **Tambah meja** (Bulat · 2 kursi 60×60, Kotak · 4 kursi
  80×80, Panjang · 6 kursi 140×80, Panjang · 8 kursi 180×80, Kursi bar ·
  1 kursi 40×40). Desain menyebut "seret ke denah"; diputuskan **ketuk
  untuk menambah** di tengah tampilan (sama di layar sentuh dan mouse),
  nama otomatis `M<n>` berikutnya yang belum dipakai di cabang.
  **Belum ditempatkan**: meja area ini tanpa posisi dan meja tanpa area;
  ketuk untuk menaruh di tengah tampilan (meja tanpa area pindah ke area
  ini saat disimpan).
- Kanvas `NodeFlowEditor`: gambar denah = node terkunci di
  `NodeRenderLayer.background`; meja = node tanpa port dengan resizer
  (min 20, maks 600); snap 20 px (toggle), minimap, tombol zoom, label
  zoom %. Toolbar: undo/redo selama sesi edit, *Ganti gambar denah*,
  slider transparansi denah (tampilan saja, tidak disimpan).
- Panel properti meja terpilih: nama, kursi, bentuk (Bulat / Kotak /
  Panjang / Bar), lebar, tinggi (20–600), orientasi (Mendatar / Tegak),
  *Boleh digabung dengan meja sebelah*, *Hapus meja*.
- Semua perubahan meja dan mode adalah **draf** sampai **Simpan tata
  letak** (satu transaksi). Keluar atau pindah tab area dengan draf belum
  disimpan menanyakan *Buang perubahan?*.
- **Simpan** (`saveFloorLayout`): nama wajib dan unik per cabang
  (termasuk antar draf), kursi 1–99, ukuran 20–600, posisi 0–5000; meja
  yang dihapus ditolak bila punya bill terbuka (`DiningInUse`). Meja
  bermodel baru masuk urutan terakhir.
- Ponsel (< 600 px): panel ditumpuk di bawah kanvas (tinggi kanvas 460, cukup untuk geser dan zoom dengan jari),
  palet dan daftar *Belum ditempatkan* berupa chip.

### Data (migrasi `denah`)

Enum baru `DiningLayoutMode`, `TableShape`; `MediaKind.floorPlan`. Kolom
baru di `dining_areas` (`layout_mode`, `floor_media_id`) dan
`dining_tables` (`shape`, `pos_x`, `pos_y`, `width`, `height`,
`can_merge`), semua punya bawaan atau nullable.

### Kriteria selesai v0.14.0

Di tablet: buka Atur denah → unggah gambar → tambah meja dari palet,
geser (tersnap 20), ubah ukuran/orientasi → simpan → layar Meja mode
Denah menampilkan meja di posisinya dengan warna status → ketuk meja →
buka bill. Ponsel 360 px tanpa luapan. Meja tanpa posisi tetap bisa
dibuka dari chip *Belum ditempatkan*.

## Rilis berikutnya (keputusan dari Storeku, dirinci saat dikerjakan)

- **v0.12.0 Modifier**: dirinci di *Lingkup v0.12.0* di atas.
- **v0.13.0 Split bill**: dirinci di *Lingkup v0.13.0* di atas.
- **v0.14.0 Denah**: dirinci di *Lingkup v0.14.0* di atas.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Meja grid, open bill, take away, tiket dapur | 1.7, 1.7e | Dirilis v0.11.0 | Tab area: *Semua* + area (tanpa tab *Tanpa area*; meja tanpa area tampil di *Semua*). |
| Meja & area di Master data | 1.17 | Dirilis v0.11.0 | Posisi denah di v0.14.0. |
| Pajak & service | 1.26 | Dirilis v0.11.0 | Retail belum memakai tarif. |
| Tutup & bayar | 1.6 | Dirilis v0.11.0 | Rincian bill (item, subtotal, service, PB1, total) tampil di kolom kanan layar Bayar, di atas pilihan metode. |
| Catatan dapur | 1.7 | Dirilis v0.11.0 | Kolom catatan di lembar menu berlaku untuk item berikutnya yang ditambahkan, lalu dikosongkan. *Minta bill* hanya untuk dine in. |
| Modifier | 1.8, 1.16b, 1.17b | Dirilis v0.12.0 | Form grup berupa dialog (bukan panel kanan / lembar bawah). Total di sheet 1.8 memakai harga dasar; harga grosir dihitung di lapisan data saat item masuk bill. Baris rincian struk = (harga + tambahan) × jumlah, modifier di bawah nama. |
| Modifier di kasir retail | — | Belum | Toko F&B memakai layar Meja / Take away. |
| Toggle *Kirim ke tiket dapur* / *Catatan bebas* per menu | 1.16b | Rilis v0.43.0 | Spec F1-10g. |
| Split bill | 1.9 | Dirilis v0.13.0 | Layar Bayar bagian menampilkan porsi tamu (mode per item) atau semua item (rata/nominal), subtotal, service, PB1, total bill, lalu baris *Bagian tamu X*. Panel bill menampilkan porsi bertamu sebagai baris sendiri dengan label tamu. Tombol *Tunggu konfirmasi* QRIS bernama *Simpan, tunggu konfirmasi*. |
| Split bill: tarif beku | — | Belum | Tarif service/PB1 dibaca ulang tiap bayar bagian; perubahan tarif di tengah split ditanggung tamu terakhir. Bekukan tarif saat bagian pertama dibayar. |
| Split bill: kas per sesi | — | Belum | Tunai bagian masuk sesi yang menyelesaikan nota; laci di tengah sesi belum menghitungnya. Cek tutup sesi berlaku per cabang. Catat `cash_session_id` per pembayaran sebelum sinkronisasi Fase 2. |
| Split bill: baris porsi | — | Sederhana | Memindah baris satu porsi menyisipkan baris baru dan menghapus yang lama (outbox bertambah). Ubah label di tempat bila seluruh baris pindah. Ubah jumlah baris porsi memakai harga ulang baris itu saja. |
| Split bill: retur bagian lunas | — | Belum | Void/retur nota di F1-13. |
| Denah | 1.7b–d | Dirilis v0.14.0 | Layar *Atur denah* (`/meja/denah`) untuk pemegang `settings:manage`: unggah PNG/JPG/WebP/SVG ≤ 5 MB (kamera di Android/iOS), preset meja, chip *Belum ditempatkan*, geser + ubah ukuran dengan snap 20 px, undo/redo, simpan sekali per area dalam satu transaksi. Layar Meja: pilihan Grid / Denah, kanvas terkunci, warna & total sama dengan grid. Layout lebar (≥ 1100 px) tiga kolom; di bawahnya satu kolom bergulir. |
| Denah: tarik dari palet | 1.7d | Ketuk | Preset dan meja belum ditempatkan ditaruh di tengah tampilan lalu digeser; tarik langsung dari palet belum ada. |
| Denah: garis bantu, LOD | 1.7d | Belum | `LodPlugin` dan garis perataan antar meja belum dipakai; cukup untuk denah ≤ 50 meja. |
| Denah: seret di layar sentuh | — | Belum diuji perangkat | Uji widget dan Xvfb memakai mouse; uji di tablet Android nyata sebelum Fase 1 ditutup. |
| Denah: peta mini mode gelap | — | Tema terang | `MinimapPlugin` memakai `MinimapTheme.light` di kedua mode. |
| Denah: pilihan Grid/Denah diingat | 1.7b | Per layar | Pilihan dan area denah kembali ke bawaan setiap layar Meja dibangun ulang (mis. kembali dari bayar). Simpan di layanan yang hidup selama aplikasi; pilih area dari meja bill yang dibuka. |
| Denah: keluar lewat menu samping | 1.7d | Tanpa konfirmasi | *Kembali* dan tombol kembali sistem bertanya sebelum membuang draf; pindah menu lewat sidebar belum. |
| Denah: geser beberapa meja | 1.7d | Satu langkah undo per meja | Pilih banyak (seret kotak/Ctrl) masih bisa; geser bersama tercatat per meja. |
| Denah: gambar lama | — | Tetap tersimpan | Mengganti gambar denah tidak menghapus berkas lama di `media_files`; bersihkan sebelum sinkronisasi Fase 2. |
| Denah: SVG | 1.7c | Cek awal `<svg` | SVG dengan DTD internal ditolak; SVG rusak yang lolos tampil kosong. |
| Denah: ukuran saat mengetik | 1.7d | Divalidasi saat simpan | Lebar/tinggi di luar 20–600 tampil apa adanya sampai *Simpan* menolaknya. |
| Denah: pas layar saat ganti area | 1.7d | Sekali saat kanvas dipasang | Berpindah antar dua area denah memakai tampilan sebelumnya; tekan tombol *pas layar*. |
| Denah: ketuk meja | 1.7b | Dirilis v0.14.0 | Ketuk = jari naik tanpa bergeser > 18 px dan tanpa jari kedua, sehingga menggeser/zoom denah di atas meja tidak membuka meja. Selama jari di kanvas, gulir halaman dikunci. |
| Gabung meja | Ada (`can_merge` di 1.7d) | Rilis v0.40.0 | [F1-10d](2026-11-13-f1-10d-gabung-meja-design.md): gabung bill dua meja *Boleh digabung*; satu bill di dua meja kosong masih gap. |
| Printer dapur terpisah | — | Rilis v0.41.0 | [F1-10e](2026-11-13-f1-10e-printer-dapur-design.md): satu printer dapur per perangkat (jaringan/Bluetooth, kertas sendiri), tiket otomatis saat *Kirim ke dapur*; printer per stasiun masih gap. |
| Nomor TA/K per perangkat | — | v0.11.0 tanpa kode perangkat | `TA-01`/`K-0001` urut per perangkat; dua tablet satu cabang bisa sama. Tambah kode perangkat sebelum sinkronisasi Fase 2. |
| Kurangi item produk nonaktif | — | Hanya hapus | Mengurangi jumlah memakai harga ulang dan ditolak (`SaleItemUnavailable`); hapus baris tetap bisa. |
| Durasi kartu meja | 1.7 | Diperbarui saat layar dibangun ulang | Tambah penyegar per menit bila perlu. |
| Tes migrasi otomatis | — | Uji manual data v0.10.0 | Tambah fixture SQLite v0.10.0 di `lakuna_data/test`. |

## Kriteria selesai v0.11.0

Di tablet: buka meja → tambah menu → kirim ke dapur → tandai disajikan →
minta bill → tutup & bayar → meja kosong lagi; take away bernomor dari
buka sampai bayar; batalkan bill dengan alasan; tarif service & PB1
tampil di bill dan struk; layar jalan di desktop, tablet, ponsel tanpa
luapan.
