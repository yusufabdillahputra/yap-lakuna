# Rencana F1-03e — Cetak ulang rekap sesi lama

Spec: [F1-03e](../specs/2026-11-14-f1-03e-cetak-ulang-rekap-sesi-design.md)

- [ ] **Tes data** `loadClosedSessionRecap` (isi rekap, kode perangkat,
      penutup, `changedSinceClose` setelah void, sesi buka / cabang lain /
      tanpa izin ditolak) dan `CashSessionLine.id`; lalu implementasi.
- [ ] **Tes isi rekap** cetak ulang (*Dicetak ulang*, catatan berubah) dan
      `SessionRecap.fromClosed`; lalu implementasi + l10n.
- [ ] **Tes VM dialog** `SessionRecapDialogViewModel` (muat, cetak, galat
      printer, PDF, galat muat) + repositori `loadSessionRecap`; lalu
      implementasi.
- [ ] **Tes widget** Kas & sesi (baris tertutup bisa diketuk, buka tidak;
      dialog 1280/360); lalu UI dan router.
- [ ] **Review** subagent baru; perbaiki Critical/Important.
- [ ] **Uji manual Xvfb**: Laporan › Kas & sesi › ketuk sesi tertutup,
      pratinjau, *Bagikan PDF*.
- [ ] **Dokumen**: spec F1-03b / F1-03e, README, STATUS-JEDA, panduan,
      CHANGELOG 0.84.0, versi 0.84.0+87.
- [ ] **PR, merge, cek rilis.**
