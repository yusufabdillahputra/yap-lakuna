# Audit fitur terhadap desain UI Lakuna

Tanggal: 2026-11-03. Permintaan Yusuf: "cek dan audit kembali serta
detailkan kembali Design UI dengan fitur-fitur yang dirancang, agar thread
agent tidak salah."

Kanvas: <https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525> (halaman fondasi
"Peta fitur hasil audit" berisi tabel yang sama dengan dokumen ini).
Spec induk: `2026-11-03-ui-desain-lakuna-forui-design.md`.

## Sumber yang diaudit

- 35 spec modul Storeku (`docs/superpowers/specs/` di repo storeku, cabang
  spec terakhir) beserta tabel **Status & gap** masing-masing.
- `docs/superpowers/STATUS-DITUNDA.md` Storeku (daftar pekerjaan yang
  tertunda saat Storeku dihentikan).
- Kunci izin di kode Storeku (sumber kebenaran, bukan matriks desain lama).

Setiap fitur dicek: apakah ada layar yang menggambarkan alurnya, apakah data
contoh konsisten, dan apakah aturan bisnis (ledger, nomor dokumen, izin)
terlihat di layar.

## Fitur Fase 1 → layar → detail wajib

| Fitur | Layar | Detail yang wajib ada di aplikasi | Izin |
| --- | --- | --- | --- |
| Login & PIN | 1.2, 1.2b | Ganti kasir dengan PIN; persetujuan PIN manajer untuk void, retur, diskon manual; salah PIN berulang → dikunci sementara | `sales:void`, `sales:discount` |
| Sesi kasir & kas laci | 1.3, 1.3b | Buka sesi + shift (opsional) + saldo awal; uang masuk/keluar; "catat juga sebagai pengeluaran"; tutup sesi dengan selisih | `cash_session:open`, `cash_session:close`, `cash_movements:create` |
| Kasir retail | 1.4, 1.4b, 1.11, 1.11b | Satuan konversi (renceng, dus), harga grosir otomatis, pilih pelanggan, diskon manual, nota tersimpan (status open) | `sales:create`, `sales:discount` |
| Pembayaran | 1.5, 1.5b, 1.5c | Tunai, kartu (no. approval opsional), transfer, QRIS statis, split; kredit = tombol khusus dengan limit, DP & jatuh tempo; layar berhasil + kembalian | `sales:create`, `debts:manage` |
| QRIS statis | 1.6, 1.6m, 1.26b | Gambar stiker utuh vertikal dari pemilik (bukan QR saja); kasir tekan Sudah Terbayar setelah cek mutasi | `payments:confirm`, `settings:manage` |
| Meja & open bill F&B | 1.7, 1.7b–1.7e | Mode grid atau denah (`vyuh_node_flow`); status item Baru / Di dapur / Disajikan; tiket dapur hanya item baru, tanpa harga; nomor take away harian | `open_bills:manage` |
| Modifier | 1.8, 1.16b, 1.17b | Grup wajib/opsional, min/maks, tambahan harga (boleh negatif), opsi habis; snapshot nama & harga di baris nota | `products:manage` |
| Split bill | 1.9 | Per item atau rata; tiap bagian dibayar dengan metode sendiri | `sales:create` |
| Struk & printer | 1.5c, 1.12 | Printer Bluetooth 58 mm, cetak otomatis, bagikan PDF | `sales:create` |
| Backup data | 1.13 | Backup/restore manual ke berkas; data per perangkat | `backup:manage` |
| Riwayat, void, retur | 1.14 | Void penuh butuh izin; retur sebagian mengembalikan stok lewat ledger | `sales:void`, `sales:return` |
| Produk & stok | 1.15, 1.15m, 1.16, 1.18 | Varian, satuan konversi, grosir; stok sebagai ledger; penyesuaian dengan alasan; kartu stok | `products:manage`, `stock:adjust` |
| Master data | 1.17, 1.17b | Kategori, satuan, lokasi, alasan, jenis pengeluaran, grup pelanggan, meja & area, grup modifier, shift | `products:manage`, `settings:manage` |
| Pembelian | 1.19, 1.19b | Terima barang → stok + HPP rata-rata; saran harga jual; DP & hutang; retur beli | `purchases:manage` |
| Pelanggan & piutang | 1.20, 1.20b | Limit kredit, alokasi pembayaran ke nota terlama, kuitansi A5/PDF dan 58 mm | `customers:manage`, `debts:manage` |
| Supplier & hutang | 1.21 | Hutang per pembelian, jatuh tempo, bayar dari kas toko / laci / bank | `suppliers:manage` |
| Pengeluaran | 1.22 | Jenis pengeluaran, foto nota; dari kas laci ikut rekap sesi | `expenses:manage` |
| Laporan & laba rugi | 1.23, 1.24 | Penjualan, produk terlaris, kas; laba rugi memakai HPP; angka laba disembunyikan tanpa izin | `reports:view`, `reports:view_profit` |
| Pengguna & role | 1.25 | Role owner, manager, cashier, waiter, stock_keeper; matriks memakai kunci izin dari kode | `users:manage` |
| Pengaturan | 1.26, 1.26b | Metode bayar, struk, pajak & service, stok minus, PIN diskon, pembulatan, tema, bahasa | `settings:manage` |
| Panduan | 1.27 | Panduan per fitur ID + EN, tangkapan layar WebP | — |

Role bawaan: owner = semua izin; manager = semua kecuali `users:manage`,
`backup:manage`, `sync:manage`; cashier = `sales:create`, `sales:return`,
`payments:confirm`, `open_bills:manage`, `cash_session:open/close`,
`cash_movements:create`, `debts:manage`; waiter = `open_bills:manage`;
stock_keeper = `purchases:manage`, `stock:adjust`, `suppliers:manage`.

## Layar yang ditambahkan atau dirombak

| Layar | Alasan |
| --- | --- |
| 1.2b Persetujuan PIN manajer | Spec void & diskon manual butuh persetujuan; belum ada layarnya |
| 1.3b Kas laci | Uang masuk/keluar dan rekap sesi belum tergambar; opsi "catat juga sebagai pengeluaran" |
| 1.4b Pelanggan, diskon, nota tersimpan | Kasir harus bisa memilih pelanggan (grosir/kredit), menyimpan nota, memberi diskon manual |
| 1.5b Kredit / piutang | Kredit bukan metode bayar biasa: wajib pelanggan, cek limit, DP, jatuh tempo |
| 1.5c Pembayaran berhasil | Kembalian besar, peringatan stok minus, cetak & bagikan |
| 1.6 / 1.6m QRIS statis | Gambar QRIS = stiker vertikal utuh (permintaan Yusuf) |
| 1.7d Atur denah | Diselaraskan dengan `vyuh_node_flow`: tanpa rotasi bebas, Orientasi 0°/90°, snap grid 20 px, minimap |
| 1.7e Tiket dapur & take away | Status item F&B, tiket dapur, nomor take away |
| 1.11b Keranjang mobile | Pola sheet bawah untuk layar < 600 px |
| 1.15m Produk mobile | Tabel tidak muat di mobile: daftar kartu + navigasi bawah |
| 1.16b, 1.17b Modifier | Master grup modifier dan penempelannya ke menu belum tergambar |
| 1.19b Detail pembelian | HPP rata-rata, saran harga jual, pembayaran hutang |
| 1.20b Kuitansi | Bukti bayar piutang (A5/PDF dan 58 mm) |
| 1.26b Pengaturan QRIS | Unggah stiker QRIS utuh, cek rasio & QR, data merchant |

Halaman fondasi baru: **Pola keadaan & responsif** (kosong, memuat, error,
offline, tanpa izin, toast, konfirmasi, satu layar di tiga lebar) dan
**Peta fitur hasil audit**.

## Aturan lintas layar yang diseragamkan

- Nomor dokumen memuat kode outlet **dan** perangkat: nota
  `PST-T01-261103-0047`; dokumen back office memakai perangkat PC kantor
  `D01`: pembelian `PB-PST-D01-…`, retur beli `RB-…`, penyesuaian `SA-…`,
  bayar hutang `BH-…`, bayar piutang `BP-…`. (Kanvas Storeku lama memakai
  `PB-PST-261102-…` tanpa kode perangkat; sudah dibetulkan.)
- Stok dan saldo selalu ledger; tidak ada layar yang mengubah angka stok
  langsung.
- Uang rupiah bulat; jumlah barang mendukung pecahan (timbang 0,5 kg).
- Hapus = arsip (soft delete); dokumen yang sudah dibayar hanya bisa di-void
  atau diretur.
- Data contoh konsisten antar layar: Toko Bu Ani (limit Rp 2.000.000,
  piutang Rp 1.150.000), nota PST-T01-261102-0047 Rp 214.000, Meja M4
  Rp 158.000, Kopi Susu Aren Rp 24.000.

## Keputusan yang diserahkan ke thread pengembang

- Skema penyimpanan tata letak denah (`layout_json` per area atau kolom
  posisi per meja).
- Paket dekoder QR offline untuk pemeriksaan gambar QRIS (opsional; boleh
  dilewati di versi pertama asal peringatan tampil).
- Tombol `destructive` di mode gelap: **sudah diputuskan** (2026-11-03) isi
  `#C10007` + teks `#FAFAFA` (6.2:1), lihat "Aturan kontras dan mode gelap"
  di spec desain.

## Status & gap

| Hal | Status |
| --- | --- |
| Audit spec Storeku → kanvas Lakuna | selesai 2026-11-03 |
| 14 layar detail + 2 halaman fondasi | terbit di kanvas 2026-11-03 |
| Implementasi Flutter | thread "Bangun aplikasi Lakuna dengan Flutter" |
