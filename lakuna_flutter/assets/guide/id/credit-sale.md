# Penjualan kredit (piutang)

Pelanggan langganan bisa membawa barang dulu dan membayar kemudian. Sisa tagihan menjadi piutang pelanggan.

## Sebelum mulai

Pelanggan harus terdaftar dan punya **Limit kredit** lebih dari 0 di menu [Pelanggan](customers-credit). Tempo bayar mengikuti grup pelanggan (tanpa grup: 14 hari).

## Langkah

1. Di layar Bayar, pilih **Kredit / piutang**.
2. **Pilih pelanggan**. Piutang berjalan dan sisa limit tampil.
3. Isi **Bayar sekarang (DP)** bila pelanggan membayar sebagian tunai. Boleh 0.
4. Periksa **Jatuh tempo** (hari ini + tempo standar), ubah bila perlu.
5. Tekan **Simpan sebagai piutang**.

> [!warning] Bila piutang berjalan ditambah piutang baru melebihi limit, nota tidak bisa disimpan. Kurangi nominal atau naikkan DP.

Struk nota mencetak *Piutang* dan *Jatuh tempo*. Bila *Rekening transfer* diisi di [Pengaturan toko](store-settings), struk juga mencetak *Transfer ke:* diikuti rekening toko agar pelanggan tahu ke mana melunasi sisanya.

Di F&B, kredit juga tersedia saat **Tutup & bayar** bill meja atau take away, dan untuk bagian terakhir [split bill](split-bill). Pada split bill, limit dihitung dari tagihan bagian itu dikurangi DP, sedangkan bagian tamu lain tetap tercatat sebagai pembayaran di nota yang sama.

Nota tercatat *Belum lunas* di Riwayat dan masuk daftar piutang pelanggan. Pembayaran berikutnya dicatat di [Pelanggan & piutang](customers-credit).
