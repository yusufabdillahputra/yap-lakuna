# F1-05e — Rekening transfer di struk piutang dan kuitansi

- **Fase:** 1
- **Status:** Rilis v0.79.0
- **Layar:** 1.12 Struk (nota baru dan cetak ulang Riwayat 1.14),
  1.20b Kuitansi (thermal dan A5).
- **Acuan:** gap [F1-05c](2026-11-14-f1-05c-rekening-transfer-design.md)
  *Rekening transfer di struk*. Storeku belum punya rekening transfer.

## Tujuan

Rekening toko (Pengaturan › *Penjualan & stok* › *Rekening transfer*,
F1-05c) baru tampil di layar Pembayaran. Pelanggan yang berutang membawa
pulang struk tanpa tahu ke mana harus mentransfer sisa tagihannya, jadi
kasir menulis nomor rekening dengan tangan. Struk yang masih menyisakan
piutang sebaiknya langsung memuat rekening itu.

## Aturan

1. **Struk nota** (nota baru di layar *Pembayaran berhasil*, cetak ulang
   dari Riwayat): bila nota punya pelanggan, dibayar kurang dari total
   (baris *Piutang* tercetak), nota tidak di-void, dan *Rekening
   transfer* terisi, cetak satu baris setelah *Piutang* / *Jatuh tempo*:
   `Transfer ke: <rekening>` (English `Transfer to: <rekening>`).
2. Baris itu tanpa nilai kanan dan dibungkus per kata seperti baris
   referensi F1-05b, sehingga rekening panjang (maks 100 karakter) tidak
   terbaca sebagai nominal. Spasi dan baris baru di rekening dirapikan
   menjadi satu spasi.
3. Nota lunas, nota tanpa pelanggan, nota void, nota diretur penuh
   (status *Diretur*), atau rekening kosong: baris tidak tercetak.
4. **Kuitansi thermal** pembayaran piutang: bila *Sisa piutang* tercetak
   (opsi *Tampilkan sisa piutang* aktif, kuitansi tidak dibatalkan) dan
   sisanya lebih dari 0, cetak baris yang sama setelah *Sisa piutang*.
5. **Kuitansi A5 (PDF)**: syarat sama dengan aturan 4; tambah isian
   **Transfer ke** berisi rekening setelah isian *Metode*.
6. Struk contoh di Pengaturan › Struk tidak berubah (tanpa piutang).
7. Cetak ulang nota piutang yang kemudian sudah dilunasi tetap memuat
   rekening, sama seperti baris *Piutang* yang mencatat keadaan saat
   transaksi.

## Rancangan teknis

- `ReceiptConfig` (`lakuna_data`, `receipt_settings.dart`) mendapat
  `transferAccount` (bawaan `''`). `loadReceiptConfig` mengisinya dari
  `loadSalesRules(...).transferAccount`, sehingga kasir, Meja, Riwayat,
  dan Pelanggan otomatis mendapat rekening tanpa mengubah repositori.
  `ReceiptSettingsViewModel.previewConfig` meneruskan nilainya agar
  config pratinjau tetap utuh (struk contoh tidak memakainya).
- `receipt_content.dart`: helper `receiptTransferLine(l10n, account)`
  mengembalikan `ReceiptPair?` (`null` bila kosong), dipakai
  `saleReceiptContent` dan `kuitansiReceiptContent`.
- `kuitansiDocument`: `KuitansiField(l10n.paymentTransferTo, rekening)`.
- l10n baru: `receiptTransferTo` = "Transfer ke: {account}" /
  "Transfer to: {account}".

## Tes

- Data: `loadReceiptConfig` memuat rekening dari aturan penjualan;
  kosong bila belum diatur.
- Unit `saleReceiptContent`: piutang + rekening → baris setelah jatuh
  tempo; lunas, void, atau rekening kosong → tanpa baris; rekening
  dengan baris baru dirapikan; tata letak 58 mm membungkus tanpa nilai.
- Unit kuitansi thermal dan A5: sisa > 0 → baris/isian; sisa 0, opsi
  sisa mati, atau kuitansi batal → tanpa.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Rekening di struk nota piutang (baru + cetak ulang) | 1.12 | Rilis v0.79.0 | — |
| Rekening di kuitansi thermal dan A5 bila masih ada sisa | 1.20b | Rilis v0.79.0 | — |
| Rekening di struk tagihan open bill sebelum bayar | — | Belum | Lakuna belum punya cetak tagihan (pre-bill). |
