#!/usr/bin/env bash

PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$PROJECT_ROOT/scripts/runtime.sh"
mkdir -p "$QUEUE_DIR" "$LOG_DIR"
[[ -f "$QUEUE_DIR/head" ]] || printf '%s\n' '-' > "$QUEUE_DIR/head"
[[ -f "$QUEUE_DIR/tail" ]] || printf '%s\n' '-' > "$QUEUE_DIR/tail"

addhead() {
  local timestamp name value
  timestamp="${EPOCHREALTIME/[.,]}"
  name="node-$timestamp"
  value="${1:-}"
  printf '%s - %s\n' "$timestamp" "$value" > "$QUEUE_DIR/$name"
  printf '%s\n' "$name" > "$QUEUE_DIR/head"
  printf '%s\n' "$name" > "$QUEUE_DIR/tail"
  printf 'Data: %s\n' "$name"
}

enqueue() {
  local value head_value last_node timestamp new_node last_timestamp next_node node_value
  value="${1:-}"
  while ! mkdir "$QUEUE_DIR/lockdir" 2>/dev/null; do
    sleep 0.01
  done

  read -r head_value < "$QUEUE_DIR/head"
  if [[ "$head_value" == "-" ]]; then
    addhead "$value"
  else
    read -r last_node < "$QUEUE_DIR/tail"
    timestamp="${EPOCHREALTIME/[.,]}"
    new_node="node-$timestamp"
    printf '%s - %s\n' "$timestamp" "$value" > "$QUEUE_DIR/$new_node"
    IFS=' ' read -r last_timestamp next_node node_value < "$QUEUE_DIR/$last_node"
    printf '%s %s %s\n' "$last_timestamp" "$new_node" "$node_value" > "$QUEUE_DIR/$last_node"
    printf 'Data: %s\n' "$new_node" >> "$LOG_DIR/Queue_created.log"
    printf '%s\n' "$new_node" > "$QUEUE_DIR/tail"
  fi

  rmdir "$QUEUE_DIR/lockdir"
}

dequeue() {
  local oldest timestamp next_node value
  while ! mkdir "$QUEUE_DIR/lockdir" 2>/dev/null; do
    sleep 0.01
  done

  read -r oldest < "$QUEUE_DIR/head"
  if [[ "$oldest" != "-" ]]; then
    IFS=' ' read -r timestamp next_node value < "$QUEUE_DIR/$oldest"
    printf '%s\n' "$next_node" > "$QUEUE_DIR/head"
    rm -f -- "$QUEUE_DIR/$oldest" 2>/dev/null
    printf 'Data: %s\n' "$oldest" >> "$LOG_DIR/Queue_deleted.log"
    DEQUEUED="$value"
  else
    DEQUEUED=""
    printf '%s\n' '-' > "$QUEUE_DIR/head"
    printf '%s\n' '-' > "$QUEUE_DIR/tail"
  fi

  rmdir "$QUEUE_DIR/lockdir"
}
