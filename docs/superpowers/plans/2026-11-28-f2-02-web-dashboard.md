# F2-02 Versi web & dashboard semua cabang — Rencana implementasi

> **Untuk agen:** SUB-SKILL WAJIB: superpowers:subagent-driven-development
> (disarankan) atau superpowers:executing-plans, tugas demi tugas. Langkah
> memakai kotak centang (`- [ ]`).

**Tujuan:** pemilik toko versi hosting membuka Lakuna di browser, masuk
dengan email + kata sandi + kode authenticator, melihat dashboard semua
cabang, dan memakai menu back office dengan data yang tersinkron dari kasir.

**Arsitektur:** build web dari `lakuna_flutter` yang sama. Browser menjadi
*perangkat web* tenant (database SQLite wasm milik `serverpod_database`),
menarik semua data lewat `sync.pull` F2-01 dan menulis lewat outbox yang
sama. Hal yang berbasis berkas (media, token, gabung, backup) dipisah di
balik antarmuka dengan versi `io` dan `web` (impor bersyarat). Kemampuan
platform disuntik lewat `AppPlatform` agar teruji di VM. Login web dan TOTP
ada di endpoint server baru; dashboard dihitung di perangkat dengan fungsi
domain, status perangkat dari `sync.tenantStatus`.

**Tech stack:** Dart 3.13, Flutter 3.47.9 (target web, `--no-web-resources-cdn`),
Serverpod 4.1, `sqlite_async` 0.14.5 / `sqlite3_web` 0.9.4 (lewat
`serverpod_database`), `hashlib` (HMAC-SHA1), `cipherlib` (AES-GCM, server),
`barcode` + `flutter_svg` (QR), Caddy.

**Spec:** `docs/superpowers/specs/2026-11-28-f2-02-web-dashboard-design.md`
(nomor aturan di bawah merujuk spec ini).

## Batasan global

- Ikuti `CLAUDE.md`: TDD, `dart format`, `dart analyze --fatal-infos` /
  `flutter analyze --fatal-infos`, semua tes, review subagent, uji manual
  (Playwright untuk web, Xvfb untuk Linux) dengan tangkapan layar.
- Semua aset offline: tanpa CDN (CanvasKit, font, `sqlite3.wasm`, worker
  dibundel di build web).
- Kode bersama tidak mengimpor `dart:io` langsung bila dipakai web: pakai
  impor bersyarat `if (dart.library.io)` dengan berkas `_io.dart` /
  `_web.dart`, keduanya memenuhi antarmuka yang sama.
- Model `.spy.yaml` + `serverpod generate`, migrasi
  `serverpod create-migration --tag <tag>`; kode generate di-commit.
- Uang `int` rupiah, jumlah `int` mili-satuan; tanpa `double`.
- Setiap kunci l10n baru di `app_id.arb` dan `app_en.arb`.
- Tiap tahap = satu rilis (pubspec `version:`, CHANGELOG, `server_version.dart`,
  STATUS-JEDA, tabel Status & gap spec + `specs/README.md`), PR ke `main`,
  squash-merge setelah CI hijau.
- Angka tetap: token web 30 hari (dicentang) / 12 jam; TOTP SHA-1, 6 digit,
  30 detik, rahasia 160 bit, jendela ±1 langkah, kunci 15 menit setelah 5
  salah; 8 kode cadangan; cache media web 64 MB; perangkat online ≤ 10
  menit; *belum sync* > 1 jam; poll status 60 detik; terlaris 5 produk
  dalam 7 hari; grafik per jam minimal 08–17.

## Fokus review

1. Sesi web habis (atau dicabut) saat outbox masih berisi perubahan: layar
   *Sesi berakhir* menyebut jumlah perubahan yang belum terkirim sebelum
   database dihapus; tidak ada penghapusan diam-diam (Tugas 11).
2. Tab ditutup di tengah pull pertama lalu dibuka lagi: sesi dilanjutkan
   dari kursor dengan token yang sama, bukan perangkat web baru (Tugas 3).
3. Dua permintaan `webAccess.open` paralel dengan kode TOTP yang sama: hanya
   satu yang berhasil (Tugas 9).
4. Outlet berzona waktu lain dari browser (outlet WIT dibuka dari laptop
   WIB, menjelang tengah malam): "hari ini" dan grafik per jam memakai
   tanggal lokal outlet (Tugas 12 dan 13).
5. Penyesuaian stok dibuat dari web setelah pindah cabang: nomor memakai
   kode outlet terpilih dan kode perangkat web (`SA-<outlet>-W01-…`), tidak
   bentrok dengan kasir cabang itu (Tugas 5).

---

## Tahap 1 · Aplikasi jalan di browser (v0.169.0)

### Tugas 1: Spike penyimpanan SQLite di browser

Spike buangan (tanpa TDD), hasilnya dicatat di spec aturan 6 dan dipakai
Tugas 3 dan 6.

**Berkas:**
- Buat: `lakuna_flutter/web/sqlite3.wasm`, `lakuna_flutter/web/db_worker.js`
  (di-commit), `tool/web_sqlite_assets.sh` (membuat ulang keduanya dari
  versi paket terkunci di `pubspec.lock`: `sqlite3.wasm` dari rilis paket
  `sqlite3` yang sama, `db_worker.js` dari
  `sqlite_async/lib/src/web/worker/worker.dart` lewat `dart compile js -O4`).

- [x] Build web debug, sajikan `build/web` dengan header COOP/COEP
  (`/tmp/claude-0/webtest/serve.py`), buka di Chromium Playwright:
  `LakunaStore.open('lakuna-spike.sqlite')` berhasil, tulis lalu muat ulang
  halaman → data tetap ada. Catat implementasi yang dipilih (OPFS /
  IndexedDB) dari log `sqlite3_web`.
- [x] Uji tanpa COOP/COEP: masih jalan (fallback IndexedDB)? Catat.
- [x] Cari cara menghapus database sesi: `sqlite3_web` `deleteDatabase`
  lewat `WebSqlite.open(...).deleteDatabase(name, storage)` atau hapus
  OPFS/IndexedDB langsung dari JS. Hasilkan keputusan:
  `Future<void> deleteWebDatabase(String name)`.
- [x] Uji build disajikan dari subpath `/app/` (`<base href="/app/">`):
  wasm dan worker termuat (URI relatif bawaan `sqlite3.wasm` /
  `db_worker.js`).
- [x] Perbarui spec aturan 6 dengan hasil spike. Commit aset + skrip + spec.

### Tugas 2: Media dan token tanpa berkas

**Berkas:**
- Buat: `packages/lakuna_data/lib/src/platform/media_blobs.dart`
  (antarmuka + impor bersyarat), `media_blobs_io.dart`,
  `media_blobs_memory.dart`; `packages/lakuna_data/lib/src/platform/token_vault.dart`.
- Ubah: `store.dart` (`mediaDirectory` → `media`), `media.dart`,
  `sync/media_sync.dart`, `hosting.dart` (`HostingVault` memenuhi
  `TokenVault`).
- Tes: `packages/lakuna_data/test/media_blobs_test.dart`,
  `packages/lakuna_data/test/token_vault_test.dart`, tes media/hosting yang
  ada tetap lulus.

**Antarmuka (dihasilkan):**
- `abstract interface class MediaBlobs { Future<bool> exists(String key); Future<Uint8List?> read(String key); Future<void> write(String key, Uint8List bytes, {bool pinned = false}); Future<void> unpin(String key); int get pinnedCount; }`
- `class FileMediaBlobs implements MediaBlobs` (folder `media` di samping
  database, tulis via `.tmp` lalu rename seperti sekarang; `pinned`
  diabaikan).
- `class MemoryMediaBlobs implements MediaBlobs { MemoryMediaBlobs({int maxBytes = 64 * 1024 * 1024}); }`
  LRU; berkas `pinned` (unggahan dari web yang belum terkirim) tidak
  pernah dibuang sampai `unpin`.
- `MediaBlobs defaultMediaBlobs(String databasePath)` (io → file, web →
  memori).
- `LakunaStore.open(path, {..., MediaBlobs? media})`, `LakunaStore.media`.
- `abstract interface class TokenVault { Future<String?> readToken(); Future<void> writeToken(String token); Future<void> deleteToken(); }`
- `class StateTokenVault implements TokenVault` (kunci
  `SyncStateKey.webDeviceToken`), `TokenVault tokenVaultOf(LakunaStore store)`
  (web → `StateTokenVault`, io → `HostingVault.of`). Semua pemanggil
  `HostingVault.of` diganti `tokenVaultOf`.
- *Ruling rencana:* unggahan gambar dari web disimpan `pinned` di memori
  sampai `media_sync` mengunggahnya (bukan tabel lokal sementara seperti
  aturan 8); `pinnedCount` masuk hitungan *belum terkirim* untuk
  `beforeunload` (aturan 7). Spec aturan 8 diperbarui.

- [ ] Tes gagal: `MemoryMediaBlobs(maxBytes: 10)` tulis 4+4+4 byte → kunci
  pertama terbuang, dua terakhir ada; `read` memindah kunci ke paling baru;
  kunci `pinned` tidak terbuang walau melebihi batas, terbuang setelah
  `unpin` + tulis berikutnya; `StateTokenVault` tulis/baca/hapus lewat
  `sync_state`; `storeMediaFile` + `readMediaFile` dengan store ber-
  `MemoryMediaBlobs` mengembalikan bytes yang sama tanpa membuat folder
  `media`.
- [ ] Jalankan `cd packages/lakuna_data && dart test test/media_blobs_test.dart test/token_vault_test.dart`: gagal.
- [ ] Implementasi; `dart test` seluruh paket: lulus. Commit.

### Tugas 3: Sesi gabung web (tanpa staging) dan progres pull

**Berkas:**
- Buat: `packages/lakuna_data/lib/src/web_session.dart`,
  `packages/lakuna_data/lib/src/platform/web_database.dart` (+ `_io`/`_web`:
  hapus database sesi sesuai Tugas 1; versi io menghapus berkas
  `<nama>{,-wal,-shm,-journal}`).
- Ubah: `lakuna_server/lib/src/sync/sync_pull_page.spy.yaml` (field
  `headSeq: int?` = `seq` terbesar tenant saat pull), `sync_endpoint.dart`,
  `packages/lakuna_data/lib/src/sync/sync_engine.dart` (callback progres),
  `hosting.dart` (`openJoinedStore` tanpa `File` di web: cek ada/tidaknya
  lewat `sync_state` deviceId).
- Tes: `packages/lakuna_data/test/web_session_test.dart`,
  `lakuna_server/test/integration/sync_endpoint_test.dart` (headSeq).

**Antarmuka (dihasilkan):**
- `typedef PullProgress = void Function(int pulled, int? head);`
- `SyncEngine.runCycle({PullProgress? onPull})`.
- `String webDatabaseName(UuidValue deviceId) => 'lakuna-${deviceId.uuid}.sqlite';`
- `Future<LakunaStore> joinHostingWeb({required String databaseName, required UuidValue deviceId, required String deviceToken, required String serverUrl, required SyncTransport transport, PullProgress? onPull, DateTime Function()? clock})`
  — buka/buat store sesi, simpan token (`StateTokenVault`) dan
  `serverUrl`, jalankan siklus sampai `hasMore` false; database yang sudah
  ada (lanjutan) memakai kursornya. Melempar `HostingJoinIncomplete` bila
  konteks toko belum lengkap, `SyncOfflineException` bila offline.
  Mengembalikan store yang **tetap terbuka**.
- `Future<void> deleteWebDatabase(String name)`.

- [ ] Tes gagal server: `pull` mengembalikan `headSeq` = seq terbesar
  tenant (bukan perangkat lain tenant lain), juga saat halaman kosong.
- [ ] Tes gagal data (transport palsu, 2.500 perubahan): `onPull` dipanggil
  per halaman dengan `(1000, 2500)`, `(2000, 2500)`, `(2500, 2500)`;
  hasil store punya `loadStoreContext` != null dan token di
  `StateTokenVault`.
- [ ] Tes gagal (Fokus review 2): transport melempar offline setelah
  halaman pertama → `SyncOfflineException`; panggil lagi dengan nama
  database dan token yang sama → lanjut dari kursor 1000 (transport tidak
  menerima `afterSeq: 0` lagi), tanpa `joinWithPairingCode` baru.
- [ ] Tes gagal: `deleteWebDatabase` versi io menghapus berkas dan
  sufiksnya.
- [ ] `serverpod generate`, implementasi, tes server + data lulus. Commit.

### Tugas 4: `AppPlatform`, menu dan rute web

**Berkas:**
- Buat: `lakuna_flutter/lib/config/app_platform.dart`,
  `lakuna_flutter/lib/data/services/web_session_store.dart` (+ `_io`/`_web`;
  web memakai `localStorage` lewat `package:web`).
- Ubah: `app_root.dart`, `bootstrap.dart`, `config/app_environment.dart`,
  `routing/router.dart`, `ui/core/menu.dart`, `ui/settings/*` (bagian backup
  dan printer), `ui/onboarding/onboarding_view.dart`, `ui/hosting/join_view*.dart`,
  serta berkas yang mengimpor `dart:io` (daftar di ringkasan spike:
  `spreadsheet_exporter`, `receipt_printer`, `backup_files`, `auto_backup`,
  `product_widgets`, `serverpod_hosting`, `local_backup_repository`,
  `local_hosting_repository`) dipecah dengan impor bersyarat.
- Tes: `lakuna_flutter/test/web/web_routes_test.dart`,
  `lakuna_flutter/test/web/web_root_test.dart`.

**Antarmuka (dihasilkan):**
- `class AppPlatform { const AppPlatform({required this.isWeb}); static const current = AppPlatform(isWeb: kIsWeb); bool get supportsCashier => !isWeb; bool get supportsLocalBackup => !isWeb; bool get supportsBluetoothPrinter => !isWeb; }`
  disediakan lewat `Provider<AppPlatform>` dan parameter `createRouter(platform:)`.
- `MenuEntry.device` (bool, `true` untuk cashier, tables, cash_session):
  disembunyikan bila `!platform.supportsCashier`; redirect router mengalihkan
  path entri itu (termasuk `/meja/denah`, `/meja/split/*`) ke `Routes.home`.
- `abstract interface class WebSessionStore { String? get activeDatabase; Future<void> setActiveDatabase(String? name); }`
- `LakunaRoot(platform:, webSessions:)`: di web tidak memanggil
  `applyPendingJoin`/`applyPendingRestore`; tanpa sesi aktif menampilkan
  layar gabung web (Tugas 6) alih-alih membuka database.
- Di web, setelah store terbuka, `SessionRepository.startOwnerSession`
  dijalankan otomatis (aturan 4); `Routes.login` (PIN) dialihkan ke Beranda.

- [ ] Tes gagal: router dengan `AppPlatform(isWeb: true)` dan staf pemilik
  → menu tanpa Kasir/Meja/Kas laci; `go('/kasir')` dan `go('/meja/denah')`
  berakhir di `/`; Pengaturan tanpa bagian *Data & backup* dan printer
  Bluetooth; dengan `isWeb: false` perilaku lama tetap (tes yang ada).
- [ ] Tes gagal: `LakunaRoot` web tanpa sesi aktif menampilkan
  `ValueKey('web-join')`; dengan sesi aktif memanggil `boot` dengan nama
  database dari `WebSessionStore`.
- [ ] Implementasi; `flutter test` seluruhnya lulus;
  `flutter build web --debug --no-web-resources-cdn` berhasil. Commit.

### Tugas 5: Pemilih cabang di web

**Berkas:**
- Ubah: `data/repositories/store_repository.dart`,
  `local_store_repository.dart`, `ui/core/app_shell.dart`;
  `packages/lakuna_data/lib/src/store_setup.dart` (`loadStoreContext`
  dengan `outletId` opsional).
- Tes: `lakuna_flutter/test/web/outlet_switch_test.dart`,
  `packages/lakuna_data/test/store_context_outlet_test.dart`.

**Antarmuka (dihasilkan):**
- `Future<StoreContext?> loadStoreContext(LakunaStore store, {UuidValue? outletId})`
  — outlet diberikan (aktif, tenant sama) atau outlet perangkat seperti
  sekarang; perangkat tetap perangkat web.
- `StoreRepository.outlets()` → `Future<Result<List<Outlet>>>`,
  `StoreRepository.switchOutlet(UuidValue id)` → `Future<Result<StoreContext>>`
  (ingat di `local_preferences` kunci `web.outlet.<tenant>`; dipulihkan di
  `load()`), `notifyListeners` agar layar memuat ulang.
- `AppShell` menampilkan pemilih *Cabang* di bilah atas bila
  `platform.isWeb` dan outlet > 1; pindah cabang menanyakan form yang belum
  disimpan lewat `canSwitch` yang sudah ada.

- [ ] Tes gagal data: tenant 2 outlet (PST, KMG), perangkat web outlet PST;
  `loadStoreContext(outletId: KMG)` → outlet KMG, device web sama;
  outlet tenant lain → `null`.
- [ ] Tes gagal (Fokus review 5): setelah `switchOutlet(KMG)`, penyesuaian
  stok dari web bernomor `SA-KMG-W01-…` dan stoknya di lokasi KMG.
- [ ] Tes gagal widget: pemilih tampil hanya di web dengan 2 outlet; pilihan
  bertahan setelah `load()` ulang.
- [ ] Implementasi, tes lulus. Commit.

### Tugas 6: Gabung web, build CI, rilis 0.169.0

**Berkas:**
- Buat: `lakuna_flutter/lib/ui/web/web_join_view.dart`,
  `web_join_view_model.dart`, `web_preparing_view.dart` (*Menyiapkan data
  toko*, progres "n dari m perubahan", *Batal*).
- Ubah: `lakuna_flutter/web/index.html` (judul, tanpa sumber jaringan),
  `.github/workflows/ci.yml` (job `Build web`:
  `flutter build web --release --no-web-resources-cdn`, cek tidak ada
  `gstatic`/`googleapis` di `build/web`), l10n, CHANGELOG, pubspec
  `0.169.0+172`, `server_version.dart`, STATUS-JEDA, spec, `specs/README.md`.
- Tes: `lakuna_flutter/test/web/web_join_view_model_test.dart`.

**Antarmuka:**
- Konsumsi: `joinHostingWeb`, `webDatabaseName`, `WebSessionStore`,
  `HostingClient.joinWithPairingCode` (platform `DevicePlatform.web`),
  `AppRestart.restart`.
- Server: kode perangkat web dibuat server (aturan 2) — `joinWithPairingCode`
  dengan platform `web` mengabaikan `deviceCode` kiriman dan memberi `W01`,
  `W02`, … unik per tenant (tes di `activation_endpoint_test.dart`).
- Galat penyimpanan ditolak (`StorageUnavailable`) → pesan aturan *Kasus
  tepi*; tab kedua → *Lakuna sudah terbuka di tab lain* (kunci
  `navigator.locks` di versi web `WebSessionStore.acquireTabLock()`; versi
  io selalu berhasil).

- [ ] Tes gagal server: dua perangkat web di tenant 2 outlet → `W01`, `W02`;
  kode kasir `W01` dari aplikasi lama tidak membuat bentrok (unik per
  outlet tetap berlaku untuk perangkat biasa).
- [ ] Tes gagal VM: kode pasang sah → status `preparing` dengan progres,
  lalu `done` dan `setActiveDatabase(lakuna-<id>.sqlite)`; offline →
  pesan galat dan bisa ulang; *Batal* → `deleteWebDatabase` dan
  `setActiveDatabase(null)`.
- [ ] Implementasi, `flutter test` lulus, build web release lulus.
- [ ] Uji manual: server lokal (Postgres 5433 + `lakuna_server`), perangkat
  Linux Xvfb membuat kode pasang, Chromium Playwright membuka build web,
  gabung, Beranda + Produk + pemilih cabang; ubah harga produk di web →
  tampil di perangkat Linux setelah sync. Tangkapan layar terang dan gelap
  ke `/tmp/claude-0/webtest/`.
- [ ] Rilis: CHANGELOG 0.169.0, versi, dokumen status; PR, CI hijau,
  review subagent, merge, cek rilis 8 aset.

## Tahap 2 · Login web pemilik (v0.170.0)

### Tugas 7: TOTP dan kode cadangan (domain)

**Berkas:**
- Buat: `packages/lakuna_domain/lib/src/totp.dart` (ekspor di
  `lakuna_domain.dart`).
- Tes: `packages/lakuna_domain/test/totp_test.dart`.

**Antarmuka (dihasilkan):**
- `int totpStep(DateTime t)` (= detik epoch ~/ 30).
- `String totpCode(List<int> secret, int step, {int digits = 6})` (HMAC-SHA1
  `hashlib`, RFC 4226 dynamic truncation, nol di depan dipertahankan).
- `int? matchTotp(List<int> secret, String code, DateTime now, {int? lastUsedStep})`
  — langkah yang cocok di `step-1..step+1`, `null` bila salah atau langkah
  ≤ `lastUsedStep`.
- `String base32Encode(List<int> bytes)`, `List<int>? base32Decode(String s)`
  (RFC 4648 tanpa padding, abaikan spasi/huruf kecil).
- `String otpauthUri({required String email, required String secretBase32})`
  → `otpauth://totp/Lakuna:<email>?secret=…&issuer=Lakuna&algorithm=SHA1&digits=6&period=30`
  (email di-percent-encode).
- `List<String> newBackupCodes(Random random)` → 8 kode `xxxx-xxxx`
  (huruf/angka tanpa `0 O 1 I L`), `String normalizeBackupCode(String s)`.

- [ ] Tes gagal: vektor RFC 6238 SHA-1 (rahasia ASCII
  `12345678901234567890`, 8 digit): T=59 → `94287082`, T=1111111109 →
  `07081804`, T=1111111111 → `14050471`, T=1234567890 → `89005924`,
  T=2000000000 → `69279037`, T=20000000000 → `65353130`; 6 digit = 6 angka
  terakhir. `matchTotp` menerima kode langkah −1 dan +1, menolak ±2,
  menolak langkah ≤ `lastUsedStep`. Base32 bolak-balik untuk 20 byte acak;
  `base32Decode('JBSWY3DPEHPK3PXP')` = `Hello!\xDE\xAD\xBE\xEF`.
  `newBackupCodes` 8 kode unik pola `^[A-HJKMNP-Z2-9]{4}-[A-HJKMNP-Z2-9]{4}$`.
- [ ] Implementasi, `dart test test/totp_test.dart` lulus. Commit.

### Tugas 8: Model server TOTP, enkripsi rahasia, token berumur

**Berkas:**
- Buat: `lakuna_server/lib/src/web_access/owner_totp.spy.yaml`,
  `owner_backup_code.spy.yaml` (kolom sesuai spec *Data*,
  `database: server`, `serverOnly: true`), `totp_cipher.dart`, pesan
  `web_access_failure.spy.yaml` (enum `noTenant, totpNotEnabled,
  totpInvalid, locked, sessionExpired, totpKeyMissing`),
  `web_access_exception.spy.yaml` (`failure`, `lockedUntil?`),
  `web_tenant.spy.yaml` (`tenantId`, `name`), `web_access_result.spy.yaml`
  (`deviceToken`, `tenantId`, `deviceId`, `deviceCode`, `outletId`,
  `expiresAt`), `totp_enrollment.spy.yaml` (`secretBase32`, `otpauthUri`).
- Ubah: `device_credential.spy.yaml` (`expiresAt: DateTime?, column=expires_at`),
  `device_auth.dart` (token lewat `expires_at` → `SyncAuthException`),
  `lakuna_server/pubspec.yaml` (`cipherlib`), `config/passwords.yaml`
  contoh + `deploy/.env.example` + compose (`TOTP_ENCRYPTION_KEY` →
  `SERVERPOD_PASSWORD_totpEncryptionKey`).
- Migrasi: `serverpod create-migration --tag login-web`.
- Tes: `lakuna_server/test/unit/totp_cipher_test.dart`,
  `test/integration/sync_endpoint_test.dart` (token habis).

**Antarmuka (dihasilkan):**
- `class TotpCipher { TotpCipher(String password); String encrypt(List<int> secret); List<int> decrypt(String sealed); static TotpCipher? fromSession(Session s); }`
  — kunci = SHA-256(password), AES-256-GCM, nonce 12 byte acak,
  `base64(nonce ‖ ciphertext ‖ tag)`; `fromSession` `null` bila
  `totpEncryptionKey` kosong.

- [ ] Tes gagal: enkripsi lalu dekripsi = rahasia asal; dua enkripsi
  rahasia sama berbeda; teks diubah satu byte → `decrypt` melempar;
  kata sandi lain → melempar. `sync.push` dengan token yang `expiresAt`
  lewat → `SyncAuthException(reason: 'expired')`.
- [ ] `serverpod generate`, migrasi hanya menambah 2 tabel + 1 kolom.
- [ ] Implementasi, tes lulus. Commit (migrasi di commit sendiri).

### Tugas 9: Endpoint `totp` dan `webAccess`, admin `totp-reset`

**Berkas:**
- Buat: `lakuna_server/lib/src/web_access/totp_endpoint.dart`,
  `web_access_endpoint.dart`, `owner_totp_check.dart`.
- Ubah: `activation_endpoint.dart` (ambil `registerDevice(...)` bersama dari
  `joinWithPairingCode`), `admin_cli.dart` (`totp-reset --email <email>`),
  `deploy/Caddyfile` (zona `auth` + `/totp/* /webAccess/*`).
- Tes: `lakuna_server/test/integration/web_access_test.dart`,
  `test/integration/totp_endpoint_test.dart`, `test/unit/admin_cli_test.dart`.

**Antarmuka (dihasilkan):**
- `Future<Device> registerDevice(Session s, Transaction tx, {required UuidValue tenantId, required UuidValue outletId, required String code, required String name, required DevicePlatform platform})`
  (insert `devices` + `sync_changes`), dipakai `joinWithPairingCode` dan
  `webAccess.open`; `Future<String> nextWebDeviceCode(Session s, Transaction tx, UuidValue tenantId)`.
- `Future<int> verifyOwnerSecondFactor(Session s, Transaction tx, UuidValue authUserId, String code, {required DateTime now})`
  — baris `owner_totp` dikunci `forUpdate`; kode 6 digit → `matchTotp`,
  selain itu kode cadangan (hash, `used_at`); salah → `failed_attempts++`,
  ke-5 → `locked_until = now + 15 menit`; benar → reset hitungan, simpan
  `last_used_step`. Melempar `WebAccessException`.
- `TotpEndpoint` (`requireLogin`): `Future<bool> status(Session)`,
  `Future<TotpEnrollment> begin(Session)` (rahasia baru belum dikonfirmasi;
  menimpa yang belum dikonfirmasi; ditolak bila sudah aktif),
  `Future<List<String>> confirm(Session, String code)` (8 kode cadangan,
  hash disimpan), `Future<void> disable(Session, String code)`.
  Hanya akun di `tenant_owners`.
- `WebAccessEndpoint` (`requireLogin`): `Future<List<WebTenant>> tenants(Session)`
  (melempar `noTenant` / `totpNotEnabled`),
  `Future<WebAccessResult> open(Session, String code, UuidValue tenantId, bool remember)`
  (verifikasi faktor kedua, `registerDevice` platform `web` di outlet
  pertama tenant, kode `W..`, `expires_at` 30 hari / 12 jam),
  `Future<void> logout(Session, String deviceToken)` (tanpa login; cabut
  token web itu saja).
- *Ruling rencana:* pilihan toko (aturan 13a) tampil bersama kotak kode di
  langkah 2, karena daftar tenant sudah diketahui setelah kata sandi.

- [ ] Tes gagal `totp`: tanpa login ditolak; `begin` → `confirm` kode
  benar → 8 kode; `confirm` salah → `totpInvalid`; `begin` saat aktif
  ditolak; `totpEncryptionKey` kosong → `totpKeyMissing`; `disable` dengan
  kode cadangan.
- [ ] Tes gagal `webAccess`: akun tanpa tenant → `noTenant`; tanpa TOTP
  aktif → `totpNotEnabled`; kode benar → perangkat `web` `W01` di outlet
  pertama, token bisa `sync.pull`, `expiresAt` 30 hari / 12 jam; kode sama
  dipakai lagi → `totpInvalid`; 5 salah → `locked`, kode benar pun ditolak
  sampai 15 menit (jam disuntik); kode cadangan sekali pakai; tenant bukan
  milik akun → `noTenant`; `logout` mencabut token.
- [ ] Tes gagal (Fokus review 3): dua `open` paralel dengan kode yang sama
  → tepat satu berhasil.
- [ ] Tes gagal admin: `totp-reset --email` menghapus `owner_totp` dan kode
  cadangan akun itu; email tak dikenal → keluar kode 1.
- [ ] Implementasi, tes lulus, `caddy validate` (CI) lulus. Commit.

### Tugas 10: Atur verifikasi 2 langkah di kartu *Versi hosting*

**Berkas:**
- Buat: `lakuna_flutter/lib/ui/hosting/two_factor_dialog.dart`,
  `two_factor_view_model.dart`, `lakuna_flutter/lib/ui/core/qr_image.dart`
  (`Barcode.qrCode().toSvg` + `SvgPicture.string`).
- Ubah: `hosting_repository.dart` (+ `local_hosting_repository.dart`,
  `serverpod_hosting.dart`), `hosting_section.dart`, l10n,
  `lakuna_flutter/pubspec.yaml` (`barcode`).
- Tes: `lakuna_flutter/test/hosting/two_factor_view_model_test.dart`,
  `test/hosting/two_factor_dialog_test.dart`.

**Antarmuka (dihasilkan):**
- `HostingRepository.twoFactorStatus(email, password)` → `Future<Result<bool>>`,
  `beginTwoFactor()` → `Future<Result<TotpEnrollment>>`,
  `confirmTwoFactor(String code)` → `Future<Result<List<String>>>`,
  `disableTwoFactor(String code)` → `Future<Result<void>>`; login akun
  memakai `login(...)` yang sudah ada (sesi JWT di memori).
- Alur: PIN pemilik (`verifyCurrentPin`) → email + kata sandi → QR +
  rahasia teks (bisa disalin) → kode 6 digit → 8 kode cadangan (tombol
  *Salin*, *Sudah saya simpan*). Status *Aktif* dengan *Nonaktifkan* /
  *Atur ulang*.

- [ ] Tes gagal VM: langkah berurutan; kata sandi salah → galat di langkah
  akun; kode salah → tetap di langkah kode dengan pesan; sukses →
  langkah kode cadangan berisi 8 kode; *Nonaktifkan* butuh kode.
- [ ] Tes gagal widget: kartu *Versi hosting* aktif menampilkan baris
  *Verifikasi 2 langkah · Belum aktif* + tombol *Aktifkan*; QR tampil.
- [ ] Implementasi, tes lulus; uji Xvfb dengan server lokal, tangkapan
  layar setiap langkah. Commit.

### Tugas 11: Layar login web 2.2, sesi web, rilis 0.170.0

**Berkas:**
- Buat: `lakuna_flutter/lib/ui/web/web_login_view.dart`,
  `web_login_view_model.dart`, `web_password_reset_view.dart`,
  `web_session_ended_view.dart`.
- Ubah: `app_root.dart` (web tanpa sesi → login web, bukan gabung kode
  pasang; gabung kode pasang tetap tersedia di build web lepas lewat tautan
  kecil *Pakai kode pasang*), `data/services/serverpod_hosting.dart`
  (`WebAccessClient`), `hosting_repository` (`logoutWeb`), app shell
  (menu *Keluar* di web), l10n, CHANGELOG 0.170.0, versi `0.170.0+173`,
  dokumen status.
- Tes: `lakuna_flutter/test/web/web_login_view_model_test.dart`,
  `test/web/web_login_view_test.dart`, `test/web/web_session_end_test.dart`.

**Antarmuka:**
- Konsumsi: `webAccess.tenants/open/logout` (Tugas 9), `joinHostingWeb`
  (Tugas 3), `deleteWebDatabase`, `WebSessionStore`.
- `enum WebLoginStep { credentials, secondFactor, preparing }`;
  `WebLoginViewModel.submitCredentials(email, password)`,
  `.submitCode(code, {UuidValue? tenantId})`, `remember` (bawaan `true`),
  `serverUrl` (asal halaman bila disajikan server, isian bila build lepas).
- Sesi berakhir (`SyncAuthException` dari siklus sync, atau *Keluar*):
  hitung outbox `pending|sent` + `media.pinnedCount`; > 0 → layar *Sesi
  berakhir* "n perubahan belum terkirim akan hilang" dengan *Keluar
  sekarang*; lalu `deleteWebDatabase` + `setActiveDatabase(null)` +
  `AppRestart.restart`. *Keluar* manual dengan perubahan belum terkirim
  mencoba sync dulu.
- `beforeunload` (versi web `WebSessionStore.setUnsentGuard(bool)`): aktif
  selama ada perubahan belum terkirim.
- *Lupa kata sandi?* memakai `emailIdp.startPasswordReset` /
  `verifyPasswordResetCode` / `finishPasswordReset`, kata sandi baru diketik
  dua kali.

- [ ] Tes gagal VM: kredensial salah → galat langkah 1; `totpNotEnabled` →
  petunjuk aktifkan di aplikasi; dua tenant → langkah 2 memuat pilihan
  toko; `locked` → pesan dengan jam buka (zona browser); sukses →
  `preparing` lalu sesi aktif dengan `remember` yang dikirim.
- [ ] Tes gagal (Fokus review 1): token ditolak saat outbox berisi 3 baris →
  layar sesi berakhir menyebut 3 dan database belum dihapus sebelum
  *Keluar sekarang*.
- [ ] Tes gagal widget: layout dua kolom ≥ 600 px, menumpuk < 600 px;
  pilihan bahasa mengganti teks; tombol *Masuk* nonaktif sampai isian
  lengkap.
- [ ] Implementasi, tes lulus; uji manual Playwright (login, salah kode,
  kunci, keluar), tangkapan layar terang + gelap + mobile.
- [ ] Rilis 0.170.0: PR, CI, review, merge, cek aset.

## Tahap 3 · Dashboard semua cabang (v0.171.0)

### Tugas 12: Agregasi dashboard (domain)

**Berkas:**
- Buat: `packages/lakuna_domain/lib/src/dashboard.dart`.
- Tes: `packages/lakuna_domain/test/dashboard_test.dart`.

**Antarmuka (dihasilkan):**
- `class OutletDay { final UuidValue outletId; final Money sales; final int transactions; final List<Money> hourly; }`
  (`hourly` 24 nilai, jam lokal outlet).
- `Money averagePerReceipt(Money sales, int transactions)` (bagi ke bawah,
  0 bila 0 transaksi).
- `({int from, int to}) hourAxis(List<Money> hourly)` — jam pertama/terakhir
  bertransaksi, diperluas ke minimal 08–17.
- `enum DeviceLiveness { online, offline }`,
  `DeviceLiveness deviceLiveness(DateTime? lastSeen, DateTime now)` (≤ 10
  menit online), `bool deviceStale(DateTime? lastSeen, DateTime now)` (> 1
  jam atau belum pernah).
- `List<({UuidValue productId, String name, Qty sold})> topProducts(List<({UuidValue productId, String name, Qty qty})> lines, {int limit = 5})`
  (gabung varian ke produk, urut jumlah turun lalu nama).
- `DateTime outletDayStart(DateTime nowUtc, String timezone)` memakai fungsi
  zona waktu yang sudah dipakai Laporan.

- [ ] Tes gagal: rata-rata 100.001/3 → 33.333; 0 transaksi → 0; sumbu jam
  transaksi 06 dan 21 → 06–21, hanya 12 → 08–17; online 10:00 tepat
  online, 10:01 offline; stale `null` → true; terlaris menggabung 2 varian
  produk sama dan memotong ke 5; (Fokus review 4) `outletDayStart` untuk
  `Asia/Jayapura` pada 2026-11-28T15:30Z = 2026-11-29T00:00 WIT.
- [ ] Implementasi, tes lulus. Commit.

### Tugas 13: Kueri dashboard multi-cabang (data)

**Berkas:**
- Buat: `packages/lakuna_data/lib/src/dashboard.dart`.
- Tes: `packages/lakuna_data/test/dashboard_test.dart`.

**Antarmuka (dihasilkan):**
- `class DashboardData { final List<OutletDay> outlets; final List<({UuidValue productId, String name, Qty sold})> top; final Map<UuidValue, int> belowMinimum; }`
- `Future<DashboardData> loadDashboard(LakunaStore store, {required UuidValue tenantId, UuidValue? outletId, required DateTime now})`
  — penjualan dan transaksi hari ini per outlet memakai fakta penjualan
  Laporan (`_facts` di `reports.dart` diangkat menjadi fungsi bersama, bukan
  disalin); terlaris 7 hari per outlet lalu digabung; di bawah minimum =
  varian dengan `min_stock_milli` dan stok lokasi outlet itu di bawahnya.

- [ ] Tes gagal: 2 outlet beda zona, nota final + void + retur sebagian →
  penjualan sama dengan Laporan outlet masing-masing hari itu; `outletId`
  membatasi satu outlet; nota tenant lain tidak terhitung; minimum per
  cabang dihitung terpisah.
- [ ] Implementasi, tes `lakuna_data` seluruhnya lulus (Laporan tidak
  berubah). Commit.

### Tugas 14: `sync.tenantStatus`

**Berkas:**
- Buat: `lakuna_server/lib/src/sync/tenant_status.spy.yaml`
  (`devices: List<DeviceStatus>`, `openConflicts: int`, `serverTime`),
  `device_status.spy.yaml` (`deviceId`, `outletId`, `code`, `name`,
  `platform`, `lastSeenAt?`).
- Ubah: `sync_endpoint.dart`, `packages/lakuna_data/lib/src/sync/sync_transport.dart`
  (+ implementasi Serverpod di Flutter).
- Tes: `lakuna_server/test/integration/sync_endpoint_test.dart`.

**Antarmuka (dihasilkan):**
- `Future<TenantStatus> tenantStatus(Session s, String deviceToken)` —
  perangkat tenant token yang punya kredensial belum dicabut (kecuali
  platform `web`), `lastSeenAt` dari `device_credentials.last_seen_at`
  terbaru; konflik = `sync_conflicts` tenant `resolved_at` kosong.
- `SyncTransport.tenantStatus()` → `Future<TenantStatus>`.

- [ ] Tes gagal: 2 perangkat kasir + 1 web → 2 baris; perangkat dicabut
  tidak muncul; tenant lain tidak muncul; 3 konflik, 1 selesai → 2.
- [ ] `serverpod generate`, implementasi, tes lulus. Commit.

### Tugas 15: Layar dashboard 2.3, rilis 0.171.0

**Berkas:**
- Buat: `lakuna_flutter/lib/ui/dashboard/dashboard_view.dart`,
  `dashboard_view_model.dart`, `dashboard_export.dart`;
  `lakuna_flutter/lib/data/repositories/dashboard_repository.dart` (+ `local_`).
- Ubah: `routing/routes.dart` (`Routes.dashboard = '/dashboard'`), `router.dart`,
  `ui/core/menu.dart` (entri `dashboard`, tanda *F2*, `reports:view`, hanya
  bila hosting aktif), `bootstrap.dart`, l10n, CHANGELOG 0.171.0, versi
  `0.171.0+174`, dokumen status, panduan (artikel *Dashboard semua cabang*
  ID + EN).
- Tes: `lakuna_flutter/test/dashboard/dashboard_view_model_test.dart`,
  `test/dashboard/dashboard_view_test.dart`.

**Antarmuka:**
- Konsumsi: `loadDashboard`, `tenantStatus`, `deviceLiveness`,
  `deviceStale`, `hourAxis`, `averagePerReceipt`, `SpreadsheetExporter`.
- `DashboardViewModel(repository, timer:)`: `load` saat dibuka dan tiap 60
  detik (status perangkat), `selectOutlet(UuidValue?)` (`null` = *Semua
  cabang*), `exportExcel()`. Status gagal (offline) → kartu perangkat
  "Status perangkat butuh internet", angka penjualan tetap tampil.

- [ ] Tes gagal VM: total semua cabang = jumlah per outlet; pilih cabang
  memfilter tabel/grafik/terlaris; poll memanggil `tenantStatus` lagi
  setelah 60 detik (fake async); offline → `devicesUnavailable`; *Perlu
  perhatian* kosong → `allClear`.
- [ ] Tes gagal widget (1280 dan 390 px): kartu KPI, tabel *Per cabang hari
  ini* dengan baris Total, *Semua beres*; menu *Dashboard semua cabang*
  hanya bila hosting aktif dan izin `reports:view`.
- [ ] Implementasi, tes lulus; uji manual web + Xvfb (data demo 2 cabang),
  tangkapan layar terang/gelap/mobile.
- [ ] Rilis 0.171.0: PR, CI, review, merge, cek aset.

## Tahap 4 · Web di paket VPS (v0.172.0)

### Tugas 16: Caddy menyajikan `/app/`, image dan aset rilis

**Berkas:**
- Ubah: `lakuna_server/deploy/Caddyfile` (`/` → `/app/`; `handle_path /app/*`
  file server dengan `try_files {path} /index.html`, `Cache-Control`
  `no-cache` untuk `index.html`, tanpa COOP/COEP (hasil spike); situs
  media + CORS aturan 25a),
  `lakuna_server/deploy/caddy/Dockerfile` (salin build web dari tahap build
  Flutter atau dari artefak `web`), `.github/workflows/release.yml` (job
  `web`: `flutter build web --release --no-web-resources-cdn --base-href /app/`,
  aset `lakuna-<versi>-web.zip`, dipakai image caddy), `ci.yml` (validasi
  Caddyfile yang baru), `docker-compose.build.yaml`.
- Tes: `lakuna_server/deploy/test/caddy_web_test.sh` (Caddy lokal + `curl`:
  `/` 30x ke `/app/`, `/app/produk` mengembalikan `index.html`, header
  tanpa COEP, `/sync/status` tetap ke server, preflight `OPTIONS` situs
  media dengan `Origin` domain utama mendapat `Access-Control-Allow-Origin`).

- [ ] Tes gagal skrip (Caddyfile lama), jalankan `sh lakuna_server/deploy/test/caddy_web_test.sh`: gagal.
- [ ] Implementasi; tes lulus; `caddy validate` CI lulus. Commit.

### Tugas 17: Panduan, uji ujung ke ujung, rilis 0.172.0

**Berkas:**
- Ubah: `docs/server/vps.md` (alamat `/app/`, `TOTP_ENCRYPTION_KEY`,
  aktifkan verifikasi 2 langkah, CORS penyedia S3 lain, `totp-reset`),
  panduan aplikasi (artikel *Versi web* ID + EN + tangkapan layar WebP),
  CHANGELOG 0.172.0, versi `0.172.0+175`, spec (Status & gap semua
  tahap), `specs/README.md`, STATUS-JEDA, memori proyek.

- [ ] Uji ujung ke ujung: compose lokal (`docker-compose.build.yaml`, atau
  Caddy + server biner bila Docker tidak ada) → Chromium membuka
  `https://localhost/app/` → login + TOTP (kode dari `totpCode` di skrip
  uji) → dashboard → ubah harga → perangkat Linux Xvfb menerima. Tangkapan
  layar.
- [ ] Rilis 0.172.0: PR, CI, review, merge; cek rilis memuat 8 aset +
  `lakuna-0.172.0-web.zip` dan image `lakuna-caddy:0.172.0` berisi `/app/`.
