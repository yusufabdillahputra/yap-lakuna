#!/bin/sh
# Memastikan build web tidak memuat aset dari internet (F2-02 aturan 25).
# Pakai: sh tool/check_web_offline.sh lakuna_flutter/build/web
set -eu
dir=${1:-lakuna_flutter/build/web}
fail=0
if grep -Eq '(src|href)="https?://' "$dir/index.html"; then
  echo "index.html memuat sumber jaringan"; fail=1
fi
if ! grep -q '"useLocalCanvasKit":true' "$dir/flutter_bootstrap.js"; then
  echo "CanvasKit bukan lokal (build tanpa --no-web-resources-cdn?)"; fail=1
fi
if ! grep -q 'fontFallbackBaseUrl' "$dir/flutter_bootstrap.js"; then
  echo "fontFallbackBaseUrl tidak diatur (font cadangan dari Google)"; fail=1
fi
for f in canvaskit/canvaskit.wasm sqlite3.wasm db_worker.js; do
  [ -f "$dir/$f" ] || { echo "aset hilang: $f"; fail=1; }
done
[ "$fail" -eq 0 ] && echo "Build web offline: OK"
exit "$fail"
