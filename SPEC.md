# relab Specification

This document constrains the OCI Image and Compose apply that put Ghidra and LaurieWired GhidraMCP on a linuxserver Selkies XFCE Desktop.

Status: approved
Genre: infra

The key words MUST, MUST NOT, SHOULD, SHOULD NOT, and MAY in this
document are to be interpreted as described in BCP 14 (RFC 2119,
RFC 8174) when, and only when, they appear in all capitals.

## Intention

Job: This repo ships an OCI Image for a headless host. The Image serves a Selkies XFCE Desktop with Ghidra and LaurieWired GhidraMCP installed. A model client attaches over HTTP MCP. Ghidra runs as a live server. The host stays clean.

Non-goals:

1. A general webtop product (office suite as the product).
2. A kitchen-sink reverse-engineering distro.
3. SealSkin multi-user VDI.
4. Official Ghidra Server (shared repos on 13100–13102).
5. Rebuilding the linuxserver Selkies Desktop stack.
6. Installing Ghidra on the host.
7. Building Ghidra from source.
8. This repo shipping a Front (authenticating reverse proxy).
9. Nix flakes, NixOS modules, `dockerTools`, `nix2container`, and any Nix store inside the Image. Nix is out of scope.
10. First-party authentication on the Desktop.
11. First-party authentication on the Bridge.

Inherited C (cite the file): none. The tree was empty when this constitution was written.

## Technique

| ID | Input | Rule | Output |
|----|-------|------|--------|
| TEC-01 | Image definition plus Compose file | The Image is the unit. The operator applies with Compose. The host has a container runtime and two bind directories. | One running container |
| TEC-02 | linuxserver XFCE Desktop image | Keep their XFCE session. Do not install a second desktop environment. | XFCE on Selkies HTTP 3000 and HTTPS 3001 |
| TEC-03 | One GUI Ghidra process plus plugin HTTP plus Bridge | Human and model share the open project. Plugin HTTP stays on container loopback. The Bridge is the MCP server. | Live Desktop view of the same database the model edits |
| TEC-04 | Bridge listening inside the container | Publish the MCP port. Add a Selkies nginx location that proxies the Bridge with buffering off. | MCP on host port 8081 and on the Selkies path `/mcp/` |
| TEC-05 | Two bind mounts | `/config` is the linuxserver home. `/data` is non-home data the operator passes in. No required subtree under `/data`. | Recreate keeps both mounts when they exist |
| TEC-06 | Compose flags | Unprivileged. No host Docker socket. No `--privileged`. `shm-size` set. GPU devices off by default. | Host blast is the two volumes and the published ports |
| TEC-07 | Compose environment | Do not set linuxserver `PASSWORD`. Do not add Bridge auth. A Front is out of this repo. | Unauthenticated Desktop and Bridge |
| TEC-08 | Pin file plus official archives | Image build runs mise. mise fetches the NSA PUBLIC zip, JDK 21, and the LaurieWired release zip. Place the extension in the Ghidra Extensions directory. | `ghidraRun` on PATH. Extension on disk |
| TEC-09 | s6 unit plus a Desktop note | The Bridge is an s6 service. Do not seed Ghidra tool config. The note tells the operator to start Ghidra and enable GhidraMCPPlugin. | Bridge is up at container start. Plugin HTTP starts after that human step |
| TEC-10 | One Image definition | amd64 is required. The same definition produces arm64 when the build host can emit it. No arch-specific packaging. | amd64 Image. arm64 Image when buildx can |

## Tooling

| TEC | Tool | Relation | We do not | Cite |
|-----|------|----------|-----------|------|
| TEC-01 | Docker Compose | adopt | invent an apply CLI | linuxserver webtop compose contract |
| TEC-02 | `lscr.io/linuxserver/webtop:debian-xfce` | adopt | install XFCE on `baseimage-selkies` | `linuxserver/docker-webtop` branch `debian-xfce` |
| TEC-03 | LaurieWired GhidraMCP plugin plus `bridge_mcp_ghidra.py` | adopt | write an MCP server | `github.com/LaurieWired/GhidraMCP` |
| TEC-04 | linuxserver nginx template (`/defaults/default.conf`) | wrap | replace Selkies routing | pelorus location in the same template |
| TEC-05 | linuxserver `/config` plus a second `/data` volume | wrap | invent a third volume | linuxserver webtop volume contract |
| TEC-06 | Compose `security_opt` unset, no socket mount | adopt | DinD | linuxserver webtop run flags |
| TEC-07 | linuxserver default (no `PASSWORD`) | adopt | invent basic-auth. Invent a bearer wrap. | linuxserver Selkies auth docs |
| TEC-08 | mise GitHub backend, mise HTTP backend, mise Java | adopt | `curl \| unzip` in the Dockerfile; Nix | https://mise.jdx.dev/dev-tools/backends/ |
| TEC-08 | NSA Ghidra PUBLIC zip | adopt | distro `ghidra` package; nixpkgs `ghidra` | https://github.com/NationalSecurityAgency/ghidra#install |
| TEC-08 | Ghidra Extensions directory extract | adopt | GUI-only Install Extensions as the bake step | Ghidra Installation Guide, Extensions |
| TEC-09 | linuxserver s6-overlay | wrap | systemd on the host | linuxserver s6 service layout |
| TEC-09 | XFCE desktop note | implement | seed CodeBrowser tool config | none |
| TEC-10 | webtop multi-arch manifest plus one PUBLIC zip | adopt | a second Dockerfile | linuxserver webtop tags; Ghidra PUBLIC zip |

| Cell | Pick | C or D | Implements | Cite if C |
|------|------|--------|------------|-----------|
| Language | POSIX shell for s6 and bake glue | D | TEC-09 | |
| Runtime | linuxserver s6-overlay inside the Image | D | TEC-09 | |
| Persistence | `/config` and `/data` | D | TEC-05 | |
| UI | Selkies plus XFCE plus Ghidra | D | TEC-02 TEC-03 | |
| Packaging | Dockerfile `FROM` webtop. Compose apply. | D | TEC-01 TEC-02 | |
| Identity | none in this repo | D | TEC-07 | |
| Host OS | Linux with a container runtime | D | TEC-01 TEC-06 | |

## Terminology

| Concept | Approved | Banned |
|---------|----------|--------|
| Image | Image | container OS, Nix image, flake output |
| Compose | Compose | helm chart, NixOS module, runbook |
| Desktop | Desktop | webtop (the product), kiosk, VDI |
| Plugin HTTP | Plugin HTTP | Ghidra Server, MCP |
| Bridge | Bridge | plugin, MCP inside Ghidra |
| MCP port | MCP port | plugin port, 8080 |
| Selkies route | Selkies route | websocket, pelorus |
| Home volume | Home volume | `$HOME`, profile |
| Data volume | Data volume | inbox, projects volume |
| Operator | Operator | user, admin, developer |
| Front | Front | SWAG, this image's auth |

Plugin HTTP is LaurieWired's Java HTTP API. It is not MCP. The Bridge speaks MCP (SSE).

## Types

| Policy | Apply target | Blast radius | Out of this repo |
|--------|--------------|--------------|------------------|
| Bake the Image | Compose build | build-machine network and store | webtop layers, mise, NSA zip, LaurieWired zip |
| Apply | one Compose project on one host | Home volume, Data volume, published ports | container runtime, host firewall, Front |
| Desktop session | browser to ports 3000 and 3001 | anyone who can reach those ports | Selkies, XFCE |
| MCP attach | host port 8081 and Selkies route `/mcp/` | anyone who can reach those listeners | LaurieWired Bridge, MCP client, LLM |
| Persist | Home volume and Data volume | those two host directories | operator backups |

N/A: ER tables. Genre is infra.

## Invariants

| ID | Predicate | On | Forbidden bypass |
|----|-----------|----|------------------|
| INV-01 | The Image is webtop debian-xfce plus tools baked by mise. The Image has no Nix store. | Image | a flake. `dockerTools`. A from-scratch Desktop. |
| INV-02 | Compose apply is the apply contract. | Apply | a required NixOS module |
| INV-03 | Home volume is `/config`. Data volume is `/data`. No third required volume. | Persist | putting required state only outside those two |
| INV-04 | Plugin HTTP is not published. The Bridge is the published MCP. | MCP attach | publishing container port 8080 |
| INV-05 | The container is unprivileged. It has no host Docker socket. | Apply | `--privileged`, `/var/run/docker.sock` |
| INV-06 | This Image does not authenticate. | Desktop, MCP attach | requiring `PASSWORD`, wrapping the Bridge with a token this repo invents |
| INV-07 | One live GUI Ghidra is the analysis process. Human and model share it. | Desktop | a second headless Ghidra as the v1 server |
| INV-08 | The Bridge starts with the container. Plugin HTTP starts after the operator enables the plugin. | TEC-09 | seeding Ghidra tool config in v1 |

## Errors

| Public operation | Bad input | One reaction |
|------------------|-----------|--------------|
| Compose build | bad pin, bad checksum, failed `FROM` pull | build exits non-zero; no Image tag |
| Compose up | host port already bound | Compose fails; no extra host writes |
| Compose up | `PASSWORD` unset | container starts; Desktop is open |
| MCP client while Plugin HTTP is down | Bridge up, Plugin HTTP down | LaurieWired error string. The Desktop note is the operator fix. |
| Data volume omitted | no bind | container starts; `/data` is an empty directory in the writable layer |

## Public contract

The Compose file this repo ships MUST declare:

| Kind | Value |
|------|--------|
| Desktop HTTP | container 3000 |
| Desktop HTTPS | container 3001 |
| MCP port | container 8081 |
| Selkies route | `/mcp/` → Bridge, `proxy_buffering off` |
| Home volume | `/config` |
| Data volume | `/data` |
| Shared memory | `shm-size` of at least 1gb |
| Privilege | no `--privileged`, no Docker socket |

The Compose file MUST NOT set `PASSWORD`.

The operator attaches an MCP client at `http://<host>:8081/sse`. The same Bridge is also at `https://<host>:3001/mcp/sse`.

Plugin HTTP remains on container loopback port 8080.

linuxserver `PUID`, `PGID`, and `TZ` MAY appear. They do not authenticate.

## Actors

| Actor | Obligations |
|-------|-------------|
| Operator | Builds the Image. Applies Compose. Mounts volumes. Opens the Desktop. Enables the plugin. Attaches the MCP client. Places a Front when the listeners must not be open. |

## Capabilities

| ID | Actor | Sea-level goal |
|----|-------|----------------|
| CAP-01 | Operator | Build the Image from this repo |
| CAP-02 | Operator | Apply Compose on a headless host |
| CAP-03 | Operator | Open the Desktop in a browser |
| CAP-04 | Operator | Bind the Data volume to host files they want inside the session |
| CAP-05 | Operator | Attach an MCP client to the Bridge after Ghidra and the plugin are on |
| CAP-06 | Operator | Read the Desktop note for the enablement step |

## Quality

| Concern | Measure, or why it cannot happen |
|---------|----------------------------------|
| secrets | This repo stores no credentials. Compose does not set `PASSWORD`. The Bridge has no auth. A Front is out of this repo. |
| blast | Apply is unprivileged. Blast is Home volume, Data volume, and the three published ports. GPU and Docker socket stay off. |
| apply failure | Compose exits non-zero on bake failure and on up failure. Apply does not write outside the named volumes. |

## Security

In scope: published Desktop ports and the MCP port are reachable with no credential this repo issues. linuxserver passwordless sudo inside the container is theirs.

Why first-party auth cannot happen: TEC-07. The operator places a Front when the listeners must not be open.

Residual risk: anyone who reaches the published ports has the Desktop (including an in-browser terminal with sudo) and can call Bridge tools on the open project.

## Success

- [ ] Compose up on a host with a container runtime yields XFCE at HTTPS port 3001. The host has no Ghidra package.
- [ ] Ghidra is on the Desktop PATH after a clean pull of the Image.
- [ ] After the operator starts Ghidra and enables the plugin, the Bridge accepts an SSE MCP client on port 8081.
- [ ] The same Bridge is reachable on the Selkies route `/mcp/sse`.
- [ ] Plugin HTTP is not reachable on a published host port.
- [ ] Recreate with the same two binds keeps Home volume state and Data volume files.
- [ ] The Image contains no `/nix/store`.
- [ ] Compose starts when `PASSWORD` is unset.

## Later work

1. Binary Ninja.
2. Official Ghidra Server.
3. Streamable-HTTP if LaurieWired adds it.
4. Seeding the plugin so the Bridge works with no GUI click.
5. Kitchen-sink reverse-engineering tools.
6. SealSkin.
7. Headless-only Ghidra.
8. First-party Bridge auth.

## Assumptions

| ID | Fact | If false |
|----|------|----------|
| AS-01 | LaurieWired Plugin HTTP starts only after GhidraMCPPlugin is enabled in the GUI tool. | CAP-05 stays blocked until that changes. INV-08 still holds. |
| AS-02 | The official PUBLIC zip contains linux amd64 and linux arm64 native bits in one archive. | Drop arm64. amd64 still ships. |
| AS-03 | `webtop:debian-xfce` stays a Selkies XFCE image. | TEC-02 needs a new adopt of the replacement tag. |
| AS-04 | FastMCP SSE keeps `/sse` and `/messages`. | TEC-04 location is updated to the new paths. |

## Decision history

- ADR-0001: The Image is Dockerfile `FROM` webtop. Rejected: Nix as image OS. Rejected: Nix as build orchestrator.
- ADR-0002: Apply is passwordless. Rejected: required `PASSWORD` and a first-party Bridge token.
