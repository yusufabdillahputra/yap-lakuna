# Rencana F1-04h — Bagi baris berdiskon rupiah per tamu

Spec: [F1-04h](../specs/2026-11-14-f1-04h-bagi-diskon-rupiah-design.md).

**Tujuan:** baris bill berdiskon rupiah bisa dibagi ke tamu; potongan
dibagi sebanding jumlah porsi.

## Langkah

- [x] **Tes data** bagi rupiah (genap, ganjil, 100%, gabung, batal split,
  bayar bagian, nota akhir); lalu `_moveQuantity`.
- [x] **Bersihkan** `BillItemDiscounted` dan kunci l10n; tes Flutter.
- [x] **Review** subagent baru; perbaiki Critical/Important.
- [x] **Uji manual Xvfb**: split per item bill berdiskon rupiah.
- [x] **Dokumen**: spec F1-04g (gap), README, STATUS-JEDA, panduan diskon
  id/en, CHANGELOG 0.65.0, pubspec `0.65.0+68`.
- [ ] **PR, merge, cek rilis.**
