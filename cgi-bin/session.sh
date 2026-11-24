#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib/runtime.sh"
cookie="${HTTP_COOKIE#*=}"

if [[ "$cookie" =~ ^[[:alnum:]-]+$ && -d "$SESSION_DIR/$cookie" ]]; then
  printf 'Content-Type: text/plain\r\n\r\n'
  printf '%s\n' "${EPOCHREALTIME%.*}" > "$SESSION_DIR/$cookie/heartbeat"
else
  printf 'Status: 303 See Other\r\nContent-Type: text/plain\r\n\r\n'
fi
