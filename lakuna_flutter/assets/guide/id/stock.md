# Penyesuaian & stok minimum

Stok di Lakuna berupa ledger: setiap perubahan dicatat sebagai pergerakan (stok awal, pembelian, penjualan, retur, penyesuaian). Saldo tidak pernah diedit langsung.

![Penyesuaian stok dengan alasan per baris.](stock)

## Melihat stok

Buka **Stok**. Tab **Daftar produk** menampilkan stok per lokasi, minimum, dan nilai (HPP). Tab **Kartu stok** menampilkan riwayat pergerakan satu produk.

## Cetak daftar stok untuk opname

Tekan **Cetak stok** di bagian atas layar Stok. Lakuna membuat PDF A4 berisi semua barang di lokasi terpilih: SKU/barcode, stok, minimum, nilai, dan kolom **Fisik** yang kosong untuk ditulis tangan saat menghitung di rak. Kata pencarian tidak menyaring cetakan, jadi daftarnya selalu lengkap. Di tab **Stok minimum**, tombolnya menjadi **Cetak stok minimum**: PDF hanya berisi barang di bawah minimum, dengan kolom **Saran beli** (**2 × minimum − stok**, stok minus dihitung 0, dibulatkan ke atas, sama dengan **Buat pembelian**) dan tanpa kolom nilai.

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

> [!note] Draf penyesuaian **tersimpan otomatis di perangkat ini**, terpisah untuk tiap lokasi, setiap kali Anda menambah barang atau mengisi stok fisik, alasan, atau catatan. Keterangan kecil *Draf tersimpan di perangkat ini.* di atas tombol menandainya. Hitungan stok opname yang panjang bisa ditinggal: pindah menu, ganti kasir, mengganti **lokasi** di bagian atas layar, bahkan menutup aplikasi tidak menghapus draf, dan draf muncul lagi saat layar Stok dibuka atau lokasinya dipilih kembali. Stok sistem dan selisihnya dihitung ulang dari stok terbaru; barang yang sudah dihapus dibuang dari draf. **Simpan penyesuaian** yang berhasil dan **Batal** menghapus draf lokasi itu. Draf milik perangkat, bukan staf: staf lain dengan izin *Penyesuaian stok* di perangkat yang sama melanjutkan draf yang sama, dan draf belum ikut ke perangkat lain.

> [!warning] Bila stok sistem sebuah barang berubah setelah stok fisiknya Anda isi (mis. ada penjualan saat draf ditinggal), baris itu menampilkan *Stok sistem berubah dari … jadi … sejak dihitung.* dan di atas tombol muncul jumlah barang yang berubah. Selisih selalu memakai stok sistem terbaru, jadi barang yang terjual setelah dihitung mungkin sudah tidak ada di rak. Hitung ulang barang itu lalu ketik jumlah barunya, atau tekan **Sudah dicek** bila jumlah fisiknya memang masih benar. Peringatan ini tidak menghalangi **Simpan penyesuaian**.

> [!warning] Bila draf gagal disimpan di perangkat (mis. penyimpanan penuh), keterangannya berubah merah menjadi *Draf belum tersimpan di perangkat.* Selama itu, pindah menu, menekan tombol kembali, atau mengganti lokasi menampilkan **Buang perubahan?**: pilih **Batal** untuk melanjutkan hitungan, **Buang** untuk keluar (draf lama yang sempat tersimpan ikut dibuang), atau **Simpan** untuk menyimpan penyesuaian lalu langsung pindah. **Simpan** hanya muncul bila minimal satu baris sudah diisi stok fisiknya (baris tanpa stok fisik tidak ikut tersimpan). Bila simpan ditolak, misalnya tidak ada selisih, Anda tetap di tab *Penyesuaian* dengan pesannya. Saat mengganti lokasi, **Simpan** menyimpan penyesuaian di lokasi lama lalu pindah ke lokasi baru.

## Stok minimum

Isi **Stok min** per varian di form produk. Tab **Stok minimum** dan Beranda menampilkan produk yang stoknya di bawah minimum, supaya Anda tahu kapan harus [membeli](purchases).

Tekan **Buat pembelian** di bawah daftar itu untuk membuka *Pembelian baru* yang sudah berisi semua barang di bawah minimum, dengan lokasi terima = lokasi yang sedang dilihat. Jumlah sarannya **2 × stok minimum − stok sekarang**, dibulatkan ke atas (mis. stok 2, minimum 20 → beli 38). Harga tiap baris diisi dari harga beli pada pembelian terakhir barang itu (dihitung per satuan dasar, mis. Rp 185.000 per dus isi 6 menjadi Rp 30.833); barang yang belum pernah dibeli memakai harga modal. Baris yang langsung terisi dalam **Satuan beli bawaan** (mis. dus) memakai harga pembelian terakhir dalam satuan itu, atau harga modal dus bila barang belum pernah dibeli per dus. Catatan di atas form menyebut berapa barang yang harganya diambil dari pembelian terakhir. **Supplier** langsung terisi dengan supplier pembelian terakhir untuk sebagian besar barang itu (catatan di atas form menyebut namanya dan berapa barang). Barang yang sudah diretur seluruhnya ke supplier lewat **Retur pembelian** tidak dihitung, jadi supplier sebelumnya yang dipakai; retur sebagian tetap dihitung; ganti bila perlu, sesuaikan jumlah dan harga, lalu simpan draf atau terima barang seperti biasa. Tombol ini hanya tampil untuk staf dengan izin *Kelola pembelian*.

Jumlah saran dihitung dalam satuan dasar, lalu diisi dalam **Satuan beli bawaan** barang itu bila sudah dipilih di form produk (mis. saran 38 botol langsung menjadi 7 dus isi 6). Bila belum, ganti **Satuan** baris itu ke dus dan jumlahnya ikut dikonversi, dibulatkan ke atas ke dus utuh (mis. saran 38 botol → 7 dus isi 6); kembali ke botol mengembalikan 38. Setelah Anda mengetik jumlah sendiri atau menambah barang itu lewat scan, jumlahnya tidak lagi dikonversi saat satuan diganti.

Draf tidak menambah stok, jadi barang yang sudah masuk draf tetap tampil di bawah minimum. Bila sudah ada **draf pembelian** ke lokasi yang sama yang memuat sebagian barang itu, **Buat pembelian** lebih dulu menampilkan *Sudah ada draf pembelian* dengan nomor draf dan berapa barang yang sudah ada di dalamnya. Pilih **Buka draf** untuk melanjutkan draf itu: barang di bawah minimum yang belum ada di draf mana pun langsung ditambahkan dengan jumlah saran dan harga beli terakhir, sedangkan baris draf yang sudah ada tidak diubah (catatan di atas form menyebut berapa yang ditambahkan; tekan **Simpan draf** agar tambahan tersimpan), **Buat draf baru** bila memang perlu pembelian terpisah, atau **Batal**. Bila ada beberapa draf, yang paling banyak memuat barang yang sama dibuka; draf lain bisa dilihat di menu *Pembelian*.

Supaya tidak perlu menebak, barang di daftar *Di bawah stok minimum* yang sudah ada di draf pembelian ke lokasi ini diberi keterangan biru **Sudah di draf** beserta nomor drafnya dan jumlah yang sudah dipesan dibandingkan saran, mis. *Sudah di draf PB-…: 5 dari saran 38 pcs*. Jumlah dihitung dalam satuan dasar dari semua draf ke lokasi ini (2 dus isi 6 = 12), dan saran sama dengan jumlah yang diisi **Buat pembelian**. Di bawahnya tertulis **Cukup untuk saran** (hijau, bertanda centang) bila pesanan di draf sudah mencapai saran, atau **Kurang … dari saran** dengan selisihnya (mis. *Kurang 33 pcs dari saran*) bila masih perlu ditambah, sehingga barang yang perlu diurus langsung terlihat. Barang tanpa keterangan itu belum dipesan. Keterangan ini hanya tampil untuk staf dengan izin *Kelola pembelian*.

## Lokasi stok

Tab **Lokasi stok** untuk menambah etalase, gudang, atau rak terpisah di cabang ini.

> [!note] Selisih penyesuaian masuk ke baris *Penyesuaian stok* di [laporan laba rugi](reports).
