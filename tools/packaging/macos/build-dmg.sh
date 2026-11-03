#!/usr/bin/env bash
# Membuat .dmg dari Lakuna.app. hdiutil kadang gagal "Resource busy" di
# runner GitHub, jadi dicoba ulang beberapa kali.
# Pemakaian: tools/packaging/macos/build-dmg.sh <versi> <Lakuna.app> <folder-keluaran>
set -euo pipefail

version="$1"
app="$2"
out="$3"

stage="$(mktemp -d)/Lakuna"
mkdir -p "$stage" "$out"
cp -R "$app" "$stage/"
ln -s /Applications "$stage/Applications"

dmg="$out/Lakuna-${version}-macos.dmg"
for attempt in 1 2 3 4 5; do
  if hdiutil create -volname "Lakuna" -srcfolder "$stage" -ov -format UDZO "$dmg"; then
    exit 0
  fi
  echo "hdiutil gagal (percobaan $attempt), coba lagi..." >&2
  sleep $((attempt * 5))
done
exit 1
