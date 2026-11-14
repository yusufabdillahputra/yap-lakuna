# Penyesuaian & stok minimum

Stok di Lakuna berupa ledger: setiap perubahan dicatat sebagai pergerakan (stok awal, pembelian, penjualan, retur, penyesuaian). Saldo tidak pernah diedit langsung.

![Penyesuaian stok dengan alasan per baris.](stock)

## Melihat stok

Buka **Stok**. Tab **Daftar produk** menampilkan stok per lokasi, minimum, dan nilai (HPP). Tab **Kartu stok** menampilkan riwayat pergerakan satu produk.

## Cetak daftar stok untuk opname

Tekan **Cetak stok** di bagian atas layar Stok. Lakuna membuat PDF A4 berisi semua barang di lokasi terpilih: SKU/barcode, stok, minimum, nilai, dan kolom **Fisik** yang kosong untuk ditulis tangan saat menghitung di rak. Kata pencarian tidak menyaring cetakan, jadi daftarnya selalu lengkap.

- Di komputer, PDF disimpan di folder dokumen Lakuna dan lokasinya ditampilkan di layar. Buka lalu cetak dari penampil PDF.
- Di HP/tablet, lembar bagikan terbuka: pilih printer, simpan, atau kirim.

Setelah menghitung, masukkan angka fisiknya di tab **Penyesuaian**.

## Penyesuaian stok (stock opname)

1. Buka tab **Penyesuaian**.
2. Pilih **Alasan umum**: *Cek rutin*, *Rusak*, *Hilang*, *Kedaluwarsa*, atau *Lainnya*.
3. Di **Scan / tambah produk**, scan barcode atau ketik nama produk yang dihitung.
4. Isi stok **Fisik**. Selisih terhadap stok sistem dihitung otomatis. Isi alasan baris bila berbeda.
5. Tekan **Simpan penyesuaian**.

Penyesuaian butuh izin *Penyesuaian stok*. Baris yang stok fisiknya kosong tidak disimpan.

## Stok minimum

Isi **Stok min** per varian di form produk. Tab **Stok minimum** dan Beranda menampilkan produk yang stoknya di bawah minimum, supaya Anda tahu kapan harus [membeli](purchases).

Tekan **Buat pembelian** di bawah daftar itu untuk membuka *Pembelian baru* yang sudah berisi semua barang di bawah minimum, dengan lokasi terima = lokasi yang sedang dilihat. Jumlah sarannya **2 × stok minimum − stok sekarang**, dibulatkan ke atas (mis. stok 2, minimum 20 → beli 38). Harga tiap baris diisi dari harga beli pada pembelian terakhir barang itu (dihitung per satuan dasar, mis. Rp 185.000 per dus isi 6 menjadi Rp 30.833); barang yang belum pernah dibeli memakai harga modal. Catatan di atas form menyebut berapa barang yang harganya diambil dari pembelian terakhir. **Supplier** langsung terisi dengan supplier pembelian terakhir untuk sebagian besar barang itu (catatan di atas form menyebut namanya dan berapa barang); ganti bila perlu, sesuaikan jumlah dan harga, lalu simpan draf atau terima barang seperti biasa. Tombol ini hanya tampil untuk staf dengan izin *Kelola pembelian*.

Draf tidak menambah stok, jadi barang yang sudah masuk draf tetap tampil di bawah minimum. Bila sudah ada **draf pembelian** ke lokasi yang sama yang memuat sebagian barang itu, **Buat pembelian** lebih dulu menampilkan *Sudah ada draf pembelian* dengan nomor draf dan berapa barang yang sudah ada di dalamnya. Pilih **Buka draf** untuk melanjutkan draf itu (barang yang belum ada di draf ditambah manual), **Buat draf baru** bila memang perlu pembelian terpisah, atau **Batal**. Bila ada beberapa draf, yang paling banyak memuat barang yang sama dibuka; draf lain bisa dilihat di menu *Pembelian*.

## Lokasi stok

Tab **Lokasi stok** untuk menambah etalase, gudang, atau rak terpisah di cabang ini.

> [!note] Selisih penyesuaian masuk ke baris *Penyesuaian stok* di [laporan laba rugi](reports).
