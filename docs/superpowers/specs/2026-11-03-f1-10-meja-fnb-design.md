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

## Rilis berikutnya (keputusan dari Storeku, dirinci saat dikerjakan)

- **v0.12.0 Modifier**: Master › *Grup modifier* (wajib/opsional,
  min/maks, opsi dengan harga tambahan boleh negatif, opsi habis), form
  produk › *Modifier*, sheet 1.8 di layar Meja (catatan dapur, jumlah,
  *Tambah ke bill · Rp X*); snapshot nama & harga di `sale_item_modifiers`;
  gabung baris hanya bila modifier dan catatan sama.
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
| Tutup & bayar | 1.6 | Dirilis v0.11.0 | Sisi kiri layar Bayar hanya menampilkan subjudul (label · n item), belum daftar item baca-saja. |
| Catatan dapur | 1.7 | Dirilis v0.11.0 | Kolom catatan di lembar menu berlaku untuk item berikutnya yang ditambahkan, lalu dikosongkan. *Minta bill* hanya untuk dine in. |
| Modifier | 1.8, 1.16b, 1.17b | Belum | v0.12.0. |
| Split bill | 1.9 | Belum | v0.13.0. |
| Denah | 1.7b–d | Belum | v0.14.0. |
| Gabung meja | Ada (`can_merge` di 1.7d) | Belum | Setelah denah. |
| Printer dapur terpisah | — | Belum | Tiket memakai printer perangkat. |

## Kriteria selesai v0.11.0

Di tablet: buka meja → tambah menu → kirim ke dapur → tandai disajikan →
minta bill → tutup & bayar → meja kosong lagi; take away bernomor dari
buka sampai bayar; batalkan bill dengan alasan; tarif service & PB1
tampil di bill dan struk; layar jalan di desktop, tablet, ponsel tanpa
luapan.
