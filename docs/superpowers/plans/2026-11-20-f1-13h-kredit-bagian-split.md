# Rencana F1-13h — Kredit bagian terakhir split bill

Spec: [F1-13h](../specs/2026-11-20-f1-13h-kredit-bagian-split-design.md)

- [ ] 1. Data: tes kredit bagian terakhir (rata, per item, nominal), penolakan, F1-13b tetap; lalu `paySplitPart(credit:)` dan `_completeBill(credited:)`.
- [ ] 2. Repositori: `payBillPart(credit:)` + izin; fake.
- [ ] 3. VM + layar Bayar: tes `canSellOnCredit` bagian terakhir dan bayar kredit; lalu implementasi.
- [ ] 4. Tes alur widget split → Kredit → struk.
- [ ] 5. Uji mutasi, review subagen, perbaiki temuan.
- [ ] 6. Uji manual Xvfb dan tangkapan layar.
- [ ] 7. Dokumen (spec F1-13 / F1-13b / F1-10, README, STATUS-JEDA, panduan), CHANGELOG, versi 0.134.0+137.
- [ ] 8. PR, CI hijau, squash-merge, rilis.
