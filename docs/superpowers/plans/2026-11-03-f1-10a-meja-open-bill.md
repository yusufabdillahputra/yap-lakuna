# Rencana F1-10a · Meja & open bill (v0.11.0)

Spec: [2026-11-03-f1-10-meja-fnb-design.md](../specs/2026-11-03-f1-10-meja-fnb-design.md).

## 1. Domain (`packages/lakuna_domain`)

- [x] Tes `test/dining_test.dart`: `fnbCharges` (service hanya dine in, PB1
  dari subtotal + service, pembulatan, tarif 0), `validateTableName` /
  `validateAreaName`, `takeAwayLabel(7)` = `TA-07`, `kitchenTicketLabel`,
  `takeAwayState`, `tableRange('M', 1, 12)`, batas tarif.
- [x] `lib/src/dining.dart` + ekspor.

## 2. Model & migrasi (`lakuna_server`)

- [x] Enum `OrderType`, `KitchenStatus`; tabel `dining_areas`,
  `dining_tables`, `kitchen_tickets`; kolom baru `sales`, `sale_items`.
- [x] `serverpod generate`, `serverpod create-migration --tag meja`; cek SQL
  SQLite hanya `ADD COLUMN` untuk `sales`/`sale_items`.

## 3. Data (`packages/lakuna_data`)

- [x] Tes `test/dining_test.dart`: area/meja CRUD, tarif, buka bill, item,
  kirim dapur, disajikan, minta bill, pindah, batal, hapus kosong, take
  away, bayar (nomor nota, stok sekali, tarif beku, sesi wajib), izin.
- [x] `lib/src/dining_admin.dart` (area, meja, tarif) dan
  `lib/src/open_bill.dart` (bill, item, dapur, bayar). Bayar memakai
  bagian bersama dengan `checkoutSale` (pembayaran, stok, nomor nota).
- [x] Struk: baris *Service* dan *PB1* bila ada.

## 4. Flutter

- [x] `DiningRepository` + `LocalDiningRepository` (cek izin), palsu untuk
  tes.
- [x] `MealsViewModel` (layar Meja) + tes.
- [x] `ui/dining/dining_view.dart`: grid meja, take away, panel bill, lembar
  menu, dialog tamu/pindah/batal, dialog tiket dapur + cetak.
- [x] Kasir mode bill (`/kasir?bill=`): `CashierRepository.loadBill` /
  `payBill`, tahap bayar langsung, *Kembali ke meja*.
- [x] Master › *Meja & area* (izin `settings:manage`).
- [x] Pengaturan › *Pajak & service*.
- [x] Rute `/meja`, menu *Meja* (`open_bills:manage`), i18n ID + EN.
- [x] Tes widget: alur meja, take away, batal, pindah, ponsel 360/820/1280,
  tanpa izin; master meja; tarif.

## 5. Selesai

- [ ] Review subagent; perbaiki Critical/Important.
- [x] Uji manual Xvfb (desktop + ponsel), tangkapan layar.
- [x] Spec Status & gap, README spec, CHANGELOG 0.11.0, versi `0.11.0+12`.
- [ ] PR, CI hijau, squash merge, cek rilis.
