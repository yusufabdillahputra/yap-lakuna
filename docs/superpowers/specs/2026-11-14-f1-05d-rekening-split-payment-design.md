# F1-05d — Rekening transfer di *Bagi beberapa metode*

- **Fase:** 1
- **Status:** Rilis v0.76.0
- **Layar:** 1.5 Pembayaran, panel *Bagi beberapa metode* (Kasir, bill
  Meja/take away, bayar per bagian split bill).
- **Acuan:** gap [F1-05c](2026-11-14-f1-05c-rekening-transfer-design.md)
  *Rekening di baris transfer Bagi metode*. Storeku belum punya rekening
  transfer sama sekali.

## Tujuan

Sejak v0.74.0 rekening toko tampil saat pembeli membayar penuh dengan
transfer. Pembeli yang membayar sebagian tunai dan sisanya transfer juga
butuh nomor rekening, tetapi panel *Bagi beberapa metode* belum
menampilkannya, jadi kasir kembali harus menghafal.

## Aturan

1. Di panel *Bagi beberapa metode*, bila metode yang dipilih untuk bagian
   baru adalah **Transfer bank** dan *Rekening transfer* diisi di
   Pengaturan › *Penjualan & stok*, kotak **Transfer ke** (sama dengan
   F1-05c: teks rekening + tombol **Salin**, label *Disalin*) tampil di
   antara isian *Nominal* dan *Referensi transfer*.
2. Metode lain (tunai, kartu, QRIS) atau rekening kosong: kotak tidak
   tampil.
3. Setelah bagian transfer ditambah, metode kembali ke tunai, atau ke
   kartu bila sudah ada bagian tunai (perilaku lama), sehingga kotak
   hilang.
4. Tata letak memakai `Wrap` dari F1-05c: di ponsel 360 px tombol *Salin*
   turun ke baris berikutnya tanpa overflow.

## Rancangan teknis

- `SplitPanel` (`lib/ui/cashier/split_panel.dart`) menampilkan
  `TransferAccountBox(account: vm.transferAccount)` bila
  `vm.draftMethod == PaymentMethod.transfer && vm.transferAccount.isNotEmpty`.
  Tidak ada perubahan data, l10n, atau view model.

## Tes

- Widget alur kasir 1280 dan 360 px: kotak tidak tampil untuk tunai/kartu,
  tampil berisi rekening untuk transfer, hilang setelah bagian ditambah;
  tanpa overflow.
- Tanpa rekening: kotak tidak tampil di panel split saat transfer dipilih.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Rekening di panel *Bagi beberapa metode* | 1.5 | Rilis v0.76.0 | — |
| Rekening di baris bagian transfer yang sudah ditambah | — | Belum | Baris hanya menampilkan referensi; rekening tampil saat memilih metode. |
