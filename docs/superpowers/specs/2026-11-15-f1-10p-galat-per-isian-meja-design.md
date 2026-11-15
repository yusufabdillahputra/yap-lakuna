# F1-10p · Galat simpan area / meja / rentang tampil di isiannya

- **Fase:** 1
- **Status:** Rilis v0.111.0
- **Layar:** 1.17 Master data › Meja & area: dialog *Area*, *Meja*,
  *Rentang meja*.
- **Acuan:** gap "Galat per isian" di
  [F1-10o](2026-11-15-f1-10o-galat-di-dialog-meja-design.md). Galat isian
  kosong / kursi di luar batas sudah tampil di bawah isiannya sejak F1-10;
  galat dari penyimpanan (nama kembar dsb.) tampil di kotak merah di atas
  tombol.

## Masalah

Sejak F1-10o, nama area atau meja yang kembar ("Nama sudah dipakai.")
tampil di kotak merah di atas tombol, jauh dari kolom **Nama** yang harus
diubah. Galat kosong untuk kolom yang sama tampil tepat di bawah kolomnya,
jadi dua galat nama tampil di dua tempat berbeda.

## Aturan

1. **Area:** galat nama dari penyimpanan (kembar, terlalu panjang, kosong)
   tampil di bawah kolom **Nama**, seperti galat nama kosong.
2. **Meja:** galat nama tampil di bawah **Nama**; galat kursi dari
   penyimpanan tampil di bawah **Kursi**.
3. **Rentang meja:** galat nama (mis. "Nama M7 sudah dipakai.") tampil di
   baris pratinjau nama, berwarna merah, menggantikan pratinjau, karena
   nama dibentuk dari awalan dan nomor. Galat kursi tampil di bawah
   **Kursi**.
4. Galat lain (area tidak ditemukan, rentang tidak sah dari penyimpanan,
   galat tak terduga "Aksi gagal. Coba lagi.") tetap di kotak merah di atas
   tombol.
5. Seperti F1-10o, galat simpan hilang saat isian mana pun diubah; isian
   tetap utuh dan dialog tetap terbuka. Galat isian sebelum simpan (nama
   kosong, kursi di luar batas) dihitung ulang setiap kali **Simpan**
   ditekan, jadi pesan kosong yang lama tidak menutupi galat simpan.

## Rancangan teknis

- Mixin `_DialogSaving` menyimpan `saveFailure` (galat asli) bersama
  `saveError` (pesan). `errorIf(test)` memberi pesan bila galat cocok;
  setiap dialog memetakan galat ke isiannya dan hanya galat yang tidak
  terpetakan masuk `_frame(error:)`.
- Tanpa kunci l10n baru.

## Pengujian

- Widget: area kembar → pesan di bawah Nama, tanpa kotak merah; meja
  kembar → di bawah Nama; galat kursi dari repo → di bawah Kursi; rentang
  kembar → di pratinjau; galat tak terduga tetap di kotak merah; mengubah
  isian menghapus pesan.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Galat simpan di isiannya (Nama, Kursi, pratinjau rentang) | 1.17 | Rilis v0.111.0 | `_DialogSaving.errorIf`. |
| Fokus otomatis ke isian yang salah | — | Belum | Kursor tetap di tempatnya; pesan merah di bawah isian. |
