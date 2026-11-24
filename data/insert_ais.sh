#!/usr/bin/env bash
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/scripts/runtime.sh"
require_database_config || exit 1
mkdir -p "$LOG_DIR"
error_log="$LOG_DIR/insert_ais.log"

while IFS='|' read -r date type mmsi d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 d16 d17 d18 d19 d20 d21 d22 d23 d24; do

alreadyExist="$(mariadb --defaults-file="$DB_DEFAULTS_FILE" -N -B -e "select MMSI from SCHIFFSINFOS WHERE MMSI = '$mmsi'")"

if test "$type" = "1" || test "$type" = "3"; then

  lon="$d9"
  lat="$d10"
  stat="$d4"
  stat_text="$d5"
  speed="$d7"

  mariadb --defaults-file="$DB_DEFAULTS_FILE" -e " 
  INSERT IGNORE INTO SCHIFFSINFOS (MMSI, DATUM) VALUES ('$mmsi', '$date');
  UPDATE SCHIFFSINFOS SET DATUM = '$date' WHERE MMSI = '$mmsi';
  insert into LOCATION (TYPE, MMSI, LON, LAT, DATUM, STATUS, STATUSTEXT, SPEED) VALUES ('$type', '$mmsi', '$lon', '$lat', '$date', '$stat', '$stat_text', '$speed');
  " 2>>"$error_log"

elif test "$type" = "5"; then

  imo="$d4"
  name="$d6"
  callsign="$d5"
  radio="$d17"
  destination="$d21"

  if test "$alreadyExist" = "$mmsi"; then
    mariadb --defaults-file="$DB_DEFAULTS_FILE" -e "
    update SCHIFFSINFOS SET NAME = '$name', CALLSIGN = '$callsign', DATUM = '$date' WHERE MMSI = '$mmsi';" 2>>"$error_log" 
  else
    mariadb --defaults-file="$DB_DEFAULTS_FILE" -e "
    insert ignore into SCHIFFSINFOS(MMSI, IMO, NAME, CALLSIGN, DATUM) values('$mmsi', '$imo', '$name', '$callsign', '$date');" 2>>"$error_log"
  fi

  mariadb --defaults-file="$DB_DEFAULTS_FILE" -e "
  insert into LOCATION (TYPE, MMSI, DATUM, ZIEL, RADIO) VALUES ('$type', '$mmsi', '$date', '$destination', '$radio');
  " 2>>"$error_log"

elif test "$type" = "18"; then

  speed="$d4"
  lon="$d6"
  lat="$d7"
  radio="$d12"


  mariadb --defaults-file="$DB_DEFAULTS_FILE" -e " 
  INSERT IGNORE INTO SCHIFFSINFOS (MMSI, DATUM) VALUES ('$mmsi', '$date');
  insert into LOCATION (TYPE, MMSI, LON, LAT, DATUM, SPEED, RADIO) VALUES ('$type', '$mmsi', '$lon', '$lat', '$date', '$speed', '$radio');
  " 2>>"$error_log"

elif test "$type" = "24"; then

  mariadb --defaults-file="$DB_DEFAULTS_FILE" -e " 
  INSERT IGNORE INTO SCHIFFSINFOS (MMSI, DATUM) VALUES ('$mmsi', '$date');
  insert into LOCATION (TYPE, MMSI, DATUM) VALUES ('$type', '$mmsi', '$date');
  " 2>>"$error_log"
fi
done
