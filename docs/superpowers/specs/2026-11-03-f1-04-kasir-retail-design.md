# F1-04 · Kasir retail

- **Fase:** 1
- **Status:** Rilis v0.6.0 (inti, bersama inti F1-05), ada gap
- **Layar desain:** 1.4 *Kasir retail · tablet*, 1.11 *Kasir · mobile*,
  1.11b *Keranjang (sheet bawah) · mobile*, versi gelapnya; 1.4b menyusul.
  Kanvas [Desain UI Lakuna](https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525)
- **Acuan Storeku:** `docs/superpowers/specs/2026-11-02-f1-04-kasir-retail-design.md`
- **Bergantung pada:** F1-03 (sesi kasir), F1-07 (katalog), F1-05 (bayar)

## Tujuan

Kasir melayani antrean dengan cepat: scan atau cari barang, harga grosir dan
satuan konversi otomatis, lalu bayar. Semua jalan offline. Kasir tanpa bayar
tidak menghasilkan penjualan, jadi v0.6.0 membawa inti F1-05 (tunai, kartu,
transfer) sekaligus. Lihat spec F1-05 untuk layar bayar.

## Lingkup v0.6.0

Termasuk:

- Rute `/kasir` (menu *Kasir*, navigasi bawah ponsel), izin `sales:create`.
- **Wajib sesi kasir terbuka** di perangkat ini. Tanpa sesi: keadaan kosong
  "Buka sesi kasir dulu" dengan tombol ke `/sesi-kasir`.
- Kolom cari dengan label *Scanner siap*: mengetik menyaring grid (nama, SKU,
  barcode); **Enter** dengan teks yang sama persis dengan barcode/SKU varian
  atau barcode satuan konversi langsung memasukkan barang itu dan
  mengosongkan kolom. Tidak dikenal → pesan "Barcode tidak dikenal", kolom
  dikosongkan.
- Chip kategori (*Semua* + kategori yang punya produk aktif).
- Grid produk aktif (`is_active`): kotak inisial, nama, harga ("mulai Rp X"
  bila harga varian berbeda; daftar ponsel menampilkan rentang penuh), stok
  (merah bila ≤ 0, abu-abu "—" untuk jasa/menu).
- Di tablet/desktop kolom cari **tetap fokus** saat produk atau tombol
  keranjang diklik, jadi scanner (yang bekerja seperti keyboard) tidak
  kehilangan input. Setelah dialog ditutup fokus kembali ke kolom cari.
- Ketuk produk: satu varian tanpa satuan lain → langsung masuk keranjang;
  selain itu → dialog pilih varian × satuan dengan harga masing-masing.
- **Keranjang (panel *Pesanan*)**: "Pelanggan umum · Ambil sendiri", baris
  item (nama + varian, satuan, catatan "grosir ≥ N", −/+, total baris; ketuk
  angka jumlah untuk mengetik jumlah termasuk pecahan "0,5"), Subtotal,
  *Diskon grosir*, **Total**, tombol *Kosongkan* dan **Bayar**.
- Ponsel (< 600 px): daftar produk satu kolom, bilah bawah "N produk · M
  item · Lihat pesanan" + total + Bayar; keranjang di sheet bawah (1.11b).
- Bilah atas kasir: toko · cabang, "Kasir: <nama> · Sesi dibuka HH.mm".
  *Ganti kasir* dan status offline tetap dari shell aplikasi.

Tidak termasuk (gap, lihat tabel): pelanggan, diskon manual, nota tersimpan
(1.4b), foto produk, catatan per item, peringatan stok tidak boleh minus.

## Aturan bisnis (`lakuna_domain`, `sale.dart`)

- Satu **baris keranjang** = (varian, satuan). Satuan dasar punya `unit_id`
  kosong dan isi 1. Barang yang sama dengan satuan sama digabung.
- **Harga satuan baris**:
  - Satuan dasar: `unitPriceFor(tiers, qty, sellPrice)` dari F1-07, dengan
    jumlah dalam satuan dasar = jumlah baris. Tingkat tertinggi yang
    dicapai menang.
  - Satuan konversi: harga satuan itu (`conversionSellPrice`), **tanpa**
    grosir (tingkat grosir didefinisikan per satuan dasar). Sama dengan
    Storeku.
- **Total baris** = harga satuan × jumlah, dibulatkan setengah menjauhi nol
  ke rupiah (jumlah pecahan). **Harga daftar** = harga tanpa grosir; *Diskon
  grosir* = Σ (harga daftar − harga satuan) × jumlah.
- Subtotal = Σ total baris + diskon grosir (= Σ harga daftar × jumlah);
  Total = Σ total baris. Pembulatan total ikut pengaturan (F1-18, belum),
  jadi tidak ada pembulatan di v0.6.0.
- Jumlah baris > 0, paling banyak 3 desimal (Qty). Jumlah 0 lewat tombol −
  menghapus baris.
- **Harga dihitung ulang di penyimpanan** dari database, bukan dari layar.
  Bila berbeda dari keranjang (harga diubah di perangkat lain lalu sync),
  nota memakai harga database dan layar sukses memakai angka nota.
- **Stok** bergerak saat nota tersimpan: satu `stock_movements` sumber
  `sale` per baris barang (bukan jasa/menu), jumlah = −(jumlah × isi), biaya
  satuan = rata-rata biaya cache saat itu (untuk HPP F1-16). Stok boleh
  minus (pengaturan *Izinkan stok minus* menyusul di F1-18); layar sukses
  memperingatkan varian yang jadi minus.

## Data

Migrasi `penjualan`, model di `lakuna_server/lib/src/sales/`.

- **`sales`**: `tenant_id`, `outlet_id`, `device_id`, `cash_session_id`,
  `staff_id`, `number` (nota `PST-K01-261103-0001`, unik per tenant),
  `status` (`completed`; `open`/`void` menyusul), `subtotal`,
  `tier_discount`, `total`, `paid_amount`, `change_amount`, `sold_at`,
  `item_count`.
- **`sale_items`**: `tenant_id`, `sale_id`, `variant_id`, `product_unit_id?`,
  `product_name`, `variant_name`, `unit_name`, `factor_milli`,
  `quantity_milli` (dalam satuan baris), `list_price`, `unit_price`,
  `line_total`, `unit_cost` (biaya rata-rata per satuan dasar saat jual),
  `tracks_stock`, `sort_order`.
- **`payments`**: lihat spec F1-05.
- Nomor nota: penghitung harian per perangkat = nomor tertinggi hari itu
  dengan awalan `OUTLET-DEVICE-YYMMDD-` + 1, dicari di transaksi yang sama.
  Tanggal = tanggal lokal zona cabang.
- `checkoutSale` (lakuna_data) dalam satu `LakunaStore.write`: cek sesi
  terbuka, muat harga, hitung ulang, validasi bayar, sisipkan nota + item +
  pembayaran, catat pergerakan stok, semua ikut outbox.
- **Sesi kasir**: rekap laci (F1-03) kini mengisi *Penjualan tunai* = Σ
  pembayaran tunai bersih (diterima − kembalian) nota di sesi itu, serta
  kartu *Transaksi* dan *Penjualan* di layar tutup sesi.

## Izin

| Aksi | Izin |
| --- | --- |
| Buka kasir, simpan penjualan | `sales:create` |

## Kasus tepi

- Scanner mengetik sangat cepat lalu Enter: kolom cari tidak dikontrol
  (`initial` + `onChange`), pencocokan pakai `normalizeCode`.
- Barcode milik satuan konversi (Dus) → baris dengan satuan itu.
- Produk dinonaktifkan atau dihapus setelah masuk keranjang → simpan
  ditolak "Produk tidak tersedia lagi", baris ditandai.
- Sesi kasir ditutup dari layar lain → simpan ditolak "Sesi kasir sudah
  ditutup".
- Simpan dua kali (ketuk ganda): tombol mati selama menyimpan; keranjang
  dikosongkan setelah tersimpan.
- Nota pertama hari baru → nomor 0001 lagi.

## Pengujian (TDD)

- Domain: harga baris (dasar + grosir, konversi tanpa grosir, pecahan),
  diskon grosir, subtotal/total, gabung baris, nomor nota berikutnya.
- Data: checkout menulis nota, item, pembayaran, stok −(qty × isi) dan
  outbox; harga dari DB; tanpa sesi ditolak; produk nonaktif ditolak; nomor
  urut per hari; rekap laci memuat penjualan tunai.
- View model: cari/filter, scan Enter, tambah/kurangi/ketik jumlah, total,
  tanpa sesi.
- Widget: alur tablet (scan → bayar tunai → sukses → transaksi baru) dan
  ponsel 360 px (sheet keranjang).

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Pelanggan, diskon manual, nota tersimpan | 1.4b | Belum | v0.7.0 bersama F1-13 dan Persetujuan PIN |
| Foto produk di kartu | Foto | Kotak inisial | Ikuti gap foto F1-07 |
| Catatan per item | Baris catatan | Hanya catatan grosir | Bersama modifier F1-10 |
| *Izinkan stok minus* | Pengaturan 1.26 | Selalu boleh, ada peringatan | F1-18 |
| *Wajib buka sesi kasir* | Pengaturan, default aktif | Selalu wajib | F1-18 |
| Pilihan satuan di dialog | Varian × satuan | Satuan dasar disebut bila produk punya satuan konversi | Cukup |
| Stok minus di daftar ponsel | Merah | Abu-abu (grid tablet sudah merah) | Rapikan bersama F1-08 Stok |
| Sheet pesanan ponsel | Menutupi layar penuh | Di dalam shell, navigasi bawah tetap terlihat | Cukup |

## Kriteria selesai

Inti v0.6.0: jual dengan scan/cari di desktop dan ponsel, stok berkurang
lewat ledger, nota bernomor perangkat, rekap laci memuat penjualan tunai,
semua tes lulus, uji manual dengan tangkapan layar.
