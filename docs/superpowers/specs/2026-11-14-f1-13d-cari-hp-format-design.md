# F1-13d — Cari nomor HP dengan format apa pun

- **Fase:** 1
- **Status:** Rilis v0.77.0
- **Layar:** 1.14 *Riwayat* (kolom cari), 1.20 *Pelanggan*, 1.21
  *Supplier*, 1.4b pilih pelanggan di Kasir, 1.5b *Kredit* (pilih
  pelanggan), pilih pelanggan di bill Meja.
- **Acuan:** gap [F1-11b](2026-11-14-f1-11b-cari-nota-riwayat-design.md)
  *Cari HP dengan format lain (+62, tanda hubung)*. Storeku punya gap yang
  sama.

## Tujuan

Nomor HP disimpan ternormalisasi (`0812…`, F1-13), tetapi kasir sering
mengetik nomor seperti tertulis di WhatsApp: `+62 812-3456-7890`. Setiap
kolom cari mencocokkan HP dengan cara sendiri-sendiri: Riwayat memakai teks
apa adanya, pilih pelanggan Kasir/Meja membuang selain digit (`62812…`
tidak cocok dengan `0812…`), *Kredit* memakai teks mentah, sedangkan layar
Pelanggan/Supplier menormalisasi sehingga potongan tengah yang berawalan 8
(`8194`) malah tidak cocok. Modul ini menyatukan aturannya.

## Aturan

1. **Kata kunci HP** hanya bila isian cari berisi digit, spasi, dan
   `+ - ( ) .` saja, dengan minimal **3 digit**. Tanda arah tak terlihat
   yang ikut tersalin dari WhatsApp/kontak Android dibuang, tanda hubung
   Unicode (mis. U+2011) dianggap `-`, spasi tak putus dianggap spasi. Kata kunci yang memuat
   huruf (mis. nomor nota `PST-K01-…`, nama) tidak dicocokkan ke HP
   sehingga tidak ada hasil palsu.
2. **Kunci pencarian:** digit kata kunci apa adanya (cocok untuk potongan
   di mana pun, mis. `2222-1010`). Bila kata kunci nomor internasional
   (`+62…`, atau `62…` minimal 10 digit), kuncinya awalan `62` diganti
   `0` (`+62 813` → `0813`) saja, karena HP tersimpan selalu `0…` dan kunci
   `62…` hanya akan cocok palsu di tengah nomor. Sisa terlalu pendek
   (`+62 8`) tidak dicocokkan. `62` di tengah nomor (`6212`) tidak
   diubah.
3. HP cocok bila **memuat** salah satu kunci. Pencocokan nama dan kolom
   lain tidak berubah.
4. Berlaku sama di: Riwayat (pencarian nota, juga di SQL), layar
   Pelanggan, layar Supplier, pilih pelanggan Kasir, pilih pelanggan
   *Kredit*, dan pilih pelanggan bill Meja.
5. Pilih pelanggan di Kasir/Meja dan *Kredit* sebelumnya mencocokkan HP
   mulai 1 karakter; kini minimal 3 digit (aturan 1), sama dengan layar
   Pelanggan.
6. Layar Pelanggan/Supplier sebelumnya mengubah `62857` (tanpa `+`,
   kurang dari 10 digit) menjadi `0857`. Kini dianggap potongan tengah
   apa adanya; ketik `+62 857` atau `0857`.

## Rancangan teknis

- `lakuna_domain` (`customer.dart`): `phoneQueryMinDigits = 3`,
  `phoneSearchKeys(String raw) → List<String>`,
  `phoneMatchesQuery(String? phone, String raw)`.
- `listSalesHistory` / `_searchSales`: pelanggan dicari dengan
  `name ilike` **atau** `phone ilike` kata kunci **atau** `phone ilike`
  tiap kunci HP, lalu dicek ulang di Dart.
- View model Pelanggan, Supplier, Kasir (`customerCandidates`,
  `creditCandidates`), Meja (`customerCandidates`) memakai
  `phoneMatchesQuery`.

## Tes

- Domain: format `0813-2222`, `+62 813 2222`, `6281322221010`,
  `(0813) 2222`, potongan tengah `2222-1010` dan `8132` cocok; huruf,
  nomor nota, `08`, `+62`, `+628`, `+62 8` tidak menghasilkan kunci; `62`
  di tengah tidak diubah; `+62 813` tidak cocok palsu dengan `…62813…`;
  salinan WhatsApp (U+202A/C, U+2011, U+00A0) cocok.
- Data: Riwayat menemukan nota pelanggan lewat `+62 812-3456`,
  `0812 3456 7890`, `62812345678`.
- View model: Pelanggan (`+62 857-1111`, `8194`), Supplier (`+62 813`),
  Kasir pilih pelanggan dan *Kredit* (`+62 813-2222`, `0813 2222`; `08`
  terlalu pendek), Meja (`+62 812`).

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Cari HP format apa pun | — | Rilis v0.77.0 | — |
| HP lama yang tersimpan tidak ternormalisasi | — | Belum | Semua jalur simpan sudah menormalisasi sejak F1-13; data sinkron Fase 2 perlu dicek. |
| Kode negara selain +62 | — | Belum | Nomor `+60`/`+65` dicocokkan sebagai digit apa adanya. |
| Garis miring dan pemisah lain (`0812/3456`) | — | Rilis v0.113.0 | Garis miring diterima di [F1-13f](2026-11-15-f1-13f-garis-miring-hp-design.md); `_ , #` tetap tidak. |
