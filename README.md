# relab

Selkies XFCE Desktop with Ghidra and LaurieWired GhidraMCP. Law is `SPEC.md`.

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
