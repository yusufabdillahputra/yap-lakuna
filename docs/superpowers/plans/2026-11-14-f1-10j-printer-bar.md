# Rencana F1-10j — Printer bar per kategori

Spec: [F1-10j](../specs/2026-11-14-f1-10j-printer-bar-design.md).

**Tujuan:** satu kali *Kirim ke dapur* mencetak minuman di printer bar dan
makanan di printer dapur menurut kategori produk.

## Langkah

- [ ] **Data** — tes `loadBarPrinter`/`saveBarPrinter` (kategori, JSON
  rusak) dan `splitBarItems` (kategori, sub-kategori, tanpa kategori);
  implementasi di `receipt_settings.dart`.
- [ ] **Repositori** — `loadBarPrinter`/`saveBarPrinter` lokal + palsu,
  izin `settings:manage`; `DiningData.barPrinter`.
- [ ] **VM printer** — `KitchenPrinterViewModel(station:)`, kategori,
  tes; kartu *Printer bar* di Struk & printer; l10n.
- [ ] **Dining** — `ticketParts`, cetak otomatis bar, status/galat bar,
  cetak ulang bar; modal tiket dua bagian; `kitchenTicketLines(heading:)`.
- [ ] **Tes widget** 1280/360 px (kartu dan modal).
- [ ] **Review** subagent baru; perbaiki Critical/Important.
- [ ] **Uji manual Xvfb** dengan dua printer jaringan tiruan.
- [ ] **Dokumen**: spec F1-10e/F1-10g (gap), README, STATUS-JEDA, panduan
  printer id/en, CHANGELOG 0.61.0, pubspec `0.61.0+64`.
- [ ] **PR, merge, cek rilis.**
