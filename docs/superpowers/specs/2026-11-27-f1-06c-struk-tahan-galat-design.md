# F1-06c — Kasir tetap terbuka bila pengaturan struk gagal dibaca

Lanjutan F1-06 (struk dan printer). Gap 6 di `docs/superpowers/GAP-FASE1.md`,
dua baris `Belum` di tabel *Status & gap* spec F1-06:

- *Kasir tetap terbuka bila pengaturan struk gagal dibaca* (usulan: jatuh ke
  bawaan + log).
- *Log galat cetak non-printer (PlatformException)* (usulan: catat ke log
  diagnostik).

Spec Storeku tidak mengatur ini; aturan di bawah diputuskan di sini.

## Masalah

- `loadReceiptConfig` dipanggil saat memuat Kasir, Meja, Riwayat, dan
  Pelanggan. Id logo yang rusak di JSON (`UuidValue.fromString` tidak
  memeriksa isi) membuat query SQLite gagal (`unrecognized token`), dan
  berkas logo yang ada tetapi tidak bisa dibaca melempar
  `FileSystemException`. Dua-duanya membuat seluruh layar gagal dimuat,
  padahal struk hanya dipakai setelah bayar. Hal yang sama berlaku untuk
  id dan berkas gambar QRIS di Kasir. (JSON salah bentuk sudah aman:
  `fromJson` memeriksa tiap tipe.)
- Galat cetak yang bukan `PrinterFailure` (mis. `PlatformException` dari
  plugin Bluetooth atau dialog cetak) hanya menampilkan *Struk gagal
  dicetak* tanpa jejak apa pun, sehingga sulit dilacak.

## Aturan

- **Pengaturan struk rusak** (`settings` `receipt` tidak bisa didekode,
  apa pun galatnya): pakai `ReceiptSettings` bawaan, dan galat dicatat.
- **Id media rusak** di JSON pengaturan struk atau QRIS: diabaikan (tanpa
  logo / tanpa gambar), isian lain tetap. `UuidValue.fromString` tidak
  memeriksa isi, dan id rusak membuat query SQLite gagal.
- **Logo struk tidak bisa dibaca:** struk tanpa logo, pengaturan lain tetap
  dipakai, dan galat dicatat. **Gambar QRIS tidak bisa dibaca:** QRIS
  tidak siap dipakai di Kasir, galat dicatat.
- Bila semuanya gagal, `ReceiptConfig` bawaan tidak punya header cabang
  dan rekening transfer (keduanya ikut gagal dimuat).
- **Galat lain saat memuat konfigurasi struk** di layar yang hanya
  memakainya untuk mencetak (Kasir, Meja, Riwayat, Pelanggan):
  `ReceiptConfig` bawaan, dan galat dicatat; layar tetap terbuka.
  Pengaturan › Struk & printer tetap menampilkan galat muatnya sendiri,
  karena di sanalah pemilik memperbaiki.
- **Galat cetak non-printer** (`print`, `sharePdf`, `printDocument`,
  `shareDocument` di `PlatformReceiptPrinter`): dicatat (operasi, jenis
  printer, galat, stack) lalu dilempar ulang, sehingga pesan di layar
  tetap *Struk gagal dicetak*. `PrinterFailure` tidak dicatat karena sudah
  punya pesan yang jelas.
- **Log** = `debugPrint` (stdout di desktop, logcat di Android), sama
  seperti galat muat lainnya (`bootstrap.dart`, `app_root.dart`). Log
  diagnostik di dalam aplikasi belum ada; itu di luar lingkup gap ini.

## Tes

- Data: id logo rusak di JSON (isian lain tetap); `loadReceiptConfigOrDefault`
  memberi bawaan dan memanggil `onError` saat store tertutup; id gambar
  QRIS rusak diabaikan. Berkas logo yang tidak bisa dibaca tidak bisa
  dibuat di tes (proses berjalan sebagai root), jadi jalurnya hanya
  ditutup oleh `try` yang sama.
- Flutter: `PlatformReceiptPrinter.print` Bluetooth dengan `write` yang
  melempar `PlatformException` → galat dilempar ulang dan tercatat lewat
  `debugPrint`; `PrinterFailure` tidak dicatat. Repositori kasir lokal
  memuat dengan pengaturan struk rusak dan mencatat galatnya.

## Status & gap

| Bagian | Status | Catatan |
| --- | --- | --- |
| Kasir tetap terbuka bila pengaturan struk gagal dibaca | Rilis v0.142.0 | Kasir, Meja, Riwayat, Pelanggan. |
| Log galat cetak non-printer | Rilis v0.142.0 | `debugPrint`; log di dalam aplikasi belum ada. |
