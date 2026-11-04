# Rencana F1-13 · Pelanggan & piutang (v0.17.0)

Spec: `docs/superpowers/specs/2026-11-03-f1-13-pelanggan-piutang-design.md`.
Alur: TDD per lapisan (domain → data → aplikasi), lalu review subagent, uji
manual Xvfb, dokumen, dan rilis.

## 1 · Domain (`packages/lakuna_domain`)

- [x] `customer.dart`: `CustomerLimits`, `normalizePhone`,
  `validateCustomer` → daftar `CustomerIssue`, `validateCustomerGroup`.
- [x] `receivable.dart`:
  - [x] `saleOutstanding(total, paidAtSale, allocated, debtReduction)`.
  - [x] `creditIssue(limit, outstanding, credit, downPayment, total, dueOn,
    today)` → galat kredit.
  - [x] `allocateOldestFirst(amount, open)` dan
    `validateAllocations(amount, open, manual)`.
  - [x] `isOverdue(dueOn, today)`, `debtPaymentNumber` (`BP-`).
  - [x] `rupiahInWords` (terbilang).
- [x] `customer_import.dart`: `parseCsv`, `customerImportRows(header,
  rows)` → baris sah + baris ditolak (nomor, alasan enum).
- [x] Tes untuk ketiganya.

## 2 · Model server

- [x] `customer_groups`, `customers`, `debt_payments`,
  `debt_payment_allocations`, enum `DebtParty`, `DebtDocumentType`.
- [x] `sales.customer_id`, `sales.due_on`, `sale_returns.debt_reduction`.
- [x] `serverpod generate`, `create-migration --tag pelanggan`.

## 3 · Data (`packages/lakuna_data/lib/src/customers.dart` + sentuhan)

- [x] Grup: daftar (+ jumlah pelanggan), simpan, hapus (ditolak bila
  dipakai).
- [x] Pelanggan: daftar dengan piutang + terlambat, simpan (HP unik, grup
  baru), hapus (piutang 0), detail (nota belum lunas, riwayat bayar).
- [x] `checkoutSale(credit:)`: pelanggan, DP, limit, jatuh tempo.
- [x] `receiveDebtPayment`: FIFO/manual, kas laci vs kas toko, saldo
  sebelum/sesudah, nomor BP.
- [x] `loadDebtPayment` untuk kuitansi.
- [x] `returnSale`: pengurang piutang; `sessionCashRefunds` dikurangi
  pengurang piutang.
- [x] `voidSale`: `VoidBlock.debtPaid`.
- [x] Riwayat: sisa piutang per baris dan rincian (pelanggan, jatuh tempo).
- [x] Rekap sesi: penjualan kredit.
- [x] `importCustomers(rows)`.
- [x] Cek izin aktor (`customers:manage` / `debts:manage`).
- [x] Tes `test/customers_test.dart` (+ kasus retur/void/riwayat).

## 4 · Aplikasi (`lakuna_flutter`)

- [x] `CustomersRepository` + `LocalCustomersRepository` (izin) + palsu.
- [x] `CustomersViewModel` (daftar, cari, pilih), `CustomerPanelViewModel`
  (detail, terima pembayaran, alokasi manual), `CustomerFormViewModel`.
- [x] Layar `/pelanggan`, `/pelanggan/:id`, kuitansi
  `/pelanggan/kuitansi/:id`; menu *Pelanggan* aktif.
- [x] Kuitansi: struk (`ReceiptContent`) dan A5 PDF; cetak, bagikan.
- [x] Import CSV/XLSX (pemilih berkas, laporan baris ditolak).
- [x] Master data: tab *Grup pelanggan*.
- [x] Kasir: `PayMode.credit`, panel kredit 1.5b, pemilih pelanggan.
- [x] Riwayat: lencana *Belum lunas*, rincian pelanggan & sisa, retur
  memotong piutang; struk nota kredit.
- [x] i18n ID + EN.
- [x] Tes VM dan widget (desktop, ponsel 360 px).

## 5 · Selesai

- [x] Review subagent; perbaiki temuan Critical/Important.
- [x] Uji manual di Xvfb; simpan tangkapan layar.
- [x] Spec Status & gap, README spec, CHANGELOG 0.17.0, versi `0.17.0+18`.
- [x] PR, CI hijau, squash merge, cek rilis.
