# F1-11l — Tambahan harga per modifier di rincian nota Riwayat

Tanggal: 2026-11-27 · Modul: F1-11 Riwayat (1.14, panel rincian nota) ·
Gap 15 di `docs/superpowers/GAP-FASE1.md`, gap 94 di STATUS-JEDA ·
Rilis: v0.151.0

## Masalah

F1-11h menulis modifier di bawah nama barang (`+ Extra Shot, Boba`) tanpa
tambahan harganya, karena harga satuan sudah termasuk tambahan itu. Saat
pelanggan bertanya "kenapa kopinya Rp 28.000?", kasir harus mencetak ulang
struk atau mengingat harga opsi di master modifier, yang mungkin sudah
berubah sejak transaksi.

## Aturan

1. Setiap modifier dengan tambahan harga ditulis bersama tambahannya:
   `+ Extra Shot +Rp 5.000, Boba +Rp 4.000`. Angkanya sama dengan struk
   cetak; formatnya mengikuti sheet modifier dan master (`+Rp`), karena
   struk menulis satu modifier per baris tanpa `Rp`.
   - Nama dan tambahannya disambung spasi tak putus agar `+Rp 5.000` tidak
     terpisah dari namanya saat dibungkus.
   - Modifier tanpa tambahan (Rp 0) ditulis namanya saja: `+ Reguler`.
   - Tambahan negatif (potongan) ditulis dengan tanda minus:
     `Tanpa Gula -Rp 1.000`.
   - Harga diambil dari salinan di nota (`sale_item_modifiers.price_delta`),
     jadi perubahan harga opsi di master tidak mengubah nota lama.
2. Baris jumlah × harga tetap memakai harga satuan termasuk modifier, jadi
   jumlah baris tidak berubah.
3. Aturan F1-11h lain tetap: urutan tersimpan, porsi split menampilkan
   modifiernya sendiri, daftar panjang dibungkus tanpa luapan di 360 px.

## Rancangan teknis

- `history_detail.dart`: teks modifier memakai `modifierDeltaLabel`
  (format yang sama dengan sheet modifier dan master) per modifier.
- Tanpa perubahan data, skema, atau l10n.
- Palsu `FakeHistoryRepository.addSale` menerima `modifierDeltas`
  (nama → rupiah) untuk tes.

## Pengujian

- Widget: `+ Extra Shot +Rp 5.000, Boba +Rp 4.000, Reguler` (Reguler
  Rp 0), potongan negatif, jumlah × harga termasuk modifier, dan 360 px
  tanpa luapan.
- Uji manual Xvfb: rincian nota bermodifier di Riwayat.

## Status & gap

| Topik | Kode | Catatan |
| --- | --- | --- |
| Tambahan harga per modifier di rincian | Rilis v0.151.0 | Angka sama dengan struk cetak, format seperti sheet modifier. |
