# Rencana F1-07u · Ekspor pratinjau import harga ke Excel

Spec: `docs/superpowers/specs/2026-11-27-f1-07u-ekspor-pratinjau-harga-design.md`

- [x] 1. Tes gagal dulu: VM ekspor (nama berkas, lokasi, galat, dihapus
  saat pratinjau berubah) dan isi Excel dibaca kembali.
- [x] 2. VM `export` / `canExport` / `exportFileName`;
  `productImportPreviewWorkbook`; l10n ID/EN.
- [x] 3. Tombol *Unduh Excel* di kartu pratinjau + pesan simpan/gagal; tes
  widget desktop dan 360 px.
- [x] 4. Dokumen: spec F1-07m gap, README specs, STATUS-JEDA, GAP-FASE1,
  panduan ID/EN Produk, CHANGELOG, pubspec.
- [x] 5. Format, analyze, semua tes, review subagent (temuan: tes > 30
  perubahan, ekspor lama setelah ganti berkas, nama berkas), uji Xvfb.
- [ ] 6. PR dan rilis.
