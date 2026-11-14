# Sesi kasir & kas laci

Penjualan dicatat ke sesi kasir di perangkat ini supaya uang laci bisa direkap saat tutup. Kasir tidak bisa menjual sebelum sesi dibuka.

![Sesi kasir aktif dengan daftar gerakan kas.](cash-session)

## Membuka sesi

1. Buka menu **Sesi kasir**.
2. Hitung uang di laci, lalu isi **Saldo awal laci**. Catatan boleh dikosongkan.
3. Tekan **Buka sesi**.

## Uang masuk dan keluar laci

Tekan **Catat uang laci**, pilih **Uang masuk** atau **Uang keluar**, isi jumlah dan keterangan (mis. beli es batu), lalu **Simpan**. Nyalakan **Catat juga sebagai pengeluaran** bila uang keluar itu biaya toko, agar ikut [laporan laba rugi](reports).

Pengeluaran, bayar hutang, dan retur tunai dari modul lain tercatat otomatis di sesi yang sedang buka.

> [!note] Bila jumlah uang keluar (di sini, retur tunai, pengeluaran dari kas laci, bayar hutang supplier, atau pembelian yang dibayar dari laci) lebih besar dari *Perkiraan uang di laci*, form menampilkan peringatan. Simpan tetap bisa, karena isi laci nyata bisa berbeda dengan perkiraan; pastikan uangnya memang ada, dan selisihnya akan terlihat saat tutup sesi.

## Menutup sesi

1. Tekan **Tutup sesi**. Rekap menampilkan saldo awal, penjualan tunai, retur tunai, uang masuk dan keluar, serta jumlah yang seharusnya ada di laci.
2. Di *Hitung uang fisik*, isi jumlah lembar tiap pecahan dan receh.
3. Bila ada selisih, isi **Catatan selisih** (wajib).
4. Konfirmasi penutupan. Rekap tersimpan di perangkat ini.

> [!note] QRIS statis dan kartu tidak masuk laci. Keduanya ditampilkan terpisah di rekap untuk dicocokkan dengan mutasi rekening.

> [!warning] Split bill yang sebagian sudah dibayar harus dilunasi atau dibatalkan dulu sebelum sesi bisa ditutup.
