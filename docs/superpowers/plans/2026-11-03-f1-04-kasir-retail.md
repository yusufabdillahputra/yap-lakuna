# Rencana F1-04 Kasir retail + inti F1-05 Bayar (v0.6.0)

Spec: `../specs/2026-11-03-f1-04-kasir-retail-design.md`,
`../specs/2026-11-03-f1-05-pembayaran-design.md`.
Target rilis v0.6.0. Setiap tugas: tes gagal dulu, lalu kode, lalu tes lulus.

## 1. Domain (`packages/lakuna_domain/lib/src/sale.dart`, `payment.dart`)

- [ ] `CartLine` (varian, satuan opsional, isi, harga jual, tiers, qty) dan
      `priceLine`: harga satuan, harga daftar, total baris, catatan grosir.
- [ ] `CartTotals` (subtotal, diskon grosir, total, item).
- [ ] `nextReceiptCounter(existingNumbers, prefix)`.
- [ ] `PaymentMethod`, `settleCash` (kembalian / kurang), `quickCashAmounts`,
      validasi referensi.

## 2. Model Serverpod (`lakuna_server/lib/src/sales/`)

- [ ] `sale_status`, `payment_method`, `payment_status` (enum byName).
- [ ] `sale`, `sale_item`, `payment`; migrasi `penjualan`.
- [ ] Analyze server dan client bersih.

## 3. Data (`packages/lakuna_data/lib/src/sales.dart`)

- [ ] Tes: checkout tunai menulis nota + item + pembayaran + stok + outbox.
- [ ] Tes: harga dari DB, grosir, satuan konversi (stok −qty × isi).
- [ ] Tes: tanpa sesi / sesi tertutup / produk nonaktif / uang kurang ditolak.
- [ ] Tes: nomor nota urut per perangkat per hari.
- [ ] Tes: rekap laci memuat penjualan tunai bersih; ringkasan sesi.
- [ ] Implementasi + ekspor.

## 4. Aplikasi: repositori & view model

- [ ] `SalesRepository` (abstrak) + `LocalSalesRepository` (izin
      `sales:create`) + palsu untuk tes.
- [ ] `CashierViewModel`: muat katalog + sesi, cari, kategori, scan Enter,
      keranjang, total.
- [ ] `PaymentViewModel`: metode, keypad, nominal cepat, simpan, hasil.

## 5. Aplikasi: layar

- [ ] Rute `/kasir`, `/kasir/bayar`; menu *Kasir*.
- [ ] `CashierView` 1.4 (grid + panel pesanan) dan 1.11/1.11b (daftar +
      bilah bawah + sheet).
- [ ] Dialog pilih varian × satuan, dialog ketik jumlah.
- [ ] `PaymentView` 1.5 (metode, tunai keypad, kartu, transfer) dan
      sukses 1.5c (kembalian, stok minus, pratinjau struk).
- [ ] Sesi kasir: angka transaksi/penjualan di tutup sesi.
- [ ] Kunci i18n `cashier*`/`payment*` ID + EN.
- [ ] Tes widget tablet + ponsel.

## 6. Verifikasi & rilis

- [ ] `dart format`, analyze `--fatal-infos`, semua tes.
- [ ] Uji manual Xvfb 1280x800 + ponsel 400x800 gelap; tangkapan layar
      `v0.6.0-*.png`.
- [ ] `pubspec.yaml` 0.6.0+7, CHANGELOG [0.6.0], Status & gap, indeks.
- [ ] Review subagent, perbaiki Critical/Important.
- [ ] PR, CI hijau, squash merge, mulai ulang cabang, cek rilis 6 menit.
