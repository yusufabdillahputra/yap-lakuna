# F0 · Fondasi & arsitektur Lakuna

- **Fase:** 0 (dipakai semua fase)
- **Status:** Dirilis di v0.1.0 (aturan kontras v0.1.1)
- **Acuan:** spec F0 Storeku
  (`yusufabdillahputra/storeku`, `docs/superpowers/specs/2026-11-02-f0-fondasi-arsitektur-design.md`),
  kanvas [Desain UI Lakuna](https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525) (89 artboard, Forui `conhcc`; spec
  `2026-11-03-ui-desain-lakuna-forui-design.md` dan audit fitur
  `2026-11-03-ui-audit-fitur-lakuna.md`), panduan arsitektur aplikasi resmi Flutter (docs.flutter.dev/app-architecture),
  dokumentasi Serverpod 4.1.

## Tujuan

Lakuna adalah aplikasi kasir offline-first untuk UMKM Indonesia (Retail dan
F&B), versi Flutter dari ide dan rancangan Storeku. Spec ini menetapkan aturan
bersama untuk semua modul: struktur repo, database, sync, RBAC, bahasa, tema,
aset offline, pengujian, CI, dan rilis. Spec modul lain menganggap aturan di
sini berlaku.

## Keputusan Yusuf (2026-11-03)

1. Flutter dipilih karena lebih matang daripada Dioxus. Pengembangan Storeku
   **ditunda**; fokus penuh ke Lakuna. Storeku **tidak** akan pernah sync ke
   server Lakuna, jadi tidak ada syarat kompatibilitas data. Rancangan
   Storeku (tabel, alur, aturan) hanya acuan.
2. Komponen UI memakai **Forui** dengan preset `conhcc` secara penuh
   (`dart run forui init --preset conhcc`): warna dasar Zinc, warna utama Sky
   (`#0069A8` terang, `#00598A` gelap), judul Montserrat, isi DM Sans, ikon
   Tabler, radius Medium. Palet pastel dan Plus Jakarta Sans milik Storeku
   **tidak** dipakai. Acuan visual setiap layar adalah kanvas
   [Desain UI Lakuna](https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525) (hasil thread desain: 54 artboard Storeku
   dikonversi ke Forui + 16 layar detail (audit + kata sandi/PIN) + 2 halaman
   fondasi baru + 17 layar mode gelap baru, total 89 artboard).
3. Semua aset harus bisa dipakai tanpa internet.
4. Satu codebase Dart untuk aplikasi dan backend: **Serverpod** (model YAML),
   dengan dukungan pengembangan berbasis AI dari Serverpod dipakai maksimal.
5. Denah meja F&B memakai paket `vyuh_node_flow` (berlaku saat modul F&B
   dikerjakan).
6. README dan dokumen publik Lakuna tidak menyebut proyek acuan lain selain
   Storeku.
7. CI memakai runner GitHub-hosted dengan job paralel sebanyak mungkin
   (repo publik).

## Prinsip (sama dengan Storeku)

1. **Offline-first.** SQLite di perangkat adalah tempat kerja utama. Semua
   fitur fase 1 jalan tanpa internet.
2. **ID dibuat di perangkat** (UUIDv7).
3. **Aturan bisnis di Dart** (`lakuna_domain`), bukan trigger database.
4. **Dokumen final append-only.** Koreksi lewat dokumen baru (void, retur,
   penyesuaian).
5. **Saldo adalah hasil hitung.** Stok dan saldo hutang/piutang berupa ledger;
   angka saldo hanya cache yang bisa dihitung ulang.
6. **Multi-tenant sejak awal.** Tabel bisnis punya `tenant_id`; tabel
   operasional punya `outlet_id`.

## Struktur monorepo (pub workspace)

| Paket | Isi | Bergantung pada |
| --- | --- | --- |
| `lakuna_server` | Server Serverpod. Model `.spy.yaml` di `lib/src/<area>/` adalah **sumber skema tunggal** untuk SQLite di perangkat dan Postgres di server. Endpoint sync di fase 2 | serverpod 4.1 |
| `lakuna_client` | Hasil generate Serverpod: kelas model, protokol, migrasi database klien. **Jangan diedit tangan** | serverpod_client |
| `packages/lakuna_domain` | Dart murni: `Money`, `BasisPoints`, `Qty`, `newId()`, `Hlc`, katalog `Permission` + `DefaultRole`, nomor nota + `DailyCounter`. Bertambah per modul | `uuid` |
| `packages/lakuna_data` | Akses database lokal: `LakunaStore` (buka/migrasi SQLite), `SyncTx` (tulis + outbox dalam satu transaksi), `sync_state`, `LocalPreferences`. Repositori modul ditambahkan di sini | lakuna_client, lakuna_domain, serverpod_database |
| `lakuna_flutter` | Aplikasi Flutter: Forui, MVVM, go_router, i18n, layar per modul | semua paket di atas |

Aturan: `lakuna_domain` tidak boleh meng-import Flutter atau Serverpod supaya
bisa dipakai di aplikasi dan server. Aplikasi tidak boleh memanggil
`ClientDatabaseSession` langsung dari widget; semua akses data lewat
repositori.

## Database (model Serverpod + SQLite)

- Model ditulis di `.spy.yaml` dengan `database: all` (tabel ada di SQLite
  perangkat dan Postgres server) atau `database: client` (hanya di
  perangkat). `serverpod generate` membuat kelas Dart dan migrasi; hasilnya
  di-commit dan CI memeriksa tidak ada perubahan setelah generate ulang.
- Tabel SQLite dibuat `STRICT` oleh Serverpod; ID `UuidValue` (UUIDv7,
  `defaultModel=random_v7`).
- Penamaan English `snake_case`, tabel jamak, FK `<tabel_tunggal>_id`.
  Serverpod memakai camelCase sebagai nama kolom bawaan, jadi **setiap field
  wajib diberi `column=snake_name`** bila namanya lebih dari satu kata.
  `tableName` adalah nama field yang dicadangkan Serverpod.
- Uang `int` rupiah penuh. Persen dalam basis poin (100 bp = 1%). Jumlah
  barang `int` mili-satuan (`*_milli`). Tanpa `double`.
- FK memakai `relation(parent=<tabel>, onDelete=Restrict)`; hapus data =
  soft delete (`deleted_at`).
- Kolom sync standar setiap tabel yang disinkronkan: `created_at`,
  `updated_at`, `deleted_at`, `created_by`, `updated_by`, `version`, `hlc`,
  `origin_device_id`.
- Semua tulis data bisnis lewat `LakunaStore.write((tx) => ...)` dan
  `SyncTx.insert/update`. Pemanggil membuat stempel (`tx.stamp()`) dan
  mengisi kolom sync baris dari stempel itu: `hlc`, `origin_device_id`,
  `created_by`/`updated_by` (= aktor), serta `version` + 1 dan `updated_at`
  saat update. `SyncTx` **menolak** baris yang `hlc`, `origin_device_id`, atau
  kolom aktornya tidak sama dengan stempel (`SyncStampMismatch`) sebelum
  menulis apa pun, lalu menambah satu entri `sync_outbox` di transaksi yang
  sama. Error di tengah transaksi membatalkan baris data dan entri outbox
  bersama-sama.
- Indeks unik tidak boleh memakai kolom yang bisa `NULL` sebagai pembeda
  (SQLite dan Postgres menganggap `NULL` selalu berbeda). Contoh:
  `settings` memakai `scope_key` (`'tenant'` atau `'outlet:<id>'`) dengan
  unik `(tenant_id, scope_key, key)`.
- Soft delete dan kunci alami unik (mis. kode outlet, keanggotaan staf di
  outlet): baris yang di-soft-delete tetap memegang kuncinya, jadi membuat
  ulang data yang sama dilakukan dengan **memulihkan** baris lama
  (`deleted_at` dikosongkan), bukan menyisipkan baris baru.
- Tabel lokal perangkat (`database: client`): `sync_outbox`,
  `sync_state`, `local_preferences`.
- Tabel fondasi v0.1.0: `tenants`, `outlets`, `stock_locations`, `devices`,
  `settings`, `staff_members`, `outlet_members` + tabel lokal di atas. Modul
  lain menambah model dan migrasi (`serverpod create-migration --tag <modul>`).
- Lokasi berkas: folder data aplikasi (`path_provider`), nama `lakuna.sqlite`.
  Folder itu bergantung pada identitas aplikasi, jadi identitas berikut
  **tidak boleh diubah** setelah rilis: Linux `id.lakuna.app`
  (`~/.local/share/id.lakuna.app`), Windows CompanyName `Lakuna` + ProductName
  `Lakuna` (`%APPDATA%\Lakuna\Lakuna`), Android/iOS/macOS bundle
  `id.lakuna.app`.
  Variabel lingkungan `LAKUNA_DATA_DIR` menggantinya untuk uji manual.
- Nomor dokumen memuat kode outlet dan perangkat: nota
  `OUTLET-DEVICE-YYMMDD-0001`, dokumen lain `<PREFIX>-OUTLET-DEVICE-YYMMDD-0001`.

## Sync (disiapkan, dijalankan fase 2)

- HLC teks yang bisa diurutkan: `<millis 13 digit>-<counter 4 digit>-<node>`.
  HLC terakhir disimpan di `sync_state` (`last_hlc`); jam perangkat
  yang mundur tidak membuat HLC mundur. Bila counter melewati 9999, HLC
  pindah ke milidetik berikutnya dengan counter 0, sehingga urutan teks
  selalu sama dengan urutan HLC.
- `sync_outbox(table_name, row_id, op, payload_json, hlc, status,
  attempts, last_error, created_at)`; status `pending/sent/acked/conflict`.
- Fase 2: endpoint Serverpod `push`/`pull`, last-writer-wins per baris dengan
  HLC. Paket resmi `serverpod_offline_sync` dievaluasi lagi bila sudah
  matang (2026-11 masih 0.0.11); sampai saat itu Lakuna memakai outbox
  sendiri.

## Deploy server (Fase 2)

- Keputusan Yusuf (2026-11-03): server Lakuna di **VPS sendiri** (mis.
  Hostinger atau IDCloudhost), **bukan** Serverpod Cloud. Baru dikerjakan di
  Fase 2.
- Rencana: image Docker dari `lakuna_server/Dockerfile` + PostgreSQL di VPS
  yang sama (atau terkelola), reverse proxy HTTPS, dan object storage
  S3-compatible lewat `serverpod_cloud_storage_s3_compat`. Detail di spec
  Fase 2 modul 1 (server sync & aktivasi hosting).
- Workflow `deploy.yml` dan paket `serverpod_cloud_storage` bawaan template
  `serverpod create` sudah dihapus; penyimpanan berkas server sementara
  memakai `DatabaseCloudStorage`.

## RBAC

- Model staf → role → izin `resource:action`, keanggotaan per outlet di
  `outlet_members(staff_member_id, role_name)`.
- Katalog izin di kode (`Permission` di `lakuna_domain`), 21 izin dengan nama
  yang sama dengan Storeku. Role bawaan `owner`, `manager`, `cashier`,
  `waiter`, `stock_keeper`.
- UI menyembunyikan menu/tombol tanpa izin; repositori memeriksa izin lagi.
  Implementasi penuh di modul F1-02 (PIN) dan F1-17 (pengguna & role).

## Arsitektur aplikasi Flutter

Mengikuti panduan arsitektur resmi Flutter:

- **Lapisan UI**: `View` (widget) + `ViewModel` (`ChangeNotifier`). View
  tidak memuat logika selain tampilan. Aksi dari view memakai `Command0` /
  `Command1` (`lib/utils/command.dart`) yang menyediakan status `running`,
  `error`, `completed`.
- **Lapisan data**: repositori abstrak di `lib/data/repositories/` dengan
  implementasi lokal di atas `lakuna_data`. Setiap repositori punya versi
  palsu (`test/testing/fake_*`) untuk tes widget.
- Hasil operasi berupa `Result<T>` (`Ok` / `Error`), bukan exception yang
  lolos ke UI.
- Model immutable. Dependency injection lewat `provider`
  (`MultiProvider` di `main.dart`). Navigasi `go_router` dengan `ShellRoute`.
- Struktur folder: `lib/config`, `lib/data`, `lib/routing`,
  `lib/ui/<fitur>/` (view + view model), `lib/ui/core/` (shell, tema,
  komponen bersama), `lib/utils`.

## UI, tema, bahasa

- **Forui 0.27** + preset `conhcc`. Berkas tema hasil CLI di
  `lakuna_flutter/lib/ui/core/theme/` boleh disesuaikan tangan; fungsi
  `lakunaLightTheme` / `lakunaDarkTheme` menerima `touch` (varian sentuh
  untuk Android/iOS, varian desktop untuk Windows/Linux/macOS).
- `MaterialApp.router` dibungkus `FTheme`; tema Material diturunkan lewat
  `lakunaMaterialTheme()` (`toApproximateMaterialTheme()` dengan ikon bawaan
  berwarna `foreground`, bukan `primary`).
- **Aturan kontras** (dari kanvas desain, berlaku sejak v0.1.1, kode di
  `theme/contrast.dart`):
  - Semua teks minimal 4.5:1 di latarnya.
  - Token warna dasar tetap hasil CLI Forui. Isi tombol primary tetap Sky
    (`#0069A8` terang, `#00598A` gelap).
  - Di tema gelap, primary yang dipakai sebagai **teks/ikon** (menu aktif,
    ikon prefix tile/item) memakai Sky muda `#74D4FF`.
  - Tombol destructive berisi warna penuh dengan teks `#FAFAFA`: `#E7000B`
    terang, `#C10007` gelap. Token `destructive` sebagai teks/ikon tetap
    (`#FF6467` gelap).
  - Teks sekunder di permukaan berwarna tema terang (tab tidak aktif) memakai
    `#52525C`.
  - Widget Forui baru yang memakai `primary` sebagai teks/ikon diberi gaya
    dari warna aksen yang sama saat pertama dipakai, dengan tes kontras.
- Mode tema Terang / Gelap / Ikuti sistem. Fase 0 menyimpannya di
  `local_preferences`; setelah login PIN ada, disimpan per staf.
- Bahasa: `flutter_localizations` + `intl`, berkas ARB `app_id.arb` (bawaan,
  templat) dan `app_en.arb`. Setiap kunci baru wajib ada di keduanya; tes
  memastikan kedua berkas punya kunci yang sama. Komponen Forui memakai
  `FLocalizations` (sudah ada bahasa Indonesia).
- Ikon: Tabler (`tabler_icons_plus`).
- Breakpoint sama dengan Storeku: mobile < 600 px (navigasi bawah), tablet
  600–1279 px (sidebar 200 px), desktop ≥ 1280 px (sidebar 256 px).
- Status offline selalu terlihat di bilah atas (ringkas berupa ikon di
  mobile, dengan label aksesibilitas).

## Aset offline

- Font Montserrat dan DM Sans (OFL) disimpan di `lakuna_flutter/assets/fonts/`
  bersama lisensinya. Tidak memakai `google_fonts`.
- Ikon Tabler berupa font di dalam paket `tabler_icons_plus`.
- Logo, ikon aplikasi, dan placeholder DiceBear dibuat sekali oleh skrip
  (spec Merek) lalu di-commit; aplikasi tidak memanggil api.dicebear.com.
- SQLite ikut terbundel lewat build hook paket `sqlite3`.
- Gambar unggahan pengguna (foto produk, QRIS) disalin ke folder data.
- Tes `offline_assets_test.dart` gagal bila `lakuna_flutter/lib` memakai
  `Image.network`, `NetworkImage`, `google_fonts`, atau `package:http`.

## Pengembangan dengan AI (Serverpod)

- `AGENTS.md` berisi aturan kerja agen dan checklist setelah perubahan;
  `CLAUDE.md` berisi aturan proyek (Bahasa Indonesia).
- `.mcp.json` mendaftarkan MCP `serverpod mcp-server` (migrasi, log, hot
  reload, menjalankan aplikasi) dan `dart mcp-server` (analisis, tes,
  flutter_driver).
- Skill Serverpod, Flutter, dan Relic di `.claude/skills/` (hasil
  `skills get --ide claude`) di-commit agar setiap sesi memakainya.
- `lakuna_flutter/lib/driver.dart` menjalankan aplikasi dengan ekstensi
  Flutter Driver untuk uji oleh agen.

## Pengujian

- `lakuna_domain`: unit test `dart test`.
- `lakuna_data`: tes dengan SQLite di folder sementara, termasuk outbox
  terisi dalam transaksi yang sama, rollback tidak meninggalkan outbox,
  semua tabel `STRICT`, HLC monoton.
- `lakuna_server`: tes integrasi `withServerpod` dengan PostgreSQL tertanam
  (tanpa Docker).
- `lakuna_flutter`: tes view model dengan repositori palsu, widget test
  (bahasa, tema, tata letak per breakpoint), tes kelengkapan kunci ARB, tes
  aset offline.
- Uji manual: aplikasi Linux di Xvfb 1280x800 dengan `LAKUNA_DATA_DIR`,
  tangkapan layar setiap layar yang berubah.

## CI dan rilis

- GitHub Actions, hanya runner GitHub-hosted, semua job CI paralel (tanpa
  `needs:`): format, analyze, cek kode generate, tes domain, tes data, tes
  server, tes Flutter, build Linux, Windows, macOS, Android, iOS (tanpa tanda
  tangan).
- Versi di `lakuna_flutter/pubspec.yaml` (`X.Y.Z+build`, SemVer; `0.x` =
  pre-release). Setiap rilis menambah bagian `CHANGELOG.md` (Keep a Changelog,
  Bahasa Indonesia: Ditambahkan / Diubah / Diperbaiki / Dihapus / Keamanan /
  Catatan teknis).
- Setelah merge ke `main`, `release.yml` membuat installer paralel, lalu tag
  `vX.Y.Z` dan GitHub Release dari CHANGELOG: Windows `.exe` (Inno Setup) +
  `.msi` (WiX 5), Linux `.deb`, macOS `.dmg`, Android `.apk` + `.aab`, iOS
  `.ipa` tanpa tanda tangan. Skrip kemasan di `tools/packaging/`.

## Praktik terbaik yang diikuti

- Arsitektur MVVM resmi Flutter (bukan Riverpod/Bloc) agar kode mudah dibaca
  agen dan manusia, dan cocok dengan contoh resmi Serverpod.
- Kode generate Serverpod dan l10n di-commit dan dicek CI.
- Satu sumber skema (`.spy.yaml`) untuk klien dan server, migrasi dibuat
  CLI, `migration.sql` hanya diubah tangan bila perlu menjaga data.
- Rahasia server (`config/passwords.yaml`) tidak di-commit; CI memakai
  variabel `SERVERPOD_PASSWORD_*` khusus tes.
- Lint `flutter_lints` / `lints` dengan `--fatal-infos`, `dart format`
  wajib.

## Kriteria selesai v0.1.0

- Monorepo dengan lima paket, analyze bersih, semua tes lulus.
- Aplikasi terbuka di Linux dengan tema conhcc terang/gelap, bahasa
  Indonesia/Inggris, shell navigasi responsif, beranda, pengaturan, dan
  status offline; database dibuat di folder data dan pengaturan bertahan
  setelah aplikasi dibuka ulang.
- CI paralel hijau, rilis v0.1.0 terbit otomatis.

## Status & gap

| Topik | Rancangan | Kode saat ini | Rekomendasi |
| --- | --- | --- | --- |
| Logo & ikon aplikasi | Mark Etalase (DiceBear icons `shopWindow`) diwarnai Sky | Ikon bawaan Flutter | Spec Merek Lakuna setelah v0.1.0 |
| Penyimpanan tema per staf | Per pengguna | Per perangkat (`local_preferences`) | Pindah ke per staf di F1-02 |
| Layar sesuai kanvas Lakuna | Kanvas Desain UI Lakuna (sidebar `FSidebar`, warna status `LakunaStatusColors`) | Shell, beranda, pengaturan memakai komponen Forui bawaan; `LakunaStatusColors` belum ada | Samakan per modul dengan kanvas; tambah `ThemeExtension` status saat layar pertama membutuhkannya |
| Aturan kontras kanvas | Semua teks ≥ 4.5:1 | v0.1.1: tombol destructive isi penuh, primary sebagai teks/ikon gelap `#74D4FF` (navigasi bawah, tile, item, grup), tab terang `#52525C`, ikon Material bawaan `foreground` (`theme/contrast.dart`, diuji) | Saat pertama dipakai, beri warna aksen ke `FPopoverMenu` mode tile dan `FSelectMenuTile` (masih `#00598A` sebagai ikon di gelap); teks `mutedForeground` di `FItem` terpilih / `FTile` hover tema terang 4.4:1, pakai `#52525C`; warna hover/tekan tombol (destructive dan primary) turun di bawah 4.5:1 sesaat, tetapkan delta sendiri bila perlu |
| Installer Windows | Bahasa Indonesia, satu cara pasang | Inno Setup berbahasa Inggris; `.exe` dan `.msi` memasang ke folder yang sama dengan ID produk berbeda | Pilih salah satu (dicatat di README); tambahkan `.isl` Indonesia bila perlu |
| Tanda tangan Android | Satu kunci rilis tetap | `release.yml` memakai secret `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` bila ada; tanpa itu APK/AAB diberi akhiran `-uji` dan catatan rilis memperingatkan | Pemilik membuat keystore dan mengisi secret sebelum data toko sungguhan dipakai |
| Tanda tangan iOS | Sertifikat Apple | IPA tanpa tanda tangan | Saat akun Apple Developer siap |
| Versi di aplikasi | Dari `pubspec.yaml` | `--dart-define=LAKUNA_VERSION` (diisi `release.yml`); build tanpa itu menampilkan `dev` | Pakai `package_info_plus` bila build lokal perlu versi akurat |
| Layar gagal mulai | Pesan + lokasi data | Bila database gagal dibuka, aplikasi berhenti tanpa pesan | Tambahkan layar error di modul Data & backup (F1-19) |
| Menu mobile | Semua modul terjangkau | Navigasi bawah 4 menu, belum ada menu "Lainnya" | Tambahkan sebelum modul nyata pertama selain kasir/produk |
