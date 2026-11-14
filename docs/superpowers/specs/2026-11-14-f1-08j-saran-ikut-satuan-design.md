# F1-08j · Jumlah saran stok minimum ikut satuan

- **Fase:** 1
- **Status:** Rilis v0.96.0
- **Layar:** 1.19 form *Pembelian baru* / *Draf* yang terisi dari Stok ›
  *Stok minimum* (F1-08c, F1-08i).
- **Acuan:** gap "Jumlah saran bisa diatur (kelipatan dus, target stok)" di
  [F1-08c](2026-11-14-f1-08c-pembelian-dari-stok-minimum-design.md), bagian
  satuan. Storeku tidak punya aturan ini.

## Masalah

Baris dari stok minimum terisi jumlah saran dalam satuan dasar (mis. 38
botol). Saat staf mengganti satuan ke *Dus (6)* karena supplier menjual per
dus, angka 38 tetap, jadi baris menjadi 38 dus = 228 botol. Staf harus
menghitung sendiri 38 ÷ 6 dan mudah kebablasan memesan enam kali lipat.

## Aturan

1. Baris yang terisi dari stok minimum mengingat **saran** dalam satuan
   dasar.
2. Selama staf belum mengubah jumlahnya, mengganti satuan mengonversi
   saran ke satuan baru dan **dibulatkan ke atas** ke satuan utuh: 38 botol
   → 7 dus (isi 6), 36 botol → 6 dus; kembali ke botol → 38 lagi.
3. Begitu staf mengetik jumlah atau menambah lewat scan ulang (+1), saran
   dilupakan: mengganti satuan kembali ke perilaku lama (angka tetap).
4. Baris yang ditambah manual tidak berubah perilakunya.
5. Bila satuan baru sudah punya baris kembar untuk varian yang sama (baris
   digabung, perilaku lama), yang ditambahkan adalah saran yang sudah
   dikonversi.

## Rancangan teknis

- `PurchaseFormLine.suggested` (`Qty?`, satuan dasar) dan
  `suggestedIn(unit)` = ⌈saran.milli ÷ faktor.milli⌉ satuan.
  `copyWith` melupakan saran setiap kali `quantity` diisi, kecuali
  pemanggil memberi `keepSuggested: true` (hanya `setUnit`), agar
  pemanggil baru tidak membawa saran basi.
- `_applyRestock` mengisi `suggested` = jumlah saran (berlaku juga untuk
  tambahan ke draf F1-08i).
- `setUnit` memakai `suggestedIn` bila ada; `setQuantity` (bila angkanya
  berubah) dan scan ulang `addByCode` melupakan saran.
- Isian jumlah dibangun ulang karena `generation` naik saat satuan
  diganti (perilaku lama).

## Pengujian

- VM: 38 → 7 dus → 38 botol; 36 → 6 dus; setelah ketik jumlah tidak
  dikonversi; isian jumlah yang sama tidak melupakan saran; scan ulang +1
  menghentikan konversi; digabung ke baris dus kembar = 1 + 7 dus; barang
  manual tetap. Dua tes terakhir diverifikasi mutasi.
- Widget (`stock_flow_test.dart`, 1280 / 360 px): *Buat pembelian*, ganti
  satuan baris Minyak ke *Dus (6)*, isian jumlah menjadi 7 (diverifikasi
  mutasi).
- Uji manual Xvfb: ganti satuan baris saran di form pembelian.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Jumlah saran ikut satuan saat satuan diganti | 1.19 | Rilis v0.96.0 | Dibulatkan ke atas ke satuan utuh. |
| Satuan beli bawaan per barang (langsung dus) | — | Belum | Saran selalu mulai dalam satuan dasar. |
| Target stok selain 2 × minimum | — | Belum | Rumus tetap 2 × minimum − stok. |
| Saran setelah draf disimpan lalu dibuka lagi | — | Belum | Draf yang dibuka ulang tidak menyimpan saran, jadi ganti satuan kembali mempertahankan angka. |
| Gabung baris kembar tanpa saran | — | Belum | Perilaku lama: angka satuan lama ditambahkan apa adanya (2 dus + baris 5 botol → 7 botol). |
