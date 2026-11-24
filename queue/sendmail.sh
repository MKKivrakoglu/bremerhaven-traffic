#!/usr/bin/env bash
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/queue/queue-lib.sh"
MAIL_ADAPTER="${MAIL_ADAPTER:-$PROJECT_ROOT/queue/mail/email.sh}"
mkdir -p "$LOG_DIR"

while true; do
  sleep 0.3
  dequeue
  if [[ -n "$DEQUEUED" ]]; then
    printf '%s | simulated email for %s\n' "$(date +%F:%T)" "$DEQUEUED" >> "$LOG_DIR/sendmail.log"
    "$MAIL_ADAPTER" "$DEQUEUED"
  fi
  printf '%s\n' "${EPOCHREALTIME/[.,]}" > "$QUEUE_DIR/checkTimestamp"
done
