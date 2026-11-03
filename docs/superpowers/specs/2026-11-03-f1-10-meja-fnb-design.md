# F1-10 · Meja F&B, open bill, modifier, split bill

- **Fase:** 1
- **Status:** Berjalan: v0.11.0 (grid, open bill, take away, pajak & service) dirilis; modifier, split bill, denah menyusul
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
ditunda (semua menu ikut tiket dan boleh catatan).

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

## Rilis berikutnya (keputusan dari Storeku, dirinci saat dikerjakan)

- **v0.12.0 Modifier**: dirinci di *Lingkup v0.12.0* di atas.
- **v0.13.0 Split bill**: satu nota, pembayaran per tamu (`guest_label`),
  mode per item / bagi rata / nominal bebas, QRIS bagian menunggu +
  *Sudah Terbayar*, nota lunas saat semua bagian lunas.
- **v0.14.0 Denah**: `vyuh_node_flow` (gambar denah = node terkunci di
  latar, meja = node tanpa port, orientasi 0°/90°, snap 20 px, minimap),
  unggah gambar PNG/JPG/WebP/SVG ≤ 5 MB, kasir memakai `NodeFlowViewer`.

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
| Toggle *Kirim ke tiket dapur* / *Catatan bebas* per menu | 1.16b | Belum | Semua menu ikut tiket dan boleh catatan. |
| Split bill | 1.9 | Belum | v0.13.0. |
| Denah | 1.7b–d | Belum | v0.14.0. |
| Gabung meja | Ada (`can_merge` di 1.7d) | Belum | Setelah denah. |
| Printer dapur terpisah | — | Belum | Tiket memakai printer perangkat. |
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
