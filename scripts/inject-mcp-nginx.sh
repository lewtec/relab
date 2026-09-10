#!/usr/bin/env bash
# Insert the Selkies /mcp/ proxy into linuxserver's nginx template.
set -euo pipefail

conf="${1:-/defaults/default.conf}"
if [[ ! -f "$conf" ]]; then
  echo "missing nginx template: $conf" >&2
  exit 1
fi

count="$(grep -c '^  error_page 500 502 503 504 /50x.html;' "$conf" || true)"
if [[ "$count" -lt 1 ]]; then
  echo "nginx template has no error_page anchors: $conf" >&2
  exit 1
fi

snippet='  location SUBFOLDERmcp/ {
    proxy_set_header        Upgrade $http_upgrade;
    proxy_set_header        Connection "upgrade";
    proxy_set_header        Host 127.0.0.1:8081;
    proxy_set_header        X-Real-IP $remote_addr;
    proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header        X-Forwarded-Proto $scheme;
    proxy_http_version      1.1;
    proxy_read_timeout      3600s;
    proxy_send_timeout      3600s;
    proxy_connect_timeout   3600s;
    proxy_buffering         off;
    proxy_cache             off;
    client_max_body_size    10M;
    proxy_pass              http://127.0.0.1:8081/;
  }
'

tmp="$(mktemp)"
# shellcheck disable=SC2016
awk -v snippet="$snippet" '
  /^  error_page 500 502 503 504 \/50x.html;/ { print snippet }
  { print }
' "$conf" >"$tmp"
mv "$tmp" "$conf"
