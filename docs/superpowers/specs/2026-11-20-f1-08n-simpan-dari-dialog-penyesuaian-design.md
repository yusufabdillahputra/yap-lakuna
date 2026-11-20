# F1-08n · Tombol Simpan di dialog *Buang perubahan?* penyesuaian stok

- **Fase:** 1
- **Status:** Rilis v0.123.0
- **Layar:** 1.18 Stok, tab *Penyesuaian*; dialog *Buang perubahan?* saat
  keluar dan saat ganti lokasi (F1-08k).
- **Acuan:** gap "Simpan langsung dari dialog" di
  [F1-08k](2026-11-15-f1-08k-keluar-draf-penyesuaian-design.md); pola sama
  dengan form produk [F1-07r](2026-11-20-f1-07r-simpan-dari-dialog-produk-design.md)
  dan pengeluaran [F1-15d](2026-11-20-f1-15d-simpan-dari-dialog-pengeluaran-design.md).

## Masalah

Kasir yang sudah menghitung stok fisik (mis. Kopi Susu fisik 3) lalu
mengetuk menu lain, **Ganti kasir**, ✕ jendela, atau mengganti lokasi hanya
bisa memilih Batal atau Buang. Untuk menyimpan hasil hitungannya ia harus
kembali ke tab *Penyesuaian*, menekan Simpan, lalu mengulang
navigasinya.

## Aturan

1. Dialog *Buang perubahan?* saat meninggalkan layar Stok (`stock-discard`)
   dan saat ganti lokasi (`stock-location-discard`) punya tombol
   **Simpan** bila tombol Simpan penyesuaian sendiri aktif, yaitu draf
   punya minimal satu baris dengan stok fisik. Draf yang hanya berisi
   catatan atau baris tanpa stok fisik tetap hanya Batal / Buang, karena
   belum ada yang bisa disimpan.
2. **Simpan** menjalankan simpan yang sama dengan tombol Simpan
   penyesuaian: baris tanpa stok fisik tidak ikut, nomor penyesuaian
   dipakai, dan ledger stok tercatat.
3. Saat keluar: bila berhasil, navigasi yang tertahan diteruskan (menu
   yang diketuk, layar masuk, atau aplikasi tertutup).
4. Saat ganti lokasi: bila berhasil, penyesuaian tercatat di lokasi lama
   lalu layar pindah ke lokasi yang dipilih. Konfirmasi *Penyesuaian …
   tersimpan.* tetap tampil di lokasi baru.
5. Bila simpan gagal (isian ditolak, mis. tidak ada selisih, atau galat
   penyimpanan), kasir tetap di layar Stok, di lokasi lama, dengan draf
   utuh. Layar pindah ke tab *Penyesuaian* agar pesan galat di bawah draf
   terlihat walau dialog dibuka dari tab lain.
6. Selama simpan berjalan, navigasi lain ditolak (`LeaveGuard.saving`,
   F1-07r, ditambah `busy` F1-08k).

## Rancangan teknis

- `StockScreen._confirmLeave` dan `_LocationSelect._select` memberi
  `onSave` ke `confirmDiscardChanges` hanya bila `vm.canSave`.
- `onSave` keluar: menyalakan `LeaveGuard.saving`, `vm.save.execute()`,
  `true` bila hasilnya `Ok`; selain itu `vm.setTab(StockTab.adjustment)`
  lalu `false`.
- `onSave` ganti lokasi: sama, tanpa `LeaveGuard` (layar tidak
  ditinggalkan; menu lain selama simpan sudah ditolak oleh `busy`). Gagal
  → pilihan lokasi kembali ke lokasi lama (`_revision++`).
- View model sudah mengosongkan draf dan memuat ulang setelah simpan
  berhasil, jadi layar yang tetap tampil tidak menyimpan dua kali.

## Pengujian

- `stock_flow_test.dart` grup F1-08n: 1280 px menu lain → Simpan →
  tersimpan dan layar Produk; draf tanpa fisik / hanya catatan → tanpa
  Simpan; isian ditolak dari tab lain → tetap, tab *Penyesuaian*, pesan
  galat; galat penyimpanan → tetap; ganti lokasi → Simpan → tersimpan di
  lokasi lama lalu pindah; ganti lokasi → Simpan gagal → tetap di lokasi
  lama dengan draf; menu lain selama simpan ditolak (keluar dan ganti
  lokasi); tujuan diperiksa lewat jalur router; 360 px menu bawah;
  ✕ jendela → Simpan → keluar.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Simpan dari dialog *Buang perubahan?* penyesuaian stok | 1.18 | Rilis v0.123.0 | Keluar dan ganti lokasi; hanya bila tombol Simpan penyesuaian aktif. |
