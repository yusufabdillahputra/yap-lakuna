# F1-05c — Rekening transfer di tombol bayar

- **Fase:** 1
- **Status:** Rilis v0.74.0
- **Layar:** 1.26 Pengaturan (*Penjualan & stok*), 1.5 Pembayaran
  (Kasir, bill Meja, bagian split bill).
- **Acuan:** gap [F1-05](2026-11-03-f1-05-pembayaran-design.md)
  *Rekening transfer di tombol* ("BCA 123-456-7890") dan gap
  [F1-18](2026-11-03-f1-18-pengaturan-design.md) *Rekening transfer*.
  Storeku punya gap yang sama (belum dibangun).

## Tujuan

Saat pembeli mau bayar transfer, kasir harus menyebutkan nomor rekening
toko. Sekarang kasir harus menghafal atau mencari catatan. Modul ini
menyimpan teks rekening di pengaturan cabang dan menampilkannya di layar
bayar, siap disalin.

## Aturan

1. **Pengaturan (1.26), kartu *Penjualan & stok*:** isian *Rekening
   transfer* (`store-rules-transfer`), satu baris, opsional, maks 100
   karakter, mis. `BCA 123-456-7890 a.n. Warung Contoh`. Disimpan bersama
   aturan lain lewat tombol *Simpan* kartu itu. Spasi di awal/akhir
   dibuang. Per cabang (kunci `sales.rules`), karena tiap cabang bisa
   punya rekening sendiri.
2. **Tombol metode *Transfer bank*** di layar bayar lebar (≥ 600 px;
   di ponsel kartu metode hanya berisi ikon dan nama): bila rekening diisi,
   keterangan kecil di bawah judul berisi teks rekening (dipotong dengan
   elipsis bila panjang) menggantikan *Cek mutasi dulu*. Bila kosong,
   tetap *Cek mutasi dulu*.
3. **Panel transfer:** bila rekening diisi, tampil kotak *Transfer ke*
   (`payment-transfer-account`) dengan teks rekening utuh dan tombol
   *Salin* (`payment-transfer-copy`) yang menyalin teks ke clipboard;
   labelnya berubah menjadi *Disalin* dengan ikon centang. Di layar sempit
   atau teks besar, tombol turun ke baris berikutnya (tanpa memotong
   rekening). Catatan *cek mutasi* tetap ada.
4. Berlaku sama untuk Kasir retail, bill Meja/take away, dan bayar per
   bagian split bill (layar bayar yang sama). Baris transfer di *Bagi
   metode* (split payment) belum menampilkannya (gap).
5. Teks rekening tidak dicetak di struk (gap terpisah).

## Rancangan teknis

- Domain: `SalesRules.transferAccount` (`String`, bawaan `''`), ikut
  `fromJson` (bukan string → kosong; dipangkas), `toJson`, `copyWith`,
  `==`. `ProfileLimits.transferAccount = 100`.
- Data: `saveSalesRules` memangkas teks dan menolak lebih dari 100
  karakter (`SalesRulesInvalid`, tampil sebagai galat simpan; UI sudah
  membatasi). `fromJson` membatasi nilai tersimpan ke 100 karakter agar
  data lama/rusak tidak membuat simpan aturan lain gagal.
- VM Pengaturan: `setTransferAccount`; `rulesDirty` membandingkan
  setelah dipangkas.
- VM Kasir: `transferAccount` dari `CashierData.salesRules`.
- UI: `TransferAccountBox` (StatefulWidget, `Clipboard.setData`) di panel
  kartu/transfer; keterangan tombol metode memakai rekening.
- l10n: `storeSettingsTransferAccount`, `storeSettingsTransferAccountHint`,
  `paymentTransferTo`, `paymentTransferCopy`, `paymentTransferCopied` (*Disalin*).

## Tes

- Domain: JSON lama tanpa kunci → kosong; bukan string → kosong;
  dipangkas; `==` memperhitungkan rekening.
- Data: simpan lalu muat ulang; dipangkas; 101 karakter ditolak.
- VM/widget Pengaturan: isi rekening → *Simpan* aktif → tersimpan.
- Widget layar bayar 1280/360: tombol *Transfer bank* menampilkan
  rekening; panel transfer menampilkan kotak dan tombol salin menyalin
  ke clipboard; tanpa rekening tetap *Cek mutasi dulu* tanpa kotak.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Rekening transfer di tombol dan panel bayar | 1.5 | Rilis v0.74.0 | Isian di *Penjualan & stok*. |
| Pindah ke halaman *Metode pembayaran* | 1.26 | Belum | Halaman itu kini khusus QRIS statis; pindahkan bila metode lain ikut diatur di sana. |
| Rekening transfer di struk | — | Belum | Berguna untuk nota piutang/pesanan yang dibayar nanti. |
| Rekening di baris transfer *Bagi metode* | 1.5 | Belum | Panel split payment memakai daftar baris sendiri. |
| Beberapa rekening terpisah (pilih bank) | — | Belum | Sekarang satu baris teks bebas, mis. `BCA 123 · Mandiri 456`. |
