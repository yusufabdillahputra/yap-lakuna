# Rencana F1-16g — Umur piutang/hutang per pelanggan dan supplier

Spec: `docs/superpowers/specs/2026-11-27-f1-16g-umur-per-nama-design.md`.

- [x] 1. Tes data (umur per pelanggan/supplier, baris = sisa, kolom =
      umur total), lalu `DebtReport.customerAging` / `supplierAging`.
- [x] 2. Tes label ekspor dan PDF mendatar, lalu `reportTable` debts dan
      `ReportTable.landscape`.
- [x] 3. Tes widget (tabel 1024–1440 px, kartu 360/800 px), lalu kolom
      di `_Debts`.
- [x] 4. Spec F1-16c/README/STATUS-JEDA/GAP-FASE1, panduan reports ID/EN,
      CHANGELOG, versi 0.147.0+150.
- [x] 5. Format, analyze, semua tes, review subagent, uji Xvfb.
- [ ] 6. PR dan rilis.
