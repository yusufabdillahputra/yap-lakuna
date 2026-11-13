# F1-03b · Cetak rekap sesi kasir

- **Fase:** 1
- **Status:** Rilis v0.38.0
- **Layar:** 1.3 Tutup sesi (tombol *Tutup sesi & cetak rekap*) dan kartu
  hasil setelah tutup.
- **Acuan:** kanvas 1.3 tombol *Tutup sesi & cetak rekap*; spec Storeku
  F1-03 dan F1-06 ("Cetak rekap sesi dengan mesin yang sama"). Storeku belum
  membangunnya, jadi isi rekap dirancang di sini.
- **Menutup gap:** F1-03 "Cetak rekap", F1-06 "Cetak rekap sesi".

## Tujuan

Saat menutup sesi, kasir bisa mencetak rekap kas laci di printer struk
untuk diserahkan bersama uang ke pemilik atau manajer, atau menyimpannya
sebagai PDF.

## Aturan

1. **Mesin cetak sama dengan struk** (F1-06): baris dari `layoutReceipt`,
   lebar kertas dan printer dari *Pengaturan › Struk & printer*. Printer
   langsung (Bluetooth/LAN) menerima ESC/POS; tanpa printer atau printer
   *Dialog cetak sistem* memakai PDF ke dialog cetak.
2. **Tombol di 1.3**: bila perangkat punya printer langsung (Bluetooth/LAN)
   terpilih, tombol primer berbunyi *Tutup sesi & cetak rekap* dan rekap
   langsung dicetak sekali setelah sesi tertutup (sama dengan cetak otomatis
   struk). Tanpa printer atau dengan *Dialog cetak sistem* tombol tetap
   *Tutup sesi* (dialog cetak tidak dibuka sendiri).
3. **Kartu hasil**: tombol *Cetak rekap* dan *Bagikan PDF* di atas *Buka
   sesi baru*. Cetak gagal → pesan printer yang sama dengan struk
   (Bluetooth mati, gagal tersambung, …) di kartu; sesi tetap tertutup dan
   bisa dicetak ulang. PDF di desktop disimpan ke folder struk dan lokasinya
   ditampilkan.
4. **Isi rekap** (ASCII, 32/48 kolom):
   - Kepala: nama toko (tebal), cabang, judul **REKAP SESI KASIR**.
   - Info: Perangkat (kode), Dibuka (tanggal jam), Dibuka oleh, Ditutup
     (tanggal jam), Ditutup oleh, masing-masing satu baris.
   - Penjualan: Transaksi, Penjualan, Tunai, Non-tunai, Kredit (bila ada),
     Void / retur.
   - Kas laci: Saldo awal, Penjualan tunai, Retur tunai (bila ada), Uang
     masuk, Uang keluar.
   - Gerakan kas (bila ada): satu baris per gerakan `jam keterangan` dan
     `+/-jumlah`.
   - Hitung uang: baris pecahan yang terisi (`100.000 x 3`), Receh (bila
     ada).
   - Penutup tebal: Seharusnya di laci, Uang dihitung, Selisih
     (`Pas` / `+5.000` / `-5.000`), lalu *Catatan: …* bila ada.
   - Waktu memakai zona waktu cabang, sama dengan layar.
5. **Data rekap** = data sesi yang dimuat ulang tepat sebelum tutup (agar
   barisnya cocok dengan seharusnya di laci) + angka akhir dari sesi tertutup (seharusnya,
   dihitung, selisih, rincian pecahan, catatan). Rekap hanya bisa dicetak
   dari kartu hasil sesi yang baru ditutup di perangkat ini; rekap sesi
   lama ada di laporan F1-16.

## Komponen

- Domain: `ReceiptContent.sections` (daftar blok pasangan label–nilai di
  antara info dan barang), diuji di `receipt_test.dart`.
- Flutter: `sessionRecapContent(l10n, …)` di
  `lib/ui/cash_session/session_recap_content.dart`;
  `CashSessionViewModel` menerima `ReceiptSettingsRepository` dan
  `ReceiptPrinter` (memuat kertas + printer saat `load`), command
  `printRecap` / `shareRecap`, `closedRecap` (snapshot sesi + sesi
  tertutup), `hasPrinter`, `recapPrintFailure`, `recapPdfPath`.

## Pengujian

- Domain: `sections` tampil berurutan dengan garis pemisah; kosong
  dilewati.
- Flutter: isi rekap (ID + EN, 58 mm), VM (tutup → cetak otomatis bila
  ada printer; tanpa printer tidak; galat printer; bagikan PDF), widget
  1280/360 px (label tombol, tombol di kartu hasil).
- Uji manual Xvfb: buka sesi, tutup, *Bagikan PDF* tersimpan dan isinya
  benar.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Tutup sesi & cetak rekap | 1.3 | Rilis v0.38.0 | Cetak otomatis hanya untuk printer langsung. |
| Cetak ulang rekap sesi lama | — | Belum | Lewat laporan sesi F1-16 bila dibutuhkan. |
