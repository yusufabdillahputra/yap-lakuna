# F1-10q · Simpan yang ditolak memindahkan kursor ke isian yang salah

- **Fase:** 1
- **Status:** Rilis v0.120.0
- **Layar:** 1.17 Master data › Meja & area: dialog *Area*, *Meja*,
  *Rentang meja*.
- **Acuan:** gap "Fokus otomatis ke isian yang salah" di
  [F1-10p](2026-11-15-f1-10p-galat-per-isian-meja-design.md).

## Masalah

Sejak F1-10p, galat simpan tampil di bawah isian yang salah, tetapi
kursor tetap di tempatnya. Kasir yang mengetik kursi lalu menekan Enter
dan mendapat "Nama sudah dipakai." harus mengetuk kolom **Nama** dulu
sebelum bisa memperbaikinya. Di ponsel, papan ketik bahkan bisa tertutup
sehingga pesan di bawah isian lain tidak terlihat.

## Aturan

1. Saat **Simpan** ditolak (tombol, atau Enter di isian terakhir dialog
   Area dan Meja; dialog rentang tetap tanpa Enter), kursor pindah ke isian
   pertama yang salah, urut dari atas ke bawah. Isian yang sudah berkursor
   tetap berkursor.
2. **Area:** nama kosong atau galat nama dari penyimpanan → **Nama**.
3. **Meja:** nama kosong atau galat nama dari penyimpanan → **Nama**;
   bila nama benar, kursi di luar 1–99 atau galat kursi dari penyimpanan →
   **Kursi**.
4. **Rentang meja:** nomor tidak sah (pratinjau merah "Rentang tidak
   sah") → **Dari** bila nomor awal kurang dari 1, selain itu **Sampai**
   (sampai lebih kecil dari dari, atau rentang lebih dari batas); galat nama
   dari penyimpanan (mis. "Nama M1 sudah dipakai.") → **Dari**, karena nama
   dibentuk dari nomor; bila rentang benar, kursi salah → **Kursi**.
5. Galat dari penyimpanan berlaku untuk isian yang dikirim: isian yang
   diubah selama simpan berjalan tidak membelokkan kursor (mis. Dari diubah
   ke 0 lalu penyimpanan menolak kursi → kursor ke **Kursi**).
6. **Rentang meja:** baris pratinjau nama (yang juga memuat galat nomor
   dan nama kembar) dipindah tepat di bawah baris **Dari–Sampai**, di atas
   **Kursi**, supaya pesannya ikut terlihat saat Dari/Sampai menerima kursor
   dan papan ketik ponsel terbuka. Penyempurnaan layar 1.17.
7. Galat yang tidak terpetakan ke isian (kotak merah di atas tombol: area
   tidak ditemukan, galat tak terduga) tidak memindahkan kursor.
8. Saat isian mendapat kursor, perilaku bawaan platform berlaku: di
   desktop seluruh teks terpilih sehingga bisa langsung diketik ulang; di
   ponsel kursor di akhir teks dan papan ketik muncul.

## Rancangan teknis

- Setiap dialog memegang `FocusNode` untuk isian yang bisa salah
  (`_nameFocus`, `_seatsFocus`, `_fromFocus`, `_toFocus`) dan
  membuangnya di `dispose`.
- Mixin `_DialogSaving` mendapat `void focusInvalid()` (kosong secara
  bawaan) yang dipanggil `runSave` setelah galat simpan diset; dialog
  memanggilnya juga saat validasi lokal menolak simpan. Bila ada
  `saveFailure`, `focusInvalid` hanya memetakan galat penyimpanan; bila
  tidak, galat isian lokal, dengan urutan aturan di atas.
- `FTextField(focusNode:)` dari Forui; tanpa kunci l10n baru.

## Pengujian

- Widget (`dining_tables_tab_test.dart`, grup F1-10q): area kosong dan
  kembar → Nama; meja kembar saat kursor di Kursi → Nama; kursi 0 saat
  kursor di Nama → Kursi; galat kursi dari penyimpanan → Kursi; nama
  kosong dan kursi 0 → Nama; rentang dari 0 → Dari; sampai < dari →
  Sampai; rentang kembar → Dari; kursi rentang 0 → Kursi; galat tak
  terduga tidak memindahkan kursor; Enter pada nama area kembar; rentang
  lebih dari 50 → Sampai; galat rentang dari penyimpanan tidak
  memindahkan kursor; isian diubah selama simpan; pratinjau di bawah
  Dari–Sampai.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Kursor pindah ke isian yang salah (Area, Meja, Rentang) | 1.17 | Rilis v0.120.0 | `_DialogSaving.focusInvalid`. |
