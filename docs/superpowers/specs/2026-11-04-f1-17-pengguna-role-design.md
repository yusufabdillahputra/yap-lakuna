# F1-17 · Pengguna & role (RBAC)

- **Fase:** 1
- **Status:** Rilis v0.22.0
- **Layar desain:** 1.25 *Pengguna & role (RBAC)*, 1.25b *Tambah pengguna,
  reset PIN & akun saya* (terang + gelap)
- **Acuan Storeku:** `2026-11-02-f1-17-pengguna-role-design.md`

## Tujuan

Pemilik menambah staf dengan PIN, memberi role di cabang ini, dan mengatur
izin per role (termasuk role custom), sehingga menu dan aksi yang tidak
diizinkan tersembunyi dan ditolak repositori. Setiap pengguna bisa mengganti
PIN dan kata sandinya sendiri di *Akun saya*.

## Lingkup

Termasuk:

- Daftar pengguna cabang: inisial, nama, email atau "PIN saja", role,
  cabang, status (Aktif, Nonaktif, "PIN dikunci N dtk").
- Tambah pengguna: nama, role, PIN 6 angka + ulangi PIN, sakelar aktif.
- Ubah pengguna: nama, role, aktif; **reset PIN** (PIN baru + ulangi, tanpa
  PIN lama); **buka kunci** PIN setelah salah berulang.
- Matriks izin per role: baris izin berlabel manusia + kunci
  `resource:action` dari enum `Permission`, kolom Pemilik (terkunci, semua
  izin), Manajer, Kasir, Pelayan, Staf gudang, dan role custom. *+ Role
  custom*, ganti nama dan hapus role custom, *Simpan perubahan*.
- *Akun saya* (semua pengguna, tanpa izin khusus): ganti PIN (PIN saat ini,
  PIN baru, ulangi) dan, bila akunnya punya kata sandi (pemilik), ganti kata
  sandi (saat ini, baru minimal 8 karakter, ulangi).

Tidak termasuk:

- Login email untuk manajer dan undangan email (Fase 2, bersama login web).
- Pemilik kedua atau pengalihan pemilik.
- Hapus staf permanen: staf cukup dinonaktifkan agar riwayat nota tetap
  menunjuk ke namanya.
- Kunci PIN yang bertahan setelah aplikasi ditutup (tetap di memori seperti
  F1-02).

## Desain UI (baseline)

- Menu *Sistem → Pengguna & role* (`users:manage`) membuka `/pengguna`
  dengan dua tab: **Pengguna** (tabel di ≥ 720 px, kartu di bawahnya) dan
  **Role & izin** (matriks; kolom role bisa digulir mendatar di layar
  sempit).
- *Tambah* dan klik baris membuka dialog pengguna (lembar penuh di < 600
  px). Dialog ubah punya bagian *Reset PIN*. Badge *PIN dikunci N dtk* dan
  tombol *Buka kunci* ada langsung di baris staf (lebih cepat daripada
  membuka dialog), dengan hitung mundur per detik. Baris pemilik dan baris
  diri sendiri tidak bisa dibuka oleh non-pemilik.
- Menu *Sistem → Akun saya* (semua pengguna) membuka `/akun` dengan kartu
  *Ganti PIN* dan *Ganti kata sandi*.
- Kolom ulangi tepat di bawah kolom pertama; galat "PIN tidak sama" /
  "Kata sandi tidak sama" (id) dan "The PINs do not match" / "The passwords
  do not match" (en), sama dengan 1.1b.
- Catatan di bawah matriks: izin berformat `resource:action`; tombol dan
  halaman yang tidak diizinkan otomatis disembunyikan; role disimpan di
  perangkat ini.

## Aturan bisnis (`lakuna_domain`)

- `staffNameIssue(name)`: wajib, maksimal 60 karakter.
- `validatePinPair(pin, retype)`: PIN tepat 6 angka; ulangi harus sama.
  `validatePasswordPair(password, retype)`: minimal 8 karakter; ulangi sama.
  Aturan yang sama dipakai 1.1b.
- `roleKeyFor(name, taken)`: kunci snake_case ASCII dari nama (huruf kecil,
  selain huruf/angka → `_`), awalan `custom_` bila kosong atau bentrok dengan
  role bawaan, akhiran `_2`, `_3`, … bila sudah dipakai.
- `encodePermissions` / `decodePermissions`: daftar kunci dipisah koma,
  urut sesuai enum; kunci yang tidak dikenal diabaikan.
- `effectivePermissions({roleKey, isOwner, stored})`: pemilik selalu semua
  izin; role yang punya baris tersimpan memakai izin tersimpan; role bawaan
  tanpa baris memakai `DefaultRole.permissions`; role tak dikenal tanpa
  baris → kosong.
- Batas wewenang (`grantIssue`): aktor yang bukan pemilik hanya boleh
  memberi izin yang ia miliki sendiri (matriks dan penetapan role), tidak
  boleh mengubah role atau status dirinya sendiri, dan tidak boleh mengubah
  pemilik.

## Data (`lakuna_data`)

Model baru `StaffRole` (`organization/staff_role.spy.yaml`, tabel `roles`,
`database: all`): `tenant_id`, `role_key`, `name`, `permission_keys`
(teks, dipisah koma), kolom sync standar. Indeks unik
`(tenant_id, role_key)`. Migrasi `--tag staff-role`.

- Role bawaan **tidak** di-seed: barisnya baru dibuat saat matriksnya diubah
  pertama kali, jadi toko lama tidak perlu migrasi data. Role `owner` tidak
  pernah disimpan.
- `id` baris role deterministik: UUIDv5 dari `tenant_id/role_key`
  (`stableId`), supaya dua perangkat yang mengubah role yang sama tidak
  membuat dua baris yang bentrok di indeks unik saat sinkronisasi Fase 2.
  Untuk role custom, kunci bisa sama di dua perangkat dengan nama berbeda;
  baris terakhir menang (dicatat sebagai catatan Fase 2).
- Nama role custom tidak boleh memakai nama role bawaan (id/en).
- `OutletStaff` membawa `permissions` dan `roleName` yang dibaca dari tabel
  `roles` saat staf dimuat; semua pemeriksaan izin (login, persetujuan
  manajer, repositori yang membaca ulang staf) otomatis memakai izin baru.
- `listRoles`, `saveRoleMatrix` (semua perubahan satu transaksi),
  `createCustomRole`, `renameCustomRole`, `deleteCustomRole` (ditolak bila
  masih dipakai staf aktif atau nonaktif).
- `listStaffAccounts`, `createStaff` (hash PIN dihitung pemanggil),
  `updateStaff` (nama, role, aktif), `resetStaffPin`, `changeOwnPin`,
  `changeOwnPassword`. Nama staf unik tanpa membedakan huruf besar/kecil di
  tenant. Pemilik tidak bisa dinonaktifkan atau diubah role-nya.
- Setiap tulis memeriksa `users:manage` aktor (kecuali *Akun saya*) dan
  batas wewenang di atas; tercatat di outbox lewat `LakunaStore.write`.

## Aplikasi

- `UsersRepository` (+ lokal + palsu). Repositori lokal menghitung hash
  Argon2id di isolate, membaca ulang izin aktor dari database, lalu meminta
  `SessionRepository` mereset kunci PIN staf yang PIN-nya diganti dan
  menyegarkan profil sesi bila staf yang sedang login ikut berubah.
- `SessionRepository.unlockPin(staffId)` dan `refreshCurrent()`.
- `roleLabel` memakai nama role custom.

## Izin

`users:manage` untuk `/pengguna`; `/akun` tanpa izin khusus.

## Kasus tepi

- Mengubah izin role yang sedang dipakai staf yang login: menu berubah
  setelah sesi disegarkan (langsung untuk perangkat ini).
- Pemilik selalu punya semua izin meskipun matriks diubah.
- PIN baru sama dengan PIN lama tetap diterima.
- Nama role custom sama dengan role lain (tanpa membedakan huruf) ditolak.
- Staf nonaktif tidak muncul di login dan tidak bisa menyetujui void.

## Pengujian

- Domain: kunci role, enkode izin, izin efektif, PIN/kata sandi + ulangi,
  batas wewenang.
- Data: tambah staf → login memakai role; ubah matriks → izin staf berubah;
  role custom + hapus yang dipakai ditolak; manajer dengan `users:manage`
  tidak bisa memberi izin di luar miliknya; pemilik tidak bisa
  dinonaktifkan; nama unik; ganti PIN/kata sandi sendiri butuh nilai lama.
- View model + widget 1440 / 800 / 360: tambah staf (PIN tidak sama),
  reset PIN, buka kunci, matriks, role custom, Akun saya.

## Status & gap

| Topik | Desain | Kode | Catatan |
| --- | --- | --- | --- |
| Role bawaan + login PIN | 1.2 | Rilis v0.3.0 | Izin kini dari tabel `roles` bila ada. |
| Tambah staf, reset PIN, matriks, role custom, Akun saya | 1.25, 1.25b | v0.22.0 | Modul ini. |
| Login email manajer | Storeku F1-17 | Belum | Fase 2 bersama login web. |
| Kunci PIN persisten | 1.25 "Dikunci 1 mnt" | Di memori | Sama dengan F1-02. |
| Cabang lain | Kolom *Cabang* | Hanya cabang perangkat ini | Multi-cabang di Fase 2. |
| Role per tenant lintas perangkat | — | `id` stabil | Penggabungan role custom bernama beda di Fase 2. |
| Buka kunci PIN | 1.25 dialog | Di baris staf | Manajer tidak bisa membuka kunci pemilik. |

## Kriteria selesai

Pemilik bisa menambah staf PIN, mereset PIN, menonaktifkan staf, mengatur
matriks izin dan role custom; menu dan aksi mengikuti izin; setiap pengguna
bisa mengganti PIN/kata sandinya sendiri dengan kolom ulangi; tes hijau.
