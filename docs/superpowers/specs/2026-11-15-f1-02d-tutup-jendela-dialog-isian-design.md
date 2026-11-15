# F1-02d — Menutup jendela saat dialog berisi isian terbuka

- **Fase:** 1
- **Status:** Rilis v0.116.0
- **Layar:** dialog pelanggan, supplier, grup pelanggan, modifier, jenis
  pengeluaran, area/meja/rentang meja (desktop).
- **Acuan:** gap [F1-02c](2026-11-15-f1-02c-tutup-jendela-tanya-dulu-design.md)
  *Dialog berisi isian saat jendela ditutup*.

## Tujuan

Sejak F1-02c menutup jendela desktop menanyakan halaman yang berubah
(`LeaveGuards`). Dialog form yang memakai `DiscardChangesScope` (F1-13e,
F1-09b, F1-10n) sudah bertanya saat ditutup lewat Batal, Esc, atau ketukan
di luar, tetapi tidak terdaftar di `LeaveGuards`, jadi isian pelanggan baru
atau meja yang sedang diubah hilang tanpa peringatan saat tombol ✕ jendela
ditekan.

## Aturan

1. Saat aplikasi diminta ditutup, setiap dialog `DiscardChangesScope` yang
   terbuka dan berubah bertanya *Buang perubahan?* dengan teks dialog itu
   sendiri, mulai dari dialog teratas, **sebelum** halaman di bawahnya
   (aturan F1-02c).
2. **Batal** di dialog mana pun: aplikasi tidak ditutup, dialog form dan
   isiannya utuh. **Buang** di semua pertanyaan: aplikasi ditutup.
3. Dialog yang sedang menyimpan (`busy`) menolak penutupan **tanpa
   bertanya**: form menutup dirinya dengan `Navigator.pop` setelah simpan,
   yang akan mengenai pertanyaan bila pertanyaan itu terbuka di atasnya
   (pertanyaan hilang, penutupan batal diam-diam, atau galat tipe hasil).
   Simpan lokal cepat; ✕ berikutnya setelah simpan selesai berjalan
   normal.
4. Bila pertanyaan *Buang perubahan?* dialog itu sudah terbuka (dari Esc,
   Batal, atau ketukan di luar), pertanyaan itu dipakai: tidak ada dialog
   kedua, **Buang** menutup dialog form dan melanjutkan penutupan aplikasi.
5. Bila **Buang** dipilih untuk dialog tetapi halaman di bawahnya lalu
   **Batal**, aplikasi tetap terbuka dan dialog form tetap tampil dengan
   isiannya (tidak ada yang hilang). Pengecualian aturan 4: pertanyaan
   yang dibuka lewat Esc/Batal/ketukan di luar menutup dialog form saat
   **Buang**, sesuai permintaan pengguna sebelumnya.
6. Dialog yang sedang ditutup (animasi keluar setelah **Buang** atau
   simpan) tidak ditanya lagi.
7. Dialog tanpa perubahan tidak bertanya. *Ganti kasir* tidak berubah:
   tombolnya tertutup penghalang dialog.

## Rancangan teknis

- `confirm_discard.dart`: `DiscardChangesScope` menjadi `StatefulWidget`.
  Selama terpasang, state-nya ada di daftar statis dialog terbuka (urutan
  dipasang). Pertanyaan disimpan sebagai `Future<bool>` bersama (aturan 4)
  dipakai `PopScope` dan penutupan aplikasi.
- `DiscardChangesScope.canDiscardAll()`: dari yang terakhir dipasang,
  dialog sibuk → `false`; dialog berubah dan tidak sedang ditutup
  (`ModalRoute.animation` bukan `reverse`) → tanya; berhenti pada
  `false`.
- `router.dart`: `ExitGuard(canExit: () async => await
  DiscardChangesScope.canDiscardAll() && await leaveGuards.canLeaveAll())`.
- Daftar statis dipakai karena dialog memakai navigator akar, di luar
  pohon `ExitGuard`/`AppShell`, sehingga tidak bisa dijangkau lewat
  `InheritedWidget`.

## Tes

- Widget `DiscardChangesScope`: tidak berubah → `true` tanpa dialog;
  berubah → dialog, Batal → `false`, Buang → `true` (form tetap ada); dua
  dialog bertumpuk ditanya dari atas, berhenti di Batal; sibuk → `false`
  tanpa dialog; dialog yang sedang ditutup dilewati; pertanyaan Esc
  yang terbuka dipakai ulang (satu dialog) dan Buang menutup dialog form;
  dilepas → tidak ditanya.
- Alur pelanggan: dialog pelanggan berisi nama → `handleRequestAppExit`
  → dialog; Batal → `cancel`, isian utuh; Buang → `exit`.
- Uji manual Xvfb: `WM_DELETE_WINDOW` saat dialog pelanggan berisi isian.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Dialog berisi isian saat jendela ditutup | — | Rilis v0.116.0 | Linux diuji manual (dialog pelanggan). |
| Urutan dialog lalu halaman diuji ujung ke ujung | — | Belum | Belum ada halaman berpenjaga yang membuka dialog `DiscardChangesScope`; urutan diuji di tingkat unit dan router satu baris. |
| Menunggu simpan selesai lalu bertanya | — | Belum | Kini ✕ selama simpan diabaikan; pengguna menekan ✕ lagi. |
