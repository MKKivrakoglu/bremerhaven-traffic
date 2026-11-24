#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib/runtime.sh"
printf 'Content-Type: text/plain\r\n\r\n'
if ! require_database_config; then
  exit 1
fi

mariadb --defaults-file="$DB_DEFAULTS_FILE" -N -e "
SELECT l.TYPE, s.MMSI, s.NAME, s.CALLSIGN, l.LON, l.LAT, l.DATUM, l.SPEED, l.RADIO, s.IMO
FROM SCHIFFSINFOS s
JOIN LOCATION l ON s.MMSI = l.MMSI
WHERE l.DATUM > (NOW() - INTERVAL  5 MINUTE)
AND l.LAT IS NOT NULL
AND l.LON IS NOT NULL
LIMIT 35;
" | while IFS=$'\t' read -r type mmsi name cs lon lat date speed radio imo; do
  printf '%s|%s|%s|%s|%s|%s|%s|%s|%s|%s\n' "$type" "$mmsi" "$name" "$cs" "$lon" "$lat" "$date" "$speed" "$radio" "$imo"
done

