#!/usr/bin/env bash
# Membuat paket .deb dari hasil `flutter build linux --release`.
# Pemakaian: tools/packaging/linux/build-deb.sh <versi> <folder-bundle> <folder-keluaran>
set -euo pipefail

version="$1"
bundle="$2"
out="$3"
here="$(cd "$(dirname "$0")" && pwd)"

root="$(mktemp -d)/lakuna_${version}_amd64"
mkdir -p "$root/DEBIAN" "$root/opt/lakuna" "$root/usr/bin" \
  "$root/usr/share/applications" "$root/usr/share/icons/hicolor/512x512/apps"

cp -r "$bundle"/. "$root/opt/lakuna/"
ln -s /opt/lakuna/lakuna "$root/usr/bin/lakuna"
cp "$here/lakuna.desktop" "$root/usr/share/applications/id.lakuna.app.desktop"
cp "$here/../../../lakuna_flutter/web/icons/Icon-512.png" \
  "$root/usr/share/icons/hicolor/512x512/apps/id.lakuna.app.png"

installed_kb="$(du -sk "$root" | cut -f1)"
cat >"$root/DEBIAN/control" <<CONTROL
Package: lakuna
Version: ${version}
Section: misc
Priority: optional
Architecture: amd64
Maintainer: Yusuf Abdillah Putra <noreply@users.noreply.github.com>
Installed-Size: ${installed_kb}
Depends: libgtk-3-0
Homepage: https://github.com/yusufabdillahputra/yap-lakuna
Description: Aplikasi kasir offline-first untuk UMKM Indonesia
 Lakuna adalah aplikasi kasir (POS) untuk usaha Retail dan F&B yang
 menyimpan data di perangkat dan tetap berjalan tanpa internet.
CONTROL

mkdir -p "$out"
dpkg-deb --build --root-owner-group "$root" "$out/lakuna_${version}_amd64.deb"
