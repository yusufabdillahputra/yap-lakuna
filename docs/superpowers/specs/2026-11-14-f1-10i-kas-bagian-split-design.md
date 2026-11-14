# F1-10i · Kas per sesi untuk bagian split bill

- **Fase:** 1
- **Status:** Dalam pengerjaan v0.56.0
- **Layar:** 1.3 Sesi kasir (rekap laci, tutup sesi), 1.9 Split bill,
  1.14 Riwayat (batal nota).
- **Acuan:** F1-03 (rekap laci: tunai seharusnya), F1-10 (split bill, gap
  *Split bill: kas per sesi*), F1-11 (batal nota hanya di sesi nota).
- **Menutup gap:** F1-10 "Split bill: kas per sesi".

## Tujuan

Uang tunai bagian split bill masuk laci perangkat yang menerimanya, saat
itu juga. Selama ini tunai bagian baru dihitung ketika bill lunas, dan masuk
sesi perangkat yang menutup bill. Akibatnya rekap laci di tengah sesi kurang,
dan bila tamu A membayar di kasir K01 lalu tamu B di K02, seluruh tunai
tercatat di laci K02.

## Aturan

1. **Sesi per pembayaran.** Setiap baris `payments` mencatat
   `cash_session_id`, yaitu sesi kasir perangkat yang mencatat pembayaran
   itu. Ini berlaku untuk Kasir retail, bayar penuh open bill, bayar bagian
   split, dan QRIS bagian. QRIS *menunggu* mencatat sesi pembuatnya (untuk
   cek tutup sesi), lalu diganti sesi yang mengonfirmasi *Sudah terbayar*,
   karena uang baru diakui saat itu.
2. **Rekap laci** (tunai dan non-tunai penjualan di 1.3, tunai seharusnya,
   dan tutup sesi) menjumlahkan pembayaran lunas dengan `cash_session_id`
   sesi itu. Nota yang dibatalkan dan bill yang dihapus tidak dihitung.
   Bill split yang belum lunas tetap dihitung, sehingga laci di tengah sesi
   sudah memuat tunai bagian. Jumlah nota dan total penjualan tetap dihitung
   per nota, di sesi yang menutup nota.
3. **Data lama.** Pembayaran sebelum versi ini tidak punya sesi. Pembayaran
   itu dihitung di sesi notanya, sama seperti sebelumnya.
4. **Tutup sesi.** Sesi ditolak ditutup (`CashSessionHasOpenSplit`) hanya
   bila ada bill terbuka yang bagiannya dibayar atau menunggu di sesi ini,
   atau pembayaran lama tanpa sesi. Perangkat lain di cabang yang sama
   kini boleh menutup sesinya.
5. **Batal nota.** Nota hanya bisa dibatalkan di sesi yang menerima semua
   pembayarannya (`VoidBlock.session`). Batal nota mengembalikan uang dari
   laci sesi itu. Nota split yang bagiannya dibayar di perangkat lain
   memakai *Retur*, karena retur mencatat uang keluar di sesi yang
   mengembalikan. *Batalkan bill* split yang belum lunas juga ditolak
   (`BillPaidInOtherSession`) bila ada bagian lunas dari sesi lain.
6. **Pesan.** Pesan tutup sesi dan pesan *Void hanya di sesi nota* disesuaikan;
   pesan baru `diningErrorPaidOtherSession` untuk batal bill.

## Komponen

- Model: `Payment.cashSessionId` (`UuidValue?`, relasi `cash_sessions`,
  `column=cash_session_id`, indeks). Migrasi `kas-per-pembayaran`.
- Data: `insertPayments(cashSessionId:)`, insert QRIS menunggu, dan
  `confirmSplitPayment` mengisi sesi. `sessionSalesSummary` menghitung
  tunai dan non-tunai per pembayaran. `closeCashSession` membatasi cek
  bill split ke sesi itu. Pemeriksaan batal nota memeriksa sesi semua
  pembayaran.

## Pengujian

- Data:
  - Retail dan open bill mencatat sesi pembayaran.
  - Bayar bagian A tunai, lalu rekap laci sesi naik sebelum bill lunas.
  - Bagian A di perangkat 1 dan bagian B di perangkat 2: tunai masing-masing
    masuk sesinya, sedangkan jumlah dan total nota masuk sesi penutup.
  - Perangkat lain boleh menutup sesi, sesi penerima bagian tidak boleh.
  - QRIS menunggu yang dikonfirmasi di sesi lain dihitung di sesi
    konfirmasi.
  - Pembayaran lama tanpa sesi tetap dihitung di sesi notanya.
  - Batal nota ditolak bila ada bagian dari sesi lain.
- Flutter: rekap 1.3 tidak berubah tampilannya. Tes yang ada tetap lulus.
- Uji manual Xvfb: split meja dua tamu, bayar A tunai, lalu buka Sesi kasir.
  Tunai penjualan sudah memuat bagian A.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Tunai bagian split masuk sesi penerima | — | Dalam pengerjaan v0.56.0 | `payments.cash_session_id`. |
| Retur nota split lintas perangkat | — | Catatan | Retur tetap dicatat di sesi yang mengembalikan uang. |
