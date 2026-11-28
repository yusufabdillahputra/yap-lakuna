# F2-02 · Versi web: login & dashboard semua cabang

- **Fase:** 2 (modul 2)
- **Status:** Spec + rencana (4 tahap, v0.169.0–v0.172.0). Belum ada kode.
- **Layar desain:** 2.2 *Login web* (`F2-Login-Web`), 2.3 *Dashboard semua
  cabang · web* (`F2-Dashboard-Web`, juga versi gelap) di kanvas
  [Desain UI Lakuna](https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525).
- **Acuan:** spec Storeku `2026-11-02-f2-02-web-dashboard-design.md` (aturan
  disalin di bawah, perbedaan dicatat), spec F2-01 Lakuna (sync, token
  perangkat, paket VPS).

## Tujuan

Pemilik toko versi hosting memantau dan mengelola semua cabang dari browser
mana saja: penjualan hari ini, status perangkat, konflik sync, dan semua
menu back office, memakai data yang sudah disinkronkan dari kasir.

Ukuran berhasil:

- Pemilik membuka alamat server di browser, masuk dengan email, kata sandi,
  dan kode authenticator, lalu melihat data tokonya tanpa memasang apa pun.
- Dashboard menampilkan penjualan hari ini semua cabang dan per cabang,
  perangkat yang tertinggal sync, dan hal yang perlu perhatian.
- Mengubah produk, harga, atau pengaturan dari web sampai ke kasir lewat
  sync yang sama dengan perangkat lain.

Bukan tujuan: kasir di web (kasir tetap di perangkat dengan PIN), mode
offline-only di browser (browser hanya untuk toko versi hosting), tinjau
konflik (F2-03), kelola cabang & perangkat (F2-04), transfer stok (F2-05).

## Pendekatan yang dipertimbangkan

1. **Aplikasi yang sama di browser sebagai perangkat hosting** (dipilih,
   lihat catatan keputusan). Build web dari `lakuna_flutter` yang sama.
   Browser menjadi satu perangkat tenant: database SQLite di browser
   (`serverpod_database` sudah mendukung web lewat `sqlite_async` +
   wasm), menarik semua data tenant lewat pull F2-01, dan menulis lewat
   outbox yang sama. Semua layar, repositori, dan aturan domain dipakai
   ulang. Biaya: data toko tersalin ke browser (dihapus saat keluar atau
   sesi habis), pemuatan awal menunggu pull pertama, dan beberapa layanan
   berbasis berkas perlu versi web.
2. **Web membaca langsung API server** (aturan Storeku). Data selalu dari
   server tanpa salinan di browser, tetapi setiap repositori butuh versi
   API server dan endpoint baru; dashboard dulu, menu lain bertahap
   berbulan-bulan. Ditolak karena biaya dan duplikasi aturan bisnis.
3. **Hanya login + dashboard dari agregasi server.** Cepat, tetapi tidak
   memberi menu back office di web seperti desain 2.3. Ditolak sebagai
   tujuan akhir; bagian dashboard tetap dipakai di pendekatan 1.

*Catatan keputusan:* pilihan ditanyakan ke Yusuf lewat kartu keputusan
2026-11-28 dengan saran pendekatan 1; pekerjaan berjalan dengan saran itu
sampai ada jawaban.

**Perbedaan dari Storeku:** Storeku menulis web langsung ke API server;
Lakuna menjadikan browser perangkat sync (pendekatan 1). MFA Storeku
dikelola arium; Lakuna memakai TOTP buatan sendiri di atas akun email
Serverpod (`serverpod_auth_idp` 4.1 belum punya TOTP).

## Lingkup

Empat tahap, masing-masing satu rilis:

1. **Tahap 1 · Aplikasi jalan di browser (v0.169.0).** Build web tanpa CDN
   (`--no-web-resources-cdn`, aset sqlite wasm dibundel), layanan
   berbasis berkas punya versi web, browser hanya menawarkan *Masuk ke
   toko versi hosting* (sementara lewat kode pasang perangkat F2-01),
   menu Kasir dan fitur perangkat (backup lokal, printer Bluetooth, laci)
   disembunyikan di web. Job CI `Build web`.
2. **Tahap 2 · Login web pemilik (v0.170.0).** Layar 2.2: email + kata
   sandi + verifikasi 2 langkah (TOTP), *Ingat perangkat ini 30 hari*,
   *Lupa kata sandi?*; pengaturan verifikasi 2 langkah di kartu *Versi
   hosting* di aplikasi; endpoint server `webAccess`. Login web
   menggantikan kode pasang untuk browser.
3. **Tahap 3 · Dashboard semua cabang (v0.171.0).** Layar 2.3 di web dan
   di perangkat hosting: pemilih cabang, kartu KPI, tabel per cabang,
   grafik per jam, terlaris minggu ini, *Perlu perhatian*, *Unduh
   laporan*; status perangkat dari server.
4. **Tahap 4 · Web di paket VPS (v0.172.0).** Caddy menyajikan aplikasi
   web di `https://<domain>/app/`, image `lakuna-caddy` membawa build web,
   aset rilis `lakuna-<versi>-web.zip`, panduan `docs/server/vps.md` dan
   Panduan aplikasi.

## Desain UI (baseline)

- **2.2 Login web** (dua kolom, kolom kiri Sky): nama toko, "Pantau semua
  cabang dari mana saja.", "Versi web membaca data yang sudah
  disinkronkan dari kasir. Semua cabang, laporan, dan pengaturan dalam
  satu tempat.", lencana *Fase 2* dan *Butuh hosting aktif*. Kolom kanan:
  *Masuk*, Email, Kata sandi, *Ingat perangkat ini 30 hari* (dicentang),
  *Lupa kata sandi?*, kartu *Verifikasi 2 langkah* ("Masukkan 6 digit dari
  aplikasi authenticator.", 6 kotak digit), tombol *Masuk*, catatan
  "Login, sesi, dan MFA dikelola oleh Serverpod di server (Postgres). Kasir
  di perangkat tetap pakai PIN.", pilihan bahasa Indonesia / English.
  Di mobile kolom menumpuk.
  - *Perluasan:* nama toko di kolom kiri diganti "Lakuna" sebelum login
    (server melayani banyak toko). Alamat server: web yang disajikan dari
    server memakai alamat asalnya sendiri; build web lepas (uji lokal)
    menampilkan isian *Alamat server* di atas Email.
  - *Perluasan:* kartu verifikasi muncul setelah email + kata sandi benar
    (langkah 2), bukan sekaligus, agar kode tidak kedaluwarsa saat kata
    sandi salah.
- **2.3 Dashboard semua cabang**: sidebar menu dengan item bertanda *F2*
  (Dashboard semua cabang, Transfer stok, Cabang & perangkat, Sync);
  status bar "Online · sync 1 menit lalu" (chip sync F2-01). Judul,
  tanggal, "data tersinkron dari semua perangkat"; pemilih *Cabang*
  (*Semua cabang (n)* / per cabang), tombol *Unduh laporan*. Kartu:
  *Penjualan hari ini* (rupiah, n transaksi, n cabang), *Rata-rata per
  nota*, *Perangkat online* (x / y, "1 perangkat terakhir sync 3 jam
  lalu"), *Konflik sync* (n, "Perlu ditinjau"). Tabel *Per cabang hari ini*:
  Cabang (nama, kode, n perangkat), Penjualan, Transaksi, Sync terakhir,
  Status (Online / n perangkat offline), baris Total. *Penjualan per jam ·
  semua cabang* (grafik batang jam buka). *Terlaris minggu ini* (nama, n
  terjual). *Perlu perhatian* (konflik menunggu tinjauan, perangkat belum
  sync n jam, n produk di bawah minimum per cabang).
  - Item menu Transfer stok, Cabang & perangkat, dan Sync milik F2-03–05:
    tidak ditampilkan sampai modulnya ada.

## Aturan bisnis

### Browser sebagai perangkat hosting

1. Web hanya untuk toko versi hosting. Di web, aplikasi tidak menawarkan
   *Buat toko baru* atau mode offline; layar pertama adalah login web
   (tahap 2; tahap 1 memakai kode pasang perangkat).
2. Setiap login web yang berhasil membuat **perangkat web** baru di tenant
   (`devices.platform = web`) dengan token perangkat berumur terbatas,
   lalu menjalankan alur gabung F2-01 (aturan 10): database browser
   dimulai kosong dan menarik semua data tenant. Kode perangkat web
   `W01`, `W02`, … (unik per **tenant**, dibuat server, awalan `W` tidak
   dipakai perangkat kasir) sehingga nomor dokumen dari web (mis.
   penyesuaian stok `SA-KMG-W01-…`) tidak bentrok di outlet mana pun.
   Outlet asal perangkat web = outlet pertama tenant (urut `created_at`).
2a. *Keputusan builder:* di web bilah atas punya **pemilih cabang**. Menu
   back office (stok, laporan, pembelian, pengaturan outlet, dst.) bekerja
   pada cabang terpilih: `StoreContext` web bisa berganti outlet (perangkat
   tetap perangkat web), pilihan diingat di `local_preferences`. Dashboard
   punya pilihan *Semua cabang*. Perangkat kasir tidak berubah (tetap satu
   outlet).
3. Perangkat web **tidak membuat nota**: menu Kasir, Meja/Open bill, Kas
   laci, dan Shift tidak ada di web; rute itu dialihkan ke Beranda. Semua
   menu back office lain sama dengan perangkat, dibatasi izin staf.
4. Staf di web adalah **pemilik** tenant yang login (profil staf pemilik
   dari data tersinkron, semua izin pemilik). Tidak ada PIN di web.
   Login web untuk manajer dengan email: gap.
5. Sesi web: *Ingat perangkat ini 30 hari* dicentang → token berlaku 30
   hari sejak login; tidak dicentang → 12 jam. Setelah habis, server
   menolak token (`SyncAuthException`), aplikasi menghapus database browser
   dan kembali ke login. *Keluar* mencabut token di server lalu menghapus
   database browser. Token web tidak diperpanjang otomatis.
6. Database browser disimpan per asal (origin) di penyimpanan browser.
   Satu browser = satu sesi toko. Setiap sesi memakai nama database baru
   (`lakuna-<deviceId>.sqlite`) yang dicatat di `localStorage`.
   *Hasil spike tahap 1 (Chromium):* `sqlite3_web` memakai OPFS
   (`drift_db/<nama>`) tanpa header COOP/COEP, data bertahan setelah muat
   ulang, dan `sqlite3.wasm` + `db_worker.js` (dibundel di `web/`, dibuat
   `tool/web_sqlite_assets.sh`) termuat dari subpath `/app/`. Database sesi
   dihapus setelah ditutup dengan menghapus folder OPFS `drift_db/<nama>`
   dan database IndexedDB bernama sama (cadangan). Nama database yang harus
   dihapus dicatat di `localStorage` lebih dulu dan dihapus saat aplikasi
   dimulai sebelum database apa pun dibuka, sehingga penghapusan yang
   terputus diulang.
6a. Gabung di web tidak memakai database staging + tukar saat mulai ulang
   (`gabung/` F2-01): database sesi baru langsung diisi pull, lalu aplikasi
   pindah ke layar utama.
7. Tulis dari web memakai `LakunaStore.write` + outbox yang sama; sync
   web berjalan saat tab terbuka dan langsung setelah setiap tulis.
   Menutup tab dengan perubahan belum terkirim memunculkan konfirmasi
   browser (`beforeunload`).

### Layanan berbasis berkas di web

8. Gambar: di web berkas media tidak ditulis ke folder; `readMediaFile`
   mengunduh lewat URL sementara F2-01 dan menyimpannya di cache memori
   tab (maks. 64 MB, LRU). Unggah gambar dari web (mis. foto produk)
   menyimpan bytes di cache memori yang sama dalam keadaan *tersemat*
   (tidak dibuang LRU) sampai terunggah; selama masih ada, gambar itu
   dihitung sebagai perubahan belum terkirim (aturan 7). *Keputusan
   rencana:* tidak memakai tabel lokal sementara.
9. Backup lokal, backup otomatis, pulihkan, printer Bluetooth, dan pemilih
   folder tidak ada di web. Cetak struk/laporan di web memakai dialog
   cetak browser (PDF). Ekspor Excel/PDF mengunduh berkas lewat browser.
10. Token perangkat di web disimpan di `local_preferences` database browser
    (bukan berkas vault); terhapus bersama database.

### Login web dan verifikasi 2 langkah (TOTP)

11. Login web memakai akun email Serverpod pemilik (yang sama dengan
    aktivasi F2-01). Hanya akun yang terdaftar di `tenant_owners` yang
    boleh membuka perangkat web; akun tanpa tenant mendapat pesan *Akun
    ini belum punya toko versi hosting*.
12. Verifikasi 2 langkah **wajib** untuk login web. Pemilik mengaktifkannya
    dari kartu *Versi hosting* di aplikasi perangkat: setelah PIN pemilik,
    aplikasi meminta email + kata sandi akun pemilik lagi (sesi JWT hanya di
    memori; perangkat hasil kode pasang belum pernah login), lalu server
    membuat rahasia TOTP (RFC 6238, SHA-1, 6
    digit, 30 detik, 160 bit), aplikasi menampilkan kode QR
    `otpauth://totp/Lakuna:<email>?secret=…&issuer=Lakuna` dan rahasia
    teks, pemilik memasukkan satu kode untuk mengonfirmasi. Sebelum
    dikonfirmasi rahasia tidak berlaku. Login web akun tanpa TOTP aktif
    ditolak dengan petunjuk mengaktifkannya di aplikasi.
13. Kode TOTP diterima untuk langkah waktu sekarang ±1; kode yang sudah
    dipakai (langkah yang sama) ditolak. Lima kode salah berturut-turut
    mengunci login web akun itu 15 menit. Rahasia TOTP disimpan di server
    terenkripsi dengan kata sandi server baru `totpEncryptionKey`
    (variabel `TOTP_ENCRYPTION_KEY` di `.env` paket VPS)
    (AES-GCM); bila kata sandi itu kosong server menolak mengaktifkan TOTP.
13a. Satu akun email bisa memiliki lebih dari satu tenant: setelah kata
    sandi dan TOTP benar, login web menampilkan pilihan toko bila tenant
    akun itu lebih dari satu. TOTP melekat ke akun, bukan tenant.
14. Kode cadangan: saat TOTP dikonfirmasi server membuat 8 kode cadangan
    sekali pakai (ditampilkan sekali, disimpan hash-nya) yang bisa
    dipakai di kotak verifikasi. Nonaktifkan / atur ulang TOTP dari kartu
    *Versi hosting* (butuh PIN pemilik dan kode TOTP atau kode cadangan).
14a. Kehilangan authenticator dan kode cadangan: admin server menjalankan
    `lakuna-admin totp-reset --email <email>` (CLI di container), lalu
    pemilik mengaktifkan ulang dari aplikasi.
15. *Lupa kata sandi?* memakai alur reset kata sandi email Serverpod
    (kode ke email, kata sandi baru diketik dua kali sesuai aturan
    kredensial Lakuna).

### Dashboard semua cabang

16. Semua angka dihitung di perangkat dari data tersinkron dengan fungsi
    domain yang sama dengan Laporan (penjualan = nota final dikurangi
    void/retur sesuai aturan Laporan F1-16), per tanggal lokal masing-masing
    outlet. "Hari ini" = tanggal lokal outlet; *Semua cabang* menjumlahkan
    per outlet.
17. *Rata-rata per nota* = penjualan ÷ jumlah transaksi (pembulatan rupiah
    ke bawah, 0 bila tanpa transaksi).
18. *Perangkat online*: perangkat (kecuali perangkat web) dengan
    `last_seen_at` di server ≤ 10 menit lalu. *Sync terakhir* per cabang =
    `last_seen_at` terbaru perangkat cabang itu. Status per cabang:
    *Online* bila semua perangkat online, selain itu *n perangkat
    offline*. Data perangkat dan konflik diambil dari endpoint server
    `sync.tenantStatus(token)` saat dashboard dibuka dan setiap 60 detik;
    offline → kartu menampilkan "Status perangkat butuh internet".
19. *Konflik sync* = jumlah baris `sync_conflicts` tenant dengan
    `resolved_at` kosong (dari `tenantStatus`); tautan ke layar F2-03 saat
    modul itu ada, sebelumnya ke kartu *Versi hosting*.
20. *Penjualan per jam*: jumlah penjualan per jam lokal hari ini, semua
    cabang atau cabang terpilih, jam 00–23 dengan sumbu dipotong ke jam
    pertama dan terakhir yang ada transaksi (minimal 08–17).
21. *Terlaris minggu ini*: 5 produk teratas berdasarkan jumlah terjual 7
    hari terakhir (termasuk hari ini), per varian digabung ke produk.
22. *Perlu perhatian*: konflik menunggu tinjauan, perangkat belum sync > 1
    jam (per perangkat), produk di bawah stok minimum per cabang (stok
    cabang itu dibanding satu nilai minimum per varian `min_stock_milli`;
    jumlah, tautan ke Stok minimum). Kosong → "Semua beres".
23. *Unduh laporan*: Excel ringkasan dashboard (KPI, per cabang, per jam,
    terlaris) untuk pilihan cabang saat ini.
24. Dashboard tampil di web dan di perangkat hosting bagi staf dengan izin
    `reports:view`; tanpa `reports:view_profit` tidak ada angka laba (dashboard
    memang tidak menampilkan laba).

### Web di paket VPS

25. Caddy menyajikan build web di `/app/` (SPA: rute tak dikenal ke
    `/app/index.html`, `index.html` tanpa cache). Header COOP/COEP tidak
    dipasang: spike tahap 1 menunjukkan SQLite wasm memakai OPFS tanpa
    keduanya, dan COEP akan memblokir gambar dari domain media. Aplikasi
    web memakai asal yang sama sebagai alamat server, jadi tidak perlu CORS.
25a. Gambar di object storage (profil `s3`, domain `MEDIA_DOMAIN`) berasal
    lain: situs media di Caddy menambah `Access-Control-Allow-Origin:
    https://<LAKUNA_DOMAIN>`, metode GET/PUT, header `Content-Type`, agar
    unduh dan unggah presigned dari web tidak diblokir CORS. Penyedia S3 lain
    perlu aturan CORS yang sama (panduan).
25b. Endpoint `webAccess` masuk zona batas laju `auth` Caddy.
26. `https://<domain>/` (tanpa path) mengalihkan ke `/app/`. Endpoint API
    tetap di path yang sama (POST `/<endpoint>/<method>`), `/readyz` tetap.

## Data

Server (tabel baru, `database: server`, `serverOnly: true`):

- `owner_totp` — `auth_user_id` (unik), `secret_encrypted`, `confirmed_at`,
  `last_used_step`, `failed_attempts`, `locked_until`, `created_at`,
  `updated_at`.
- `owner_backup_codes` — `auth_user_id`, `code_hash`, `used_at`.
- `device_credentials` + kolom `expires_at` (null = perangkat biasa).

Klien: tidak ada tabel bisnis baru. Kunci `sync_state`/`local_preferences`
baru untuk token web dan masa berlaku sesi.

## Izin

Sama dengan aplikasi. Dashboard: `reports:view`. Pengaturan TOTP: pemilik
(akun email tenant) + `sync:manage`. Login web: pemilik tenant.

## Kasus tepi

- Pull pertama di browser lama (toko besar): layar *Menyiapkan data toko*
  dengan progres "n dari m perubahan" (balasan pull diberi `headSeq`
  server, field baru di `SyncPullPage`) dan tombol *Batal* (keluar).
  Setiap login web menarik ulang seluruh log perubahan tenant dari awal;
  pull snapshot di server dicatat sebagai gap.
- Browser privat / penyimpanan ditolak: pesan "Browser ini tidak
  mengizinkan penyimpanan data. Matikan mode privat atau pakai browser
  lain."
- Dua tab membuka web yang sama: tab kedua menampilkan "Lakuna sudah
  terbuka di tab lain" (kunci Web Locks) agar database tidak dibuka dua
  kali.
- Jam komputer salah > 90 detik: TOTP gagal; pesan menyarankan cek jam.
- Server lebih lama dari aplikasi web: tidak mungkin di paket VPS (web dan
  server dari rilis yang sama); build web lepas memakai pemeriksaan versi
  F2-01.
- Pemilik mencabut perangkat web dari F2-04 (nanti): sesi berakhir seperti
  token habis.

## Pengujian (TDD)

- Domain (`lakuna_domain`): TOTP (vektor uji RFC 6238), jendela ±1,
  penolakan pakai ulang, agregasi dashboard (penjualan, rata-rata, per jam,
  terlaris, perangkat online/offline).
- Server: endpoint `webAccess` (login → perangkat web, wajib TOTP, kunci
  setelah 5 salah, kode cadangan, token habis ditolak), `tenantStatus`,
  enkripsi rahasia.
- Data (`lakuna_data`): kueri dashboard multi-outlet, sesi web (hapus
  database saat keluar/habis), media cache memori.
- Flutter: view model login web (langkah, galat, kunci), dashboard, rute
  web (Kasir dialihkan), widget dengan `debugDefaultTargetPlatformOverride`
  tidak cukup untuk web → logika "apakah web" disuntik lewat
  `AppPlatform` agar teruji di VM.
- CI: job `Build web` (`flutter build web --release --no-web-resources-cdn`).
- Manual: Chromium headless (Playwright) membuka build web yang disajikan
  Caddy lokal: login, pull, dashboard, ubah harga produk lalu cek tersinkron
  ke perangkat Linux di Xvfb. Tangkapan layar setiap layar baru, terang dan
  gelap.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Aplikasi jalan di browser | — | Belum | Tahap 1. |
| Login web + TOTP | 2.2 | Belum | Tahap 2. |
| Dashboard semua cabang | 2.3 | Belum | Tahap 3. |
| Web di paket VPS | — | Belum | Tahap 4. |
| Login web manajer | 2.2 | Belum | Hanya pemilik (akun email tenant). |
| Kasir di web | — | Tidak direncanakan | Kasir tetap di perangkat dengan PIN. |
| Item menu F2-03–05 | 2.3 | Belum | Muncul bersama modulnya. |
| Pull snapshot untuk perangkat baru | — | Belum | Login web menarik seluruh log perubahan tenant. |

## Kriteria selesai

Pemilik membuka `https://<domain>/app/` dari paket VPS, login dengan email,
kata sandi, dan TOTP, melihat dashboard semua cabang dari data tersinkron,
membuka menu back office, dan perubahan dari web sampai ke perangkat kasir;
tes domain, server, data, dan widget hijau; build web di CI.
