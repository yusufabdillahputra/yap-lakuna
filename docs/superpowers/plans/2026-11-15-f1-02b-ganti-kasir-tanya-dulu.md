# Rencana F1-02b · *Ganti kasir* bertanya dulu bila form belum disimpan

Spec: [F1-02b](../specs/2026-11-15-f1-02b-ganti-kasir-tanya-dulu-design.md).

- [x] 1. Tes gagal dulu: unit `LeaveGuards.canLeaveAll`, widget ganti
  kasir dari form pembelian / produk / pengeluaran.
- [x] 2. `LeaveGuards.canLeaveAll`, `AppShell.canSwitch`, sambungan di
  router.
- [x] 3. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 4. Review subagent; temuan diperbaiki (Minor: spec disesuaikan dengan kode, tes ketukan kedua tegas, tes Produk; dua celah kecil dicatat sebagai gap).
- [x] 5. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-02b/`.
- [x] 6. Dokumen: spec, gap F1-12f, spec F1-02, README spec, STATUS-JEDA,
  panduan, CHANGELOG, versi.
- [ ] 7. PR, CI hijau, squash-merge, rilis.
