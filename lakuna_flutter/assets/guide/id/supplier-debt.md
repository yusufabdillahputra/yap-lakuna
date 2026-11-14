# Supplier & hutang

Menu **Supplier** menyimpan data pemasok dan hutang per pembelian, lalu mencatat pembayarannya.

## Menambah supplier

1. Buka **Supplier**, lalu tekan **Supplier**.
2. Isi nama supplier, kontak, telepon, kategori barang, dan **Tempo standar (hari)**. Tempo ini mengisi jatuh tempo bawaan di [Pembelian](purchases).
3. Tekan **Simpan**.

Banyak supplier sekaligus? Tekan **Import Excel** dan pilih berkas .xlsx atau .csv dengan kolom **Nama** (wajib), Kontak, Telepon, Kategori, Tempo (hari), Alamat, Catatan. Judul kolom boleh Indonesia atau English. **Unduh templat** di dialog yang sama memberi berkas Excel berisi judul kolom dan dua baris contoh; baris contoh otomatis dilewati saat import.

- Pratinjau menampilkan jumlah baris yang siap diimport dan baris yang dilewati beserta alasannya (nama kosong, telepon tidak sah, tempo di luar 0–365 hari, teks terlalu panjang, nama dobel di berkas).
- Nama yang sudah terdaftar (tanpa beda huruf besar/kecil) **memperbarui** supplier itu: hanya kolom yang terisi yang diganti, kolom kosong mempertahankan data lama.
- Supplier baru tanpa tempo memakai tempo standar 14 hari. Tempo boleh ditulis `30` atau `30 hari`.
- Semua baris disimpan bersama. Berkas yang sama bisa diimport ulang untuk memperbarui data tanpa membuat supplier ganda.

## Membayar hutang

1. Pilih supplier. Total hutang dan daftar pembelian yang belum lunas tampil, yang terlambat ditandai.
2. Isi **Jumlah dibayar**, atau tekan **Lunasi semua**.
3. Pilih **Sumber dana**: kas toko, kas laci (butuh sesi kasir terbuka dan tanggal hari ini), atau rekening bank.
4. Isi **No. bukti transfer** dan lampirkan foto bukti bila ada (foto
   sampai 20 MB dikecilkan otomatis ke 2.000 px).
5. Alokasi otomatis mendahulukan jatuh tempo terdekat. Tekan **Atur alokasi manual** untuk mengisi per pembelian.
6. Tekan **Simpan pembayaran**.

Pembayaran juga bisa dimulai dari detail pembelian dengan tombol **Bayar hutang**.

## Membatalkan pembayaran hutang

1. Di riwayat bayar supplier, tekan ikon **Batalkan pembayaran** di baris pembayaran itu.
2. Isi **Alasan batal**, lalu tekan **Ya, batalkan**.
3. Sisa hutang setiap pembelian kembali seperti sebelum pembayaran. Pembayaran tetap tampil dicoret dengan label *Batal* dan alasannya.

Pembayaran dari kas laci dikembalikan ke laci di sesi kasir yang sedang buka. Setelah dibatalkan, catat ulang pembayaran yang benar.

> [!note] Hutang yang jatuh tempo dan lewat tempo juga tampil di tab *Piutang & hutang* pada [Laporan](reports).
