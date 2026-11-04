#!/usr/bin/env bash
# Cek versi rilis (F1-22): bila `version: X.Y.Z+N` di pubspec belum punya tag
# vX.Y.Z, CHANGELOG wajib punya bagian [X.Y.Z] dan nomor build N wajib lebih
# besar dari N di tag rilis terakhir (Play Console & App Store menolak
# versionCode / CFBundleVersion yang tidak naik).
#
# Keluaran untuk GitHub Actions ditulis ke $GITHUB_OUTPUT bila ada:
# version, build, release (true/false).
set -euo pipefail

pubspec="lakuna_flutter/pubspec.yaml"
line="$(grep -E '^version:' "$pubspec" | head -1)"
full="${line#version: }"
version="${full%%+*}"
build="${full#*+}"
[ "$build" = "$full" ] && build=1
out="${GITHUB_OUTPUT:-/dev/null}"
echo "version=$version" >> "$out"
echo "build=$build" >> "$out"

if git ls-remote --exit-code --tags origin "refs/tags/v$version" >/dev/null; then
  echo "Tag v$version sudah ada; tidak ada rilis baru."
  echo "release=false" >> "$out"
  exit 0
fi

if ! grep -q "^## \[$version\]" CHANGELOG.md; then
  echo "::error::CHANGELOG.md belum punya bagian ## [$version]"
  exit 1
fi

prev="$(git ls-remote --tags --refs --sort=-v:refname origin 'v*' | head -1 | sed 's#.*refs/tags/##')"
if [ -n "$prev" ]; then
  git fetch -q --depth 1 origin "refs/tags/$prev:refs/tags/$prev"
  prev_line="$(git show "$prev:$pubspec" | grep -E '^version:' | head -1)"
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
