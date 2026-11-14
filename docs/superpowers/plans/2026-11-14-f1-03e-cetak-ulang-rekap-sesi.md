# Rencana F1-03e — Cetak ulang rekap sesi lama

Spec: [F1-03e](../specs/2026-11-14-f1-03e-cetak-ulang-rekap-sesi-design.md)

- [x] **Tes data** `loadClosedSessionRecap` (isi rekap, kode perangkat,
      penutup, `changedSinceClose` setelah void, sesi buka / cabang lain /
      tanpa izin ditolak) dan `CashSessionLine.id`; lalu implementasi.
- [x] **Tes isi rekap** cetak ulang (*Dicetak ulang*, catatan berubah) dan
      `SessionRecap.fromClosed`; lalu implementasi + l10n.
- [x] **Tes VM dialog** `SessionRecapDialogViewModel` (muat, cetak, galat
      printer, PDF, galat muat) + repositori `loadSessionRecap`; lalu
      implementasi.
- [x] **Tes widget** Kas & sesi (baris tertutup bisa diketuk, buka tidak;
      dialog 1280/360); lalu UI dan router.
- [x] **Review** subagent baru; perbaiki Critical/Important.
      Hasil: 0 Critical, 2 Important (view model dibuat ulang saat builder
      dialog dipanggil ulang; notifikasi setelah dispose) diperbaiki:
      view model milik State dialog + penjaga `_disposed`; juga `canPrint`
      butuh pengaturan struk, jam disuntikkan untuk *Dicetak ulang*, tes
      catatan berubah di dialog.
- [x] **Uji manual Xvfb**: Laporan › Kas & sesi › ketuk sesi tertutup,
      pratinjau, *Bagikan PDF*.
      Hasil: tabel 5 sesi (4 tertutup berikon printer, sesi buka tanpa
      ikon); dialog sesi 03/11 menampilkan Perangkat K01, Ditutup oleh,
      *Reprinted*, rincian cocok dengan seharusnya 728.403 (tanpa catatan
      berubah); *Bagikan PDF* menyimpan `Struk/rekap-sesi-261113-1943.pdf`
      dan isinya benar.
- [x] **Dokumen**: spec F1-03b / F1-03e, README, STATUS-JEDA, panduan,
      CHANGELOG 0.84.0, versi 0.84.0+87.
- [ ] **PR, merge, cek rilis.**
