# Rencana F1-08l · Jumlah di draf dibandingkan saran stok minimum

Spec: [F1-08l](../specs/2026-11-15-f1-08l-jumlah-di-draf-design.md).

- [x] 1. Tes gagal dulu: data `RestockDraft.quantities`, VM `draftMarkOf`,
  widget teks *dipesan dari saran*.
- [x] 2. `restockDraftsOf` mengisi jumlah; fake repo; VM; tampilan + l10n.
- [x] 3. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 4. Review subagent; tanpa Critical/Important; Minor diperbaiki (dua baris sama dijumlah, tes dua draf di 360 px, `draftNumberOf` dihapus, `suggestedOf` bersama).
- [x] 5. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-08l/`.
- [x] 6. Dokumen: spec, gap F1-08h, README spec, STATUS-JEDA, panduan,
  CHANGELOG, versi.
- [ ] 7. PR, CI hijau, squash-merge, rilis.
