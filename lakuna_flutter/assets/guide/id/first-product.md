# Menambah produk pertama

Produk harus ada sebelum bisa dijual di kasir. Satu produk boleh punya beberapa varian (mis. ukuran), satuan konversi (mis. dus isi 12), dan harga grosir.

![Form Edit produk dengan tab varian, satuan, grosir, dan modifier.](product)

> [!note] Saat setup toko, langkah 4 sudah bisa membuat satu produk pertama (nama, harga, satuan, barcode, stok awal) atau langsung membuka import Excel.

## Langkah

1. Buka menu **Produk**, lalu tekan **Produk baru**.
2. Di *Info dasar*, isi **Nama produk**, pilih **Kategori**, dan **Jenis**: *Barang* (stok dilacak), *Jasa* (tanpa stok), atau *Menu F&B*.
3. Isi **Satuan dasar**, misalnya pcs, botol, atau kg. Stok selalu disimpan dalam satuan ini.
4. Di tab **Varian**, isi harga beli, harga jual, stok minimum, dan stok awal. Tambah baris dengan **Tambah varian** bila perlu. SKU dan barcode boleh diisi untuk scan.
5. Tekan **Simpan**.

## Barang tanpa barcode

Untuk barang buatan sendiri (kue, racikan, barang curah), kosongkan field **Barcode** lalu tekan ikon tongkat di ujung field (**Buat barcode**). Lakuna mengisi kode EAN-13 toko berawalan `20` yang belum dipakai produk lain. Simpan produk, lalu cetak labelnya lewat **Cetak label**; kasir cukup memindai label itu.

> [!note] Barang impor dengan barcode UPC-A (12 digit) tetap ditemukan walau pemindai membacanya sebagai 13 digit berawalan `0`, di Kasir, Stok, Pembelian, dan pencarian produk.

## Satuan & harga grosir

- Tab **Satuan & konversi**: tambah satuan seperti *dus* berisi 12 pcs. Menjual 1 dus mengurangi 12 pcs dari stok. Harga kosong berarti harga satuan dasar × isi.
- Tab **Harga grosir**: atur harga per satuan mulai jumlah tertentu. Kasir memakainya otomatis.

## Banyak produk sekaligus

Di **Produk**, tekan **Import Excel**. Tekan **Unduh templat** untuk berkas Excel berisi judul kolom (Nama, Kategori, Jenis, Satuan, SKU, Barcode, Harga beli, Harga jual, Stok awal, Stok minimum) dan dua baris contoh. Ganti baris contoh dengan produk Anda (baris contoh yang tertinggal otomatis dilewati), lalu tekan **Pilih berkas**. Pratinjau menampilkan baris yang siap dan baris yang dilewati beserta alasannya.

> [!note] Kategori dan satuan juga bisa diatur di **Master data**. Urutan kategori di sana menjadi urutan tab di layar kasir.

Setelah produk tersimpan, lanjutkan ke [Transaksi & harga grosir](sale).
