# F1-08p · Tanda *cukup* / *kurang* untuk barang di draf pembelian

- **Fase:** 1
- **Status:** Rilis v0.131.0
- **Layar:** 1.18 *Stok* › tab *Stok minimum* (dan panel *Stok minimum* di
  tab *Penyesuaian* desktop).
- **Acuan:** gap "Tanda *cukup* bila draf sudah memenuhi saran" di
  [F1-08l](2026-11-15-f1-08l-jumlah-di-draf-design.md). Storeku tidak punya
  tanda draf. Penyempurnaan layar.

## Masalah

Keterangan *Sudah di draf PB-…: 5 dari saran 38 pcs* (F1-08l) menyebut
angka, tetapi staf masih harus membandingkan sendiri setiap baris untuk
tahu barang mana yang pesanannya sudah cukup dan mana yang masih perlu
ditambah. Dengan belasan barang di bawah minimum, mudah terlewat.

## Aturan

1. Di bawah keterangan *Sudah di draf …* tampil satu baris status:
   - **Cukup untuk saran** (hijau, ikon centang) bila jumlah yang dipesan
     di semua draf ≥ saran;
   - **Kurang {selisih} {satuan} dari saran** (abu-abu) bila masih kurang,
     dengan selisih = saran − dipesan dalam satuan dasar.
2. Saran dan jumlah dipesan sama dengan F1-08l (saran = isian *Buat
   pembelian*, dipesan = semua draf ke lokasi ini, satuan dasar).
3. Barang tanpa draf tidak mendapat baris status (sama seperti sebelumnya,
   tanpa keterangan). Aturan F1-08h lain tetap: hanya untuk staf berizin
   pembelian, teks dibungkus utuh tanpa elipsis.

## Rancangan teknis

- `StockViewModel.shortfallOf(row, mark)` → `Qty` (0 bila cukup), memakai
  `suggestedOf`.
- `_MinimumPanel`: widget status berkunci `stock-min-cover-<varian>`; warna
  hijau sama dengan selisih positif penyesuaian (`_diffColor`).
- l10n baru `stockMinimumDraftEnough`, `stockMinimumDraftShort` (ID + EN).

## Pengujian

- VM: kurang, tepat sama, dan lebih dari saran.
- Widget 1280 / 360 px: satu barang kurang, satu barang cukup; teks utuh.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Tanda cukup / kurang di stok minimum | 1.18 | Rilis v0.131.0 | `shortfallOf`; hijau bila cukup. |
| *Buat pembelian* melewati barang yang sudah cukup di draf | — | Belum | Draf baru tetap berisi semua barang di bawah minimum; *Buka draf* sudah hanya menambah barang yang belum di draf (F1-08i). |
