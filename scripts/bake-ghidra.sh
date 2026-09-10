#!/usr/bin/env bash
# After mise install: put the extension in Ghidra and the Bridge in /opt/ghidra-mcp.
set -euo pipefail

find_ghidra_home() {
  local root
  root="$(mise where 'github:NationalSecurityAgency/ghidra')"
  if [[ -x "${root}/ghidraRun" ]]; then
    printf '%s\n' "$root"
    return
  fi
  local run
  run="$(find "$root" -name ghidraRun -type f | head -n 1)"
  if [[ -z "$run" ]]; then
    echo "ghidraRun not found under ${root}" >&2
    exit 1
  fi
  dirname "$run"
}

find_mcp_home() {
  local root
  root="$(mise where 'github:LaurieWired/GhidraMCP')"
  if [[ -f "${root}/bridge_mcp_ghidra.py" ]]; then
    printf '%s\n' "$root"
    return
  fi
  local bridge
  bridge="$(find "$root" -name bridge_mcp_ghidra.py -type f | head -n 1)"
  if [[ -z "$bridge" ]]; then
    echo "bridge_mcp_ghidra.py not found under ${root}" >&2
    exit 1
  fi
  dirname "$bridge"
}

ghidra_home="$(find_ghidra_home)"
mcp_home="$(find_mcp_home)"
ext_zip="$(find "$mcp_home" -name 'GhidraMCP-*.zip' ! -name '*release*' -type f | head -n 1)"
if [[ -z "$ext_zip" ]]; then
  echo "GhidraMCP extension zip not found under ${mcp_home}" >&2
  exit 1
fi

mkdir -p "${ghidra_home}/Ghidra/Extensions"
unzip -o -d "${ghidra_home}/Ghidra/Extensions" "$ext_zip"

python3 -m venv /opt/ghidra-mcp
/opt/ghidra-mcp/bin/pip install --no-cache-dir 'requests>=2,<3' 'mcp>=1.2.0,<2'
cp "${mcp_home}/bridge_mcp_ghidra.py" /opt/ghidra-mcp/bridge_mcp_ghidra.py
chmod 755 "${ghidra_home}/ghidraRun" /opt/ghidra-mcp/bridge_mcp_ghidra.py

cat >/usr/local/bin/ghidraRun <<EOF
#!/bin/bash
export PATH="/mise/shims:\${PATH}"
export JAVA_HOME="\$(mise where java)"
exec "${ghidra_home}/ghidraRun" "\$@"
EOF
chmod 755 /usr/local/bin/ghidraRun
chmod -R a+rX /mise
chown -R abc:abc /opt/ghidra-mcp
