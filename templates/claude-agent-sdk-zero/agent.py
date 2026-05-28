#!/usr/bin/env python3
# 한국어 역할 주석: <PROJECT-NAME> 의 Claude Agent SDK 진입 스크립트.
# Solon 7-step flow 와 solon-safe permission preset 을 기본값으로 적재한다.

"""<PROJECT-NAME> — <DOMAIN> agent built on the Claude Agent SDK,
wired to the Solon 7-step methodology via the solon-mcp bridge.

Run:

    export ANTHROPIC_API_KEY=...
    python agent.py "<your request>"

The agent will:

1. Read SFS.md + .sfs-local/divisions.yaml to learn this project.
2. Call `sfs_status` (verbatim) to see the current sprint.
3. Route the request through the 7-step flow:
       brainstorm → plan → implement → review → retro
4. Stop at Gate 6 and ask the human to confirm before any merge / push.

This file is intentionally short. The interesting policy lives in
`system_prompt.md` and `solon-safe-permissions.yaml`.
"""

from __future__ import annotations

import asyncio
import os
import sys
from pathlib import Path

try:
    import yaml
except ImportError as exc:  # pragma: no cover
    raise SystemExit(
        "pyyaml is required. Install with: pip install -e .[dev]"
    ) from exc

try:
    # The Agent SDK's public surface has changed a few times across early
    # 0.x releases; the imports below match the most common shape at the
    # time this template was cut. Adjust to whatever your installed
    # version exposes.
    from claude_agent_sdk import ClaudeSDKClient, AgentOptions  # type: ignore
except ImportError as exc:  # pragma: no cover
    raise SystemExit(
        "claude-agent-sdk is required. Install with: pip install -e ."
    ) from exc


HERE = Path(__file__).resolve().parent
PROJECT_NAME = "<PROJECT-NAME>"
DOMAIN = "<DOMAIN>"


def load_system_prompt() -> str:
    """Read the version-controlled system prompt verbatim. Runtime
    overlays are appended AFTER this string, never blended into it."""
    return (HERE / "system_prompt.md").read_text(encoding="utf-8")


def load_permissions() -> dict:
    """Load the solon-safe permission preset. Hosts that natively
    consume the YAML can pass this dict through directly; hosts that
    want a different shape should translate here."""
    with (HERE / "solon-safe-permissions.yaml").open(encoding="utf-8") as fh:
        return yaml.safe_load(fh)


def build_options() -> AgentOptions:
    """Compose the AgentOptions: solon-mcp registered as `solon`,
    system prompt loaded from disk, permission posture inherited from
    the Solon-safe preset."""
    permissions = load_permissions()

    # Pre-approve only the read-only Solon surface up front. Mutating
    # tools (sfs_start, sfs_review, etc.) go through the host's
    # ask-approval flow per call.
    pre_approved = list(permissions.get("tools", {}).get("pre_approved", []))

    return AgentOptions(
        system_prompt=load_system_prompt(),
        mcp_servers={
            # The Solon MCP bridge. Install with `pip install solon-mcp`.
            "solon": {
                "command": "solon-mcp",
                "transport": "stdio",
            },
        },
        pre_approved_tools=pre_approved,
        # Host-side denial list straight from the preset.
        denied_tools=list(permissions.get("tools", {}).get("denied", [])),
    )


async def run(prompt: str) -> int:
    """One-shot agent invocation. For interactive multi-turn use,
    swap to the streaming `ClaudeSDKClient` pattern from the SDK docs."""
    options = build_options()
    async with ClaudeSDKClient(options=options) as client:
        async for message in client.query(prompt):
            # The SDK delivers structured messages; for the smoke
            # template we just print text deltas. Replace with your
            # rendering of choice (Rich, structured logging, etc.).
            text = getattr(message, "text", None)
            if text:
                print(text, end="", flush=True)
        print()
    return 0


def main() -> int:
    """CLI entrypoint. Reads the prompt from argv. Exits non-zero on
    missing API key so CI / supervisor scripts can detect it."""
    if not os.environ.get("ANTHROPIC_API_KEY"):
        print(
            f"{PROJECT_NAME}: ANTHROPIC_API_KEY is not set.\n"
            "Export it before running, e.g.:\n"
            "    export ANTHROPIC_API_KEY=<your-anthropic-api-key>\n",
            file=sys.stderr,
        )
        return 1

    if len(sys.argv) < 2:
        print(
            f"usage: {sys.argv[0]} \"<request>\"\n"
            f"example: {sys.argv[0]} \"Help me draft a plan for X\"\n",
            file=sys.stderr,
        )
        return 2

    prompt = " ".join(sys.argv[1:])
    return asyncio.run(run(prompt))


if __name__ == "__main__":
    raise SystemExit(main())
