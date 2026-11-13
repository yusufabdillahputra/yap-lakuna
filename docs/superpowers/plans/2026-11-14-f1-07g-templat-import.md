# Rencana F1-07g · Templat berkas import (v0.47.0)

Spec: [F1-07g](../specs/2026-11-14-f1-07g-templat-import-design.md).

## Langkah

- [x] Domain (TDD, `import_template_test.dart`): `productImportTemplate`,
      `customerImportTemplate`, `supplierImportTemplate`; tiap templat
      dibaca pembacanya → 2 baris sah, 0 ditolak, semua judul dikenali
      (`*ImportKnownHeader`).
- [x] `import_template.dart`: `ImportTemplateKind` (nama berkas, lembar,
      isi .xlsx) dan `ImportFileActions` (tombol *Pilih berkas* + *Unduh
      templat*, pesan lokasi / galat di bawahnya).
- [x] Tiga dialog import memakai `ImportFileActions`; `exporter`
      diteruskan router → layar Produk/Pelanggan/Supplier → dialog.
- [x] l10n ID/EN, tes .xlsx bolak-balik (`readTableFile` → pembaca
      import), tes widget 1280/360 px untuk ketiga dialog.
- [x] Uji manual Xvfb: unduh templat supplier, import berkas itu
      (2 baris siap).
- [x] Panduan ID/EN (produk pertama, pelanggan, supplier), spec
      F1-07b/F1-14b/F1-07g/README/STATUS-JEDA, CHANGELOG, versi 0.47.0+50.
- [x] Review subagent, perbaiki temuan (baris contoh dilewati saat import
      dengan alasan `sample`; kolom HP/Telepon/SKU/Barcode berformat
      teks dan angka contoh berupa angka; tangkap semua galat simpan;
      tes galat/share sheet/pelanggan 360 px; spec Komponen). Share sheet
      iPad dicatat sebagai gap.
- [x] Uji manual ulang: unduh templat supplier, ganti satu nama contoh,
      import → 1 baris siap, 1 dilewati sebagai contoh.
- [ ] PR #53: CI, merge, cek rilis.
