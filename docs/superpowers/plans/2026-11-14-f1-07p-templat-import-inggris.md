# Rencana F1-07p — Templat import berbahasa Inggris

Spec: [F1-07p](../specs/2026-11-14-f1-07p-templat-import-inggris-design.md)

- [x] **Tes domain** templat EN terbaca utuh dan contoh EN dilewati; lalu
      templat EN dan pemeriksaan contoh kedua bahasa.
- [x] **Tes Flutter** `.xlsx` EN terbaca kembali, kolom teks EN, tombol
      memilih templat sesuai bahasa; lalu implementasi.
- [x] **Review** subagent baru; perbaiki Critical/Important.
      Hasil: 0 Critical, 0 Important. Minor diikuti: SKU contoh EN
      (`SMP-…`), teks pengantar dialog EN memakai judul templat
      (*Credit limit*, *Sell price*, *Cost price*, *Term (days)*).
- [x] **Uji manual Xvfb**: aplikasi English, unduh templat, import.
      Hasil: *Download template* di Supplier menyimpan
      `import-template-suppliers.xlsx` (lembar *Suppliers*, judul Name …
      Note, contoh *Sample Fresh Foods Ltd*); berkas itu dipilih kembali:
      0 baris siap, 2 baris dilewati *sample row from the template*.
- [x] **Dokumen**: spec F1-07g / F1-07p, README, STATUS-JEDA, panduan,
      CHANGELOG 0.85.0, versi 0.85.0+88.
- [x] **PR, merge, cek rilis.** PR #91 di-merge (13 cek hijau).
