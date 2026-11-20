# F1-13h — Kredit untuk bagian terakhir split bill

Tanggal: 2026-11-20 · Modul: F1-13 Pelanggan & piutang + F1-10 Split bill
(layar 1.5b, 1.9) · Rilis: v0.134.0

## Masalah

Di split bill F&B, setiap tamu membayar bagiannya sendiri. Bila satu tamu
langganan ingin *bayar nanti*, kasir tidak bisa mencatatnya sebagai
piutang: pilihan **Kredit / piutang** hanya ada di *Tutup & bayar* utuh
(F1-13b). Gap *Kredit bagian split bill* di F1-13 / F1-13b / F1-10, satu-
satunya gap Fase 1 yang masih terbuka di STATUS-JEDA.

Storeku belum membangun gap ini, jadi tidak ada aturan yang disalin.

## Pilihan rancangan

1. **Kredit hanya untuk bagian terakhir (dipilih).** Satu nota tetap satu
   pelanggan dan satu piutang. Tamu lain membayar dulu; bagian terakhir
   menutup bill sebagai nota kredit. Tanpa tabel baru, piutang, retur,
   void, kuitansi, dan laporan memakai aturan F1-13 tanpa perubahan.
2. Kredit per bagian dengan pelanggan berbeda: butuh dokumen piutang per
   bagian (tabel baru + alokasi pembayaran piutang per bagian). Ditunda
   sampai ada permintaan; dicatat sebagai gap.

Pilihan 1 menutup kasus umum (satu tamu langganan *ngebon*) tanpa
mengubah model data.

## Aturan

1. Pilihan **Kredit / piutang** muncul di layar Bayar bagian split untuk
   staf `debts:manage` hanya bila bagian itu **bagian terakhir**: tidak ada
   pembayaran QRIS yang menunggu, semua bagian tamu lain yang bertagihan
   sudah lunas, dan (mode nominal bebas) nominalnya sama dengan sisa
   tagihan. Mode per item juga harus tanpa porsi yang belum dibagi.
2. Aturan kredit F1-13 berlaku pada **tagihan bagian itu**: pelanggan
   wajib, DP tunai 0 ≤ DP < tagihan bagian, jatuh tempo ≥ hari ini,
   `piutang berjalan + (tagihan bagian − DP) ≤ limit`.
3. Pelanggan kredit harus sama dengan pelanggan bill bila bill sudah punya
   pelanggan (`BillCustomerMismatch`, sama dengan F1-13b).
4. DP tunai disimpan sebagai pembayaran bagian (label tamu) di sesi kasir
   ini. Bill langsung selesai seperti bagian terakhir biasa: nomor nota,
   stok, HPP, tarif beku, dengan `customer_id` / `customer_name` pelanggan
   kredit, `due_on`, dan `paid_amount` = Σ pembayaran bagian lain (bersih
   kembalian) + DP. Sisa piutang = tagihan bagian − DP.
5. Bukan bagian terakhir → ditolak `SplitInvalid(creditNotLast)`;
   `payments` diisi bersama `credit` → ditolak; tanpa `debts:manage` →
   ditolak.
6. Piutang, pembayaran piutang, retur, void, kuitansi, dan laporan memakai
   aturan F1-13 tanpa perubahan (nota muncul di *Belum lunas* dan detail
   pelanggan).
7. Layar Bayar bagian yang bukan terakhir tidak menampilkan pilihan
   Kredit (tetap seperti sekarang).

## Rancangan teknis

- `paySplitPart(..., credit: SaleCredit?)`; helper `_isLastPart(split,
  label, due)`; `checkSaleCredit(w, scope, credit, due, now)`.
- `_completeBill(..., credit, customer, credited)`: `paid_amount = total −
  credited` (F1-13b: `credited = total − DP`, jadi tetap `DP`).
- `CashierRepository.payBillPart(..., credit:)`, izin `debts:manage`
  dicek di repositori dan data.
- `CashierViewModel.canSellOnCredit`: untuk bagian, benar bila
  `bill.split` menyatakan bagian ini terakhir. `_payPart` mengirim
  `SaleCredit` dan pembayaran kosong di mode Kredit.

## Pengujian

- Data: kredit bagian terakhir (mode rata, per item, nominal bebas) →
  nota selesai, `paid_amount`, `due_on`, pelanggan, piutang = tagihan
  bagian − DP, DP masuk sesi; bukan bagian terakhir, QRIS menunggu,
  pembayaran + kredit, tanpa izin, melebihi limit, pelanggan bill berbeda
  ditolak; F1-13b tetap `paid_amount = DP`.
- VM: `canSellOnCredit` bagian terakhir vs bukan; bayar kredit bagian
  mengirim `SaleCredit`.
- Widget: split 2 tamu, tamu A tunai, tamu B → Kredit → pelanggan →
  Simpan → struk; tamu A tidak melihat Kredit.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Kode | Catatan |
| --- | --- | --- | --- |
| Kredit bagian terakhir split bill | 1.5b, 1.9 | Rilis v0.134.0 | Satu pelanggan per nota. |
| Kredit beberapa bagian / pelanggan berbeda per bagian | 1.5b | Belum | Butuh dokumen piutang per bagian (tabel baru + alokasi). |
