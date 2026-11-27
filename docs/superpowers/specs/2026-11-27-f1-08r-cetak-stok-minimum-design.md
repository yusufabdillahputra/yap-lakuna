# F1-08r — Cetak stok di bawah minimum

Tanggal: 2026-11-27 · Modul: F1-08 Stok (1.18, tab **Stok minimum**) ·
Gap 16 di `docs/superpowers/GAP-FASE1.md`, gap 95 di STATUS-JEDA ·
Rilis: v0.152.0

## Masalah

*Cetak stok* (F1-08b) selalu mencetak semua barang di lokasi. Pemilik yang
hanya ingin membawa daftar belanja ke supplier, atau mengecek rak barang
yang hampir habis, harus mencari baris *di bawah minimum* di antara ratusan
baris.

## Aturan

1. Di tab **Stok minimum**, tombol di kepala layar menjadi **Cetak stok
   minimum** dan mencetak hanya barang di daftar tab itu (stok ≤ minimum,
   minimum diisi), dengan urutan yang sama. Di tab lain tombol tetap
   *Cetak stok* dan mencetak semua barang (F1-08b).
2. Isi PDF A4 tegak:
   - judul `Stok di bawah minimum · <lokasi>`; subjudul sama dengan
     F1-08b (`<cabang> · dicetak <tanggal> <jam> · <staf>`);
   - kolom **Produk**, **SKU / Barcode**, **Stok**, **Minimum**, **Saran
     beli** (jumlah + satuan dasar, sama dengan *Buat pembelian* F1-08c),
     **Fisik** (kosong untuk ditulis tangan);
   - tanpa kolom *Nilai* dan baris *Total*, karena daftar ini untuk
     belanja dan cek rak;
   - catatan: jumlah item · stok minus, lalu "Saran beli = 2 × minimum − stok (stok minus
     dihitung 0), dibulatkan ke atas, sama dengan Buat pembelian."
3. Tombol mati bila daftar minimum kosong, dan dengan syarat F1-08b yang
   lain (sedang memuat, lokasi baru belum termuat, sedang mencetak).
4. Nama berkas `stok-minimum-<lokasi>-<yymmdd>-<HHmm>.pdf`. Pesan sukses
   dan galat sama dengan F1-08b.
5. Izin sama dengan F1-08b: siapa pun yang bisa membuka layar Stok.

## Rancangan teknis

- `stock_print.dart`: `stockMinimumPrintTable(l10n, rows:, …)` dan
  `stockPrintFileName(…, minimum: true)`.
- `StockViewModel.printsMinimum` (`tab == StockTab.minimum`);
  `printRows` memakai `below` di tab itu; `canPrint` ikut.
- `stock_view.dart`: label tombol dan pembuat tabel menurut
  `printsMinimum`.
- Kunci l10n baru: `stockPrintMinimum`, `stockPrintMinimumTitle`,
  `stockPrintColSuggested`, `stockPrintMinimumCounts`,
  `stockPrintMinimumNote`.

## Pengujian

- Unit: kolom, saran beli dengan satuan, stok minus, catatan, bahasa
  Inggris, nama berkas `stok-minimum-…`.
- VM: `printRows` dan `canPrint` di tab minimum (kosong → mati).
- Widget 1280 / 360 px: label tombol berganti di tab minimum.
- Uji manual Xvfb: tab Stok minimum › Cetak stok minimum, buka PDF.

## Status & gap

| Topik | Kode | Catatan |
| --- | --- | --- |
| Cetak hanya di bawah minimum | Rilis v0.152.0 | Dari tab *Stok minimum*. |
| Status draf pembelian di cetakan | Belum | Cetakan tidak menulis *Sudah di draf …*; lihat di layar. |
