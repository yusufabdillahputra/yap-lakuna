# Rencana F1-12i · Tombol Simpan draf di dialog Buang perubahan? pembelian

Spec: [F1-12i](../specs/2026-11-20-f1-12i-simpan-draf-dari-dialog-pembelian-design.md).

- [x] 1. Tes gagal dulu: grup F1-12i di `purchase_flow_test.dart`, label di
  `confirm_discard_test.dart`.
- [x] 2. `confirmDiscardChanges(saveLabel:)`, kunci l10n
  `purchaseDiscardSaveDraft`, `savePurchaseDraftBeforeLeaving`, `onSave` di
  form samping dan halaman form.
- [x] 3. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 4. Review subagent; temuan diperbaiki (tanpa Critical/Important;
  Minor: isian yang diubah selama simpan ditandai tersimpan lalu hilang,
  tes kasus tepi, gap halaman tertutup dan gulir ke galat dicatat).
- [x] 5. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-12i/`.
- [x] 6. Dokumen: spec, gap F1-12f dan F1-07r, README spec, STATUS-JEDA,
  panduan, CHANGELOG, versi.
- [ ] 7. PR, CI hijau, squash-merge, rilis.
