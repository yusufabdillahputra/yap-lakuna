#!/bin/sh
# Membuat ulang aset SQLite untuk build web (F2-02 aturan 6): sqlite3.wasm
# dari rilis paket `sqlite3` yang terkunci di pubspec.lock, dan db_worker.js
# dari worker `sqlite_async`. Keduanya di-commit di lakuna_flutter/web/
# agar build web tidak mengunduh apa pun.
#   sh tool/web_sqlite_assets.sh          # tulis ulang aset
#   sh tool/web_sqlite_assets.sh --check  # gagal bila versi tidak cocok
set -eu
root=$(cd "$(dirname "$0")/.." && pwd)
web="$root/lakuna_flutter/web"
version=$(awk '/^  sqlite3:$/{f=1} f&&/version:/{gsub(/"/,"",$2);print $2;exit}' "$root/pubspec.lock")
async=$(awk '/^  sqlite_async:$/{f=1} f&&/version:/{gsub(/"/,"",$2);print $2;exit}' "$root/pubspec.lock")
stamp="sqlite3 $version, sqlite_async $async"
if [ "${1:-}" = "--check" ]; then
  have=$(cat "$web/sqlite_assets.version" 2>/dev/null || true)
  if [ "$have" != "$stamp" ]; then
    echo "Aset SQLite web ($have) tidak cocok dengan pubspec.lock ($stamp)." >&2
    echo "Jalankan: sh tool/web_sqlite_assets.sh" >&2
    exit 1
  fi
  exit 0
fi
curl -fsSL -o "$web/sqlite3.wasm" \
  "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-$version/sqlite3.wasm"
cd "$root"
dart compile js tool/web/db_worker.dart -o "$web/db_worker.js" -O4 \
  -Dsqlite3.dartbigints=false
rm -f "$web/db_worker.js.deps" "$web/db_worker.js.map"
echo "$stamp" > "$web/sqlite_assets.version"
echo "Aset SQLite web diperbarui: $stamp"
