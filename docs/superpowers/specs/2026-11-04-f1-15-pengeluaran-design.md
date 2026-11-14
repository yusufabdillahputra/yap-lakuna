# F1-15 · Pengeluaran

- **Fase:** 1
- **Status:** Rilis v0.19.0
- **Layar desain:** 1.22 *Pengeluaran* (desktop), 1.3b *Kas laci* (opsi
  *Catat juga sebagai pengeluaran*), 1.17 *Master data › Jenis pengeluaran*
- **Acuan Storeku:** `docs/superpowers/specs/2026-11-02-f1-15-pengeluaran-design.md`

## Tujuan

Toko mencatat biaya operasional di luar pembelian barang dagang (sewa,
listrik, plastik, transport, gaji manual) per jenis, dari kas toko, kas
laci, atau rekening bank, dengan foto nota, supaya laba rugi (F1-16) akurat.

## Lingkup v0.19.0

Termasuk:

- Master data **Jenis pengeluaran** (tambah, ubah nama, hapus bila belum
  dipakai) dengan jenis bawaan.
- Layar **1.22 Pengeluaran**: cari, filter periode, tabel, panel *Per
  jenis*, form *Catat pengeluaran*, rincian + batal, ekspor Excel.
- **Kas laci** (1.3b): uang keluar bisa *dicatat juga sebagai
  pengeluaran* (jenis + foto nota), dengan lencana *Pengeluaran · jenis* di
  rekap sesi.

Tidak termasuk: penggajian otomatis (F3), pengeluaran berulang, anggaran.

## Desain UI

- **1.22** (≥ 1000 px): judul *Pengeluaran*, subjudul *Biaya operasional di
  luar pembelian barang dagang*, tombol *Ekspor Excel*. Kiri: cari +
  *Periode* (30 hari terakhir, bulan ini, bulan lalu); tabel Tanggal,
  Keterangan, Jenis, Sumber dana (mis. *Kas laci · sesi Sari*), Jumlah,
  Bukti (*Ada foto* / *Tanpa foto*); kartu *Per jenis · <periode>* dengan
  total dan batang per jenis. Kanan: kartu *Catat pengeluaran*
  (Keterangan, Jenis, Jumlah, Sumber dana, Tanggal, *Ambil foto nota*,
  *Simpan pengeluaran*).
- Di bawah 1000 px kartu form diganti tombol *+ Catat pengeluaran* yang
  membuka dialog berisi form yang sama; tabel jadi daftar kartu di 360 px.
- Ketuk baris → dialog **Rincian pengeluaran**: nomor, tanggal, jenis,
  sumber dana, pencatat, foto nota (bisa dibuka), dan *Batalkan
  pengeluaran* dengan alasan. Pengeluaran batal tetap tampil dengan lencana
  *Dibatalkan* dan tidak dihitung.
- **Kas laci**: saat *Uang keluar* dipilih dan staf punya
  `expenses:manage`, sakelar *Catat juga sebagai pengeluaran* (subjudul
  *Agar ikut laporan laba rugi*); bila aktif muncul *Jenis pengeluaran* dan
  *Foto nota (opsional)*. Baris gerakan kas hasilnya menampilkan lencana
  *Pengeluaran · <jenis>*.
- **Master data**: tab *Jenis pengeluaran* (nama, jumlah pengeluaran,
  ubah, hapus) untuk staf dengan `expenses:manage`.

## Keputusan

1. **Dokumen `expenses`** per outlet: `number`
   `EX-<OUTLET>-<PERANGKAT>-<yymmdd>-NNNN`, `spent_on` (tanggal kalender),
   `description` (wajib, ≤ 120), `expense_category_id` (wajib), `amount`
   (> 0, ≤ Rp 1.000.000.000), `funding_source` (`FundingSource`),
   `cash_session_id` + `cash_movement_id` bila dari laci,
   `receipt_media_id` (foto nota, `MediaKind.expenseReceipt`),
   `voided_at` / `voided_by` / `void_reason`.
2. **Tanggal** tidak boleh di masa depan; boleh mundur untuk kas toko dan
   bank.
3. **Kas laci**: wajib sesi kasir terbuka di perangkat ini dan izin
   `cash_movements:create`; menulis `cash_movements` keluar
   (`source = expense`, catatan = keterangan) dalam transaksi yang sama.
   Tanggalnya selalu hari ini menurut cabang (lapisan data memakai tanggal
   saat simpan, bukan tanggal kiriman layar, agar layar yang terbuka
   melewati tengah malam tidak macet); form menolak tanggal lain untuk
   kas laci. Keterangan uang keluar yang dicatat juga sebagai pengeluaran
   dibatasi 120 karakter.
4. **Tidak ada ubah nilai**: koreksi = batalkan (alasan wajib, ≤ 200) lalu
   catat baru. Pembatalan pengeluaran laci menulis uang masuk
   (`source = expense_void`) di sesi yang sedang buka di perangkat ini;
   tanpa sesi terbuka pembatalan laci ditolak. Pembatalan laci juga butuh
   `cash_movements:create` (tombol *Batalkan* disembunyikan tanpa izin
   itu). Pembatalan kas toko/bank tidak menyentuh laci.
5. **Jenis pengeluaran** (`expense_categories`) milik tenant, nama wajib
   ≤ 60, unik tanpa membedakan huruf besar/kecil. Jenis bawaan dibuat
   sekali per tenant saat pertama dibutuhkan: *Sewa tempat*, *Listrik &
   air*, *Gaji & upah*, *Transport*, *Plastik & kemasan*, *Bahan habis
   pakai*, *Lain-lain*. Hapus ditolak bila sudah dipakai pengeluaran (ubah
   nama tetap boleh).
6. **Periode**: *30 hari terakhir* (hari ini − 29 s.d. hari ini, bawaan),
   *Bulan ini*, *Bulan lalu*, menurut tanggal lokal cabang. Total dan *Per
   jenis* hanya menghitung pengeluaran yang tidak batal.
7. **Cari** keterangan, nomor, atau nama jenis (tanpa beda huruf).
8. **Ekspor Excel** daftar sesuai filter: Tanggal, Nomor, Keterangan,
   Jenis, Sumber dana, Jumlah, Bukti, Status.
9. **Izin**: menu, layar, master jenis, catat, batal = `expenses:manage`
   (+ `cash_movements:create` untuk laci). Dicek di menu, layar,
   repositori aplikasi, dan lapisan data untuk semua aksi tulis.
10. **Data per outlet**: daftar dan ringkasan dibatasi outlet ini; jenis
    dipakai bersama semua cabang.
11. **Foto nota** ≤ 5 MB tersimpan (pilih sampai 20 MB, dikecilkan ke
    2.000 px sejak v0.63.0, [F1-15b](2026-11-14-f1-15b-kecilkan-foto-nota-design.md)), gambar sah (PNG/JPEG/WebP), sama dengan bukti
    bayar hutang (F1-14). Foto di rincian bisa dibuka besar dan
    diperbesar; foto hanya dibaca untuk pengeluaran cabang ini.

## Beda dengan Storeku

- Nomor memuat kode perangkat (`EX-PST-K01-…`) mengikuti konvensi Lakuna.
- Batal pengeluaran laci membalik kas di sesi yang sedang buka (Storeku
  belum menetapkan).

## Data

- `expense_categories`: `tenant_id`, `name`, kolom sync standar.
- `expenses`: lihat keputusan 1; indeks `(tenant_id, number)` unik,
  `(outlet_id, spent_on)`, `expense_category_id`, `cash_session_id`.
- `MediaKind.expenseReceipt`.
- Migrasi `expense`.

## Pengujian

- Domain: validasi pengeluaran, nomor `EX-`, rentang periode, validasi
  nama jenis.
- Data: jenis bawaan sekali, catat kas toko/bank/laci (kas keluar di
  sesi, ditolak tanpa sesi / tanggal mundur / izin), foto tersimpan,
  daftar + ringkasan per periode dan cari, batal (laci membalik kas,
  tanpa sesi ditolak), jenis unik dan hapus ditolak bila dipakai, kas laci
  + pengeluaran dari sesi kasir.
- Aplikasi: repositori lokal (izin), VM daftar/form/rincian/jenis, alur
  widget 1440/800/360 px, kas laci dengan sakelar pengeluaran.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Jenis pengeluaran, catat, batal, per jenis, ekspor, kas laci | 1.22, 1.3b, 1.17 | Rilis v0.19.0 | — |
| Pengeluaran berulang (sewa bulanan) | — | Belum | Fase 3. |
| Laba rugi | 1.24 | Belum | F1-16 membaca `expenses` tidak batal. |
| Peran khusus dengan `expenses:manage` tanpa `cash_movements:create` | — | Dicek di UI, repositori, data | Peran bawaan belum punya kombinasi ini; tambah tes data saat peran khusus (F1-17) ada. |
| Jumlah pakai per jenis | — | Dihitung di memori dari semua pengeluaran tenant | Ganti dengan kueri `GROUP BY` bila data besar. |
| Sinkronisasi (Fase 2) | — | Belum | Jenis bawaan dibuat per perangkat saat offline: pakai ID deterministik (UUIDv5 tenant + nama) atau gabung saat sync. Batal pengeluaran laci dari perangkat lain mengembalikan uang ke laci perangkat itu; batasi ke perangkat asal. |
| Isian cari hilang saat lebar melewati 520 px | — | Filter tetap berlaku | Pertahankan controller saat tata letak berganti. |

## Kriteria selesai

- Pengeluaran tercatat per jenis dan periode, kas laci terpengaruh bila
  dipakai, dan bisa dibatalkan dengan jejak.
- Layar jalan di desktop, tablet, dan ponsel 360 px tanpa luapan.
