# Status: titik lanjut pengembangan

Pengembangan sempat dijeda pada 2026-11-04 dan **dilanjutkan lagi pada
2026-11-13** atas permintaan pemilik. Dokumen ini mencatat titik terakhir
agar pekerjaan bisa dilanjutkan tanpa menelusuri ulang riwayat.

## Rilis terakhir

| Versi | Isi | PR |
| --- | --- | --- |
| v0.29.0 | Pelanggan di Kasir, nota tersimpan (F1-04d) | #34 |
| v0.29.1 | Orientasi EXIF foto ponsel (QRIS) | #35 |
| v0.30.0 | Kredit saat *Tutup & bayar* open bill F&B (F1-13b) | #36 |
| v0.31.0 | Import produk dari Excel/CSV (F1-07b) | #37 |
| v0.32.0 | Diskon nota di open bill F&B (F1-04e) | #38 |
| v0.33.0 | Pelanggan baru dari Kasir (F1-04f) | #39 |
| v0.34.0 | Harga grosir per grup pelanggan (F1-07c) | #40 |
| v0.35.0 | Arsip produk (F1-07d) | #41 |
| v0.36.0 | Cetak label barcode (F1-07e) | #42 |
| v0.37.0 | Foto produk (F1-07f) | #43 |
| v0.38.0 | Cetak rekap sesi kasir (F1-03b) | #44 |
| v0.39.0 | Logo di struk (F1-06b) | #45 |
| v0.40.0 | Gabung meja (F1-10d) | #46 |
| v0.41.0 | Printer dapur terpisah (F1-10e) | #47 |
| v0.42.0 | Pelanggan & harga grup di open bill (F1-10f) | #48 |
| v0.43.0 | Kirim ke tiket dapur & catatan per menu (F1-10g) | #49 |
| v0.44.0 | Batal pembayaran piutang & hutang (F1-13c) | #50 |
| v0.45.0 | Import supplier dari Excel/CSV (F1-14b) | #51 |
| v0.46.0 | Pulihkan backup dari onboarding (F1-19b) | #52 |
| v0.47.0 | Templat import produk, pelanggan, supplier (F1-07g) | #53 |
| v0.48.0 | Cetak stok per lokasi (F1-08b) | #54 |
| v0.49.0 | Buat pembelian dari stok minimum (F1-08c) | #55 |
| v0.50.0 | Foto faktur pembelian (F1-12b) | #56 |
| v0.51.0 | PDF pembelian + tautan kartu stok (F1-12c) | #57 |

Semua modul Fase 1 di `specs/README.md` sudah dirilis. Yang tersisa adalah
gap per modul (tabel **Status & gap** di tiap spec, cari `| Belum |`).

## Gap Fase 1 yang paling berguna untuk dilanjutkan

1. ~~Diskon di open bill / split bill F&B~~ — selesai v0.32.0 (F1-04e);
   diskon per baris di bill masih gap.
2. **Kredit per bagian split bill** — spec F1-13b. Butuh pelanggan per
   bagian tamu dan dokumen piutang per bagian, karena saat ini piutang
   melekat pada satu nota dengan satu pelanggan. Perlu desain model data
   sendiri (tabel baru + alokasi pembayaran piutang).
3. ~~Harga grosir per grup pelanggan~~ — selesai v0.34.0 (F1-07c);
   harga grup di open bill F&B selesai v0.42.0 (F1-10f).
4. ~~*Pelanggan baru* dari pemilih pelanggan Kasir~~ — selesai v0.33.0
   (F1-04f).
5. ~~Foto produk~~ — selesai v0.37.0 (F1-07f); kecilkan foto ke WebP
   masih gap.
6. ~~Logo di struk~~ — selesai v0.39.0 (F1-06b); cetak rekap sesi
   selesai v0.38.0 (F1-03b).
7. ~~Gabung meja~~ — selesai v0.40.0 (F1-10d). ~~Printer dapur
   terpisah~~ — selesai v0.41.0 (F1-10e); printer per stasiun (bar vs
   dapur) masih gap. ~~Sakelar *Kirim ke tiket dapur* / *Catatan bebas*
   per menu~~ — selesai v0.43.0 (F1-10g).
8. ~~Batal pembayaran piutang & hutang~~ — selesai v0.44.0 (F1-13c);
   ubah pembayaran tanpa batal tetap tidak didukung (batal lalu catat ulang).
9. ~~Import supplier dari Excel/CSV~~ — selesai v0.45.0 (F1-14b);
   templat berkas untuk diunduh selesai v0.47.0 (F1-07g).
10. ~~Pulihkan dari onboarding~~ — selesai v0.46.0 (F1-19b); enkripsi
   backup masih gap.
11. ~~Cetak stok~~ — selesai v0.48.0 (F1-08b). ~~Buat pembelian dari
   daftar stok minimum~~ — selesai v0.49.0 (F1-08c).
12. ~~Foto faktur pembelian~~ — selesai v0.50.0 (F1-12b). ~~PDF pembelian
   dan tautan kartu stok~~ — selesai v0.51.0 (F1-12c).

Beberapa baris `Belum` di spec lama sudah selesai di modul lain (mis.
persetujuan PIN manajer di F1-04b, cetak ulang dari riwayat di F1-11,
kredit di F1-13, data & backup di F1-19). Rapikan saat menyentuh modulnya.

## Menunggu pemilik

- Secret penandatanganan Android (keystore) untuk rilis Play Store; sampai
  ada, APK/AAB dibangun sebagai build uji.
- Akun Apple untuk `.ipa` bertanda tangan.

## Cara melanjutkan

Baca `CLAUDE.md`, lalu pilih satu gap di atas dan ikuti alur Superpowers
(spec → rencana → TDD → review → uji manual → rilis). Cabang kerja:
`claude/project-thread-a2lk7x` (mulai ulang dari `origin/main` setelah
setiap squash-merge).
