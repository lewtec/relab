# ADR-0002: Passwordless apply

Status: accepted

The Compose file does not set linuxserver `PASSWORD`. This repo does not authenticate the Desktop or the Bridge.

Rejected: fail-closed init when `PASSWORD` is empty, nginx basic-auth in front of the Bridge, and a bearer wrap this repo would own.

The operator places a Front when the published ports must not be open. That Front is out of this repo.
