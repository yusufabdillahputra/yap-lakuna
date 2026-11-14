# Rencana F1-13d — Cari nomor HP dengan format apa pun

Spec: [F1-13d](../specs/2026-11-14-f1-13d-cari-hp-format-design.md)

- [x] **Tes domain** `phoneSearchKeys` / `phoneMatchesQuery` (gagal dulu);
      lalu implementasi.
- [x] **Tes data** Riwayat `+62 812-3456` (gagal dulu); lalu `_searchSales`.
- [x] **Tes VM** Pelanggan, Supplier, Kasir (pilih + Kredit), Meja (gagal
      dulu); lalu pakai `phoneMatchesQuery`.
- [x] **Review** subagent baru; perbaiki Critical/Important.
      Diperbaiki: salinan WhatsApp (tanda arah, tanda hubung Unicode) dan
      kunci `62…` mentah untuk `+62…` (cocok palsu di tengah nomor).
- [x] **Uji manual Xvfb**: Riwayat dan pilih pelanggan Kasir dengan `+62`.
      Hasil: Pelanggan `+62 813-2222` → Toko Bu Ani; Riwayat
      `+62 813-2222-1010` → 5 nota Toko Bu Ani lintas tanggal.
- [x] **Dokumen**: spec F1-11b / F1-13, README, STATUS-JEDA, panduan,
      CHANGELOG 0.77.0, versi 0.77.0+80.
- [ ] **PR, merge, cek rilis.**
