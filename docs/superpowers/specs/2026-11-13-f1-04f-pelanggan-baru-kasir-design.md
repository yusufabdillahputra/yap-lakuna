# F1-04f · Pelanggan baru dari Kasir

- **Fase:** 1
- **Status:** Rilis v0.33.0
- **Layar:** 1.4b (dialog *Pilih pelanggan*), 1.5b (pemilih kredit),
  memakai form pelanggan 1.20.
- **Acuan:** F1-04d aturan 1–3 (pelanggan di kepala Pesanan), F1-13
  (form pelanggan, kredit).
- **Menutup gap:** F1-04d "*Pelanggan baru* dari pemilih Kasir".

## Tujuan

Pelanggan yang belum terdaftar bisa langsung dibuat dari Kasir tanpa
meninggalkan transaksi, lalu terpilih otomatis di nota (atau di kredit).

## Aturan

1. Tombol *Pelanggan baru* tampil di dialog *Pilih pelanggan* dan di panel
   *Kredit / piutang* untuk staf dengan `customers:manage`. Staf tanpa izin
   tidak melihat tombolnya; repositori pelanggan tetap memeriksa izin.
2. Tombol membuka form pelanggan yang sama dengan menu Pelanggan 1.20
   (nama, HP, alamat, grup / grup baru, limit kredit, catatan) dengan
   validasi dan aturan HP unik yang sama, termasuk keyboard.
3. Isian awal dari kata pencarian: bila berisi huruf menjadi nama, bila
   hanya angka (dan tanda `+`, spasi, `-`) menjadi nomor HP.
4. Setelah disimpan: daftar pelanggan dimuat ulang; di dialog *Pilih
   pelanggan*, pelanggan baru langsung dipasang ke nota dan dialog
   ditutup; di panel kredit, pelanggan baru langsung terpilih (jatuh tempo
   dari tempo grupnya). Batal = tidak ada perubahan.
5. Keranjang, diskon, dan pilihan bayar tidak berubah selama form dibuka.

## Komponen

- `CashierData.canAddCustomer` (`customers:manage`) lokal + palsu.
- `CustomerFormScope` (InheritedWidget) di `CashierScreen` membawa
  `CustomersRepository` dari router.
- `showCustomerForm(..., initialName:, initialPhone:)`.
- `CashierViewModel.useNewCustomer(Customer)` (kepala nota) dan
  `useNewCreditCustomer(Customer)` (panel kredit; muat ulang lalu pilih).

## Pengujian

- View model: pelanggan baru terpasang di nota; kredit memuat ulang lalu
  memilih pelanggan baru dengan jatuh tempo tempo grup.
- Widget 1280 dan 360 px: pencarian "Siti" → *Pelanggan baru* → nama
  terisi → simpan → nota berpelanggan Siti; panel kredit; tanpa izin
  tombol tidak tampil.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| *Pelanggan baru* dari pemilih Kasir dan kredit | 1.4b, 1.5b | Rilis v0.33.0 | Selesai. |
