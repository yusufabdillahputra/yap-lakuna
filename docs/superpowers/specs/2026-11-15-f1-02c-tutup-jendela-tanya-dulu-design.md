# F1-02c — Menutup jendela aplikasi bertanya dulu

- **Fase:** 1
- **Status:** Rilis v0.115.0
- **Layar:** semua layar desktop (Windows, Linux, macOS) setelah masuk.
- **Acuan:** gap [F1-02b](2026-11-15-f1-02b-ganti-kasir-tanya-dulu-design.md)
  *Tutup aplikasi (jendela desktop) bertanya*.

## Tujuan

Pindah menu (F1-12f, F1-07q, F1-15c, F1-08k) dan *Ganti kasir* (F1-02b)
sudah bertanya sebelum membuang isian yang belum disimpan. Menutup jendela
aplikasi di desktop (tombol ✕, Alt+F4, Cmd+Q) masih langsung keluar, jadi
form pembelian setengah jadi, produk baru, pengeluaran, atau draf
penyesuaian stok hilang tanpa peringatan.

## Aturan

1. Saat sistem operasi meminta aplikasi ditutup, setiap halaman yang
   terdaftar di `LeaveGuards` dan sedang berubah bertanya *Buang
   perubahan?* (dialog yang sama dengan pindah menu), urutan dari halaman
   teratas.
2. **Batal** di dialog mana pun: aplikasi tidak ditutup, isian utuh.
   **Buang** di semua dialog (atau tidak ada yang berubah): aplikasi
   ditutup seperti biasa.
3. Permintaan tutup kedua selama dialog masih terbuka diabaikan (tidak
   membuka dialog kedua, tidak menutup aplikasi). Pengecualian macOS: Cmd+Q
   **kedua** setelah Cmd+Q pertama langsung keluar (perilaku embedder
   Flutter, lihat gap); tombol ✕ kedua tetap diabaikan.
4. Berlaku setelah masuk (layar berbingkai menu). Layar masuk / PIN tidak
   punya isian yang perlu dijaga.
5. Ponsel dan tablet tidak berubah: sistem operasinya tidak meminta izin
   sebelum menutup aplikasi.
6. Bila dialog *Buang perubahan?* sudah terbuka (dari pindah menu atau
   *Ganti kasir*) saat jendela ditutup, dialog itu dipakai: **Buang** juga
   menutup aplikasi, karena pengguna memang meminta tutup.
7. Galat saat memeriksa halaman dilaporkan lalu aplikasi tetap ditutup,
   agar jendela tidak terkunci oleh penjaga yang rusak.

## Rancangan teknis

- `lib/ui/core/exit_guard.dart`: `ExitGuard(canExit, child)` memasang
  `AppLifecycleListener(onExitRequested:)` → `AppExitResponse.exit` bila
  `canExit()` benar, selain itu `cancel`; permintaan saat pemeriksaan
  berjalan → `cancel`. Galat `canExit` tidak ditangkap: binding Flutter
  melaporkannya dan tidak menganggapnya `cancel` (aturan 7).
- `router.dart`: bingkai `AppShell` dibungkus `ExitGuard(canExit:
  leaveGuards.canLeaveAll)`. Kunci halaman `ShellRoute` tetap, jadi state
  `ExitGuard` bertahan selama navigasi dan listener terpasang sekali.
- Linux dan Windows: embedder Flutter sudah meneruskan `delete-event` /
  `WM_CLOSE` ke `System.requestAppExit` (runner Windows memakai
  `HandleTopLevelWindowProc`). Windows hanya menahan bila jendela itu
  jendela terakhir proses (lihat gap).
- macOS: tanpa perubahan, tombol ✕ menutup jendela, lalu aplikasi keluar
  karena `applicationShouldTerminateAfterLastWindowClosed`; dialog akan
  muncul di jendela yang sudah tertutup. Embedder juga menandai
  `shouldTerminate` sejak permintaan pertama, sehingga permintaan kedua
  selama dialog terbuka langsung keluar. Karena itu
  `MainFlutterWindow.performClose` bertanya ke Dart lewat kanal
  `lakuna/window` (`requestClose` → `bool`) selagi jendela tampil:
  `false` (batal atau dialog masih terbuka) → jendela tetap; selain itu
  (diizinkan, `ExitGuard` belum terpasang di layar masuk, galat) →
  `NSApp.terminate`. Izin dari kanal dipakai sekali oleh `onExitRequested`
  berikutnya agar tidak bertanya dua kali.

## Tes

- Widget `ExitGuard`: boleh → `exit`; tidak boleh → `cancel`; permintaan
  kedua selama pemeriksaan → `cancel` tanpa memanggil `canExit` lagi;
  dilepas → tidak menahan.
- Kanal `lakuna/window`: diizinkan → `true` lalu permintaan keluar
  berikutnya `exit` tanpa bertanya (sekali saja); ditolak → `false`; klik
  kedua dan Cmd+Q selama dialog → `false` / `cancel`; dilepas → tanpa
  penangan.
- Alur pembelian (desktop): form berubah → permintaan tutup → dialog
  *Buang perubahan?*; Batal → `cancel`, form utuh; Buang → `exit`. Form
  tanpa perubahan → `exit` tanpa dialog.
- Uji manual Xvfb: `WM_DELETE_WINDOW` ke jendela Linux saat form pembelian
  berubah → dialog; tutup kedua diabaikan; Batal → form utuh; Buang →
  aplikasi keluar; tanpa perubahan → langsung keluar.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Tutup jendela desktop bertanya | — | Rilis v0.115.0 | Linux diuji manual; Windows/macOS hanya lewat build CI. |
| Cmd+Q kedua selama dialog (macOS) | — | Belum | Embedder langsung keluar karena `shouldTerminate` sudah ditandai; butuh penanganan `applicationShouldTerminate` sendiri. |
| Windows dengan jendela kedua (mis. dialog cetak plugin) | — | Belum | Engine Windows hanya menahan `WM_CLOSE` jendela terakhir proses. |
| Dialog berisi isian (pelanggan, supplier, master data, meja) saat jendela ditutup | — | Rilis v0.116.0 | [F1-02d](2026-11-15-f1-02d-tutup-jendela-dialog-isian-design.md). |
