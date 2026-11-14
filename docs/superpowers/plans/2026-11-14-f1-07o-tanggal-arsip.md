# Rencana F1-07o — Tanggal arsip di dialog *Produk diarsipkan*

Spec: [F1-07o](../specs/2026-11-14-f1-07o-tanggal-arsip-design.md)

- [x] **Tes VM + widget** (gagal dulu: tanpa zona, tanpa tanggal); lalu
      `ArchivedCatalog`, VM, dialog, l10n.
- [x] **Perbaikan tata letak ponsel** dialog (baris terlipat per huruf,
      overflow) dengan tes tinggi baris.
- [x] **Review** subagent baru; perbaiki Critical/Important.
      Tanpa temuan Critical/Important; minor: tes posisi tombol di ponsel,
      konstanta lebar.
- [x] **Uji manual Xvfb**: arsipkan produk, buka *Diarsipkan*.
      Hasil: Keripik Singkong → *Camilan · Stock 0.5 bungkus · Archived
      November 14, 2026*; *Pulihkan* mengembalikan produk.
- [x] **Dokumen**: spec F1-07d, README, STATUS-JEDA, panduan, CHANGELOG
      0.78.0, versi 0.78.0+81.
- [x] **PR, merge, cek rilis.** PR #84 di-merge (13 cek hijau).
