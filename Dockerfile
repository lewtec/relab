# syntax=docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e
FROM lscr.io/linuxserver/webtop:debian-xfce@sha256:2de7b2cb2f9e55fde54e07a83ffeb4f09cac846f1219896dd3d44de7d0aa9731

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
