# F1-12i · Tombol Simpan draf di dialog *Buang perubahan?* pembelian

- **Fase:** 1
- **Status:** Rilis v0.124.0
- **Layar:** 1.19 Pembelian: form samping (layar lebar) dan halaman form
  pembelian baru / draf (layar sempit); dialog *Buang perubahan?*
  (F1-12f).
- **Acuan:** gap "Simpan draf langsung dari dialog" di
  [F1-12f](2026-11-14-f1-12f-keluar-tanpa-menyimpan-design.md); pola sama
  dengan form produk [F1-07r](2026-11-20-f1-07r-simpan-dari-dialog-produk-design.md),
  pengeluaran [F1-15d](2026-11-20-f1-15d-simpan-dari-dialog-pengeluaran-design.md),
  dan penyesuaian stok [F1-08n](2026-11-20-f1-08n-simpan-dari-dialog-penyesuaian-design.md).

## Masalah

Staf yang sedang mengisi pembelian (mis. memindai 10 barang dari faktur
supplier) lalu mengetuk menu lain, **Ganti kasir**, ✕ jendela, *Pembelian
baru*, atau draf lain di daftar hanya bisa memilih Batal atau Buang. Untuk
menyimpan isiannya ia harus kembali, menekan **Simpan draf**, lalu
mengulang navigasinya.

## Aturan

1. Dialog *Buang perubahan?* dari form pembelian punya tombol **Batal**,
   **Buang**, dan **Simpan draf** (label "Simpan draf", bukan "Simpan",
   karena barang belum diterima dan stok belum bertambah). Tata letak sama
   dengan F1-07r; di layar sempit tersusun ke bawah, Simpan draf teratas.
2. **Simpan draf** menjalankan simpan yang sama dengan tombol *Simpan
   draf* form (validasi draf, foto faktur). Bila berhasil, navigasi yang
   tertahan diteruskan: menu yang diketuk, Kembali, layar masuk, aplikasi
   tertutup, atau di layar lebar form samping diganti dengan *Pembelian
   baru* / draf yang dipilih. Daftar pembelian dimuat ulang bila layar
   Pembelian tetap tampil, jadi draf baru langsung terlihat.
3. Bila simpan gagal karena isian (mis. qty 0) atau ditolak penyimpanan,
   staf tetap di form dengan pesan galat yang sama dengan tombol *Simpan
   draf*.
4. Selama simpan berjalan, navigasi lain ditolak (`LeaveGuard.saving`,
   F1-07r).
5. Form yang tetap tampil setelah tersimpan sudah menjadi draf bernomor,
   jadi simpan berikutnya memperbarui draf yang sama, tidak membuat
   pembelian kedua.
6. Isian yang diubah selama simpan berjalan (mis. scan atau catatan yang
   diketik sebelum simpan selesai) tidak ikut tersimpan dan tetap
   terhitung belum tersimpan; staf tetap di form agar isian itu tidak
   hilang, dan dialog ditanya lagi saat ia keluar. Ini juga berlaku untuk
   tombol *Simpan draf* biasa: ringkasan isian diambil sebelum menunggu
   penyimpanan.

## Rancangan teknis

- `confirmDiscardChanges` mendapat parameter opsional `saveLabel` (bawaan
  "Simpan"); pembelian memakai kunci l10n baru `purchaseDiscardSaveDraft`.
- `savePurchaseDraftBeforeLeaving(form, guard)` di
  `purchase_form_view.dart`: menyalakan `LeaveGuard.saving`, menjalankan
  `form.saveDraft.execute()`, lalu `true` bila `Ok` dan form tidak berubah
  lagi selama simpan.
- `PurchaseFormViewModel._submit` mengambil ringkasan isian (`_signature`,
  tanda foto dianggap bersih) sebelum `await` simpan draf, lalu memakainya
  sebagai tanda tersimpan; terima barang tetap memakai `_markSaved()`
  karena form diganti.
- `PurchasesScreen._confirmLeave` (form samping) dan
  `_PurchaseFormPageState._confirmLeave` (halaman form) memberi `onSave`.
  Form samping memuat ulang daftar di callback pasca-frame bila
  `mounted && !isRouteClosing(context)`.

## Pengujian

- `purchase_flow_test.dart` grup F1-12i: 1440 px menu lain → Simpan draf
  → draf tersimpan dan layar Stok; *Pembelian baru* → Simpan draf → form
  kosong dan draf tampil di daftar; qty 0 → tetap dengan pesan; galat
  penyimpanan → tetap dengan pesan; menu lain selama simpan ditolak; ✕
  jendela → Simpan draf → keluar; 360 px halaman form Kembali → Simpan
  draf → daftar; buka draf itu, ubah, Kembali → Simpan draf memperbarui
  draf yang sama.
- Tambahan setelah review: pilih draf lain → Simpan draf → draf itu
  terbuka; ketukan daftar selama simpan ditolak; Ganti kasir → Simpan
  draf; isian yang diubah selama simpan → tetap di form lalu tersimpan
  berikutnya; view model: catatan yang diketik selama simpan draf tetap
  terhitung berubah.
- `confirm_discard_test.dart`: label `saveLabel`.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Simpan draf dari dialog *Buang perubahan?* pembelian | 1.19 | Rilis v0.124.0 | Form samping dan halaman form. |
| Simpan dari dialog saat form tertutup halaman lain | — | Belum | Layar lebar: detail pembelian diterima dibuka di atas form samping yang berubah, lalu ✕ jendela / Ganti kasir → Simpan draf gagal: pesannya di form yang tertutup. Sama dengan gap F1-07r. |
| Gulir ke pesan galat | — | Rilis v0.127.0 | [F1-12j](2026-11-20-f1-12j-gulir-ke-galat-pembelian-design.md): form bergulir ke galat paling atas setelah simpan gagal, dari tombol maupun dialog. |
