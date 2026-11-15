# Meja & open bill

Usaha *F&B* dan *Campuran* memakai layar **Meja** untuk mencatat pesanan per meja (dine in) atau take away, lalu membayarnya saat tamu selesai.

![Denah meja dan open bill Meja M2.](tables)

## Sebelum mulai

- Buat area dan meja di **Master data › Meja & area**. Pakai **Tambah beberapa** untuk membuat M1–M12 sekaligus. Bila dialog area, meja, atau rentang sudah diubah lalu Anda menekan **Batal**, Esc, mengetuk di luar dialog, atau tombol kembali ponsel, Lakuna bertanya **Buang perubahan?** lebih dulu. Pilih **Batal** untuk kembali ke dialog, atau **Buang** untuk menutup tanpa menyimpan. Bila nama sudah dipakai (mis. rentang M1–M12 padahal M7 sudah ada), dialog tetap terbuka dan pesannya tampil tepat di bawah kolom **Nama** (untuk rentang: menggantikan pratinjau nama); ubah isiannya lalu simpan lagi.
- Atur service charge dan PB1 di **Pengaturan › Pajak & service**. Service hanya untuk dine in.

## Membuka bill

1. Buka menu **Meja**. Warna meja menunjukkan status: *Kosong*, *Terisi · open bill*, atau *Minta bill*.
2. Ketuk meja kosong, isi **Jumlah tamu**, lalu **Buka bill**. Untuk take away, tekan **Take away baru** dan isi nama pemesan bila perlu.
3. Tekan **+ Menu**, cari menu, lalu ketuk untuk menambah. Menu dengan [modifier](modifiers) membuka lembar pilihan dulu.
4. Tekan **Kirim ke dapur**. Tiket dapur berisi item baru saja dan bisa dicetak dengan **Cetak tiket**. Bila *Printer dapur* diatur di **Pengaturan › Struk & printer**, tiket langsung tercetak di sana; bila gagal, tekan **Cetak ulang**. Menu yang *Kirim ke tiket dapur*-nya dimatikan tidak masuk tiket dan langsung *Disajikan* (lihat [Modifier menu](modifiers)).
5. Tandai item dengan **Tandai disajikan** saat makanan diantar.

## Pelanggan di bill

- Tekan **Pilih pelanggan** di bawah judul bill, cari nama atau nomor HP, lalu ketuk pelanggannya. Bila pelanggan masuk grup dengan [harga grosir](first-product), semua item di bill langsung memakai harga grupnya, termasuk item yang sudah dikirim ke dapur.
- **Ganti** memilih pelanggan lain; tombol **×** melepas pelanggan dan mengembalikan harga normal.
- Bila grup pelanggan diubah di menu **Pelanggan** saat bill-nya masih terbuka, panel bill menampilkan *Grup pelanggan berubah. Harga bill masih memakai grup lama.* Tekan **Segarkan harga** agar semua item dihitung ulang dengan grup baru dan harga menu terkini. Selama belum disegarkan, item yang baru ditambah sudah memakai grup baru.
- Saat **Tutup & bayar** dengan *Kredit / piutang*, pelanggan bill otomatis terpilih. Kredit untuk pelanggan lain ditolak; ganti dulu pelanggan bill.
- Pelanggan tidak bisa diubah setelah bill di-split atau ada bayar bagian. Dua bill dengan pelanggan berbeda tidak bisa digabung.

## Menutup bill

1. Saat tamu meminta tagihan, tekan **Minta bill** (meja berubah warna).
2. Tekan **Tutup & bayar**. Layar Bayar terbuka dengan total termasuk service dan PB1.
3. Selesaikan seperti [pembayaran tunai](pay-cash) atau [QRIS statis](pay-qris). Untuk tamu yang membayar sendiri-sendiri, pakai [Split bill](split-bill).

## Cetak tagihan

Tamu bisa memeriksa tagihan sebelum membayar.

1. Di panel bill, tekan **Cetak tagihan**. Pratinjau tagihan tampil: pesanan, Subtotal, diskon, service, PB1, pembulatan, dan TOTAL, berbanner *TAGIHAN - BELUM DIBAYAR*.
2. Tekan **Cetak tagihan** di dialog untuk mencetak ke printer struk, atau **Bagikan PDF** untuk mengirimnya lewat WhatsApp.
3. Bila sebagian tamu sudah membayar lewat split bill, tagihan memuat *Sudah dibayar* dan *Sisa tagihan*. Rekening transfer toko ikut tercetak bila diisi di [Pengaturan toko](store-settings).

> [!note] Mencetak tagihan tidak menutup bill, tidak mengubah status *Minta bill*, dan tidak membuat nomor nota baru. Tamu masih bisa menambah pesanan; cetak ulang tagihannya setelah itu.

## Pindah dan batal

- **Pindah meja** memindahkan seluruh bill ke meja kosong.
- **Batalkan bill** menutup bill tanpa pembayaran; alasan wajib diisi dan butuh izin *Void nota* (atau PIN manajer).

> [!note] Item yang sudah dikirim ke dapur tidak bisa diubah atau dihapus.
