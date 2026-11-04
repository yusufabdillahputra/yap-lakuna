# Rencana F1-15 · Pengeluaran (v0.19.0)

Spec: `docs/superpowers/specs/2026-11-04-f1-15-pengeluaran-design.md`

## 1. Model & migrasi

- [ ] `expense_category.spy.yaml`, `expense.spy.yaml` di
      `lakuna_server/lib/src/expenses/`; `MediaKind.expenseReceipt`.
- [ ] `serverpod generate`, `serverpod create-migration --tag expense`.

## 2. Domain (`lakuna_domain`)

- [ ] `expense.dart`: `ExpenseLimits`, `ExpenseIssue`, `validateExpense`,
      `validateExpenseCategoryName`, `expenseNumber`, `ExpensePeriod` +
      `expensePeriodRange`.
- [ ] Tes.

## 3. Data (`lakuna_data`)

- [ ] `expenses.dart`: jenis bawaan, daftar/simpan/hapus jenis, catat
      (kas toko/bank/laci + foto), daftar + ringkasan per periode, rincian,
      batal (balik kas laci), foto nota.
- [ ] `recordCashMovement` + opsi pengeluaran dari sesi kasir
      (`recordDrawerExpense`), label gerakan kas → jenis.
- [ ] Tes.

## 4. Aplikasi

- [ ] `ExpensesRepository` + lokal + palsu.
- [ ] VM daftar (periode, cari, per jenis, ekspor), form, rincian (batal),
      jenis pengeluaran (master data).
- [ ] Layar `/pengeluaran`, menu, dialog form (sempit), dialog rincian.
- [ ] Master data: tab *Jenis pengeluaran*.
- [ ] Kas laci: sakelar *Catat juga sebagai pengeluaran*, lencana di rekap.
- [ ] i18n ID + EN; tes VM dan widget 1440/800/360.

## 5. Selesai

- [ ] Review subagent; perbaiki Critical/Important.
- [ ] Uji manual Xvfb + tangkapan layar.
- [ ] Spec Status & gap, README spec, CHANGELOG 0.19.0, versi `0.19.0+20`.
- [ ] PR, CI hijau, squash merge, cek rilis.
