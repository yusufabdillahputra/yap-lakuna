# Desain UI Lakuna (Forui, preset `conhcc`)

Status: disetujui untuk dikerjakan (keputusan Yusuf 2026-11-03).
Kanvas: **"Desain UI Lakuna"** — <https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525>
(privat, milik Yusuf). Kanvas Storeku "Desain UI Retail UMKM" tetap utuh dan
tidak diubah.

## Yang diminta

- **Kata Yusuf (2026-11-03):** desain UI harus disesuaikan dengan Forui
  (<https://forui.dev>) memakai preset `conhcc`, sesuai diskusi di thread
  Lakuna; pekerjaan desain dipisah ke thread sendiri.
- **Keputusan sebelumnya (2026-11-03 04:33Z):** Lakuna memakai preset
  `conhcc` **penuh**, bukan palet pastel / Plus Jakarta Sans milik Storeku.
  Tata letak layar tetap mengikuti kanvas Storeku. Mark logo "Etalase"
  diwarnai ulang ke Sky. Placeholder gambar memakai DiceBear.
- **Kata Yusuf (2026-11-03 04:47Z):** audit ulang desain terhadap fitur yang
  dirancang dan buat lebih detail "agar thread agent tidak salah". Gambar
  QRIS bukan barcode saja, tetapi **kotak persegi panjang vertikal** seperti
  stiker QRIS resmi (header QRIS + GPN, nama merchant, NMID, kode terminal,
  QR, "SATU QRIS UNTUK SEMUA").
- **Kata Yusuf (2026-11-03 04:53Z):** denah meja F&B memakai
  [`vyuh_node_flow`](https://pub.dev/packages/vyuh_node_flow).

## Tujuan

Satu kanvas desain yang menjadi acuan visual aplikasi Flutter Lakuna:
semua 50 layar Storeku (27 layar Fase 1, 6 Fase 2, 7 Fase 3, 8 contoh
gelap, plus 3 halaman fondasi) dengan tata letak dan alur yang sama, tetapi
token warna, tipografi, radius, ikon, dan pola komponennya sama dengan yang
akan dihasilkan `dart run forui init --preset conhcc`. Developer Flutter
harus bisa menyalin nilai dari kanvas langsung ke `FThemeData` tanpa
menerjemahkan lagi.

**Bukan tujuan:** mengubah alur atau urutan layar Storeku. Layar baru hanya
ditambahkan bila audit fitur menemukan alur yang belum tergambar (lihat
`2026-11-03-ui-audit-fitur-lakuna.md`).

## Token dari preset `conhcc`

Nilai diambil dari kode `forui_cli` 0.27.0 (`lib/src/codec.dart`) dan
`forui` 0.27.7, bukan dari ingatan.

### Warna (`FColors`)

| Token | Terang | Gelap |
| --- | --- | --- |
| `background` | `#FFFFFF` | `#09090B` |
| `foreground` | `#09090B` | `#FAFAFA` |
| `primary` (Sky) | `#0069A8` | `#00598A` |
| `primaryForeground` | `#F0F9FF` | `#F0F9FF` |
| `secondary` / `muted` | `#F4F4F5` | `#27272A` |
| `secondaryForeground` | `#18181B` | `#FAFAFA` |
| `mutedForeground` | `#71717B` | `#9F9FA9` |
| `destructive` / `error` | `#E7000B` | `#FF6467` |
| `card` | `#FFFFFF` | `#18181B` |
| `border` | `#E4E4E7` | `#FFFFFF` 10% (≈ `#27272A` di atas kartu) |
| `barrier` | `#000000` 20% | `#000000` 48% |

Warna tambahan yang tidak ada di `FColors` (dibuat sebagai
`ThemeExtension` `LakunaStatusColors`, diambil dari skala Tailwind v4 yang
juga dipakai Forui):

| Peran | Terang (latar / teks) | Gelap (latar / teks) |
| --- | --- | --- |
| Berhasil / tersinkron | `#DCFCE7` / `#016630` | `#032E15` / `#7BF1A8` |
| Peringatan / stok rendah / menunggu | `#FEF3C6` / `#973C00` | `#461901` / `#FFD230` |
| Bahaya / void / konflik | `#FEF2F2` / `#C10007` | `#460809` / `#FFA2A2` |
| Info / pilihan aktif | `#F0F9FF`–`#DFF2FE` / `#00598A` | `#052F4A` / `#74D4FF` |
| Latar aplikasi di belakang kartu | `#FAFAFA` | `#09090B` |

Warna status tetap dibedakan juga dengan ikon dan kecerahan, bukan rona saja.

### Aturan kontras dan mode gelap (keputusan 2026-11-03)

Yusuf meminta teks mode gelap yang kurang terbaca diperbaiki mengikuti
praktik komunitas. Rujukan: Material Design dark theme (permukaan gelap
bertingkat makin terang, hindari putih murni untuk teks, warna jenuh diganti
tona terang), Apple HIG Dark Mode (kontras minimal 4.5:1, usahakan 7:1 untuk
teks kecil; uji dengan Increase Contrast), Radix Colors (warna cerah seperti
Sky muda memakai teks gelap), WCAG 2.2 SC 1.4.3 dan 1.4.11.

| Aturan | Terang | Gelap |
| --- | --- | --- |
| Teks utama | `#09090B` | `#FAFAFA` (19:1 di latar, 17:1 di kartu) |
| Teks sekunder di latar/kartu | `#71717B` | `#9F9FA9` (6.8:1 di kartu) |
| Teks sekunder di permukaan berwarna (tab, badge, kartu terpilih) | `#52525C` (7:1) | `#9F9FA9` |
| Primary sebagai **teks/ikon** (link, tab aktif, nav aktif) | `#0069A8` | `#74D4FF` (10.6:1); jangan `#00598A` (2.7:1) |
| Tombol primary | `#0069A8` + `#F0F9FF` | `#00598A` + `#F0F9FF` (7:1) |
| Tombol destructive | `#E7000B` + `#FAFAFA` | **`#C10007`** + `#FAFAFA` (6.2:1); bukan `#FF6467` + putih (2.8:1) |
| Teks/ikon destructive | `#C10007`/`#E7000B` | `#FF6467` (6.1:1 di kartu) |
| Badge latar Sky muda | — | `#74D4FF` + teks `#052F4A` (8.3:1) |
| Kontrol tanpa warna teks eksplisit | — | wajib `foreground`; jangan biarkan default hitam |

Di Flutter: override `FButtonStyles` destructive untuk tema gelap dan
`FTabs` (label tidak aktif `#52525C` di tema terang); token lain tetap dari
CLI. Semua artboard kanvas diperiksa otomatis: tidak ada teks di bawah 4.5:1
(kecuali dua contoh "jangan" di halaman Gaya visual · mode gelap).

### Tipografi

- Judul (`h1`–`h3`, judul kartu, angka KPI besar): **Montserrat** 600–800.
- Isi, tombol, tabel, angka rupiah: **DM Sans** 400–700, angka
  `tabular-nums` (`FontFeature.tabularFigures()`).
- Font dibundel di `apps/lakuna/assets/fonts/` (sudah diunduh CLI Forui),
  tanpa `google_fonts` saat aplikasi jalan.

### Radius (`FBorderRadius`, Medium)

| Token | px | Dipakai Forui untuk |
| --- | --- | --- |
| `xs2` | 4 | checkbox |
| `xs` | 6 | item kecil di select |
| `sm` | 8 | tooltip, OTP, tombol kecil |
| `md` | 10 | **tombol, text field, select, tabs, item sidebar, dialog, toast, popover** |
| `lg` | 14 | **kartu (`FCard`)** |
| `pill` | 100 | badge, progress |

Konversi dari kanvas Storeku: 16/14 px → 14 (kartu), 12/10 px → 10 (tombol,
input), 8 → 8, 6 → 6, 18/20 → 14 (panel besar), pill tetap.

### Ikon

Tabler Icons (paket `tabler_icons_plus`, outline, stroke 2, 24 px grid;
16–20 px di UI). Kanvas memakai path SVG asli Tabler 3.x agar nama ikon
bisa langsung dicari (`TablerIcons.<nama>`). Peta nama ikon ada di halaman
fondasi "Peta komponen Forui".

### Komponen

Sidebar mengikuti `FSidebar`: latar `background`, garis kanan `border`,
item 14 px dengan ikon 16 px, item aktif berlatar `secondary`. (Storeku
memakai sidebar biru penuh; di Lakuna diganti agar sesuai Forui.) Bagian
lain memetakan komponen Dioxus ke Forui:

| Storeku (Dioxus Components) | Lakuna (Forui) |
| --- | --- |
| Button | `FButton` (`primary`, `secondary`, `outline`, `ghost`, `destructive`; ukuran sentuh 44/48) |
| Toggle Group (tema, periode) | `FTabs` gaya segmen atau `FSelectTileGroup` |
| Badge | `FBadge` |
| Input, Textarea, Label, Form | `FTextField`, `FTextFormField`, `FLabel` |
| Select, Combobox | `FSelect`, `FAutocomplete`, `FMultiSelect` |
| Date Picker, Calendar | `FDateField`, `FCalendar`, `FLineCalendar` |
| Tabs, Accordion, Collapsible | `FTabs`, `FAccordion`, `FCollapsible` |
| Dialog, Alert Dialog, Sheet | `FDialog` (`showFDialog`), `showFSheet` / `showFPersistentSheet` |
| Toast | `showFToast` + `FToaster` |
| Progress, Skeleton | `FDeterminateProgress`, `FProgress`, `FCircularProgress`; skeleton kustom |
| Switch, Checkbox, Radio, Slider | `FSwitch`, `FCheckbox`, `FRadio`, `FSlider` |
| Pagination | `FPagination` |
| Dropdown/Context Menu, Popover, Tooltip | `FPopoverMenu`, `FContextMenu`, `FPopover`, `FTooltip` |
| Avatar, Separator | `FAvatar`, `FDivider` |
| Card, Item | `FCard`, `FItem` / `FTile` / `FTileGroup` |
| Sidebar, Navbar, Menubar | `FSidebar`, `FHeader`, `FBottomNavigationBar`, `FScaffold` |
| Breadcrumb | `FBreadcrumb` |
| PIN pad | `FOtpField` untuk tampilan digit + tombol angka kustom |
| Virtual List | `ListView.builder` / `SliverList` |
| Denah meja (dioxus-flow) | `vyuh_node_flow`: `NodeFlowEditor` (atur denah 1.7d) dan `NodeFlowViewer` (kasir 1.7b) |
| Gambar QRIS statis | `Image` dalam `AspectRatio` rasio asli + `BoxFit.contain` (tidak dipotong) |

### Logo dan placeholder (DiceBear)

- Mark **Etalase** (DiceBear `icons` / `shopWindow`, Bootstrap Icons MIT) di
  kotak radius 22% dengan gradien Sky `#00A6F4` → `#0069A8`, ikon
  `#F0F9FF`. Wordmark "Lakuna" Montserrat 800.
- Foto produk kosong: DiceBear `shapes` (CC0), seed = id/nama produk,
  latar `#F0F9FF`/`#F4F4F5`, bentuk `#0069A8`/`#00A6F4`/`#74D4FF`/`#E4E4E7`.
- Avatar pengguna: DiceBear `initials`, latar `#0069A8`/`#00598A`, teks
  `#F0F9FF`, DM Sans 700.
- Hanya gaya CC0 dan `icons` (MIT). Semua SVG dibuat sekali lalu dibundel.

### Teks yang khusus Storeku

- "arium" → `lakuna_auth` (PIN Argon2id lokal) di Fase 1 dan auth
  Serverpod di Fase 2.
- "dioxus-flow" → `vyuh_node_flow` (lihat bagian Denah meja).
- Halaman "Peta Dioxus Components" → "Peta komponen Forui".

### Denah meja F&B (`vyuh_node_flow` 0.32)

- Gambar denah = node terkunci (`locked: true`) di lapisan
  `NodeRenderLayer.background`, ukuran = ukuran gambar.
- Meja = node tanpa port; meja bulat memakai `CircleShape`. Lebar/tinggi
  diubah lewat resizer; **tidak ada rotasi bebas** (paket tidak mendukung),
  diganti pilihan **Orientasi 0° / 90°** (tukar lebar-tinggi).
- `SnapPlugin` + `GridSnapDelegate` 20 px, `MinimapPlugin`, `LodPlugin`
  untuk denah besar.
- Kasir (1.7b) memakai `NodeFlowViewer` (geser & zoom saja); warna meja
  mengikuti status bill. Tata letak disimpan sebagai JSON per area
  (`dining_areas.layout_json`) atau ke kolom posisi meja; keputusan skema di
  thread pengembang.

### QRIS statis

- Pemilik mengunggah **gambar stiker QRIS utuh** (PNG/JPG/WebP ≤ 5 MB) di
  Pengaturan › Metode pembayaran (1.26b). Aplikasi memeriksa rasio vertikal
  dan, bila bisa, membaca QR secara offline (NMID, nama merchant); bila QR
  tidak terbaca tetap boleh disimpan dengan peringatan.
- Layar bayar (1.6 tablet, 1.6m mobile) menampilkan gambar itu **utuh, rasio
  asli, tidak dipotong**, dengan nominal besar, langkah cek mutasi, tombol
  **Belum masuk** dan **Sudah Terbayar** (izin `payments:confirm`).

## Struktur kanvas

Sama dengan Storeku: halaman Fondasi & komponen, Fase 1, Fase 2, Fase 3,
Contoh mode gelap; nomor layar tetap (1.1 … 1.27, 1.7b–d, 2.1 … 2.6,
3.1 … 3.7) supaya spec Storeku tetap bisa dirujuk. Hasil audit menambah
layar bernomor sisipan (1.2b, 1.3b, 1.4b, 1.5b, 1.5c, 1.6m, 1.7e, 1.11b,
1.15m, 1.16b, 1.17b, 1.19b, 1.20b, 1.26b) dan dua halaman fondasi: "Pola
keadaan & responsif" dan "Peta fitur hasil audit". Halaman "Mode gelap"
berisi 23 layar (8 contoh lama + versi gelap 15 layar hasil audit). Total 85
artboard.

## Cara membuat

Layar dikonversi dengan skrip dari berkas `.dc.html` Storeku (peta warna
terang dan gelap terpisah, font, radius, sidebar `FSidebar`, ikon Tabler,
placeholder DiceBear), lalu halaman fondasi ditulis ulang tangan. Skrip
sekali pakai, tidak disimpan di repo (kanvas adalah sumber kebenaran).

## Pemeriksaan

- Tidak ada lagi warna palet Storeku (`#3368A0`, `#66A3BF`, `#C8DFDB`,
  `#F2EFE7`, dll.) maupun "Plus Jakarta Sans" di berkas kanvas.
- Teks di atas latar lolos kontras 4.5:1 untuk pasangan token utama.
- Setiap layar dirender dan dilihat (tangkapan layar terang dan gelap)
  sebelum kanvas diserahkan.

## Status & gap

| Hal | Status |
| --- | --- |
| Kanvas "Desain UI Lakuna" (85 artboard, 23 layar mode gelap) | terbit 2026-11-03 |
| Kontras: semua teks ≥ 4.5:1, aturan mode gelap | terbit 2026-11-03 |
| Audit fitur + 14 layar detail | terbit 2026-11-03 |
| QRIS stiker vertikal, denah `vyuh_node_flow` | terbit 2026-11-03 |
| Tema Flutter (`FThemeData`) | dikerjakan thread "Bangun aplikasi Lakuna dengan Flutter" |
