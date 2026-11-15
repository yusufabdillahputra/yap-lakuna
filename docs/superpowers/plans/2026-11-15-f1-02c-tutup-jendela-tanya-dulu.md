# Rencana F1-02c · Menutup jendela aplikasi bertanya dulu

Spec: [F1-02c](../specs/2026-11-15-f1-02c-tutup-jendela-tanya-dulu-design.md).

- [x] 1. Tes gagal dulu: `exit_guard_test.dart`, alur pembelian
  (permintaan tutup saat form berubah / tidak berubah).
- [x] 2. `ExitGuard` + bungkus `AppShell` di router; macOS
  `performClose` → kanal `lakuna/window` → `NSApp.terminate`.
- [x] 3. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 4. Review subagent; temuan diperbaiki (Important: ✕ kedua di macOS langsung keluar → kanal `lakuna/window` dari `performClose`; Minor: galat penjaga, dialog terbuka dipakai, jendela kedua Windows dicatat di spec).
- [x] 5. Uji manual Xvfb (tutup jendela Linux) + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-02c/`.
- [x] 6. Dokumen: spec, gap F1-02b, README spec, STATUS-JEDA, panduan,
  CHANGELOG, versi.
- [ ] 7. PR, CI hijau (termasuk build Windows/macOS), squash-merge, rilis.
