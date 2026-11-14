# Rencana F1-05c — Rekening transfer di tombol bayar

Spec: [F1-05c](../specs/2026-11-14-f1-05c-rekening-transfer-design.md)

- [x] **Tes domain** `SalesRules.transferAccount` (JSON, pangkas, `==`);
      lalu implementasi.
- [x] **Tes data** simpan/muat/pangkas/tolak 101 karakter; lalu
      `saveSalesRules`.
- [x] **Tes VM + widget** Pengaturan dan layar bayar (1280/360,
      clipboard); lalu UI dan l10n.
- [x] **Review** subagent baru; perbaiki Critical/Important.
- [x] **Uji manual Xvfb**: isi rekening, bayar transfer di Kasir.
- [x] **Dokumen**: spec F1-05 dan F1-18, README, STATUS-JEDA, panduan,
      CHANGELOG 0.74.0, versi 0.74.0+77.
- [x] **PR, merge, cek rilis.**
