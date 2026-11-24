#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../queue/queue-lib.sh"
enqueue "${1:-}"
