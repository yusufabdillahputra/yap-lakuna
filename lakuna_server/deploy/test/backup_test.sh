#!/bin/sh
# Tes backup.sh dengan pg_dump tiruan: sh lakuna_server/deploy/test/backup_test.sh
set -u
here=$(cd "$(dirname "$0")" && pwd)
script="$here/../backup.sh"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin"
fails=0
check() { if eval "$2"; then echo "ok   $1"; else echo "GAGAL $1"; fails=$((fails + 1)); fi; }

fake_pg_dump() { # $1 = isi skrip pg_dump tiruan
  printf '#!/bin/sh\n%s\n' "$1" > "$work/bin/pg_dump"
  chmod +x "$work/bin/pg_dump"
}
fresh_dir() {
  rm -rf "$work/b" && mkdir -p "$work/b"
  touch -t 202001010000 "$work/b/lakuna-20200101-000000.dump"
  touch "$work/b/lakuna-20200102-000000.dump.tmp"
}
run() { PATH="$work/bin:$PATH" BACKUP_DIR="$work/b" BACKUP_KEEP_DAYS=14 sh "$script" once >/dev/null 2>&1; }

# pg_dump gagal (mis. disk penuh setelah menulis sebagian).
fresh_dir
fake_pg_dump 'for a; do case "$a" in --file=*) echo sebagian > "${a#--file=}";; esac; done; exit 1'
run; rc=$?
check "gagal: kode keluar bukan 0" '[ "$rc" -ne 0 ]'
check "gagal: tidak ada dump baru" '[ "$(ls "$work/b" | grep -c "^lakuna-2026\|^lakuna-20[3-9]")" -eq 0 ]'
check "gagal: backup lama tidak dihapus" '[ -f "$work/b/lakuna-20200101-000000.dump" ]'
check "gagal: berkas .tmp dibuang" '! ls "$work/b" | grep -q "$(date -u +%Y%m%d).*\.tmp$"'

# pg_dump berhasil.
fresh_dir
fake_pg_dump 'for a; do case "$a" in --file=*) echo isi > "${a#--file=}";; esac; done'
run; rc=$?
check "berhasil: kode keluar 0" '[ "$rc" -eq 0 ]'
check "berhasil: dump baru ada" '[ "$(ls "$work/b" | grep -c "^lakuna-$(date -u +%Y%m%d)-[0-9]*\.dump$")" -eq 1 ]'
check "berhasil: backup lama dihapus" '[ ! -f "$work/b/lakuna-20200101-000000.dump" ]'
check "berhasil: sisa .tmp lama dibuang" '[ -z "$(ls "$work/b" | grep "\.tmp$")" ]'

[ "$fails" -eq 0 ] && echo "semua lulus" || { echo "$fails gagal"; exit 1; }
