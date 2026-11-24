# Shared paths and local configuration for the project scripts.
# Set PROJECT_ROOT before sourcing this file when the script is not under scripts/.
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

if [[ -r "$PROJECT_ROOT/config/runtime.env" ]]; then
  # This file is local server configuration and must not be committed.
  # shellcheck disable=SC1091
  source "$PROJECT_ROOT/config/runtime.env"
fi

DB_DEFAULTS_FILE="${DB_DEFAULTS_FILE:-$PROJECT_ROOT/config/mariadb.cnf}"
QUEUE_DIR="${QUEUE_DIR:-$PROJECT_ROOT/var/queue}"
LOG_DIR="${LOG_DIR:-$PROJECT_ROOT/var/log}"
STATE_DIR="${STATE_DIR:-$PROJECT_ROOT/var/run}"
SESSION_DIR="${SESSION_DIR:-${TMPDIR:-/tmp}/bremerhaven-traffic-sessions}"
SIM_MAIL_DIR="${SIM_MAIL_DIR:-$PROJECT_ROOT/var/mail/sim}"

export PROJECT_ROOT DB_DEFAULTS_FILE QUEUE_DIR LOG_DIR STATE_DIR SESSION_DIR SIM_MAIL_DIR

require_database_config() {
  if [[ ! -r "$DB_DEFAULTS_FILE" ]]; then
    printf 'Database config is missing or unreadable: %s\n' "$DB_DEFAULTS_FILE" >&2
    return 1
  fi
}
