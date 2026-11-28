#!/bin/sh
# Backup database server Lakuna dengan pg_dump (format custom, terkompresi).
#   lakuna-backup once   satu backup sekarang
#   lakuna-backup loop   backup sekarang lalu setiap 24 jam (layanan compose)
set -eu
umask 077

backup_once() {
  name="lakuna-$(date -u +%Y%m%d-%H%M%S).dump"
  pg_dump --format=custom --file="/backups/$name.tmp"
  mv "/backups/$name.tmp" "/backups/$name"
  find /backups -name 'lakuna-*.dump' -mtime +"${BACKUP_KEEP_DAYS:-14}" -delete
  echo "backup: /backups/$name"
}

case "${1:-once}" in
  once) backup_once ;;
  loop)
    while true; do
      backup_once || echo "backup gagal" >&2
      sleep 86400
    done
    ;;
  *) echo "pakai: lakuna-backup once|loop" >&2; exit 64 ;;
esac
