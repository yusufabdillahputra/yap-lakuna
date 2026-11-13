# Rencana F1-10g · Kirim ke tiket dapur & catatan bebas per menu

Spec: `docs/superpowers/specs/2026-11-13-f1-10g-menu-dapur-catatan-design.md`.

- [x] 1. Model `products.send_to_kitchen` / `allow_note` (bawaan `true`),
      `serverpod generate`, migrasi `menu-dapur` (Postgres + SQLite klien).
- [x] 2. Domain/data (TDD): `ProductDraft` / `CatalogProduct` membawa kedua
      sakelar; simpan/muat/daftar.
- [x] 3. `sendToKitchen`: item non-dapur langsung *Disajikan* tanpa tiket;
      tanpa item dapur → tanpa tiket (`KitchenSendResult.ticket` `null`,
      `served`). `addBillItem` mengabaikan catatan menu tanpa catatan bebas.
- [x] 4. Form produk 1.16b: bagian *Dapur* di tab *Modifier* (VM + tes).
- [x] 5. Meja: `servedWithoutTicket`, modal tiket hanya bila ada tiket, cetak
      otomatis hanya tiket; lembar menu menyimpan catatan untuk menu
      berikutnya; lembar modifier tanpa isian catatan. Tes VM + widget
      1280/360 px.
- [x] 6. Uji manual Xvfb dengan printer dapur tiruan (9101).
- [x] 7. Review subagent, perbaiki temuan (minor: validasi catatan,
      reset pesan, tes outbox dan lembar modifier).
- [ ] 8. Dokumen (spec, F1-10, README, STATUS-JEDA, panduan), CHANGELOG
      0.43.0, pubspec `0.43.0+46`, PR, CI, merge.
