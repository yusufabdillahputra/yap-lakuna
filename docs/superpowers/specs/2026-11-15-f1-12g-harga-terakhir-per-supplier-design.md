# F1-12g · Harga beli terakhir dari supplier yang dipilih

- **Fase:** 1
- **Status:** Rilis v0.105.0
- **Layar:** 1.19 Pembelian (form *Pembelian baru* / draf), termasuk form
  yang dibuka dari Stok › *Stok minimum*.
- **Acuan:** gap "Harga terakhir per supplier terpilih" di
  [F1-08e](2026-11-14-f1-08e-harga-beli-terakhir-design.md) dan
  [F1-12e](2026-11-14-f1-12e-harga-terakhir-barang-manual-design.md).
  Storeku tidak punya aturan ini.

## Masalah

Harga beli baris diisi dari pembelian diterima terakhir barang itu,
**dari supplier mana pun**. UMKM sering membeli barang yang sama dari
beberapa supplier dengan harga berbeda (grosir besar vs toko dekat). Saat
staf memilih *CV Sumber Pangan*, harga yang terisi bisa harga dari *Toko
Makmur* minggu lalu, dan staf harus mengingat serta mengetik ulang harga
supplier yang dipilih.

## Aturan

1. **Harga terakhir** sebuah barang di form = harga per satuan dasar pada
   pembelian diterima terakhir **dari supplier yang dipilih di form**.
   Bila barang itu belum pernah dibeli dari supplier tersebut, atau
   supplier kosong / supplier baru yang diketik, pakai pembelian diterima
   terakhir dari supplier mana pun (perilaku F1-08e/F1-12e). Bila belum
   pernah dibeli sama sekali, harga modal. Aturan lain tetap: hanya
   pembelian cabang ini, baris bonus Rp 0 dilewati, satuan konversi
   dihitung per satuan dasar.
2. Berlaku untuk baris **satuan dasar yang harganya masih otomatis**:
   baris yang ditambah staf (scan / cari), baris yang satuannya
   dikembalikan ke satuan dasar, dan baris dari stok minimum. Harga yang
   sudah diketik staf tidak pernah ditimpa.
3. **Mengganti supplier** (memilih supplier lain, mengosongkan, atau
   mengetik supplier baru) menyegarkan harga semua baris otomatis sesuai
   supplier baru; bila supplier baru tidak punya riwayat untuk barang itu,
   harga kembali ke harga terakhir dari supplier mana pun, atau harga
   modal.
4. Form dari stok minimum memilih supplier terakhir lebih dulu (F1-08d),
   lalu mengisi harga dari supplier itu. *Buka draf* (F1-08i) memakai
   supplier draf untuk barang yang ditambahkan.
5. Baris yang dimuat dari draf tersimpan dianggap harganya sudah
   ditetapkan: mengganti supplier draf tidak mengubahnya. Baris di form
   yang baru saja disimpan sebagai draf tetap otomatis sampai draf itu
   dibuka ulang (staf masih di form yang sama).
6. Simpan / terima menunggu penyegaran harga yang sedang berjalan, agar
   yang tersimpan sama dengan yang tampil (sama dengan F1-12e).
7. Penyegaran harga karena ganti supplier bukan isian baru: ganti
   supplier itu sendiri sudah dihitung perubahan (F1-12f).
8. Isian harga yang hanya difokus atau diseleksi (tanpa angka berubah)
   tidak dianggap ketikan staf; hanya harga yang benar-benar berubah
   yang mengunci baris.
9. Bila riwayat harga gagal dibaca saat supplier diganti, harga baris
   tetap seperti sebelumnya (staf bisa mengetik harganya). Catatan
   "N harga diisi dari pembelian terakhir" di form stok minimum
   menghitung isian pertama dan tidak dihitung ulang setelah supplier
   diganti.

## Rancangan teknis

- Data: `lastPurchasePricesOf(store, scope, variantIds, {supplierId})`
  menyaring pembelian dengan `supplier_id` itu bila diberikan.
  Repositori `lastPurchasePrices(variantIds, {supplierId})`.
- VM: `PurchaseFormLine.autoPrice` (true untuk baris baru, baris stok
  minimum, dan setelah ganti satuan; false setelah staf mengetik harga
  dan untuk baris draf). Tembolok harga per supplier di samping tembolok
  harga semua supplier. `selectSupplier` / `useNewSupplier` memulai
  penyegaran yang dibuang bila supplier berganti lagi selama menunggu
  (`_priceRev`, naik juga saat form dikosongkan atau draf dimuat).
  Harga terakhir untuk barang baru (`_fillLastPrice`) dan untuk baris
  stok minimum (`_applyRestockPrices`) juga dibuang bila supplier berganti
  selama menunggu; penyegaran supplier baru yang mengisinya.
  `setUnitPrice` mengabaikan harga yang sama (isian Forui memanggil
  `onChange` saat fokus/seleksi berubah).
  Restock: `_applyRestockSupplier` dijalankan sebelum
  `_applyRestockPrices`.

## Pengujian

- Data (`purchases_test.dart`): harga per supplier; supplier tanpa
  riwayat → kosong; tanpa `supplierId` tetap terbaru dari semua.
- VM (`purchase_view_models_test.dart`): tambah barang dengan supplier
  terpilih; ganti supplier menyegarkan baris otomatis tapi tidak baris
  yang diketik; supplier tanpa riwayat → harga semua supplier; supplier
  baru / kosong; ganti supplier dua kali cepat dengan jawaban terbalik
  (hanya hasil terakhir); isian harga yang hanya difokus; harga barang
  baru / stok minimum dari supplier lama dibuang; stok minimum memakai
  harga supplier terakhir; *Buka draf* memakai supplier draf; baris draf
  tidak berubah; simpan menunggu penyegaran.
- Widget (`purchase_flow_test.dart`): ketuk isian harga lalu pilih
  supplier → harga supplier tampil dan tersimpan.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Harga terakhir dari supplier terpilih | 1.19 | Rilis v0.105.0 | Jatuh ke harga semua supplier bila belum pernah dibeli dari supplier itu. |
| Penanda asal harga di baris | — | Rilis v0.129.0 | [F1-12l](2026-11-20-f1-12l-asal-harga-baris-pembelian-design.md): *Harga terakhir {tanggal} · {supplier}* atau *Harga modal* di bawah nama barang. |
| Harga terakhir per satuan konversi | 1.19 | Selesai v0.106.0 | [F1-12h](2026-11-15-f1-12h-harga-terakhir-satuan-konversi-design.md), termasuk per supplier. |
