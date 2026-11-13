# Rencana F1-03b — Cetak rekap sesi kasir

Spec: `docs/superpowers/specs/2026-11-13-f1-03b-cetak-rekap-sesi-design.md`

- [x] 1. Domain: tes lalu `ReceiptContent.sections`.
- [x] 2. Flutter: tes lalu `sessionRecapContent` (ID + EN); l10n.
- [x] 3. VM: tes lalu printer/kertas saat load, `closedRecap`, cetak otomatis, `printRecap` / `shareRecap`.
- [x] 4. UI: label tombol tutup, tombol di kartu hasil, pesan galat/lokasi PDF; rute; tes widget 1280/360 px.
- [x] 5. Uji manual Xvfb; review subagent.
- [x] 6. CHANGELOG 0.38.0, versi `0.38.0+41`, status spec F1-03/F1-06, README specs, STATUS-JEDA; PR, CI, merge.
