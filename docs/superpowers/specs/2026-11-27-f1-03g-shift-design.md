# F1-03g — Shift kasir

Lanjutan F1-03 (sesi kasir) dan F1-09 (master data). Gap 1 di
`docs/superpowers/GAP-FASE1.md`.

## Tujuan

Pemilik bisa membuat daftar shift cabang (mis. *Pagi 07.00–15.00*,
*Malam 22.00–06.00*). Kasir memilih shift saat membuka sesi, shift tampil di
layar sesi, rekap cetak, dan Laporan › Kas & sesi, dan laporan itu
merangkum sesi per shift.

## Aturan dari Storeku (F1-09 / F1-03)

- **Shift** = nama, jam mulai, jam selesai (boleh melewati tengah malam,
  mis. 22.00–06.00), **per outlet**. Nama unik per outlet tanpa membedakan
  huruf besar/kecil.
- Hapus = soft delete, **ditolak** bila shift dipakai sesi kasir; pesan
  menyebut jumlah sesi.
- Sesi kasir **opsional** memilih shift (`cash_sessions.shift_id`); tanpa
  master shift, sesi dibuka seperti sebelumnya.

## Perbedaan di Lakuna

- Jam disimpan sebagai menit sejak tengah malam (`start_minute`,
  `end_minute`, 0–1439), bukan teks `HH:MM`. Isian menerima `7`, `07.00`,
  `7:30`, `0730`; tampil `07.00` (format jam Indonesia).
- Jam mulai sama dengan jam selesai ditolak (shift 0 atau 24 jam
  membingungkan).
- Saat membuka sesi, shift yang sedang berjalan menurut jam cabang
  dipilih otomatis; kasir bisa menggantinya atau memilih *Tanpa shift*.
- Tab **Master data › Shift** butuh `settings:manage` (sama dengan Meja &
  area); daftar shift untuk pilihan buka sesi bisa dibaca semua staf yang
  membuka sesi. Izin dicek di repositori dan di `lakuna_data`.
- Membuka sesi dengan shift yang sudah dihapus atau milik cabang lain
  ditolak (`ShiftNotFound`).
- Nama shift dibaca dari baris shift (termasuk yang sudah dihapus lunak),
  jadi ganti nama ikut tampil di sesi lama. Sesi yang memakai shift tidak
  bisa membuat shift itu terhapus.

## Data

- Tabel baru `shifts`: `id`, `tenant_id`, `outlet_id`, `name`,
  `start_minute`, `end_minute`, kolom sinkron baku (`created_at`,
  `updated_at`, `deleted_at`, `created_by`, `updated_by`, `version`, `hlc`,
  `origin_device_id`). Indeks `outlet_id`.
- `cash_sessions.shift_id` (nullable, relasi ke `shifts`, `Restrict`).
- Migrasi `--tag shift`.

## Domain (`lakuna_domain`, `shift.dart`)

- `ShiftLimits.name = 40`.
- `parseShiftTime(String) → int?`, `formatShiftTime(int) → '07.00'`,
  `shiftRangeLabel(start, end) → '07.00–15.00'`.
- `validateShift(name:, start:, end:) → Set<ShiftIssue>` (`name`, `start`,
  `end`, `sameTime`).
- `shiftContains(start, end, minute)` termasuk shift lewat tengah malam;
  `currentShiftIndex(list, minute)` memilih shift berjalan; bila tumpang
  tindih (serah terima), shift yang paling baru mulai.

## Data (`lakuna_data`, `shifts.dart`)

- `listShifts(store, scope) → List<ShiftRow(shift, usage)>` urut jam mulai
  lalu nama.
- `saveShift(...)` (buat/ubah, `ShiftInvalid`, `ShiftNameTaken`,
  `ShiftNotFound`, `ShiftActorNotPermitted`).
- `deleteShift(...)` (`ShiftInUse(sessions)`).
- `openCashSession(shiftId:)` memeriksa shift aktif di cabang.
- `CashSessionLine.shift`, `ClosedSessionRecap.shift`, dan
  `CashReport.shifts` (per shift: jumlah sesi, penjualan sesi, selisih;
  sesi tanpa shift digabung sebagai *Tanpa shift*; hanya terisi bila ada
  sesi bershift di periode). Penjualan = seluruh nota lunas sesi itu
  (sesi lewat tengah malam tidak dipotong per tanggal), jadi bisa berbeda
  dengan tab Penjualan.

## UI

- **Master data › Shift** (ikon jam): daftar nama, rentang jam, jumlah
  sesi; tombol *+ Shift*; dialog nama + jam mulai + jam selesai, tanya
  sebelum keluar dan tombol Simpan dari dialog batal (pola F1-09b/c).
- **Sesi kasir › Buka sesi**: pilihan *Shift* (helper *Dari Master data ›
  Shift (opsional).*) di atas saldo awal, hanya bila ada shift.
- **Sesi aktif**: baris *Shift Pagi · 07.00–15.00* di kartu sesi aktif;
  judul tutup sesi *Tutup sesi kasir · Sari · Shift Pagi*.
- **Rekap cetak** dan **Sesi sebelumnya**: baris *Shift*.
- **Laporan › Kas & sesi**: kolom staf memuat shift (*Sari · Pagi*),
  tabel *Per shift* (Shift, Sesi, Penjualan, Selisih), dan catatan per
  shift di ekspor.
- Panduan ID/EN: Master data dan Sesi kasir.

## Tes

- Domain: parse/format, validasi, lewat tengah malam, shift berjalan.
- Data: CRUD, nama unik per outlet, izin, hapus ditolak bila dipakai,
  buka sesi dengan shift (sah, dihapus, cabang lain), laporan per shift.
- View model: Shift tab, pilihan shift buka sesi (otomatis, ganti, tanpa).
- Widget: tab Shift, form buka sesi, kartu aktif, laporan; 1280 dan 360 px.

## Status & gap

| Bagian | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Master Shift | 1.17b | Rilis v0.137.0 | |
| Pilih shift saat buka sesi | 1.3 | Rilis v0.137.0 | Otomatis shift berjalan. |
| Shift di rekap dan laporan | 1.3 / 1.19 | Rilis v0.137.0 | Tabel *Per shift* di Kas & sesi. |
| Jadwal shift per staf | — | Belum | Fase 3 (karyawan & gaji). |
