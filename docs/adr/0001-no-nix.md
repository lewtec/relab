# ADR-0001: No Nix

Status: accepted

The Image is a Dockerfile `FROM lscr.io/linuxserver/webtop:debian-xfce`. Bake uses mise. Apply is Compose.

Rejected: a flake as the build orchestrator, `dockerTools`, `nix2container`, a NixOS module as the apply contract, and a Nix store inside the Image.

Nix rebuilds of Selkies were refused because linuxserver already owns that stack. A flake that only pins fetch URLs was refused because the Dockerfile pin is enough.
