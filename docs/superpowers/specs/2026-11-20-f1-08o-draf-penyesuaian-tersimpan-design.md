# F1-08o · Draf penyesuaian stok tersimpan di perangkat

- **Fase:** 1
- **Status:** Rilis v0.130.0
- **Layar:** 1.18 Stok › tab *Penyesuaian* (kartu *Penyesuaian stok baru*),
  pilihan lokasi di kepala layar.
- **Acuan:** gap "Simpan draf penyesuaian untuk dilanjutkan nanti" di
  [F1-08k](2026-11-15-f1-08k-keluar-draf-penyesuaian-design.md). Storeku
  tidak punya draf penyesuaian. Penyempurnaan layar.

## Masalah

Stok opname bisa berlangsung berjam-jam: staf menambahkan puluhan barang ke
draf penyesuaian dan mengisi jumlah fisik sambil menghitung rak. Draf hanya
hidup selama layar Stok terbuka. Pindah menu, mengganti lokasi untuk
mengecek gudang, ganti kasir, atau aplikasi tertutup (baterai habis,
pembaruan) membuang semua hitungan. F1-08k hanya bertanya sebelum draf
dibuang; staf tetap harus memilih antara menyimpan penyesuaian yang belum
selesai atau kehilangan hitungannya.

## Aturan

1. Draf penyesuaian (barang, jumlah fisik, catatan baris, alasan umum, dan
   catatan umum) **tersimpan otomatis di perangkat ini, per lokasi stok**,
   setiap kali berubah. Satu lokasi punya satu draf.
2. Membuka layar Stok atau memilih lokasi memuat draf lokasi itu. Baris
   memakai stok sistem terbaru (selisih dihitung ulang); barang yang tidak
   ada lagi di lokasi itu (dihapus) dibuang dari draf.
3. Karena draf tidak hilang, meninggalkan layar Stok, ganti kasir, dan
   mengganti lokasi **tidak lagi bertanya** *Buang perubahan?*. Draf lokasi
   lama tetap tersimpan dan muncul lagi saat lokasi itu dipilih. Dialog
   F1-08k / F1-08n hanya muncul bila draf terakhir gagal disimpan di
   perangkat. Tulis draf yang masih berjalan ditunggu dulu, paling lama 2
   detik; bila belum selesai juga, dialog muncul. Teks dialog menyebut
   draf *belum tersimpan di perangkat*. *Buang* di dialog itu juga
   menghapus draf lama lokasi itu yang sempat tersimpan.
4. *Simpan penyesuaian* yang berhasil dan *Batal* menghapus draf lokasi
   itu.
5. Selama draf berisi, kartu menampilkan keterangan kecil *Draf tersimpan
   di perangkat ini.* Bila penyimpanan gagal, keterangannya *Draf belum
   tersimpan di perangkat.* (warna galat).
6. Draf milik perangkat, bukan staf: staf lain dengan izin `stock:adjust`
   di perangkat yang sama melanjutkan draf yang sama. Staf tanpa izin itu
   tidak memuat atau menyimpan draf. Draf tidak disinkronkan (Fase 2).
7. Selama lokasi dimuat, isian draf nonaktif dan perubahan diabaikan
   (draf tersimpan lokasi itu belum dibaca). Lokasi tidak bisa diganti
   selama penyesuaian disimpan, agar draf lokasi yang disimpan tetap
   terhapus.
8. Bila draf tersimpan gagal dibaca, perubahan di lokasi itu tidak ditulis
   agar draf lama tidak tertimpa: keterangannya *Draf belum tersimpan di
   perangkat.* dan keluar bertanya. Draf dibaca lagi saat layar dimuat
   ulang, selama belum ada perubahan di layar. JSON draf yang rusak (termasuk
   satu baris dengan jumlah negatif atau tipe salah) dibaca sebagai tanpa
   draf; varian kembar dipakai sekali.
9. Bila hapus draf gagal setelah baris terakhir dibuang, hapusnya dicoba
   lagi saat layar ditinggalkan (tanpa dialog).
10. Stok sistem yang dipakai adalah stok saat penyesuaian disimpan (aturan
   F1-08), bukan saat barang dihitung. Penjualan di antara hitung dan
   simpan ikut mengubah selisih, sama seperti sebelumnya.

## Rancangan teknis

- `StockRepository.adjustmentDraft(locationId)` →
  `Result<StockAdjustmentDraft?>` dan
  `saveAdjustmentDraft(locationId, draft)` (`null` = hapus). Repositori
  lokal menyimpan JSON di `LocalPreferences` (tabel preferensi perangkat,
  tidak disinkronkan) dengan kunci
  `stock.adjustmentDraft.<tenant>.<outlet>.<lokasi>`; JSON rusak dibaca
  sebagai tanpa draf. Keduanya butuh `stock:adjust`.
- `StockAdjustmentDraft` (alasan, catatan, baris: varian, fisik
  mili-satuan atau kosong, catatan) dengan `toJson` / `fromJson`.
- `StockViewModel`: setiap perubahan draf menaikkan `_draftChange` dan
  menulis draf (berantai agar urutan tulis terjaga); `_draftStored`
  mencatat perubahan terakhir yang berhasil ditulis.
  `hasUnsavedChanges` = draf berisi dan belum tersimpan. `_loadOnce`
  memulihkan draf lokasi target sekali per pemilihan lokasi.
- `LocalStockRepository` mendapat `preferences`.

## Pengujian

- `local_stock_repository_test.dart`: simpan, baca, hapus draf per lokasi;
  JSON rusak; staf tanpa `stock:adjust` ditolak.
- `stock_view_model_test.dart`: draf ditulis setiap berubah, dipulihkan
  saat muat dan saat lokasi diganti (lokasi lain punya draf sendiri),
  barang yang hilang dibuang, simpan dan batal menghapus draf,
  `hasUnsavedChanges` palsu setelah tersimpan dan benar bila tulis gagal,
  staf tanpa izin tidak membaca draf.
- `stock_flow_test.dart`: keluar menu dan ganti lokasi tanpa dialog;
  draf muncul lagi setelah kembali; keterangan tersimpan / gagal; *Buang*
  saat tulis gagal menghapus draf lama; keluar saat tulis berjalan menunggu,
  tulis macet memunculkan dialog setelah 2 detik. Tes F1-08k / F1-08n
  memakai repositori yang gagal menulis draf.
- Uji manual Xvfb: isi draf, tutup aplikasi, buka lagi → draf kembali.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Draf penyesuaian tersimpan di perangkat | 1.18 | Rilis v0.130.0 | Per lokasi, otomatis; tanpa dialog keluar. |
| Draf penyesuaian lintas perangkat | — | Belum | Fase 2 (sinkronisasi); kini per perangkat. |
