# F1-08b · Cetak stok

- **Fase:** 1
- **Status:** Dikerjakan
- **Layar:** 1.18 Stok, tombol *Cetak stok* di kepala layar (kanvas
  [Desain UI Lakuna](https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525),
  berkas `F1-Stok`).
- **Acuan:** gap *Cetak stok* di F1-08 dan spec Storeku F1-08 ("PDF/print
  daftar stok per lokasi"). Perbedaan dicatat di sini.

## Tujuan

Pemilik atau staf gudang mencetak daftar stok satu lokasi untuk dihitung
di rak (stock opname manual), lalu memasukkan hasil hitungnya di tab
*Penyesuaian*.

## Aturan

1. **Tombol** *Cetak stok* (ikon printer, `stock-print`) di kepala layar
   Stok, tampil di semua tab, di samping pilihan lokasi. Aktif bila data
   termuat dan lokasi terpilih punya minimal satu baris; mati selama PDF
   dibuat dan disimpan (ketukan ganda tidak membuat dua berkas).
2. **Isi** PDF A4 tegak memakai mesin PDF laporan (`reportPdf`, F1-16):
   - judul `Daftar stok · <lokasi>`; subjudul `<cabang> · dicetak <tanggal>
     <jam> · <staf>` (zona waktu cabang);
   - kolom **Produk** (nama + varian), **SKU**, **Stok** (jumlah + satuan
     dasar), **Minimum** (kosong bila tidak diisi, sama dengan daftar),
     **Nilai** (stok × HPP, sama dengan daftar), **Fisik** (kosong, untuk
     ditulis tangan);
   - baris **Total** nilai;
   - catatan: jumlah item · di bawah minimum · stok minus, lalu "Tulis
     hasil hitung di kolom Fisik, lalu catat selisihnya di menu Stok, tab
     Penyesuaian." (tanpa karakter `›`, yang tidak ada di font PDF).
3. **Baris**: semua varian barang di lokasi terpilih dengan urutan yang
   sama dengan tab *Daftar produk*. Kata pencarian **tidak** menyaring isi
   cetakan (daftar opname harus lengkap).
4. **Simpan** lewat `SpreadsheetExporter` (sama dengan unduh PDF
   laporan): desktop menyimpan ke folder dokumen Lakuna dan menampilkan
   lokasi berkas (`stock-print-saved`); Android/iOS membuka share sheet
   (dari sana bisa dicetak). Galat tampil sebagai pesan `stock-print-failed`.
   Nama berkas `stok-<lokasi>-<yymmdd>.pdf` (lokasi huruf kecil, spasi →
   `-`, tanpa karakter lain).
5. **Izin**: siapa pun yang bisa membuka layar Stok. Nilai stok ikut
   tercetak karena layar juga menampilkannya.

Perbedaan dari Storeku: Storeku belum punya cetak stok; kolom *Fisik*
kosong ditambahkan agar cetakan langsung bisa dipakai opname.

## Komponen

- `stock_print.dart` (`ui/stock`): `stockPrintTable(l10n, …)` →
  `ReportTable`, `stockPrintFileName(location, date)`.
- `StockViewModel`: `exporter`, `print` (`Command1<String?, Uint8List>`),
  `printPath`.
- `StockScreen` menerima `exporter` dari router.

## Pengujian

- Unit: isi tabel (kolom, minimum kosong, total, catatan, pencarian
  diabaikan), nama berkas.
- VM: `print` menyimpan dengan nama berkas, lokasi tersimpan, galat.
- Widget 1280 / 360 px: tombol, pesan lokasi, tombol mati tanpa baris.
- Uji manual Xvfb: cetak stok Etalase, buka PDF.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Cetak stok per lokasi (PDF) | 1.18 | Dikerjakan | |
| Cetak langsung ke printer tanpa berkas | — | Belum | Desktop menyimpan PDF; cetak dari penampil PDF. |
| Cetak hanya di bawah minimum | — | Belum | Bila diminta; tab *Stok minimum* sudah menampilkannya. |
