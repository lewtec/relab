#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

cat >"$tmp" <<'EOF'
server {
  listen 3000;
  location SUBFOLDERpelorus/ {
    proxy_pass http://127.0.0.1:5100/;
  }
  error_page 500 502 503 504 /50x.html;
}
server {
  listen 3001 ssl;
  location SUBFOLDERpelorus/ {
    proxy_pass http://127.0.0.1:5100/;
  }
  error_page 500 502 503 504 /50x.html;
}
EOF

bash "$root/scripts/inject-mcp-nginx.sh" "$tmp"
count="$(grep -c 'location SUBFOLDERmcp/' "$tmp")"
if [[ "$count" -ne 2 ]]; then
  echo "expected 2 mcp locations, got ${count}" >&2
  exit 1
fi
grep -q 'proxy_pass              http://127.0.0.1:8081/;' "$tmp"
grep -q 'proxy_set_header        Host 127.0.0.1:8081;' "$tmp"
echo ok
