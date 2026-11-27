# F1-19f · Backup dan PDF besar di isolate terpisah

- **Fase:** 1
- **Status:** Rilis v0.158.0
- **Layar:** Data & backup (1.13), Label barcode (1.15b), Stok (1.18),
  Laporan (1.23 / 1.24), rincian pembelian (1.19b).
- **Acuan:** gap 21 di `GAP-FASE1.md`: [F1-07e](2026-11-13-f1-07e-label-barcode-design.md)
  *PDF ribuan label tanpa membekukan layar*,
  [F1-08b](2026-11-14-f1-08b-cetak-stok-design.md) *PDF ribuan baris di
  isolate terpisah*, [F1-19d](2026-11-14-f1-19d-backup-otomatis-design.md)
  *Backup di isolate terpisah*. Storeku (Rust) tidak punya masalah ini:
  pekerjaan berat di sana berjalan di thread latar.

## Masalah

Flutter menggambar layar di isolate utama. Tiga pekerjaan berat berjalan di
isolate itu:

1. PDF label barcode (sampai 2.000 label) dibuat dan disimpan sekaligus.
2. PDF tabel (*Cetak stok*, *Stok minimum*, ekspor PDF Laporan, cetak
   pembelian). Daftar stok toko besar ribuan baris.
3. Zip backup (*Backup sekarang* dan backup otomatis tiap 6–24 jam):
   SHA-256 database, lalu memampatkan database dan semua gambar, termasuk
   enkripsi AES bila dikunci.

Selama pekerjaan itu putaran progres berhenti dan klik tidak ditanggapi;
untuk backup otomatis, kasir bisa merasakan layar macet sesaat di tengah
transaksi.

## Aturan

1. PDF label, PDF tabel, SHA-256 dan zip backup dibuat di isolate terpisah
   (`Isolate.run`). Hasil (berkas, isi PDF, manifest) sama persis dengan
   sebelumnya.
2. Yang tetap di isolate utama: membaca aset font (aset hanya bisa dibaca
   di sana), memformat rupiah (memakai terjemahan aktif), `VACUUM INTO`
   dan hitungan nota/produk (koneksi database milik isolate utama).
3. Galat di isolate (disk penuh, berkas tak terbaca) diteruskan apa
   adanya; berkas setengah jadi tetap dihapus seperti sebelumnya.

## Rancangan teknis

- `lib/data/services/pdf_fonts.dart`: `loadPdfFontBytes()` (tiga
  `ByteData`) dan `pdfFonts(bytes)` (`pw.Font`).
- `buildBarcodeLabelPdf`: font dimuat, lalu `_labelPdfInIsolate` →
  `Isolate.run(() => _labelDocument(...).save())`.
  `barcodeLabelPdfDocument` (untuk tes jumlah halaman) memakai inti yang
  sama di isolate ini.
- `reportPdf`: semua sel `XlsxNumber` diformat lebih dulu menjadi
  `Map<int, String>`, lalu `_reportPdfInIsolate`.
- `lakuna_data` `createBackup`: `_sha256InIsolate(path)` dan
  `_writeZipInIsolate(outPath, manifest, entries, zipPassword, comment)`.
- Closure `Isolate.run` dibuat di fungsi tingkat atas yang hanya menerima
  argumen yang bisa dikirim (teks, daftar, rekaman, `ByteData`), bukan di
  dalam fungsi yang memegang `LakunaStore` atau `BuildContext`.

## Tes

- Pembantu `measureMainIsolateStall`: timer 5 ms di isolate utama; jeda
  terlama harus < 50% lama pekerjaan.
- PDF tabel 3.000 baris, 2.000 label A4, backup dengan gambar acak 64 MB.
  Ketiganya gagal sebelum perubahan (jeda ≈ seluruh durasi).
- Galat menulis zip di isolate (tujuan berupa folder) sampai sebagai
  `FileSystemException`.
- Tes widget yang memicu PDF sungguhan memakai `tapAndWaitForIsolate`
  (`runAsync`, tunggu sampai berkas tercatat).
- Tes lama (isi manifest, backup terkunci, jumlah halaman, PDF 800 baris,
  alur cetak stok dengan `runAsync`) tetap lulus.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| PDF label & tabel di isolate terpisah | — | Rilis v0.158.0 | — |
| Zip backup di isolate terpisah | — | Rilis v0.158.0 | Manual dan otomatis. |
| `VACUUM INTO` di isolate terpisah | — | Belum | Koneksi SQLite milik isolate utama; salinan database biasanya cepat dibanding zip. |
| Periksa & ekstrak berkas pulihkan di isolate | — | Belum | Jarang (sekali saat pulihkan) dan dialog progres sudah tampil; sama dengan sebelumnya. |
| Struk/kuitansi PDF di isolate | — | Tidak perlu | Satu nota, cepat. |
