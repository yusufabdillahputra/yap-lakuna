# F1-16c — Umur piutang & hutang di Laporan

- **Status:** Rilis v0.82.0
- **Layar:** 1.24 *Laporan*, tab **Piutang & hutang**.
- **Acuan:** gap [F1-14](2026-11-04-f1-14-supplier-hutang-design.md)
  *Umur hutang* dan tab Piutang & hutang
  [F1-16](2026-11-04-f1-16-laporan-design.md). Storeku F1-16 belum punya
  umur piutang/hutang.

## Tujuan

Tab Piutang & hutang hanya memisahkan *lewat tempo* dan *belum*. Pemilik
perlu tahu seberapa lama uang tertahan: piutang yang lewat 90 hari jauh
lebih berisiko daripada yang baru lewat seminggu, dan hutang supplier yang
lama tertunggak bisa merusak hubungan dengan pemasok. Laporan umur
(*aging*) adalah laporan standar akuntansi untuk keputusan menagih dan
membayar.

## Aturan

1. Setiap **nota** yang masih bersisa (nota jual kredit pelanggan, nota
   beli berhutang ke supplier) masuk satu kelompok umur menurut hari lewat
   jatuh tempo pada tanggal hari ini cabang:
   - *Belum jatuh tempo* — jatuh tempo hari ini atau nanti, atau tanpa
     jatuh tempo;
   - *Lewat 1–30 hari*, *Lewat 31–60 hari*, *Lewat 61–90 hari*;
   - *Lewat > 90 hari*.
   Hari lewat = selisih tanggal kalender (jatuh tempo kemarin = 1 hari),
   sama dengan aturan *lewat tempo* yang sudah ada (`isOverdue`).
2. Tab Piutang & hutang menampilkan dua tabel baru: **Umur piutang**
   (sebelum tabel per pelanggan) dan **Umur hutang** (sebelum tabel per
   supplier). Kolom: Umur, Nota terbuka, Sisa; lima baris kelompok (nol
   tetap tampil) dan baris **Total** tebal. Tanpa sisa sama sekali:
   pesan kosong yang sama dengan tabel per pelanggan / supplier.
3. Total tabel umur sama dengan kartu *Piutang pelanggan* / *Hutang
   supplier*: hanya pelanggan dan supplier yang tampil di tabel per
   pelanggan / supplier (belum dihapus) yang dihitung.
4. Unduhan PDF/Excel tab ini mendapat bagian *Umur piutang* dan *Umur
   hutang* (Nota terbuka, Sisa) sebelum daftar per pelanggan / supplier.
   Bagian tanpa sisa sama sekali tidak ditulis di unduhan (di layar tampil
   pesan kosong).
6. Kartu *Piutang jatuh tempo* dihitung dari data yang sama dengan umur
   (sisa lewat tempo pelanggan di daftar), jadi kartu = jumlah kelompok
   *Lewat …*.
5. Catatan di bawah tab: *Umur dihitung dari jatuh tempo tiap nota sampai
   hari ini; nota tanpa jatuh tempo masuk Belum jatuh tempo.*

## Rancangan teknis

- `lakuna_domain` (`receivable.dart`): `enum AgingBucket` dan
  `agingBucketOf(dueOn, today)`; `Aging` (nilai + jumlah nota per
  kelompok, `total`, `count`, `Aging.of(docs, today)`), murni dan diuji.
- `lakuna_data`: `customersWithReceivables` (customers.dart) dan
  `suppliersWithPayables` (suppliers.dart) mengembalikan daftar beserta
  peta nota bersisa dari **satu** pembacaan (`listCustomers` /
  `loadSuppliersOverview` memakainya). `loadDebtReport` menghitung daftar,
  kartu jatuh tempo, dan umur dari data itu; `DebtReport` mendapat
  `receivableAging` dan `payableAging`.
- UI `reports_extra_view.dart` (`_Debts`) dan `reportTable` debts di
  `report_labels.dart`. l10n baru ID + EN.

## Tes

- Domain: batas kelompok (hari ini, kemarin, 30, 31, 60, 61, 90, 91 hari,
  tanpa jatuh tempo), penjumlahan nilai dan jumlah nota.
- Data: laporan dengan nota kredit dan nota beli bertanggal jatuh tempo
  berbeda; total umur = kartu; pelanggan terhapus tidak dihitung.
- Widget: tabel umur di tab Piutang & hutang 1280 / 360 px; tabel ekspor.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Umur piutang & hutang per kelompok | 1.24 | Rilis v0.82.0 | Tab Piutang & hutang + unduhan PDF/Excel. |
| Umur per pelanggan / supplier (kolom kelompok di tabel per nama) | — | Rilis v0.147.0 | [F1-16g](2026-11-27-f1-16g-umur-per-nama-design.md); kolom *Lewat tempo* diganti kolom kelompok. |
| Kelompok umur bisa diatur (mis. 7/14/30 hari) | — | Belum | Tetap 30/60/90. |
| Umur pada tanggal lampau | — | Belum | Posisi hari ini saja, seperti tab Piutang & hutang. |
