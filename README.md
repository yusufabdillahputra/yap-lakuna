# Lakuna

Aplikasi kasir (POS) offline-first untuk UMKM Indonesia, mode Retail dan
F&B. Data disimpan di perangkat sehingga kasir tetap jalan tanpa internet.
Lakuna adalah versi Flutter dari
[Storeku](https://github.com/yusufabdillahputra/storeku).

## Unduh

Installer setiap versi ada di halaman
[Releases](https://github.com/yusufabdillahputra/yap-lakuna/releases):
Windows (`.exe`, `.msi`), Linux (`.deb`), macOS (`.dmg`), Android (`.apk`,
`.aab`), dan iOS (`.ipa` tanpa tanda tangan, untuk pengujian).

- Di Windows pilih **salah satu** installer (`.exe` atau `.msi`), jangan
  keduanya.
- Berkas Android berakhiran `-uji` ditandatangani kunci sementara: pembaruan
  ke versi berikutnya mengharuskan uninstall dan menghapus data di perangkat.
  Gunakan hanya untuk mencoba.

## Teknologi

- **Flutter** 3.47 + **Forui** (preset `conhcc`: Zinc + Sky, Montserrat,
  DM Sans, ikon Tabler), Bahasa Indonesia dan Inggris, mode terang/gelap.
- **Serverpod** 4.1: satu skema model YAML untuk database SQLite di perangkat
  dan PostgreSQL di server (sinkronisasi di fase 2).
- Arsitektur aplikasi mengikuti panduan resmi Flutter (MVVM, repositori,
  `provider`, `go_router`).

## Struktur repo

| Folder | Isi |
| --- | --- |
| `lakuna_flutter/` | Aplikasi Flutter |
| `lakuna_server/` | Server Serverpod dan model data (`.spy.yaml`) |
| `lakuna_client/` | Klien hasil generate Serverpod |
| `packages/lakuna_domain/` | Aturan bisnis Dart murni (uang, jumlah, izin, nomor nota) |
| `packages/lakuna_data/` | Database lokal dan outbox sinkronisasi |
| `docs/superpowers/` | Spec dan rencana per modul |
| `tools/packaging/` | Skrip pembuat installer |

## Mengembangkan

Butuh Flutter 3.47.9.

```bash
flutter pub get
(cd packages/lakuna_domain && dart test)
(cd packages/lakuna_data && dart test)
# Tes server memakai PostgreSQL tertanam (tanpa Docker). Tanpa
# lakuna_server/config/passwords.yaml, isi kata sandi tes lewat variabel:
export SERVERPOD_PASSWORD_database=lakuna-test
export SERVERPOD_PASSWORD_emailSecretHashPepper=lakuna-test
export SERVERPOD_PASSWORD_jwtHmacSha512PrivateKey=lakuna-test
export SERVERPOD_PASSWORD_jwtRefreshTokenHashPepper=lakuna-test
(cd lakuna_server && dart test)
(cd lakuna_flutter && flutter test)
(cd lakuna_flutter && flutter run -d linux)   # atau windows / macos / android
```

Aturan proyek ada di [`CLAUDE.md`](CLAUDE.md), panduan alat Serverpod untuk
agen AI di [`AGENTS.md`](AGENTS.md), dan arsitektur di
[spec F0](docs/superpowers/specs/2026-11-03-f0-fondasi-arsitektur-design.md).
Riwayat perubahan di [`CHANGELOG.md`](CHANGELOG.md).

## Lisensi pihak ketiga

Lihat [`NOTICE.md`](NOTICE.md).
