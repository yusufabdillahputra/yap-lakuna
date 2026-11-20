# F1-10n · Dialog area, meja, dan rentang meja tidak tertutup tanpa bertanya

- **Fase:** 1
- **Status:** Rilis v0.108.0
- **Layar:** 1.17 Master data › Meja & area: dialog *Area baru / Ubah
  area*, *Meja baru / Ubah meja*, dan *Rentang meja*.
- **Acuan:** gap "Dialog area / meja / rentang meja (tab Meja)" di
  [F1-09b](2026-11-15-f1-09b-dialog-master-data-design.md); aturan dan
  dialog *Buang perubahan?* sama dengan F1-13e dan F1-09b. Storeku tidak
  punya aturan ini.

## Masalah

Ketiga dialog tertutup langsung lewat ketukan di luar dialog, Esc, tombol
kembali sistem, atau **Batal**, dan membuang isian. *Rentang meja* paling
merugikan: awalan, nomor dari–sampai, kursi, dan area sudah diatur untuk
membuat puluhan meja sekaligus. Dialog juga tampil di navigator cabang,
sehingga menu samping masih bisa diketuk.

## Aturan

1. Dialog dianggap **berubah** bila isiannya berbeda dari keadaan saat
   dibuka:
   - area: nama;
   - meja: nama, area, kursi, *Boleh digabung*;
   - rentang meja: awalan, dari, sampai, kursi, area. Nilai bawaan
     (`M`, 1, 12, 4 kursi, tanpa area) bukan perubahan.
   Nama dan awalan dibandingkan setelah spasi di awal/akhir dibuang, sama
   seperti saat disimpan. Angka dibandingkan sebagai angka ("04" = 4).
   Mengetik lalu mengembalikan isian tidak dihitung.
2. Menutup dialog yang berubah lewat ketukan di luar dialog, Esc, tombol
   kembali sistem, atau **Batal** menampilkan **Buang perubahan?** dengan
   isi "Area yang sedang diisi …" / "Meja yang sedang diisi …" / "Rentang
   meja yang sedang diisi … belum disimpan dan akan hilang.", tombol
   **Batal** (kembali) dan **Buang** (tutup). Dialog yang tidak berubah
   tertutup seperti biasa. **Simpan** tidak ditanyakan.
3. Dialog tampil di navigator akar (menutupi menu samping / bawah).
4. Esc bekerja walau tidak ada isian berfokus (lingkup fokus
   `TapOutsideToPop`, F1-09b).

## Rancangan teknis

- `_showDialog` memakai `showFDialog(useRootNavigator: true,
  barrierDismissible: false)` dan membungkus `FDialog` dengan
  `TapOutsideToPop`.
- Setiap `State` dialog menyimpan tanda tangan awal (`late final`, dibaca
  pertama kali saat `build` pertama, jadi berisi keadaan saat dibuka) dan
  membungkus `_frame` dengan `DiscardChangesScope(dirty, busy: false,
  body, dialogKey)`. Simpan memanggil `Navigator.pop(nilai)` sehingga tidak
  ditahan. Dialog tidak menyimpan sendiri (penyimpanan oleh tab setelah
  dialog tertutup), jadi tidak ada keadaan *busy*.
- Isian memanggil `setState` saat berubah agar `PopScope` memakai keadaan
  terbaru (nama area, nama/kursi/area meja, area rentang).
- `_showDialog` juga dipakai dialog konfirmasi hapus area/meja: ketukan di
  luar dan Esc kini lewat `maybePop` (tanpa `PopScope`), hasilnya tetap
  `null` = batal, dan menu samping ikut tertutup.
- Tombol Batal memanggil `Navigator.maybePop` dan diberi kunci
  `dining-setup-area-cancel`, `dining-setup-table-cancel`,
  `dining-setup-range-cancel`.
- Kunci pertanyaan: `dining-area-discard`, `dining-table-discard`,
  `dining-range-discard` (+ `-cancel` / `-confirm`).
- l10n: `diningAreaDiscardBody`, `diningTableDiscardBody`,
  `diningRangeDiscardBody` (ID + EN).

## Pengujian

- `dining_tables_tab_test.dart`:
  - area: dialog baru tanpa perubahan tertutup dengan ketukan di luar;
    nama diketik lalu Esc bertanya, Batal kembali; menu samping tertutup
    dialog dan ikut bertanya; Buang tidak menyimpan; nama dengan spasi tepi
    tidak bertanya;
  - meja: tabel per isian (nama, kursi, area, *Boleh digabung*) lalu Esc
    bertanya dan Buang tidak menyimpan; kursi "04" untuk 4 tidak
    bertanya;
  - rentang: nilai bawaan ditutup Esc langsung; ubah sampai lalu tombol
    Batal bertanya, ketuk di luar bertanya, Buang tidak membuat meja; area
    dihitung; tabel per isian (awalan, dari, sampai, kursi); awalan dengan
    spasi tepi dan "01" tidak bertanya;
  - tombol kembali sistem (`handlePopRoute`) ikut bertanya;
  - konfirmasi hapus: ketuk di luar sama dengan Batal (tidak menghapus).
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Tanya sebelum menutup dialog area, meja, rentang meja | 1.17 | Rilis v0.108.0 | Sama dengan F1-09b. |
| Isian dialog hilang saat simpan ditolak (nama kembar, meja sibuk) | — | Rilis v0.109.0 | [F1-10o](2026-11-15-f1-10o-galat-di-dialog-meja-design.md). |
| Simpan langsung dari dialog *Buang perubahan?* | — | Rilis v0.126.0 | [F1-09c](2026-11-20-f1-09c-simpan-dari-dialog-master-data-design.md). |
