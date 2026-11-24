#!/usr/bin/env bash
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/scripts/runtime.sh"
require_database_config || exit 1
mkdir -p "$LOG_DIR" "$STATE_DIR"

last_line_file="$STATE_DIR/ais-last-line"
last_pid_file="$STATE_DIR/ais-last-pid"
error_log="$LOG_DIR/watcher_error.log"
success_log="$LOG_DIR/watcher_success.log"
last_line="$(cat "$last_line_file" 2>/dev/null || true)"
last_process="$(cat "$last_pid_file" 2>/dev/null || true)"
active_line="$(mariadb --defaults-file="$DB_DEFAULTS_FILE" -B -N -e 'select count(*) from LOCATION')"
printf '%s\n' "$active_line" > "$last_line_file"

if [[ -n "$last_line" && "$last_line" == "$active_line" ]]; then
  printf '%s - restarting AIS stream\n' "$(date '+%F %T')" >> "$error_log"
  if [[ "$last_process" =~ ^[0-9]+$ ]]; then
    kill "$last_process" 2>>"$error_log" || true
  fi
  ncat -e "$PROJECT_ROOT/data/insert_ais.sh" rhodes 8082 2>>"$error_log" &
  printf '%s\n' "$!" > "$last_pid_file"
else
  printf '%s - AIS data is changing\n' "$(date '+%F %T')" >> "$success_log"
fi

