# F1-07s — Siapa yang mengarsipkan produk

Tanggal: 2026-11-27 · Modul: F1-07 Produk (1.15, dialog *Produk
diarsipkan*) · Gap 18 (bagian pertama) di `docs/superpowers/GAP-FASE1.md`,
gap 97 di STATUS-JEDA · Rilis: v0.154.0

## Masalah

Dialog *Produk diarsipkan* menulis kapan produk diarsipkan (F1-07o), tetapi
tidak siapa. Pemilik yang menelusuri "kenapa Kopi Sachet hilang dari
Kasir" harus bertanya ke semua staf.

## Aturan

1. Keterangan baris menjadi *Sembako · Stok 24 botol · Diarsipkan 14
   November 2026 oleh Rina* (EN *Archived November 14, 2026 by Rina*).
2. Pengarsip = staf yang terakhir mengubah produk itu (`products.updated_by`).
   Produk arsip tidak bisa diubah selain dipulihkan, dan arsip serta pulih
   sama-sama mengisi `updated_by`, jadi nilainya selalu pengarsip terakhir.
   Diarsipkan ulang setelah dipulihkan → nama terbaru.
3. Bila staf tidak ditemukan (data lama tanpa `updated_by`), keterangan
   kembali ke *Diarsipkan 14 November 2026* tanpa nama.
4. Nama staf yang sudah dinonaktifkan tetap ditulis.

## Rancangan teknis

- Tanpa migrasi: `products.updated_by` sudah diisi `archiveProduct` dan
  `restoreProduct` sejak F1-07d.
- `CatalogProduct.archivedByName`: `_loadProducts` memuat nama staf untuk
  produk yang `deleted_at`-nya terisi.
- `archived_products_dialog.dart`: `archivedOnLabel(l10n, at, timezone,
  by)`; l10n baru `productsArchivedOnBy` (ID/EN).

## Pengujian

- Data: diarsipkan Rina → `archivedByName` Rina; produk aktif `null`;
  dipulihkan lalu diarsipkan pemilik → nama pemilik.
- Unit label: dengan nama, tanpa nama, bahasa Inggris.
- Widget 1280/360 (alur arsip yang ada): keterangan memuat *oleh Yusuf*.
- Uji manual Xvfb: arsipkan produk, buka *Produk diarsipkan*.

## Status & gap

| Topik | Kode | Catatan |
| --- | --- | --- |
| Siapa yang mengarsipkan | Rilis v0.154.0 | Dari `updated_by` produk arsip. |
| Riwayat arsip/pulih lengkap per produk | Belum | Hanya pengarsip terakhir yang terlihat. |
| Risiko Fase 2 (sync) | Catatan | Sync antar-perangkat tidak boleh menimpa produk arsip dengan suntingan perangkat lain; bila boleh, `updated_by` bukan lagi pengarsip dan butuh kolom `archived_by`. |

Review (tanpa Critical/Important): semua jalur tulis `Product` di
`lakuna_data` diperiksa; hanya `restoreProduct` yang menyentuh produk arsip.
