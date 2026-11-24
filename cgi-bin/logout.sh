#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/lib/runtime.sh"
cookie="${HTTP_COOKIE#*=}"

printf 'Content-Type: text/plain\r\nSet-Cookie: mysession=; Expires=Thu, 01 Jan 1970 00:00:00 GMT; Path=/; HttpOnly; SameSite=Lax\r\n\r\n'
if [[ "$cookie" =~ ^[[:alnum:]-]+$ && -d "$SESSION_DIR/$cookie" ]]; then
  rm -rf -- "$SESSION_DIR/$cookie"
fi

