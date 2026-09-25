# syntax=docker/dockerfile:1@sha256:ecfaec9ed6d810b56388c508f4121597bfbba70d41a6dfeee4d8cad5f295fc32
FROM lscr.io/linuxserver/webtop:debian-xfce@sha256:9b8c8d5f30c9c7e1e7ac044b349d98252b0c07a9cc828ba0f05a37c075069ddf

ENV TITLE=relab \
    MISE_DATA_DIR=/mise \
    MISE_CONFIG_DIR=/mise \
    MISE_CACHE_DIR=/mise/cache \
    MISE_INSTALL_PATH=/usr/local/bin/mise \
    MISE_YES=1 \
    PATH="/mise/shims:${PATH}"

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    python3 \
    python3-pip \
    python3-venv \
    unzip \
  && rm -rf /var/lib/apt/lists/*

RUN HOME=/root curl --proto '=https' --fail --silent --show-error --location https://mise.run | sh

COPY mise.toml /mise/mise.toml
COPY scripts/bake-ghidra.sh /tmp/bake-ghidra.sh

RUN chmod +x /tmp/bake-ghidra.sh \
  && mise trust /mise/mise.toml \
  && mise --cd /mise install \
  && /tmp/bake-ghidra.sh \
  && rm -f /tmp/bake-ghidra.sh \
  && rm -rf /mise/cache /root/.cache

COPY scripts/inject-mcp-nginx.sh /tmp/inject-mcp-nginx.sh
RUN chmod +x /tmp/inject-mcp-nginx.sh \
  && /tmp/inject-mcp-nginx.sh /defaults/default.conf \
  && rm -f /tmp/inject-mcp-nginx.sh

COPY root/ /
RUN chmod +x \
    /etc/s6-overlay/s6-rc.d/init-relab/run \
    /etc/s6-overlay/s6-rc.d/svc-ghidra-mcp/run \
    /opt/ghidra-mcp/run-bridge.py \
  && mkdir -p /data

EXPOSE 3000 3001 8081
VOLUME /config /data
