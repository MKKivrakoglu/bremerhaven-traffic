#!/usr/bin/env bash
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$PROJECT_ROOT/scripts/runtime.sh"
mkdir -p "$SIM_MAIL_DIR"

recipient="${1:-unknown}"
safe_recipient="${recipient//[^[:alnum:]_.-]/_}"
message_file="$SIM_MAIL_DIR/$safe_recipient-mail"

printf 'Betreff: Anmeldung erkannt | WaterTraffics\n\n' > "$message_file"
printf 'Guten Tag %s,\n\nAm %s haben Sie sich erfolgreich in das System eingeloggt.\n' \
  "$recipient" "$(date +%F)" >> "$message_file"
