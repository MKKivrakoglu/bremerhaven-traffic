#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib/runtime.sh"

if ! require_database_config; then
  printf 'Status: 500 Internal Server Error\r\nContent-Type: text/plain\r\n\r\nLogin is not configured.\n'
  exit 1
fi

user="${QUERY_STRING%%|*}"
pass="${QUERY_STRING#*|}"

# Escape SQL string delimiters because the recovered endpoint receives credentials
# as a legacy pipe-delimited query string rather than using prepared statements.
sql_user="${user//\\/\\\\}"
sql_user="${sql_user//\'/\'\'}"
sql_pass="${pass//\\/\\\\}"
sql_pass="${sql_pass//\'/\'\'}"

result="$(mariadb --defaults-file="$DB_DEFAULTS_FILE" -B -N -e \
  "SELECT username FROM anmelden WHERE username='${sql_user}' AND pass='${sql_pass}' LIMIT 1;" 2>/dev/null)"

if [[ -n "$result" ]]; then
  "$PROJECT_ROOT/cgi-bin/warteschlange.sh" "$user" >/dev/null
  token="$(pwgen 40 1)"
  mkdir -p "$SESSION_DIR/$token"
  touch "$SESSION_DIR/$token/heartbeat"
  printf 'Content-Type: text/plain\r\nSet-Cookie: mysession=%s; Path=/; HttpOnly; SameSite=Lax\r\n\r\n' "$token"
else
  printf 'Status: 403 Forbidden\r\nContent-Type: text/plain\r\n\r\n'
fi
