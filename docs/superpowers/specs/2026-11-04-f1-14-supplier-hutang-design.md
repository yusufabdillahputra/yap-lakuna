# F1-14 · Supplier & hutang

- **Fase:** 1
- **Status:** Dalam pengerjaan (v0.18.0)
- **Layar desain:** 1.21 *Supplier & hutang · desktop* di kanvas
  [Desain UI Lakuna](https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525).
- **Acuan Storeku:** `docs/superpowers/specs/2026-11-02-f1-14-supplier-hutang-design.md`
  (aturan disalin; perbedaan di *Beda dengan Storeku*).
- **Bergantung pada:** F1-12 Pembelian (hutang per pembelian), F1-13 (tabel
  `debt_payments` dan `debt_payment_allocations`, aturan alokasi).

## Tujuan

Pemilik atau manajer melihat hutang ke setiap supplier dan jatuh tempo
terdekat, lalu mencatat pembayaran hutang yang dialokasikan ke pembelian.
Uang yang keluar dari laci ikut tercatat di sesi kasir.

## Lingkup v0.18.0

Termasuk:

- Master supplier lengkap: nama, kontak (nama orang), no. telepon,
  kategori/keterangan barang, alamat, tempo standar (hari), catatan;
  tambah, ubah, hapus (ditolak bila masih berhutang).
- Daftar supplier dengan hutang, cari nama/telepon/kategori, kartu *Total
  hutang* + *Jatuh tempo terdekat* + jumlah pembelian terlambat.
- Panel supplier: kontak, tempo standar, tabel pembelian belum lunas
  (jatuh tempo, total, sisa, kolom *Bayar*), form bayar hutang (jumlah,
  sumber dana, no. bukti transfer, tanggal, catatan, foto bukti), teks
  sisa hutang setelah simpan, catatan kas laci, riwayat pembayaran, dan
  *Riwayat pembelian* (semua pembelian supplier, membuka detail
  pembelian).
- Alokasi otomatis ke jatuh tempo terdekat dulu, atau manual per
  pembelian (sama seperti piutang).
- Pembelian 1.19: jatuh tempo bawaan = tanggal + tempo standar supplier;
  hutang pembelian dikurangi pembayaran hutang; tombol *Bayar hutang* di
  detail pembelian membuka supplier itu.
- Rekap sesi kasir: bayar hutang dari laci tampil sebagai kas keluar
  berlabel *Bayar hutang supplier*.

Tidak termasuk (gap):

- Import supplier dari Excel.
- Batal/void pembayaran hutang.
- Pengingat jatuh tempo (notifikasi).
- Laporan umur hutang (F1-16).

## Desain UI

### 1.21 Supplier & hutang

- Judul *Supplier & hutang*, subjudul "N supplier", tombol *+ Supplier*.
- Kiri: cari supplier; tabel Supplier (nama, kategori · telepon) dan
  Hutang (tebal bila > 0); kartu kuning *Total hutang*, "Jatuh tempo
  terdekat: dd/MM" dan jumlah pembelian terlambat.
- Kanan (≥ 1000 px) atau halaman `/supplier/:id` (lebih sempit): judul
  "<nama> · bayar hutang", "Kontak: <kontak> · tempo standar N hari",
  tombol *Riwayat pembelian* dan *Ubah data*.
  - Form: *Jumlah dibayar* (tombol *Lunasi semua*), *Sumber dana* (Kas
    toko / Kas laci / Rekening bank), *No. bukti transfer* (opsional),
    *Tanggal bayar*, *Catatan*.
  - Tabel pembelian belum lunas: nomor + tanggal, jatuh tempo (merah +
    *Terlambat* bila lewat), total, sisa, bayar (alokasi otomatis tampil;
    *Atur alokasi manual* membuat kolom bisa diisi). Baris total.
  - Info biru: "Setelah disimpan, sisa hutang ke <nama> Rp X (jatuh tempo
    dd/MM)." Bila kas laci: "Bayar dari kas laci akan tercatat sebagai uang
    keluar di sesi kasir yang sedang buka."
  - *Lampirkan foto bukti* (PNG/JPG/WebP ≤ 5 MB, kamera di ponsel) dengan
    pratinjau kecil dan tombol hapus; *Simpan pembayaran*.
  - Riwayat pembayaran: nomor `BH-…`, tanggal · sumber · no. bukti,
    jumlah, ikon foto bila ada bukti (membuka gambar).
  - Supplier tanpa hutang: "Tidak ada hutang ke supplier ini." dan form
    disembunyikan.
  - *Hapus supplier* di bawah.
- *Riwayat pembelian*: dialog daftar semua pembelian supplier (nomor,
  tanggal, total, sisa/status), ketuk membuka `/pembelian/:id`.

### Form supplier (dialog)

Nama*, Kontak, No. telepon, Kategori barang, Tempo standar (hari, 0–365,
bawaan 14), Alamat, Catatan.

## Keputusan

1. **Hutang per pembelian** = total − dibayar saat beli − alokasi
   pembayaran hutang − pengurang hutang retur beli, minimum 0. Draf tidak
   berhutang. Saldo tidak pernah disimpan sebagai angka (ledger).
2. **Hutang dihitung per tenant** (semua cabang), sama dengan piutang
   pelanggan. Supplier milik tenant.
3. **Pembayaran** memakai `debt_payments` dengan `party = supplier`,
   `supplier_id`, `funding_source`, nomor
   `BH-<OUTLET>-<PERANGKAT>-<yymmdd>-NNNN` (bayar hutang; piutang memakai
   `BP-`), `balance_after` = sisa hutang supplier setelahnya. Alokasi di
   `debt_payment_allocations` dengan `document_type = purchase`,
   `purchase_id`, `balance_before`.
4. **Alokasi otomatis** ke pembelian dengan jatuh tempo terdekat dulu
   (lalu tanggal beli, nomor). Pembelian tanpa jatuh tempo diurut paling
   akhir. Alokasi manual wajib berjumlah sama dengan uang dibayar dan
   tidak melebihi sisa tiap pembelian (aturan `validateDebtPayment`).
5. **Sumber dana**:
   - *Kas laci*: wajib ada sesi kasir terbuka di perangkat ini dan tanggal
     bayar = hari ini; menulis `cash_movements` keluar
     (`source = supplier_payment`) di sesi itu. Staf wajib punya
     `cash_movements:create`.
   - *Kas toko* dan *Rekening bank*: tidak menyentuh laci.
6. **Tanggal bayar** tidak boleh di masa depan.
7. **No. bukti transfer** opsional (≤ 60 karakter), boleh untuk sumber
   mana pun.
8. **Foto bukti** disimpan sebagai `media_files` (`kind = paymentProof`)
   dan ditautkan lewat `debt_payments.proof_media_id`.
9. **Izin**:
   - Menu *Supplier*: `suppliers:manage` **atau** `debts:manage`.
   - Tambah/ubah/hapus supplier: `suppliers:manage`.
   - Bayar hutang: `debts:manage` (+ `cash_movements:create` untuk laci).
   - Dicek di menu, layar, repositori aplikasi, dan lapisan data.
10. **Supplier**: nama wajib (≤ 120, sama dengan F1-12), unik per tenant tanpa membedakan huruf
    besar/kecil; telepon dinormalisasi seperti pelanggan (boleh kosong,
    tidak wajib unik karena satu sales bisa memegang beberapa supplier);
    tempo 0–365 hari; teks lain ≤ 120 (alamat ≤ 200, catatan ≤ 500).
11. **Hapus supplier** ditolak bila masih berhutang; pembelian lama tetap
    menampilkan namanya.
12. **Pembelian**: jatuh tempo bawaan = tanggal beli + tempo standar
    supplier (14 hari untuk supplier baru); bila staf sudah mengubah
    jatuh tempo, memilih supplier tidak menimpanya.
13. **Retur beli** memotong hutang yang tersisa setelah pembayaran;
    kelebihannya dikembalikan seperti F1-12.

## Beda dengan Storeku

- Nomor bayar hutang `BH-` (Storeku belum menetapkan nomor).
- Supplier di Lakuna punya kolom kontak dan alamat; Storeku hanya
  `category_note`.
- Hutang dihitung tenant-wide (Storeku per outlet belum ditetapkan).

## Data

- `suppliers` (+ migrasi `supplier`): `contact_name?`, `category?`,
  `address?`, `term_days` (int, default 14).
- `debt_payments` (+): `reference?`, `proof_media_id?` → `media_files`.
- Enum `MediaKind` (+) `paymentProof`.
- Tanpa tabel baru.

## Pengujian

- Domain: urutan alokasi hutang (jatuh tempo, tanpa jatuh tempo terakhir),
  validasi supplier, `purchaseDebt` dengan alokasi.
- Data: bayar sebagian dua pembelian, sisa hutang benar, `balance_after`,
  kas laci keluar di sesi (dan ditolak tanpa sesi / tanggal mundur), foto
  bukti tersimpan, izin, hapus supplier berhutang ditolak, retur beli
  setelah pembayaran, daftar pembelian memperhitungkan pembayaran.
- Aplikasi: VM daftar/panel/form; alur widget 1280 dan 360 px (tambah
  supplier, bayar, alokasi manual, laci tanpa sesi); tombol *Bayar hutang*
  di detail pembelian.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Master supplier, hutang per pembelian, bayar hutang, foto bukti | 1.21 | v0.18.0 | — |
| Import supplier | — | Belum | Pola import pelanggan. |
| Batal pembayaran hutang | — | Belum | Void + jurnal balik kas. |
| Umur hutang | — | Belum | F1-16 Laporan. |

## Kriteria selesai

- Hutang dari Pembelian tampil per supplier dengan jatuh tempo terdekat.
- Pembayaran dialokasikan ke pembelian, sisa hutang di Pembelian ikut
  berkurang, dan kas laci terpengaruh bila dipakai.
- Layar jalan di desktop, tablet, dan ponsel 360 px tanpa luapan.
