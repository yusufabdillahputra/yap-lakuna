# F1-06 · Struk & printer

- **Fase:** 1
- **Status:** Berjalan (v0.8.0)
- **Layar desain:** 1.5c / 1.12 *Pembayaran berhasil · struk* (desktop dan
  mobile), 1.26 *Pengaturan › Struk & printer*. Kanvas
  [Desain UI Lakuna](https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525)
- **Acuan Storeku:** `docs/superpowers/specs/2026-11-02-f1-06-struk-design.md`

## Tujuan

Setiap nota bisa dicetak ke printer thermal 58/80 mm atau dibagikan sebagai
PDF, dengan header dan footer toko. Layar, kertas, dan PDF memakai baris
struk yang sama sehingga yang terlihat di layar sama dengan yang tercetak.

## Lingkup v0.8.0

Termasuk:

- **Mesin tata letak struk** di `lakuna_domain` (Dart murni): baris teks
  monospace 32 kolom (58 mm) atau 48 kolom (80 mm), rata kiri/tengah/kanan,
  tebal, garis pemisah, bungkus kata, pasangan label–nilai.
- **Encoder ESC/POS** di `lakuna_domain`: inisialisasi, rata, tebal, teks
  ASCII, umpan kertas, potong. Diuji dengan tes golden (byte persis).
- **Pengaturan struk per cabang** (tabel `settings`, kunci
  `receipt.settings`): lebar kertas, header (maks 4 baris), footer (maks 4
  baris), cetak otomatis setelah bayar.
- **Printer per perangkat** (preferensi lokal, tidak disinkronkan):
  - **Bluetooth** (Android): pilih dari perangkat yang sudah dipasangkan
    (*Cari printer*), kirim byte ESC/POS lewat Bluetooth klasik (SPP),
    paket `print_bluetooth_thermal`.
  - **Jaringan (LAN)**: alamat IP/host + port (bawaan 9100), byte ESC/POS
    lewat soket TCP. Jalan di semua platform.
  - **Dialog cetak sistem**: PDF struk ke dialog cetak OS (paket
    `printing`), untuk printer USB/driver di desktop.
- **Tes cetak** dari Pengaturan: struk contoh ke printer terpilih.
- **Layar sukses (1.12)**: status printer ("Terhubung · RPP02N · Bluetooth
  · 58 mm" atau "Belum ada printer"), *Cetak struk*, *Bagikan PDF*,
  *Transaksi baru*, pratinjau struk dari baris yang sama. Cetak otomatis
  bila diaktifkan dan printer langsung (Bluetooth/LAN) terpilih.
- **Bagikan PDF**: Android/iOS memakai share sheet sistem; desktop
  menyimpan ke folder Dokumen (`Dokumen/Lakuna/Struk/<nota>.pdf`) lalu
  menampilkan lokasinya.
- Font struk **DM Mono** dibundel (OFL), dipakai di pratinjau dan PDF.

Tidak termasuk (gap): logo raster, Bluetooth di iOS/macOS/Windows (BLE),
USB langsung tanpa driver, cetak ulang dari riwayat (F1-11), cetak rekap
sesi (F1-03), struk WhatsApp (F3-03).

## Desain UI

- **1.12 / 1.5c**: kolom kiri (desktop) atau atas (mobile) = ringkasan
  pembayaran berhasil + kartu printer + tombol; kanan/bawah = kertas
  struk putih. Kartu printer: ikon printer, "Terhubung" + "RPP02N ·
  Bluetooth · 58 mm"; tanpa printer: "Belum ada printer · atur di
  Pengaturan › Struk & printer". Tombol *Cetak struk* (primer bila printer
  langsung), *Bagikan PDF* (outline). Catatan kecil di bawah: "Cetak
  otomatis setelah bayar bisa diaktifkan di Pengaturan › Struk & printer."
- **Kertas struk**: nama toko (tebal, tengah), cabang, baris header
  (tengah), garis, No / Tgl / Kasir, garis, barang (nama; baris kedua
  "  2 x 70.000" kiri, jumlah kanan), garis, TOTAL (tebal), setiap metode
  bayar, Kembali (bila ada tunai), garis, footer (tengah).
- **1.26 Struk & printer** (bagian Pengaturan, izin `settings:manage`):
  - Kartu *Printer perangkat ini*: status, pilihan jenis (Bluetooth hanya
    di Android, Jaringan, Dialog cetak sistem), untuk Bluetooth daftar
    printer terpasang + *Cari printer*, untuk Jaringan isian alamat + port,
    tombol *Tes cetak*. Pilihan langsung tersimpan di perangkat.
  - Kartu *Struk cabang ini*: lebar kertas (58 mm / 80 mm), *Header
    struk*, *Footer struk* (teks multi-baris), saklar *Cetak otomatis
    setelah bayar*, tombol *Simpan* / *Batal*. Pratinjau struk contoh di
    samping (desktop) atau di bawah (mobile), ikut berubah saat mengetik.

## Aturan bisnis

- Kolom: 58 mm = 32, 80 mm = 48. Semua baris ≤ kolom; teks lebih panjang
  dibungkus per kata (kata lebih panjang dari kolom dipotong paksa).
- Pasangan label–nilai: label kiri, nilai kanan, minimal satu spasi. Bila
  tidak muat, label di baris sendiri dan nilai rata kanan di baris
  berikutnya.
- Barang: nama (dibungkus), lalu baris rincian "  <qty> [satuan] x
  <harga>" dengan jumlah baris rata kanan (aturan pasangan).
- Nominal di struk tanpa "Rp", pemisah ribuan sesuai bahasa (id: titik,
  en: koma). Tanggal `dd/MM/yy HH.mm` waktu cabang.
- Header bawaan (belum pernah disimpan) = alamat dan telepon cabang bila
  ada; footer bawaan = "Terima kasih, sampai jumpa lagi!" sesuai bahasa.
  Header/footer maks 4 baris, tiap baris maks 48 karakter (lebih dari
  itu ditolak saat simpan).
- ESC/POS: teks dikirim sebagai ASCII; huruf beraksen diganti huruf
  dasarnya, karakter lain di luar ASCII cetak diganti `?`, kecuali `×` →
  `x`, `·` → `-`, `–`/`—` → `-`, kutip miring → kutip lurus.
- Urutan byte: `ESC @`, per baris `ESC a n` (0 kiri, 1 tengah, 2 kanan),
  `ESC E n` (tebal), teks, `LF`; akhir `ESC d 3` lalu `GS V 66 0` (potong
  sebagian setelah umpan).
- Gagal cetak (printer mati, soket timeout 5 detik, Bluetooth tidak
  terhubung) tidak membatalkan nota: tampil pesan galat dengan tombol
  *Coba lagi*.
- Cetak otomatis hanya untuk printer langsung (Bluetooth/LAN), sekali per
  nota, segera setelah nota tersimpan.

## Data

- `settings` (scope `outlet:<id>`, key `receipt.settings`, JSON):
  `{paper: "mm58"|"mm80", header: String?, footer: String?, autoPrint:
  bool}`. `null` = pakai bawaan. Tulis lewat `store.write` (outbox).
- Preferensi lokal `printer.selected` (tabel `local_preferences`, tidak
  disinkronkan): `{kind: "bluetooth"|"network"|"system", name, address}`
  (`address` = MAC Bluetooth atau `host:port`).
- `outlets.address`, `outlets.phone` dibaca untuk header bawaan.

## Izin

- Cetak dan bagikan struk: staf yang membuat nota (`sales:create`).
- Pengaturan struk dan printer: `settings:manage` (UI dan repositori).
  Pengaturan struk cabang dibaca kasir tanpa izin itu.

## Pengujian

- Domain: `receipt_test.dart` (lebar 32/48, bungkus kata, pasangan yang
  tidak muat, rata, garis), `escpos_test.dart` (byte golden, ASCII
  pengganti, potong).
- Data: `receipt_settings_test.dart` (bawaan dari alamat cabang, simpan
  dan muat, validasi baris, outbox, cabang lain).
- Aplikasi: pembangun isi struk dari `CheckoutResult` (barang, split,
  kembalian), view model printer (pilih, tes cetak, galat), layar sukses
  (cetak, bagikan, cetak otomatis sekali), bagian pengaturan, printer
  jaringan nyata lewat `ServerSocket` lokal di tes.
- Manual (Xvfb): printer LAN tiruan (`nc -l 9100`) lalu byte diperiksa,
  PDF bagikan di desktop, pratinjau 58/80 mm, mobile.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Struk layar, ESC/POS, PDF, header/footer, lebar kertas | 1.12, 1.26 | Berjalan v0.8.0 | - |
| Bluetooth Android | *Cari printer* | Berjalan v0.8.0 (belum diuji di perangkat fisik) | Uji dengan printer RPP02N/sejenis |
| Bluetooth iOS/macOS/Windows (BLE) | - | Belum | Bila ada permintaan; paket sudah mendukung BLE |
| Logo di struk | *Tampilkan logo* | Belum | Raster `GS v 0` dari logo toko (bersama Profil toko) |
| Cetak ulang dari riwayat | 1.14 | Belum | Bersama F1-11, label CETAK ULANG |
| Cetak rekap sesi | 1.3 | Belum | Mesin baris yang sama (F1-03) |
| USB langsung tanpa driver | - | Lewat dialog cetak sistem | Bila ada permintaan |
