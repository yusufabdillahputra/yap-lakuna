# Pemberitahuan pihak ketiga

Lakuna memakai karya pihak ketiga berikut. Lisensi lengkap paket Dart dan
Flutter juga tampil di aplikasi (halaman lisensi Flutter) dan di folder
paket masing-masing.

## Font yang dibundel

| Font | Pemegang hak cipta | Lisensi | Berkas |
| --- | --- | --- | --- |
| Montserrat | The Montserrat Project Authors | SIL Open Font License 1.1 | `lakuna_flutter/assets/fonts/Montserrat/LICENSE.txt` |
| DM Sans | The DM Sans Project Authors | SIL Open Font License 1.1 | `lakuna_flutter/assets/fonts/DM_Sans/LICENSE.txt` |
| DM Mono (struk) | The DM Mono Project Authors | SIL Open Font License 1.1 | `lakuna_flutter/assets/fonts/DM_Mono/LICENSE.txt` |

## Ikon dan komponen

| Karya | Lisensi |
| --- | --- |
| Ikon Tabler lewat paket `tabler_icons_plus` | MIT |
| Forui (komponen UI) | MIT |
| `pdf`, `printing` (PDF dan dialog cetak struk) | Apache-2.0 |
| `print_bluetooth_thermal` (printer Bluetooth) | BSD-3-Clause |
| Paket klien Serverpod yang ikut di aplikasi (`serverpod_client`, `serverpod_database`, dll.) | BSD-3-Clause |
| Paket server `serverpod` (hanya di `lakuna_server`, tidak ikut di aplikasi) | Server Side Public License v1 |
| Flutter dan Dart SDK | BSD-3-Clause |

Catatan SSPL: menurut README Serverpod, server boleh di-host tanpa batasan
selama tidak menawarkan Serverpod itu sendiri sebagai layanan cloud kepada
pihak ketiga. Layanan hosted Lakuna (fase 2) menawarkan aplikasi kasir,
bukan Serverpod sebagai layanan.

## Logo dan ikon aplikasi

Mark "Etalase" pada logo dan ikon aplikasi Lakuna memakai ikon
`shop-window` dari [Bootstrap Icons](https://github.com/twbs/icons) (lewat
gaya DiceBear `icons`), diwarnai ulang ke gradien Sky. Dibuat sekali oleh
`tools/brand/render.mjs` dan `tools/brand/make_icons.py`, lalu di-commit.
Teks lisensinya juga tampil di aplikasi (Pengaturan › Tentang Lakuna).

```
The MIT License (MIT)

Copyright (c) 2019-2024 The Bootstrap Authors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
