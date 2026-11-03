# Rencana v0.8.0: Struk & printer

Spec: [F1-06 Struk & printer](../specs/2026-11-03-f1-06-struk-printer-design.md).

**Tujuan:** struk dicetak ke printer thermal (Bluetooth Android, LAN) atau
lewat dialog cetak sistem, dibagikan sebagai PDF, dengan header/footer per
cabang.

**Arsitektur:** mesin baris struk + encoder ESC/POS di `lakuna_domain`;
pengaturan struk per cabang di `lakuna_data` (`settings`); pilihan printer
di preferensi lokal; aplikasi menambah `ReceiptSettingsRepository`,
layanan `ReceiptPrinter` (Bluetooth / jaringan / sistem + bagikan PDF),
pembangun PDF, widget kertas struk, bagian Pengaturan › Struk & printer,
dan layar sukses baru.

## Tugas 1 · Domain: tata letak struk

- [x] Tes gagal `receipt_test.dart`: kolom 32/48, `wrapText`, pasangan
  muat/tidak muat, barang dua baris, garis, header/footer tengah.
- [x] `receipt.dart`: `ReceiptPaper`, `ReceiptAlign`, `ReceiptLine`,
  `ReceiptContent` (+ `ReceiptItem`, `ReceiptPair`), `layoutReceipt`.

## Tugas 2 · Domain: ESC/POS

- [x] Tes gagal `escpos_test.dart`: byte golden satu struk kecil, ASCII
  pengganti, tanpa potong.
- [x] `escpos.dart`: `receiptAscii`, `encodeEscPos`.

## Tugas 3 · Data: pengaturan struk

- [x] Tes gagal `receipt_settings_test.dart`.
- [x] `receipt_settings.dart`: `ReceiptSettings`, `ReceiptSettingsError`,
  `validateReceiptSettings`, `loadReceiptSettings` (bawaan dari alamat
  cabang), `saveReceiptSettings`; preferensi `printer.selected`.

## Tugas 4 · Aplikasi: repositori, layanan printer, PDF

- [x] `ReceiptSettingsRepository` (lokal + palsu), izin `settings:manage`
  untuk simpan dan printer.
- [x] `ReceiptPrinter` (abstrak) + `PlatformReceiptPrinter`
  (Bluetooth `print_bluetooth_thermal`, soket TCP, `printing`), palsu
  untuk tes. Tes soket dengan `ServerSocket` lokal.
- [x] `receipt_content.dart`: `CheckoutResult` + data kasir + pengaturan →
  `ReceiptContent` (tes).
- [x] `receipt_pdf.dart` (DM Mono dibundel), `ReceiptPaperView`.

## Tugas 5 · Aplikasi: layar sukses dan cetak

- [x] View model: status printer, `printReceipt`, `shareReceipt`, cetak
  otomatis sekali; tes.
- [x] Layar sukses 1.12 dengan kartu printer, tombol, galat + *Coba lagi*.

## Tugas 6 · Aplikasi: Pengaturan › Struk & printer

- [x] `ReceiptSettingsViewModel` + tes.
- [x] Bagian pengaturan (printer perangkat + struk cabang + pratinjau),
  tes widget.
- [x] i18n ID + EN, `flutter gen-l10n`.

## Tugas 7 · Rilis

- [x] Uji manual Xvfb (printer LAN tiruan, PDF, 58/80 mm, mobile),
  tangkapan layar.
- [x] Versi 0.8.0, CHANGELOG, status spec + README.
- [ ] Review subagent, perbaiki Critical/Important.
- [ ] PR, CI hijau, squash merge, mulai ulang cabang, cek rilis.
