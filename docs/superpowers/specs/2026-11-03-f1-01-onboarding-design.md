# F1-01 · Onboarding & setup toko

- **Fase:** 1
- **Status:** Berjalan (target v0.2.0)
- **Layar desain:** 1.1 *Setup toko pertama · tablet* (kanvas
  [Desain UI Lakuna](https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525))
- **Acuan Storeku:** `docs/superpowers/specs/2026-11-02-f1-01-onboarding-design.md`

## Tujuan

Pemilik UMKM memasang Lakuna dan langsung punya toko siap jualan dalam 4
langkah, tanpa internet dan tanpa server.

## Lingkup

Termasuk:

- Pilihan bahasa (ID/EN) dan tema (Terang/Gelap/Ikuti sistem).
- Jenis usaha (Retail, F&B, Campuran), nama usaha, cabang pertama, kode
  cabang dan kode perangkat untuk nomor nota, zona waktu (WIB/WITA/WIT).
- Akun pemilik: nama, email, kata sandi, dan PIN 6 digit.
- Ringkasan dan tombol *Mulai jualan*.

Tidak termasuk:

- Aktivasi hosting (Fase 2 modul 1) dan cabang kedua (Fase 2 modul 4).
- Login PIN dan ganti kasir (F1-02). Sampai F1-02 rilis, setelah setup
  aplikasi langsung masuk ke Beranda.
- Produk pertama dan import Excel. Kanvas menamai langkah 4 "Produk pertama
  (atau import Excel)", tetapi modul produk belum ada. Langkah 4 sementara
  menjadi ringkasan, dan produk pertama dipindah ke F1-07 (lihat gap).

## Desain UI (baseline)

Kanvas hanya menggambar langkah 2 versi tablet. Langkah lain mengikuti pola
yang sama.

- **Tablet/desktop (≥ 600 px):** dua kolom.
  - Panel kiri 340 px berlatar Sky dengan teks putih: "Selamat datang",
    judul "Siapkan toko Anda dalam 4 langkah", stepper vertikal (selesai = ✓,
    aktif = titik putih bernomor dan label tebal), dan catatan bawah "Semua
    data tersimpan di perangkat ini. Anda bisa mengaktifkan versi hosting
    kapan saja."
  - Area utama: "Langkah n dari 4" dan sakelar bahasa ID/EN di atas, judul
    H1, isi langkah, lalu tombol *Kembali* (outline) dan *Lanjut: …*
    (primary) di bawah.
- **Mobile (< 600 px):** tanpa panel kiri. Bagian atas berisi "Langkah n dari
  4", judul langkah, dan progress bar. Tombol di bawah selebar layar.
- **Langkah:**
  1. *Bahasa & tema*: pilihan bahasa dan tema, berlaku langsung.
  2. *Jenis usaha & cabang pertama*:
     - Tiga kartu pilihan jenis usaha dengan deskripsi dari kanvas.
     - Nama usaha, nama cabang, kode cabang, kode perangkat, dan zona waktu.
     - Kotak pratinjau nomor nota (mis. `PST-K01-261103-0001`) yang
       berubah saat kode diketik.
     - Kode perangkat ditambahkan dari spec Storeku karena kanvas hanya
       menampilkan kode cabang. Bawaannya `K01`.
  3. *Akun pemilik & PIN*: nama pemilik, email, kata sandi (minimal 8
     karakter), PIN 6 digit, dan konfirmasi PIN.
  4. *Siap jualan*: ringkasan usaha, cabang, perangkat, dan pemilik, lalu
     tombol *Mulai jualan*. Data baru ditulis saat tombol ini ditekan.
- Komponen Forui: `FTextField`, `FSelect`, kartu pilihan memakai
  `FSelectTileGroup`, `FButton`, `FDeterminateProgress`, `FAlert` untuk
  galat.

## Aturan bisnis (`lakuna_domain`)

- **Kode cabang dan kode perangkat:** 2–6 karakter huruf/angka, otomatis
  huruf besar.
- **Nama usaha, cabang, dan pemilik:** dipangkas spasinya, 1–60 karakter.
- **Email:** wajib, format `nama@domain.tld`, disimpan huruf kecil.
- **Kata sandi:** minimal 8 karakter.
- **PIN:** tepat 6 angka, dan konfirmasinya harus sama.
- **Zona waktu:** `Asia/Jakarta` (WIB), `Asia/Makassar` (WITA),
  `Asia/Jayapura` (WIT).
- **Validasi:** `SetupInput.validate()` mengembalikan daftar galat per field.
  Langkah berikutnya tidak bisa dibuka selama langkah ini masih punya galat.
- **Kata sandi dan PIN:** di-hash dengan **Argon2id** (`CredentialHasher`,
  paket `hashlib` yang murni Dart) dan disimpan sebagai string PHC
  `$argon2id$v=19$m=19456,t=2,p=1$<salt>$<hash>`.
  - Parameternya rekomendasi OWASP, dengan salt acak 16 byte.
  - Teks asli tidak pernah disimpan.
  - Hashing berjalan di isolate terpisah agar UI tidak macet.

## Data

Setup menulis dalam **satu transaksi** `LakunaStore.write`, dengan aktor
pemilik (`created_by` = ID pemilik):

| Tabel | Baris |
| --- | --- |
| `tenants` | Nama usaha, `business_type`, `timezone` |
| `outlets` | Nama cabang, kode, zona waktu |
| `devices` | `id` = ID perangkat dari `LakunaStore`, kode, nama "Perangkat <kode>", platform |
| `stock_locations` | "Etalase", `is_default = true` |
| `staff_members` | Pemilik: `is_owner = true`, email, `pin_hash`, `password_hash` (kolom baru) |
| `outlet_members` | Pemilik di cabang pertama dengan role `owner` |

- Setiap baris tercatat di `sync_outbox`.
- Bila satu baris gagal, semuanya dibatalkan.
- **Migrasi `onboarding`:** menambah kolom `staff_members.password_hash`
  (String, nullable).
- **Perbedaan dengan Storeku:**
  - Metode bayar bawaan (Tunai, Kartu, Transfer) dan satuan dasar (pcs, pak,
    dus, kg) dibuat oleh modulnya sendiri saat pertama dibuka (F1-05 dan
    F1-07), bukan di onboarding. Dengan begitu tabelnya lahir bersama
    modulnya.
  - Tidak ada tabel `users`/`roles` arium. Pemilik adalah `staff_members`,
    dan role berupa kunci teks di `outlet_members`.
- **Konteks toko:** `StoreRepository.loadContext()` mengembalikan
  `StoreContext` berisi tenant, outlet, perangkat, dan pemilik. Bila belum
  ada tenant, hasilnya `null`.
- **Satu tenant per perangkat:** setup ditolak (`SetupAlreadyDone`) bila
  database sudah punya tenant.

## Izin

Tidak perlu izin, karena belum ada pengguna. Setup hanya bisa dijalankan bila
database belum punya tenant. Router selalu mengarahkan ke `/setup` selama
`loadContext()` masih `null`, dan menolak membuka `/setup` setelah setup
selesai.

## Kasus tepi

- **Aplikasi ditutup di tengah wizard:** tidak ada yang tersimpan kecuali
  bahasa dan tema (preferensi lokal). Wizard mulai lagi dari langkah 1.
- **Tombol *Mulai jualan* ditekan dua kali:** perintah sedang berjalan,
  jadi tombol nonaktif. Bila tetap terpanggil, panggilan kedua mendapat
  `SetupAlreadyDone` dan tidak membuat data ganda.
- **Galat database saat setup:** transaksi dibatalkan, pesan galat tampil di
  langkah 4, dan pengguna bisa mencoba lagi.
- **Kode diketik huruf kecil atau dengan spasi:** diubah ke huruf besar dan
  dipangkas sebelum divalidasi.

## Pengujian (TDD)

- **`lakuna_domain`:**
  - Validasi `SetupInput` per field (kode, nama, email, kata sandi, PIN,
    zona waktu).
  - `CredentialHasher`: verifikasi benar dan salah, salt berbeda per hash,
    format PHC.
- **`lakuna_data`:**
  - `setupStore` membuat 6 baris dan 6 entri outbox dalam satu transaksi.
  - Aktor dan HLC terisi.
  - Setup kedua ditolak.
  - Galat di tengah transaksi membatalkan semua baris.
  - `loadContext()` mengembalikan `null` sebelum setup.
- **`lakuna_flutter`:**
  - View model: navigasi langkah, validasi memblokir *Lanjut*, pratinjau
    nota, perintah setup memanggil repositori sekali.
  - Widget: alur lengkap 4 langkah di ukuran tablet dan mobile, lalu
    redirect router ke Beranda.
- **Uji manual Xvfb** dengan tangkapan layar tiap langkah (tablet dan
  mobile, terang dan gelap).

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Langkah 4 "Produk pertama (atau import Excel)" | Tambah produk atau import Excel di onboarding | Langkah 4 berisi ringkasan + *Mulai jualan* | Tambahkan saat F1-07 Produk (import Excel memakai `FDeterminateProgress`) |
| Kode perangkat | Tidak tampak di 1.1 (pratinjau memakai `T01`) | Field kode perangkat, bawaan `K01` | Pertahankan; kanvas bisa diperbarui |
| Lokasi stok Gudang | Etalase & Gudang | Hanya "Etalase" | Sama dengan Storeku: tambah lewat Master data (F1-09) |

## Kriteria selesai

- Instal baru membuka wizard. Setelah *Mulai jualan*, Beranda menampilkan
  nama usaha, cabang, dan kode perangkat.
- Semua tes lulus, analyze bersih, dan uji manual dengan tangkapan layar.
- CHANGELOG 0.2.0, tabel Status & gap, dan indeks spec diperbarui.
