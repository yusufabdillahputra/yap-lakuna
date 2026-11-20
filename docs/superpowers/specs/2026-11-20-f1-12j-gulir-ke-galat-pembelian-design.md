# F1-12j · Gulir ke galat setelah simpan pembelian gagal

- **Fase:** 1
- **Status:** Rilis v0.127.0
- **Layar:** 1.19 Pembelian: form samping (layar lebar), halaman form
  draf / pembelian baru (ponsel dan dari Stok).
- **Acuan:** gap "Gulir ke pesan galat" di
  [F1-12i](2026-11-20-f1-12i-simpan-draf-dari-dialog-pembelian-design.md).
  Storeku tidak punya aturan khusus; pola fokus isian salah ada di dialog
  meja ([F1-10q](2026-11-20-f1-10q-fokus-isian-salah-design.md)).

## Masalah

Form pembelian panjang: supplier dan nomor faktur di atas, barang di
tengah, pembayaran dan total di bawah. Bila *Simpan draf* atau *Terima
barang* gagal, pesannya tampil di isian yang salah atau di kotak merah di
atas tombol. Saat staf sedang melihat bagian lain (mis. menekan *Simpan
draf* dari dialog *Buang perubahan?* sambil melihat daftar barang, atau
menekan *Terima barang* di bawah padahal supplier kosong di atas), pesan
itu di luar layar dan seolah tidak terjadi apa-apa.

## Aturan

1. Setiap simpan pembelian yang gagal (*Simpan draf*, *Terima barang*,
   *Simpan draf* dari dialog *Buang perubahan?*, atau *Hapus draf*)
   menggulir form ke pesan galat paling atas yang tampil: isian yang salah
   (supplier, nomor faktur, jumlah / harga barang, daftar barang kosong,
   diskon, dibayar, jatuh tempo, catatan) atau kotak galat simpan (mis.
   lokasi stok tidak ada, penyimpanan menolak).
2. "Paling atas" menurut posisi di layar, jadi tata letak lebar (pembayaran
   dan total bersebelahan) dan sempit sama-sama benar.
3. Bila pesannya sudah terlihat seluruhnya, layar tidak digeser. Bila
   belum, pesan ditaruh sedikit di bawah tepi atas area gulir (10%).
4. Simpan yang berhasil tidak menggulir.

## Rancangan teknis

- `PurchaseFormViewModel` menaikkan `failedSubmits` (penghitung) setiap
  `_submit` gagal (lokasi tidak ada, isian salah, galat penyimpanan) dan
  setiap hapus draf gagal.
- Ongkir dan sumber dana juga dijangkari, walau galatnya tidak bisa muncul
  dari form (ongkir tidak bisa negatif, sumber dana selalu terpilih).
- `PurchaseFormPanel` menjadi `StatefulWidget`. Isian yang bisa salah dan
  kotak `purchase-action-error` dibungkus `_IssueAnchor(id)` yang memasang
  `GlobalKey` dari registri milik panel (lewat `InheritedWidget`).
- Saat `failedSubmits` berubah, panel menunggu bingkai berikutnya, memilih
  jangkar galat yang terpasang dengan posisi global teratas (lalu
  terkiri), lalu `Scrollable.ensureVisible` dengan
  `ScrollPositionAlignmentPolicy.explicit` dan perataan 0,1 bila jangkar di
  luar layar.
- Tidak memindahkan fokus keyboard: pilihan supplier dan tanggal bukan
  isian teks.

## Pengujian

- `purchase_view_models_test.dart`: `failedSubmits` naik pada isian salah
  (terima tanpa barang, catatan terlalu panjang), galat penyimpanan, dan
  hapus draf gagal; tetap pada simpan berhasil (aturan 4). Jalur lokasi
  tidak ada tidak diuji tersendiri.
- `purchase_flow_test.dart` grup F1-12j:
  - 360 px (halaman form): banyak barang, supplier kosong, *Terima barang*
    di bawah → supplier terlihat di layar;
  - 1440 px: banyak barang, galat penyimpanan dari dialog *Buang
    perubahan?* setelah gulir ke atas → kotak galat terlihat;
  - galat yang sudah terlihat tidak menggeser layar.
  - "Terlihat" diukur terhadap area gulir halaman, bukan seluruh jendela.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Gulir ke galat setelah simpan pembelian gagal | 1.19 | Rilis v0.127.0 | Tombol form dan dialog *Buang perubahan?*. |
| Fokus keyboard ke isian salah | — | Rilis v0.128.0 | [F1-12k](2026-11-20-f1-12k-fokus-isian-salah-pembelian-design.md): isian teks saja; supplier dan tanggal tidak menerima kursor. |
