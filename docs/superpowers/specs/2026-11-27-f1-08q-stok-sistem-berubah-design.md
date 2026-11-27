# F1-08q — Peringatan stok sistem berubah sejak dihitung

- **Fase:** 1
- **Status:** Rilis v0.143.0
- **Layar:** 1.18 Stok › tab *Penyesuaian* (kartu *Penyesuaian stok baru*).
- **Acuan:** baris *Peringatan stok berubah saat mengisi* (Kasus tepi,
  `Belum`) di spec F1-08. Gap 7 di `docs/superpowers/GAP-FASE1.md`.
  Storeku tidak mengaturnya; aturan di bawah diputuskan di sini.

## Masalah

Sejak F1-08o (v0.130.0) draf penyesuaian tersimpan di perangkat dan bisa
dilanjutkan berjam-jam atau berhari-hari kemudian. Selisih selalu dihitung
dari stok sistem terbaru (aturan F1-08o nomor 10). Bila ada penjualan,
pembelian, atau retur di antara hitung dan simpan, selisihnya berubah tanpa
tanda apa pun, padahal jumlah fisik yang diketik mungkin sudah tidak cocok
lagi dengan rak (barang terjual setelah dihitung). Di Fase 2 sinkronisasi
membuat ini lebih sering.

## Aturan

1. Saat jumlah fisik sebuah baris diisi atau diubah, stok sistem saat itu
   dicatat sebagai **stok saat dihitung** baris itu, ikut tersimpan di
   draf perangkat. Mengosongkan jumlah fisik menghapusnya.
2. Bila stok sistem terbaru (dimuat ulang saat layar dibuka, lokasi
   dipilih, atau setelah simpan) berbeda dengan stok saat dihitung, baris
   itu menampilkan peringatan kecil berwarna peringatan:
   *Stok sistem berubah dari {lama} jadi {baru} sejak dihitung. Selisih
   memakai stok terbaru; hitung ulang bila perlu.*
   dan tombol kecil **Sudah dicek**, yang menjadikan stok terbaru sebagai
   stok saat dihitung (peringatan hilang).
3. Mengubah jumlah fisik ke angka lain juga mencatat stok terbaru (dianggap
   dihitung ulang). Mengetik angka yang sama tidak menghapus peringatan,
   karena Forui memanggil `onChange` saat field mendapat fokus.
4. Di atas tombol *Simpan penyesuaian* muncul ringkasan
   *{n} barang: stok sistem berubah sejak dihitung.* selama masih ada baris
   berperingatan. Peringatan **tidak** memblokir simpan: selisih tetap
   memakai stok sistem saat disimpan (aturan F1-08).
5. Draf lama (sebelum v0.143.0) tidak punya stok saat dihitung; barisnya
   tidak berperingatan sampai jumlah fisiknya diubah atau *Sudah dicek*.

## Rancangan teknis

- `StockAdjustmentDraftLine` menjadi kelas (bukan record) dengan
  `countedSystem` (`Qty?`, JSON `countedSystem` mili-satuan, opsional;
  bukan bilangan bulat ≥ 0 → `null`).
- `AdjustmentDraftLine.countedSystem` dan `systemChanged`;
  `StockViewModel.setPhysical` mencatatnya bila angka berubah,
  `acknowledgeSystemChange(variantId)`, `systemChangedCount`.
- View: `_SystemChangedNote` di baris tabel dan kartu ponsel (kunci
  `stock-system-changed-<id>`, tombol `stock-system-ok-<id>`), ringkasan
  `stock-system-changed-summary`.
- Baris tabel selalu `Column` (catatan disisipkan dengan `if`) agar kolom
  fisik dan catatan tidak dibangun ulang saat peringatan muncul atau
  hilang; bila tidak, fokus dan ketikan berikutnya hilang (temuan review).
- `_updateLine` tidak menulis ulang draf bila baris tidak berubah
  (`onChange` Forui saat fokus).
- Batasan yang diterima: stok saat dihitung adalah stok dari muatan
  terakhir layar, bukan stok tepat saat mengetik. Penjualan di antara
  muatan dan ketikan baru tampil sebagai peringatan setelah muat ulang.
  Mengosongkan lalu mengetik ulang angka yang sama juga mencatat ulang
  stok (kosong → angka dihitung sebagai angka baru).

## Pengujian

- Draf: JSON bolak-balik dengan `countedSystem`; JSON lama tanpa field itu
  dan nilai negatif/bukan angka dibaca `null`.
- VM: isi fisik mencatat stok; stok berubah lalu dimuat ulang →
  `systemChanged`, ringkasan 1; *Sudah dicek* dan angka baru
  menghapusnya; angka sama tidak; kosongkan fisik menghapusnya; draf
  dipulihkan membawa stok saat dihitung.
- Widget: peringatan dan ringkasan tampil, *Sudah dicek* menghilangkannya.
- Widget (tabel dan ponsel): mengetik angka baru di baris berperingatan
  tetap memakai `EditableTextState` yang sama dan fokus tidak hilang;
  ketikan berikutnya tersimpan.

## Status & gap

| Bagian | Status | Catatan |
| --- | --- | --- |
| Peringatan stok sistem berubah sejak dihitung | Rilis v0.143.0 | Per baris + ringkasan; tidak memblokir simpan. |
