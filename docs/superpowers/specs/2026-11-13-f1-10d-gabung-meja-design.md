# F1-10d · Gabung meja

- **Fase:** 1
- **Status:** Rilis v0.40.0
- **Layar:** 1.7 / 1.8 *Meja* (panel bill: aksi *Gabung meja*).
- **Acuan:** spec Storeku F1-10 ("Pindah meja / gabung meja"), kanvas
  1.7d properti meja *Boleh digabung dengan meja sebelah* (`can_merge`,
  sudah disimpan sejak v0.14.0).
- **Menutup gap:** F1-10 "Gabung meja".

## Tujuan

Rombongan yang awalnya duduk di dua meja (atau pindah bergabung) dibayar
dalam satu tagihan, tanpa membatalkan bill lalu memasukkan ulang pesanan.

## Aturan

1. **Siapa dan di mana.** Aksi *Gabung meja* ada di panel bill dine in
   (izin `open_bills:manage`, sama dengan aksi bill lain). Tampil hanya bila
   meja bill ini *Boleh digabung*.
2. **Pilihan meja.** Dialog menampilkan meja lain di cabang ini yang punya
   bill dine in terbuka **dan** *Boleh digabung*. Tidak ada pilihan →
   pesan "Belum ada meja lain yang bisa digabung".
3. **Hasil.** Bill meja yang dipilih (sumber) digabung ke bill ini
   (tujuan), dalam satu transaksi:
   - Semua item sumber pindah ke bill tujuan apa adanya (status dapur,
     catatan, modifier, harga beku), urut setelah item tujuan. Baris tidak
     digabung otomatis.
   - Tiket dapur sumber ikut pindah ke bill tujuan.
   - Jumlah tamu dijumlah (maks 99). Nama pelanggan bill tujuan dipakai;
     bila kosong, diambil dari sumber. *Minta bill* tujuan tetap.
   - Diskon nota tujuan tetap berlaku atas total gabungan; total, service,
     dan PB1 dihitung ulang dengan tarif terkini.
   - Bill sumber dihapus (soft delete) sehingga mejanya kosong.
4. **Ditolak** (`BillMergeBlocked`) bila:
   - salah satu bill sudah punya pembayaran bagian atau sedang di-split
     (`split`): selesaikan/batalkan split dulu;
   - bill sumber punya diskon nota (`discount`): hapus dulu agar diskon
     tidak hilang diam-diam;
   - salah satu meja tidak *Boleh digabung*, bill bukan dine in, atau bill
     sama (`notAllowed`);
   - jumlah tamu gabungan > 99 (`guests`).
   Bill dari cabang lain tidak terlihat sama sekali (`BillNotFound`).
   Dialog hanya menawarkan bill sumber yang tidak di-split dan tanpa diskon
   nota; aksi *Gabung meja* nonaktif selama bill ini di-split.
5. **Tanpa denah**: sakelar *Boleh digabung dengan meja sebelah* juga ada di
   form meja *Data master › Meja & area*.
6. Setelah berhasil, panel tetap menampilkan bill tujuan yang kini berisi
   semua item; layar Meja menampilkan meja sumber kosong.

## Komponen

- Data: `mergeOpenBills(store, scope, staffId, targetBillId,
  sourceBillId)`, `BillMergeBlocked(BillMergeReason)`.
- Data master: `DiningTableDraft.canMerge`; sakelar *Boleh digabung
  dengan meja sebelah* di form meja (toko tanpa denah).
- Flutter: `DiningRepository.mergeBill`, `DiningViewModel.merge`
  (`Command1<UuidValue>`), `mergeSources(bill)`, `canMergeInto(bill)`,
  `canMergeNow(bill)`;
  aksi `dining-merge` + dialog `dining-merge-dialog` di `dining_view.dart`;
  pesan galat per alasan; l10n.

## Pengujian

- Data: gabung (item, urutan, tiket, tamu, nama pelanggan, total
  dengan diskon tujuan, sumber terhapus, outbox), setiap alasan tolak.
- Flutter: VM (target, eksekusi, galat), widget 1280/360 px (aksi hanya
  untuk meja *Boleh digabung*, dialog, hasil).
- Uji manual Xvfb: gabung dua meja berisi pesanan lalu bayar.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Gabung bill dua meja | `can_merge` | Rilis v0.40.0 | Sakelar juga di form *Data master › Meja & area*. |
| Gabung meja kosong ke bill (satu bill menempati dua meja) | — | Belum | Butuh relasi bill ke banyak meja; sementara buka bill di satu meja lalu gabung bila meja kedua sudah punya pesanan. |
| Pisah kembali bill yang sudah digabung | — | Belum | Pakai split bill untuk membayar terpisah. |
| Jejak gabung | — | Belum | Bill sumber hanya di-soft delete, belum ada kolom penanda bill tujuan; tambahkan bila audit butuh. |
| Diskon persen tujuan | — | Sesuai desain | Diskon persen ikut berlaku atas total gabungan tanpa persetujuan ulang. |
