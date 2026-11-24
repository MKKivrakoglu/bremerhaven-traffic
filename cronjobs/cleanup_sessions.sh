#!/usr/bin/env bash
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$PROJECT_ROOT/scripts/runtime.sh"
now="${EPOCHREALTIME%.*}"

shopt -s nullglob
for session in "$SESSION_DIR"/*/; do
  [[ -f "$session/heartbeat" ]] || continue
  last="$(cat "$session/heartbeat")"
  [[ "$last" =~ ^[0-9]+$ ]] || continue
  age=$((now - last))
  if (( age > 60 )); then
    rm -rf -- "$session"
  fi
done

