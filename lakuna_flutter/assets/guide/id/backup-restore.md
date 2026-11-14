# Backup & pulihkan

Di versi gratis semua data dan gambar hanya ada di perangkat ini. Backup rutin mencegah data hilang bila HP atau komputer rusak. Fitur ini butuh izin *Backup & pulihkan* (bawaan: pemilik).

![Pengaturan Data & backup.](backup)

## Membuat backup

1. Buka **Pengaturan › Data & backup**.
2. Tekan **Backup sekarang**.
3. Di komputer, file .zip tersimpan di folder *Dokumen › Lakuna › Backup*. Di HP, pilih tujuan dari menu bagikan, misalnya Google Drive atau WhatsApp ke diri sendiri.

File backup berisi database dan semua gambar. Simpan di tempat aman karena isinya data toko Anda.

> [!note] Beranda mengingatkan bila backup terakhir lebih dari 7 hari lalu atau belum pernah backup.

## Backup otomatis harian (komputer)

Di Windows, Linux, dan macOS, Lakuna membuat backup sendiri sekali sehari selama aplikasi terbuka, jadi data tetap aman walau Anda lupa menekan **Backup sekarang**.

- File disimpan di *Dokumen › Lakuna › Backup › Otomatis*. Tujuh backup terakhir disimpan, yang lebih lama dihapus. Backup manual di folder *Backup* tidak pernah dihapus.
- Pemeriksaan pertama dua menit setelah aplikasi dibuka, lalu setiap jam. Backup dibuat bila backup otomatis terakhir lebih dari 24 jam lalu, juga saat layar PIN terbuka.
- **Pengaturan › Data & backup** menampilkan sakelar **Backup otomatis harian** (bawaan menyala), lokasi folder, dan kapan backup otomatis terakhir. Bila gagal (mis. disk penuh), tampil peringatan dan aplikasi mencoba lagi tiap jam.
- Backup otomatis juga menghitung sebagai backup terakhir, jadi pengingat di Beranda tidak muncul selama backup otomatis berjalan.

> [!note] Backup otomatis tidak dikunci kata sandi. Bila folder Dokumen disinkronkan ke awan (mis. OneDrive atau iCloud Drive), salinannya ikut tersimpan di akun awan Anda. Matikan sakelar bila tidak diinginkan, lalu pakai **Backup sekarang** dengan kunci kata sandi.

Di HP dan tablet, backup otomatis belum tersedia; tetap pakai **Backup sekarang**.

## Mengunci backup dengan kata sandi

Bila backup disimpan di Google Drive, WhatsApp, atau flashdisk, kunci dengan kata sandi agar isinya tidak bisa dibaca orang lain.

1. Di **Pengaturan › Data & backup**, nyalakan **Kunci dengan kata sandi**.
2. Isi **Kata sandi backup** (minimal 8 karakter) dan **Ulangi kata sandi** dengan isi yang sama.
3. Tekan **Backup sekarang**. Pesan hasil menyebut *Backup terkunci kata sandi*.

> [!warning] Kata sandi tidak disimpan di aplikasi. Catat di tempat aman: tanpa kata sandi ini backup tidak bisa dipulihkan, termasuk oleh tim Lakuna.

Saat memulihkan backup terkunci, aplikasi meminta kata sandinya dulu sebelum menampilkan ringkasan. Bila salah, coba lagi tanpa memilih ulang file.

## Memulihkan dari backup

1. Buka **Pengaturan › Data & backup**, lalu tekan **Pulihkan** dan pilih file .zip (backup otomatis ada di folder *Backup › Otomatis*).
2. Bila backup terkunci, isi kata sandinya lalu tekan **Buka**.
3. Periksa ringkasan backup: toko, cabang, perangkat, tanggal, jumlah transaksi dan produk.
4. Ketik nama toko persis seperti yang diminta, lalu tekan **Pulihkan & muat ulang**.
5. Aplikasi memuat ulang dengan data dari backup.

> [!warning] Semua data di perangkat ini diganti isi backup. Data lama dipindah ke folder *sebelum-pulihkan* di lokasi data, sehingga masih bisa diselamatkan bila salah pilih.

Bila file backup rusak, aplikasi otomatis kembali ke data lama. Backup dari versi Lakuna yang lebih baru harus dipulihkan setelah aplikasi diperbarui.

## Pindah ke perangkat baru

Di perangkat baru Anda tidak perlu membuat toko dulu.

1. Pasang Lakuna dan buka. Wizard *Siapkan toko Anda* tampil.
2. Di langkah pertama (*Bahasa & tema*), tekan **Pulihkan dari backup** dan pilih file .zip dari perangkat lama.
3. Bila backup terkunci, isi kata sandinya dan tekan **Buka**. Periksa ringkasannya, ketik nama toko, lalu tekan **Pulihkan & muat ulang**.
4. Aplikasi memuat ulang ke layar masuk. Masuk dengan PIN staf seperti di perangkat lama.

Tombol ini hanya ada sebelum toko dibuat. Setelah toko ada, pulihkan lewat **Pengaturan › Data & backup**.

> [!warning] Perangkat baru melanjutkan kode perangkat dan nomor nota perangkat lama. Jangan memakai backup yang sama di dua perangkat sekaligus.
