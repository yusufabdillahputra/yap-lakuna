# Rencana F1-13f · Garis miring di pencarian nomor HP

Spec: [F1-13f](../specs/2026-11-15-f1-13f-garis-miring-hp-design.md).

- [x] 1. Tes gagal dulu: domain (`customer_test.dart`), data Riwayat,
  view model Pelanggan.
- [x] 2. `_phoneQueryPattern` menerima `/`; U+2215/U+FF0F dianggap `/`.
- [x] 3. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 4. Review subagent; temuan diperbaiki (Important: draf *Pelanggan baru* dari kata pencarian belum mengenal `/`; Minor: tes cocok palsu `+62/813`, catatan tanggal/pecahan, gap garis miring Unicode lain).
- [x] 5. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-13f/`.
- [x] 6. Dokumen: spec, gap F1-13d, README spec, STATUS-JEDA, panduan,
  CHANGELOG, versi.
- [ ] 7. PR, CI hijau, squash-merge, rilis.
