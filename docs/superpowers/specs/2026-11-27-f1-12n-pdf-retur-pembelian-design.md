# F1-12n · PDF retur pembelian (RB-) tersendiri

- **Fase:** 1
- **Status:** Rilis v0.161.0
- **Layar:** rincian pembelian (1.19b), daftar *Retur yang sudah dibuat* di
  kartu retur.
- **Acuan:** gap 24 di `GAP-FASE1.md` dan gap
  [F1-12c](2026-11-14-f1-12c-pdf-pembelian-kartu-stok-design.md) *PDF retur
  pembelian (RB-) tersendiri*. Pola sama dengan PDF pembelian F1-12c.

## Masalah

Saat barang dikembalikan ke supplier, supplier atau sopirnya meminta bukti
retur: barang apa, berapa, dan nilainya. Sejauh ini retur hanya tercantum
satu baris (`Retur RB-… · tanggal · Rp…`) di PDF pembelian asal, sehingga
pemilik harus mencetak seluruh pembelian dan menjelaskan baris mana yang
diretur.

## Aturan

1. Setiap baris di *Retur yang sudah dibuat* punya tombol **PDF**
   (`purchase-return-print-<id>`) yang membuat PDF retur itu saja, dengan
   jalur simpan/bagikan yang sama dengan *Cetak / bagikan PDF* (desktop
   menyimpan berkas dan menampilkan lokasinya; ponsel membuka lembar
   bagikan).
2. Isi PDF:
   - Judul *Retur pembelian RB-…*; subjudul: supplier (atau *Tanpa
     supplier*), *Dari pembelian PB-…*, No. faktur supplier bila ada,
     tanggal retur (zona waktu toko), lokasi, staf yang mencatat retur,
     kode perangkat.
   - Tabel Barang | Qty | Nilai: satu baris per barang yang diretur (nama +
     varian + SKU; qty dalam satuan baris pembelian, dengan isi konversi
     bila bukan satuan dasar; nilai = nilai mendarat yang dikembalikan).
   - Ringkasan: **Total retur**, *Memotong hutang* (bila > 0), *Uang
     kembali* + sumbernya (laci / kas toko / rekening) bila > 0.
   - Catatan: catatan retur bila ada, lalu *Dicetak … oleh …*.
3. Nama berkas `retur-<nomor>.pdf` huruf kecil (mis.
   `retur-rb-pst-d01-261103-0001.pdf`); cetak ulang menimpa berkas lama.
4. PDF dibuat di isolate terpisah seperti PDF lain (F1-19f).
5. Izin dan cabang sama dengan rincian pembelian; tidak ada tulis data.
6. Pesan hasil di kartu *Tindakan* dibuat umum (*PDF disimpan di …* /
   *PDF gagal dibuat*) karena dipakai PDF pembelian dan PDF retur.
7. Baris retur yang barangnya tidak ada di perangkat (belum tersinkron)
   dicetak *Barang tidak ditemukan* dengan qty dan nilainya, agar baris
   berjumlah sama dengan total.

## Komponen

- Data: `PurchaseDetail.returnItems` (baris retur per id retur) dan
  `returnStaffNames`.
- Flutter: `purchaseReturnPrintTable`, `purchaseReturnPrintFileName`;
  tombol per retur di `_ActionsCard`.

## Pengujian

- Data: detail memuat baris retur per retur dan nama staf.
- Flutter: tabel cetak (baris, ringkasan, sumber uang kembali, catatan),
  nama berkas, tanggal menurut zona toko, tanpa supplier, baris barang
  yang tidak ditemukan; widget desktop dan 360 px (retur → tombol PDF →
  berkas tersimpan / lembar bagikan).
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| PDF retur pembelian (RB-) tersendiri | — | Rilis v0.161.0 | Tombol PDF per retur di rincian pembelian. |
| Tanda tangan penerima di PDF retur | — | Belum | Supplier menandatangani lembar cetak secara manual. |
