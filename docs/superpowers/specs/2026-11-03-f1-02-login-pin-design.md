# F1-02 · Login PIN & ganti kasir

- **Fase:** 1
- **Status:** Dirilis di v0.3.0
- **Layar desain:** 1.2 *Login & ganti kasir (PIN) · tablet* (kanvas
  [Desain UI Lakuna](https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525))
- **Acuan Storeku:** `docs/superpowers/specs/2026-11-02-f1-02-login-pin-design.md`

## Tujuan

Beberapa staf bergantian memakai satu perangkat dengan cepat dan aman:
pilih nama, ketik PIN 6 digit, langsung bekerja dengan izin sesuai role.

## Lingkup

Termasuk:

- Layar "Siapa yang bertugas?": grid staf aktif di cabang perangkat ini.
- Keypad PIN 6 digit (layar sentuh dan keyboard fisik).
- Kunci sementara: 5 kali salah, PIN staf itu dikunci 60 detik.
- Masuk dengan email & kata sandi untuk pemilik.
- Tombol **Ganti kasir** di bilah atas, dengan nama staf yang aktif.
- Menu dan rute mengikuti izin role staf yang aktif.
- Setelah setup toko (F1-01), pemilik langsung masuk tanpa mengetik PIN.

Tidak termasuk:

- Kelola pengguna dan role (F1-17). Sampai F1-17 rilis, staf satu-satunya
  adalah pemilik.
- Dialog persetujuan PIN manajer untuk void dan diskon. Dibangun bersama
  modul pertama yang membutuhkannya (F1-04 / F1-12), memakai `PinGuard`
  yang sama.
- Login web dan MFA (Fase 2).

## Desain UI (baseline)

Kanvas 1.2 menggambar versi tablet:

- **Kiri:** baris konteks "Warung Contoh · Cabang Pusat · Perangkat K01",
  judul H1 "Siapa yang bertugas?", grid kartu staf 3 kolom (avatar inisial,
  nama, role), lalu tautan "Masuk dengan email & kata sandi (pemilik)".
- **Kanan:** kartu "Masukkan PIN <nama>" dengan 6 titik, keypad 1–9 /
  Batal / 0 / ⌫ (tombol 64 px), dan catatan "PIN diverifikasi di perangkat
  ini. 5 kali salah → dikunci 1 menit."
- **Mobile (< 600 px):** satu kolom. Daftar staf dulu; setelah staf dipilih,
  kartu PIN menggantikan daftar dengan tombol *Kembali*.
- **Pemilik (email):** tautan mengganti kartu kanan menjadi formulir email
  dan kata sandi dengan tombol *Masuk* dan *Kembali ke PIN*.
- **Galat:** `FAlert` destructive di kartu: "PIN salah. Sisa n percobaan.",
  "PIN dikunci. Coba lagi dalam n detik." (hitung mundur), "Email atau kata
  sandi salah.".
- **Bilah atas:** nama staf yang aktif dan tombol outline *Ganti kasir*
  (ikon saja di mobile).
- Komponen Forui: `FCard`, `FButton`, `FTextField`, `FAlert`, `FAvatar`.

## Aturan bisnis (`lakuna_domain`)

- **PIN:** 6 angka, hash Argon2id (`CredentialHasher` dari F1-01),
  diverifikasi lokal di isolate terpisah.
- **`PinGuard`:** menghitung kegagalan per kunci (ID staf untuk PIN, email
  untuk kata sandi). Kegagalan ke-5 mengunci kunci itu 60 detik dan
  mengatur ulang hitungan; berhasil mengatur ulang semuanya. Saat dikunci,
  verifikasi tidak dijalankan sama sekali. Jam disuntikkan agar bisa diuji.
- **Izin role:** `permissionsForRole(key)` memetakan kunci role bawaan ke
  set `Permission`. Kunci tak dikenal → set kosong (aman secara bawaan).
  Pemilik (`is_owner`) selalu mendapat semua izin.
- **Izin menu:** setiap entri menu boleh punya satu izin wajib (sama dengan
  Storeku): Kasir dan Riwayat `sales:create`, Produk `products:manage`,
  Stok `stock:adjust`, Pembelian `purchases:manage`, Pelanggan
  `customers:manage`, Supplier `suppliers:manage`, Pengeluaran
  `expenses:manage`, Laporan `reports:view`, Pengguna `users:manage`.
  Beranda, Pengaturan (isinya baru tampilan), dan Panduan terbuka untuk
  semua staf.

## Data (`lakuna_data`)

Tidak ada tabel atau migrasi baru. Sesi login hanya di memori: membuka ulang
aplikasi selalu menampilkan layar login (sama dengan Storeku).

- `listOutletStaff(store, tenantId, outletId)` → staf aktif (`is_active`,
  tidak dihapus) yang punya keanggotaan aktif di cabang itu, beserta kunci
  role-nya. Urutan: pemilik dulu, lalu nama.
- `findStaffById(store, tenantId, outletId, id)` dan
  `findOwnerByEmail(store, tenantId, outletId, email)` mengembalikan staf
  yang sama bentuknya (`OutletStaff`) termasuk hash untuk diverifikasi.
- Login tidak menulis apa pun ke database. Log masuk/keluar staf dicatat
  bersama sesi kasir (F1-03).

## Aplikasi (`lakuna_flutter`)

- `SessionRepository` (`ChangeNotifier`): `current` (`StaffProfile`:
  ID, nama, role, izin, punya PIN; tanpa hash), `listStaff()`,
  `loginWithPin(staffId, pin)`, `loginWithPassword(email, password)`,
  `pinRetryAfter(staffId)`, `passwordRetryAfter(email)`,
  `startOwnerSession(StoreContext)`, `logout()`. Galat bertipe:
  `WrongPin(remainingAttempts)`, `CredentialsLocked(retryAfter)`,
  `WrongCredentials`, `StaffUnavailable`.
- Percobaan untuk kunci yang sama (staf atau email) diantrekan di
  repositori, sehingga pemeriksaan kunci dan pencatatan gagal tidak bisa
  disalip percobaan bersamaan.
- Email tak dikenal tetap diverifikasi terhadap hash tiruan agar waktu
  respons tidak membocorkan email terdaftar.
- `LoginViewModel`: staf terpilih, digit PIN, mode email, hitung mundur
  kunci (`Timer` per detik), perintah `Command0`.
- Router: toko belum ada → `/setup`; toko ada tanpa sesi → `/masuk`; sesi
  ada dan berada di `/masuk` atau `/setup` → Beranda; rute modul yang izinnya
  tidak dimiliki → Beranda.
- Setelah *Mulai jualan* di wizard, `startOwnerSession` dipanggil sehingga
  pemilik langsung masuk ke Beranda.

## Kasus tepi

- **Staf tanpa PIN** (belum diatur di F1-17): kartunya nonaktif dengan
  keterangan "Belum punya PIN".
- **Staf dinonaktifkan saat layar login terbuka:** verifikasi mengembalikan
  `StaffUnavailable` dan daftar dimuat ulang.
- **PIN diketik saat dikunci:** keypad nonaktif sampai hitung mundur habis,
  juga setelah berpindah ke staf lain lalu kembali, atau bolak-balik ke
  formulir email. Email yang dikunci langsung menampilkan hitung mundur saat
  diketik.
- **Staf lain dipilih saat PIN sedang diperiksa:** pilihan diabaikan sampai
  hasilnya keluar, agar galat tidak mendarat di kartu staf lain.
- **Email bukan milik pemilik:** pesan sama dengan kata sandi salah, agar
  tidak membocorkan email yang terdaftar. Pemilik boleh masuk di cabang mana
  pun; role-nya diambil dari keanggotaan cabang bila ada, selain itu
  `owner`.
- **Label keypad di layar sempit:** label diperkecil (mis. "Cancel" di
  ponsel) agar tidak meluap.
- **Dikunci lalu aplikasi ditutup:** kunci di memori hilang (diterima di
  Fase 1, sama dengan Storeku).

## Pengujian (TDD)

- **`lakuna_domain`:** `PinGuard` (gagal 1–4 tidak mengunci, ke-5 mengunci
  60 detik, sisa percobaan, lepas setelah 60 detik, berhasil mengatur ulang,
  kunci terpisah per staf), `permissionsForRole`, inisial nama.
- **`lakuna_data`:** daftar staf hanya yang aktif di cabang itu dan
  urutannya, pencarian pemilik per email (huruf besar/kecil), staf terhapus
  tidak muncul.
- **`lakuna_flutter`:** repositori sesi (PIN benar/salah/terkunci, kata
  sandi, `startOwnerSession`, logout), view model login, alur widget
  (tablet dan mobile, keyboard fisik, ganti kasir, menu sesuai role,
  redirect router).
- **Uji manual Xvfb** dengan tangkapan layar: login tablet terang, PIN salah,
  login mobile gelap, bilah atas dengan *Ganti kasir*.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Persetujuan PIN manajer | Void dan diskon "butuh PIN manajer" | Belum | Bangun bersama modul pertama yang membutuhkannya, pakai `PinGuard` |
| Kunci per perangkat | "Dikunci 1 mnt" | `PinGuard` di memori, hilang saat aplikasi ditutup | Cukup untuk Fase 1 |
| Log masuk/keluar | - | Tidak dicatat | Catat di sesi kasir (F1-03) |
| Ganti/atur ulang PIN | Kanvas 1.25b: setiap ganti atau atur ulang PIN menghapus hitungan salah dan kunci sementara | Belum ada ganti PIN | Saat F1-17 (Pengguna & role, *Akun saya*): panggil `PinGuard.recordSuccess` untuk staf itu setelah PIN disimpan |
| Nama staf di bilah atas mobile | Kanvas 1.2 hanya tablet | Mobile: ikon *Ganti kasir* saja (nama di label aksesibilitas); nama tampil di Beranda | Pertahankan; bilah atas ponsel sempit |

## Kriteria selesai

Terpenuhi di v0.3.0: uji manual di Xvfb (login tablet terang, PIN salah,
kunci dengan hitung mundur, login email pemilik, menu kasir, mobile gelap,
setup langsung masuk sebagai pemilik).

- Buka ulang aplikasi menampilkan layar login; PIN pemilik membuka Beranda.
- Lima PIN salah mengunci 60 detik dengan hitung mundur.
- Login email pemilik berjalan; *Ganti kasir* kembali ke layar login.
- Menu mengikuti izin role.
- Semua tes lulus, analyze bersih, uji manual dengan tangkapan layar,
  CHANGELOG 0.3.0, Status & gap, dan indeks spec diperbarui.
