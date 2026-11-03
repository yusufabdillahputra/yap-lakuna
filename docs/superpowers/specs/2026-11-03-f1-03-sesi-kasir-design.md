# F1-03 · Sesi kasir

- **Fase:** 1
- **Status:** Dirilis di v0.4.0
- **Layar desain:** 1.3 *Buka / tutup sesi kasir · tablet* dan 1.3b *Kas laci:
  uang masuk/keluar, shift* (terang dan gelap), kanvas
  [Desain UI Lakuna](https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525)
- **Acuan Storeku:** `docs/superpowers/specs/2026-11-02-f1-03-sesi-kasir-design.md`

## Tujuan

Kasir membuka laci dengan saldo awal, mencatat uang masuk dan keluar, lalu di
akhir shift menghitung uang fisik dan melihat selisihnya. Dengan begitu
pemilik bisa menelusuri kas harian.

## Lingkup

Termasuk:

- Buka sesi: saldo awal laci dan catatan opsional.
- Kas laci (1.3b):
  - Kartu sesi aktif dengan perkiraan uang di laci.
  - Tabel gerakan kas sesi ini.
  - Formulir *Catat uang laci* (uang keluar/masuk, jumlah, keterangan).
- Tutup sesi (1.3):
  - Ringkasan transaksi.
  - Rekap kas laci.
  - Hitung uang fisik per pecahan.
  - Selisih dan catatan selisih.
  - Tombol *Tutup sesi*.
- Menu *Sesi kasir* di kelompok Penjualan dan di navigasi bawah ponsel.

Tidak termasuk (lihat gap):

- **Shift.** Master Shift ada di F1-09; sampai itu ada, sesi dibuka tanpa
  shift.
- **"Catat juga sebagai pengeluaran" dan foto nota.** Keduanya bagian dari
  F1-15 Pengeluaran.
- **Cetak rekap.** Memakai mesin cetak F1-06.
- **Angka penjualan, QRIS, kartu, void, dan retur di rekap.** Modul penjualan
  belum ada, jadi nilainya 0 sampai F1-04/F1-05/F1-11 menulis datanya.
- **Laporan rekap sesi.** Ada di F1-16.

## Desain UI (baseline)

### Tanpa sesi terbuka

Kartu *Buka sesi kasir* berisi:

- Baris konteks: usaha · cabang · perangkat · staf.
- *Saldo awal laci* dengan awalan "Rp".
- *Catatan* (opsional).
- Tombol primary *Buka sesi*.

Kanvas tidak menggambar keadaan ini dan juga tidak memakai tombol nominal
cepat. Formulirnya mengikuti kartu *Saat buka sesi* di 1.3b.

### Sesi terbuka (1.3b)

- **Kepala:** judul "Sesi kasir · Kas laci", subjudul "usaha · cabang ·
  Kasir: <nama>", dan tombol outline *Tutup sesi* dengan ikon gembok.
- **Kiri, kartu sesi aktif:**
  - "Sesi aktif".
  - "Dibuka HH.mm oleh <nama> · <perangkat>".
  - Di kanan: "Perkiraan uang di laci" (tebal).
- **Kiri, kartu *Gerakan kas sesi ini*:**
  - Kolom Jam / Keterangan / Sumber / Jumlah.
  - Baris pertama selalu saldo awal, bersumber "Buka sesi", warnanya netral
    dan tebal.
  - Uang masuk hijau dengan "+", uang keluar merah dengan "−".
  - Catatan kaki: gerakan kas dari modul lain (pengeluaran, hutang, retur
    tunai) akan otomatis tercatat di sesi yang sedang buka.
- **Kanan, kartu *Catat uang laci* (360 px):**
  - `FTabs` *Uang keluar* / *Uang masuk*.
  - *Jumlah* dengan awalan Rp.
  - *Keterangan*.
  - Tombol *Simpan*.
  - Teks kecil: "Butuh izin `cash_movements:create`."
- **Mobile:** satu kolom: kartu sesi, formulir, lalu tabel. Tabel tetap
  terbaca di ponsel: kolom Sumber dilipat ke bawah Keterangan.

### Tutup sesi (1.3)

- **Kepala:** "Tutup sesi kasir · <nama>" dan tombol *Kembali ke kas laci*.
  - Kanvas memakai `FTabs` *Buka sesi* / *Tutup sesi*. Di aplikasi, buka dan
    tutup adalah keadaan berbeda, sehingga tab diganti tombol kembali (lihat
    gap).
- **Kiri:**
  - Tiga kartu angka: *Transaksi*, *Penjualan*, *Void / retur*.
  - Kartu *Rekap kas laci* berisi baris-baris berikut:
    - Saldo awal (jam buka).
    - Penjualan tunai.
    - Uang masuk lain.
    - Uang keluar.
    - **Seharusnya di laci** (tebal).
    - QRIS statis (terkonfirmasi) · kartu.
  - Catatan kaki "QRIS statis & kartu tidak masuk laci, …".
- **Kanan, kartu *Hitung uang fisik* (400 px):**
  - Satu baris per pecahan: label, kolom angka lembar, dan subtotal rata
    kanan.
  - Pecahan: Rp 100.000, 50.000, 20.000, 10.000, 5.000, 2.000, 1.000, lalu
    *Receh* yang diisi nominal langsung. Rp 2.000 dan 1.000 diambil dari
    Storeku; kanvas hanya menampilkan sampai 5.000.
  - *Uang dihitung* (tebal).
  - *Selisih* dalam pil:
    - Kuning (peringatan) bila tidak nol.
    - Hijau bila pas.
  - *Catatan selisih* (wajib bila selisih ≠ 0).
  - Tombol primary *Tutup sesi*.
- **Setelah tutup:** kartu hasil berisi seharusnya, dihitung, dan selisih,
  serta tombol *Buka sesi baru*.

## Aturan bisnis (`lakuna_domain`)

- **Satu sesi terbuka per perangkat.**
- **Seharusnya di laci** = saldo awal + penjualan tunai (bersih dari
  kembalian) − retur tunai + uang masuk − uang keluar.
- **Saldo awal** ≥ 0.
- **Jumlah uang masuk/keluar** > 0, dan keterangannya wajib.
- **Hitung uang:**
  - Total = Σ (pecahan × lembar) + receh.
  - Lembar dan receh tidak boleh negatif.
- **Selisih** = dihitung − seharusnya. Positif berarti lebih, negatif berarti
  kurang.
- **Catatan selisih** wajib bila selisih ≠ 0.
- **Rincian pecahan** disimpan sebagai JSON di `counted_breakdown`.

## Data

Migrasi `sesi-kasir`.

- **`cash_sessions`** (`database: all`) berisi kolom berikut:
  - `tenant_id`, `outlet_id`, `device_id`, `status` (`opened`/`closed`).
  - `opened_by`, `opened_at`, `opening_cash`, `opening_note`.
  - `closed_by`, `closed_at`, `expected_cash`, `counted_cash`,
    `difference`, `counted_breakdown`, `closing_note`.
  - Kolom sync.
  - Indeks pada `device_id`, `status`.
- **`cash_movements`** berisi kolom berikut:
  - `tenant_id`, `outlet_id`, `cash_session_id`.
  - `direction` (`inflow`/`outflow`), `amount` (selalu positif), `note`.
  - `source` (`manual`; modul lain memakai nama modulnya).
  - Kolom sync.
- **Penulisan:** semua tulis lewat `LakunaStore.write` dengan aktor staf yang
  bertugas, sehingga tercatat di outbox.
- **Saat tutup:** pemeriksaan "masih terbuka" dan pembaruan sesi berada dalam
  satu transaksi, jadi menutup dua kali tidak menimpa hasil pertama.
- **Perbedaan dengan Storeku:**
  - Arah memakai `inflow`/`outflow`, karena `in` adalah kata kunci Dart.
  - Kolom `outlet_id` ditambahkan di `cash_movements` agar query bisa
    dibatasi per cabang tanpa join.

## Izin

| Aksi | Izin |
| --- | --- |
| Buka sesi | `cash_session:open` |
| Tutup sesi | `cash_session:close` |
| Uang masuk/keluar | `cash_movements:create` |

- Izin dicek di UI (tombol tersembunyi atau nonaktif) dan di repositori
  aplikasi `CashDrawerRepository` (`NotPermitted`). Namanya bukan
  `CashSessionRepository` karena nama itu dipakai kode generate Serverpod.
- Menu *Sesi kasir* tampil bagi staf dengan `cash_session:open`.

## Kasus tepi

- **Membuka sesi kedua di perangkat yang sama** ditolak
  (`CashSessionAlreadyOpen`). Layar memuat ulang sesi yang terbuka.
- **Mencatat uang atau menutup sesi yang sudah ditutup di layar lain** ditolak
  (`CashSessionNotOpen`), lalu layar memuat ulang.
- **Ganti kasir saat sesi terbuka:** sesi tetap milik perangkat. Kasir
  berikutnya melanjutkan sesi yang sama, dan nama penutup dicatat di
  `closed_by`.
- **Selisih pas (0):** catatan tidak wajib.
- **Bolak-balik kas laci ↔ tutup sesi:** hitungan, catatan selisih, dan
  formulir uang laci dikosongkan (field-nya juga dipasang ulang kosong), dan
  rekap dimuat ulang saat masuk ke tutup sesi.
- **Panjang catatan** dihitung per karakter yang tampak (grapheme), sama
  dengan penghitung field teks.

## Pengujian (TDD)

- **`lakuna_domain`:**
  - Seharusnya di laci.
  - Total hitung pecahan dan receh.
  - Validasi saldo awal, uang masuk/keluar, dan catatan selisih.
  - JSON rincian pecahan.
- **`lakuna_data`:**
  - Buka sesi: satu baris dan satu entri outbox; sesi kedua ditolak.
  - Uang masuk/keluar.
  - Rekap.
  - Tutup: selisih dan catatan; menutup dua kali ditolak.
  - Sesi perangkat lain tidak terbaca.
- **`lakuna_flutter`:**
  - Repositori lokal dengan izin.
  - View model: buka, catat, tutup, dan galat.
  - Alur widget di tablet dan mobile.
  - Menu sesuai izin.
- **Uji manual Xvfb** dengan tangkapan layar: buka sesi, kas laci, tutup sesi,
  hasil, dan mobile gelap.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Shift | "Shift Pagi", pilih shift saat buka | Tanpa shift | Tambah kolom `shift_id` dan pilihan shift saat F1-09 menyediakan master Shift |
| Catat sebagai pengeluaran + foto nota | Sakelar dan pilihan jenis di 1.3b | Belum | F1-15 Pengeluaran menulis `cash_movements` dengan `source` `expense` |
| Cetak rekap | "Tutup sesi & cetak rekap" | Tombol *Tutup sesi*, tanpa cetak | Pakai mesin cetak F1-06 |
| Angka penjualan/QRIS/kartu/void/retur | Terisi | 0 sampai modul penjualan ada | F1-04, F1-05, dan F1-11 mengisi rekap |
| Tab Buka/Tutup sesi | `FTabs` di kepala 1.3 | Keadaan terpisah: tombol *Tutup sesi* dan *Kembali ke kas laci* | Pertahankan, karena tab "Buka sesi" saat sesi terbuka tidak bermakna |
| Pecahan Rp 2.000 dan 1.000 | Tidak tampak di 1.3 | Ada (sama dengan Storeku) | Kanvas bisa ditambah |
| Keadaan "belum ada sesi" | Tidak digambar | Kartu *Buka sesi kasir* (saldo awal, catatan) | Tambah artboard di kanvas |
| Navigasi ponsel | Kanvas 1.3b mobile tidak menggambar navigasi bawah | *Sesi kasir* menjadi item navigasi bawah (Beranda, Kasir, Sesi kasir, Produk, Pengaturan sesuai izin) | Pertahankan; tanpa ini kasir di ponsel tidak bisa membuka sesi |
| Kartu angka di ponsel | - | Tiga kartu tetap satu baris | Pertahankan |
| Izin tutup tanpa izin buka | - | Menu dan rute butuh `cash_session:open`; role kustom yang hanya punya `cash_session:close` tidak bisa membuka layar | Saat F1-17 menambah role kustom: izinkan rute bila punya salah satu dari open/close |
| Log masuk/keluar staf | Spec F1-02 menunda ke F1-03 | Belum: sesi mencatat `opened_by`/`closed_by` saja | Tabel log bila laporan F1-16 membutuhkannya |

## Kriteria selesai

Terpenuhi di v0.4.0: uji manual di Xvfb (buka sesi, uang masuk/keluar,
tutup dengan selisih dan catatan wajib, selisih pas, sesi tetap terbuka
setelah aplikasi dibuka ulang, menu tersembunyi untuk staf gudang, ponsel
gelap). Tangkapan layar `v0.4.0-*.png`.

- Buka sesi, catat uang masuk/keluar, lalu tutup dengan hitung pecahan.
  Selisih dan catatan tersimpan, dan semuanya tercatat di outbox.
- Semua tes lulus, analyze bersih, uji manual dengan tangkapan layar,
  CHANGELOG 0.4.0, Status & gap, dan indeks spec diperbarui.
