# F1-13b · Kredit untuk open bill F&B

- **Fase:** 1
- **Status:** Dikerjakan
- **Layar desain:** 1.5b *Bayar: Kredit / piutang* (dipakai juga dari bill
  Meja / Take away, 1.7–1.9).
- **Acuan:** F1-13 aturan 1–4 (kredit retail), F1-10 *Tutup & bayar*.
- **Menutup gap:** F1-13 "Kredit open bill / split bill F&B" (bagian open
  bill; split bill tetap gap).

## Tujuan

Pelanggan langganan warung/kafe bisa makan dulu dan bayar belakangan:
kasir menutup bill meja atau take away sebagai nota kredit, sama seperti
kredit di Kasir retail.

## Aturan

1. Pilihan **Kredit / piutang** muncul di layar Bayar bill (*Tutup &
   bayar*) untuk staf `debts:manage`, sama dengan retail. Tidak muncul
   saat membayar bagian split bill atau setelah bill menerima pembayaran
   sebagian (split terkunci).
2. Aturan kredit F1-13 berlaku utuh: pelanggan wajib, DP tunai
   0 ≤ DP < total bill (setelah service & PB1 dan pembulatan), jatuh
   tempo ≥ hari ini, `piutang berjalan + (total − DP) ≤ limit`.
3. Nota bill selesai seperti *Tutup & bayar* biasa (nomor nota, stok,
   HPP, service & PB1 beku, sesi kasir) dengan `customer_id`,
   `customer_name` = nama pelanggan (menggantikan nama take away),
   `due_on`, dan `paid_amount = DP`. DP tunai masuk laci sebagai
   pembayaran tunai.
4. Piutang, retur, void, dan pembayaran piutang memakai aturan F1-13 tanpa
   perubahan (nota F&B kredit muncul di *Belum lunas* dan detail
   pelanggan).
5. Lapisan data: `payOpenBill(..., credit:)`; `payments` harus kosong bila
   `credit` diisi; butuh `debts:manage`.

## Pengujian

- Data: bill kredit dengan DP → `paid_amount`, `due_on`, pelanggan,
  piutang pelanggan bertambah, stok bergerak; melebihi limit ditolak;
  `payments` + `credit` ditolak; staf tanpa `debts:manage` ditolak.
- View model: kredit tersedia di mode bill (bukan bagian split), checkout
  bill mengirim `SaleCredit`.
- Widget: bill → Bayar → Kredit → pilih pelanggan → Simpan.

## Status & gap

| Topik | Desain | Kode | Catatan |
| --- | --- | --- | --- |
| Kredit *Tutup & bayar* open bill | 1.5b | Dikerjakan | |
| Kredit bagian split bill | 1.5b | Belum | Bagian split dibayar per tamu; kredit per tamu butuh pelanggan per bagian. |
