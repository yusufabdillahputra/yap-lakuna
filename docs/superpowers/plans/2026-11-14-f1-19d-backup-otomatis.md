# Rencana F1-19d — Backup otomatis harian (desktop)

Spec: [F1-19d](../specs/2026-11-14-f1-19d-backup-otomatis-design.md)

- [x] **Tes repositori** `autoBackup` / `setAutoBackup` / `runAutoBackup`
      (pangkas 7, tanpa staf, catat waktu, gagal); lalu implementasi.
- [x] **Tes penjadwal** `AutoBackupScheduler`; lalu implementasi dan
      pemasangan di `bootstrap.dart`.
- [x] **Tes VM + widget** *Data & backup* 1280/360; lalu UI dan l10n.
- [x] **Review** subagent baru; perbaiki Critical/Important.
- [x] **Uji manual Xvfb**: sakelar, backup otomatis terbuat di folder.
      Hasil: dua menit setelah aplikasi dibuka (masih di layar PIN)
      `Backup/Otomatis/lakuna-backup-PST-261114-2113.zip` terbuat (7 entri,
      tanpa `.part`); Beranda *Backup terakhir hari ini*; kartu *Backup
      otomatis* tampil dengan lokasi folder; sakelar mati/nyala tersimpan.
- [x] **Dokumen**: spec F1-19 / F1-19c, README, STATUS-JEDA, panduan,
      CHANGELOG 0.75.0, versi 0.75.0+78.
- [x] **PR, merge, cek rilis.** PR #81 di-merge (13 cek hijau).
