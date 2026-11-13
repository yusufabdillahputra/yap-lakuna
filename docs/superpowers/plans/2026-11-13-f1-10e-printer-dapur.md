# Rencana F1-10e · Printer dapur terpisah

Spec: `docs/superpowers/specs/2026-11-13-f1-10e-printer-dapur-design.md`.

- [ ] 1. Data (TDD): `KitchenPrinter{printer, paper}`, `kitchenPrinterKey`,
      `loadKitchenPrinter` / `saveKitchenPrinter` (hanya jaringan/Bluetooth;
      JSON rusak atau jenis sistem → `null`; kertas bawaan 58 mm).
- [ ] 2. Repositori: `ReceiptSettingsRepository.loadKitchenPrinter /
      saveKitchenPrinter` (izin `settings:manage` untuk simpan), versi lokal
      dan palsu. `DiningData.kitchenPrinter` dari repositori meja.
- [ ] 3. `KitchenPrinterViewModel` (TDD): muat, jenis, alamat sah/tidak,
      cari Bluetooth, pilih, kertas, tes cetak, lupakan.
- [ ] 4. Kartu *Printer dapur* di Struk & printer (1.26) + l10n ID/EN.
- [ ] 5. `DiningViewModel`: `ticketPaper`, `shouldAutoPrintTicket`,
      `autoPrintTicket(lines)`; modal tiket menampilkan status cetak dapur
      dan *Cetak ulang*. Tes VM + widget 1280/360 px.
- [ ] 6. Uji manual Xvfb dengan printer jaringan tiruan.
- [ ] 7. Review subagent, perbaiki temuan.
- [ ] 8. Dokumen (spec gap, README, STATUS-JEDA), CHANGELOG 0.41.0, pubspec
      `0.41.0+44`, PR, CI, merge.
