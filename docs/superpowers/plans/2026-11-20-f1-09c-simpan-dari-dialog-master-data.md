# Rencana F1-09c · Tombol Simpan di dialog Buang perubahan? master data

Spec: [F1-09c](../specs/2026-11-20-f1-09c-simpan-dari-dialog-master-data-design.md).

- [x] 1. Tes gagal dulu: grup F1-09c di `customer_groups_tab_test.dart`,
  `expense_categories_tab_test.dart`, `modifier_groups_tab_test.dart`,
  `dining_tables_tab_test.dart`.
- [x] 2. `_save` menjawab `Future<bool>` di keenam dialog (`runSave` juga),
  `DiscardChangesScope(onSave: _save)`.
- [x] 3. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 4. Review subagent; temuan diperbaiki.
- [x] 5. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-09c/`.
- [x] 6. Dokumen: spec, gap F1-09b, F1-10n, F1-07r, F1-13g, README spec,
  STATUS-JEDA, panduan, CHANGELOG, versi.
- [x] 7. PR, CI hijau, squash-merge, rilis (#132).
