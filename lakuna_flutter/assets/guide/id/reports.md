# Laporan & laba rugi

Menu **Laporan** merangkum penjualan, laba, stok, kas, piutang dan hutang, serta retur untuk cabang ini.

![Ringkasan laporan hari ini.](reports)

## Langkah

1. Buka **Laporan** dan pilih **Periode**: *Hari ini*, *7 hari terakhir*, *Bulan ini*, salah satu bulan sebelumnya, atau *Rentang tanggal…*.
   - *Rentang tanggal…* membuka jendela **Dari** / **Sampai** (paling panjang 366 hari, tidak melewati hari ini), mis. 1–15 November. Laba bersih dibandingkan dengan jumlah hari yang sama tepat sebelumnya, dan nama berkas unduhan memuat tanggalnya (`…-20261101-20261115-…`).
2. Pilih tab:
   - **Ringkasan**: penjualan, laba kotor, rata-rata per nota, piutang jatuh tempo, penjualan per metode bayar, dan produk terlaris.
   - **Penjualan**: per produk, per kasir, atau per kategori.
   - **Produk terlaris**.
   - **Laba rugi**: penjualan bersih, HPP, laba kotor, beban operasional, dan laba bersih, dibanding periode sebelumnya.
   - **Stok**, **Kas & sesi**, **Piutang & hutang**, **Retur**.
   - Di **Piutang & hutang**, tabel **Umur piutang** dan **Umur hutang** mengelompokkan sisa tiap nota menurut lamanya lewat jatuh tempo: *Belum jatuh tempo*, *Lewat 1–30 hari*, *31–60*, *61–90*, dan *> 90 hari*. Tagih atau bayar lebih dulu yang paling lama.
   - Di **Kas & sesi**, ketuk sesi yang sudah ditutup (ikon printer di ujung baris) untuk melihat rekapnya, lalu **Cetak rekap** ke printer struk atau **Bagikan PDF**. Rekap cetak ulang diberi baris *Dicetak ulang* dengan tanggal jamnya. Sesi yang masih buka belum bisa dicetak.
3. Tekan **Unduh PDF** atau **Unduh Excel** untuk menyimpan atau membagikan laporan.

## Cara hitung

- HPP memakai harga pokok rata-rata tertimbang saat barang dijual.
- Beban operasional diambil dari [Pengeluaran](expenses); selisih stok dari [penyesuaian](stock).
- PB1 yang dipungut bukan pendapatan dan tidak ikut dihitung.

> [!note] Laporan butuh izin *Lihat laporan*. Tab Laba rugi butuh izin *Lihat laba rugi*, jadi bisa disembunyikan dari manajer.
