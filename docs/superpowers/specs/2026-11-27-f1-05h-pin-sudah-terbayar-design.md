# F1-05h — PIN manajer untuk *Sudah Terbayar* QRIS

Lanjutan F1-05 (pembayaran) dan F1-18 (Pengaturan › Metode pembayaran,
1.26b). Gap 2 di `docs/superpowers/GAP-FASE1.md`.

## Tujuan

Pemilik bisa mewajibkan PIN manajer saat kasir menekan *Sudah Terbayar*
QRIS statis. Staf tanpa izin `payments:confirm` tetap bisa menerima QRIS
dengan PIN manajer, bukan diblokir seperti sebelumnya.

## Acuan desain (1.26b)

Sakelar **Kasir boleh konfirmasi tanpa PIN manajer**: *Bila mati, Sudah
Terbayar meminta PIN izin payments:confirm milik manajer.* Dialog PIN
memakai *Persetujuan manajer* (1.2b) yang sama dengan void dan diskon.

Spec Storeku tidak mengatur sakelar ini; aturan di bawah diputuskan di sini.

## Aturan

- Sakelar disimpan di pengaturan QRIS statis cabang
  (`payments.qris_static`, `cashierConfirmWithoutPin`), **bawaan hidup**
  (perilaku lama tidak berubah). Butuh `settings:manage` seperti isian
  QRIS lain.
- **Boleh konfirmasi langsung** (`canConfirmQrisDirectly`): staf punya
  `payments:confirm` **dan** (sakelar hidup **atau** staf punya
  `settings:manage`). Jadi saat sakelar mati, pemilik dan manajer tetap
  langsung; role Kasir bawaan meminta PIN.
- Staf yang tidak boleh langsung (tanpa `payments:confirm`, atau sakelar
  mati tanpa `settings:manage`) tetap bisa memilih QRIS. *Sudah Terbayar*
  membuka dialog *Persetujuan manajer*; penyetuju = staf lain di cabang
  yang ber-PIN dan **boleh konfirmasi langsung** dengan aturan yang sama.
- Satu persetujuan berlaku untuk satu pembayaran (semua bagian QRIS di
  nota itu; dialog menyebut total QRIS-nya), masa berlaku 30 menit seperti
  diskon, habis setelah tersimpan. Menambah bagian QRIS baru, mengganti
  metode bayar, atau persetujuan ditolak membuang persetujuan dan
  mengembalikan bagian QRIS ke *Menunggu*. Bagian menunggu di Meja ›
  Split bill meminta PIN per bagian. Batal di dialog PIN = tidak terjadi
  apa-apa.
- Bila lapisan data menolak (sakelar baru dimatikan di perangkat lain),
  layar memaksa PIN dengan aturan penyetuju ketat sampai data dimuat
  ulang.
- Pengonfirmasi dicari seperti staf bertugas (`findActingStaff`): pemilik
  tanpa keanggotaan cabang tetap `owner`.
- Di luar lingkup: pembayaran piutang lewat QRIS (F1-13) tidak memakai
  *Sudah Terbayar*, jadi sakelar ini tidak berlaku di sana.
- `payments.confirmed_by` = penyetuju (atau staf sendiri bila langsung).
- Lapisan data memeriksa ulang di transaksi: konfirmasi QRIS (bayar
  langsung, bayar bill, bayar bagian split, konfirmasi bagian menunggu)
  ditolak dengan `QrisConfirmNotPermitted` bila pengonfirmasi tidak boleh
  konfirmasi langsung. Repositori juga meminta PIN penyetuju benar-benar
  baru diperiksa (`hasApproval`), sehingga id staf saja tidak cukup.
- *Simpan, tunggu konfirmasi* bagian split tidak butuh PIN (belum
  dikonfirmasi).

## UI

- **Pengaturan › Metode pembayaran › QRIS statis**: sakelar *Kasir boleh
  konfirmasi tanpa PIN manajer* di bawah *Wajib tekan "Sudah Terbayar"*,
  dengan keterangan *Bila mati, kasir tanpa izin Pengaturan memasukkan
  PIN manajer setiap menekan Sudah Terbayar.*
- **Kasir › QRIS** (tunggal, bill, bagian split) dan **dialog bagian QRIS
  di split**: tombol *Sudah Terbayar* selalu aktif; bila butuh PIN, teks
  kecil *Sudah Terbayar butuh PIN manajer.* menggantikan pesan *tidak
  punya izin*, lalu dialog PIN muncul saat tombol ditekan.
- **Meja › Split bill**: tombol *Sudah Terbayar* bagian menunggu tampil
  untuk staf yang bisa membayar; bila butuh PIN, dialog muncul dulu.
- Panduan ID/EN: Pengaturan (sakelar) dan Kasir (QRIS).

## Tes

- Domain: `canConfirmQrisDirectly` (izin × sakelar), JSON bawaan hidup.
- Data: simpan sakelar; checkout QRIS dengan sakelar mati ditolak tanpa
  penyetuju, sah dengan penyetuju manajer (`confirmed_by` = penyetuju),
  ditolak bila penyetuju kasir biasa; staf tanpa `payments:confirm` dengan
  penyetuju; konfirmasi bagian menunggu dengan penyetuju.
- Repositori: penyetuju tanpa `hasApproval` ditolak, persetujuan habis
  setelah berhasil.
- VM + widget: QRIS tampil untuk staf tanpa izin, dialog PIN saat
  *Sudah Terbayar*, batal tidak menyimpan, sakelar di Pengaturan.

## Status & gap

| Bagian | Desain | Status | Catatan |
| --- | --- | --- | --- |
| PIN manajer untuk *Sudah Terbayar* | 1.26b, 1.2b | Rilis v0.138.0 | Kasir, bill, split, bagian menunggu. |
| Sakelar *Kasir boleh konfirmasi tanpa PIN manajer* | 1.26b | Rilis v0.138.0 | Bawaan hidup; manajer/pemilik tetap langsung. |
