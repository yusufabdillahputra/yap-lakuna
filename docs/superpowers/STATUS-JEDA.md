# Status: pengembangan dijeda (2026-11-04)

Pemilik meminta pengembangan Lakuna dijeda setelah pekerjaan yang sedang
berjalan selesai. Dokumen ini mencatat titik berhenti agar pekerjaan bisa
dilanjutkan tanpa menelusuri ulang riwayat.

## Rilis terakhir

| Versi | Isi | PR |
| --- | --- | --- |
| v0.29.0 | Pelanggan di Kasir, nota tersimpan (F1-04d) | #34 |
| v0.29.1 | Orientasi EXIF foto ponsel (QRIS) | #35 |
| v0.30.0 | Kredit saat *Tutup & bayar* open bill F&B (F1-13b) | #36 |
| v0.31.0 | Import produk dari Excel/CSV (F1-07b) | #37 |

Semua modul Fase 1 di `specs/README.md` sudah dirilis. Yang tersisa adalah
gap per modul (tabel **Status & gap** di tiap spec, cari `| Belum |`).

## Gap Fase 1 yang paling berguna untuk dilanjutkan

1. **Diskon di open bill / split bill F&B** — spec F1-04b.
2. **Kredit per bagian split bill** — spec F1-13b (butuh pelanggan per
   bagian tamu).
3. **Harga grosir per grup pelanggan** — spec F1-13 / F1-04d.
4. ***Pelanggan baru* dari pemilih pelanggan Kasir** — spec F1-04d.
5. **Arsip produk, cetak label barcode, foto produk** — spec F1-07.
6. **Cetak rekap sesi, logo di struk** — spec F1-06.
7. **Gabung meja, printer dapur terpisah** — spec F1-10.

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
