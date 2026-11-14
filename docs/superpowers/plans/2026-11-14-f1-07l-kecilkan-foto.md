# Rencana F1-07l — Kecilkan foto produk dan foto faktur

Spec: [F1-07l](../specs/2026-11-14-f1-07l-kecilkan-foto-design.md).

**Tujuan:** foto besar (sampai 20 MB) dikecilkan otomatis ke 1.024 px
(produk) / 2.000 px (faktur) sebelum disimpan.

## Langkah

- [x] **Domain** — batas pilih dan sisi maksimum di `ProductLimits` /
  `PurchaseLimits`.
- [x] **Data: shrink** — tambah dependensi `image`; tes `shrinkPhoto`
  (besar → JPEG ≤ batas, alpha → PNG, EXIF orientasi, kecil tetap, rusak
  → null) lalu implementasi di isolate.
- [x] **Data: pakai** — tes foto produk 3.000 px dan foto faktur (draf,
  terima, ganti) tersimpan kecil, berkas > 20 MB ditolak; lalu
  `setProductPhoto`, `savePurchaseDraft`, `receivePurchase`,
  `setPurchaseInvoicePhoto`.
- [x] **Flutter** — VM produk dan pembelian memakai batas pilih; palsu
  repositori; teks petunjuk/galat (id/en); tes VM.
- [x] **Review** subagent baru; perbaiki Critical/Important (batas 50 MP,
  bingkai pertama animasi, galat isolate, gambar tipis, PNG besar → JPEG,
  izin sebelum dekode).
- [x] **Uji manual Xvfb**: foto produk besar, cek ukuran di `media/`.
- [x] **Dokumen**: spec F1-07f/F1-12b (gap), README, STATUS-JEDA, panduan
  produk & pembelian id/en, CHANGELOG 0.62.0, pubspec `0.62.0+65`.
- [x] **PR, merge, cek rilis.**
