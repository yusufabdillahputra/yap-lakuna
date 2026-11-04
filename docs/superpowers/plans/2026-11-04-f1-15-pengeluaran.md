# Rencana F1-15 · Pengeluaran (v0.19.0)

Spec: `docs/superpowers/specs/2026-11-04-f1-15-pengeluaran-design.md`

## 1. Model & migrasi

- [x] `expense_category.spy.yaml`, `expense.spy.yaml` di
      `lakuna_server/lib/src/expenses/`; `MediaKind.expenseReceipt`.
- [x] `serverpod generate`, `serverpod create-migration --tag expense`.

## 2. Domain (`lakuna_domain`)

- [x] `expense.dart`: `ExpenseLimits`, `ExpenseIssue`, `validateExpense`,
      `validateExpenseCategoryName`, `expenseNumber`, `ExpensePeriod` +
      `expensePeriodRange`.
- [x] Tes.

## 3. Data (`lakuna_data`)

- [x] `expenses.dart`: jenis bawaan, daftar/simpan/hapus jenis, catat
      (kas toko/bank/laci + foto), daftar + ringkasan per periode, rincian,
      batal (balik kas laci), foto nota.
- [x] Opsi pengeluaran dari sesi kasir memakai `recordExpense` (kas laci),
      label gerakan kas → jenis (`expenseLabelsForSession`).
- [x] Tes.

## 4. Aplikasi

- [x] `ExpensesRepository` + lokal + palsu.
- [x] VM daftar (periode, cari, per jenis, ekspor), form, rincian (batal),
      jenis pengeluaran (master data).
- [x] Layar `/pengeluaran`, menu, dialog form (sempit), dialog rincian.
- [x] Master data: tab *Jenis pengeluaran*.
- [x] Kas laci: sakelar *Catat juga sebagai pengeluaran*, lencana di rekap.
- [x] i18n ID + EN; tes VM dan widget 1440/800/360.

## 5. Selesai

- [x] Review subagent; perbaiki Critical/Important.
- [x] Uji manual Xvfb + tangkapan layar.
- [x] Spec Status & gap, README spec, CHANGELOG 0.19.0, versi `0.19.0+20`.
- [x] PR, CI hijau, squash merge, cek rilis.
