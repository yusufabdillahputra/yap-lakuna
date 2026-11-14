# F1-08i · *Buka draf* menambahkan barang stok minimum yang belum ada

- **Fase:** 1
- **Status:** Rilis v0.95.0
- **Layar:** 1.18 *Stok* › *Stok minimum* › *Buat pembelian* › dialog
  *Sudah ada draf pembelian* › *Buka draf* → form draf 1.19.
- **Acuan:** gap "Gabungkan barang yang belum ada ke draf yang dibuka" di
  [F1-08g](2026-11-14-f1-08g-draf-pembelian-ganda-design.md). Storeku tidak
  punya alur ini.

## Masalah

*Buka draf* (F1-08g) membuka draf apa adanya. Barang di bawah minimum yang
belum ada di draf harus dicari dan ditambah satu per satu, padahal jumlah
saran dan harganya sudah diketahui dari stok minimum. Staf yang lupa
menambahkannya baru sadar saat barang itu tetap tampil di bawah minimum.

## Aturan

1. *Buka draf* membuka form draf itu dan menambahkan di akhir setiap barang
   di bawah minimum yang **belum ada** di draf itu **maupun di draf lain**
   ke lokasi yang sama, dengan jumlah saran F1-08c (2 × minimum − stok,
   satuan dasar) dan harga beli terakhir F1-08e (harga modal bila belum
   pernah dibeli). Barang yang sudah dipesan lewat draf lain tidak
   ditambahkan lagi agar tidak terpesan dua kali.
2. Baris draf yang sudah ada **tidak diubah**: jumlah, satuan, dan harganya
   tetap, walau barangnya juga di bawah minimum. Barang dihitung "sudah
   ada" per varian, apa pun satuannya (mis. draf berisi 1 dus, saran 38 pcs
   → tidak ditambah), sama dengan pencocokan F1-08g. Lokasi terima, supplier,
   tanggal, dan isian lain draf juga tetap (supplier terakhir F1-08d tidak
   dipakai).
3. Catatan di atas form:
   - ada yang ditambahkan: "Dari stok minimum {lokasi}: {n} barang
     ditambahkan ke draf ini, {m} barang sudah ada. Simpan draf agar
     tambahan tersimpan." (+ catatan harga terakhir / barang dilewati
     seperti F1-08c/e);
   - semua sudah ada: "Semua barang di bawah minimum {lokasi} sudah ada di
     draf ini."
4. Tambahan baru tersimpan saat staf menekan *Simpan draf* atau *Terima*;
   keluar tanpa menyimpan membuang tambahan (draf di database tidak
   berubah). Setelah *Simpan draf* berhasil, catatan stok minimum hilang.
5. Membuka draf dari menu *Pembelian* tidak berubah (tanpa tambahan).
6. Isi dialog F1-08g menyebut bahwa barang yang belum ada akan ditambahkan.

## Rancangan teknis

- `StockScreen._restock`: isian yang diteruskan ke *Buka draf* membuang
  varian yang ada di draf lain hasil pencarian (`found.skip(1)`).
- Router: `onOpenDraft(id, restock)` → `context.push(Routes.purchase(id),
  extra: restock)`; rute `/pembelian/:id` meneruskan `extra`
  `PurchaseRestock` ke `PurchaseDetailScreen.restock`, yang meneruskannya ke
  `PurchaseFormPage` bila pembelian itu draf.
- `PurchaseFormViewModel._load`: setelah `_fill(draft)`, bila ada
  `restock`, `_applyRestockToDraft` memilih baris yang variannya belum ada,
  memanggil `_applyRestock(…, keepLocation: true)`, lalu
  `_applyRestockPrices(keys baris baru)`. `_applyRestockPrices` kini
  menerima kunci baris sasaran agar harga baris draf lama tidak tersentuh.
- Getter baru `restockIntoDraft` dan `restockInDraft`; dikosongkan di
  `_blank` dan setelah simpan berhasil.
- l10n: `purchaseRestockIntoDraft`, `purchaseRestockAllInDraft` (ID + EN);
  `stockRestockDraftBody` diperbarui.

## Pengujian

- VM: barang yang belum ada ditambahkan dengan jumlah saran dan harga
  terakhir; baris draf lama, lokasi, dan supplier tetap (riwayat supplier
  terakhir diabaikan); semua sudah ada → tidak ada baris baru; *Simpan
  draf* menyimpan tambahan ke draf yang sama (tidak membuat draf baru) dan
  menghapus catatan.
- Widget (`stock_flow_test.dart`, 1280 / 360 px): *Buka draf* menampilkan
  catatan "1 barang ditambahkan ke draf ini, 1 barang sudah ada" dan dua
  baris.
- Widget: dua draf (A barang pertama, B barang kedua), *Buka draf* membuka
  B tanpa menambah barang pertama (diverifikasi mutasi).
- Uji manual Xvfb: draf berisi satu barang, *Buat pembelian* › *Buka draf*
  menampilkan barang kedua tertambah.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| *Buka draf* menambahkan barang stok minimum yang belum ada | 1.19 | Rilis v0.95.0 | Baris draf lama tidak diubah; tambahan tersimpan saat draf disimpan. |
| Peringatan saat keluar tanpa menyimpan tambahan | — | Belum | Form pembelian belum punya peringatan perubahan belum tersimpan. |
| Draf diterima / dihapus di perangkat lain di antara dialog dan form | — | Belum | Isian stok minimum diabaikan tanpa catatan (detail pembelian atau halaman galat yang tampil). |
