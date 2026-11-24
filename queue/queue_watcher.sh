#!/usr/bin/env bash
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/queue/queue-lib.sh"
mkdir -p "$STATE_DIR" "$LOG_DIR"

timestamp_file="$QUEUE_DIR/checkTimestamp"
last_pid_file="$STATE_DIR/sendmail.pid"
error_log="$LOG_DIR/queue_watcher_error.log"
success_log="$LOG_DIR/queue_watcher_success.log"
last_diff_log="$LOG_DIR/queue_watcher_diff.log"
[[ -r "$timestamp_file" ]] || exit 0

read -r timestamp < "$timestamp_file"
last_process="$(cat "$last_pid_file" 2>/dev/null || true)"
new_timestamp="${EPOCHREALTIME/[.,]}"
diff="$(((new_timestamp - timestamp) / 1000))"
printf 'Difference: %s ms\n' "$diff" >> "$last_diff_log"

if (( diff > 800 )); then
  printf '%s - restarting queue worker\n' "$(date '+%F %T')" >> "$error_log"
  if [[ "$last_process" =~ ^[0-9]+$ ]]; then
    kill "$last_process" 2>>"$error_log" || true
  fi
  "$PROJECT_ROOT/queue/sendmail.sh" &
  printf '%s\n' "$!" > "$last_pid_file"
else
  printf '%s - queue worker is active\n' "$(date '+%F %T')" >> "$success_log"
fi
