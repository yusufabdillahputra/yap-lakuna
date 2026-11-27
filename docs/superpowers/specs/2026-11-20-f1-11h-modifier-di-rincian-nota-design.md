# F1-11h · Modifier pesanan di rincian nota Riwayat

- **Fase:** 1
- **Status:** Rilis v0.118.0
- **Layar:** 1.14 Riwayat (panel rincian nota).
- **Acuan:** gap *Modifier di rincian nota Riwayat* di
  [F1-11g](2026-11-20-f1-11g-cari-catatan-barang-design.md).

## Masalah

Sejak F1-11f nota bisa dicari lewat nama modifier (*boba*, *extra shot*),
tetapi rincian nota di Riwayat hanya menampilkan nama produk, jumlah ×
harga, dan (sejak F1-11g) catatan. Staf yang membuka hasil pencarian tidak
melihat mengapa nota itu cocok, dan tidak bisa membedakan dua baris *Teh
Botol* dengan modifier berbeda saat meretur.

## Aturan

1. Baris barang bermodifier menampilkan satu baris redup di bawah nama:
   `+ Besar, Boba` (nama modifier dari salinan di nota, urutan tersimpan).
2. Tambahan harga modifier tidak ditulis ulang: harga satuan di baris
   jumlah × harga sudah termasuk tambahan itu (sama dengan layar bayar dan
   split bill). Struk cetak tetap menulis `+ nama +Rp…` per modifier.
3. Porsi split bill menampilkan modifiernya sendiri (modifier disalin ke
   setiap porsi saat dipisah).
4. Daftar modifier panjang dibungkus ke baris berikutnya, tanpa luapan di
   360 px.

## Rancangan teknis

- `history_detail.dart`: `detail.receipt.modifiersOf(item)` (sudah dimuat
  `loadSaleDetail`) → `Text('+ …')` gaya redup di bawah nama barang.
- Tanpa perubahan data, skema, atau l10n (awalan `+` sama dengan struk).
- Review subagent: tanpa Critical/Important. Minor: tes 360 px dengan
  modifier panjang ditambah; tanpa harga tambahan dicatat sebagai aturan 2.

## Tes

- Widget (`history_flow_test.dart`): modifier dan catatan tampil di baris
  barangnya saja; 360 px dengan enam modifier panjang tanpa luapan;
  diverifikasi mutasi. Repositori palsu menerima `modifiers` dan
  pencariannya ikut mencocokkan nama modifier.
- Uji manual Xvfb: cari `boba` → dua nota; rincian menampilkan *+ Reguler,
  Boba* dan *+ Besar, Boba* (dengan *Note: less ice*).

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Modifier di rincian nota Riwayat | — | Rilis v0.118.0 | Diuji manual (Linux). |
| Tambahan harga per modifier di rincian | — | Rilis v0.151.0 | [F1-11l](2026-11-27-f1-11l-harga-modifier-di-rincian-design.md) |
