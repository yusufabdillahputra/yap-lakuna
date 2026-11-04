#!/usr/bin/env bash
# Cek versi rilis (F1-22): bila `version: X.Y.Z+N` di pubspec belum punya tag
# vX.Y.Z, CHANGELOG wajib punya bagian [X.Y.Z] dan nomor build N wajib lebih
# besar dari N di tag rilis terakhir (Play Console & App Store menolak
# versionCode / CFBundleVersion yang tidak naik).
#
# Tag terakhir dipilih dengan urutan versi (`-v:refname`); tag pra-rilis
# seperti v1.0.0-rc1 akan terurut setelah v1.0.0, jadi jangan dipakai.
#
# Keluaran untuk GitHub Actions ditulis ke $GITHUB_OUTPUT bila ada:
# version, build, release (true/false).
set -euo pipefail

pubspec="lakuna_flutter/pubspec.yaml"
line="$(grep -m1 -E '^version:' "$pubspec")"
full="${line#version: }"
version="${full%%+*}"
build="${full#*+}"
[ "$build" = "$full" ] && build=1
out="${GITHUB_OUTPUT:-/dev/null}"
echo "version=$version" >> "$out"
echo "build=$build" >> "$out"

# --exit-code: 0 = tag ada, 2 = tag tidak ada, lainnya = galat jaringan/git.
rc=0
git ls-remote --exit-code --tags origin "refs/tags/v$version" >/dev/null || rc=$?
if [ "$rc" -eq 0 ]; then
  echo "Tag v$version sudah ada; tidak ada rilis baru."
  echo "release=false" >> "$out"
  exit 0
elif [ "$rc" -ne 2 ]; then
  echo "::error::Gagal membaca tag dari origin (kode $rc)."
  exit "$rc"
fi

if ! grep -q "^## \[$version\]" CHANGELOG.md; then
  echo "::error::CHANGELOG.md belum punya bagian ## [$version]"
  exit 1
fi

prev="$(git ls-remote --tags --refs --sort=-v:refname origin 'v*' | awk 'NR==1 { sub(/.*refs\/tags\//, ""); print }')"
if [ -n "$prev" ]; then
  git fetch -q --depth 1 origin "refs/tags/$prev:refs/tags/$prev"
  prev_line="$(git show "$prev:$pubspec" | grep -m1 -E '^version:')"
  prev_full="${prev_line#version: }"
  prev_build="${prev_full#*+}"
  [ "$prev_build" = "$prev_full" ] && prev_build=0
  if [ "$build" -le "$prev_build" ]; then
    echo "::error::Nomor build $build harus lebih besar dari $prev_build ($prev). Naikkan +N di $pubspec."
    exit 1
  fi
  echo "Nomor build $build > $prev_build ($prev)."
fi
echo "release=true" >> "$out"
