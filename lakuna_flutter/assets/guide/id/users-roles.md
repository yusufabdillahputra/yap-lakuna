# Pengguna & role

Setiap staf punya nama, role, dan PIN sendiri. Role menentukan izin: tombol dan halaman yang tidak diizinkan otomatis disembunyikan.

![Matriks izin per role.](users)

## Menambah staf

1. Buka **Pengguna & role**, tab **Pengguna**, lalu tekan **Tambah**.
2. Isi **Nama** dan pilih **Role**: *Manajer*, *Kasir*, *Pelayan*, *Staf gudang*, atau role custom.
3. Isi **PIN (6 angka)** dan **Ulangi PIN**.
4. Biarkan **Aktif** menyala, lalu tekan **Simpan pengguna**.

## Reset dan buka kunci PIN

- **Reset PIN**: buka staf, isi **PIN baru** dan **Ulangi PIN baru**, lalu **Reset PIN**. Staf tidak perlu PIN lama.
- **Buka kunci**: staf yang salah PIN 5 kali terkunci 1 menit; tekan **Buka kunci** untuk membukanya sekarang.
- Staf yang keluar cukup dimatikan **Aktif**-nya agar tidak muncul di layar login.

## Mengatur izin role

1. Buka tab **Role & izin**. Matriks menampilkan izin per role, misalnya *Buat transaksi*, *Void nota*, *Diskon manual*, *Lihat laba rugi*.
2. Centang atau hapus centang izin, lalu **Simpan perubahan**.
3. Tekan **Role custom** untuk membuat role baru, misalnya *Barista*.

> [!note] Pemilik selalu punya semua izin. Pemilik mengganti PIN dan kata sandinya sendiri di **Akun saya**, dengan kolom ulangi untuk keduanya.

## Log masuk dan keluar

Tab **Log masuk** mencatat setiap kali staf masuk atau keluar di perangkat kasir. Tab ini hanya untuk pengguna dengan izin *Pengguna & role* (pemilik dan manajer).

- Log dikelompokkan per tanggal, dengan yang terbaru di atas. Tiap baris berisi jam, nama staf, kejadian, dan kode perangkat (mis. *K01*).
- Ada beberapa jenis kejadian:
  - *Masuk dengan PIN*;
  - *Masuk dengan kata sandi*;
  - *Masuk setelah penyiapan toko*;
  - *Keluar (Ganti kasir)*;
  - *Keluar otomatis*, bila akun staf dinonaktifkan atau dikeluarkan dari cabang saat sedang bertugas.
- Pilih nama di **Staf** untuk melihat log satu staf saja. Tekan **Muat lagi** untuk melihat log yang lebih lama.

> [!note] Aplikasi yang ditutup tanpa **Ganti kasir** tidak punya baris *Keluar*. Login berikutnya di perangkat itu menjadi batasnya. PIN yang salah tidak dicatat di log ini.
