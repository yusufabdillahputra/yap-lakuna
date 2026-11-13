# Pelanggan & piutang

Menu **Pelanggan** menyimpan data pelanggan, limit kredit, dan piutang per nota, lalu mencatat pembayaran piutang lengkap dengan kuitansi.

## Menambah pelanggan

1. Buka **Pelanggan**, lalu tekan **Pelanggan**.
2. Isi nama, no. HP, grup, **Limit kredit** (0 berarti tidak boleh belanja kredit), alamat, dan catatan.
3. Tekan **Simpan**.

Banyak pelanggan sekaligus? Tekan **Import Excel** dan pilih berkas .xlsx atau .csv dengan kolom Nama, HP, Alamat, Grup, Limit, Catatan.

## Grup pelanggan

Atur grup di **Master data › Grup pelanggan**. Tempo standar grup mengisi jatuh tempo otomatis saat [penjualan kredit](credit-sale). Pelanggan tanpa grup memakai tempo 14 hari.

## Menerima pembayaran piutang

1. Pilih pelanggan, lalu di *Terima pembayaran* isi **Jumlah diterima** atau tekan **Lunasi semua**.
2. Pilih **Metode**. Tunai masuk ke laci bila ada sesi kasir terbuka, selain itu dicatat sebagai kas toko.
3. Alokasi otomatis mendahulukan nota paling lama. Tekan **Atur alokasi manual** untuk mengisi per nota.
4. Tekan **Simpan & cetak kuitansi**. Kuitansi tersedia dalam format A5/PDF atau struk thermal.

## Membatalkan pembayaran piutang

Salah catat nominal, metode, atau pelanggan? Batalkan pembayarannya lalu catat ulang.

1. Di riwayat pembayaran pelanggan, tekan ikon **Batalkan pembayaran** di baris pembayaran itu.
2. Isi **Alasan batal**, lalu tekan **Ya, batalkan**.
3. Sisa piutang setiap nota kembali seperti sebelum pembayaran. Pembayaran tetap tampil dicoret dengan label *Batal* dan alasannya, dan kuitansinya bercap BATAL.

Pembayaran tunai yang masuk laci dikeluarkan lagi dari laci di sesi kasir yang sedang buka, jadi buka sesi kasir dulu. Pembayaran dari cabang lain hanya bisa dibatalkan di cabang itu.

> [!note] Kuitansi bisa dicetak ulang dari riwayat pembayaran pelanggan dengan tanda SALINAN. Pelanggan yang masih punya piutang tidak bisa dihapus.
