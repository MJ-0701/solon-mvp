"""Smoke tests for the <PROJECT-NAME> agent scaffold.

These do not require an API key or network access. They verify that
the scaffold loads cleanly, the system prompt is non-empty, the
permission preset parses, and the MCP server registration shape is
present in agent.py.
"""

from __future__ import annotations

import importlib.util
from pathlib import Path

import yaml


HERE = Path(__file__).resolve().parents[1]


def _load_agent_module():
    spec = importlib.util.spec_from_file_location("agent", HERE / "agent.py")
    assert spec is not None, "could not load agent.py"
    module = importlib.util.module_from_spec(spec)
    # We deliberately do NOT exec_module here — that would import the
    # Agent SDK, which the smoke environment may not have installed.
    # Instead we statically inspect the source.
    return spec, module


def test_agent_py_exists_and_is_python():
    """agent.py exists, has a __main__ guard, and references the SDK."""
    src = (HERE / "agent.py").read_text(encoding="utf-8")
    assert "if __name__ == \"__main__\":" in src
    assert "from claude_agent_sdk" in src
    assert "load_system_prompt" in src
    assert "load_permissions" in src


def test_system_prompt_nonempty_and_solon_aware():
    """The system prompt is version-controlled and inherits Solon rules."""
    src = (HERE / "system_prompt.md").read_text(encoding="utf-8")
    assert len(src) > 200, "system prompt looks empty / placeholder-only"
    # Spot-check the load-bearing principles.
    for token in (
        "Bash adapter SSoT",
        "Mainline-first",
        "Gate 6 before merge",
        "Korean-first projects",
        "stop contract",
    ):
        assert token in src, f"system prompt missing principle: {token}"


def test_permission_preset_parses_and_denies_auto_push():
    """The permission preset is valid YAML and denies git push by default."""
    with (HERE / "solon-safe-permissions.yaml").open(encoding="utf-8") as fh:
        data = yaml.safe_load(fh)
    assert data["version"].startswith("0.7."), "preset version drift"
    denied = data["tools"]["denied"]
    assert "bash:git push*" in denied, "Solon-safe preset must deny git push"
    assert "bash:rm -rf *" in denied, "Solon-safe preset must deny rm -rf"
    workflow = data["workflow"]
    assert workflow["mainline_first"] is True
    assert workflow["require_gate_6"] is True


def test_mcp_server_registration_shape():
    """agent.py registers the Solon MCP server under the name `solon`."""
    src = (HERE / "agent.py").read_text(encoding="utf-8")
    assert '"solon"' in src, "MCP server must be registered under the name 'solon'"
    assert '"command": "solon-mcp"' in src, "MCP server must launch via the solon-mcp binary"
    assert '"transport": "stdio"' in src, "MCP server must use stdio transport"


def test_pyproject_has_required_dependencies():
    """The scaffold pins the Solon MCP and Agent SDK as runtime deps."""
    src = (HERE / "pyproject.toml").read_text(encoding="utf-8")
    assert 'claude-agent-sdk' in src
    assert 'solon-mcp' in src
    assert 'pyyaml' in src


def test_no_secrets_committed():
    """The scaffold does not ship any obvious secret material."""
    for path in HERE.rglob("*"):
        if not path.is_file():
            continue
        if path.suffix in {".pyc",}:
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        # Markers below are split so this test file itself does not match the
        # repo-wide hygiene scan that looks for `sk` + `-ant-` etc.
        markers = ("sk" + "-ant-", "sk" + "-proj-", "gh" + "p_", "AI" + "zaSy")
        for marker in markers:
            assert marker not in text, f"possible secret leaked in {path}: {marker}"
