# F1-12c · Cetak/bagikan PDF pembelian dan tautan kartu stok

- **Fase:** 1
- **Status:** Dalam pengerjaan (v0.51.0)
- **Layar:** 1.19b detail pembelian (kartu *Tindakan*: *Cetak / bagikan
  PDF*; nama produk di *Barang diterima* membuka kartu stok) → 1.18 Stok
  tab *Kartu stok*.
- **Acuan:** gap F1-12 *Kartu stok terkait, cetak/bagikan PDF* (tombol di
  kanvas 1.19b). Pola PDF sama dengan *Cetak stok* (F1-08b).
- **Menutup gap:** F1-12 "Kartu stok terkait, cetak/bagikan PDF".

## Tujuan

Pemilik bisa mengirim bukti pembelian ke supplier atau rekan (WhatsApp,
email) dan menelusuri pergerakan stok barang yang baru diterima tanpa
mencari produk lagi di layar Stok.

## Aturan

1. **Tombol** *Cetak / bagikan PDF* (`purchase-print`, ikon printer) di
   kartu *Tindakan* detail pembelian yang sudah diterima.
   - Desktop: PDF disimpan di folder dokumen Lakuna, pesan *PDF pembelian
     disimpan di <path>*.
   - Android/iOS: lembar bagikan sistem terbuka (tanpa pesan path).
   - Gagal membuat atau menyimpan → *PDF pembelian gagal dibuat. Coba
     lagi.*; tombol mati selama proses.
2. **Isi PDF** (A4 tegak, `reportPdf`):
   - Judul *Pembelian PB-…*; subjudul *Supplier · No. faktur · tanggal ·
     lokasi · staf · perangkat*.
   - Tabel: Produk (nama + varian, SKU), Qty (dengan satuan), Harga beli,
     Subtotal.
   - Baris ringkasan tebal: Subtotal, Diskon faktur (bila ada), Ongkos
     kirim (bila ada), Total, Dibayar di muka, Bayar hutang (bila ada),
     Diretur (bila ada), Sisa hutang.
   - Catatan: jatuh tempo (bila masih berhutang), catatan pembelian, daftar
     retur (`RB-… · tanggal · −Rp`), dan "Dicetak <tanggal jam> oleh
     <staf>".
   - Nama berkas `pembelian-<nomor huruf kecil>.pdf` (mis.
     `pembelian-pb-pst-k01-261114-0001.pdf`); mencetak ulang menimpa
     berkas lama (isi selalu yang terbaru).
3. **Kartu stok**: nama produk barang yang melacak stok di *Barang
   diterima* menjadi tautan (`purchase-stock-card-<item>`), membuka layar
   Stok tab *Kartu stok* untuk varian itu **di lokasi terima pembelian**.
   Tautan hanya tampil bila staf punya izin `stock:adjust` (izin menu
   Stok). Barang yang tidak melacak stok (jasa) tidak bertautan.
4. Layar Stok menerima `?tab=card&varian=<id>&lokasi=<id>`; varian atau
   lokasi yang tidak ada lagi jatuh ke perilaku bawaan (lokasi bawaan,
   varian pertama di bawah minimum).

## Komponen

- `lib/ui/purchases/purchase_print.dart`: `purchasePrintTable(l10n, detail,
  {staff, printedAt, timezone, money})` → `ReportTable`;
  `purchasePrintFileName(number)`.
- `PurchaseDetailViewModel(exporter:)`: `printPdf` (`Command1<String?,
  (Future<Uint8List> Function(), String)>`), `printPath`.
- `PurchaseDetailView(onOpenStockCard:)`, `PurchaseDetailScreen
  (onOpenStockCard:, exporter:)`.
- `Routes.stockCard(variantId, locationId)`; `StockScreen(initialVariantId,
  initialLocationId)` → `StockViewModel.focusCard`.

## Pengujian

- Tabel cetak: kolom, baris ringkasan, retur dan bayar hutang, catatan
  jatuh tempo, nama berkas.
- VM detail: cetak menyimpan lewat exporter (path), galat → `printPdf.error`.
- VM stok: `focusCard` sebelum muat memilih lokasi dan varian; varian tak
  dikenal jatuh ke bawaan.
- Widget: tombol cetak + pesan tersimpan (1440 px dan 360 px), tautan kartu
  stok membuka tab *Kartu stok* produk itu; tanpa izin stok tidak ada
  tautan.
- Uji manual Xvfb: cetak PDF dan render dengan `pdftoppm`; tautan kartu
  stok.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Cetak/bagikan PDF pembelian | Tombol di 1.19b | Dalam pengerjaan | — |
| Tautan kartu stok dari detail pembelian | Tombol di 1.19b | Dalam pengerjaan | — |
| PDF retur pembelian (RB-) tersendiri | — | Belum | Retur tercantum di PDF pembelian asal. |
| Kirim langsung ke WhatsApp supplier | — | Belum | Lembar bagikan sistem sudah menawarkan WhatsApp di ponsel. |
