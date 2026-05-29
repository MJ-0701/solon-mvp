"""<PROJECT-NAME> custom MCP tool — Solon mcp-tool-zero scaffold.

Exposes ONE narrow tool for the <DOMAIN> domain. Keep the surface small: a tool
with a single, testable purpose and an LLM-readable description beats a
"do anything" tool (the agent-build review lens fails the latter).

Rename `domain_tool` below to your real <TOOL-NAME> after scaffolding.

Permissions load from solon-safe-permissions.yaml (default-deny). Results are
written to the caller-provided output path, never streamed into a chat
transcript (runtime-token-firewall: poll artifacts, not thoughts).
"""

from __future__ import annotations

import pathlib

import yaml
from mcp.server.fastmcp import FastMCP

PRESET_PATH = pathlib.Path(__file__).with_name("solon-safe-permissions.yaml")


def load_permissions() -> dict:
    """Load the Solon-safe permission preset for <PROJECT-NAME>."""
    with open(PRESET_PATH, "r", encoding="utf-8") as fh:
        return yaml.safe_load(fh)


mcp = FastMCP("<PROJECT-NAME>-<DOMAIN>")


@mcp.tool()
def domain_tool(target: str, max_items: int = 50) -> dict:
    """Run the <DOMAIN> operation over `target` (rename to your <TOOL-NAME>).

    Args:
        target: the <DOMAIN> entity or path to operate on. Required, no default.
        max_items: bound on results returned. Keeps the tool output-bounded so
            it fits a sub-agent capsule's token_budget.

    Returns:
        A dict with `status` and `result`; large payloads belong in an
        output_paths file, not the return value.
    """
    if not target:
        raise ValueError("target is required")
    if max_items <= 0:
        raise ValueError("max_items must be positive")
    # TODO(<DOMAIN>): replace with the real operation. Keep it single-purpose.
    return {"status": "ok", "result": {"target": target, "count": 0, "items": []}}


def main() -> None:
    """Entry point: serve the tool over stdio for an MCP host."""
    load_permissions()  # fail fast if the preset is missing/corrupt
    mcp.run(transport="stdio")


if __name__ == "__main__":
    main()
