# Dashboard semua cabang

**Dashboard semua cabang** merangkum penjualan hari ini dari setiap cabang, status perangkat kasir, dan hal yang perlu ditindaklanjuti dalam satu layar. Menu ini muncul setelah [versi hosting](hosting) aktif, juga di versi web, untuk staf dengan izin *Lihat laporan* (bawaan: pemilik dan manajer).

![Dashboard semua cabang.](dashboard)

## Yang ditampilkan

- **Penjualan hari ini**: total penjualan semua cabang, jumlah transaksi, dan jumlah cabang. "Hari ini" mengikuti tanggal di zona waktu masing-masing cabang, dan angkanya dihitung dengan aturan yang sama dengan [Laporan](reports) (nota batal dan retur dikurangkan).
- **Rata-rata per nota**: penjualan dibagi jumlah transaksi, dibulatkan ke bawah.
- **Perangkat online**: perangkat kasir yang tersambung ke server dalam 10 menit terakhir, mis. *2 / 3*. Bila ada perangkat yang belum sync lebih dari 1 jam, catatannya menyebut kapan terakhir sync. Perangkat web tidak dihitung.
- **Konflik sync**: perubahan yang menunggu ditinjau di server.
- **Per cabang hari ini**: penjualan, transaksi, sync terakhir, dan status perangkat tiap cabang (*Online*, *1 perangkat offline*, atau *Tanpa perangkat*), dengan baris **Total**. Di HP tabel berubah menjadi kartu.
- **Penjualan per jam**: grafik batang per jam hari ini. Sumbu jam selalu memuat 08–17 dan melebar bila ada penjualan di luar jam itu.
- **Terlaris minggu ini**: 5 produk dengan jumlah terjual terbanyak dalam 7 hari terakhir (termasuk hari ini); varian digabung ke produknya.
- **Perlu perhatian**: konflik yang menunggu tinjauan, perangkat yang belum sync lebih dari 1 jam, dan jumlah produk di bawah stok minimum per cabang. Bila tidak ada, kartu berganti menjadi **Semua beres**.

## Langkah

1. Buka **Dashboard semua cabang** di menu.
2. Pilih **Semua cabang** atau satu cabang di pilihan cabang. Kartu, tabel, grafik, dan daftar terlaris mengikuti pilihan itu.
3. Tekan baris *produk di bawah stok minimum* cabang ini untuk membuka [Stok minimum](stock), atau baris konflik untuk membuka kartu **Versi hosting** (perlu izin *Sync & hosting*).
4. Tekan **Unduh laporan** untuk menyimpan ringkasan dashboard ke Excel (`dashboard-semua-cabang-261128.xlsx` atau `dashboard-PST-261128.xlsx`).

> [!note] Angka penjualan dihitung dari data yang sudah tersinkron ke perangkat ini. Penjualan di perangkat kasir yang sedang offline baru masuk setelah perangkat itu tersambung lagi.

## Bila status perangkat tidak tampil

Status perangkat dan konflik diambil dari server saat dashboard dibuka dan setiap 60 detik. Bila perangkat ini sedang offline, kartunya menampilkan *Status perangkat butuh internet*; angka penjualan tetap tampil dari data terakhir.
