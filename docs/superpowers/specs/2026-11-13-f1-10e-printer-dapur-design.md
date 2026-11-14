# F1-10e · Printer dapur terpisah

- **Fase:** 1
- **Status:** Rilis v0.41.0
- **Layar:** 1.26 *Pengaturan › Struk & printer* (kartu *Printer dapur*),
  1.7 / 1.8 *Meja* (modal tiket dapur setelah *Kirim ke dapur*).
- **Acuan:** spec Storeku F1-10 (tiket dapur, "printer dapur terpisah
  menyusul bersama pengaturan printer"), spec Lakuna F1-06 (printer per
  perangkat).
- **Menutup gap:** F1-10 "Printer dapur terpisah".

## Tujuan

Tiket dapur keluar langsung di printer dapur atau bar, terpisah dari
printer struk di kasir, tanpa kasir menekan *Cetak tiket* setiap kali.

## Aturan

1. **Per perangkat**, sama dengan printer struk: disimpan di preferensi
   lokal (`printer.kitchen`, JSON printer + lebar kertas), tidak ikut
   sinkronisasi. Mengubahnya butuh izin `settings:manage`.
2. **Pilihan** di kartu *Printer dapur*:
   - *Sama dengan printer struk* (bawaan): perilaku lama. Modal tiket
     punya tombol *Cetak tiket* ke printer struk atau dialog cetak sistem.
   - *Jaringan (LAN)*: alamat `host[:port]` (port bawaan 9100), divalidasi
     sama dengan printer struk.
   - *Bluetooth* (Android): pilih dari printer yang sudah dipasangkan.
   - Lebar kertas dapur 58 / 80 mm (bawaan 58 mm), terpisah dari struk.
   - *Tes cetak tiket* mengirim tiket contoh ke printer dapur.
   - *Lupakan printer dapur* kembali ke *Sama dengan printer struk*.
3. **Kirim ke dapur**: bila printer dapur khusus terpasang, tiket langsung
   dicetak sekali ke printer itu (lebar kertas dapur) setelah terkirim.
   Modal tiket menampilkan *Tiket dicetak di printer dapur*, atau pesan
   galat printer dengan *Cetak ulang*. Item tetap berstatus *Di dapur*
   walau cetak gagal (tiket sudah tercatat).
4. Bila cetak tiket sebelumnya masih berjalan (printer lambat) saat tiket
   baru dikirim, tiket baru menunggu lalu dicetak; status di modal hanya
   milik tiket yang tampil.
5. Memilih *Sama dengan printer struk* saat printer dapur tersimpan
   langsung melupakannya.
6. Tiket dari *Tutup & bayar* / split bill tidak berubah (tidak ada tiket
   otomatis di sana).

## Komponen

- Data (`lakuna_data`): `kitchenPrinterKey`,
  `loadKitchenPrinter` / `saveKitchenPrinter` (`KitchenPrinter{printer,
  paper}`).
- Flutter: `ReceiptSettingsRepository.loadKitchenPrinter /
  saveKitchenPrinter`; `KitchenPrinterViewModel` + kartu `KitchenPrinterCard`
  di bagian Struk & printer; `DiningData.kitchenPrinter`;
  `DiningViewModel.shouldAutoPrintTicket`, `autoPrintTicket(lines)`,
  `ticketPaper`.

## Pengujian

- Data: simpan/muat/lupakan, JSON rusak → `null`, kertas bawaan.
- Flutter: VM printer dapur (jenis, alamat sah/tidak, Bluetooth, tes,
  lupakan, izin), dining VM (cetak otomatis sekali ke printer dapur dengan
  kertas dapur; tanpa printer dapur tidak otomatis; galat), widget 1280 /
  360 px.
- Uji manual Xvfb: printer dapur jaringan tiruan menerima tiket saat
  *Kirim ke dapur*.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Printer dapur terpisah | — | Rilis v0.41.0 | Kartu *Printer dapur* di 1.26; tiket otomatis + *Cetak ulang* di modal 1.7e. |
| Printer per stasiun (bar vs dapur, per kategori) | 1.26, 1.7e | Rilis v0.61.0 | [F1-10j](2026-11-14-f1-10j-printer-bar-design.md): printer bar per kategori. |
