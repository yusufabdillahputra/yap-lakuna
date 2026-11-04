# F1-13 · Pelanggan & piutang

- **Fase:** 1
- **Status:** Rilis v0.17.0
- **Layar desain:** 1.20 *Pelanggan & piutang*, 1.20b *Kuitansi pembayaran
  piutang*, 1.5b *Kredit / piutang* (terang + gelap) di kanvas
  [Desain UI Lakuna](https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525),
  plus tab *Grup pelanggan* di Master data 1.17.
- **Acuan Storeku:** `docs/superpowers/specs/2026-11-02-f1-13-pelanggan-piutang-design.md`
  (aturan v0.16.0 Storeku disalin di sini; perbedaan dicatat di *Beda
  dengan Storeku*).

## Tujuan

Toko mencatat pelanggan tetap, memberi kredit dengan batas, dan menerima
pembayaran piutang yang dialokasikan ke nota. Saldo piutang selalu dihitung
dari dokumen, tidak pernah disimpan sebagai angka yang diubah-ubah.

## Lingkup v0.17.0

**Termasuk**
- Layar 1.20 `/pelanggan`: daftar pelanggan (nama, HP, grup, piutang), cari,
  ringkasan total piutang dan jumlah nota terlambat, tambah/ubah/hapus
  pelanggan, panel pelanggan (limit, piutang, sisa limit), daftar nota
  belum lunas, form *Terima pembayaran* dengan alokasi otomatis (nota
  terlama dulu) atau manual, dan riwayat pembayaran.
- Kuitansi 1.20b: pratinjau A5 dan struk thermal, *Cetak* (printer struk)
  dan *Bagikan PDF* (A5 atau struk). Cetak ulang dari riwayat pembayaran
  diberi tanda *SALINAN*.
- Grup pelanggan (nama + tempo standar) di Master data, juga dibuat
  otomatis dari form pelanggan dan import.
- Kredit di Kasir (1.5b) untuk nota retail: pilih pelanggan, DP tunai,
  jatuh tempo, cek limit.
- Retur nota kredit memotong piutang dulu; void ditolak bila nota sudah
  menerima pembayaran piutang.
- Import pelanggan dari CSV atau XLSX.

**Tidak termasuk**
- Kredit untuk bagian split bill F&B (gap; open bill dirilis v0.30.0, lihat F1-13b).
- Memilih pelanggan dari kepala pesanan Kasir dan harga grosir per grup
  (layar 1.4b, gap).
- Persetujuan PIN untuk melewati limit (gap; limit dikunci).
- Poin dan membership (Fase 3).
- Batal/ubah pembayaran piutang (gap).

## Desain UI

### 1.20 Pelanggan & piutang
- Kepala: *Pelanggan & piutang*, subjudul "N pelanggan · piutang dicatat
  per nota", tombol *Import Excel* dan *+ Pelanggan* (keduanya butuh
  `customers:manage`).
- Kiri: cari "Cari nama / HP", tabel Pelanggan (nama + HP) · Grup ·
  Piutang, lalu kartu kuning *Total piutang* "N pelanggan · M lewat jatuh
  tempo".
- Kanan (pelanggan terpilih): nama, "Grup X · pelanggan sejak Mar 2026",
  *Ubah data*; tiga petak *Limit kredit*, *Piutang* (kuning), *Sisa limit*.
- *Terima pembayaran* (butuh `debts:manage`): Jumlah diterima, Metode
  (Tunai / Transfer bank / QRIS statis), Tanggal; tabel nota belum lunas
  (Nota + tanggal, Jatuh tempo + lencana *Terlambat*, Total, Sisa,
  Alokasi, baris Total); catatan "Alokasi otomatis ke nota paling lama
  dulu. Setelah disimpan, sisa piutang X Rp …"; *Atur alokasi manual*
  (kolom alokasi jadi isian) dan *Simpan & cetak kuitansi*.
- *Riwayat pembayaran*: nomor BP, tanggal, metode, jumlah, buka kuitansi.
- Lebar < 1000 px: panel pelanggan dibuka sebagai halaman
  `/pelanggan/:id`.

### Form pelanggan (dialog)
Nama*, No. HP, Alamat, Grup (pilih atau ketik baru), Limit kredit (Rp,
0 = tidak boleh kredit), Catatan. *Hapus pelanggan* hanya bila piutang 0.

### 1.20b Kuitansi
- Breadcrumb Pelanggan › nama › Kuitansi BP-…, judul *Pembayaran piutang
  tersimpan*, subjudul "Rp X dari N dialokasikan ke M nota", lencana
  *Tersimpan*, *Kembali ke pelanggan*.
- Pratinjau A5: logo/nama toko, cabang, alamat, *KUITANSI* + nomor,
  Telah terima dari, Uang sejumlah (terbilang, miring), Untuk pembayaran
  "Piutang N nota", Metode; tabel Nota · Sisa sebelum · Dibayar; kota dan
  tanggal; kotak jumlah; nama kasir; sisa piutang setelah pembayaran.
- Pratinjau struk 58/80 mm dari mesin struk 1.12.
- Panel *Kuitansi*: Format A5/PDF atau Struk, *Tampilkan rincian per
  nota*, *Tampilkan sisa piutang*, *Kota pada tanda tangan* (bawaan kota
  cabang), *Cetak*, *Bagikan PDF*.

### 1.5b Kredit di Kasir
- Tombol *Kredit / piutang* di daftar metode (hanya dengan
  `debts:manage`).
- Panel: pemilih pelanggan (cari nama/HP, sisa limit, lencana *Lewat
  tempo*), tiga petak Limit / Piutang berjalan / Sisa limit, *Bayar
  sekarang (DP)* tunai (boleh 0), *Jatuh tempo* (bawaan hari ini + tempo
  standar grup, 14 hari tanpa grup), ringkasan Total nota − Dibayar
  sekarang = *Jadi piutang*, *Sisa limit setelah ini*, peringatan merah
  bila melebihi limit (tombol terkunci), *Simpan sebagai piutang*.

### Grup pelanggan (Master data)
Tab *Grup pelanggan*: nama, tempo standar (hari), jumlah pelanggan; tambah,
ubah, hapus (hanya bila tidak dipakai).

## Keputusan

1. **Piutang per nota** dihitung dari dokumen:
   `total − dibayar saat jual − Σ alokasi pembayaran − Σ pengurang piutang
   retur`, minimum 0. "Dibayar saat jual" = `sales.paid_amount` (bersih
   setelah kembalian). Hanya nota ber-`customer_id` dengan status terjual
   (`completed`, `partiallyReturned`, `returned`); nota void tidak dihitung.
   Nota lunas lama (`paid_amount = total`) otomatis bernilai 0.
2. **Kredit di Kasir** (`checkoutSale` dengan `credit`): pelanggan wajib,
   DP tunai 0 ≤ DP < total (dicatat sebagai pembayaran tunai biasa, masuk
   laci), jatuh tempo ≥ hari ini (tanggal lokal cabang).
   `piutang berjalan + (total − DP) ≤ limit`; limit 0 = tidak boleh
   kredit. Nota tersimpan `completed` dengan `customer_id`, `due_on`,
   `paid_amount = DP`. Kredit butuh `debts:manage` di repositori.
3. **Retur nota kredit**: nilai retur memotong piutang nota itu dulu
   (`sale_returns.debt_reduction`), sisanya dikembalikan tunai/transfer.
   Bila seluruhnya memotong piutang, `refund_method = debt` dan sesi kasir
   tidak wajib. Retur tunai di rekap laci = `amount − debt_reduction`.
4. **Void nota kredit** ditolak bila nota sudah menerima alokasi
   pembayaran (`VoidBlock.debtPaid`).
5. **Pembayaran piutang** `debt_payments` (`party = customer`) bernomor
   `BP-<OUTLET>-<PERANGKAT>-<yymmdd>-NNNN` + `debt_payment_allocations`
   (`document_type = sale`). Jumlah > 0 dan ≤ total piutang pelanggan.
   Alokasi otomatis FIFO (nota terlama: `sold_at`, lalu nomor) atau manual
   (per nota ≤ sisa, jumlah alokasi = jumlah diterima, nota milik
   pelanggan). Tanggal bayar bawaan hari ini dan tidak boleh di masa depan.
   Tabel yang sama dipakai hutang supplier di F1-14 (`party = supplier`,
   `document_type = purchase`).
6. **Kas**: metode tunai dengan sesi kasir terbuka di perangkat ini
   menulis `cash_movements` masuk (`source = debt_payment`, catatan
   "Pembayaran piutang BP-…") dan `debt_payments.cash_session_id`. Tanpa
   sesi, dicatat sebagai kas toko (buku kas F1-15). Transfer dan QRIS
   tidak menyentuh laci.
7. **Kuitansi**: struk dari mesin struk 1.12 (`ReceiptContent`) dan A5 PDF
   (paket `pdf`). Terbilang rupiah di domain (`rupiahInWords`). Sisa
   piutang dan sisa sebelum per nota disimpan saat bayar
   (`debt_payments.balance_after`, `debt_payment_allocations.balance_before`)
   agar cetak ulang sama dengan cetakan pertama.
8. **Data pelanggan**: nama wajib (≤ 80); HP dinormalisasi (digit saja,
   awalan `+62`/`62` → `0`), 8–15 digit, unik per tenant bila diisi;
   limit ≥ 0; alamat ≤ 160, catatan ≤ 200. Hapus (soft delete) hanya bila
   piutang 0. Grup unik per tenant tanpa membedakan huruf besar/kecil,
   tempo 0–365 hari (bawaan 14).
9. **Import**: CSV atau XLSX dengan baris judul (`nama`, `hp`, `alamat`,
   `grup`, `limit`, `catatan`; nama kolom English `name`, `phone`,
   `address`, `group`, `credit_limit`, `note` juga diterima). HP yang
   sudah ada memperbarui pelanggan itu, hanya kolom yang terisi. Grup baru
   dibuat. Baris tidak valid dilewati dan dilaporkan nomor baris + alasan
   (enum, diterjemahkan).
10. **Izin**: menu *Pelanggan* untuk `customers:manage` **atau**
    `debts:manage`. Tambah/ubah/hapus/import butuh `customers:manage`;
    terima pembayaran dan kredit di Kasir butuh `debts:manage`. Dicek di
    UI, repositori aplikasi, dan lapisan data (aktor staf aktif outlet
    dengan izin itu, pola F1-12).
11. **Terlambat** bila jatuh tempo < hari ini (lokal cabang) dan sisa > 0.
12. **Riwayat 1.14**: nota kredit yang masih bersisa berlencana *Belum
    lunas*; rincian menampilkan pelanggan, jatuh tempo, dan sisa piutang.
    Struk nota kredit memuat baris *Piutang* dan *Jatuh tempo*.
13. **Rekap sesi**: baris *Penjualan kredit* (Σ bagian piutang nota sesi)
    dan *Terima piutang tunai* masuk lewat gerakan kas.

## Beda dengan Storeku

- Storeku menyimpan grup pelanggan dari F1-09; Lakuna membangunnya di sini
  dengan *tempo standar* sesuai desain 1.5b.
- Lakuna menyimpan `balance_before`/`balance_after` agar kuitansi cetak
  ulang tidak berubah (gap Storeku).
- Lakuna menambah kuitansi A5 sesuai desain 1.20b (Storeku hanya struk).
- Alasan baris import dilewati berupa enum + terjemahan (gap Storeku).
- Lapisan data memeriksa izin aktor, bukan hanya keanggotaan outlet (gap
  Storeku).

## Data

**Tabel baru**
- `customer_groups`: `tenant_id`, `name`, `term_days`, kolom sync baku.
- `customers`: `tenant_id`, `customer_group_id?`, `name`, `phone?`,
  `address?`, `note?`, `credit_limit`, kolom sync baku. Indeks
  (`tenant_id`, `phone`).
- `debt_payments`: `tenant_id`, `outlet_id`, `device_id`, `staff_id`,
  `party` (`customer`/`supplier`), `customer_id?`, `supplier_id?`,
  `number`, `amount`, `method?` (`PaymentMethod`, pelanggan),
  `funding_source?` (F1-14), `paid_on`, `cash_session_id?`,
  `balance_after`, `note?`.
- `debt_payment_allocations`: `debt_payment_id`, `document_type`
  (`sale`/`purchase`), `sale_id?`, `purchase_id?`, `amount`,
  `balance_before`.

**Kolom baru**: `sales.customer_id?`, `sales.due_on?`,
`sale_returns.debt_reduction` (bawaan 0).

**Enum baru**: `DebtParty`, `DebtDocumentType`.

Semua tulis lewat `LakunaStore.write` + `SyncTx`. Migrasi `pelanggan`.

## Pengujian

- **Domain**: piutang nota, normalisasi & validasi pelanggan, cek limit
  kredit, alokasi FIFO dan validasi manual, terlambat, terbilang, nomor
  `BP-`, parser import (CSV dan baris tabel).
- **Data**: simpan/ubah/hapus pelanggan (HP unik, hapus ditolak bila
  berpiutang); grup; checkout kredit (DP, limit, jatuh tempo, izin);
  piutang per pelanggan; bayar FIFO dan manual, kas laci vs kas toko;
  retur nota kredit memotong piutang; void ditolak setelah dibayar; import
  CSV/XLSX.
- **Aplikasi**: repositori lokal (izin), view model daftar/panel/bayar,
  kredit di Kasir, widget alur desktop (pelanggan baru → kredit di Kasir →
  terima pembayaran → kuitansi) dan ponsel 360 px.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Pelanggan, grup, piutang per nota, terima pembayaran, kuitansi, kredit di Kasir, import | 1.20, 1.20b, 1.5b | Rilis v0.17.0 | Selesai. |
| Riwayat *Belum lunas*, retur memotong piutang, rekap sesi *Penjualan kredit* | 1.14, 1.3b | Rilis v0.17.0 | Selesai. |
| Tab *Grup pelanggan* di Master data | 1.17 | Rilis v0.17.0 | Tampil bila staf punya `customers:manage` (Master data sendiri butuh `products:manage`); grup juga bisa dibuat dari form pelanggan. |
| Kuitansi A5 & thermal | 1.20b | Rilis v0.17.0 | Terbilang selalu Bahasa Indonesia (dokumen hukum); kota bawaan = bagian terakhir alamat cabang. |
| Kredit *Tutup & bayar* open bill F&B | 1.5b | Rilis v0.30.0 | Lihat [F1-13b](2026-11-04-f1-13b-kredit-open-bill-design.md). |
| Kredit bagian split bill F&B | 1.5b | Belum | Butuh pelanggan per bagian tamu. |
| Pilih pelanggan di kepala pesanan | 1.4b | Rilis v0.29.0 | [F1-04d](2026-11-04-f1-04d-pelanggan-nota-tersimpan-design.md) |
| Harga grosir per grup pelanggan | 1.4b | Belum | Grup belum punya harga (butuh model harga per grup). |
| Persetujuan PIN melewati limit | Teks peringatan 1.5b | Limit dikunci | Pakai dialog persetujuan F1-11. |
| Batal pembayaran piutang | — | Belum | Void pembayaran + jurnal balik kas. |
| Nomor baris import saat berkas punya baris kosong | — | Bergeser | Bawa nomor baris asli dari CSV/XLSX (`row@r`). |
| Piutang dihitung dari semua nota kredit pelanggan | — | Dipecah per 500 id | Indeks/ringkasan saat data Fase 2 membesar. |
| Pembayaran tunai bertanggal mundur | — | Kas toko, tidak masuk laci hari ini | Buku kas F1-15. |

## Kriteria selesai

- Pelanggan dengan limit bisa berbelanja kredit dari Kasir; nota tampil
  *Belum lunas* di Riwayat.
- Piutang tampil per nota dengan status terlambat; pembayaran dialokasikan
  dan kuitansi tercetak/terbagi sebagai PDF.
- Retur dan void nota kredit konsisten dengan piutang.
- Layar jalan di desktop, tablet, dan ponsel 360 px tanpa luapan.
