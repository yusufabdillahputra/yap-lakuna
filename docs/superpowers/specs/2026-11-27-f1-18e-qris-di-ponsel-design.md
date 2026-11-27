# F1-18e — *Tampilkan juga di layar mobile kasir* (QRIS statis)

Lanjutan F1-18 (Pengaturan › Metode pembayaran, 1.26b). Gap 3 di
`docs/superpowers/GAP-FASE1.md`.

## Tujuan

Pemilik bisa memilih apakah gambar stiker QRIS ikut tampil di layar kasir
ukuran ponsel. Toko yang memasang stiker QRIS cetak di meja kasir sering
memakai ponsel kecil sebagai kasir: gambar di layar 6 inci sulit dipindai
dan menutupi tombol, jadi pelanggan cukup memindai stiker cetak.

## Acuan desain (1.26b)

Kanvas menaruh sakelar **Tampilkan juga di layar mobile kasir** di bawah
*Kasir boleh konfirmasi tanpa PIN manajer*, tanpa keterangan. Spec
Storeku tidak mengaturnya; arti di bawah diputuskan di sini.

## Aturan

- Sakelar disimpan di pengaturan QRIS statis cabang
  (`payments.qris_static`, `showOnPhone`), **bawaan hidup** (perilaku lama
  tidak berubah). Butuh `settings:manage` seperti isian QRIS lain.
- Yang diatur hanya **gambar stiker** di tata letak ponsel (lebar layar
  < 600 px, breakpoint `LayoutSize.mobile`). Metode QRIS tetap bisa
  dipilih, nominal, merchant, *Dana masuk ke*, peringatan, *Belum masuk*,
  *Sudah Terbayar*, dan PIN manajer (F1-05h) tetap sama.
- Saat sakelar mati, di ponsel gambar stiker dan teks *Ketuk gambar untuk
  layar penuh* diganti kotak petunjuk *Minta pelanggan memindai stiker
  QRIS yang terpasang di toko.* Dialog bagian QRIS split di ponsel juga
  tidak memuat gambar dan memakai petunjuk yang sama.
- Tablet dan desktop selalu menampilkan gambar (sakelar hanya untuk
  ponsel, sesuai namanya).
- Sakelar tetap bisa diubah walau QRIS nonaktif (berlaku saat diaktifkan).

## UI

- **Pengaturan › Metode pembayaran › QRIS statis**: sakelar *Tampilkan
  juga di layar mobile kasir* dengan keterangan *Bila mati, kasir di
  ponsel tidak menampilkan gambar QRIS; pelanggan memindai stiker cetak
  di toko.*
- **Kasir › Bayar › QRIS statis (1.6m)** dan **dialog bagian QRIS** di
  ponsel: kotak petunjuk (ikon QR, teks di atas) menggantikan gambar.
- Panduan ID/EN: Pengaturan (sakelar) dan Kasir (QRIS).

## Tes

- Data: simpan sakelar, JSON lama tanpa kunci = hidup.
- Widget: sakelar di Pengaturan tersimpan; ponsel dengan sakelar mati
  tidak menampilkan gambar, petunjuk tampil, *Sudah Terbayar* tetap
  berhasil; tablet tetap menampilkan gambar; dialog bagian split ponsel.

## Status & gap

| Bagian | Desain | Status | Catatan |
| --- | --- | --- | --- |
| *Tampilkan juga di layar mobile kasir* | 1.26b | Rilis v0.139.0 | Hanya gambar di ponsel; bawaan hidup. |
