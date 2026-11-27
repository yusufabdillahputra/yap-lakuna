# Menerima QRIS statis

Versi gratis memakai gambar QRIS statis milik toko. Aplikasi tidak menerima bukti bayar otomatis, jadi kasir yang mengonfirmasi setelah dana masuk.

![Stiker QRIS toko tampil utuh, menunggu konfirmasi kasir.](pay-qris)

## Sebelum mulai

Pemilik mengunggah gambar stiker QRIS di **Pengaturan › Metode pembayaran**, mengisi data merchant, lalu menyalakan **QRIS statis aktif di kasir**. Satu gambar per cabang. Unggah stiker utuh (bukan potongan kode QR) dalam format PNG, JPG, atau WebP, maksimal 5 MB. Di HP atau tablet Android/iOS, tombol **Foto stiker** membuka kamera: potret seluruh stiker lurus dari depan, termasuk header QRIS, nama toko, NMID, dan tulisan di bawah QR. Bila kamera tidak bisa dibuka, periksa izin kamera di pengaturan perangkat atau pakai **Pilih file**.

Setelah gambar dipilih, Lakuna membaca kode QR-nya tanpa internet. Bila terbaca sebagai QRIS statis, *Hasil pemeriksaan* menampilkan **QR terbaca** beserta NMID dan nama merchant, lalu *Nama merchant*, *NMID*, dan *Kode terminal* yang masih kosong terisi otomatis (isian yang sudah diketik tidak ditimpa). Bila QR tidak terbaca, bukan QRIS, atau QRIS dinamis, muncul peringatan; gambar tetap boleh disimpan, tetapi sebaiknya ganti dengan stiker QRIS statis yang tajam.

## Langkah

1. Di layar Bayar, pilih **QRIS statis**. Gambar QRIS dan total tampil di layar. Tekan **Perbesar gambar QRIS** agar pelanggan lebih mudah memindai.
2. Minta pelanggan scan dan mengetik nominal yang sama persis.
3. Cek notifikasi dana masuk di HP toko atau mutasi rekening.
4. Tekan **Sudah Terbayar**. Nama kasir dan jam konfirmasi tercatat.

> [!warning] Jangan tekan Sudah Terbayar hanya dari tangkapan layar pelanggan. Pastikan dana benar-benar masuk.

Bila dana belum masuk, tekan **Belum masuk** dan pilih metode lain atau tunggu sebentar.

## PIN manajer untuk Sudah Terbayar

Staf dengan izin *Konfirmasi bayar manual* menekan **Sudah Terbayar** langsung. Staf tanpa izin itu tetap bisa menerima QRIS: setelah **Sudah Terbayar** ditekan, muncul dialog **Persetujuan manajer**, lalu manajer memeriksa mutasi dan memasukkan PIN-nya. Yang tercatat sebagai pengonfirmasi adalah manajer itu.

Pemilik bisa mewajibkan PIN untuk semua kasir dengan mematikan **Kasir boleh konfirmasi tanpa PIN manajer** di **Pengaturan › Metode pembayaran**. Setelah itu hanya staf yang juga punya izin *Kelola pengaturan* (pemilik dan manajer) yang menekan Sudah Terbayar langsung, dan hanya mereka yang bisa menyetujui. Satu PIN berlaku untuk semua bagian QRIS di satu pembayaran; bila bagian QRIS baru ditambahkan atau metode bayar diganti, PIN diminta lagi. Bagian split bill yang menunggu di layar Meja meminta PIN per bagian.

## QRIS di kasir ponsel

Di kasir berukuran ponsel, gambar stiker tampil di bawah total; ketuk gambar untuk layar penuh. Bila toko sudah memasang stiker QRIS cetak di meja kasir, pemilik bisa mematikan **Tampilkan juga di layar mobile kasir** di **Pengaturan › Metode pembayaran**. Setelah itu kasir di ponsel tidak menampilkan gambar QRIS, hanya total dan petunjuk *Minta pelanggan memindai stiker QRIS yang terpasang di toko.* Langkah konfirmasi tetap sama. Kasir di tablet dan desktop selalu menampilkan gambar.
