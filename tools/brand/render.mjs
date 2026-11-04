// Merender master ikon dan grafik store Lakuna dari mark Etalase
// (Bootstrap Icons `shop-window`, MIT; lewat DiceBear `icons`).
// Dijalankan sekali saat merek berubah; hasilnya di-commit.
//
//   node tools/brand/render.mjs <folder-keluaran>
//
// Butuh Playwright + Chromium. Keluaran: master-rounded.png,
// master-square.png, master-macos.png (1024×1024), feature-graphic.png
// (1024×500). `make_icons.py` menurunkan semua ukuran platform.
import { readFileSync, mkdirSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const { chromium } = require('playwright');

const here = dirname(fileURLToPath(import.meta.url));
const repo = resolve(here, '..', '..');
const out = resolve(process.argv[2] ?? join(here, 'out'));
mkdirSync(out, { recursive: true });

const mark = readFileSync(join(here, 'shop-window.path'), 'utf8').trim();
// Font sebagai data URL: halaman setContent tidak boleh memuat file://.
const font = (file) =>
  'data:font/ttf;base64,' +
  readFileSync(join(repo, 'lakuna_flutter/assets/fonts', file)).toString('base64');

// Sky conhcc: #00A6F4 → #0069A8, ikon #F0F9FF.
const gradient = `<linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
  <stop offset="0" stop-color="#00A6F4"/><stop offset="1" stop-color="#0069A8"/>
</linearGradient>`;
const glyph = `<path transform="translate(20 18.125) scale(3.75)" d="${mark}" fill="#F0F9FF"/>`;

/** Kotak 100×100: [radius] 22 (membulat) atau 0 (penuh, iOS/Play). */
const icon = (radius) => `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="100%" height="100%">
  <defs>${gradient}</defs>
  <rect width="100" height="100" rx="${radius}" fill="url(#g)"/>${glyph}</svg>`;

const page = (body, w, h) => `<!doctype html><html><head><style>
@font-face { font-family: Montserrat; src: url('${font('Montserrat/Montserrat.ttf')}'); font-weight: 100 900; }
@font-face { font-family: 'DM Sans'; src: url('${font('DM_Sans/DMSans.ttf')}'); font-weight: 100 900; }
html, body { margin: 0; width: ${w}px; height: ${h}px; background: transparent; }
</style></head><body>${body}</body></html>`;

const jobs = [
  ['master-rounded.png', 1024, 1024, icon(22)],
  ['master-square.png', 1024, 1024, icon(0)],
  // macOS: kotak membulat 824 px di tengah kanvas 1024 (grid ikon Apple).
  [
    'master-macos.png',
    1024,
    1024,
    `<div style="position:absolute;left:100px;top:100px;width:824px;height:824px;filter:drop-shadow(0 10px 14px rgba(0,0,0,.28))">${icon(22)}</div>`,
  ],
  [
    'feature-graphic.png',
    1024,
    500,
    `<div style="width:1024px;height:500px;box-sizing:border-box;padding:0 80px;display:flex;align-items:center;gap:48px;
      background:linear-gradient(135deg,#F0F9FF 0%,#DFF2FE 55%,#B8E6FE 100%);font-family:'DM Sans'">
      <div style="width:220px;height:220px;flex:none;filter:drop-shadow(0 12px 24px rgba(0,105,168,.35))">${icon(22)}</div>
      <div>
        <div style="font-family:Montserrat;font-weight:800;font-size:96px;color:#052F4A;letter-spacing:-2px;line-height:1">Lakuna</div>
        <div style="margin-top:18px;font-size:34px;font-weight:500;color:#00598A;line-height:1.3">Kasir offline untuk toko,<br>warung &amp; kafe</div>
      </div>
    </div>`,
  ],
];

const browser = await chromium.launch();
const tab = await browser.newPage({ deviceScaleFactor: 1 });
for (const [name, w, h, body] of jobs) {
  await tab.setViewportSize({ width: w, height: h });
  await tab.setContent(page(body, w, h), { waitUntil: 'load' });
  await tab.evaluate(() => document.fonts.ready);
  await tab.screenshot({
    path: join(out, name),
    omitBackground: !name.startsWith('feature'),
  });
  console.log(name);
}
await browser.close();
