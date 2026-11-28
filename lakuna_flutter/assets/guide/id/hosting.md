# Versi hosting

Versi hosting menyinkronkan data semua cabang dan perangkat ke server toko Anda sendiri. Aplikasi tetap bekerja offline: penjualan disimpan dulu di perangkat, lalu dikirim ke server begitu ada jaringan. Fitur ini butuh izin *Sync & hosting* (bawaan: pemilik).

![Pengaturan Versi hosting.](hosting)

## Yang perlu disiapkan

- **Alamat server**, misalnya `https://sync.tokoanda.id`. Pilih *Server Lakuna* bila tersedia di aplikasi Anda, atau *Server sendiri* untuk server di VPS toko.
- **Kode aktivasi** dari pengelola server (8 huruf/angka, berlaku sekali).
- **Akun pemilik** di server: email dan kata sandi. Belum punya? Buat di langkah 2 dengan kode verifikasi yang dikirim ke email.

## Mengaktifkan di perangkat pertama

1. Buka **Pengaturan › Versi hosting**, tekan **Aktifkan versi hosting**.
2. **Server & kode**: pilih server, isi kode aktivasi, tekan **Periksa**, lalu **Lanjut**. Bila server lebih lama dari aplikasi, tampil *Server perlu diperbarui*; minta pengelola server memperbaruinya dulu.
3. **Akun pemilik**: masuk, atau pilih **Daftar akun baru**, tekan **Kirim kode**, isi kode dari email lalu kata sandi dua kali (minimal 8 karakter).
4. **Unggah data**: tekan **Aktifkan dan unggah data**. Data toko, produk, stok, dan riwayat penjualan diunggah bertahap; kemajuan tiap kelompok tampil. Unggahan bisa dijeda (**Jeda unggahan**) dan dilanjutkan, dan tetap berjalan bila aplikasi ditutup lalu dibuka lagi.
5. **Selesai**: tekan **Selesai**. Kartu menampilkan *Aktif · server …*.

> [!note] Data tetap ada di perangkat. Server hanya salinan bersama; bila jaringan putus, kasir tetap bisa berjualan.

## Status sync di atas layar

Chip di kanan atas menunjukkan keadaan sync:

- **Tersinkron · 14.32**: semua perubahan sudah terkirim.
- **Menyinkronkan… (35)**: ada perubahan yang sedang dikirim.
- **Menunggu jaringan (35)**: perangkat offline; perubahan dikirim otomatis saat online.
- **Sync dijeda**: sync dimatikan sementara dari kartu Versi hosting.
- **Perlu perhatian**: ada masalah, misalnya jam perangkat tidak sesuai atau server menolak token. Pemilik bisa menekan chip untuk membuka kartu Versi hosting dan melihat penjelasannya.

Di HP, chip hanya berupa ikon dengan titik warna; tekan lama untuk melihat teksnya.

## Kartu Versi hosting

Setelah aktif, kartu menampilkan server, waktu sync terakhir, dan jumlah perubahan yang menunggu. Tombolnya:

- **Sync sekarang**: kirim dan tarik perubahan saat itu juga.
- **Jeda sync** / **Lanjutkan sync**: hentikan sementara, mis. saat kuota internet terbatas.
- **Buat kode pasang perangkat**: buat kode untuk menambah perangkat (lihat di bawah).

## Menambah perangkat atau cabang

1. Di perangkat yang sudah aktif, tekan **Buat kode pasang perangkat**. Tampil kode 8 huruf/angka dan kode lengkap seperti `https://sync.tokoanda.id#ABCD2345`. Kode berlaku 15 menit dan hanya sekali pakai. Tekan **Salin kode lengkap** lalu kirim ke perangkat baru, mis. lewat WhatsApp.
2. Di perangkat baru, pada layar awal pilih **Gabung ke toko yang sudah memakai hosting**. Di perangkat yang sudah punya data, buka **Pengaturan › Versi hosting** lalu tombol yang sama.
3. Tempel kode lengkap di isian alamat: alamat dan kode terisi sendiri. Tekan **Periksa kode**.
4. Pilih cabang, isi **Kode perangkat** (1–6 huruf/angka, mis. `K02`, dipakai di nomor nota) dan nama perangkat, lalu tekan **Gabung**.
5. Data toko ditarik dari server, lalu aplikasi dimuat ulang. Masuk dengan PIN staf seperti biasa.

> [!warning] Gabung mengganti data di perangkat ini dengan data toko dari server. Bila perangkat sudah berisi penjualan, aplikasi memperingatkan dan membuat backup otomatis di folder data (*backup-sebelum-gabung*) sebelum mengganti. Data lama juga disimpan di folder *sebelum-gabung-…*.

## Foto dan gambar

Semua gambar toko ikut tersinkron: foto produk, foto faktur pembelian, foto bukti pengeluaran, bukti bayar hutang supplier, stiker QRIS, logo struk, dan gambar denah. Setelah datanya terkirim (juga bila ada data lain yang perlu perhatian), berkas gambar diunggah ke penyimpanan server satu per satu; gambar yang sama persis tidak diunggah dua kali. Perangkat lain mengunduh gambar saat pertama kali dibutuhkan, misalnya saat produk atau pembelian itu dibuka, lalu menyimpannya di perangkat.

Selama gambar belum terunduh (perangkat offline, atau perangkat asal belum mengunggahnya), tampil gambar pengganti. Gambar yang terunduh dalam beberapa detik langsung tampil; bila lebih lama, gambar asli tampil saat layar itu dibuka lagi. Gambar yang gagal diunduh dicoba lagi setelah sekitar 2 menit. Unduhan diperiksa keasliannya; berkas yang rusak di jalan dibuang dan dicoba lagi nanti. Unggahan atau unduhan yang macet lebih dari 2 menit dihentikan dan diulang di siklus sync berikutnya.

## Bila ada masalah

- **Jam perangkat tidak sesuai**: atur tanggal dan jam otomatis di perangkat, lalu tekan **Sync sekarang**.
- **Server menolak token perangkat**: perangkat dicabut atau toko dihapus di server. Hubungi pengelola server.
- **Server tidak bisa dihubungi**: periksa alamat dan jaringan. Perubahan tetap tersimpan dan dikirim nanti.
- **Memulihkan backup** mematikan versi hosting di perangkat itu; aktifkan atau gabung lagi bila perlu.
