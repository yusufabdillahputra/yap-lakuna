# F1-10j — Printer bar per kategori

- **Status:** Rilis v0.61.0
- **Layar:** 1.26 *Pengaturan › Struk & printer* (kartu baru *Printer
  bar*), 1.7 / 1.8 *Meja* (modal tiket dapur setelah *Kirim ke dapur*).
- **Acuan:** [F1-10e](2026-11-13-f1-10e-printer-dapur-design.md) gap
  *Printer per stasiun (bar vs dapur, per kategori)*; spec Storeku F1-10
  (tiket dapur). Storeku belum punya printer per stasiun; aturan di bawah
  keputusan Lakuna.

## Tujuan

Kafe dan warung makan sering punya dua tempat menyiapkan pesanan: dapur
(makanan) dan bar (minuman). Dengan printer bar, minuman langsung tercetak
di bar dan makanan di dapur dari satu kali *Kirim ke dapur*, tanpa pelayan
memisahkan pesanan.

## Aturan

1. **Satu stasiun tambahan bernama Bar**, per perangkat seperti printer
   dapur: preferensi lokal `printer.bar` (JSON printer, lebar kertas, id
   kategori), tidak ikut sinkronisasi. Mengubahnya butuh `settings:manage`.
2. **Kartu *Printer bar*** di bawah *Printer dapur*:
   - *Tidak dipakai* (bawaan) / *Jaringan (LAN)* / *Bluetooth* (Android),
     alamat dan Bluetooth sama dengan printer dapur. Lebar kertas 58 / 80 mm
     (bawaan 58 mm).
   - *Kategori ke bar*: chip kategori menu (kategori induk saja, urut
     nama). Kategori induk ikut membawa sub-kategorinya. Perubahan chip
     langsung tersimpan bila printer bar sudah dipilih; sebelum itu dipakai
     saat printer dipilih.
   - Tanpa kategori terpilih, kartu menampilkan *Pilih minimal satu
     kategori; sampai itu semua tiket tetap ke dapur.*
   - *Tes cetak tiket bar* dan *Lupakan printer bar* seperti printer dapur.
3. **Kirim ke dapur** dengan printer bar aktif (printer + minimal satu
   kategori): item tiket dibagi menurut kategori produk (atau induknya).
   - Item kategori bar → **tiket bar**, dicetak otomatis sekali ke printer
     bar (kertas bar). Judul tiket *TIKET BAR*; nomor, meja, jam, pelayan
     sama dengan tiket dapur.
   - Item lainnya → tiket dapur dengan perilaku lama (otomatis ke printer
     dapur bila ada; tanpa printer dapur lewat *Cetak tiket* ke printer
     struk).
   - Bila semua item ke bar, tiket dapur tidak dicetak dan modal hanya
     menampilkan tiket bar. Bila tidak ada item bar, tidak ada yang
     dikirim ke printer bar.
   - Satu nomor tiket (`K-0012`) untuk keduanya; data tiket dan status item
     (*Di dapur*) tidak berubah.
4. **Modal tiket** menampilkan pratinjau tiket dapur lalu tiket bar
   (masing-masing dengan judul stasiun) dan status cetak per stasiun:
   *Mencetak di printer bar…*, *Tiket dicetak di printer bar*, atau pesan
   galat printer dengan tombol *Cetak ulang tiket bar*. Galat bar tidak
   menghalangi tiket dapur, dan sebaliknya.
5. Bila tiket bar sebelumnya masih tercetak saat tiket baru dikirim, tiket
   baru menunggu lalu dicetak (sama dengan printer dapur).
6. Produk yang kategorinya dihapus atau tanpa kategori selalu ke dapur.
   Id kategori bar yang sudah tidak ada diabaikan.

## Komponen

- `lakuna_data` (`receipt_settings.dart`): `KitchenPrinter.categoryIds`,
  `barPrinterKey`, `loadBarPrinter` / `saveBarPrinter`;
  `splitBarItems(items, products, parents, bar)` → `(kitchen, bar)`.
- `ReceiptSettingsRepository.loadBarPrinter / saveBarPrinter` (lokal +
  palsu); `DiningData.barPrinter`.
- `KitchenPrinterViewModel(station: PrinterStation.bar)` memakai VM yang
  sama dengan kategori; `KitchenPrinterCard` dengan stasiun bar.
- `DiningViewModel`: `ticketParts`, `shouldAutoPrintBar`, `autoPrintBar`,
  `printBarTicket`, `barPrintFailure`, `barTicketPrinted`.
- `kitchenTicketLines(..., heading:)` untuk judul *TIKET BAR*.

## Pengujian

- Data: simpan/muat/lupakan printer bar dengan kategori, JSON rusak;
  pembagian item (kategori, sub-kategori, tanpa kategori, produk tidak
  dikenal).
- Flutter: VM printer bar (kategori sebelum/sesudah printer dipilih, izin,
  tes), dining VM (tiket dibagi, cetak otomatis bar sekali, semua item ke
  bar, galat bar terpisah, cetak ulang bar), widget kartu dan modal 1280 /
  360 px.
- Uji manual Xvfb: dua printer jaringan tiruan menerima tiket masing-masing.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Printer bar per kategori | 1.26, 1.7e | Rilis v0.61.0 | Selesai. |
| Lebih dari dua stasiun / nama stasiun bebas | — | Belum | Dapur + Bar dulu. |
| Stasiun per produk (bukan kategori) | — | Belum | Kategori cukup untuk pemisahan makanan/minuman. |
| Stasiun ikut sinkronisasi antar perangkat | — | Belum | Printer per perangkat seperti printer dapur. |
