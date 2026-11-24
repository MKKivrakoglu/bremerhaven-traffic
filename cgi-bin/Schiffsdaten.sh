#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib/runtime.sh"
printf 'Content-Type: text/plain\r\n\r\n'
if ! require_database_config; then
  exit 1
fi

SQL="SELECT s.MMSI, s.NAME, l.LAT, l.LON, l.DATUM
     FROM SCHIFFSINFOS s
     JOIN LOCATION l ON s.MMSI = l.MMSI
     WHERE l.DATUM > (NOW() - INTERVAL 1 HOUR)
       AND l.LAT IS NOT NULL
       AND l.LON IS NOT NULL;"

mariadb --defaults-file="$DB_DEFAULTS_FILE" -B -N -e "$SQL" | while IFS=$'\t' read -r MMSI NAME LAT LON DATUM; do
  printf '%s|%s|%s|%s|%s\n' "$MMSI" "$NAME" "$LAT" "$LON" "$DATUM"
done
