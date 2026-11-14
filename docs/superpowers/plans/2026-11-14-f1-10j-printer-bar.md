# Rencana F1-10j — Printer bar per kategori

Spec: [F1-10j](../specs/2026-11-14-f1-10j-printer-bar-design.md).

**Tujuan:** satu kali *Kirim ke dapur* mencetak minuman di printer bar dan
makanan di printer dapur menurut kategori produk.

## Langkah

- [x] **Data** — tes `loadBarPrinter`/`saveBarPrinter` (kategori, JSON
  rusak) dan `splitBarItems` (kategori, sub-kategori, tanpa kategori);
  implementasi di `receipt_settings.dart`.
- [x] **Repositori** — `loadBarPrinter`/`saveBarPrinter` lokal + palsu,
  izin `settings:manage`; `DiningData.barPrinter`.
- [x] **VM printer** — `KitchenPrinterViewModel(station:)`, kategori,
  tes; kartu *Printer bar* di Struk & printer; l10n.
- [x] **Dining** — `kitchenTicket` / `barTicket`, cetak otomatis bar, status/galat bar,
  cetak ulang bar; modal tiket dua bagian; `kitchenTicketLines(heading:)`.
- [x] **Tes widget** 1280/360 px (kartu dan modal).
- [x] **Review** subagent baru; perbaiki Critical/Important (cetak langsung
  diantrekan satu per satu, tiket antrean tetap dicetak walau modal
  ditutup, chip kategori diantrekan, kategori terhapus/nonaktif).
- [x] **Uji manual Xvfb** dengan dua printer jaringan tiruan.
- [x] **Dokumen**: spec F1-10e/F1-10g (gap), README, STATUS-JEDA, panduan
  printer id/en, CHANGELOG 0.61.0, pubspec `0.61.0+64`.
- [x] **PR, merge, cek rilis.**
