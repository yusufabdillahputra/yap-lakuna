# F1-08l · Jumlah yang sudah di draf dibandingkan saran stok minimum

- **Fase:** 1
- **Status:** Rilis v0.112.0
- **Layar:** 1.18 *Stok* › tab *Stok minimum* (dan panel *Stok minimum* di
  tab *Penyesuaian* desktop).
- **Acuan:** gap "Jumlah di draf dibandingkan jumlah saran" di
  [F1-08h](2026-11-14-f1-08h-tanda-sudah-di-draf-design.md). Saran
  `2 × minimum − stok` dari [F1-08c](2026-11-14-f1-08c-pembelian-dari-stok-minimum-design.md).

## Masalah

Keterangan *Sudah di draf PB-…* tidak menyebut berapa yang sudah dipesan.
Staf tidak tahu apakah draf itu sudah cukup (mis. 5 botol, padahal saran
38 botol) tanpa membuka draf satu per satu.

## Aturan

1. Keterangan menjadi **Sudah di draf {nomor}: {dipesan} dari saran
   {saran} {satuan}**, mis. "Sudah di draf PB-PST-D01-261103-0001: 5 dari
   saran 38 pcs".
   - **Dipesan** = jumlah barang itu di semua draf pembelian cabang ke
     lokasi yang dilihat, dalam satuan dasar (2 dus isi 6 = 12 botol).
   - **Saran** = jumlah yang diisi *Buat pembelian* (F1-08c):
     `2 × minimum − stok`, dibulatkan ke atas, minimal 1.
2. Bila barang ada di lebih dari satu draf: **Sudah di {n} draf, a.l.
   {nomor}: {dipesan} dari saran {saran} {satuan}**; nomor yang disebut
   tetap draf pertama menurut urutan F1-08g.
3. Aturan F1-08h lain tetap: hanya untuk staf berizin pembelian, galat
   baca draf diabaikan, ikut segar saat daftar dimuat ulang, teks dibungkus
   utuh tanpa elipsis.

## Rancangan teknis

- `RestockDraft.quantities`: `variantId → Qty` satuan dasar per draf
  (`Qty(quantityMilli).toBaseUnit(factorMilli)`, dijumlah per baris).
  `restockDraftsOf` mengisinya; `variantIds` tetap.
- `StockViewModel.draftMarkOf(variantId)` →
  `DraftMark ({String number, int drafts, Qty ordered})?`, menggantikan
  `draftNumberOf`.
- `StockViewModel.suggestedOf(row)` (`restockQuantity(stock, minStock)`)
  dipakai bersama oleh *Buat pembelian* dan keterangan, agar saran yang
  tampil sama dengan isian form.
- `_MinimumPanel`: `formatQty` untuk angka.
- l10n baru: `stockMinimumInDraftQty`, `stockMinimumInDraftsQty`
  (ID + EN); `stockMinimumInDraft` tidak dipakai lagi.

## Pengujian

- Data: jumlah per draf dalam satuan dasar (dus × isi), dua baris barang
  yang sama dalam satu draf dijumlah.
- VM: dipesan dijumlah dari semua draf, jumlah draf, nomor draf pertama.
- Widget (1280 / 360 px): satu draf dan dua draf, teks utuh tanpa elipsis.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Jumlah di draf dibandingkan saran | 1.18 | Rilis v0.112.0 | `RestockDraft.quantities`, `draftMarkOf`. |
| Tanda *cukup* bila draf sudah memenuhi saran | 1.18 | Rilis v0.131.0 | [F1-08p](2026-11-20-f1-08p-tanda-cukup-draf-design.md): *Cukup untuk saran* / *Kurang … dari saran*. |
| Tes konversi satuan di repositori palsu | — | Belum | Produk palsu tanpa satuan konversi; konversi diuji di `lakuna_data`. |
