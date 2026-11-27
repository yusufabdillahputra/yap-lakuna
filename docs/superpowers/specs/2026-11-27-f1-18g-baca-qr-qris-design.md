# F1-18g — Baca QR dari gambar stiker QRIS (*QR terbaca*)

Lanjutan F1-18 (Pengaturan › Metode pembayaran, 1.26b). Gap 5 di
`docs/superpowers/GAP-FASE1.md`.

## Tujuan

Saat pemilik memilih atau memotret stiker QRIS, aplikasi membaca kode QR
di gambar secara offline, memastikan itu QRIS statis, lalu mengisi *Nama
merchant di QRIS*, *NMID*, dan *Kode terminal* dari isi QR. Salah ketik
NMID berkurang, dan stiker yang salah (QR lain, QRIS dinamis, atau QR
tidak terbaca) ketahuan sebelum dipakai kasir.

## Acuan desain (1.26b)

*Hasil pemeriksaan* punya baris *QR terbaca: QRIS statis, NMID
ID10234567890, merchant WARUNG CONTOH.* dan isian *Nama merchant di QRIS*
berketerangan *Terbaca dari QR, bisa diubah*. Catatan Flutter di kanvas:
*Pemeriksaan QR memakai dekoder offline; bila QR tidak terbaca tetap
boleh disimpan dengan peringatan.*

## Aturan

- **Dekoder:** paket `zxing2` (Dart murni, BSD-3-Clause) di `lakuna_data`,
  gambar dibaca dengan paket `image` yang sudah ada. Berjalan di isolate
  (`Isolate.run`) agar UI tidak tersendat; tanpa jaringan.
- **Isi QR (EMVCo MPM, standar QRIS):** TLV dua digit tag + dua digit
  panjang. Dibaca di `lakuna_domain` (`parseQrisPayload`):
  - CRC tag `63` (CRC16-CCITT-FALSE) harus cocok, bila tidak = *bukan
    QRIS yang sah*.
  - Harus ada template merchant (tag `26`–`51`) bersubtag `00` =
    `ID.CO.QRIS.WWW`; NMID = subtag `02` template itu.
  - Tag `01` = `11` statis, `12` dinamis.
  - Nama merchant = tag `59`, kota = tag `60`, kode terminal = subtag
    `07` dari tag `62` (*terminal label*).
- **Hasil pemeriksaan** (baris tambahan di bawah rasio dan resolusi):
  - QRIS statis: centang hijau *QR terbaca: QRIS statis, NMID …, merchant
    ….*
  - QRIS dinamis: peringatan *QR ini QRIS dinamis (nominal sekali
    pakai). Pakai stiker QRIS statis dari bank/PJP.*
  - QR terbaca tapi bukan QRIS / CRC salah: peringatan *QR terbaca tapi
    bukan QRIS. Pastikan gambar yang dipilih adalah stiker QRIS toko.*
  - QR tidak terbaca: peringatan *QR tidak terbaca dari gambar. Pastikan
    seluruh stiker tajam dan tidak terpotong; NMID bisa diketik manual.*
  - Selama membaca: *Membaca QR…*.
  Semua peringatan **tidak** memblokir *Simpan* (sesuai catatan desain).
  *Simpan* hanya menunggu selama gambar **baru** masih dibaca (biasanya
  kurang dari sedetik), supaya isi otomatis tidak datang setelah
  tersimpan.
- **Format gambar:** PNG apa pun (1/8/16-bit, palet, latar transparan
  dicampur di atas putih), JPEG, WebP. CRC dan panjang TLV dihitung dalam
  byte UTF-8, jadi nama merchant non-ASCII tetap terbaca.
- **Isi otomatis:** hanya setelah gambar **baru** dipilih/dipotret dan QR
  terbaca sebagai QRIS (statis atau dinamis): *Nama merchant*, *NMID*, dan
  *Kode terminal* diisi dari QR **bila isiannya masih kosong**. Isian yang
  sudah diketik tidak ditimpa; bila NMID isian berbeda dengan NMID di QR,
  muncul peringatan *NMID di isian (…) berbeda dengan QR (…).* Nama
  merchant dipotong ke 60 karakter, kode terminal ke 20 (batas isian).
- Gambar tersimpan juga dibaca saat halaman dibuka (hanya hasil
  pemeriksaan, tanpa isi otomatis).
- *Batal* mengembalikan isian dan hasil pemeriksaan gambar tersimpan.

## Tes

- Domain: QRIS statis lengkap, dinamis, CRC salah, bukan QRIS (mis. URL),
  TLV rusak, NMID di tag 26–50 dengan GUID QRIS.
- Data: QR asli di PNG dan JPEG terbaca (fixture dibuat sekali dengan
  `qrcode` Python, di-commit), gambar tanpa QR = `null`.
- Widget: hasil pemeriksaan per kasus, isi otomatis hanya isian kosong,
  peringatan NMID beda, *Simpan* tetap aktif dengan peringatan.

## Status & gap

| Bagian | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Pembacaan QR (NMID otomatis) | 1.26b *QR terbaca* | Rilis v0.141.0 | zxing2 offline di isolate. |
