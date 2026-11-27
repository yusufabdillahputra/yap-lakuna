# F1-18f — *Foto stiker* QRIS dari kamera

Lanjutan F1-18 (Pengaturan › Metode pembayaran, 1.26b). Gap 4 di
`docs/superpowers/GAP-FASE1.md`.

## Tujuan

Pemilik yang hanya punya stiker QRIS cetak (tanpa file asli dari bank/PJP)
bisa langsung memotretnya dari Pengaturan, seperti foto produk (F1-07f),
foto nota pengeluaran, dan foto faktur pembelian.

## Acuan desain (1.26b)

Kotak *Ganti gambar QRIS* punya dua tombol: **Pilih file** dan **Foto
stiker**, dengan teks *Seret file ke sini atau pilih dari galeri / kamera*.
Catatan biru menyebut *foto lurus seluruh stiker* sebagai pengganti file
asli. Seret file (drag and drop) tetap di luar lingkup.

## Aturan

- Tombol **Foto stiker** hanya tampil bila perangkat punya kamera
  (`ImageFilePicker.canTakePhoto`: Android/iOS), sama seperti foto produk.
- Foto kamera diperkecil ke lebar maks 2000 px (kualitas JPEG 85) lalu
  melewati pemeriksaan yang sama dengan file: format, batas 5 MB, rasio
  vertikal, dan resolusi. Foto miring/lanskap tetap boleh disimpan dengan
  peringatan rasio seperti file.
- Batal di kamera = tidak terjadi apa-apa.
- File gagal dibuka menampilkan *File tidak bisa dibuka. Pilih file
  lain.*; kamera gagal dibuka (mis. izin kamera iOS ditolak) menampilkan
  *Kamera tidak bisa dibuka. Periksa izin kamera di pengaturan perangkat,
  atau pilih file.* Sebelumnya galat *Pilih file* tidak tampil sama
  sekali. Pesan hilang saat gambar berhasil dipilih atau *Batal*.
- Selama dialog file/kamera terbuka, *Pilih file*, *Foto stiker*,
  *Simpan*, dan *Batal* mati.
- Teks petunjuk kotak unggah menyebut kamera bila tombolnya ada.

## Tes

- Widget: tombol tampil hanya bila kamera ada, foto masuk pratinjau +
  hasil pemeriksaan dan tersimpan dengan lebar maks 2000, galat kamera
  tampil dan hilang setelah pilih ulang, *Simpan* mati selama memotret.

## Status & gap

| Bagian | Desain | Status | Catatan |
| --- | --- | --- | --- |
| *Foto stiker* (kamera) | 1.26b | Rilis v0.140.0 | Android/iOS; seret file belum. |
