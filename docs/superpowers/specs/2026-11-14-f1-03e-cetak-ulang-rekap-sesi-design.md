# F1-03e · Cetak ulang rekap sesi lama

- **Fase:** 1
- **Status:** Dalam pengerjaan (v0.84.0)
- **Layar:** 1.23 Laporan › tab *Kas & sesi*: baris sesi yang sudah ditutup
  bisa diketuk dan membuka dialog *Rekap sesi* (pratinjau kertas, *Cetak*,
  *Bagikan PDF*).
- **Acuan:** gap F1-03b "Cetak ulang rekap sesi lama — lewat laporan sesi
  F1-16 bila dibutuhkan". Storeku belum membangunnya; perbedaan dicatat di
  sini.

## Tujuan

Rekap sesi kasir hanya bisa dicetak dari kartu hasil sesi yang baru ditutup
di perangkat itu (F1-03b). Bila kertas rekap hilang, printer mati saat
tutup, atau pemilik ingin memeriksa sesi kemarin, rekap sesi lama bisa
dicetak ulang dari Laporan › *Kas & sesi*.

## Aturan

1. **Pintu masuk:** di tabel *Sesi kasir* tab *Kas & sesi*, setiap sesi yang
   sudah ditutup bisa diketuk (ikon printer kecil di ujung baris). Sesi yang
   masih buka tidak bisa diketuk: rekapnya belum final.
2. **Izin:** `reports:view`, sama dengan tab itu, dicek ulang di repositori.
   Rekap tidak memuat angka laba.
3. **Isi rekap** = isi rekap F1-03b (mesin struk yang sama, lebar kertas dan
   printer dari *Pengaturan › Struk & printer*) dengan perbedaan:
   - Perangkat = kode perangkat tempat sesi itu dibuka, bukan perangkat yang
     mencetak; Ditutup oleh = staf yang menutup sesi.
   - Baris info tambahan **Dicetak ulang** dengan tanggal jam cetak (zona
     waktu cabang).
   - Rincian penjualan, kas laci, dan gerakan kas dimuat ulang dari data saat
     ini; angka penutup (seharusnya, dihitung, selisih, pecahan, catatan)
     dari sesi tertutup. Bila rincian kas laci saat ini tidak lagi sama
     dengan *Seharusnya di laci* yang tersimpan (mis. nota sesi itu di-void
     sesudah tutup), rekap memuat catatan *Rincian mengikuti data saat ini;
     ada nota yang berubah setelah sesi ditutup.*
4. **Dialog Rekap sesi:** pratinjau kertas, tombol *Tutup*, *Bagikan PDF*,
   *Cetak*. Cetak ke printer terpilih; tanpa printer atau *Dialog cetak
   sistem* membuka dialog cetak. Galat printer memakai pesan yang sama
   dengan struk; PDF di desktop disimpan ke folder struk dan lokasinya
   ditampilkan. Nama berkas `rekap-sesi-YYMMDD-HHMM` dari waktu tutup.
5. Sesi tidak ditemukan / belum ditutup / gagal dimuat: dialog menampilkan
   pesan galat dan tombol *Tutup*.

## Komponen

- Data (`reports_extra.dart`): `CashSessionLine.id`; `ClosedSessionRecap`
  (sesi, gerakan kas, `SessionSalesSummary`, `CashDrawer`, nama pembuka,
  nama penutup, kode perangkat, `changedSinceClose`);
  `loadClosedSessionRecap(store, scope, permissions:, sessionId:)` melempar
  `ReportActorNotPermitted` atau `CashSessionNotClosed`.
- Flutter: `ReportsRepository.loadSessionRecap(sessionId)`;
  `SessionRecap.fromClosed`; `sessionRecapContent(..., reprintedAt:)`;
  `SessionRecapDialogViewModel` + `showSessionRecapDialog` di
  `lib/ui/reports/session_recap_dialog.dart`; `_Line.onTap` di tabel
  laporan; `ReportsScreen` menerima `receiptSettings`, `printer`, dan
  `store` dari router.

## Pengujian

- Data: rekap sesi tertutup (gerakan, penjualan, pembuka/penutup, kode
  perangkat); `changedSinceClose` setelah void nota sesi itu; sesi terbuka
  dan sesi cabang lain ditolak; tanpa `reports:view` ditolak.
- Flutter: isi rekap cetak ulang (baris *Dicetak ulang*, catatan berubah);
  VM dialog (muat, cetak, galat printer, bagikan PDF, galat muat); widget
  (baris tertutup bisa diketuk, baris buka tidak; dialog 1280 / 360 px).
- Uji manual Xvfb: tutup sesi, buka Laporan › Kas & sesi, ketuk sesi,
  *Bagikan PDF*.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Cetak ulang rekap sesi lama | 1.23 | Dalam pengerjaan | Dari Laporan › Kas & sesi, izin `reports:view`. |
