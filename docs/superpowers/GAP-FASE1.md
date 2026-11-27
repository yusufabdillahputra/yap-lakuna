# Inventaris gap Fase 1 (27 November 2026)

Pemilik meminta (27 November 2026): rapikan gap kecil Fase 1 sampai habis,
lalu mulai persiapan Fase 2. Dokumen ini memilah semua baris `Belum` di
tabel **Status & gap** spec (`specs/*.md`). Urutan kerja ada di bagian A.
Centang dan isi versi saat rilis; baris spec asal juga diperbarui.

## Sudah selesai di modul lain (dirapikan 27 November 2026)

Baris ini ditulis sebelum modul penggantinya dirilis. Tabel spec asal
sudah diperbarui: PIN manajer (F1-02 → F1-04b), ganti PIN (F1-02 →
F1-17), catat sebagai pengeluaran (F1-03 → F1-15), kredit dan pembulatan
(F1-05 → F1-13, F1-18), cetak ulang (F1-06 → F1-11), tab Modifier (F1-07 →
F1-10), master jenis pengeluaran / grup pelanggan / meja & area / grup
modifier (F1-09), retur bagian split (F1-10 → F1-11), status *Belum lunas*
(F1-11 → F1-13), laba rugi (F1-15 → F1-16), baris pembulatan laporan
(F1-16 → F1-18), data & backup (F1-18 → F1-19), tanya sebelum keluar form
pengeluaran/pelanggan/supplier (F1-07q → F1-15c, F1-13e).

## A. Dikerjakan (urutan)

| # | Gap | Spec asal | Rilis |
| --- | --- | --- | --- |
| 1 | Shift: master Shift (1.17b), pilih shift saat buka sesi (1.3), rekap dan laporan per shift | F1-03, F1-09 | v0.137.0 (F1-03g) |
| 2 | PIN manajer untuk *Sudah Terbayar* QRIS + sakelar *Kasir boleh konfirmasi tanpa PIN manajer* (1.26b) | F1-05, F1-18 | v0.138.0 (F1-05h) |
| 3 | *Tampilkan juga di layar mobile kasir* (1.26b) | F1-18 | v0.139.0 (F1-18e) |
| 4 | Foto stiker QRIS dari kamera (1.26b) | F1-18 | |
| 5 | Baca NMID dari gambar QRIS (1.26b *QR terbaca*) | F1-18 | |
| 6 | Kasir tetap terbuka bila pengaturan struk gagal dibaca; galat cetak non-printer tercatat | F1-06 | |
| 7 | Peringatan stok sistem berubah saat mengisi penyesuaian | F1-08 | |
| 8 | Log masuk/keluar staf | F1-03 | |
| 9 | Target margin di tab Ringkasan | F1-16d | |
| 10 | Rentang tanggal laporan terakhir diingat | F1-16b | |
| 11 | Umur piutang/hutang per pelanggan dan supplier | F1-16c | |
| 12 | Pelunasan piutang per rekening di laporan | F1-13i | |
| 13 | Cari: nama grup modifier, `5kg` = `5 kg`, garis miring Unicode lain di HP | F1-11f, F1-11e, F1-13f | |
| 14 | Sorot kata kunci di barang cocok Riwayat | F1-11i | |
| 15 | Tambahan harga per modifier di rincian nota | F1-11h | |
| 16 | Cetak stok hanya di bawah minimum | F1-08b | |
| 17 | Cetak semua tagihan tamu sekaligus | F1-10m | |
| 18 | Siapa yang mengarsipkan produk; jejak gabung meja | F1-07o, F1-10d | |
| 19 | Backup otomatis: jam dan jumlah simpanan bisa diatur; *hari ini* menurut kalender; preferensi tidak ikut pulihkan | F1-19d | |
| 20 | Import: rapatkan spasi ganda nama kategori | F1-07b | |
| 21 | PDF label / stok dan backup di isolate terpisah | F1-07e, F1-08b, F1-19d | |
| 22 | Satuan beli bawaan per barang (saran langsung dus) | F1-08j | |
| 23 | Lebih dari satu foto per faktur pembelian | F1-12b | |
| 24 | PDF retur pembelian (RB-) tersendiri | F1-12c | |
| 25 | Ekspor pratinjau import harga ke Excel | F1-07m | |
| 26 | Persetujuan ulang bila dasar diskon rupiah mengecil | F1-04e | |

## B. Sengaja tidak (keputusan produk, tetap `Belum` di spec)

Baris dengan catatan *sengaja*, *cukup*, atau perilaku yang dipilih:
kecilkan denah/QRIS/logo (F1-07l, F1-15b), cetak tagihan menandai *Minta
bill* (F1-10k), harga dari retur penuh (F1-08m), keranjang Kasir saat
ganti kasir (F1-02b), satu pemberi diskon per nota (F1-04i), ubah
referensi/pembayaran tanpa void (F1-05b, F1-13c), rekening sebagai master
ID (F1-05g), pindah rekening ke *Metode pembayaran* (F1-05c), logo dari
profil toko (F1-06b), stasiun dapur per produk / lebih dari dua (F1-10j),
pecah draf per supplier (F1-08d), target stok selain 2 × minimum (F1-08j),
templat bahasa lain (F1-07p), batas dpi label (F1-07i), grosir satuan
konversi dan import varian (F1-07b, F1-07c, F1-07k), modifier di Kasir
retail (F1-10), riwayat sesi lengkap di layar Sesi (F1-03f), kode negara
selain +62 (F1-13d), dan tepi teknis kecil lain yang catatannya menyebut
alasan bertahan (mis. F1-02d, F1-07j, F1-07n, F1-07q, F1-08i, F1-08k,
F1-08l, F1-10g, F1-10l, F1-10o, F1-11g, F1-12i, F1-19c).

## C. Fase 2/3, perangkat nyata, atau batas platform

- **Fase 2 (sinkronisasi/server):** import dari dua perangkat, jenis
  pengeluaran bawaan, draf penyesuaian lintas perangkat, stasiun printer
  ikut sync, `\` di `LIKE` Postgres, HP lama tersinkron, login email
  manajer, pilih toko dari server, huruf non-ASCII tanpa beda besar/kecil
  (Postgres melipat Unicode).
- **Fase 3:** QRIS dinamis, pengeluaran berulang, batas diskon per role
  (promo), kredit beberapa bagian split / pelanggan per bagian.
- **Perangkat atau platform:** Bluetooth BLE iOS/macOS/Windows, label
  langsung ke printer ESC/POS, QRIS di tagihan cetak (gambar ESC/POS),
  seret denah di tablet nyata, Cmd+Q kedua (macOS), jendela kedua Windows,
  backup otomatis di ponsel (SAF/Files) dan backup terkunci (keychain),
  Argon2 / AE-2 / normalisasi Unicode kata sandi, kalender Forui tanpa
  batas tanggal, encoder WebP, varian JPEG yang tidak didukung paket
  `image`.
