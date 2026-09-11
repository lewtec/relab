#!/usr/bin/env python3
"""Run LaurieWired bridge with Host checks that accept the tailnet name."""

from mcp.server.fastmcp import FastMCP
from mcp.server.transport_security import TransportSecuritySettings

_orig_init = FastMCP.__init__


def _init(self, *args, **kwargs):
    kwargs.setdefault(
        "transport_security",
        TransportSecuritySettings(enable_dns_rebinding_protection=False),
    )
    return _orig_init(self, *args, **kwargs)


FastMCP.__init__ = _init

import runpy

runpy.run_path("/opt/ghidra-mcp/bridge_mcp_ghidra.py", run_name="__main__")
