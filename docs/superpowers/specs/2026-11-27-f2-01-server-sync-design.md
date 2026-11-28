# F2-01 · Server sync & aktivasi hosting

- **Fase:** 2 (modul 1)
- **Status:** Tahap 1 (server) rilis v0.164.0, tahap 2 (mesin sync perangkat) rilis v0.165.0, tahap 3 (aktivasi, chip status, gabung perangkat) rilis v0.166.0; tahap 4–5 menyusul. Fondasi sudah ada sejak v0.1.0:
  kolom sync di setiap tabel, `sync_outbox` terisi di transaksi yang sama
  (`SyncTx`), HLC monoton di `sync_state`, ID UUIDv7 dibuat di perangkat.
- **Layar desain:** 2.1 *Aktivasi versi hosting* (stepper), kartu *Versi
  hosting* di Pengaturan, chip status sync di bilah atas (sekarang
  *Offline · data di perangkat ini*). Bila artboard 2.1 belum ada di kanvas
  Lakuna, layar dibuat mengikuti baseline Storeku 2.1 dengan komponen Forui
  dan dicatat di sini.
- **Acuan:** spec Storeku `2026-11-02-f2-01-server-sync-design.md` (aturan
  disalin di bawah, perbedaan dicatat), spec F0 Lakuna bagian *Sync* dan
  *Deploy server*, keputusan Yusuf 2026-11-03 (server di **VPS sendiri**
  dengan Docker, bukan Serverpod Cloud).

## Tujuan

UMKM yang memilih versi hosting bisa memindahkan semua data dan gambar dari
perangkatnya ke server miliknya sendiri, lalu semua perangkat di semua
cabang tersinkron otomatis. Kasir tetap bekerja penuh tanpa internet: sync
berjalan di latar belakang dan kegagalan jaringan tidak pernah menahan
transaksi.

Ukuran berhasil:

- Dua perangkat yang sama-sama berjualan offline lalu online kembali
  berakhir dengan data yang sama (konvergen), tanpa nota hilang atau
  ganda.
- Aktivasi perangkat pertama dengan data Fase 1 yang sudah berjalan
  berbulan-bulan selesai tanpa mengubah ID atau nomor dokumen apa pun, dan
  bisa dijeda/dilanjutkan.
- Pemilik bisa memasang server di VPS dengan satu `docker compose up` dan
  panduan tertulis.

Bukan tujuan modul ini: versi web dan dashboard semua cabang (F2-02), layar
tinjau konflik (F2-03), kelola cabang dan cabut perangkat (F2-04), transfer
stok (F2-05).

Anti-tujuan (gagal walau "jalan"):

- Kasir menunggu jaringan untuk menyimpan transaksi.
- Data satu tenant terlihat oleh perangkat tenant lain.
- Sync diam-diam menimpa nota atau pembayaran yang sudah final.

## Pendekatan yang dipertimbangkan

1. **Outbox + endpoint `push`/`pull` Serverpod buatan sendiri (dipilih).**
   Memakai fondasi yang sudah ada sejak v0.1.0 (outbox per baris, payload
   JSON baris utuh, HLC). Server menyimpan baris di tabel Postgres yang
   sama (skema satu sumber dari `.spy.yaml`) dan log perubahan berurutan
   untuk pull. Kendali penuh atas aturan konflik, izin tenant, dan
   unggah data awal.
2. **`database: sync` + modul `serverpod_offline_sync`.** Serverpod 4.1
   sudah punya opsi model `database: sync`, tetapi masih fitur eksperimen
   (`experimental_features: databaseSync`), modulnya 0.0.x, dan setiap
   tabel wajib punya kolom `spaceId` ke `offline_sync_spaces`. Memakainya
   berarti mengubah 46 model `database: all` dan semua repositori Fase 1,
   dan aturan konfliknya tidak bisa dibedakan per jenis tabel (dokumen
   final vs master). Dievaluasi lagi saat stabil; protokol di sini sengaja
   sederhana supaya bisa diganti.
3. **Layanan replikasi pihak ketiga (PowerSync, ElectricSQL, dll.).**
   Bertentangan dengan keputusan server sendiri di VPS dan menambah
   layanan berbayar/eksternal. Ditolak.

## Lingkup

Termasuk:

- Endpoint Serverpod `sync` (`push`, `pull`, `status`) dan `activation`
  (`activateFirstDevice`, `createPairingCode`, `joinWithPairingCode`).
- Mesin sync klien di `lakuna_data` (`SyncEngine`) dengan transport
  abstrak (palsu untuk tes, Serverpod client untuk aplikasi).
- Unggah data awal yang bisa dijeda/dilanjutkan, dengan progres per
  kelompok.
- Aset (stiker QRIS, foto produk) ke object storage S3-compatible.
- Chip status sync dan kartu *Versi hosting* di Pengaturan; layar 2.1.
- Paket deploy VPS: `docker-compose` (server, Postgres, MinIO opsional,
  Caddy untuk HTTPS), berkas contoh konfigurasi, dan panduan pasang.

Tidak termasuk: lihat *Bukan tujuan* di atas. Izin per aksi di server
(selain batas tenant/outlet) dicatat sebagai gap.

## Desain UI (baseline)

**Kartu Versi hosting (Pengaturan, izin `sync:manage`).** Status
*Belum aktif* dengan tombol **Aktifkan versi hosting**, atau *Aktif ·
server `sync.tokocontoh.id`* dengan waktu sync terakhir, jumlah perubahan
menunggu, tombol **Sync sekarang**, dan **Buat kode pasang perangkat**.

**Layar 2.1 Aktivasi (stepper 4 langkah).**

```
[1 Server & kode ✓]──[2 Login pemilik ✓]──[3 Unggah data]──[4 Selesai]
Server: https://sync.tokocontoh.id · Postgres · gambar ke object storage

Produk, varian & satuan        1.240 / 1.240  ✓
Pelanggan & supplier             312 / 312    ✓
Transaksi penjualan            8.410 / 15.002 ▓▓▓▓▓░░░
Pergerakan stok                    0 / 22.310
Gambar                             0 / 48
Kasir tetap bisa dipakai selama proses ini. ID data dibuat di perangkat,
jadi tidak diubah saat masuk server, dan unggahan dilanjutkan bila koneksi
putus.                                   [Jeda unggahan]
```

1. **Server & kode aktivasi:** pilih **Server Lakuna** atau **Server
   sendiri** (lihat *Pengoperasian server*); untuk server sendiri ketik
   alamatnya (https wajib, kecuali `localhost` untuk uji). Lalu kode
   aktivasi dari admin server; tombol
   **Periksa** memanggil `status` dan menampilkan versi server.
2. **Login pemilik:** email + kata sandi akun pemilik di server (auth email
   Serverpod yang sudah ada di `lakuna_server`, OTP email saat daftar).
   Akun baru bisa dibuat di langkah ini. Kata sandi memakai aturan ketik
   ulang (lihat aturan kredensial Lakuna).
3. **Unggah data:** seperti sketsa di atas; bisa dijeda.
4. **Selesai:** ringkasan, lalu sync otomatis menyala.

**Pasang perangkat lain.** Di perangkat yang sudah aktif: **Buat kode pasang
perangkat** menampilkan kode 8 karakter yang berlaku 15 menit. Di perangkat
baru (layar onboarding, pilihan *Gabung ke toko yang sudah memakai
hosting*): alamat server + kode, pilih cabang dan kode perangkat, lalu data
ditarik dari server.

**Chip status di bilah atas.** *Offline · data di perangkat ini* (belum
aktif), *Tersinkron · 14.32*, *Menyinkronkan… (120)*, *Menunggu jaringan
(35)*, *Perlu perhatian* (galat atau konflik; ketuk membuka kartu Versi
hosting). Mobile: ikon saja dengan titik warna.

*Perluasan (tahap 3):* chip keenam *Sync dijeda (n)* saat sync dijeda dari
kartu Versi hosting (**Jeda sync** / **Lanjutkan sync**; di langkah 3
tombolnya **Jeda unggahan**). Jeda tersimpan di `sync_state` dan berlaku
setelah aplikasi dibuka ulang. Galat di kartu dijelaskan per jenis: jam
perangkat tidak sesuai, server menolak token, server tidak bisa dihubungi.
Layar onboarding mendapat kartu *Gabung ke toko yang sudah memakai
hosting*; kartu Versi hosting yang belum aktif juga punya tombol itu.

## Aturan bisnis

### Protokol

1. **Push.** Klien mengirim entri `sync_outbox` berstatus `pending` urut
   **urutan sisip** (`id` outbox), bukan urut `hlc`: baris induk selalu
   ditulis sebelum anaknya di perangkat, jadi urutan sisip menjaga FK.
   Batch maks 500 entri atau 1 MB (`maxRequestSize` server dinaikkan ke
   4 MB). Setiap entri: `table_name`, `row_id`, `op`, `payload_json` (baris
   utuh; perangkat asal dibaca dari `originDeviceId` di payload dan harus
   sama dengan perangkat token), `hlc`. Server menerapkan satu batch dalam
   satu transaksi, **setiap entri dalam savepoint** sendiri (FK Postgres
   tidak deferrable, jadi galat satu entri tidak boleh membatalkan batch),
   dan membalas hasil per entri: `applied`, `stale` (HLC server lebih baru;
   balasan memuat baris server), `merged` (aturan 7b/8b; balasan memuat
   baris server), atau `rejected` dengan alasan (`tenant`, `table`,
   `device`, `final`, `unique`, `dependency`, `clock`). Klien menandai
   `acked` untuk `applied`/`stale`/`merged` dan `conflict` untuk
   `rejected`, lalu menghapus entri `acked` yang lebih tua dari 7 hari.
   Kirim ulang aman: entri dengan `(row_id, hlc)` yang sudah diterapkan
   dibalas `applied` lagi tanpa efek.
2. **Pull.** Klien meminta perubahan dengan `seq > last_seq` (disimpan di
   `sync_state`), maks 1.000 per halaman, dibatasi **tenant** perangkat.
   *Keputusan Claude:* modul ini menarik semua outlet tenant, karena piutang
   dan batas kredit pelanggan dihitung se-tenant, `debt_payment_allocations`
   bisa menunjuk nota outlet lain, dan delapan tabel anak tidak punya
   `outlet_id`. Pull per outlet adalah optimasi untuk nanti (gap).
   Perubahan yang asalnya perangkat ini sendiri dilewati. Klien menerapkan
   dengan aturan LWW yang sama (setiap perubahan dalam savepoint), lalu
   menyimpan `last_seq` di transaksi yang sama. Baris yang diterapkan dari
   pull **tidak** menambah outbox. Perubahan yang gagal diterapkan di
   perangkat (mis. FK ke baris yang ditolak) disimpan di
   `sync_state.pull_parked` dan dicoba lagi setiap siklus; kursor tetap
   maju.
3. **Urutan siklus:** push sampai outbox kosong (atau galat), lalu pull
   sampai habis. Satu siklus pada satu waktu per perangkat.
4. **Jadwal:** saat aktif dan online, siklus jalan 2 detik setelah tulis
   terakhir (debounce), setiap 30 detik, dan saat aplikasi kembali ke
   depan. Galat jaringan memakai backoff eksponensial sampai 5 menit.
   Tidak ada siklus saat versi hosting belum aktif.

### Konflik (LWW per baris)

5. Pemenang per baris = HLC terbesar (urutan teks HLC sama dengan urutan
   waktu, F0). Seri HLC tidak mungkin karena HLC memuat node perangkat.
6. Baris yang kalah dicatat di `sync_conflicts` (server) bila nilainya
   berbeda dan asalnya perangkat lain, untuk ditinjau di F2-03. Modul ini
   hanya mencatat.
7. **Dokumen final** hanya boleh berubah lewat transisi yang memang ada di
   Fase 1, apa pun perangkatnya:
   - `sales.status`: `open` → `completed` → `partiallyReturned` →
     `returned`, dan `completed`/`partiallyReturned` → `voided` (beserta
     `voided_at`, `void_reason`, dsb.);
   - `debt_payments`, `payments` hutang, `cash_movements`: hanya mengisi
     kolom `voided_at`/alasan;
   - `purchases`: `draft` → `received` (dan retur/void seperti penjualan).
   7a. Pembaruan yang mengubah kolom isi dokumen final (total, item, nomor,
   tanggal) ditolak (`rejected`, alasan `final`) dan konflik dicatat.
   7b. Dua transisi status yang bersaing digabung **monoton**, bukan LWW:
   urutan kekuatan `voided` > `returned` > `partiallyReturned` >
   `completed` > `open`. Status tidak pernah mundur; kolom void ikut dari
   versi `voided`. Balasan `merged` membawa baris hasil gabung. Contoh:
   kasir A meretur sebagian saat kasir B mem-void offline → hasil
   `voided`; baris retur A tetap ada (ledger) dan muncul di laporan
   sebagai retur atas nota yang di-void, ditinjau di F2-03.
   7c. Ledger (pergerakan stok, pembayaran, alokasi, baris retur) hanya
   pernah disisipkan, jadi tidak bentrok. Open bill memakai LWW biasa.
8. **Kunci unik.** Server hanya menegakkan indeks unik database yang ada di
   model (nomor dokumen per tenant, kode outlet, kode perangkat per
   outlet, kunci role, anggota outlet, `settings (tenant_id, scope_key,
   key)`).
   8a. Baris dengan ID baru yang bentrok dengan indeks unik ditolak
   (`rejected`, alasan `unique`), konflik dicatat.
   8b. Pengecualian `settings`: bentrok kunci alami digabung LWW ke baris
   server yang sudah ada (`merged`); klien menghapus baris lokalnya dan
   memakai baris server.
   8c. Keunikan yang hanya dijaga kode aplikasi (SKU/barcode, nama
   kategori, telepon pelanggan, nama supplier, dll.) **tidak** ditolak
   server. Duplikat dari dua perangkat masuk apa adanya dan ditampilkan
   sebagai *kemungkinan ganda* di F2-03.
8d. **Nasib baris yang ditolak** (*keputusan Claude*): perangkat
   menyimpan barisnya, entri outbox berstatus `conflict`, dan baris yang
   bergantung padanya ikut ditolak dengan alasan `dependency` lalu dicoba
   ulang setiap siklus (berhasil setelah induknya diselesaikan di F2-03).
   Chip menampilkan *Perlu perhatian*. Ukuran berhasil "isi tabel sama"
   berlaku untuk tenant tanpa konflik terbuka.

### Tenant, perangkat, dan aktivasi

9. **Perangkat pertama** mengaktifkan hosting untuk tenant lokalnya dengan
   **kode aktivasi** sekali pakai yang dibuat admin server (lihat
   *Pengoperasian server*): server membuat tenant dengan **ID yang sama**
   (UUIDv7 dari perangkat), menautkan akun pemilik, lalu menerima unggah
   data awal. Satu tenant hanya bisa diaktifkan sekali.
10. **Perangkat berikutnya** bergabung lewat kode pasang. *Keputusan
    Claude:* perangkat yang bergabung memulai dari data server; data lokal
    yang sudah ada (tenant lain hasil onboarding Fase 1) **tidak
    digabung**. Sebelum bergabung, aplikasi wajib membuat backup otomatis
    (format backup F1-19) lalu mengganti database lokal. Alasannya: dua
    tenant lokal punya ID produk, kategori, dan pelanggan berbeda untuk
    barang yang sama, dan menggabungkannya butuh pencocokan manual yang
    masuk akal hanya di F2-03. UI memperingatkan bila database lokal berisi
    penjualan.
10a. **Perangkat hasil salinan backup.** Backup F1-19 membawa ID dan kode
    perangkat, jadi dua perangkat hidup bisa punya ID yang sama. Server
    menolak aktivasi atau pasang bila ID perangkat itu sudah punya token
    aktif (*Perangkat ini salinan dari perangkat lain*). Perangkat yang
    bergabung lewat kode pasang **selalu** mendapat ID dan kode perangkat
    baru dari langkah pasang, sehingga node HLC dan nomor nota tidak
    pernah sama.
11. Perangkat mendapat **token perangkat** (rahasia acak 256 bit, server
    menyimpan hash-nya) yang terikat ke tenant dan perangkat. Semua `push`/
    `pull` memakai token ini, bukan sesi staf. Cabut token ada di F2-04.
12. Server memeriksa setiap perubahan: `tenant_id` baris = tenant token;
    `outlet_id` (bila ada) termasuk outlet tenant; `origin_device_id` =
    perangkat token; tabel ada di daftar tabel sync. Tabel `database:
    client` (`sync_outbox`, `sync_state`, `local_preferences`,
    `stock_levels`) tidak pernah dikirim.
13. **HLC masa depan:** perubahan dengan waktu HLC > waktu server + 5 menit
    ditolak (`rejected`, alasan `clock`) dan chip menampilkan *Jam perangkat
    tidak sesuai*. Waktu server dikirim di setiap balasan; klien memajukan
    HLC lokal bila waktu server lebih besar (HLC `receive`). Saat aktivasi
    perangkat pertama, bila `last_hlc` lokal lebih dari 5 menit di depan
    waktu server, semua entri snapshot (aturan 15) **distempel ulang** dengan
    HLC baru dari waktu server dan `last_hlc` diturunkan. Ini aman karena
    tenant itu belum punya data di server. Perangkat yang bergabung memulai
    dari data server, jadi tidak membawa HLC lama.
14. Mengaktifkan hosting mengubah `tenants.plan` menjadi `hosted`.

### Unggah data awal

15. Saat aktivasi, outbox lama (riwayat setiap versi sejak instal, sebagian
    dengan skema lama) **dipadatkan**: dihapus, lalu diganti satu entri
    snapshot per baris yang ada sekarang, dengan HLC baris itu (atau HLC
    baru menurut aturan 13), disisipkan dalam urutan dependensi tabel
    (`syncTables`: tenant, outlet, lokasi, perangkat, staf, master, dokumen,
    ledger, media) dan di dalam tabel urut induk sebelum anak untuk tabel
    yang merujuk dirinya sendiri (kategori). Karena push urut sisip,
    urutan ini yang dipakai server. Penandanya `sync_state.initial_upload`
    (`pending`/`done`) dan `initial_upload_cursor` (tabel + ID terakhir)
    agar pemadatan bisa dilanjutkan; tulisan baru selama pemadatan masuk
    outbox seperti biasa setelah snapshot tabelnya.
16. Progres per kelompok = jumlah entri `acked` / total entri kelompok itu.
    *Jeda unggahan* menghentikan siklus sampai dilanjutkan; kasir tetap
    jalan dan tulisan baru masuk outbox seperti biasa.

### Cache turunan di perangkat

17. Setelah pull, `stock_levels` untuk varian+lokasi yang tersentuh
    dihitung ulang dari `stock_movements` (urut `occurred_at`, lalu `hlc`;
    `rebuildStockLevels` sekarang urut `occurred_at, id` dan diubah),
    termasuk rata-rata biaya, karena pergerakan dari perangkat lain bisa
    datang terlambat. Saldo hutang/piutang sudah dihitung dari ledger saat
    dibaca, jadi tidak perlu dibangun ulang.
18. Penghitung nota tetap per perangkat (`devices.receipt_counter`), dan
    nomor nota memuat kode outlet + perangkat (F0), jadi dua perangkat
    tidak pernah membuat nomor yang sama.

### Aset

19. Berkas media disimpan di object storage dengan kunci
    `<tenant_id>/<storage_key>` (`storage_key` = `<sha256>.<ext>`, F0).
    Setelah baris `media_files` di-push, klien meminta URL unggah
    ter-presign, mengunggah, lalu memanggil `markUploaded`. Unggah ulang
    berkas dengan hash sama dilewati.
20. Perangkat lain mengunduh berkas saat pertama dibutuhkan (lazy) ke
    `<folder data>/media/` dan memeriksa hash. Gambar yang belum terunduh
    menampilkan placeholder, bukan galat.

## Pengoperasian server

*Keputusan Yusuf 2026-11-27 (kartu keputusan, pilihan "Keduanya"):* server
dirancang **multi-tenant** dan dipakai dengan dua cara, dari image dan
paket deploy yang **sama**:

- **Server hosting Yusuf.** Satu server di VPS Yusuf melayani banyak toko
  pelanggan versi hosting (dasar dashboard semua cabang di F2-02). Yusuf
  sebagai admin server membuat kode aktivasi lewat CLI di container
  (`lakuna-admin activation-code --note "Toko Ani"`) dan memberikannya ke
  pemilik toko.
- **Server sendiri.** Toko yang ingin datanya di VPS sendiri memasang paket
  yang sama mengikuti panduan pasang. Pemilik toko itu sendiri yang menjadi
  admin server dan menjalankan perintah CLI yang sama untuk membuat kode
  aktivasinya. Tidak ada mode server khusus atau kata sandi setup: kode
  aktivasi sekali pakai sudah menjaga siapa yang boleh membuat tenant,
  sehingga server sendiri yang alamatnya diketahui orang lain tetap aman.

Akibatnya di aplikasi dan dokumen:

- Langkah 1 layar 2.1 punya pilihan **Server Lakuna** (alamat bawaan dari
  `--dart-define=LAKUNA_HOSTING_URL` saat build rilis; pilihan ini
  disembunyikan bila nilainya kosong) dan **Server sendiri** (alamat
  diketik). Keduanya memakai kode aktivasi. Gabung perangkat lain memakai
  alamat yang tersimpan di perangkat pertama lewat kode pasang, jadi
  pengguna tidak perlu mengetik alamat lagi bila memindai/menyalin kode
  pasang lengkap (`<alamat>#<kode>`); mengetik alamat + kode tetap bisa.
- Tidak ada alamat server yang ditanam di kode selain nilai `dart-define`
  itu, dan aplikasi tidak pernah menghubungi server sebelum pemilik
  mengaktifkan hosting.
- Panduan pasang `docs/server/` ditulis untuk dua pembaca: **admin server
  hosting** (banyak toko, pemantauan, kuota disk) dan **pemilik toko yang
  memasang sendiri** (satu toko, langkah dari sewa VPS sampai kode
  aktivasi pertama).
- `status` mengembalikan versi server dan versi protokol sync. Aplikasi
  menolak server dengan protokol lebih lama dari yang didukung (*Server
  perlu diperbarui*), karena server sendiri bisa tertinggal versi.

- **Email OTP:** konfigurasi sekarang memakai `ServerpodCloudEmailIdpConfig`
  (mengirim email lewat Serverpod Cloud) dan diganti ke
  `EmailIdpConfigFromPasswords` dengan pengirim SMTP dari `passwords.yaml`
  / variabel lingkungan (mis. SMTP penyedia email domain Yusuf). Kredensial
  SMTP adalah tugas pemilik.
- **docker-compose:** `server` (image `lakuna_server/Dockerfile`),
  `postgres` (volume tetap), `minio` (opsional; bisa diganti S3
  penyedia), `caddy` (HTTPS otomatis Let's Encrypt). Backup Postgres
  harian (`pg_dump`) ke volume dan object storage.

## Data

Model baru di `lakuna_server/lib/src/sync/` (migrasi `--tag sync-server`):

| Model | Tabel | `database` | Isi |
| --- | --- | --- | --- |
| `SyncChange` | `sync_changes` | server | `seq` (bigserial via `id` int), `tenant_id`, `outlet_id?`, `table_name`, `row_id`, `hlc`, `origin_device_id`, `payload_json`, `received_at`. Indeks `(tenant_id, id)` dan unik `(row_id, hlc)` |
| `SyncConflict` | `sync_conflicts` | server | `tenant_id`, `table_name`, `row_id`, `winner_hlc`, `loser_hlc`, `loser_device_id`, `loser_payload_json`, `reason`, `created_at`, `resolved_at?` |
| `DeviceCredential` | `device_credentials` | server | `tenant_id`, `device_id`, `token_hash`, `created_at`, `last_seen_at`, `revoked_at?` |
| `PairingCode` | `pairing_codes` | server | `tenant_id`, `code_hash`, `created_by_device_id`, `expires_at`, `used_at?` |
| `ActivationCode` | `activation_codes` | server | `code_hash`, `note` (nama toko pemesan), `created_at`, `expires_at`, `used_at?`, `tenant_id?` |
| `TenantOwner` | `tenant_owners` | server | `tenant_id`, `auth_user_id` (akun Serverpod auth) |

`server` di sini berarti model tanpa tabel di SQLite perangkat (Serverpod
`database: server`). Tabel bisnis yang sudah ada (`database: all`) dipakai
apa adanya di Postgres.

Klien: kunci baru di `sync_state`: `server_url`, `sync_paused`,
`last_seq`, `initial_upload`, `initial_upload_cursor`,
`initial_upload_acked`, `last_sync_at`, `last_error`, `pull_parked`.
Tidak ada tabel klien baru.

*Keputusan Claude (tahap 3):* progres per kelompok (aturan 16) hanya untuk
unggah awal. `initial_upload_acked` menjadi `1` setelah siklus pertama yang
tuntas tanpa perubahan menunggu (perangkat gabungan langsung `1`); sesudahnya
perubahan baru cukup dihitung *N perubahan menunggu* di kartu dan chip.

*Keputusan Claude (tahap 3):* token perangkat **tidak** disimpan di
database, tetapi di berkas `<folder data>/hosting/device-token` (izin 600
di Linux/macOS). Alasannya: backup F1-19 menyalin database, jadi token di
database ikut terbawa ke perangkat lain dan membuat dua perangkat memakai
satu token. Memulihkan backup mematikan versi hosting di perangkat itu
(token dihapus, `server_url` dikosongkan). Penyimpanan aman platform
(Keychain/Keystore/libsecret) dicatat sebagai gap.

*Keputusan Claude (tahap 3):* gabung perangkat disiapkan di
`<folder data>/gabung/` (database baru, data ditarik penuh dari server,
konteks toko harus lengkap), lalu dipasang saat aplikasi dimuat ulang
sebelum database dibuka. Data lama dipindah ke
`<folder data>/sebelum-gabung-<YYMMDD-HHMM>/`. Pemasangan aman bila
aplikasi mati di tengah. Daftar cabang untuk kode pasang diambil dari
endpoint baru `activation.pairingOutlets` (kode diperiksa, belum dipakai).

Daftar tabel sync dan urutan dependensinya ditulis sekali di
`lakuna_domain` (`syncTables`) dan dipakai server serta klien; tes
memastikan setiap model `database: all` ada di daftar itu.

## Izin

- `sync:manage` (sudah ada di katalog izin): aktivasi, sync sekarang, kode
  pasang perangkat, jeda unggahan.
- Server: batas tenant/outlet/perangkat (aturan 12). Admin server (CLI)
  bukan peran aplikasi. Izin per aksi di
  server (mis. perangkat kasir tidak boleh mengubah `staff_members`) dicatat
  sebagai gap; di Fase 1 aturan itu sudah dijaga repositori di perangkat.

## Kasus tepi

- Koneksi putus di tengah batch: transaksi server dibatalkan, batch
  dikirim ulang, idempoten per `(row_id, hlc)`.
- Aplikasi ditutup saat unggah data awal: dilanjutkan dari kursor.
- Jam perangkat mundur: HLC tetap monoton (F0). Jam maju jauh: aturan 13.
- Dua perangkat menjual stok terakhir: keduanya sah (ledger), stok minus
  dilaporkan seperti Fase 1.
- Dua perangkat mengubah open bill yang sama: LWW per baris; item bill
  adalah baris sendiri, jadi menambah item di dua perangkat tidak saling
  menimpa.
- Backup dipulihkan (F1-19) di perangkat aktif: pemulihan mematikan sync
  dan meminta pasang ulang sebagai perangkat baru (aturan 10a), karena
  `last_seq` dan outbox di backup bisa basi.
- Server baru kosong dipakai dengan token lama: `status` membalas tenant
  tidak dikenal; chip *Perlu perhatian*.
- Payload dari versi aplikasi lebih lama tanpa kolom baru: kolom hilang
  diisi default model (mis. `discount_base` = `null`, spec F1-04j).
  Server menolak push dari versi aplikasi di bawah versi minimum yang ia
  umumkan di `status` (chip *Perbarui aplikasi*).

## Pengujian (TDD)

- `lakuna_domain`: `syncTables` lengkap dan urut dependensi; HLC
  `receive`.
- `lakuna_server` (Postgres tertanam, sudah dipakai CI): push menerapkan
  dan idempoten; LWW stale; final dan unique ditolak dan tercatat; tenant/
  outlet/perangkat asing ditolak; savepoint per entri (FK gagal tidak
  membatalkan batch); transisi status monoton (void vs retur); `settings`
  digabung; pull bertahap per halaman; aktivasi dengan kode sekali pakai;
  perangkat salinan ditolak; kode pasang kedaluwarsa/sekali pakai;
  HLC masa depan ditolak.
- `lakuna_data`: `SyncEngine` dengan transport palsu (push lalu pull,
  backoff, outbox tidak terisi oleh pull, `stock_levels` dibangun ulang,
  unggah data awal bisa dilanjutkan).
- End-to-end (di `lakuna_server/test/integration`): dua `LakunaStore`
  SQLite + server tertanam; transaksi offline di keduanya lalu sync →
  isi tabel sama.
- Widget: kartu Versi hosting, layar 2.1 (1280 dan 360 px), chip status.
- Uji manual: `docker compose up` lokal, aktivasi dari aplikasi Linux di
  Xvfb, perangkat kedua dari folder data lain.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Kolom sync, outbox, HLC, UUIDv7 | F0 | Rilis v0.1.0 | Dipakai apa adanya. |
| Endpoint push/pull + log perubahan | — | Rilis v0.164.0 | Juga aktivasi, kode pasang, CLI admin, email SMTP (server). |
| Mesin sync klien | — | Rilis v0.165.0 | `SyncEngine`, `SyncScheduler`, pemadatan outbox, unggah awal bisa dilanjutkan, parkir pull, `stock_levels` per varian. Belum dipasang di aplikasi (tahap 3). |
| Aktivasi + pasang perangkat + chip status | 2.1 | Rilis v0.166.0 | Stepper 4 langkah, kartu Versi hosting, kode pasang + kode lengkap `<alamat>#<kode>`, gabung dari onboarding atau Pengaturan, chip 6 keadaan, sync otomatis setelah tulis. |
| Token perangkat di penyimpanan aman platform | — | Belum | Tahap 3 memakai berkas izin 600 di folder data (bukan di database); Keychain/Keystore/libsecret menyusul. |
| Sync dijeda | — | Rilis v0.166.0 | Perluasan desain: chip *Sync dijeda (n)*, jeda bertahan setelah aplikasi dibuka ulang. |
| Aset ke object storage | — | Belum | Tahap 4. |
| Paket deploy VPS + panduan | — | Belum | Tahap 5; satu paket untuk server hosting Yusuf dan server sendiri toko. |
| Izin per aksi di server | — | Belum | Gap; perangkat sudah menjaga izin di repositori. |
| Pull per outlet | — | Belum | Modul ini menarik semua outlet tenant (aturan 2). |
| Keunikan tingkat aplikasi di server | — | Belum | Duplikat SKU/nama dari dua perangkat dilaporkan di F2-03 (aturan 8c). |
| Baris isi baru di dokumen final | — | Rilis v0.164.0 | `sale_items`, `payments`, `purchase_items` baru dari perangkat lain untuk nota/pembelian final ditolak `final`; anak dari baris yang ditolak di batch yang sama ditolak `dependency` (aturan 7a, 8d). Pembaruan baris anak yang sudah ada (mis. QRIS `pending` → `paid`) tetap LWW: gap. |
| Penjaga tenant di `ON CONFLICT` | — | Belum | Dua tenant yang berlomba menyisipkan ID sama (butuh UUID bocor); penerap sudah memeriksa tenant baris lama dan semua induk FK. |
| Batas percobaan kode pasang/aktivasi | — | Belum | 31^8 kombinasi; batas laju di Caddy (tahap 5). |
| Perubahan pull yang selalu gagal | — | Belum | Diparkir dan dicoba tiap siklus tanpa batas dan tanpa teks galat; entri `dependency` juga didorong ulang tanpa batas. Tinjauan di F2-03. |
| Versi protokol saat pull | — | Sebagian | Aktivasi, gabung, dan pemeriksaan kode pasang menolak server dengan protokol lebih lama atau lebih baru (rilis v0.166.0). Siklus sync berikutnya belum memeriksa ulang bila server diturunkan versinya setelah aktif. |
| Void lokal yang belum terkirim | — | Belum | Pull dengan HLC lebih baru dan status lebih lemah sempat menimpa void lokal sampai push berikutnya digabung server. |
| Gabung data dua tenant lokal | — | Tidak direncanakan | Perangkat yang bergabung memulai dari data server (aturan 10). |

## Kriteria selesai

Perangkat pertama bisa diaktifkan ke server di VPS (docker compose) dan
mengunggah semua data serta gambar dengan bisa dijeda/dilanjutkan;
perangkat kedua bisa bergabung dengan kode pasang; kedua perangkat
berjualan offline lalu tersinkron dua arah sampai isi tabel sama; tes
server, data, widget, dan end-to-end hijau di CI.
