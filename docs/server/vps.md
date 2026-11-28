# Server Lakuna di VPS

Panduan memasang server sync Lakuna (versi hosting) di VPS sendiri, mis.
Hostinger atau IDCloudhost, dengan Docker. Satu paket yang sama dipakai
untuk dua keperluan:

- **[Admin server hosting](#admin-server-hosting)**: satu server untuk banyak
  toko. Pengelola membuat kode aktivasi untuk setiap toko yang berlangganan.
- **[Pasang server sendiri](#pasang-server-sendiri)**: satu toko memasang
  server untuk dirinya sendiri, dari sewa VPS sampai kode aktivasi pertama.

Isi paket ada di [`lakuna_server/deploy/`](../../lakuna_server/deploy):

| Berkas | Isi |
| --- | --- |
| `docker-compose.yaml` | Layanan `server` (Lakuna), `postgres` (database), `caddy` (HTTPS otomatis + batas laju), `backup` (pg_dump harian), dan `s3` (object storage gambar SeaweedFS, opsional, profil `s3`). |
| `Caddyfile` | HTTPS Let's Encrypt untuk domain server, batas permintaan per IP untuk aktivasi/kode pasang/login dan sync. |
| `.env.example` | Contoh pengaturan: domain, rahasia, SMTP, object storage. |
| `backup.sh` | Skrip backup yang dipakai layanan `backup`. |

Image server dan Caddy diterbitkan setiap rilis di GitHub Container Registry
(`ghcr.io/yusufabdillahputra/lakuna-server` dan `lakuna-caddy`, tag versi
mis. `0.168.0` dan `latest`), jadi VPS tidak perlu membangun apa pun.

## Kebutuhan

- VPS Linux 64-bit (Ubuntu 24.04 atau Debian 12), minimal **1 vCPU, 2 GB
  RAM, 20 GB disk**. Untuk server hosting banyak toko mulai dari 2 vCPU /
  4 GB / 80 GB dan pantau disknya (lihat [Pemantauan](#pemantauan-dan-kuota-disk)).
- Domain atau subdomain, mis. `sync.tokoanda.id`, dengan akses ke DNS.
- Port **80** dan **443** terbuka (TCP; 443 juga UDP untuk HTTP/3).
- Opsional: akun SMTP (mis. email domain dari penyedia hosting) untuk
  mengirim kode verifikasi pendaftaran pemilik.

## Pasang server sendiri

Langkah untuk satu toko, dari nol.

### 1. Sewa VPS dan arahkan domain

1. Sewa VPS dengan sistem operasi Ubuntu 24.04. Catat **alamat IP** dan
   kata sandi root dari panel penyedia.
2. Di pengelola DNS domain, buat **A record**: nama `sync` (atau nama
   lain), nilai = IP VPS. Bila VPS punya IPv6, buat juga **AAAA record**.
   Tunggu beberapa menit sampai `ping sync.tokoanda.id` menjawab dari IP
   VPS.

### 2. Pasang Docker

Masuk ke VPS (`ssh root@IP-VPS`), lalu:

```bash
apt-get update && apt-get install -y ca-certificates curl git
curl -fsSL https://get.docker.com | sh
docker compose version   # harus tampil versi Docker Compose v2
```

Bila VPS memakai firewall `ufw`:

```bash
ufw allow OpenSSH && ufw allow 80/tcp && ufw allow 443/tcp && ufw allow 443/udp && ufw enable
```

### 3. Ambil paket deploy

```bash
git clone --depth 1 https://github.com/yusufabdillahputra/yap-lakuna.git /opt/lakuna-src
cp -r /opt/lakuna-src/lakuna_server/deploy /opt/lakuna
cd /opt/lakuna
cp .env.example .env
```

### 4. Isi `.env`

Buka `nano .env` dan isi:

- `LAKUNA_DOMAIN`: domain dari langkah 1, tanpa `https://`, mis.
  `sync.tokoanda.id`.
- `ACME_EMAIL`: email Anda (pemberitahuan sertifikat HTTPS).
- Lima rahasia (`POSTGRES_PASSWORD`, `SERVICE_SECRET`,
  `EMAIL_SECRET_HASH_PEPPER`, `JWT_HMAC_SHA512_PRIVATE_KEY`,
  `JWT_REFRESH_TOKEN_HASH_PEPPER`): isi masing-masing dengan teks acak
  berbeda. Buat dengan:

  ```bash
  for k in POSTGRES_PASSWORD SERVICE_SECRET EMAIL_SECRET_HASH_PEPPER JWT_HMAC_SHA512_PRIVATE_KEY JWT_REFRESH_TOKEN_HASH_PEPPER; do
    sed -i "s|^$k=.*|$k=$(openssl rand -hex 32)|" .env
  done
  ```

- SMTP (disarankan): `SMTP_HOST`, `SMTP_PORT` (587 untuk STARTTLS, 465
  untuk SSL), `SMTP_USER`, `SMTP_PASSWORD`, `SMTP_FROM`. Tanpa SMTP, kode
  verifikasi pendaftaran pemilik hanya tercatat di tabel log server:

  ```bash
  docker compose exec postgres psql -U lakuna -d lakuna -c \
    "SELECT \"time\", message FROM serverpod_log WHERE message LIKE 'SMTP belum diatur%' ORDER BY \"time\" DESC LIMIT 3;"
  ```

> **Simpan `.env` baik-baik.** Rahasia JWT dan pepper tidak boleh berubah
> setelah server dipakai: mengubahnya membuat semua login pemilik dan kode
> verifikasi yang sedang berjalan tidak berlaku. `POSTGRES_PASSWORD` hanya
> dipakai saat database pertama kali dibuat.

### 5. Nyalakan

```bash
docker compose up -d
docker compose ps        # server, postgres, caddy, backup: running/healthy
docker compose logs -f server   # Ctrl+C untuk keluar
```

Server menerapkan migrasi database sendiri saat menyala. Caddy meminta
sertifikat HTTPS ke Let's Encrypt dalam beberapa detik pertama; bila gagal,
periksa DNS dan port 80/443 (`docker compose logs caddy`).

Uji dari komputer lain: buka `https://sync.tokoanda.id/readyz` di browser.
Halaman menjawab `OK` (atau kosong dengan status 200) bila server siap.

### 6. Buat kode aktivasi pertama

```bash
docker compose exec server ./bin/admin activation-code --note "Toko Anda"
```

Kode 8 huruf/angka tampil **sekali**; berlaku 30 hari (`--days 60` untuk
lebih lama) dan hanya untuk satu toko.

### 7. Hubungkan aplikasi

Di aplikasi Lakuna perangkat utama: **Pengaturan › Versi hosting ›
Aktifkan versi hosting**, pilih **Server sendiri**, isi
`https://sync.tokoanda.id` dan kode aktivasi, lalu ikuti langkahnya (lihat
Panduan › Versi hosting di aplikasi). Perangkat lain bergabung dengan kode
pasang dari perangkat utama.

## Admin server hosting

Server yang sama melayani banyak toko. Setiap toko adalah tenant terpisah;
data antar toko tidak pernah tercampur.

### Toko baru

1. Buat kode aktivasi per toko, catatannya nama toko atau nomor
   langganan:

   ```bash
   docker compose exec server ./bin/admin activation-code --note "Toko Ani · INV-2026-031" --days 14
   ```

2. Kirim kode dan alamat server ke pemilik toko. Build aplikasi yang
   membawa `LAKUNA_HOSTING_URL` (variabel repo, lihat [Rilis](#rilis-aplikasi-dengan-server-lakuna))
   menampilkan pilihan **Server Lakuna** sehingga pemilik cukup mengisi
   kode.
3. Kode yang tidak dipakai kedaluwarsa sendiri. Kode yang sudah dipakai
   tidak bisa dipakai toko lain.

### Pemantauan dan kuota disk

```bash
docker compose ps                         # semua layanan running/healthy
docker compose logs --since 1h server     # galat terbaru
df -h /                                   # sisa disk VPS
docker system df -v | head -30            # ukuran volume (postgres, backups, s3)
```

Ukuran data per toko (tenant):

```bash
docker compose exec postgres psql -U lakuna -d lakuna -c "
  SELECT t.name,
         (SELECT count(*) FROM device_credentials d
            WHERE d.tenant_id = t.id AND d.revoked_at IS NULL) AS perangkat,
         (SELECT max(d.last_seen_at) FROM device_credentials d
            WHERE d.tenant_id = t.id) AS terakhir_sync,
         (SELECT pg_size_pretty(coalesce(sum(m.size_bytes), 0)) FROM media_files m
            WHERE m.tenant_id = t.id) AS gambar
  FROM tenants t ORDER BY t.name;"
```

Kode aktivasi yang sudah dibuat:

```bash
docker compose exec postgres psql -U lakuna -d lakuna -c "
  SELECT note, created_at, expires_at, used_at FROM activation_codes
  ORDER BY created_at DESC LIMIT 20;"
```

Saran batas: sisakan minimal 20% disk kosong; bila gambar (`media_files`)
mendominasi, pindahkan gambar ke object storage (bagian berikut).

### Gambar di object storage

Tanpa pengaturan, gambar toko disimpan di database Postgres. Untuk banyak
toko lebih hemat memakai object storage S3-compatible:

- **SeaweedFS di VPS yang sama** (profil `s3`): buat A record kedua, mis.
  `media.tokoanda.id` ke IP VPS, lalu di `.env`:

  ```bash
  MEDIA_DOMAIN=media.tokoanda.id
  S3_ENDPOINT=https://media.tokoanda.id
  S3_ACCESS_KEY=lakuna
  S3_SECRET_KEY=<acak, mis. openssl rand -hex 24>
  S3_BUCKET=lakuna-media
  ```

  Jalankan `docker compose --profile s3 up -d`. Layanan `s3-init` membuat
  bucket privat otomatis (aman dijalankan ulang). Caddy membuka
  `MEDIA_DOMAIN` dengan HTTPS dan meneruskannya ke SeaweedFS.
- **Object storage penyedia** (IDCloudhost Object Storage, Cloudflare R2,
  Wasabi, dll.): isi `S3_ENDPOINT`, `S3_ACCESS_KEY`,
  `S3_SECRET_KEY`, `S3_BUCKET`, `S3_REGION` dari penyedia (R2 memakai
  region `auto`), kosongkan `MEDIA_DOMAIN`, lalu `docker compose up -d`.

`S3_ENDPOINT` harus alamat yang bisa dibuka **dari perangkat kasir**:
aplikasi mengunggah dan mengunduh gambar langsung ke alamat itu dengan URL
bertanda tangan. Jangan pakai `http://s3:8333`. Keempat isian (`S3_ENDPOINT`,
`S3_ACCESS_KEY`, `S3_SECRET_KEY`, `S3_BUCKET`) harus terisi semua; bila
salah satu kosong, server kembali menyimpan gambar di database. Gambar
yang sudah tersimpan di database tidak dipindahkan otomatis.

## Backup dan pulihkan

Layanan `backup` membuat `pg_dump` saat menyala lalu setiap 24 jam ke
volume `backups`, dan menghapus backup yang lebih tua dari
`BACKUP_KEEP_DAYS` (bawaan 14) hari.

```bash
# Backup sekarang
docker compose exec backup lakuna-backup once
# Daftar backup
docker compose exec backup ls -lh /backups
# Salin backup terbaru ke folder VPS (lalu unduh dengan scp/rsync)
docker compose cp backup:/backups ./backups-$(date +%F)
```

Simpan salinan di luar VPS (komputer kantor, Google Drive, atau object
storage lain), misalnya seminggu sekali. Backup di volume hilang bila VPS
dihapus. Gambar di SeaweedFS ada di volume `s3`; salin dengan
`docker compose cp s3:/data ./s3-$(date +%F)`.

Pulihkan ke server (data server saat ini **diganti**):

```bash
docker compose stop server
docker compose cp ./lakuna-20261201-020000.dump postgres:/tmp/pulih.dump
docker compose exec postgres pg_restore -U lakuna -d lakuna --clean --if-exists /tmp/pulih.dump
docker compose start server
```

Setelah pemulihan, perangkat yang sudah sync lebih baru dari backup tetap
memegang data terbarunya dan mengirimnya lagi pada sync berikutnya.

## Pembaruan versi

Perbarui server **sebelum** memperbarui aplikasi di perangkat: aplikasi
baru menolak server yang lebih lama (*Server perlu diperbarui*).

```bash
cd /opt/lakuna
docker compose exec backup lakuna-backup once   # jaga-jaga
docker compose pull
docker compose up -d
docker compose logs --since 5m server           # migrasi diterapkan otomatis
```

Untuk mengunci versi, isi `LAKUNA_SERVER_IMAGE=ghcr.io/yusufabdillahputra/lakuna-server:0.168.0`
(dan `LAKUNA_CADDY_IMAGE` sejenis) di `.env`. Bila berkas paket
(`docker-compose.yaml`, `Caddyfile`) berubah di rilis baru, ambil ulang:
`git -C /opt/lakuna-src pull` lalu salin berkas yang berubah ke
`/opt/lakuna` (jangan timpa `.env`).

## Rilis aplikasi dengan Server Lakuna

Build rilis membawa alamat **Server Lakuna** dari variabel repo GitHub
`LAKUNA_HOSTING_URL` (Settings › Secrets and variables › Actions ›
Variables), mis. `https://sync.lakuna.id`. Kosong = aplikasi hanya
menawarkan **Server sendiri**.

## Masalah umum

| Gejala | Periksa |
| --- | --- |
| Aplikasi: *Server tidak bisa dihubungi* | `https://<domain>/readyz` dari browser; `docker compose ps`; DNS dan port 443. |
| Caddy gagal mendapat sertifikat | A record belum mengarah ke VPS, port 80 tertutup, atau batas Let's Encrypt (tunggu 1 jam). |
| Kode verifikasi email tidak datang | Pengaturan SMTP; sementara ambil kode dari tabel `serverpod_log` (lihat langkah `.env`). |
| *Terlalu banyak permintaan* (HTTP 429) | Batas laju Caddy per IP; naikkan `AUTH_RATE_LIMIT` / `SYNC_RATE_LIMIT` bila banyak kasir memakai satu IP (NAT kantor). |
| Gambar tidak muncul di perangkat lain | `S3_ENDPOINT` harus bisa dibuka dari perangkat; `docker compose logs server s3`. |
| `docker compose pull`: *unauthorized* / *denied* | Paket image di GHCR masih privat. Pemilik repo: GitHub › Packages › `lakuna-server` (dan `lakuna-caddy`) › Package settings › Change visibility › Public (sekali saja). Atau build di VPS dari salinan repo: `cd /opt/lakuna-src/lakuna_server/deploy && docker compose --env-file /opt/lakuna/.env build`, lalu `docker compose up -d` di `/opt/lakuna`. |
| Disk penuh | `docker system df -v`, kurangi `BACKUP_KEEP_DAYS`, pindahkan gambar ke object storage, `docker image prune`. |
