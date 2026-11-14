# F1-07o — Tanggal arsip di dialog *Produk diarsipkan*

- **Fase:** 1
- **Status:** Rilis v0.78.0
- **Layar:** 1.15 Daftar produk › dialog *Produk diarsipkan*.
- **Acuan:** gap [F1-07d](2026-11-13-f1-07d-arsip-produk-design.md)
  *Tanggal arsip di dialog* ("Layar produk belum memegang zona waktu
  cabang"). Storeku belum punya arsip produk.

## Tujuan

Pemilik yang membuka *Produk diarsipkan* sering bertanya "kapan produk ini
diarsipkan?", misalnya untuk menelusuri kenapa barang hilang dari Kasir.
Waktu arsip sudah tersimpan (`products.deleted_at`) tetapi belum tampil.

## Aturan

1. Setiap baris dialog menambah keterangan **Diarsipkan {tanggal}** di
   belakang kategori dan stok terakhir, mis.
   *Sembako · Stok 24 botol · Diarsipkan 14 November 2026* (EN:
   *Archived November 14, 2026*).
2. Tanggal memakai **zona waktu cabang** (zona outlet, atau zona tenant
   bila outlet kosong), bukan zona perangkat, sama dengan nota dan laporan.
3. **Ponsel:** di dialog yang sempit (< 360 px isi), tombol *Pulihkan*
   turun ke bawah teks. Sebelumnya tombol di samping teks membuat nama dan
   keterangan terlipat per huruf; daftar juga menyusut (`Flexible`) agar
   tombol *Tutup* tidak terdorong keluar layar.

## Rancangan teknis

- `CatalogRepository.archived()` mengembalikan
  `ArchivedCatalog = ({List<CatalogProduct> products, String? timezone})`;
  `LocalCatalogRepository` mengisi zona dari `StoreContext` (outlet, lalu
  tenant).
- `ArchivedProductsViewModel.timezone`; `_Row` memformat
  `formatLongDate(l10n, outletLocalTime(archivedAt, timezone))`.
- l10n `productsArchivedOn(date)`.

## Tes

- VM: zona waktu ikut dimuat.
- Widget 1280/360: keterangan berisi tanggal lokal cabang (20.00 UTC
  13/11 → 14 November WIB); tinggi baris di 360 px < 200 px; tanpa
  overflow.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Tanggal arsip di dialog | — | Rilis v0.78.0 | — |
| Siapa yang mengarsipkan | — | Belum | Tidak ada kolom `archived_by`; butuh migrasi. |
