# Rencana F1-14b · Import supplier dari Excel/CSV (v0.45.0)

Spec: [F1-14b](../specs/2026-11-14-f1-14b-import-supplier-design.md).

## Langkah

- [x] Domain (TDD, `supplier_import_test.dart`): `supplierImportRows`,
      `parseImportTermDays`, alasan tolak, nama ganda tanpa beda huruf.
- [x] Data (TDD, `suppliers_test.dart` grup *import*): `importSuppliers` —
      buat/perbarui per nama, kolom kosong dipertahankan, tempo bawaan,
      supplier terhapus, validasi ulang, izin, outbox.
- [x] Repositori `importRows` (lokal + palsu) dan tes repositori lokal.
- [x] `SupplierImportViewModel`, `supplier_import_dialog.dart`, tombol
      *Import Excel* di layar Supplier, `tablePicker` di router.
- [x] l10n ID/EN, tes VM + widget 1280/360 px.
- [x] Uji manual Xvfb dengan berkas CSV (pratinjau, baris dilewati,
      ringkasan, data diperbarui).
- [x] Panduan ID/EN, spec F1-14/F1-14b/README/STATUS-JEDA, CHANGELOG,
      versi 0.45.0+48.
- [x] Review subagent, perbaiki temuan (daftar tidak dimuat ulang bila
      dialog ditutup lewat latar — juga di import pelanggan/produk; jumlah
      baris dilewati di ringkasan; import ulang tanpa perubahan tidak
      menulis; alias judul telepon; tes tambahan).
- [ ] PR #51: CI, merge, cek rilis.
