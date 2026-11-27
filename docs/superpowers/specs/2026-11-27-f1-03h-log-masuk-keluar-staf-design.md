# F1-03h — Log masuk/keluar staf

Lanjutan F1-02 (login PIN) dan F1-03 (sesi kasir). Gap 8 di
`docs/superpowers/GAP-FASE1.md`, gap 87 di STATUS-JEDA.

## Masalah

Login hanya disimpan di memori. Spec F1-02 menunda log masuk/keluar ke
F1-03, dan sesi kasir hanya mencatat `opened_by` / `closed_by`. Pemilik
tidak bisa melihat siapa yang memakai perangkat kasir dan kapan, misalnya
saat menelusuri selisih laci, nota yang janggal, atau staf yang masuk di
luar jam kerjanya.

## Tujuan

Setiap kali staf masuk atau keluar di perangkat ini, kejadian itu dicatat
di database. Pemilik atau manajer (`users:manage`) bisa melihat log
tersebut di **Pengguna & role › Log masuk**.

## Aturan

1. **Yang dicatat** (satu baris per kejadian):
   - *Masuk dengan PIN*: login PIN di layar login berhasil.
   - *Masuk dengan kata sandi*: login pemilik dengan email dan kata sandi
     berhasil.
   - *Masuk setelah penyiapan toko*: sesi pemilik yang dimulai otomatis
     setelah onboarding.
   - *Keluar*: lewat *Ganti kasir*.
   - *Keluar otomatis*: akun dinonaktifkan atau dikeluarkan dari cabang
     saat staf itu sedang bertugas (`refreshCurrent`).
2. **Tidak dicatat:**
   - persetujuan PIN manajer (void, diskon, QRIS), yang sudah tercatat
     di dokumennya;
   - cek PIN di *Akun saya*;
   - percobaan gagal (lihat gap).
3. Pencatatan **tidak boleh** menggagalkan atau memperlambat login.
   - Galat tulis dicatat ke log debug (`logError`), lalu login jalan
     terus.
   - Penulisan diantrekan, sehingga urutan *Keluar* A lalu *Masuk* B
     tetap terjaga.
4. Aplikasi yang ditutup tanpa *Ganti kasir* tidak punya baris *Keluar*.
   Login berikutnya di perangkat yang sama menjadi batasnya. Panduan
   menjelaskan hal ini.
5. Tampilan log, di tab **Log masuk**:
   - Hanya untuk `users:manage`. Repositori juga menolak staf lain.
   - Isinya kejadian di cabang ini, dari semua perangkat yang tersinkron,
     dengan yang terbaru di atas.
   - Log dikelompokkan per tanggal menurut zona waktu cabang. Tiap baris
     berisi jam `HH.mm`, nama staf, jenis kejadian, dan kode perangkat.
   - Filter **Staf** berisi *Semua staf* ditambah semua staf cabang,
     termasuk yang nonaktif.
   - Daftar memuat 50 baris dulu. **Muat lagi** mengambil 50 baris yang
     lebih lama.
   - Di layar lebar log tampil sebagai tabel, dan di ponsel sebagai
     kartu.
   - Bila log kosong, tampil teks *Belum ada log masuk.*

## Rancangan teknis

- **Model** `StaffAccessLog`, tabel `staff_access_logs` (`database: all`,
  `lakuna_server/lib/src/organization/`). Kolomnya:
  - `tenant_id`, `outlet_id`;
  - `device_id`, relasi ke `devices`;
  - `staff_id`, relasi ke `staff_members`;
  - `kind` (`StaffAccessKind`);
  - `occurred_at`;
  - kolom sinkron baku: `created_at`, `updated_at`, `deleted_at`,
    `created_by`, `updated_by`, `version`, `hlc`, `origin_device_id`.
  - Indeksnya `(outlet_id, occurred_at)`.
  - Migrasi dibuat dengan `--tag log-masuk`.
- **Enum** `StaffAccessKind`, disimpan berdasarkan nama: `signInPin`,
  `signInPassword`, `signInSetup`, `signOut`, `signOutRemoved`.
- **`lakuna_data`** `staff_access_log.dart`:
  - `recordStaffAccess(store, scope, {staffId, kind})` menulis lewat
    `store.write` + `insert` (perangkat = `scope.deviceId`), sehingga
    barisnya masuk outbox.
  - `listStaffAccess(store, scope, {staffId?, before?, limit})` memakai
    kursor dan urutan `(occurredAt, hlc, id)`. HLC menjaga urutan tulis
    di milidetik yang sama, karena UUID v7 acak di dalam satu milidetik
    (temuan review).
    - Hasilnya baris beserta nama staf dan kode perangkat, termasuk staf
      dan perangkat yang sudah dihapus.
    - Staf yang tidak dikenal tampil sebagai `?`.
- **`LocalSessionRepository`** memanggil `_record(kind, staff)` setelah:
  - `_signIn` berhasil;
  - `startOwnerSession`;
  - `logout` dengan staf aktif;
  - `refreshCurrent` mengeluarkan staf.
  - `_record` menyambung `Future` ke rantai `_logChain`. Galatnya
    ditangkap dan dicatat.
  - Rantai ini dibuka ke tes lewat `@visibleForTesting Future<void>
    get pendingLog`.
- **`UsersRepository.accessLog({staffId, before})`** mengembalikan
  `Result<StaffAccessPage>`, berisi `rows` dan `hasMore`. Pemanggil tanpa
  `users:manage` mendapat `NotPermitted`.
- **UI:**
  - `UsersTab.accessLog`, dengan label tab *Log masuk* / *Sign-in log*.
  - `UsersViewModel` menyimpan `accessRows`, `accessStaff`,
    `accessHasMore`, dan memakai `loadAccess` / `loadMoreAccess` (metode
    biasa dengan token muat, bukan Command, karena Command menolak muat
    kedua saat filter berganti di tengah muat).
  - Log dimuat saat tab pertama kali dibuka, dan dimuat ulang saat filter
    berubah.
  - Widget-nya `access_log_tab.dart`.

## Pengujian

- **lakuna_data:**
  - catat lalu baca, urut terbaru dulu;
  - filter staf;
  - halaman dengan kursor tanpa baris ganda pada `occurredAt` yang sama;
  - cakupan dibatasi tenant/outlet;
  - baris masuk outbox;
  - nama staf yang sudah dihapus tetap tampil.
- **LocalSessionRepository:**
  - login PIN dan kata sandi menulis baris yang benar;
  - login gagal tidak menulis;
  - verifyApprover tidak menulis;
  - logout menulis *Keluar*, dan logout kedua tanpa staf tidak menulis;
  - `startOwnerSession` menulis *setelah penyiapan*;
  - staf dinonaktifkan lalu `refreshCurrent` menulis *Keluar otomatis*;
  - galat tulis tidak menggagalkan login.
- **Repositori Flutter:** `accessLog` menolak tanpa `users:manage`.
- **VM / widget:**
  - tab muncul;
  - baris dan grup tanggal tampil;
  - filter staf memanggil ulang;
  - Muat lagi menambah baris;
  - tampilan kosong;
  - tampilan ponsel 400 px tanpa overflow.

## Status & gap

| Bagian | Status |
| --- | --- |
| Catat masuk (PIN, kata sandi, setelah penyiapan) dan keluar (manual, otomatis) | Ada (v0.144.0) |
| Tab Log masuk dengan filter staf dan Muat lagi | Ada (v0.144.0) |
| Percobaan PIN/kata sandi gagal dan penguncian di log | Belum |
| Keluar saat aplikasi ditutup tanpa Ganti kasir | Belum (login berikutnya jadi batas) |
| Filter rentang tanggal, ekspor log | Belum |
