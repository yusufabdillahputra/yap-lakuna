# F1-07i · Peringatan kode terlalu panjang untuk label

- **Fase:** 1
- **Status:** Rilis v0.57.0
- **Layar:** 1.15b Cetak label barcode.
- **Acuan:** F1-07e (label barcode), F1-07h (buat barcode EAN-13 toko).
- **Menutup gap:** F1-07e "Peringatan kode terlalu panjang untuk label kecil".

## Tujuan

Produk tanpa barcode dicetak dengan SKU sebagai Code 128. SKU panjang di
kertas kecil (38 × 25 mm) membuat garis barcode lebih tipis dari yang bisa
dicetak printer termal 203 dpi (1 titik = 0,125 mm) dan dibaca pemindai.
Label tetap tercetak, tetapi gagal dipindai di kasir. Pemilik perlu tahu
sebelum mencetak satu gulung label.

## Aturan

1. **Lebar modul**: lebar area barcode di label dibagi jumlah modul
   (garis/spasi tersempit) simbologi. Batas minimum **0,25 mm** (2 titik
   printer 203 dpi); di bawahnya kode dianggap *terlalu rapat*.
2. **Jumlah modul** (`barcodeModules`, `barcode_label_pdf.dart`) diambil
   dari hasil gambar paket `barcode` yang juga mencetak label (lebar total
   dibagi garis tersempit), sehingga sama dengan yang tercetak untuk
   Code 128 (EAN-13/UPC-A sedikit lebih sempit karena digit di luar garis
   memakan ±2 mm, tetap aman di semua kertas):
   EAN-13 dan UPC-A 95, EAN-8 67, Code 128 `11 × (simbol + 2) + 13` dengan
   deret angka ≥ 4 dipadatkan ke set C (dua digit per simbol). Zona tenang
   tidak dihitung karena sudah disisihkan sebagai padding. Kode yang tidak
   bisa digambar menghasilkan 0 dan tidak ditandai.
3. **Lebar area barcode** per kertas (`BarcodeLabelPaper.barcodeWidthMm`) =
   lebar label − 2 × (padding + zona tenang): A4 70 − 12 = 58 mm,
   50 × 30 50 − 8 = 42 mm, 38 × 25 38 − 6 = 32 mm.
4. Layar Cetak label menampilkan peringatan (`FAlert` primary + ikon
   segitiga peringatan; Forui tidak punya varian kuning) di bawah total
   label, dekat tombol Cetak, bila ada produk terpilih yang kodenya terlalu
   rapat untuk kertas yang dipilih. Isinya jumlah produk dan namanya (maks.
   3 nama, sisanya *dan N lainnya*) serta sarannya:
   kertas lebih lebar, SKU lebih pendek, atau *Buat barcode* (F1-07h).
   Peringatan tidak memblokir cetak/simpan (pemilik mungkin punya printer
   300 dpi).
5. Contoh: SKU 14 karakter (189 modul) aman di A4 (0,31 mm) tetapi terlalu
   rapat di 50 × 30 (0,22 mm) dan 38 × 25 (0,17 mm). EAN-13 aman di semua
   kertas (38 × 25: 0,34 mm). SKU sekitar 20 karakter terlalu rapat bahkan
   di A4.

## Komponen

- Domain (`barcode.dart`): `minBarcodeModuleMm`,
  `barcodeTooDense(modules, widthMm)`.
- Flutter (`barcode_label_pdf.dart`): `barcodeModules`, `barcodeTooDenseOn`,
  `BarcodeLabelPaper.labelWidthMm` / `barcodeWidthMm`;
  `BarcodeLabelViewModel.denseRows`, `FAlert`
  `labels-too-dense` di `barcode_label_view.dart`.
- l10n: `labelsTooDense` (`{count}`, jamak di EN), `labelsTooDenseHint`
  (`{names}`), `labelsTooDenseMore` (`{names}`, `{count}`).
- Jumlah modul di-cache per kode di view model (getter dipanggil tiap
  rebuild).

## Pengujian

- Domain: batas terlalu rapat dari jumlah modul dan lebar.
- Layanan PDF: jumlah modul per simbologi (Code 128 huruf, campuran dengan
  deret angka, 13 digit), kode tak terbaca, hasil per kertas.
- VM: produk SKU 14 karakter tidak ditandai di A4, ditandai di 38 × 25 dan
  50 × 30, bersih lagi saat kembali ke A4 dan saat produk tidak dipilih.
- Widget (1280 dan 360 px): peringatan muncul setelah memilih kertas
  38 × 25; tidak muncul untuk SKU pendek di 50 × 30.
- Uji manual Xvfb: produk SKU panjang, kertas 38 × 25.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Peringatan kode terlalu rapat per kertas | — | Rilis v0.57.0 | Batas 0,25 mm per modul, tidak memblokir cetak. |
| Batas mengikuti dpi printer yang dipilih | — | Belum | Saat ini anggap printer termal 203 dpi. |
