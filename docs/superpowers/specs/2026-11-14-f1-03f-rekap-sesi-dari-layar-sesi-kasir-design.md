# F1-03f · Cetak ulang rekap dari layar Sesi kasir

- **Fase:** 1
- **Status:** Dalam pengerjaan (v0.87.0)
- **Layar:** 1.3 Sesi kasir (formulir *Buka sesi*): kartu baru *Sesi
  sebelumnya* berisi sesi tertutup terakhir di perangkat ini.
- **Acuan:** gap [F1-03e](2026-11-14-f1-03e-cetak-ulang-rekap-sesi-design.md)
  *Cetak ulang dari layar Sesi kasir*. Storeku belum membangunnya;
  perbedaan dicatat di sini.

## Tujuan

F1-03e membuka cetak ulang rekap sesi lama lewat Laporan, yang butuh izin
`reports:view`. Kasir yang menutup sesi biasanya tidak punya izin itu,
padahal merekalah yang perlu mencetak ulang bila kertas rekap hilang atau
printer mati saat tutup. Modul ini menampilkan sesi tertutup terakhir di
layar Sesi kasir perangkat itu.

## Aturan

1. **Kartu *Sesi sebelumnya*** (`cash-previous-card`) tampil di bawah
   formulir *Buka sesi* bila ada sesi tertutup di **perangkat ini** dan
   staf punya `cash_session:close` atau `reports:view`. Isinya maksimal
   **5 sesi** tertutup terakhir (urut waktu tutup terbaru), per baris:
   tanggal dan jam buka–tutup (zona waktu cabang), nama pembuka, dan
   selisih kas (merah bila kurang, hijau bila lebih). Ikon printer di ujung
   baris.
2. Mengetuk baris membuka dialog **Rekap sesi** yang sama dengan F1-03e
   (pratinjau, *Tutup*, *Bagikan PDF*, *Cetak*, baris *Dicetak ulang*).
3. **Izin di repositori:** `loadClosedSessionRecap` menerima
   `reports:view` (sesi mana pun di cabang, seperti F1-03e) **atau**
   `cash_session:close` untuk sesi yang dibuka di perangkat yang sama.
   Sesi perangkat lain tanpa `reports:view` ditolak.
4. Gagal memuat daftar: kartu tidak tampil (formulir buka sesi tetap
   jalan). Kartu hasil sesi yang baru ditutup tidak berubah; setelah
   *Buka sesi baru* daftar dimuat ulang sehingga sesi tadi ikut tampil.
5. Kartu tidak tampil saat sesi sedang terbuka (layar kas laci).

## Komponen

- Data (`reports_extra.dart`): `listRecentClosedSessions(store, scope,
  {permissions, limit = 5})` → `List<CashSessionLine>` untuk
  `scope.deviceId`; `loadClosedSessionRecap` menerima `cash_session:close`
  untuk sesi perangkat yang sama.
- Flutter:
  - `CashDrawerRepository.recentClosed()` dan `loadSessionRecap(id)`.
  - `SessionRecapDialogViewModel` dan `showSessionRecapDialog` menerima
    fungsi `loadRecap` (bukan `ReportsRepository`), dipakai Laporan dan
    Sesi kasir.
  - `CashSessionViewModel.previous`, dimuat saat `load` / `startNew` bila
    tidak ada sesi terbuka dan staf berizin.
  - `_PreviousSessions` di `cash_session_view.dart`; `CashSessionScreen`
    sudah menerima `receiptSettings` dan `printer`.

## Pengujian

- Data: daftar sesi tertutup perangkat ini (urut terbaru, maks 5, tanpa
  sesi terbuka, tanpa perangkat lain); izin `cash_session:close` boleh
  memuat rekap sesi perangkat sendiri, ditolak untuk perangkat lain; tanpa
  izin ditolak.
- Flutter: VM (daftar dimuat, tanpa izin kosong, dimuat ulang setelah
  *Buka sesi baru*); widget 1280 / 360 px: kartu tampil, ketuk membuka
  dialog Rekap sesi; VM dialog dengan `loadRecap`.
- Uji manual Xvfb: tutup sesi, *Buka sesi baru*, ketuk sesi sebelumnya,
  *Bagikan PDF*.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Cetak ulang rekap dari layar Sesi kasir | 1.3 | Dalam pengerjaan | 5 sesi tertutup terakhir perangkat ini; izin `cash_session:close`. |
| Riwayat sesi lengkap dengan filter tanggal | — | Belum | Pakai Laporan › Kas & sesi (butuh `reports:view`). |
