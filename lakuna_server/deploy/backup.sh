#!/bin/sh
# Backup database server Lakuna dengan pg_dump (format custom, terkompresi).
#   lakuna-backup once   satu backup sekarang
#   lakuna-backup loop   backup sekarang lalu setiap 24 jam (layanan compose)
# Backup lama hanya dihapus setelah backup baru berhasil, jadi backup yang
# gagal berhari-hari tidak pernah menghabiskan backup yang masih baik.
set -u
umask 077
dir="${BACKUP_DIR:-/backups}"

backup_once() {
  name="lakuna-$(date -u +%Y%m%d-%H%M%S).dump"
  tmp="$dir/$name.tmp"
  if ! pg_dump --format=custom --file="$tmp"; then
    rm -f "$tmp"
    echo "backup gagal: pg_dump" >&2
    return 1
  fi
  if ! mv "$tmp" "$dir/$name"; then
    rm -f "$tmp"
    echo "backup gagal: mv" >&2
    return 1
  fi
  # Sisa .tmp dari backup yang terputus, lalu backup yang lebih tua dari
  # BACKUP_KEEP_DAYS hari.
  find "$dir" -maxdepth 1 -name 'lakuna-*.dump.tmp' -delete
  find "$dir" -maxdepth 1 -name 'lakuna-*.dump' -mtime +"${BACKUP_KEEP_DAYS:-14}" -delete
  echo "backup: $dir/$name"
}

case "${1:-once}" in
  once) backup_once ;;
  loop)
    while true; do
      backup_once || true
      sleep 86400
    done
    ;;
  *) echo "pakai: lakuna-backup once|loop" >&2; exit 64 ;;
esac
