# F1-07e · Cetak label barcode

- **Fase:** 1
- **Status:** Rilis v0.36.0
- **Layar:** 1.15b Cetak label barcode (halaman baru), tombol di 1.15 Daftar
  produk dan 1.16 Form produk.
- **Acuan:** spec Storeku F1-07 "Label barcode: pilih produk + jumlah label,
  cetak ke printer label/thermal atau PDF A4 (Code128/EAN-13)"; kanvas 1.15
  tombol *Cetak label barcode*.
- **Menutup gap:** F1-07 "Tab Barcode & label, *Cetak label barcode*".

## Tujuan

Pemilik toko bisa menempel label harga + barcode di rak atau di barang
(terutama barang tanpa barcode pabrik yang diberi SKU sendiri), lalu kasir
cukup memindai label itu.

## Aturan

1. **Baris label** = setiap varian produk aktif (tidak diarsipkan), plus
   setiap satuan konversi yang punya barcode sendiri (mis. *dus*). Judul
   baris: nama produk, nama varian bila produk punya lebih dari satu
   varian, dan nama satuan untuk baris satuan. Harga: harga jual varian,
   atau harga jual satuan (bila kosong: harga varian × faktor).
2. **Kode** yang dicetak: barcode baris; bila kosong, SKU varian (baris
   satuan tanpa barcode tidak dibuat). Baris tanpa barcode maupun SKU tampil
   nonaktif dengan keterangan *Tanpa barcode/SKU*.
3. **Simbologi** (aturan di `lakuna_domain`, `labelSymbology`):
   - 13 digit dengan digit periksa benar → EAN-13;
   - 8 digit dengan digit periksa benar → EAN-8;
   - 12 digit dengan digit periksa benar → UPC-A;
   - selain itu, karakter ASCII cetak (32–126) → Code 128;
   - selain itu (mis. huruf beraksen) → tidak bisa dicetak, baris nonaktif.
4. **Kertas** (pilih satu, bawaan A4):
   - *A4 · 24 label (3 × 8)*: grid penuh 70 × 37,125 mm tanpa margin
     halaman (kertas stiker A4 siap potong). Opsi *Lewati label pertama*
     (0–23) untuk lembar yang sebagian sudah terpakai.
   - *Label 50 × 30 mm* dan *Label 38 × 25 mm*: satu label per halaman
     untuk printer label (lewat driver sistem / dialog cetak).
5. **Isi label**: nama (maks. 2 baris, dipotong), harga *Rp 36.000*
   (opsi *Tampilkan harga*, bawaan aktif), barcode dengan teks kode di
   bawahnya. Font PDF yang sama dengan kuitansi (DM Sans / Montserrat),
   tanpa aset jaringan.
6. **Jumlah**: centang baris → jumlah 1; ubah 1–999 per baris. Tombol *Isi
   sesuai stok* mengisi jumlah baris terpilih dengan stok varian (dibulatkan
   ke atas, stok satuan = stok ÷ faktor, minimal 1, maks. 999). Total label
   per cetak maks. 2.000; lebih dari itu tombol cetak nonaktif dengan pesan.
7. **Aksi**: *Cetak* (dialog cetak sistem, `ReceiptPrinter.printDocument`)
   dan *Simpan PDF* (share sheet di ponsel, folder Dokumen di desktop,
   `shareDocument`, folder yang sama dengan PDF struk), nama berkas
   `label-barcode-YYMMDD-HHmm.pdf`. Dialog cetak dibuka dengan ukuran kertas
   label yang dipilih (A4 / 50 × 30 / 38 × 25 mm). Hanya hasil aksi terakhir
   (cetak atau simpan) yang ditampilkan. Printer ESC/POS Bluetooth/jaringan
   tidak dipakai untuk label (lihat gap).
8. **Masuk dari**: tombol *Cetak label* di header 1.15 (ikon di ponsel), dan
   tombol *Cetak label* di form 1.16 untuk produk lama yang membuka halaman
   dengan baris produk itu sudah dicentang. Izin `products:manage` (layar
   produk).
9. **Pencarian** nama, SKU, dan barcode (SKU tetap dicari walau barcode
   terisi) dan saklar *Hanya yang dipilih*; saklar ini otomatis aktif bila
   halaman dibuka dari form produk. Label memakai data produk yang sudah
   disimpan. Jumlah di luar 1–999 dan *Lewati* di luar 0–23 langsung
   dibetulkan di kolomnya.
   Pratinjau satu label (baris terpilih pertama) ditampilkan di panel kanan
   (layar lebar) atau di atas tombol (ponsel).

## Komponen

- Domain: `BarcodeSymbology`, `labelSymbology(String)`, `eanCheckDigit`.
- Flutter: `services/barcode_label_pdf.dart` (`BarcodeLabelPaper`,
  `BarcodeLabel`, `buildBarcodeLabelPdf`), `BarcodeLabelViewModel`
  (`LabelRow`), `BarcodeLabelScreen`, rute `/produk/label` (`?produk=<id>`).

## Pengujian

- Domain: EAN-13/EAN-8/UPC-A valid dan digit periksa salah → Code 128, kode
  non-ASCII → tidak bisa.
- PDF: A4 25 label → 2 halaman, lewati 23 → 2 halaman untuk 2 label, roll
  3 label → 3 halaman.
- VM: baris dari katalog (varian, satuan berbarcode, tanpa kode), pilih
  awal dari produk, isi sesuai stok, batas total, cetak/simpan memanggil
  printer, galat printer.
- Widget 1280/360 px: buka dari daftar, pilih, cetak; buka dari form.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Cetak label barcode A4 / printer label (PDF) | Tombol 1.15 | Rilis v0.36.0 | |
| Label langsung ke printer ESC/POS (Bluetooth/jaringan) | — | Belum | Perlu perintah barcode ESC/POS dan ukuran label per printer. |
| Tab *Barcode & label* di form 1.16 | Ada | Diganti | Tombol *Cetak label* di form membuka 1.15b. |
| Buat barcode otomatis untuk produk tanpa kode | — | Rilis v0.55.0 | Tombol *Buat barcode* di field Barcode varian, EAN-13 awalan 20 ([F1-07h](2026-11-14-f1-07h-barcode-otomatis-upc-design.md)). |
| Peringatan kode terlalu panjang untuk label kecil | — | Rilis v0.57.0 | [F1-07i](2026-11-14-f1-07i-peringatan-kode-label-design.md): peringatan bila garis < 0,25 mm untuk kertas terpilih. |
| UPC-A dibaca pemindai sebagai 13 digit (awalan 0) | — | Rilis v0.55.0 | `barcodeKey` menyamakan `0` + UPC-A dengan kode 12 digit ([F1-07h](2026-11-14-f1-07h-barcode-otomatis-upc-design.md)). |
| PDF ribuan label tanpa membekukan layar | — | Belum | Batas 2.000 label; PDF dibuat di isolate UI. |
