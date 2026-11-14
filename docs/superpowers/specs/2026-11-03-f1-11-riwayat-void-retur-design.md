# F1-11 · Riwayat transaksi, void & retur

- **Fase:** 1
- **Status:** Rilis v0.15.0
- **Layar desain:** 1.14 *Riwayat transaksi, void & retur* (desktop, tablet,
  ponsel, gelap) di kanvas
  [Desain UI Lakuna](https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525).
- **Acuan Storeku:** `docs/superpowers/specs/2026-11-02-f1-11-riwayat-void-retur-design.md`
  (aturan dan keputusan v0.14.0 Storeku disalin di sini; perbedaan dicatat).

## Tujuan

Kasir dan manajer bisa mencari nota, melihat rinciannya, mencetak ulang,
meretur sebagian atau seluruh barang, dan membatalkan (void) nota dengan
jejak audit. Data lama tidak pernah dihapus.

## Lingkup v0.15.0

Termasuk:
- daftar nota dengan filter tanggal, kasir, metode, dan status;
- rincian nota;
- cetak ulang struk;
- retur penjualan per item, dengan alasan dan cara uang kembali;
- void nota lunas;
- persetujuan PIN untuk void;
- ekspor Excel.

Tidak termasuk:
- retur pembelian (F1-12);
- retur ke piutang (F1-13; skema sudah siap).

## Desain UI (baseline 1.14)

**Ringkasan dan filter**
- Ringkasan "Hari ini · 64 transaksi · Rp 4.120.000" dan tombol
  *Ekspor Excel*.
- Filter Tanggal (*Hari ini*, *Kemarin*, *7 hari*), Kasir, Metode, dan
  Status.

**Daftar nota**
- Tabel: Nota, Jam, Kasir, Metode, Total, Status.
- Ponsel memakai kartu, bukan tabel.

**Panel rincian**
- Total awal, sudah diretur, dan nilai bersih.
- Item dengan jumlah dan harga.
- Form retur: jumlah per item, alasan (*Barang rusak*, *Salah ambil*,
  *Kedaluwarsa*, *Lainnya*), uang kembali (*Tunai* dari laci sesi aktif,
  atau *Transfer*), dan pilihan *Kembalikan barang ke stok*.
- Tombol *Proses retur · Rp X*, *Cetak ulang struk*, dan *Void transaksi*,
  dengan catatan "Butuh izin `sales:void` (PIN manajer). Void membalik
  stok & pembayaran lewat entri baru, data lama tidak dihapus."

**Tata letak**
- Lebar konten ≥ 900 px: daftar di kiri, panel rincian 380 px di kanan.
- Lebih sempit (tablet potret, ponsel): rincian dibuka sebagai halaman
  (`/riwayat/:id`), lalu daftar dimuat ulang saat kembali.
- Daftar berupa kartu bila lebar daftar < 520 px.
- Rentang *Kemarin* dan *7 hari* menampilkan tanggal di bawah jam.

## Keputusan (brainstorming 3 Nov 2026, mengikuti Storeku v0.14.0)

1. **Daftar** hanya berisi nota bernomor dengan status `completed`,
   `partiallyReturned`, `returned`, atau `voided`. Bill terbuka tetap di
   layar Meja. Filter Status: Semua, Selesai, Retur (sebagian dan penuh),
   Void. *Menunggu konfirmasi* dan *Belum lunas* tidak muncul, karena nota
   retail tidak bisa disimpan dengan QRIS menunggu, dan kredit baru ada di
   F1-13.
2. **Tanggal** memakai tanggal lokal outlet dari `sold_at`, dengan pilihan
   *Hari ini*, *Kemarin*, dan *7 hari*.
   - Filter Kasir memakai `sales.staff_id`, yaitu staf yang menutup nota.
     Ini berbeda dari Storeku: bill F&B mencatat pelayan di `opened_by`.
   - Filter Metode memakai metode pembayaran `paid` nota itu. Nota split
     muncul di setiap metodenya.
3. **Nilai retur** sudah termasuk bagian service, PB1, dan potongan grosir
   nota.
   - Total nota dibagi ke baris secara proporsional terhadap `line_total`
     (`allocateByWeight`, sisa terbesar).
   - Nilai retur kumulatif baris = `bagian_baris × qty_retur_kumulatif / qty`,
     dibulatkan ke bawah, kecuali retur terakhir yang mengambil sisanya.
   - Nilai satu retur = nilai kumulatif baru − nilai kumulatif sebelumnya.
   - Hasilnya, retur semua item selalu tepat sama dengan total nota.
   - Baris porsi split (F1-10c) ikut dihitung sebagai baris sendiri.
4. **Nomor retur** `RT-<OUTLET>-<PERANGKAT>-<yymmdd>-0001`, urut per
   perangkat per hari (pola yang sama dengan `SA-`).
5. **Uang kembali** disimpan di `refund_method`:
   - `cash`: diambil dari laci sesi aktif perangkat ini, jadi wajib ada sesi
     terbuka. Rekap sesi menghitung `cashRefunds` dari retur `cash` di sesi
     itu. Retur **tidak** menulis `cash_movements`, agar tidak terhitung dua
     kali.
   - `transfer`: hanya dicatat, tidak memengaruhi laci.
   - `debt` disiapkan di enum tetapi disembunyikan sampai F1-13.
6. **Alasan retur** disimpan sebagai kode (`damaged`, `wrongItem`, `expired`,
   `other`) ditambah catatan bebas. Catatan wajib untuk `other`, maksimal
   200 karakter.
7. **Kembalikan ke stok** diatur per dokumen retur (`restock`).
   - Bawaannya dicentang, kecuali untuk alasan *Barang rusak* dan
     *Kedaluwarsa*.
   - Hanya baris yang dulu menulis pergerakan `sale` yang dikembalikan,
     yaitu baris yang punya pergerakan bersumber nota itu untuk varian
     tersebut. Ini menghindari gap Storeku soal `track_stock` yang berubah.
   - Pergerakan dicatat sebagai `saleReturn` masuk, di lokasi dan dengan HPP
     pergerakan `sale` asalnya. `source_id` = id dokumen retur.
   - Kartu stok menampilkan nomor `RT-`.
8. **Void nota lunas** hanya untuk nota yang memenuhi semua syarat ini:
   - status `completed`, tanpa retur;
   - `sold_at` hari ini (tanggal lokal);
   - `cash_session_id` = sesi yang masih buka di perangkat ini.

   Akibat void:
   - Stok dibalik dengan menyalin pergerakan `sale` nota itu bertanda
     terbalik, dengan lokasi, varian, dan HPP yang sama. Sumbernya tetap
     `sale` dan id nota, dengan catatan "Void".
   - Pembayaran tidak dihapus. Rekap sesi sudah mengabaikan nota yang bukan
     `completed`/retur.
   - Kolom yang diisi: `void_reason`, `voided_by` (penyetuju), `voided_at`.
   - Alasan void wajib diisi.
9. **Persetujuan PIN** menutup gap F1-02.
   - Bila staf aktif tidak punya izin yang diminta (`sales:void`), dialog
     *Persetujuan manajer* meminta staf lain yang berizin di outlet ini
     beserta PIN-nya.
   - PIN diperiksa dengan aturan kunci yang sama dengan login (5 salah →
     terkunci 1 menit).
   - Dialog yang sama dipakai tombol *Batalkan bill* di layar Meja.
   - PIN yang benar mencatat persetujuan sekali pakai selama 2 menit di
     `SessionRepository`. Repositori menolak `approverId` tanpa persetujuan
     itu, jadi id staf saja tidak cukup. Persetujuan habis setelah void
     berhasil, saat ganti kasir, atau saat kedaluwarsa; void yang gagal
     validasi tidak menghabiskannya.
10. **Cetak ulang** memakai struk yang sama dengan baris "CETAK ULANG".
    Nota void diberi baris "VOID", dan nota yang diretur mencantumkan nilai
    retur dan nilai bersih.
11. **Ekspor Excel** memakai penulis XLSX sendiri di atas paket `archive`
    (paket `excel` bentrok dengan `xml` 7 yang dipakai `pdf`).
    - Isinya mengikuti filter aktif, satu baris per nota: nomor, tanggal,
      jam, kasir, metode, total, retur, bersih, status.
    - Di desktop, berkas disimpan ke folder dokumen Lakuna yang sama dengan
      PDF struk, lalu path-nya ditampilkan. Di Android/iOS, berkas dibagikan
      lewat share sheet (`share_plus`).
12. **Retur** tidak boleh melebihi sisa per baris (qty terjual − sudah
    diretur).
    - Nota `voided` tidak bisa diretur.
    - Nota split yang lunas boleh diretur. Uang kembali dipilih manual
      (tunai atau transfer).
13. **Izin**:
    - Lihat riwayat: `sales:create`, atau `reports:view` untuk manajer tanpa
      izin kasir.
    - Retur: `sales:return`.
    - Void: `sales:void`, atau persetujuan PIN dari staf yang punya izin
      itu.
    - Semua izin dicek di layar dan di repositori. Untuk void, repositori
      menerima id penyetuju yang sudah diverifikasi, lalu memeriksa ulang
      izin role penyetuju.

## Data

**Tabel baru**
- `sale_returns`: `id`, `tenant_id`, `outlet_id`, `device_id`,
  `cash_session_id?`, `sale_id`, `staff_id`, `number`, `reason`, `note?`,
  `refund_method`, `amount`, `restock`, `returned_at`, ditambah kolom sync
  baku.
- `sale_return_items`: `id`, `tenant_id`, `sale_return_id`, `sale_item_id`,
  `quantity_milli`, `amount`, ditambah kolom sync baku.

**Enum**
- Enum baru `SaleReturnReason` dan `RefundMethod` (`cash`, `transfer`,
  `debt`).
- `SaleStatus` bertambah `partiallyReturned` dan `returned`.

Semua tulis lewat `LakunaStore.write` + `SyncTx`. Migrasi `riwayat`.

## Pengujian

- **Domain:** alokasi nilai retur (sisa terbesar, retur bertahap, retur
  penuh = total), batas jumlah retur, transisi status, nomor `RT-`.
- **Data:**
  - daftar dan filter;
  - retur sebagian lalu sisanya → `returned`, dengan stok dan
    `cashRefunds` sesi benar;
  - retur tanpa restok;
  - retur `cash` tanpa sesi ditolak;
  - void membalik stok dan rekap sesi;
  - void ditolak untuk nota kemarin, sesi lain, atau nota yang sudah
    diretur;
  - persetujuan dengan PIN salah ditolak.
- **View model dan widget:**
  - filter;
  - panel rincian di tablet;
  - halaman rincian di ponsel 360 px;
  - dialog retur;
  - dialog void dengan persetujuan;
  - cetak ulang;
  - ekspor.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Riwayat, retur, void, cetak ulang, ekspor | 1.14 | Rilis v0.15.0 | — |
| Cari nota (nomor, pelanggan, referensi) di semua tanggal | — | Rilis v0.66.0 | [F1-11b](2026-11-14-f1-11b-cari-nota-riwayat-design.md) |
| Open bill yang dibatalkan | — | Tidak tampil di riwayat (nomor OB- tanpa nota) | Lihat di layar Meja bila perlu laporan pembatalan bill. |
| Rekap sesi *Void/retur* | Jumlah | Jumlah nota void + retur di sesi | — |
| Sesi kasir dibuka/ditutup saat riwayat terbuka | — | `hasOpenSession` baru diperbarui saat layar dimuat ulang | Muat ulang saat sesi berubah. |
| Retur tunai melebihi uang di laci | — | Tidak diperingatkan | Peringatan di F1-04 berikutnya. |
| Retur/void dari dua perangkat | — | Data per perangkat | Konflik ditangani sinkronisasi Fase 2. |
| Retur ke piutang | "Potong piutang" | Enum siap, opsi disembunyikan | Aktifkan di F1-13. |
| Status *Menunggu konfirmasi* / *Belum lunas* | Ada di daftar | Belum muncul | Ikut kredit F1-13. |

## Kriteria selesai

- Retur sebagian dan penuh, void (dengan persetujuan PIN), cetak ulang, dan
  ekspor berjalan.
- Rekap sesi kasir menampilkan retur tunai yang benar.
- Layar jalan di desktop, tablet, dan ponsel 360 px tanpa luapan.
