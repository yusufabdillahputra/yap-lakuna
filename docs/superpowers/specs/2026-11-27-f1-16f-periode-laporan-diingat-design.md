# F1-16f — Periode laporan terakhir diingat

Tanggal: 2026-11-27 · Modul: F1-16 Laporan (1.23 / 1.24) · Gap 10 di
`docs/superpowers/GAP-FASE1.md`, gap 89 di STATUS-JEDA · Rilis: v0.146.0

## Masalah

F1-16b aturan 7: periode laporan tidak disimpan, sehingga membuka Laporan
lagi selalu kembali ke *Hari ini*. Pemilik yang memeriksa *Bulan ini*
atau rentang gaji *1–15 November* harus memilihnya ulang setiap kali
pindah menu.

## Aturan

1. Periode yang dipilih di Laporan disimpan di **perangkat ini**, per
   cabang. Yang disimpan bisa *Hari ini*, *7 hari terakhir*, *Bulan ini*,
   satu bulan kalender, atau rentang tanggal bebas. Membuka Laporan lagi,
   termasuk setelah aplikasi ditutup, memakai periode itu.
2. Periode relatif tetap relatif. *Bulan ini* yang disimpan bulan lalu
   menjadi bulan berjalan saat dibuka lagi, dan *Hari ini* tetap hari
   ini.
3. Bila periode yang disimpan tidak berlaku lagi, Laporan kembali ke
   *Hari ini*, tanpa pesan. Periode dianggap tidak berlaku bila:
   - bulannya tidak lagi ada di daftar pilihan (lebih dari 12 bulan lalu,
     atau sudah menjadi bulan berjalan);
   - rentangnya gagal `reportRangeError` (melewati hari ini, lebih dari
     366 hari, atau terbalik);
   - datanya rusak.
4. Gagal menyimpan atau membaca periode tidak mengganggu laporan. Laporan
   tetap tampil, dan pilihan hanya tidak diingat.
5. Tab yang aktif tidak diingat. Laporan tetap dibuka di *Ringkasan*.

Perbedaan dari spec F1-16b: aturan 7 di sana diganti oleh spec ini.

## Rancangan teknis

- Domain `ReportPeriod`:
  - `toJson()` menghasilkan `{"kind": "...", "year": .., "month": ..}`,
    atau untuk rentang `{"kind": "custom", "from": "yyyy-mm-dd",
    "to": "..."}`.
  - `ReportPeriod.fromJson(Object?)` mengembalikan `null` bila datanya
    rusak.
  - `restorable(today)` memeriksa aturan 3.
- `ReportsRepository` mendapat `savedPeriod()` dan `savePeriod(period)`.
  - Versi lokal memakai `LocalPreferences` dengan kunci
    `reports.period.<tenant>.<outlet>`.
  - Galat apa pun dari keduanya ditelan, dibaca sebagai `null`.
- `ReportsViewModel`:
  - Muat pertama membaca periode tersimpan sebelum memuat data. Yang
    tidak `restorable` diganti *Hari ini*. `restorable` memakai tanggal
    perangkat, karena tanggal cabang baru ada setelah data dimuat.
  - Bila staf memilih periode sebelum periode tersimpan selesai dibaca,
    pilihan staf yang dipakai, juga bila sama dengan periode yang tampil.
  - Daftar **Periode** selalu memuat periode aktif. Bulan yang lolos
    dengan tanggal perangkat bisa tidak ada di daftar tanggal cabang
    (zona waktu berbeda di pergantian bulan), dan FSelect gagal tanpa
    item untuk nilainya (temuan review).
  - `setPeriod` menyimpan periode tanpa menunggu.

## Pengujian

- Domain: JSON bolak-balik untuk kelima jenis periode; data rusak;
  `restorable` untuk bulan ke-12 dan ke-13, bulan berjalan, rentang masa
  depan, dan rentang 367 hari.
- Repositori lokal: simpan lalu baca, per cabang, dan JSON rusak dibaca
  `null`.
- VM:
  - periode tersimpan dipakai saat muat pertama;
  - periode yang tidak berlaku menjadi *Hari ini*;
  - `setPeriod` menyimpan, dan muat ulang tidak membaca lagi;
  - periode yang dipilih selama periode tersimpan masih dibaca menang.
- Widget: pilih periode, lalu buka Laporan dengan periode tersimpan, dan
  pilihan **Periode** menunjukkan periode itu.
- Uji manual Xvfb: pilih *Bulan ini*, pindah menu, lalu kembali.

## Status & gap

| Topik | Kode | Catatan |
| --- | --- | --- |
| Periode terakhir diingat per cabang di perangkat | Rilis v0.146.0 | Tab tidak diingat. |
| Periode diingat per staf | Belum | Satu periode untuk semua staf di perangkat. |
