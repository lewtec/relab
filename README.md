# relab

Selkies XFCE Desktop with Ghidra and LaurieWired GhidraMCP. Law is `SPEC.md`.

## Image

CI builds `linux/amd64` and pushes `ghcr.io/<owner>/relab` on `master`/`main` and on `v*` tags. Pull requests run the checks and bake the image without pushing.

```
docker pull ghcr.io/<owner>/relab:latest
```

Point `image:` in `docker-compose.yml` at that tag when you do not want to bake locally.

## Apply

```
docker compose up --build
```

Open `https://localhost:3001` and accept the self-signed certificate.

MCP:

- `http://localhost:8081/sse`
- `https://localhost:3001/mcp/sse`

Enable GhidraMCPPlugin in Ghidra after first start. The Desktop note has the steps.

Binds: `./config` → `/config` (home), `./data` → `/data`.

No password. Place a Front if the ports must not be open.

## Tailnet (ts-proxy)

Optional overlay. `ghcr.io/lucasew/ts-proxy:0.14.0` wraps the relab container as one tailnet node (`forward: relab`). Every TCP port on the container is the same port on `<RELAB_HOSTNAME>.<tailnet>.ts.net`.

`RELAB_HOSTNAME` is the Tailscale node name. Default is `relab`. ts-proxy expands it from the environment. Use a different value per instance, and a distinct compose project so names do not clash.

```
RELAB_HOSTNAME=lab-alice RELAB_CONFIG=./alice/config RELAB_DATA=./alice/data \
  docker compose -p lab-alice -f docker-compose.yml -f compose.tailscale.yml up
```

Watch `<RELAB_HOSTNAME>-ts-proxy` logs for the first-run login URL. Tailscale state is `./ts-proxy-state/<RELAB_HOSTNAME>`. The overlay does not publish host ports.

- Desktop: `https://<RELAB_HOSTNAME>.<tailnet>.ts.net:3001`
- Desktop HTTP: `http://<RELAB_HOSTNAME>.<tailnet>.ts.net:3000`
- MCP: `http://<RELAB_HOSTNAME>.<tailnet>.ts.net:8081/sse`

Config is `examples/ts-proxy.yaml`. Funnel is off. To use an auth key, set `TS_AUTHKEY` and uncomment the `tokens` block in that file.
