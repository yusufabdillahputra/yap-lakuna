# F1-12k · Kursor ke isian salah setelah simpan pembelian gagal

- **Fase:** 1
- **Status:** Rilis v0.128.0
- **Layar:** 1.19 Pembelian: form samping (layar lebar), halaman form
  draf / pembelian baru (ponsel dan dari Stok).
- **Acuan:** gap "Fokus keyboard ke isian salah" di
  [F1-12j](2026-11-20-f1-12j-gulir-ke-galat-pembelian-design.md); pola
  dialog meja [F1-10q](2026-11-20-f1-10q-fokus-isian-salah-design.md).

## Masalah

F1-12j menggulir form ke galat paling atas, tetapi kursor tetap di tempat
lain (mis. kotak pindai barcode atau tombol). Staf yang memakai papan ketik
harus mengklik isian yang salah dulu sebelum bisa memperbaikinya.

## Aturan

1. Setelah simpan pembelian gagal (*Simpan draf*, *Terima barang*, atau
   *Simpan draf* dari dialog *Buang perubahan?*), kursor pindah ke galat
   yang sama dengan sasaran gulir F1-12j (paling atas, lalu paling kiri),
   bila galat itu isian teks: nomor faktur, jumlah, harga, diskon, ongkir,
   dibayar, catatan, atau nama supplier dalam mode *Supplier baru*.
2. Bila galat paling atas bukan isian teks (pilihan supplier, jatuh tempo,
   sumber dana, daftar barang kosong, kotak galat simpan), kursor tidak
   pindah.
   Kursor tidak dilompatkan ke isian teks di bawahnya, karena papan ketik
   ponsel akan menggulir layar menjauhi galat paling atas.
3. Kursor dipindah setelah gulir selesai, sehingga posisi gulir F1-12j
   (10% dari tepi atas, atau tidak bergeser bila sudah terlihat) tetap
   berlaku. Pengecualian bawaan platform: isian yang menempel di tepi
   bawah area gulir bisa bergeser beberapa piksel agar caret tidak
   menempel tepi (`scrollPadding` 20 px).
4. Isian yang sudah berkursor tetap berkursor. Perilaku bawaan platform
   berlaku (desktop: teks terpilih; ponsel: papan ketik muncul).

## Rancangan teknis

- `_revealFirstIssue` di `PurchaseFormPanel` menunggu
  `Scrollable.ensureVisible` (bila perlu gulir), lalu bila sasaran berupa
  `PurchaseIssue` dengan field di `_textIssueFields` (atau supplier saat
  `newSupplier`), mencari `EditableText`
  pertama di bawah jangkar dan memanggil `focusNode.requestFocus()`.
- Bila simpan gagal lagi selama gulir berjalan, panggilan lama tidak
  memberi kursor (dibandingkan dengan `_revealed`).
- Tidak ada `FocusNode` baru: node milik `FTextField` dipakai lewat
  `EditableText`.

## Pengujian

- `purchase_flow_test.dart` grup F1-12k:
  - 360 px: qty 0, kursor di kotak pindai, gulir ke bawah, *Simpan draf* →
    qty terlihat dan berkursor;
  - 1440 px: qty 0 lalu *Simpan draf* dari dialog *Buang perubahan?* →
    qty berkursor;
  - supplier kosong dan qty 0, *Terima barang* → galat supplier tampil
    dan tidak ada isian teks yang berkursor;
  - *Supplier baru* dengan nama kosong, *Terima barang* → nama supplier
    berkursor;
  - diskon melebihi subtotal (isian ber-prefix Rp), *Simpan draf* → diskon
    berkursor.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Kursor ke isian salah setelah simpan pembelian gagal | 1.19 | Rilis v0.128.0 | Isian teks saja; pilihan supplier dan tanggal tidak menerima kursor. |
