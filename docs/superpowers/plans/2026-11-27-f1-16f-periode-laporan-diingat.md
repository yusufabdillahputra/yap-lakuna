# Rencana F1-16f — Periode laporan terakhir diingat

Spec: `docs/superpowers/specs/2026-11-27-f1-16f-periode-laporan-diingat-design.md`.

- [x] 1. Tes domain (JSON bolak-balik, data rusak, `restorable`), lalu
      `ReportPeriod.toJson` / `fromJson` / `restorable`.
- [x] 2. Tes repositori lokal, lalu `savedPeriod` / `savePeriod` dengan
      `LocalPreferences`; versi palsu; sambungan di `bootstrap.dart`.
- [x] 3. Tes VM (dipulihkan, tidak berlaku, simpan, balapan pilih), lalu
      `ReportsViewModel._load` / `setPeriod`; tes widget.
- [x] 4. Spec F1-16b/README/STATUS-JEDA/GAP-FASE1, panduan reports ID/EN,
      CHANGELOG, versi 0.146.0+149.
- [x] 5. Format, analyze, semua tes, review subagent, uji Xvfb.
- [ ] 6. PR dan rilis.
