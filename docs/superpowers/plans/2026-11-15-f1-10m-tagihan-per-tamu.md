# Rencana F1-10m · Tagihan per tamu split bill

Spec: [F1-10m](../specs/2026-11-15-f1-10m-tagihan-per-tamu-design.md).
Rilis: v0.102.0+105.

- [x] 1. Tes gagal dulu: `guestBillReceiptContent` (unit).
- [x] 2. `_chargeLines` + `guestBillReceiptContent`, l10n ID/EN.
- [x] 3. `BillPrintJob` + refaktor `DiningViewModel` (tes Meja tetap lulus).
- [x] 4. `SplitBillData` dengan konteks struk (repo lokal + palsu).
- [x] 5. Tes VM split gagal dulu, lalu `canPrintPart` + `partPrint`.
- [x] 6. `showBillPrintDialog` bersama, tombol kartu tamu, router.
- [x] 7. Tes widget split 1280/360.
- [x] 8. Format, analyze, semua tes.
- [x] 9. Review subagent; Critical/Important/Minor diperbaiki.
- [x] 10. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-10m/`.
- [x] 11. Dokumen: spec, gap F1-10k, README spec, STATUS-JEDA, panduan
  meja ID/EN, CHANGELOG, versi.
- [ ] 12. PR, CI hijau, squash-merge, rilis.
