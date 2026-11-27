# Rencana F1-04j · Setujui ulang diskon rupiah bila pesanan berkurang

Spec: `docs/superpowers/specs/2026-11-27-f1-04j-setujui-ulang-diskon-rupiah-design.md`

- [x] 1. Domain: tes dulu, lalu `discountReapprovalDue`.
- [x] 2. Model `Sale.discountBase` + migrasi `dasar-diskon`, `serverpod
  generate`.
- [x] 3. Data: tes gagal dulu (dasar tersimpan, bayar/bayar bagian
  ditolak, tanda hilang saat pesanan bertambah, setujui ulang dengan
  penyetuju, bill lama), lalu `setBillDiscount`, `_assertPayable`,
  `OpenBill.discountNeedsReapproval`.
- [x] 4. VM Meja `discountNeedsReapproval` / `discountBlocksPay`; pesan dan
  tombol *Setujui ulang diskon*; galat di Meja, Pembayaran, Split; fake
  repositori; tes VM dan widget 1280/360.
- [x] 5. Dokumen: spec F1-04e gap, README specs, STATUS-JEDA, GAP-FASE1,
  panduan ID/EN Diskon, CHANGELOG, pubspec.
- [x] 6. Format, analyze, semua tes, review subagent, uji Xvfb. Review:
  ganti pelanggan tidak lagi ditolak (`_assertDiscountFits`), petunjuk
  untuk staf tanpa izin diskon, dok komentar, spec diperbarui.
- [ ] 7. PR dan rilis.
