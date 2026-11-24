#!/usr/bin/env bash
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/scripts/runtime.sh"
require_database_config || exit 1
mkdir -p "$LOG_DIR"

TABLE_NAME="LOCATION"
TABLE_NAME2="SCHIFFSINFOS"
LOG_FILE="$LOG_DIR/cleanup-$(date +%F).log"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Starte Löschung..." > "$LOG_FILE"

# Löschen + betroffene Zeilen zählen
ROWS_DELETED="$(mariadb --defaults-file="$DB_DEFAULTS_FILE" -N -B -e \
  "DELETE FROM $TABLE_NAME WHERE DATUM < (NOW() - INTERVAL 8 DAY); SELECT ROW_COUNT()")" 2>>"$LOG_FILE"

ROWS_DELETED2="$(mariadb --defaults-file="$DB_DEFAULTS_FILE" -N -B -e \
  "DELETE FROM $TABLE_NAME2 WHERE DATUM < (NOW() - INTERVAL 8 DAY); SELECT ROW_COUNT()")" 2>>"$LOG_FILE"

if test -z "$ROWS_DELETED"; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Fehler beim Ausführen des SQL-Befehls." >> "$LOG_FILE"
elif test "$ROWS_DELETED" -gt 0; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $ROWS_DELETED Zeilen gelöscht von $TABLE_NAME." >> "$LOG_FILE"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $ROWS_DELETED2 Zeilen gelöscht von $TABLE_NAME2." >> "$LOG_FILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Keine Zeilen zum Löschen gefunden." >> "$LOG_FILE"
fi

