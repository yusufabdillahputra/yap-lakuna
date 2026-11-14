# F1-04h — Bagi baris berdiskon rupiah per tamu

- **Status:** Rilis v0.65.0
- **Layar:** 1.7c *Split bill* per item (F&B).
- **Acuan:** gap [F1-04g](2026-11-14-f1-04g-diskon-baris-open-bill-design.md)
  *Bagi baris berdiskon rupiah per tamu*; split bill
  [F1-10c](2026-11-03-f1-10-meja-fnb-design.md).

## Tujuan

Sekarang baris bill yang diberi diskon **rupiah** (mis. *Es Teh ×3,
diskon Rp 3.000*) tidak bisa dibagi ke beberapa tamu; kasir harus menghapus
diskon atau mengubahnya ke persen dulu, lalu menghitung ulang sendiri.
Dengan modul ini potongan rupiah dibagi otomatis sebanding jumlah porsi,
seperti diskon persen yang sudah bisa dibagi.

## Aturan

1. **Bagi sebanding:** memindah *q* dari baris berjumlah *Q* dengan
   potongan rupiah *D* memberi porsi yang pindah potongan
   `D × q / Q` dibulatkan setengah ke atas, dan sisa baris menyimpan
   `D − potongan porsi`. Keduanya tetap diskon rupiah (`discount_bp` 0).
   Jumlah potongan dan total bill tidak berubah.
2. **Tidak melebihi baris:** potongan tiap porsi tidak melebihi total
   kotornya; kelebihan karena pembulatan dipindah ke bagian lain (diskon
   100% tetap 100% di semua porsi).
3. **Gabung kembali:** porsi rupiah dari baris asal yang sama digabung bila
   tamu, status dapur, dan tiketnya sama; potongannya dijumlahkan. Batal
   split atau mengurangi tamu mengembalikan potongan asal persis. Porsi
   rupiah tidak digabung dengan porsi persen atau tanpa diskon.
4. Porsi terakhir pindah utuh beserta seluruh potongannya (seperti
   sebelumnya). Diskon persen tidak berubah (F1-04g aturan 7).
5. Struk dan tiket sudah menggabung porsi rupiah dari baris asal yang sama
   (`mergeSplitPortions`), jadi nota akhir menampilkan satu baris dengan
   potongan asal.
6. Diskon porsi yang diubah setelah split (porsi diberi rupiah lain)
   tetap dihormati; saat digabung potongannya dijumlahkan.
7. Pesan *Hapus atau ubah diskon rupiah item ini ke persen sebelum dibagi*
   (`BillItemDiscounted`) tidak dipakai lagi oleh split dan dihapus.

## Komponen

- `lakuna_data/split_bill.dart` `_moveQuantity`: potongan rupiah dibagi
  sebanding; target gabung untuk rupiah = porsi rupiah dari akar yang sama.
- Hapus `BillItemDiscounted` dan kunci l10n `billSplitErrorItemDiscounted`.
- Panduan *Diskon* (id/en).

## Pengujian

- Data: rupiah 5.000 qty 2 → porsi 2.500 + 2.500, batal split → 5.000;
  rupiah 1.000 qty 3 → 333 / 334 / 333, digabung 667, batal → 1.000;
  diskon 100% rupiah tetap habis di semua porsi; total bill tetap; bayar
  bagian tamu memakai potongan porsinya; nota akhir satu baris berpotongan
  asal.
- Uji manual Xvfb: bill dengan diskon rupiah dibagi ke 2 tamu.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Bagi baris berdiskon rupiah per tamu | 1.7c | Rilis v0.65.0 | Sebanding jumlah, dibulatkan setengah ke atas. |
| Atur potongan per porsi secara manual saat membagi | — | Belum | Ubah diskon porsi setelah dibagi bila perlu. |
