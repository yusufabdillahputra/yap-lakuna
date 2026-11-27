# F1-16h — Pelunasan piutang per metode dan rekening di Laporan

Tanggal: 2026-11-27 · Modul: F1-16 Laporan (1.23, tab **Ringkasan**) ·
Gap 12 di `docs/superpowers/GAP-FASE1.md`, gap 91 di STATUS-JEDA ·
Rilis: v0.148.0

## Masalah

F1-13i mencatat rekening tujuan pada pembayaran piutang transfer, tetapi
Laporan tidak membacanya. Kartu *Penjualan per metode bayar* (dengan rincian
transfer per rekening F1-05g) hanya membaca nota penjualan. Pelunasan
piutang yang masuk lewat transfer atau QRIS tidak muncul di laporan
mana pun. Pelunasan tunai hanya muncul sebagai kas masuk di tab Kas & sesi.

Akibatnya, saat mencocokkan mutasi rekening BCA, pemilik melihat uang masuk
yang tidak ada di laporan.

## Aturan

1. Tab **Ringkasan**, di kartu *Penjualan per metode bayar*, mendapat bagian
   **Pelunasan piutang** di bawah catatan kartu. Bagian ini hanya tampil
   bila ada pelunasan pada periode itu.
   - Baris judul: *Pelunasan piutang* dan totalnya.
   - Satu baris per metode, urut terbesar. Pelunasan piutang hanya bisa
     Tunai, Transfer bank, atau QRIS statis (`debtPaymentMethods`).
   - Di bawah *Transfer bank*, rincian per rekening tujuan dengan format
     yang sama dengan F1-05g. *Tanpa rekening* selalu terakhir. Rincian
     tidak ditulis bila semua transfer tanpa rekening.
   - Catatan: *Pembayaran piutang pelanggan menurut tanggal bayar, di luar
     penjualan di atas. Pembayaran yang dibatalkan tidak dihitung.*
2. Yang dihitung adalah pembayaran piutang **pelanggan** di cabang ini:
   - tanggal bayar (`paidOn`) masuk periode laporan;
   - belum dibatalkan dan belum dihapus.
   Pembayaran hutang ke supplier (uang keluar) tidak dihitung.
3. Angka *Penjualan*, laba rugi, dan porsi metode bayar penjualan tidak
   berubah. Pelunasan bukan penjualan baru, karena nota kreditnya sudah
   dihitung pada tanggal jual.
4. Unduhan PDF/Excel tab Ringkasan mendapat bagian yang sama setelah
   *Penjualan per metode bayar*: baris tebal *Pelunasan piutang* dengan
   total, satu baris per metode, dan rincian rekening `· BCA 123`.
   Catatannya ikut ditulis.
5. Bagian ini tampil untuk semua yang boleh membuka Laporan
   (`reports:view`), sama dengan kartu metode bayar.

## Rancangan teknis

- `lakuna_domain` `report.dart`:
  - `ReportDebtPayment(method, amount, {transferAccount})`.
  - `DebtCollection` berisi `methods` (`List<(ReportPaymentMethod,
    Money)>`, urut terbesar), `total`, dan `transferAccounts`
    (`List<TransferAccountRow>`).
  - `debtCollection(List<ReportDebtPayment>)` membuat `DebtCollection`.
    Pengelompokan rekening memakai fungsi bersama dengan
    `transferByAccount` agar urutannya sama.
- `lakuna_data` `reports.dart`:
  - `ReportData.debtPayments` (bawaan kosong) dan
    `late final collections`.
  - `buildReport` membaca `DebtPayment` dengan kondisi: tenant, outlet,
    `party = customer`, `method != null`, `voidedAt`/`deletedAt` kosong,
    `paidOn` di `range.from..range.to`. `paidOn` adalah tanggal kalender,
    jadi tidak perlu konversi zona waktu.
- UI `_Methods` di `reports_view.dart` dan `reportTable` summary di
  `report_labels.dart`. Kunci l10n baru: `reportsDebtCollections`,
  `reportsDebtCollectionsNote`.

## Pengujian

- Domain: kelompok per metode, urutan, total, rincian rekening, dan
  rekening kosong saja yang tidak ditulis.
- Data: pelunasan transfer ke 2 rekening, tunai, dan QRIS di periode;
  pelunasan di luar periode, pelunasan yang dibatalkan, dan pembayaran
  hutang supplier tidak dihitung; penjualan bersih tidak berubah.
- Label ekspor: baris dan catatan; bagian tidak ditulis bila tidak ada
  pelunasan.
- Widget: bagian tampil di 1440 px dan 360 px tanpa luapan; tidak tampil
  tanpa pelunasan.
- Uji manual Xvfb: terima pelunasan transfer ke rekening, lalu buka
  Laporan.

## Status & gap

| Topik | Kode | Catatan |
| --- | --- | --- |
| Pelunasan piutang per metode dan rekening di Ringkasan | Rilis v0.148.0 | Layar dan unduhan. |
| Pembayaran hutang supplier per sumber dana di laporan | Belum | Sumber dana dicatat di F1-14, belum diringkas. |
