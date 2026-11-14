# Rencana F1-05d — Rekening transfer di *Bagi beberapa metode*

Spec: [F1-05d](../specs/2026-11-14-f1-05d-rekening-split-payment-design.md)

- [x] **Tes widget** alur kasir 1280/360 (gagal dulu: kotak tidak ada).
- [x] **Implementasi** `SplitPanel` menampilkan `TransferAccountBox`.
- [x] **Review** subagent baru; perbaiki Critical/Important.
- [x] **Uji manual Xvfb**: Kasir › Bayar › Bagi beberapa metode › Transfer.
      Hasil: tunai Rp 2.000 lalu *Bank transfer*: kotak *Transfer ke* berisi
      rekening + *Salin* di antara Nominal dan Referensi; setelah *Tambah
      metode* sisa Rp 0 dan kotak hilang; pembayaran selesai.
- [x] **Dokumen**: spec F1-05c, README, STATUS-JEDA, panduan split payment,
      CHANGELOG 0.76.0, versi 0.76.0+79.
- [x] **PR, merge, cek rilis.** PR #82 di-merge (13 cek hijau).
